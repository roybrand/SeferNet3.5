using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data; 
using System.Configuration;
using SeferNet.DataLayer;
using SeferNet.BusinessLayer.BusinessObject;
using System.Data.SqlClient;
using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using Clalit.SeferNet.GeneratedEnums;


namespace SeferNet.BusinessLayer.WorkFlow
{
    public class Remarks
    {
        string m_ConnStr;

        public Remarks()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang();
        }
       
        public Remarks(string lang)
        {
            m_ConnStr = ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"].ConnectionString;
        }

        public DataSet GetSweepingRemarkByID(int p_remarkID)
        {
            DataLayer.RemarksDB db = new RemarksDB(m_ConnStr);
            DataSet ds = new DataSet();
            db.GetSweepingRemarkByID(ref ds, p_remarkID);
            return ds;
        }

        public DataSet GetSweepingRemarkAreasByRelatedRemarkID(int p_relatedRemarkID)
        {
            DataLayer.RemarksDB db = new RemarksDB(m_ConnStr);
            DataSet ds = new DataSet();
            db.GetSweepingRemarkAreasByRelatedRemarkID(ref ds, p_relatedRemarkID);
            ds.Tables[0].TableName = "Districts";
            ds.Tables[1].TableName = "Administrations";
            ds.Tables[2].TableName = "UnitTypes";
            ds.Tables[3].TableName = "PopulationSectors";
			ds.Tables[4].TableName = "ExcludedDepts";
			ds.Tables[5].TableName = "Cities";
			ds.Tables[6].TableName = "Services";

            return ds;
        }

        //--- new Sweeping DeptRemarks concept
        public void DeleteDeptRemark(int DeptRemarkID)
        {
            SeferNet.DataLayer.RemarksDB dal = new SeferNet.DataLayer.RemarksDB(m_ConnStr);
            dal.DeleteDeptRemark(DeptRemarkID);
        }

        //--- new Sweeping DeptRemarks concept
        public bool InsertSweepingDeptRemark(int remarkDicID, string remarkText, string districtCodes, string administrationCodes,
            string UnitTypeCodes, string subUnitTypeCode, string populationSectorCodes, string excludedDeptCodes,
            DateTime? validFrom, DateTime? validTo, DateTime? dateShowFrom, bool displayInInternet, string cityCodes, string servicesParameter)
        {
            string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();
            SeferNet.DataLayer.RemarksDB dal = new SeferNet.DataLayer.RemarksDB(m_ConnStr);

            if (validFrom == DateTime.MinValue)
            {
                validFrom = Convert.ToDateTime("1/1/1900");
            }
            if (validTo == DateTime.MinValue)
            {
                validTo = Convert.ToDateTime("1/1/1900");
            }
            if (dateShowFrom == DateTime.MinValue)
            {
                dateShowFrom = Convert.ToDateTime("1/1/1900");
            }

            dal.InsertSweepingDeptRemark(remarkDicID, remarkText, districtCodes, administrationCodes,
                                 UnitTypeCodes, subUnitTypeCode, populationSectorCodes, excludedDeptCodes,
                                 validFrom, validTo, dateShowFrom, displayInInternet, cityCodes, servicesParameter, updateUser);
            return true;
        }

		//--- new Sweeping DeptRemarks concept
		public void InsertSweepingRemarkExclutions(DataTable TblRemarks, int DeptCode)
		{
			string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();
			SeferNet.DataLayer.RemarksDB dal = new SeferNet.DataLayer.RemarksDB(m_ConnStr);
			DataRow[] delRows = TblRemarks.Select("Deleted = 1", "", DataViewRowState.CurrentRows);
			
			foreach (DataRow delRow in delRows)
			{
				dal.InsertSweepingRemarkExclutions((int)delRow["RemarkID"], DeptCode, updateUser);
			}
		}

		//--- new Sweeping DeptRemarks concept
		public void GetSweepingRemarkExclusions(ref DataSet ds, int DeptRemarkID)
		{
			string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();
			SeferNet.DataLayer.RemarksDB dal = new SeferNet.DataLayer.RemarksDB(m_ConnStr);
			
			dal.GetSweepingRemarkExclusions(ref ds, DeptRemarkID);
		}

        //--- new Sweeping DeptRemarks concept
        public bool InsertDeptRemark(int remarkDicID, string remarkText, int deptCode, 
            DateTime? validFrom, DateTime? validTo, DateTime? activeFrom, bool displayInInternet)
        {
            string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();
            SeferNet.DataLayer.RemarksDB dal = new SeferNet.DataLayer.RemarksDB(m_ConnStr);

            if (validFrom == DateTime.MinValue)
            {
                validFrom = Convert.ToDateTime("1/1/1900");
            }
            if (validTo == DateTime.MinValue)
            {
                validTo = Convert.ToDateTime("1/1/1900");
            }

            dal.InsertDeptRemark(remarkDicID, remarkText, deptCode, 
                                 validFrom, validTo, activeFrom, displayInInternet, updateUser);
            return true;
        }

        #region Employee remarks


        #endregion 

        

        public void GetSweepingRemarks(ref DataSet p_ds, string p_DistrictCode, string p_AdminClinicCode, string p_SectorCode, 
                                                    string p_UnitTypeCode, int p_subUnitTypeCode, int p_userPermittedDistrict
                                                    ,string p_servicesParameter, string p_cityCodes, string freeText)
        {
            SeferNet.DataLayer.RemarksDB rem = new SeferNet.DataLayer.RemarksDB(m_ConnStr);

            rem.GetSweepingRemarks(ref p_ds, p_DistrictCode, p_AdminClinicCode, p_SectorCode, p_UnitTypeCode, 
                                        p_subUnitTypeCode, p_userPermittedDistrict, p_servicesParameter, p_cityCodes, freeText);
        }

        public void GetUnitRemarks(ref DataSet p_ds, int UnitID)
        {
            SeferNet.DataLayer.RemarksDB rem = new SeferNet.DataLayer.RemarksDB(m_ConnStr);

            rem.GetUnitRemarks(ref p_ds, UnitID);
        }

        public void UpdateEmployeeRemarks(ref DataTable p_TblRemarks)
        {
            SeferNet.DataLayer.RemarksDB rem = new SeferNet.DataLayer.RemarksDB(m_ConnStr);
            UserInfo user = new UserManager().GetUserInfoFromSession();

            rem.UpdateEmployeeRemarks(ref p_TblRemarks, user.UserNameWithPrefix);
        }

        public void UpdateEmployeeServiceRemarks(ref DataTable p_TblRemarks)
        {
            SeferNet.DataLayer.RemarksDB rem = new SeferNet.DataLayer.RemarksDB(m_ConnStr);
            UserInfo user = new UserManager().GetUserInfoFromSession();

            rem.UpdateEmployeeServiceRemarks(ref p_TblRemarks, user.UserNameWithPrefix);
        }

        public void UpdateDeptRemarks(ref DataTable dtRemarks)
        {
            if (string.IsNullOrEmpty(m_ConnStr))
            {
                m_ConnStr = ConnectionHandler.ResolveConnStrByLang();
            }

            SeferNet.DataLayer.RemarksDB dal = new SeferNet.DataLayer.RemarksDB(m_ConnStr);
            int remarkID;
            string remarkText;
            DateTime validFrom;
            DateTime? validTo;
            DateTime? activeFrom;
            bool showOnInternet, isRemarkDeleted;
            UserManager userManager = new UserManager();
            UserInfo user = userManager.GetUserInfoFromSession();
            int showOrder;

            // Set new "showOrder"
            DataRow[] result_DR = dtRemarks.Select("Deleted <> 1", "ShowOrder");

            DataTable tableOrder = new DataTable("NewOrder");
            tableOrder.Columns.Add(new DataColumn("OrderNumber", typeof(int)));

            for (int i = 0; i < dtRemarks.Rows.Count; i++)
            {
                if (!Convert.ToBoolean(dtRemarks.Rows[i]["Deleted"]))
                { 
                    tableOrder.Rows.Add(Convert.ToInt32(dtRemarks.Rows[i]["ShowOrder"]));
                }

            }

            int count_for_result_DR = result_DR.Count();
            int currentID = 0;
            
            for (int i = 0; i < dtRemarks.Rows.Count; i++)
            {
                remarkID = Convert.ToInt32(dtRemarks.Rows[i]["RemarkID"]);
                isRemarkDeleted = Convert.ToBoolean(dtRemarks.Rows[i]["Deleted"]);

                if (isRemarkDeleted)
                {
                    dal.DeleteDeptRemark(remarkID);
                }
                else
                {
                    showOrder = Convert.ToInt32(result_DR[currentID]["ShowOrder"]);
                    currentID = currentID + 1;

                    remarkText = dtRemarks.Rows[i]["RemarkText"].ToString();

                    validFrom = Convert.ToDateTime(dtRemarks.Rows[i]["ValidFrom"]);
                    activeFrom = Convert.ToDateTime(dtRemarks.Rows[i]["ActiveFrom"]);
                    validTo = null;
                    if (dtRemarks.Rows[i]["ValidTo"] != DBNull.Value && !string.IsNullOrEmpty(dtRemarks.Rows[i]["ValidTo"].ToString()))
                        validTo = Convert.ToDateTime(dtRemarks.Rows[i]["ValidTo"]);
                    showOnInternet = Convert.ToBoolean(dtRemarks.Rows[i]["InternetDisplay"]);
                    if (Convert.ToInt16(dtRemarks.Rows[i]["RecordType"]) != 4) // not history remarks
                        dal.UpdateDeptRemark(remarkID, remarkText, validFrom, validTo, activeFrom, showOnInternet, showOrder, user.UserNameWithPrefix);

                }

            }
        }

        public void GetEmployeeRemarks(ref DataSet p_ds, int p_EmployeeID)
        {
            SeferNet.DataLayer.RemarksDB rem = new SeferNet.DataLayer.RemarksDB(m_ConnStr);

            rem.GetEmployeeRemarksForUpdate(ref p_ds, p_EmployeeID);
        }
        public void GetEmployeeServiceRemarks(ref DataSet p_ds, int DeptEmployeeID, int serviceCode)
        {
            SeferNet.DataLayer.RemarksDB rem = new SeferNet.DataLayer.RemarksDB(m_ConnStr);

            rem.GetEmployeeServiceRemarksForUpdate(ref p_ds, DeptEmployeeID, serviceCode);
        }

        public void GetEmployeeDepts(ref DataSet p_ds, long p_EmployeeID)
        {
            SeferNet.DataLayer.RemarksDB rem = new SeferNet.DataLayer.RemarksDB(m_ConnStr);

            rem.GetEmployeeDepts(ref p_ds, p_EmployeeID);
        }

        public DataSet GetDeptRemarkDetails(int remarkId)
        {
            SeferNet.DataLayer.RemarksDB rem = new SeferNet.DataLayer.RemarksDB(m_ConnStr);

            return rem.GetDeptRemarkDetails(remarkId);            
        }
    }

}
