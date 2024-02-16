using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using SeferNet.DataLayer;
using Clalit.SeferNet.GeneratedEnums;
using SeferNet.BusinessLayer.BusinessObject;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class ReceptionHoursManager
    {
        private const string CN_Fields_Joint = "_";
        private const string CN_Fields_DELIMETER = ",";
        private const string CN_Fields_DELIMETER2 = "#";
        private string m_ConnStr;
        private DataTable _deptsAddresses;

        public ReceptionHoursManager()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang();
        }


        /// <summary>
        /// ran's method - without rank from DB
        /// </summary>
        /// <param name="receptionDt"></param>
        public void GenerateGridTable(ref DataTable receptionDt)
        {
            int currPrimaryProfessionCode, currSecondaryProfessionCode, primaryNumOfRecs, secondaryNumOfRecs;
            List<DataRow> deletedRows = new List<DataRow>();
            bool professionsHaveSameHours;
            string professionName;


            for (int i = 0; i < receptionDt.Rows.Count; i++)
            {
                currPrimaryProfessionCode = Convert.ToInt32(receptionDt.Rows[i]["ProfessionOrServiceCode"]);
                primaryNumOfRecs = Convert.ToInt32(receptionDt.Rows[i]["ReceptionDaysInDept"]);


                for (int j = i + 1; j < receptionDt.Rows.Count; j++)
                {
                    currSecondaryProfessionCode = Convert.ToInt32(receptionDt.Rows[j]["ProfessionOrServiceCode"]);
                    secondaryNumOfRecs = Convert.ToInt32(receptionDt.Rows[j]["ReceptionDaysInDept"]);
                    if (currPrimaryProfessionCode != currSecondaryProfessionCode && secondaryNumOfRecs == primaryNumOfRecs
                                                && !deletedRows.Contains(receptionDt.Rows[j]) && !deletedRows.Contains(receptionDt.Rows[i]))
                    {
                        DataRow[] firstRowsArr = receptionDt.Select("ProfessionOrServiceCode=" + currPrimaryProfessionCode.ToString(), 
                                                                                                                "receptionDay, openingHour");
                        DataRow[] secondRowsArr = receptionDt.Select("ProfessionOrServiceCode=" + currSecondaryProfessionCode.ToString(),
                                                                                                                "receptionDay, openingHour");
                        

                        professionsHaveSameHours = CheckIfTablesHasSameHours(firstRowsArr, secondRowsArr);

                        if (professionsHaveSameHours)
                        {
                            professionName = secondRowsArr[0]["ProfessionOrServiceDescription"].ToString();

                            for (int k = 0; k < secondRowsArr.Length; k++)
                            {
                                deletedRows.Add(secondRowsArr[k]);
                            }

                            for (int k = 0; k < firstRowsArr.Length; k++)
                            {
                                firstRowsArr[k]["ProfessionOrServiceDescription"] = firstRowsArr[k]["ProfessionOrServiceDescription"] + " , " + professionName;
                            }
                        }
                    }
                }
            }

            foreach (DataRow row in deletedRows)
            {
                row.Delete();
            }

            // order by A-B and save the datatable to viewstate so we can use it on data bind
            receptionDt.AcceptChanges();
            receptionDt.DefaultView.Sort = "ProfessionOrServiceDescription ASC";          
        }

        public DataTable GenerateGridTable(ref DataTable inputDt, ref DataTable groupingDt)
        {
            DataRow viewdr = null, groupRow;
            DataTable viewtbl = CreateViewDataTable();
            int match_i = 0, recRank = 0;
            string filterSetting;
            DataRow[] groupData;


            for (int i = 0; i < groupingDt.Rows.Count; i++)
            {
                filterSetting = string.Empty;
                groupRow = groupingDt.Rows[i];

                if (CheckRelevantValidDatesForToday(groupingDt.Rows[i], false))
                {
                    if (groupingDt.Columns.Contains("DeptCode") && groupingDt.Rows[i]["DeptCode"] != null)
                    {
                        filterSetting = "DeptCode  = " + groupingDt.Rows[i]["DeptCode"].ToString();
                    }

                    if (groupingDt.Columns.Contains("openingHour") && groupingDt.Rows[i]["openingHour"] != null)
                    {
                        filterSetting += " and openingHour = '" + groupingDt.Rows[i]["openingHour"].ToString() + "' ";
                    }

                    if (groupingDt.Columns.Contains("closingHour") && groupingDt.Rows[i]["closingHour"] != null)
                    {
                        filterSetting += " and closingHour = '" + groupingDt.Rows[i]["closingHour"].ToString() + "' ";
                    }



                    if (groupingDt.Columns.Contains("remarkText") && !string.IsNullOrEmpty(groupingDt.Rows[i]["remarkText"].ToString()))
                    {
                        filterSetting += " and remarkText = '" + groupingDt.Rows[i]["remarkText"].ToString() + "' ";
                    }

                    if (groupingDt.Columns.Contains("ItemID") && groupingDt.Rows[i]["ItemID"] != DBNull.Value)
                        filterSetting += " and ItemID = " + groupingDt.Rows[i]["ItemID"].ToString();

                    if (groupingDt.Columns.Contains("ValidFrom"))
                    {
                        if (groupingDt.Rows[i]["ValidFrom"] == DBNull.Value)
                            filterSetting += " and ValidFrom is null ";
                        else
                        {
                            DateTime validFromDate = Convert.ToDateTime(groupingDt.Rows[i]["ValidFrom"]);

                            filterSetting += " and ValidFrom = '" + Convert.ToDateTime(groupingDt.Rows[i]["ValidFrom"]) + "'";
                        }
                    }

                    if (groupingDt.Columns.Contains("ValidTo"))
                    {
                        if (groupingDt.Rows[i]["ValidTo"] == DBNull.Value)
                            filterSetting += " and ValidTo is null ";
                        else
                        {
                            DateTime validToDate = Convert.ToDateTime(groupingDt.Rows[i]["ValidTo"]);
                            filterSetting += " and ValidTo = '" + validToDate + "'";
                        }
                    }



                    if (filterSetting.Trim().StartsWith("and"))
                        filterSetting = filterSetting.Trim().Remove(0, 3);

                    if (recRank != Convert.ToInt16(groupRow["RecRank"]))
                    {
                        if (viewdr != null)
                        {
                            viewtbl.Rows.Add(viewdr);
                        }
                        viewdr = GetNewViewRow(viewtbl);
                        match_i = 0;
                        recRank = Convert.ToInt16(groupRow["RecRank"]);

                    }

                    groupData = inputDt.Select(filterSetting);
                    for (int j = 0; j < groupData.Length; j++)
                    {
                        match_i++;
                        AddDataRowtoViewRow(groupData[j], viewdr, match_i);
                    }
                   
                }
            }

            if (viewdr != null)
            {
                viewtbl.Rows.Add(viewdr);
            }

            viewtbl.DefaultView.Sort = "Days, OpeningHour ASC";

            return viewtbl.DefaultView.ToTable();
        }

        /// <summary>
        /// used in queue order hours grid
        /// </summary>
        /// <param name="hoursDt"></param>
        public void GenerateHoursGridTable(DataTable hoursDt)
        {

            List<DataRow> deletedDays = new List<DataRow>();
            bool daysHaveSameHours;
            int currDay, currSecondaryDay;
            DataRow firstRow, secondRow;

            // add columns to hold the united id's and days
            hoursDt.Columns.Add(new DataColumn("QueueOrderHoursIDTemp", typeof(string)));
            hoursDt.Columns.Add(new DataColumn("ReceptionDayTemp", typeof(string)));

            for (int i = 0; i < hoursDt.Rows.Count; i++)
            {
                // copy the values to the future columns
                hoursDt.Rows[i]["QueueOrderHoursIDTemp"] = hoursDt.Rows[i]["QueueOrderHoursID"];
                hoursDt.Rows[i]["ReceptionDayTemp"] = hoursDt.Rows[i]["ReceptionDay"];

                firstRow = hoursDt.Rows[i];
                currDay = Convert.ToInt32(hoursDt.Rows[i]["ReceptionDay"]);

                for (int j = i + 1; j < hoursDt.Rows.Count; j++)
                {
                    currSecondaryDay = Convert.ToInt32(hoursDt.Rows[j]["ReceptionDay"]);
                    secondRow = hoursDt.Rows[j];

                    if (currDay != currSecondaryDay && !deletedDays.Contains(hoursDt.Rows[j]))
                    {
                        daysHaveSameHours = CheckIfDaysHasSameHours(firstRow, secondRow);

                        if (daysHaveSameHours)
                        {
                            deletedDays.Add(secondRow);                                               
                            

                            firstRow["ReceptionDayTemp"] = firstRow["ReceptionDay"].ToString();
                            if (!string.IsNullOrEmpty(currSecondaryDay.ToString()))
                            {
                                firstRow["ReceptionDayTemp"] +=  "," + currSecondaryDay.ToString();
                            }
                            
                            
                            firstRow["QueueOrderHoursIDTemp"] = firstRow["QueueOrderHoursID"].ToString();
                            if (!string.IsNullOrEmpty(secondRow["QueueOrderHoursID"].ToString()))
                            {
                                firstRow["QueueOrderHoursIDTemp"] += "," + secondRow["QueueOrderHoursID"].ToString();
                            }
                        }
                    }
                }
            }

            foreach (DataRow row in deletedDays)
            {
                row.Delete();
            }

            // overwrite the old columns with the new ones
            hoursDt.Columns.Remove("ReceptionDay");
            hoursDt.Columns.Remove("QueueOrderHoursID");
            hoursDt.Columns["ReceptionDayTemp"].ColumnName = "Days";
            hoursDt.Columns["QueueOrderHoursIDTemp"].ColumnName = "QueueOrderHoursID";

            // order by hours and save the datatable to viewstate so we can use it on data bind
            hoursDt.AcceptChanges();
            hoursDt.DefaultView.Sort = "OpeningHour ASC";


            // get a list with unique professions to bind the professions headers
            //return GetUniqueProfessionsFromDataTable(ref receptionDt);
        }

        public DataTable GetUniqueProfessionsFromDataTable(ref DataTable receptionDt)
        {
            List<int> uniqueProfessionCodes = new List<int>();
            DataTable professionsDt = new DataTable();
            professionsDt.Columns.Add(new DataColumn("Code", typeof(int)));
            professionsDt.Columns.Add(new DataColumn("Desc", typeof(string)));

            foreach (DataRowView row in receptionDt.DefaultView)
            {
                if (!uniqueProfessionCodes.Contains(Convert.ToInt32(row["ProfessionOrServiceCode"])))
                {
                    DataRow dr = professionsDt.NewRow();
                    dr["Code"] = row["ProfessionOrServiceCode"];
                    dr["Desc"] = row["ProfessionOrServiceDescription"];

                    professionsDt.Rows.Add(dr);
                    uniqueProfessionCodes.Add(Convert.ToInt32(row["ProfessionOrServiceCode"]));
                }
            }

            uniqueProfessionCodes = null;

            return professionsDt;
        }

        /// <summary>
        /// generate grid table (data is grouped by),when the input is the table that was returned from the grid's ReturnData function
        /// </summary>
        /// <param name="receptionDt">data table</param>
        /// <param name="deptCode">required dept code</param>
        public void GenerateGridTableFromReturnData(ref DataTable receptionDt)
        {
            List<int> doneCodes = new List<int>();

            receptionDt.Columns["ItemId"].ColumnName = "ProfessionOrServiceCode";
            receptionDt.Columns["ItemDesc"].ColumnName = "ProfessionOrServiceDescription";
            receptionDt.Columns["remarkText"].ColumnName = "receptionRemarks";
            receptionDt.Columns.Add("ReceptionDaysInDept", typeof(int));

            SetDayNameToTable(receptionDt);


            for (int i = 0; i < receptionDt.Rows.Count; i++)
            {
                DateTime fromDate = DateTime.MinValue, toDate = DateTime.MaxValue;

                if (receptionDt.Rows[i]["validFrom"] != DBNull.Value)
                    fromDate = Convert.ToDateTime(receptionDt.Rows[i]["validFrom"]);

                if (receptionDt.Rows[i]["validTo"] != DBNull.Value)
                    toDate = Convert.ToDateTime(receptionDt.Rows[i]["validTo"]);

                if (string.IsNullOrEmpty(receptionDt.Rows[i]["ReceptionDay"].ToString()) ||
                    DateTime.Compare(fromDate, DateTime.Today) > 0 || DateTime.Compare(toDate, DateTime.Today) < 0)
                {
                    receptionDt.Rows[i].Delete();
                    continue;
                }

                if (!doneCodes.Contains(Convert.ToInt32(receptionDt.Rows[i]["ProfessionOrServiceCode"])))
                {
                    doneCodes.Add(Convert.ToInt32(receptionDt.Rows[i]["ProfessionOrServiceCode"]));

                    DataRow[] numOfRows = receptionDt.Select("ProfessionOrServiceCode=" + receptionDt.Rows[i]["ProfessionOrServiceCode"].ToString());

                    foreach (DataRow row in numOfRows)
                    {
                        row["ReceptionDaysInDept"] = numOfRows.Length;
                    }
                }

                CheckIfActive24Hours(receptionDt.Rows[i]);
            }

            receptionDt.AcceptChanges();

            GenerateGridTable(ref receptionDt);
        }

        /// <summary>
        /// returns data table with the unique days in the original table, as long as the dates are valid for toady
        /// </summary>
        /// <param name="originalDt"></param>
        /// <param name="columnName"></param>
        /// <returns></returns>
        public DataTable ReturnUniqueDaysTable(DataTable originalDt, string columnName)
        {
            DataTable dt = new DataTable();
            List<string> addedDays = new List<string>();
            string currDay;
            DataRow row;
            ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
            DataTable daysTbl = cacheHandler.getCachedDataTable(eCachedTables.DIC_ReceptionDays.ToString());

            dt.Columns.Add("ReceptionDayName");
            dt.Columns.Add(columnName);

            for (int i = 0; i < originalDt.Rows.Count; i++)
            {
                row = originalDt.Rows[i];

                if (CheckRelevantValidDatesForToday(row, true))
                {
                    currDay = originalDt.Rows[i][columnName].ToString();
                    if (!addedDays.Contains(currDay))
                    {
                        addedDays.Add(currDay);
                        DataRow dr = dt.NewRow();
                        dr["ReceptionDayName"] = daysTbl.Select("ReceptionDayCode=" + row[columnName].ToString())[0]["ReceptionDayName"].ToString(); ;
                        dr[columnName] = originalDt.Rows[i][columnName].ToString();
                        dt.Rows.Add(dr);
                    }
                }
            }
            addedDays = null;

            return dt;
        }

        public DataTable GetProfessionsAndServicesList(DataTable originalDt)
        {
            DataTable newDt = new DataTable();
            newDt.Columns.Add("ItemCode", typeof(int));
            newDt.Columns.Add("ItemDesc", typeof(string));
            newDt.Columns.Add("ItemType", typeof(string));
            newDt.Columns.Add("Deptcode", typeof(string));
            newDt.Columns.Add("DeptName", typeof(string));
            newDt.Columns.Add("AgreementType", typeof(string));

            for (int i = 0; i < originalDt.Rows.Count; i++)
            {
                if (originalDt.Rows[i]["ItemID"] != DBNull.Value)
                {
                    DataRow[] rows = newDt.Select("itemCode = " + originalDt.Rows[i]["ItemID"].ToString());

                    if (rows == null || rows.Length == 0)
                    {
                        DataRow newRow = newDt.NewRow();
                        newRow["ItemCode"] = Convert.ToInt32(originalDt.Rows[i]["ItemID"]);
                        newRow["ItemDesc"] = originalDt.Rows[i]["ItemDesc"].ToString();
                        newRow["ItemType"] = originalDt.Rows[i]["ItemType"].ToString();
                        newRow["DeptCode"] = originalDt.Rows[i]["DeptCode"].ToString();
                        newRow["DeptName"] = originalDt.Rows[i]["DeptName"].ToString();
                        newRow["AgreementType"] = originalDt.Rows[i]["AgreementType"].ToString();

                        newDt.Rows.Add(newRow);
                    }
                }
            }

            return newDt;
        }

        public DataTable GetUniqueProfessionsPerDays(DataTable daysDt)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add(new DataColumn("receptionDay", typeof(string)));
            dt.Columns.Add(new DataColumn("receptionDayName", typeof(string)));
            dt.Columns.Add(new DataColumn("professionOrServiceCode", typeof(string)));

            for (int i = 0; i < daysDt.Rows.Count; i++)
            {
                DataRow[] currDay = dt.Select("receptionDay=" + daysDt.Rows[i]["receptionDay"].ToString()
                    + " and professionOrServiceCode=" + daysDt.Rows[i]["professionOrServiceCode"].ToString());

                if (currDay == null || currDay.Length == 0)
                {
                    DataRow row = dt.NewRow();
                    row["receptionDay"] = daysDt.Rows[i]["receptionDay"];
                    row["receptionDayName"] = daysDt.Rows[i]["receptionDayName"];
                    row["professionOrServiceCode"] = daysDt.Rows[i]["professionOrServiceCode"];
                    dt.Rows.Add(row);
                }
            }

            return dt;
        }

        public void SetDayNameToTable(DataTable receptionDt)
        {
            if (receptionDt.Columns["ReceptionDayName"] == null)
            { 
                receptionDt.Columns.Add("ReceptionDayName", typeof(string));           
            }

            ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
            DataTable daysTbl = cacheHandler.getCachedDataTable(eCachedTables.DIC_ReceptionDays.ToString());

            for (int i = 0; i < receptionDt.Rows.Count; i++)
            {
                DataRow row = receptionDt.Rows[i];

                if (!CheckRelevantValidDatesForToday(row, true))
                {
                    row.Delete();
                }
                else
                {
                    if (row["receptionDay"] != DBNull.Value && !string.IsNullOrEmpty(row["receptionDay"].ToString()))
                    {
                        row["ReceptionDayName"] = daysTbl.Select("ReceptionDayCode=" + row["receptionDay"].ToString())[0]["ReceptionDayName"].ToString();
                    }

                    CheckIfActive24Hours(row);
                }
            }

            receptionDt.AcceptChanges();
        }

        public int CheckIfOverlappInSameClinicAndMakeChanges(ref DataTable hoursDt, out int[] rowsIdArr, UserInfo currUser)
        {
            int foundOverlapp = 0;
            rowsIdArr = null;
            DataTable dtNewlyAddedRows = hoursDt.Clone();

            for (int i = 0; i < hoursDt.Rows.Count; i++)
            {
                DataRow firstRow = hoursDt.Rows[i];

                for (int j = i + 1; j < hoursDt.Rows.Count; j++)
                {
                    DataRow secondRow = hoursDt.Rows[j];
                    

                    // NEW: check if overlapped in seame clinic
                    // return on first case of overlapping. 
                    // No need to continue throght all sycle, return foundOverlapp = "2" immediately
                    if (firstRow["ReceptionDay"].ToString() == secondRow["ReceptionDay"].ToString() &&
                        firstRow["DeptCode"].ToString() == secondRow["DeptCode"].ToString() &&
                        (firstRow["Newly_Added"].ToString() == "1" || secondRow["Newly_Added"].ToString() == "1"))
                    {
                        // if dates are not overlapp - any hours is valid
                        if (DatesHaveOverlapp(firstRow["ValidFrom"], firstRow["validTo"],
                                                secondRow["validFrom"], secondRow["validTo"]))
                        {
                            if (!HoursAreValid_InSameCDept(firstRow, secondRow, currUser))
                            {
                                if (foundOverlapp == 0)
                                { 
                                    foundOverlapp = 2;
                                }

                                if (Convert.ToInt16(firstRow["Newly_Added"]) == 1)
                                {
                                    // Second row is old and we make out of date in case of conflict

                                    secondRow["validTo"] = Convert.ToDateTime(firstRow["validFrom"]).AddDays(-1);

                                    if (firstRow["validTo"] != DBNull.Value)
                                    {
                                        // add one more row:
                                        // same as row we put out of action but with "ValidFrom" - after newly added row expiration

                                        DataRow newRow = dtNewlyAddedRows.NewRow();

                                        newRow.ItemArray = secondRow.ItemArray.Clone() as object[];

                                        //for (int y = 0; y < newRow.ItemArray.Length; y++)
                                        //{
                                        //    newRow.ItemArray[y] = secondRow.ItemArray[y];
                                        //}

                                        newRow["validFrom"] = Convert.ToDateTime(firstRow["validTo"]).AddDays(1);
                                        newRow["validTo"] = DBNull.Value;

                                        dtNewlyAddedRows.Rows.Add(newRow);
                                    }
                                }
                                else
                                {
                                    // first row is old and we make out of date in case of conflict

                                    firstRow["validTo"] = Convert.ToDateTime(secondRow["validFrom"]).AddDays(-1);

                                    if (secondRow["validTo"] != DBNull.Value)
                                    {
                                        // add one more row:
                                        // same as row we put out of action but with "ValidFrom" - after newly added row expiration

                                        DataRow newRow = dtNewlyAddedRows.NewRow();

                                        newRow.ItemArray = firstRow.ItemArray.Clone() as object[];

                                        //for (int y = 0; y < newRow.ItemArray.Length; y++)
                                        //{
                                        //    newRow.ItemArray[y] = firstRow.ItemArray[y];
                                        //}

                                        newRow["validFrom"] = Convert.ToDateTime(secondRow["validTo"]).AddDays(1);
                                        newRow["validTo"] = DBNull.Value;

                                        dtNewlyAddedRows.Rows.Add(newRow);

                                    }                                
                                }

                                //ID_List.Add(Convert.ToInt32(firstRow["ID_Original"]));
                                //ID_List.Add(Convert.ToInt32(secondRow["ID_Original"]));
                            }
                        }
                    }

                }
            }

            if (dtNewlyAddedRows.Rows.Count > 0)
            { 
                 foreach (DataRow newlyAddedRow in dtNewlyAddedRows.Rows)
                {
                    hoursDt.ImportRow(newlyAddedRow);
                }           
            }

            hoursDt.AcceptChanges();

            return foundOverlapp;
        }

        public int CheckIfOverlapp(ref DataTable hoursDt, out int[] rowsIdArr, UserInfo currUser)
        {
            int foundOverlapp = 0; // 0 - NO overlap; 1 - overlap in different clinics; 2 - overlap in the same clinic 
            rowsIdArr = null;

            // get the rows with real reception hours only
            DataRow[] rows = hoursDt.Select("openingHour is not null AND closingHour is not null");
            string commaSeperated = string.Empty;

            for (int i = 0; i < rows.Length; i++)
            {
                if (!string.IsNullOrEmpty(rows[i]["RemarkID"].ToString()))
                    commaSeperated += rows[i]["RemarkID"].ToString() + "," + rows[i]["DeptCode"].ToString() + ",";
                else
                    commaSeperated += "0," + rows[i]["DeptCode"].ToString() + ","; ;
            }

            if (commaSeperated.Length > 0)
            {
                commaSeperated = commaSeperated.Substring(0, commaSeperated.Length - 1);
            }


            // check which receptions ids has remark that enable overlapp
            DoctorDB dal = new DoctorDB();
            DataSet ds = dal.CheckHoursOverlappingRemark(commaSeperated);

            // we will use this table to compare addresses
            _deptsAddresses = ds.Tables[1];

            // remove this receptions from the table because we don't want to check them
            hoursDt = rows.CopyToDataTable();
            DataRow[] overlappRemark = ds.Tables[0].Select("EnableOverlappingHours = 1");

            for (int i = 0; i < overlappRemark.Length; i++)
            {
                DataRow[] arr = hoursDt.Select("RemarkID = " + overlappRemark[i]["RemarkID"].ToString());

                for (int j = 0; j < arr.Length; j++)
                {
                    arr[j].Delete();
                }
            }

            hoursDt.AcceptChanges();
            hoursDt.DefaultView.Sort = "ReceptionDay, OpeningHour";

            hoursDt = hoursDt.DefaultView.ToTable();

            List<int> ID_List = new List<int>();

            for (int i = 0; i < hoursDt.Rows.Count; i++)
            {
                DataRow firstRow = hoursDt.Rows[i];

                for (int j = i + 1; j < hoursDt.Rows.Count; j++)
                {
                    DataRow secondRow = hoursDt.Rows[j];

                    // within a single dept - any overlapp is legal (before 02.06.2022)
                    //if (firstRow["ReceptionDay"].ToString() == secondRow["ReceptionDay"].ToString() &&
                    //                firstRow["DeptCode"].ToString() != secondRow["DeptCode"].ToString())

                    // new agreament - NO overlapping is permitted. No matter in same clinic or in different clinics
                    if (firstRow["ReceptionDay"].ToString() == secondRow["ReceptionDay"].ToString())
                    {
                        // if dates are not overlapp - any hours is valid
                        if (DatesHaveOverlapp(firstRow["ValidFrom"], firstRow["validTo"],
                                                secondRow["validFrom"], secondRow["validTo"]))
                        {
                            if (!HoursAreValid(firstRow, secondRow, currUser))
                            {
                                if (foundOverlapp == 0)
                                {
                                    if (firstRow["DeptCode"].ToString() != secondRow["DeptCode"].ToString()) // different clinics
                                    {
                                        foundOverlapp = 1;
                                    }
                                    else // same clinic
                                    {
                                        if (foundOverlapp != 1)
                                        {
                                            foundOverlapp = 2;
                                        }
                                    }
                            
                                }

                                ID_List.Add(Convert.ToInt32(firstRow["ID_Original"]));
                                ID_List.Add(Convert.ToInt32(secondRow["ID_Original"]));
                            }
                        }
                    }
                }
            }

            rowsIdArr = ID_List.ToArray();
            return foundOverlapp;
        }

        // ****** PropagateTheRemarkOnAllRowsInConflict NOT IN USE as to CANCEL PropagateTheRemarkOnAllRowsInConflict 26/06/2021
        public bool PropagateTheRemarkOnAllRowsInConflict(ref DataTable hoursDt, DataRow secondRow, UserInfo currUser)
        {
            bool Propagated = false;

            DataRow[] rows = hoursDt.Select("openingHour is not null AND closingHour is not null");
            string commaSeperated = string.Empty;

            for (int i = 0; i < rows.Length; i++)
            {
                if (!string.IsNullOrEmpty(rows[i]["RemarkID"].ToString()))
                    commaSeperated += rows[i]["RemarkID"].ToString() + "," + rows[i]["DeptCode"].ToString() + ",";
                else
                    commaSeperated += "0," + rows[i]["DeptCode"].ToString() + ","; ;
            }

            if (commaSeperated.Length > 0)
            {
                commaSeperated = commaSeperated.Substring(0, commaSeperated.Length - 1);
            }

            // check which receptions ids has remark that enable overlapp
            DoctorDB dal = new DoctorDB();
            DataSet ds = dal.CheckHoursOverlappingRemark(commaSeperated);

            // we will use this table to compare addresses
            _deptsAddresses = ds.Tables[1];

            for (int i = 0; i < hoursDt.Rows.Count; i++)
            {
                DataRow firstRow = hoursDt.Rows[i];

                if (firstRow["ReceptionDay"].ToString() != String.Empty) // real reception
                { 
                    // within a single dept - any overlapp is legal
                    if (firstRow["ReceptionDay"].ToString() == secondRow["ReceptionDay"].ToString() &&
                                    firstRow["DeptCode"].ToString() != secondRow["DeptCode"].ToString())
                    {
                        // if dates are not overlapped - any hours are valid
                        if (DatesHaveOverlapp(firstRow["ValidFrom"], firstRow["validTo"],
                                                secondRow["validFrom"], secondRow["validTo"]))
                        {
                            if (firstRow["RemarkID"].ToString() == string.Empty)
                            { 
                                if (!HoursAreValid(firstRow, secondRow, currUser))
                                {
                                    firstRow["RemarkID"] = secondRow["RemarkID"];
                                    firstRow["RemarkText"] = secondRow["RemarkText"];

                                    Propagated = true;
                                }                        
                            }
                        }
                    }                
                }
            }

            if (Propagated)
            { 
                hoursDt.AcceptChanges();            
            }

            return Propagated;
        }

        public bool CheckIfOverlappOverThisRow(ref DataTable hoursDt, DataRow currRow /*, out int[] rowsIdArr*/)
        {
            bool foundOverlapp = false;
            //rowsIdArr = null;

            // get the rows with real reception hours only
            DataRow[] rows = hoursDt.Select("openingHour is not null AND closingHour is not null");
            string commaSeperated = string.Empty;

            for (int i = 0; i < rows.Length; i++)
            {
                if (!string.IsNullOrEmpty(rows[i]["RemarkID"].ToString()))
                    commaSeperated += rows[i]["RemarkID"].ToString() + "," + rows[i]["DeptCode"].ToString() + ",";
                else
                    commaSeperated += "0," + rows[i]["DeptCode"].ToString() + ","; ;
            }

            if (commaSeperated.Length > 0)
            { 
                 commaSeperated = commaSeperated.Substring(0, commaSeperated.Length - 1);
            }

            // check which receptions ids has remark that enable overlapp
            DoctorDB dal = new DoctorDB();
            DataSet ds = dal.CheckHoursOverlappingRemark(commaSeperated);

            // we will use this table to compare addresses
            _deptsAddresses = ds.Tables[1];

            // remove this receptions from the table because we don't want to check them
            hoursDt = rows.CopyToDataTable();
            //DataRow[] overlappRemark = ds.Tables[0].Select("EnableOverlappingHours = 1");

            //for (int i = 0; i < overlappRemark.Length; i++)
            //{
            //    DataRow[] arr = hoursDt.Select("RemarkID = " + overlappRemark[i]["RemarkID"].ToString());

            //    for (int j = 0; j < arr.Length; j++)
            //    {
            //        arr[j].Delete();
            //    }
            //}

            //hoursDt.AcceptChanges();
            hoursDt.DefaultView.Sort = "ReceptionDay, OpeningHour";

            hoursDt = hoursDt.DefaultView.ToTable();

            DataRow firstRow = currRow;
            DataRow firstShift;
            DataRow secondShift;

            for (int i = 0; i < hoursDt.Rows.Count; i++)
            {
                DataRow secondRow = hoursDt.Rows[i];

                // within a single dept or with remark - any overlapp is legal
                if (firstRow["ReceptionDay"].ToString() == secondRow["ReceptionDay"].ToString() &&
                                firstRow["DeptCode"].ToString() != secondRow["DeptCode"].ToString()
                                && firstRow["receptionID"].ToString() != secondRow["receptionID"].ToString()
                                && firstRow["RemarkID"].ToString() == string.Empty && secondRow["RemarkID"].ToString() == string.Empty )
                {
                    if (Convert.ToDateTime(firstRow["openingHour"]).TimeOfDay < Convert.ToDateTime(secondRow["openingHour"]).TimeOfDay)
                    {
                        firstShift = firstRow;
                        secondShift = secondRow;
                    }
                    else
                    { 
                        firstShift = secondRow;
                        secondShift = firstRow;                    
                    }
                                        // if dates are not overlapp - any hours is valid
                    if (DatesHaveOverlapp(firstRow["ValidFrom"], firstRow["validTo"],
                                            secondRow["validFrom"], secondRow["validTo"]))
                    {
                        if (!HoursAreValid(firstShift, secondShift))
                        {
                            if (!foundOverlapp)
                                foundOverlapp = true;

                            //rowsIdArr = new int[2];
                            //rowsIdArr[0] = Convert.ToInt32(firstRow["ID_Original"]);
                            //rowsIdArr[1] = Convert.ToInt32(secondRow["ID_Original"]);

                            return foundOverlapp;
                        }
                    }
                }
            }

            return foundOverlapp;
        }


        #region private methods

        private bool CheckIfTablesHasSameHours(DataRow[] firstView, DataRow[] secondView)
        {

            for (int i = 0; i < firstView.Length; i++)
            {
                if (firstView[i]["receptionDay"].ToString() != secondView[i]["receptionDay"].ToString()
                    || firstView[i]["openingHour"].ToString() != secondView[i]["openingHour"].ToString()
                    || firstView[i]["closingHour"].ToString() != secondView[i]["closingHour"].ToString()
                    || firstView[i]["receptionRemarks"].ToString() != secondView[i]["receptionRemarks"].ToString())
                    


                {
                    return false;
                }
            }

            return true;

        }

        private bool CheckIfDaysHasSameHours(DataRow firstRow, DataRow secondRow)
        {

            if (firstRow["OpeningHour"].ToString() != secondRow["OpeningHour"].ToString() ||
                firstRow["ClosingHour"].ToString() != secondRow["ClosingHour"].ToString())
            {
                return false;
            }

            return true;
        }

        private void AddDataRowtoViewRow(DataRow drData, DataRow drView, int matchIndex)
        {
            string[] receptions;
            if (matchIndex == 1)
            {
                drView["ReceptionIds"] = drData["receptionID"].ToString();
                if (drData.Table.Columns.Contains("ItemID") && drData["ItemID"] != DBNull.Value)
                {
                    drView["itemsCodes"] = drData["ItemID"].ToString();
                }

                if (drData.Table.Columns.Contains("ItemDesc") && drData["ItemDesc"] != DBNull.Value)
                    drView["itemsNames"] = drData["ItemDesc"].ToString();

                if (drData.Table.Columns.Contains("ItemType") && drData["ItemType"] != DBNull.Value)
                    drView["itemsTypes"] = drData["ItemType"].ToString();

                if (drData.Table.Columns.Contains("deptCode") && drData["deptCode"] != DBNull.Value)
                    drView["DepartCode"] = drData["deptCode"].ToString();

                if (drData.Table.Columns.Contains("deptName") && drData["deptName"] != DBNull.Value)
                    drView["DepartName"] = drData["deptName"].ToString();

                drView["Days"] = ConvertDay(Convert.ToByte(drData["receptionDay"]));
                drView["openingHour"] = drData["openingHour"].ToString();
                drView["closingHour"] = drData["closingHour"].ToString();
                drView["RemarkID"] = drData["RemarkID"].ToString();
                drView["Remark"] = drData["RemarkText"].ToString();
                drView["EnableOverMidnightHours"] = drData["EnableOverMidnightHours"].ToString();
                drView["ValidFrom"] = drData["validFrom"];
                drView["ValidTo"] = drData["validTo"];


                if (drData.Table.Columns.Contains("cityCode") && drData["cityCode"] != DBNull.Value)
                    drView["DepartCityCode"] = drData["cityCode"].ToString();

                if (drData.Table.Columns.Contains("cityName") && drData["cityName"] != DBNull.Value)
                    drView["DepartCity"] = drData["cityName"].ToString();

            }
            else
            {
                receptions = drView["ReceptionIds"].ToString().Split(CN_Fields_DELIMETER.ToCharArray());
                if (!receptions.Contains(drData["receptionID"].ToString()))
                {
                    drView["ReceptionIds"] += CN_Fields_DELIMETER + drData["receptionID"].ToString();
                }

                if (drData.Table.Columns.Contains("ItemID") && drData["ItemID"] != DBNull.Value)
                {
                    string itemCode = CN_Fields_DELIMETER + drData["ItemID"].ToString();
                    string itemType = CN_Fields_DELIMETER + drData["ItemType"].ToString();


                    if (drView["itemsCodes"].ToString() != drData["ItemID"].ToString())
                    {
                        if (!drView["itemsCodes"].ToString().Contains(itemCode) && !drView["itemsCodes"].ToString().Contains(itemCode + CN_Fields_DELIMETER))
                        {
                            drView["itemsCodes"] += itemCode;
                            drView["itemsTypes"] += itemType;
                        }

                    }
                }

                if (drData.Table.Columns.Contains("ItemDesc") && drData["ItemDesc"] != DBNull.Value)
                {
                    if (!drView["itemsNames"].ToString().Contains(drData["ItemDesc"].ToString()))
                    {
                        drView["itemsNames"] += CN_Fields_DELIMETER + drData["ItemDesc"].ToString();
                    }
                }


                if (!drView["Days"].ToString().Contains(ConvertDay(Convert.ToByte(drData["receptionDay"]))))
                {
                    if (!string.IsNullOrEmpty(drView["Days"].ToString()))
                        drView["Days"] += CN_Fields_DELIMETER + ConvertDay(Convert.ToByte(drData["receptionDay"]));
                    else
                        drView["Days"] = ConvertDay(Convert.ToByte(drData["receptionDay"]));

                }

                if (!drView["RemarkID"].ToString().Contains(drData["RemarkID"].ToString()))
                {
                    if (!string.IsNullOrEmpty(drView["RemarkID"].ToString()))
                        drView["RemarkID"] += CN_Fields_DELIMETER + drData["RemarkID"].ToString();
                    else
                        drView["RemarkID"] = drData["RemarkID"].ToString();
                }
                //drView["RemarkReceptionIds"] += CN_Fields_DELIMETER + drData["receptionID"].ToString() + CN_Fields_Joint + drData["RemarkID"].ToString();

            }
        }

        private string ConvertDay(byte DayIndex)
        {
            string DayDesc = string.Empty;
            DayDesc = DayIndex.ToString();
            return DayDesc;

            switch (DayIndex)
            {
                case 1:
                    {
                        DayDesc = "?";
                    }
                    break;
                case 2:
                    {
                        DayDesc = "?";
                    }
                    break;
                case 3:
                    {
                        DayDesc = "?";
                    }
                    break;
                case 4:
                    {
                        DayDesc = "?";
                    }
                    break;
                case 5:
                    {
                        DayDesc = "?";
                    }
                    break;
                case 6:
                    {
                        DayDesc = "?";
                    }
                    break;
                case 7:
                    {
                        DayDesc = "?";
                    }
                    break;
            }

            return DayDesc;
        }

        private DataRow GetNewViewRow(DataTable ViewTbl)
        {
            DataRow viewdr;

            viewdr = ViewTbl.NewRow();
            viewdr["ReceptionIds"] = "";

            if (ViewTbl.Columns.Contains("itemsCodes"))
                viewdr["itemsCodes"] = "";

            if (ViewTbl.Columns.Contains("itemsNames"))
                viewdr["itemsNames"] = "";

            if (ViewTbl.Columns.Contains("itemsTypes"))
                viewdr["itemsTypes"] = "";

            //if (ViewTbl.Columns.Contains("itemsReceptionIds"))
            //    viewdr["itemsReceptionIds"] = "";

            if (ViewTbl.Columns.Contains("DepartCode"))
                viewdr["DepartCode"] = "";

            if (ViewTbl.Columns.Contains("DepartName"))
                viewdr["DepartName"] = "";

            viewdr["Days"] = "";
            viewdr["openingHour"] = "";
            viewdr["closingHour"] = "";
            viewdr["RemarkID"] = "";
            //viewdr["RemarkReceptionIds"] = "";
            viewdr["Remark"] = "";
            //viewdr["ValidFrom"] = "";
            //viewdr["ValidTo"] = "";
            viewdr["ValidFrom"] = DBNull.Value;
            viewdr["ValidTo"] = DBNull.Value;

            if (ViewTbl.Columns.Contains("DepartCityCode"))
                viewdr["DepartCityCode"] = "";

            if (ViewTbl.Columns.Contains("DepartCity"))
                viewdr["DepartCity"] = "";
            return viewdr;
        }

        private DataTable CreateViewDataTable()
        {
            DataTable dt = new DataTable();
            DataColumn column = null;
            DataRow dr = dt.NewRow();

            column = new DataColumn("ReceptionIds");
            dt.Columns.Add(column);

            column = new DataColumn("itemsCodes");
            dt.Columns.Add(column);

            column = new DataColumn("itemsNames");
            dt.Columns.Add(column);

            column = new DataColumn("itemsTypes");
            dt.Columns.Add(column);

            //column = new DataColumn("itemsReceptionIds");
            //dt.Columns.Add(column);

            column = new DataColumn("DepartCode");
            dt.Columns.Add(column);

            column = new DataColumn("DepartName");
            dt.Columns.Add(column);

            column = new DataColumn("Days");
            dt.Columns.Add(column);

            column = new DataColumn("openingHour");
            dt.Columns.Add(column);

            column = new DataColumn("closingHour");
            dt.Columns.Add(column);

            column = new DataColumn("RemarkID");
            dt.Columns.Add(column);

            column = new DataColumn("Remark");
            dt.Columns.Add(column);

            column = new DataColumn("EnableOverMidnightHours");
            dt.Columns.Add(column);

            column = new DataColumn("ValidFrom",typeof(DateTime));
            dt.Columns.Add(column);

            column = new DataColumn("ValidTo");
            dt.Columns.Add(column);

            column = new DataColumn("DepartCityCode");
            dt.Columns.Add(column);

            column = new DataColumn("DepartCity");
            dt.Columns.Add(column);



            return dt;

        }

        private void CheckIfActive24Hours(DataRow dataRow)
        {
            if ((dataRow["openingHour"].ToString() == "00:01" || dataRow["openingHour"].ToString() == "00:00")
                    && (dataRow["closingHour"].ToString() == "23:59" || dataRow["closingHour"].ToString() == "00:00"))
            {
                dataRow["openingHour"] = "24";
                dataRow["closingHour"] = "שעות";
            }
        }

        private bool CheckRelevantValidDatesForToday(DataRow row, bool disableFutureDates)
        {
            DateTime fromDate = DateTime.MinValue;
            if (disableFutureDates)
            {
                if (row["validFrom"] != DBNull.Value)
                {
                    fromDate = Convert.ToDateTime(row["validFrom"]);
                }
            }

            DateTime toDate = DateTime.MaxValue;
            
            if (row["validTo"] != DBNull.Value)
            {
                toDate = Convert.ToDateTime(row["validTo"]);
            }


            if (DateTime.Compare(fromDate, DateTime.Today) > 0 || DateTime.Compare(toDate, DateTime.Today) < 0)
            {
                return false;
            }
            else
            {
                return true;
            }
           
        } 

        private bool HoursAreValid(DataRow firstRow, DataRow secondRow, UserInfo currUser)
        {
            TimeSpan firstOpen = Convert.ToDateTime(firstRow["openingHour"]).TimeOfDay;
            TimeSpan firstClose = Convert.ToDateTime(firstRow["closingHour"]).TimeOfDay;
            TimeSpan secondOpen = Convert.ToDateTime(secondRow["openingHour"]).TimeOfDay;
            TimeSpan secondClose = Convert.ToDateTime(secondRow["closingHour"]).TimeOfDay;

            
            // if hours are overlapp - not valid, unless it's same dept and same hours
            if (firstClose > secondOpen)
            {
                if (DeptsHaveSameAddress(Convert.ToInt32(firstRow["deptCode"]), Convert.ToInt32(secondRow["deptCode"])))
                {
                    if (firstOpen == secondOpen && firstClose == secondClose)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }

            // if same address - any break between reception hours is valid
            if (DeptsHaveSameAddress(Convert.ToInt32(firstRow["deptCode"]), Convert.ToInt32(secondRow["deptCode"])))
            {
                return true;
            }
            // if different address - we need at least 15 minutes break between receptions, unless the user is administrator
            else 
            {
                if (!currUser.IsAdministrator)
                {
                    if (firstClose.Add(new TimeSpan(0, 15, 00)) > secondOpen)
                    {
                        return false;
                    }
                }
            }

            // otherwise - valid
            return true;

        }

        private bool HoursAreValid_InSameCDept(DataRow firstRow, DataRow secondRow, UserInfo currUser)
        {
            TimeSpan firstOpen = Convert.ToDateTime(firstRow["openingHour"]).TimeOfDay;
            TimeSpan firstClose = Convert.ToDateTime(firstRow["closingHour"]).TimeOfDay;
            TimeSpan secondOpen = Convert.ToDateTime(secondRow["openingHour"]).TimeOfDay;
            TimeSpan secondClose = Convert.ToDateTime(secondRow["closingHour"]).TimeOfDay;


            // if hours are overlapp - not valid, unless it's same dept and same hours
            if (firstClose > secondOpen)
            {
                if (firstOpen == secondOpen && firstClose == secondClose)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }

            return true;
       }

        private bool HoursAreValid(DataRow firstRow, DataRow secondRow)
        {
            TimeSpan firstOpen = Convert.ToDateTime(firstRow["openingHour"]).TimeOfDay;
            TimeSpan firstClose = Convert.ToDateTime(firstRow["closingHour"]).TimeOfDay;
            TimeSpan secondOpen = Convert.ToDateTime(secondRow["openingHour"]).TimeOfDay;
            TimeSpan secondClose = Convert.ToDateTime(secondRow["closingHour"]).TimeOfDay;


            // if hours are overlapp - not valid, unless it's same dept and same hours
            if (firstClose > secondOpen)
            {
                if (DeptsHaveSameAddress(Convert.ToInt32(firstRow["deptCode"]), Convert.ToInt32(secondRow["deptCode"])))
                {
                    if (firstOpen == secondOpen && firstClose == secondClose)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }

            // if same address - any break between reception hours is valid
            if (DeptsHaveSameAddress(Convert.ToInt32(firstRow["deptCode"]), Convert.ToInt32(secondRow["deptCode"])))
            {
                return true;
            }
            // if different address - we need at least 15 minutes break between receptions, unless the user is administrator
            else
            {
                if (firstClose.Add(new TimeSpan(0, 15, 00)) > secondOpen)
                {
                    return false;
                }
            }

            // otherwise - valid
            return true;
        }


        private bool DeptsHaveSameAddress(int firstDeptCode, int secondDeptCode)
        {
            DataRow firstDept = _deptsAddresses.Select("DeptCode = " + firstDeptCode.ToString())[0];
            DataRow secondDept = _deptsAddresses.Select("DeptCode = " + secondDeptCode.ToString())[0];

            if (firstDeptCode != secondDeptCode)
            {

                if (firstDept[eDeptEnum.cityCode.ToString()].ToString() == secondDept[eDeptEnum.cityCode.ToString()].ToString())
                {
                    // if both of them are null - or have same value
                    if (((firstDept[eDeptEnum.StreetCode.ToString()] == DBNull.Value && secondDept[eDeptEnum.StreetCode.ToString()] == DBNull.Value))
                        || (firstDept[eDeptEnum.StreetCode.ToString()].ToString() == secondDept[eDeptEnum.StreetCode.ToString()].ToString()))
                    {
                        // if both of them are null - or have same value
                        if ((firstDept[eDeptEnum.house.ToString()] == DBNull.Value && secondDept[eDeptEnum.house.ToString()] == DBNull.Value)
                            || (firstDept[eDeptEnum.house.ToString()].ToString() == secondDept[eDeptEnum.house.ToString()].ToString()))
                        {
                                return true;
                        }
                    }
                }
                return false;
            }

            return true;
        }

        private bool DatesHaveOverlapp(object firstFrom, object firstTo, object secondFrom, object secondTo)
        {
            DateTime? firstDateFrom, firstDateTo, secondDateFrom, secondDateTo;

            firstDateFrom = ConvertToDate(firstFrom);
            firstDateTo = ConvertToDate(firstTo);
            secondDateFrom = ConvertToDate(secondFrom);
            secondDateTo = ConvertToDate(secondTo);

            if ( (firstDateTo == null && secondDateTo == null) || (firstDateFrom == secondDateFrom))
            {
                return true;
            }

            if (firstDateFrom < secondDateFrom)
            {
                if (firstDateTo >= secondDateFrom || firstDateTo == null)
                {
                    return true;
                }
            }
            else
            {
                if (secondDateTo >= firstDateFrom || secondDateTo == null)
                {
                    return true;
                }
            }

            return false;
        }

        private DateTime? ConvertToDate(object dateObject)
        {
            DateTime? val = null;

            if (dateObject != DBNull.Value)
            {
                val = Convert.ToDateTime(dateObject);
            }

            return val;
        }

        #endregion 
    }
}
