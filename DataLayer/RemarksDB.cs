using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Web;
using System.Data.SqlClient;
using SeferNet.Globals;
using System.Data.SqlTypes;

namespace SeferNet.DataLayer
{
    public class RemarksDB : Base.SqlDal
    {

        public RemarksDB(string p_conString)
            : base(p_conString)
        {
        }

        public DataSet getDicGeneralRemarks(Enums.remarkType? remarkType, bool userIsAdmin, int RemarkCategoryID)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams;


            switch (remarkType)
            {
                case Enums.remarkType.Clinic:
                    inputParams = new object[] { true, false, false, false, false, userIsAdmin, RemarkCategoryID };
                    break;
                case Enums.remarkType.Doctor:
                    inputParams = new object[] { false, true, false, false, false, userIsAdmin, RemarkCategoryID };
                    break;
                case Enums.remarkType.DoctorInClinic:
                    inputParams = new object[] { false, false, true, false, false, userIsAdmin, RemarkCategoryID };
                    break;
                case Enums.remarkType.ServiceInClinic:
                case Enums.remarkType.DoctorServiceInClinic:
                    inputParams = new object[] { false, false, false, true, false, userIsAdmin, RemarkCategoryID };
                    break;
                case Enums.remarkType.ReceptionHours:
                    inputParams = new object[] { false, false, false, false, true, userIsAdmin, RemarkCategoryID };
                    break;

                case Enums.remarkType.Sweeping:
                    inputParams = new object[] { true, false, false, false, false, userIsAdmin, RemarkCategoryID };
                    break;

                default:
                    inputParams = new object[] { false, false, false, false, false, userIsAdmin, RemarkCategoryID };
                    break;
            }


            string spName = "rpc_getDIC_GeneralRemarks";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getDicGeneralRemarksToCorrect(Enums.remarkType? remarkType, bool userIsAdmin, int RemarkCategoryID)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams;


            switch (remarkType)
            {
                case Enums.remarkType.Clinic:
                    inputParams = new object[] { true, false, false, false, false, userIsAdmin, RemarkCategoryID };
                    break;
                case Enums.remarkType.Doctor:
                    inputParams = new object[] { false, true, false, false, false, userIsAdmin, RemarkCategoryID };
                    break;
                case Enums.remarkType.DoctorInClinic:
                    inputParams = new object[] { false, false, true, false, false, userIsAdmin, RemarkCategoryID };
                    break;
                case Enums.remarkType.ServiceInClinic:
                case Enums.remarkType.DoctorServiceInClinic:
                    inputParams = new object[] { false, false, false, true, false, userIsAdmin, RemarkCategoryID };
                    break;
                case Enums.remarkType.ReceptionHours:
                    inputParams = new object[] { false, false, false, false, true, userIsAdmin, RemarkCategoryID };
                    break;

                case Enums.remarkType.Sweeping:
                    inputParams = new object[] { true, false, false, false, false, userIsAdmin, RemarkCategoryID };
                    break;

                default:
                    inputParams = new object[] { false, false, false, false, false, userIsAdmin, RemarkCategoryID };
                    break;
            }


            string spName = "rpc_getDIC_GeneralRemarksToCorrect";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetGeneralRemarkCategoriesByLinkedTo(Enums.remarkType remarkType, bool userIsAdmin)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams;


            switch (remarkType)
            {
                case Enums.remarkType.Clinic:
                    inputParams = new object[] { true, false, false, false, false, userIsAdmin };
                    break;
                case Enums.remarkType.Doctor:
                    inputParams = new object[] { false, true, false, false, false, userIsAdmin };
                    break;
                case Enums.remarkType.DoctorInClinic:
                    inputParams = new object[] { false, false, true, false, false, userIsAdmin };
                    break;
                case Enums.remarkType.ServiceInClinic:
                case Enums.remarkType.DoctorServiceInClinic:
                    inputParams = new object[] { false, false, false, true, false, userIsAdmin };
                    break;
                case Enums.remarkType.ReceptionHours:
                    inputParams = new object[] { false, false, false, false, true, userIsAdmin };
                    break;

                case Enums.remarkType.Sweeping:
                    inputParams = new object[] { true, false, false, false, false, userIsAdmin };
                    break;

                default:
                    inputParams = new object[] { false, false, false, false, false, userIsAdmin };
                    break;
            }


            string spName = "rpc_GetGeneralRemarkCategoriesByLinkedTo";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetGeneralRemarkByRemarkID(int remarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { remarkID };
            DataSet ds;

            string spName = "rpc_getDic_GeneralRemarksByRemarkID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getGeneralRemarks_ToCorrect_ByRemarkID(int remarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { remarkID };
            DataSet ds;

            string spName = "rpc_getGeneralRemarks_ToCorrect_ByRemarkID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getRemarksTypes()
        {
            object[] outputParams = new object[1] { new object() };

            DataSet ds;

            string spName = "rpc_getRemarksTypes";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });
            ds = FillDataSet(spName, ref outputParams);

            return ds;
        }

        public DataSet getRemarkTags()
        {
            object[] outputParams = new object[1] { new object() };

            DataSet ds;

            string spName = "rpc_getRemarkTags";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });
            ds = FillDataSet(spName, ref outputParams);

            return ds;
        }

        public DataSet getRemarkTagsToCreateRemark()
        {
            object[] outputParams = new object[1] { new object() };

            DataSet ds;

            string spName = "rpc_getRemarkTagsToCreateRemark";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });
            ds = FillDataSet(spName, ref outputParams);

            return ds;
        }

        public DataSet getServiceRemarks(int deptCode, int serviceCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, serviceCode };
            DataSet ds;

            string spName = "rpc_getServiceRemarks";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        

        public void deleteDic_GeneralRemark(int remarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { remarkID };

            string spName = "rpc_deleteDic_GeneralRemark";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public DataSet GetDIC_RemarkCategory()
        {
            object[] outputParams = new object[1] { new object() };
            DataSet ds;

            string spName = "rpc_GetDIC_RemarkCategory";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });
            ds = FillDataSet(spName, ref outputParams);

            return ds;
        }

        public bool DeleteRemarkCategory(int RemarkCategoryID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { RemarkCategoryID };


            string spName = "rpc_DeleteRemarkCategory";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return true;
        }

        public bool UpdateRemarkCategory(int RemarkCategoryID, string RemarkCategoryName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[2] { RemarkCategoryID, RemarkCategoryName };


            string spName = "rpc_UpdateRemarkCategory";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            
            return true;
        }

        public bool ApproveDICRemark_AndUpdateRemarks(int DIC_remarkID, string UserName, string newRemarkText)
        {
            bool executionResult = false;
            object[] outputParams = new object[1] { executionResult };
            object[] inputParams = new object[3] { DIC_remarkID, UserName, newRemarkText };


            string spName = "rpc_Update_DIC_remark_and_remarks_in_use";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return Convert.ToBoolean(outputParams[0]);
            //return true;
        }
        
        public bool InsertRemarkCategory(string RemarkCategoryName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { RemarkCategoryName };


            string spName = "rpc_InsertRemarkCategory";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            
            return true;
        }

        public bool RenewRemarks(int remarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { remarkID };

            string spName = "rpc_RefreshRemarks";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            
            return true;
        }

        public void UpdateDicGeneralRemark(
            int remarkID,
            string remark,
            int remarkCategory,
            bool active,
            bool linkedToDept,
            bool linkedToDoctor,
            bool linkedToDoctorInClinic,
            bool linkedToServiceInClinic,
            bool linkedToReceptionHours,
            bool EnableOverlappingHours,
            float factor,
            bool openNow,
            int showForPreviousDays,
            string UserName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { 
                remarkID,
                remark,
				remarkCategory,
                active,
                linkedToDept,
		        linkedToDoctor,
		        linkedToDoctorInClinic,
		        linkedToServiceInClinic,
		        linkedToReceptionHours,
                EnableOverlappingHours,
                factor,
                openNow,
                showForPreviousDays,
                UserName
            };


            string spName = "rpc_UpdateDicGeneralRemark";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void UpdateDeptRemark(int remarkID,string RemarkText,DateTime validFrom,DateTime? validTo, DateTime? activeFrom, bool displayInInternet,
                                    int showOrder, string updateUser)
        {

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { remarkID, RemarkText, validFrom, validTo, activeFrom, displayInInternet, showOrder, updateUser };

			string spName = "rpc_UpdateDeptRemark";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        

        public void InsertDicGeneralRemark(
                string remark,
                int remarkCategory,
                bool active,
                bool linkedToDept,
                bool linkedToDoctor,
                bool linkedToDoctorInClinic,
                bool linkedToServiceInClinic,
                bool linkedToReceptionHours, 
                bool EnableOverlappingHours,
                float factor,
                bool openNow,
                int showForPreviousDays,
                string UserName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { 
                remark,	
				remarkCategory,
                active,	
                linkedToDept,
		        linkedToDoctor,
		        linkedToDoctorInClinic,
		        linkedToServiceInClinic,
		        linkedToReceptionHours,
                EnableOverlappingHours,
                factor,
                openNow,
                showForPreviousDays,
                UserName};


            string spName = "rpc_InsertDic_GeneralRemark";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void InsertDicGeneralRemarkToCorrect(
                string remark,
                int DIC_GeneralRemarks_remarkID,
                string UserName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { 
                remark,
                DIC_GeneralRemarks_remarkID,
                UserName};

            string spName = "rpc_InsertDic_GeneralRemark_ToCorrect";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }
        
        public void DeleteDicGeneralRemarkToCorrect(int DIC_GeneralRemarks_remarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] {DIC_GeneralRemarks_remarkID};

            string spName = "rpc_DeleteDic_GeneralRemark_ToCorrect";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void GetSweepingRemarks(ref DataSet p_ds,
                                        string p_DistrictCode,
                                        string p_AdminClinicCode,
                                        string p_SectorCode,
                                        string p_UnitTypeCode,
                                        int p_subUnitTypeCode,
                                        int p_userPermittedDistrict,
                                        string p_servicesParameter,
                                        string p_cityCodes,
                                        string freeText)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_DistrictCode, p_AdminClinicCode, p_SectorCode, p_UnitTypeCode,
                                                    p_subUnitTypeCode, p_userPermittedDistrict, p_servicesParameter, p_cityCodes, freeText};
            if (p_DistrictCode == "-1" || p_DistrictCode == string.Empty)
                inputParams[0] = null;
            if (p_AdminClinicCode == "-1" || p_AdminClinicCode == string.Empty)
                inputParams[1] = null;
            if (p_SectorCode == "-1" || p_SectorCode == string.Empty)
                inputParams[2] = null;
            if (p_UnitTypeCode == "-1" || p_UnitTypeCode == string.Empty)
                inputParams[3] = null;
            if (p_servicesParameter == "-1" || p_servicesParameter == string.Empty)
                inputParams[6] = null;

            string spName = "rpc_GetSweepingRemarks_MultiSelected";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }

        public void GetSweepingRemarkByID(ref DataSet p_ds, int p_remarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_remarkID };

            string spName = "rpc_getSweepingRemarkByID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }

        public void GetSweepingRemarkAreasByRelatedRemarkID(ref DataSet p_ds, int p_remarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_remarkID };

            string spName = "rpc_getSweepingRemarkAreasByRelatedRemarkID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }

        public void GetUnitRemarks(ref DataSet p_ds, int UnitID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { UnitID };

            string spName = "rpc_GetUnitRemarks";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }

        public void UpdateEmployeeRemarks(ref DataTable p_TblRemarks, string p_UpdateUser)
        {
            object[] inputParams = new object[9];
            object[] inputParams2 = new object[1] { null };

            if (p_UpdateUser == null)
            {
                p_UpdateUser = string.Empty;
            }
            for (int i = 0; i < p_TblRemarks.Rows.Count; i++)
            {
                if (Convert.ToByte(p_TblRemarks.Rows[i]["Deleted"]) == 0)
                {
                    inputParams[0] = Convert.ToInt32(p_TblRemarks.Rows[i]["RemarkID"]);  //  @RemarkID int 
                    inputParams[1] = p_TblRemarks.Rows[i]["RemarkText"].ToString();  // @RemarkText varchar(max), 
                    inputParams[2] = Convert.ToDateTime(p_TblRemarks.Rows[i]["ValidFrom"]); //@ValidFrom smalldatetime,
                    inputParams[3] = null;
                    if (!string.IsNullOrEmpty(p_TblRemarks.Rows[i]["ValidTo"].ToString()))
                    {
                        inputParams[3] = p_TblRemarks.Rows[i]["ValidTo"].ToString(); //@ValidTo smalldatetime,
                    }

                    if (p_TblRemarks.Rows[i]["InternetDisplay"].ToString() == "True" || p_TblRemarks.Rows[i]["InternetDisplay"].ToString() == "False")
                        continue; // case of historyTable
                    inputParams[4] = Convert.ToDateTime(p_TblRemarks.Rows[i]["ActiveFrom"]); //@ActiveFrom smalldatetime,                    
                    inputParams[5] = Convert.ToByte(p_TblRemarks.Rows[i]["InternetDisplay"].ToString());  //;@InternetDisplay tinyint, 
                    inputParams[6] = p_TblRemarks.Rows[i]["DeptsCodes"].ToString();  //;@InternetDisplay tinyint, 
                    inputParams[7] = Convert.ToBoolean(p_TblRemarks.Rows[i]["AttributedToAllClinics"]);  //;@InternetDisplay tinyint, 
                    inputParams[8] = p_UpdateUser;// @UpdateUser varchar(50)

                    string spName = "rpc_UpdateEmployeeRemarks";
                    DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
                    ExecuteNonQuery(spName, inputParams);
                }
                else
                {
                    inputParams2[0] = Convert.ToInt32(p_TblRemarks.Rows[i]["RemarkID"]);  //  @RemarkID int
                    string spName = "rpc_deleteEmployeeRemarks";
                    DBActionNotification.RaiseOnDBDelete(spName, inputParams);
                    ExecuteNonQuery(spName, inputParams2);
                }
            }

        }

        public void UpdateEmployeeServiceRemarks(ref DataTable p_TblRemarks, string p_UpdateUser)
        {
            object[] inputParams = new object[6];
            object[] inputParams2 = new object[1] { null };

            if (p_UpdateUser == null)
            {
                p_UpdateUser = string.Empty;
            }
            for (int i = 0; i < p_TblRemarks.Rows.Count; i++)
            {
                if (Convert.ToByte(p_TblRemarks.Rows[i]["Deleted"]) == 0)
                {
                    inputParams[0] = Convert.ToInt32(p_TblRemarks.Rows[i]["RemarkID"]);  //  @RemarkID int 
                    inputParams[1] = p_TblRemarks.Rows[i]["RemarkText"].ToString();  // @RemarkText varchar(max), 
                    inputParams[2] = Convert.ToDateTime(p_TblRemarks.Rows[i]["ValidFrom"]); //@ValidFrom smalldatetime,
                    inputParams[3] = null;
                    if (!string.IsNullOrEmpty(p_TblRemarks.Rows[i]["ValidTo"].ToString()))
                    {
                        inputParams[3] = p_TblRemarks.Rows[i]["ValidTo"].ToString(); //@ValidTo smalldatetime,
                    }
                    
                    inputParams[4] = Convert.ToByte(p_TblRemarks.Rows[i]["InternetDisplay"]);  //;@InternetDisplay tinyint, 
                    inputParams[5] = p_UpdateUser;// @UpdateUser varchar(50)

                    string spName = "rpc_UpdateDeptEmployeeServiceRemark";
                    DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
                    ExecuteNonQuery(spName, inputParams);
                }
                else
                {
                    inputParams2[0] = Convert.ToInt32(p_TblRemarks.Rows[i]["RemarkID"]);  //  @RemarkID int
                    string spName = "rpc_DeleteDeptEmployeeServiceRemarkByRemarkID";
                    DBActionNotification.RaiseOnDBDelete(spName, inputParams);
                    ExecuteNonQuery(spName, inputParams2);
                }
            }

        }

        #region Remarks - Adiel

        public void GetEmployeeRemarksForUpdate(ref DataSet p_ds, int m_EmployeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { m_EmployeeID };


            string spName = "rpc_GetEmployeeRemarksForUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }
        public void GetEmployeeServiceRemarksForUpdate(ref DataSet p_ds, int DeptEmployeeID, int serviceCode)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { DeptEmployeeID, serviceCode };


            string spName = "rpc_GetEmployeeServiceRemarksForUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }


        public void GetEmployeeDepts(ref DataSet p_ds, long m_EmployeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[1] { m_EmployeeID };


            string spName = "rpc_GetEmployeeDepts";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        #endregion 

        #region Employee Remarks

        public void InsertEmployeeRemarks(int employeeID, string remarkText, int dicRemarkID, bool attributedToAllClinics, string delimitedDepts,
                                                                    bool displayInInternet, DateTime? validFrom, DateTime? validTo, DateTime? activeFrom, string updateUser)
        {

            SqlDateTime sqlFrom = SqlDateTime.Null, sqlTo = SqlDateTime.Null, sqlactiveFrom = SqlDateTime.Null; 

            if (validFrom != null)
            {
                sqlFrom = (SqlDateTime)validFrom;
            }
            if (validTo != null)
            {
                sqlTo = (SqlDateTime)validTo;
            }
            if (activeFrom != null)
            {
                sqlactiveFrom = (SqlDateTime)activeFrom;
            }
            else if(validFrom != null)
            {
                sqlactiveFrom = sqlFrom;
            }



            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { 
                employeeID, remarkText, dicRemarkID, attributedToAllClinics, delimitedDepts, displayInInternet, sqlFrom, sqlTo, sqlactiveFrom, updateUser};


            string spName = "rpc_insertEmployeeRemarks";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
            if (ErrorCode != 0)
            {
                switch (ErrorCode)
                {
                    case 2627: //duplicate key
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "RemarkLinkAlreadyExists") as string;
                        break;

                    case 547: //Data constraint violation
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "ConstraintViolation") as string;
                        break;

                    default:
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalInsertError") as string;
                        break;
                }
            }

        }

        public void DeleteEmployeeRemarks(int employeeRemarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeRemarkID };

            string spName = "rpc_deleteEmployeeRemarks";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public DataSet GetEmployeeRemarksAttributedToDepts(int employeeRemarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeRemarkID };
            DataSet ds;

            string spName = "rpc_getEmployeeRemarksAttributedToDepts";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeRemarksForDept(int deptCode, int employeeID)
        {

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, employeeID };
            DataSet ds;

            string spName = "rpc_getEmployeeRemarksForDept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public int InsertEmployeeRemarksAttributedToDepts(int employeeID, string deptCodes, int attributedToAll,
            int employeeRemarkID, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { employeeID, deptCodes, attributedToAll, employeeRemarkID, updateUser };


            string spName = "rpc_insertEmployeeRemarksAttributedToDepts";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);


            return ErrorCode;


        }

        #endregion

        //---- new Sweeping DeptRemarks concept
        public void DeleteDeptRemark(int DeptRemarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { DeptRemarkID };

            string spName = "rpc_DeleteDeptRemark";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);


        }

        //---- new Sweeping DeptRemarks concept
        public void InsertSweepingDeptRemark(int remarkDicID, string remarkText, string districtCodes, string administrationCodes,
            string UnitTypeCodes, string subUnitTypeCode, string populationSectorCodes, string excludedDeptCodes,
            DateTime? validFrom, DateTime? validTo, DateTime? dateShowFrom, bool displayInInternet, string cityCodes, string servicesParameter, string updateUser)
        {
            SqlDateTime sqlFrom = SqlDateTime.Null;
            SqlDateTime sqlTo = SqlDateTime.Null;
            SqlDateTime sqlShowFrom = SqlDateTime.Null;

            if (validFrom != null)
            {
                sqlFrom = (SqlDateTime)validFrom;
            }
            if (validTo != null)
            {
                sqlTo = (SqlDateTime)validTo;
            }
            if (dateShowFrom != null)
            {
                sqlShowFrom = (SqlDateTime)dateShowFrom;
            }

            //object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { remarkDicID, remarkText, districtCodes, administrationCodes, UnitTypeCodes,
                                                  subUnitTypeCode, populationSectorCodes, excludedDeptCodes, sqlFrom, sqlTo, sqlShowFrom, displayInInternet,
                                                  cityCodes, servicesParameter, updateUser};


            string spName = "rpc_InsertSweepingDeptRemark";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, inputParams);

        }

        //---- new Sweeping DeptRemarks concept
        public void InsertDeptRemark(int remarkDicID, string remarkText, int deptCode,
            DateTime? validFrom, DateTime? validTo, DateTime? activeFrom, bool displayInInternet, string updateUser)
        {
            SqlDateTime sqlFrom = SqlDateTime.Null;
            SqlDateTime sqlTo = SqlDateTime.Null;
            SqlDateTime sqlActiveFrom = SqlDateTime.Null;

            if (validFrom != null)
            {
                sqlFrom = (SqlDateTime)validFrom;
            }
            if (validTo != null)
            {
                sqlTo = (SqlDateTime)validTo;
            }
            if (activeFrom != null)
            {
                sqlActiveFrom = (SqlDateTime)activeFrom;
            }


            //object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { remarkDicID, remarkText, deptCode, sqlFrom, sqlTo, sqlActiveFrom, displayInInternet, 
                                                  updateUser};


            string spName = "rpc_InsertDeptRemark";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, inputParams);

        }

		//---- new Sweeping DeptRemarks concept
        public void InsertSweepingRemarkExclutions(int DeptRemarkID, int DeptCode, string updateUser)
        {
            object[] inputParams = new object[] { DeptRemarkID, DeptCode, updateUser };


            string spName = "rpc_InsertSweepingRemarkExclusions";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, inputParams);

        }

		//---- new Sweeping DeptRemarks concept
        public void GetSweepingRemarkExclusions(ref DataSet ds, int DeptRemarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { DeptRemarkID };


            string spName = "rpc_GetSweepingRemarkExcludedDepts";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

        }

        public DataSet getRemarksExtended(string selectedCodes, byte linkedToDept, byte linkedToServiceInClinic, byte linkedToDoctor,
                byte linkedToDoctorInClinic, byte linkedToReceptionHours)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { selectedCodes, linkedToDept, linkedToServiceInClinic, 
                linkedToDoctor, linkedToDoctorInClinic,  linkedToReceptionHours};

            string spName = "rpc_getRemarksExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetDeptRemarkDetails(int remarkId)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { remarkId };

            string spName = "rpc_GetDeptRemarkDetails";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = this.FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }
    }
}
