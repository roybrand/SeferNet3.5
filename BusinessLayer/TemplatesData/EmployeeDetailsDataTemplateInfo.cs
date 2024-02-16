using System;
using System.Text;
using System.Data;
using HtmlTemplateParsing;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using Clalit.SeferNet.GeneratedEnums;
namespace SeferNet.BusinessLayer.TemplatesData
{
    public class EmployeeDetailsDataTemplateInfo : ITemplateInfoDatasetDataLoader
    {
        // List<vDummyEmployeeDetails> _EmployeeList;
        DataSet _EmployeeDs;
        DataTable _EmployeesReceptionInfo = null;
        DataTable _EmployeesRemarks = null;
        public EmployeeDetailsDataTemplateInfo(DataSet employeeDS)
        {
            _EmployeeDs = employeeDS;
            
            if (_EmployeeDs.Tables["EmployeesRemarks"] != null)
            {
                CreateRemarksTable();
                foreach (DataRow dr in _EmployeeDs.Tables["Results"].Rows)
                {
                    dr["EmployeeName"] = "<b>" + dr["EmployeeName"] + "</b>";

                    if (dr["expert"] != null && dr["expert"].ToString() != "")
                        dr["EmployeeName"] += "<br/>" + "<b>" + dr["expert"].ToString() + "</b>";

                    if (dr["positions"] != null && dr["positions"].ToString() != "")
                        dr["EmployeeName"] += "<br/>" + dr["positions"].ToString();

                    if (dr["AgreementTypeDescription"] != null && dr["AgreementTypeDescription"].ToString() != "")
                        dr["EmployeeName"] += "<br/>" + "הסכם: " + dr["AgreementTypeDescription"].ToString();

                    insertIntoTableRemarks(dr["EmployeeID"].ToString(), dr["DeptCode"].ToString());
                }
            }
            
            foreach (DataRow dr in _EmployeeDs.Tables["Results"].Rows)
            {
                dr["DeptName"] = "<b>" + dr["DeptName"] + "</b>";

                if (dr["Address"] != null && dr["Address"].ToString() != "")
                    dr["DeptName"] += "<br/>" + dr["Address"].ToString();

                if (dr["Phone"] != null && dr["Phone"].ToString() != "")
                    dr["DeptName"] += "<br/>" + "טלפון: " + dr["Phone"].ToString();

                if (dr["Fax"] != null && dr["Fax"].ToString() != "")
                    dr["DeptName"] += "<br/>" + "פקס: " + dr["Fax"].ToString();

                if (dr["EmployeeLanguageDescription"] != null && dr["EmployeeLanguageDescription"].ToString() != "")
                {
                    dr["EmployeeLanguageDescription"] = dr["EmployeeLanguageDescription"].ToString().Replace(",", "<br/>").Replace(" ", string.Empty);
                    dr["EmployeeLanguage"] = dr["EmployeeLanguageDescription"];
                }
            }

            _EmployeeDs.Tables["Results"].Columns.Add("Reseption", typeof(string), string.Empty);

            if (_EmployeeDs.Tables["EmployeesReceptionInfo"].Rows.Count > 0)
            {
                _EmployeesReceptionInfo = new DataTable();
                _EmployeesReceptionInfo.Columns.Add("EmployeeID", typeof(long));
                _EmployeesReceptionInfo.Columns.Add("DeptCode", typeof(int));
                _EmployeesReceptionInfo.Columns.Add("AgreementType", typeof(int));
                _EmployeesReceptionInfo.Columns.Add("ServiceDescription");
                _EmployeesReceptionInfo.Columns.Add("Sunday");
                _EmployeesReceptionInfo.Columns.Add("Monday");
                _EmployeesReceptionInfo.Columns.Add("Tuesday");
                _EmployeesReceptionInfo.Columns.Add("Wednesday");
                _EmployeesReceptionInfo.Columns.Add("Thursday");
                _EmployeesReceptionInfo.Columns.Add("Friday");
                _EmployeesReceptionInfo.Columns.Add("Saturday");
                _EmployeesReceptionInfo.Columns.Add("HolHamoeed");
                _EmployeesReceptionInfo.Columns.Add("HolidayEvening");
                _EmployeesReceptionInfo.Columns.Add("Holiday");
                _EmployeesReceptionInfo.Columns.Add("Ramadan");
                

                DataRow dRow;

                dRow = _EmployeesReceptionInfo.NewRow();
                dRow["EmployeeID"] = _EmployeeDs.Tables["EmployeesReceptionInfo"].Rows[0]["EmployeeID"].ToString();
                dRow["DeptCode"] = _EmployeeDs.Tables["EmployeesReceptionInfo"].Rows[0]["DeptCode"].ToString();
                dRow["ServiceDescription"] = _EmployeeDs.Tables["EmployeesReceptionInfo"].Rows[0]["ServiceDescription"].ToString();
                dRow["AgreementType"] = _EmployeeDs.Tables["EmployeesReceptionInfo"].Rows[0]["AgreementType"].ToString();
                ICacheService cache = ServicesManager.GetService<ICacheService>();
                DataTable dtReceptionDays = cache.getCachedDataTable("DIC_ReceptionDays");

                
                foreach (DataRow dr in _EmployeeDs.Tables["EmployeesReceptionInfo"].Rows)
                {

                    
                    int receptionDayCode = (int)dr["receptionDay"];

                    string columnName_ReceptionDay = Enum.GetName(typeof(eDIC_ReceptionDays), receptionDayCode);


                    if (dr["EmployeeID"].ToString() == dRow["EmployeeID"].ToString() 
                        && dr["DeptCode"].ToString() == dRow["DeptCode"].ToString() 
                        && dr["ServiceDescription"].ToString() == dRow["ServiceDescription"].ToString()
                        && dr["AgreementType"].ToString() == dRow["AgreementType"].ToString())
                    {
                        /* If the employee have 2 shifts in one day */
                        if (dRow[columnName_ReceptionDay] != null && dRow[columnName_ReceptionDay].ToString() != "")
                        {
                            dRow[columnName_ReceptionDay] += string.Format("&nbsp; &nbsp;{0} - {1}", dr["openingHour"], dr["closingHour"]);
                            //dRow[columnName_ReceptionDay] += string.Format("&nbsp; {0} - {1}", dr["closingHour"], dr["openingHour"]);

                            if (dr["RemarkText"] != null && dr["RemarkText"].ToString() != "")
                            {
                                //dRow[columnName_ReceptionDay] += string.Format("<br />{0}", dr["RemarkText"]);
                                dRow[columnName_ReceptionDay] += string.Format(" {0}", dr["RemarkText"]);
                            }
                        }
                        else
                        {
                            dRow[columnName_ReceptionDay] = string.Format("{0} - {1}", dr["openingHour"], dr["closingHour"]);
                            //dRow[columnName_ReceptionDay] = string.Format("{0} - {1}",dr["closingHour"], dr["openingHour"]);

                            if (dr["RemarkText"] != null && dr["RemarkText"].ToString() != "")
                            {
                                //dRow[columnName_ReceptionDay] += string.Format("<br />{0}", dr["RemarkText"]);
                                dRow[columnName_ReceptionDay] += string.Format(" {0}", dr["RemarkText"]);
                            }
                        }

                    }
                    else
                    {
                        
                        _EmployeesReceptionInfo.Rows.Add(dRow);
                        dRow = _EmployeesReceptionInfo.NewRow();
                        dRow["EmployeeID"] = dr["EmployeeID"];
                        dRow["DeptCode"] = dr["DeptCode"];
                        dRow["ServiceDescription"] = dr["ServiceDescription"];
                        dRow["AgreementType"] = dr["AgreementType"];
                        dRow[columnName_ReceptionDay] = string.Format("{0} - {1}", dr["openingHour"], dr["closingHour"]);
                        //dRow[columnName_ReceptionDay] = string.Format("{0} - {1}", dr["closingHour"], dr["openingHour"]);

                        if (dr["RemarkText"] != null && dr["RemarkText"].ToString() != "")
                        {
                            dRow[columnName_ReceptionDay] += string.Format("<br />{0}", dr["RemarkText"]);
                        }
                    }
                }
                /* Insert the last row */
                _EmployeesReceptionInfo.Rows.Add(dRow);

                foreach (DataRow drResult in _EmployeeDs.Tables["Results"].Rows)
                {
                    foreach (DataRow drResep in _EmployeesReceptionInfo.Rows)
                    {
                        if (drResult["EmployeeID"].ToString() == drResep["EmployeeID"].ToString() 
                            && drResult["DeptCode"].ToString() == drResep["DeptCode"].ToString()
                            && drResult["AgreementType"].ToString() == drResep["AgreementType"].ToString() )
                        {
                            if (drResult["Reseption"].ToString() == string.Empty)
                                drResult["Reseption"] = "<table cellpadding='0' cellspacing='0' width='100%'>";

                            drResult["Reseption"] += "<tr><td colspan='2'>" + drResep["ServiceDescription"].ToString() + ": </td></tr>";

                            if (drResep["Sunday"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "א'" + "</td><td>" + drResep["Sunday"].ToString() + "</td></tr>";
                            if (drResep["Monday"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "ב'" + "</td><td>" + drResep["Monday"].ToString() + "</td></tr>";
                            if (drResep["Tuesday"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "ג'" + "</td><td>" + drResep["Tuesday"].ToString() + "</td></tr>";
                            if (drResep["Wednesday"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "ד'" + "</td><td>" + drResep["Wednesday"].ToString() + "</td></tr>";
                            if (drResep["Thursday"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "ה'" + "</td><td>" + drResep["Thursday"].ToString() + "</td></tr>";
                            if (drResep["Friday"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "ו'" + "</td><td>" + drResep["Friday"].ToString() + "</td></tr>";
                            if (drResep["Saturday"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "ש'" + "</td><td>" + drResep["Saturday"].ToString() + "</td></tr>";
                            if (drResep["HolHamoeed"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "חול המועד " + "</td><td>" + drResep["HolHamoeed"].ToString() + "</td></tr>";
                            if (drResep["HolidayEvening"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "ערב חג " + "</td><td>" + drResep["HolidayEvening"].ToString() + "</td></tr>";
                            if (drResep["Holiday"].ToString() != string.Empty)
                                drResult["Reseption"] += "<tr><td>" + "חג" + "</td><td>" + drResep["Holiday"].ToString() + "</td></tr>";
                        }
                    }

                    if (drResult["Reseption"].ToString() != string.Empty)
                        drResult["Reseption"] += "</table>";
                }
            }
        }

        public void CreateRemarksTable()
        {
            _EmployeesRemarks = new DataTable();
            _EmployeesRemarks.Columns.Add("EmployeeID", typeof(long));
            _EmployeesRemarks.Columns.Add("DeptCode", typeof(int));
            _EmployeesRemarks.Columns.Add("RemarkText",typeof(string));
            //_EmployeesRemarks.Columns.Add("ValidText");
            //_EmployeesRemarks.Columns.Add("ValidTo");
            _EmployeesRemarks.Columns.Add("Valid",typeof(string));

            
        }

        public void insertIntoTableRemarks(string employeeID, string deptCode)
        {
            bool firstRow = true;
            string strRemarkText = "", strValid = "";
            DataRow[] drArray = _EmployeeDs.Tables["EmployeesRemarks"].Select("employeeID = " + employeeID + " and deptCode = " + deptCode);
            if (drArray != null)
            {
                foreach (DataRow dr in drArray)
                {
                    if (firstRow)
                    {
                        if(dr["ValidTo"].ToString() != "")
                            strValid = "בתוקף עד " + dr["ValidTo"].ToString();
                        strRemarkText = dr["RemarkText"].ToString();
                        firstRow = false;
                    }
                    else
                    {
                        if (dr["ValidTo"].ToString() != "")
                            strValid += "<br />" + "בתוקף עד " + dr["ValidTo"].ToString();
                        strRemarkText += "<br />" + dr["RemarkText"].ToString();
                        
                    }
                }

                if (!firstRow)
                {
                    DataRow dRow;
                    dRow = _EmployeesRemarks.NewRow();
                    dRow["EmployeeID"] = employeeID;
                    dRow["DeptCode"] = deptCode;
                    dRow["RemarkText"] = strRemarkText;
                    dRow["Valid"] = strValid;
                    _EmployeesRemarks.Rows.Add(dRow);
                }
            }
        }

        public string getDayText(DataTable dtReceptionDays, int dayCode)
        {
            DataRow dr = dtReceptionDays.Select("ReceptionDayCode =" + dayCode.ToString())[0];
            return dr["EnumName"].ToString();
        }




        public string GetDBFieldName(string containerName, string templateFieldName)
        {
            return string.Empty;
        }

        public DataTable GetDataTableByKey(string tableName)
        {
            DataTable dtToReturn = new DataTable();

            switch (tableName)
            {
                case "MainDetails":
                    dtToReturn = _EmployeeDs.Tables["Results"];
                    break;
                default :dtToReturn = GetDataTableByKeyAndParent(tableName,null);
                    break;
  
            }
            return dtToReturn;
        }

        public DataSet EmployeeDs
        {
            get { return _EmployeeDs; }
        }



        public DataTable GetDataTableByKeyAndParent(string tableName, DataRow drParent)
        {
            DataTable dtToReturn = new DataTable();
            switch (tableName)
            {
                case "EmployeesReceptionInfo":
                {
                    if (_EmployeesReceptionInfo != null)
                    {
                        dtToReturn = _EmployeesReceptionInfo.Clone();
                        if (drParent != null)
                        {
                            DataRow[] rows = _EmployeesReceptionInfo.Select(string.Format(" EmployeeID = {0} and deptCode = {1}", drParent["EmployeeID"], drParent["DeptCode"]));
                            foreach (DataRow dr in rows)
                            {
                                dtToReturn.ImportRow(dr);
                            }
                        }
                    }
                    
                   
                } break;
                case "EmployeesRemarks":
                    {
                        if (_EmployeesRemarks != null)
                        {
                            dtToReturn = _EmployeesRemarks.Clone();

                            if (drParent != null)
                            {
                                DataRow[] rows = _EmployeesRemarks.Select(string.Format(" EmployeeID = {0} and deptCode = {1}", drParent["EmployeeID"], drParent["DeptCode"]));
                                if (rows.Length > 0)
                                {
                                    dtToReturn.ImportRow(rows[0]);
                                }
                            }
                        }
                        

                    } break;
            }
            return dtToReturn;
        }
    }
}
