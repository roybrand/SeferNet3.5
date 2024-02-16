using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
using System.ComponentModel;
using SeferNet.DataLayer;
using System.Globalization;
using System.Data.SqlTypes;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class DoctorHoursBO
    {

         internal class Constants
         {
                //public const String SeferNetConnectionString = "SeferNetConnectionString";
         }

        /// <summary>
        /// private field for conn property
        /// </summary>
        private SqlConnection _conn;
        /// <summary>
        /// Propery to hold our SQL connection
        /// </summary>
        private SqlConnection conn
        {
            get
            {
                if (_conn == null)
                    _conn = new SqlConnection(ConnectionHandler.ResolveConnStrByLang());

                return _conn;
            }
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public int DeleteDoctorHours(int receptionID)
        {
            DoctorDB doctordb = new DoctorDB();
            return doctordb.DeleteDoctorHours(receptionID);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptEmployeeReceptionProfessions_Attributed(int receptionID)
        {
            DoctorDB doctordb = new DoctorDB();

            return doctordb.GetDeptEmployeeReceptionProfessions_Attributed(receptionID);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptEmployeeServicesForReceptionToAdd(int receptionID, int deptCode, int employeeID)
        {
            DoctorDB doctordb = new DoctorDB();

            return doctordb.GetDeptEmployeeServicesForReceptionToAdd(receptionID, deptCode, employeeID);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public string DeleteDeptEmployeeReceptionProfessions(int deptEmployeeReceptionProfessionsID)
        {
            DoctorDB doctordb = new DoctorDB();
            return doctordb.DeleteDeptEmployeeReceptionProfessions(deptEmployeeReceptionProfessionsID);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptEmployeeReceptionRemarks(int employeeReceptionID)
        {
            DoctorDB doctordb = new DoctorDB();

            return doctordb.GetDeptEmployeeReceptionRemarks(employeeReceptionID);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptEmployeeReceptionRemarksByID(int deptEmployeeReceptionRemarkID)
        {
            DoctorDB doctordb = new DoctorDB();

            return doctordb.GetDeptEmployeeReceptionRemarksByID(deptEmployeeReceptionRemarkID);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteDeptEmployeeReceptionRemarks(int DeptEmployeeReceptionRemarkID)
        {
            DoctorDB doctordb = new DoctorDB();
            doctordb.DeleteDeptEmployeeReceptionRemarks(DeptEmployeeReceptionRemarkID);
        }

        //public void UpdateEmployeeReceptions_TR(long employeeID, DataTable dt, string updateUser)
        //{
           // SqlTransaction trans = null;
           // string idToDelete = string.Empty;
           // int deptCode, employeeId, receptionDay, itemID, remarkId;
           // string itemType, remarkText, openingHour, closingHour;
           // DateTime? validFrom = null, validTo = null;

           // DataRow[] rows = dt.Select("receptionDay is not null");



           //try
           // {
           //     conn.Open();
           //     trans = conn.BeginTransaction();

           //     DoctorDB dal = new DoctorDB();
           //      dal.DeleteEmployeeReception(employeeID, trans);

           //     foreach (DataRow row in rows)
           //     {
           //         deptCode = Convert.ToInt32(row["deptCode"]);
           //         employeeId = Convert.ToInt32(row["EmployeeID"]);
           //         receptionDay = Convert.ToInt32(row["receptionDay"]);
           //         openingHour = row["openingHour"].ToString();
           //         closingHour = row["closingHour"].ToString();
           //         itemType = row["itemType"].ToString();
           //         itemID = Convert.ToInt32(row["itemID"]);
           //         remarkText = row["remarkText"].ToString();
           //         remarkId = -1;
           //         if (row["remarkID"] != DBNull.Value)
           //         {
           //             remarkId = Convert.ToInt32(row["remarkID"]);
           //         }


           //         validFrom = validTo = null;

           //         if (row["validFrom"] != DBNull.Value)
           //         {
           //             validFrom = Convert.ToDateTime(row["validFrom"]);
           //         }
           //         if (row["validTo"] != DBNull.Value)
           //         {
           //             validTo = Convert.ToDateTime(row["validTo"]);
           //         }

           //         dal.InsertEmployeeReception(trans, deptCode, employeeId, receptionDay, openingHour, closingHour, itemType, itemID,
           //                                                     remarkText, remarkId, validFrom, validTo, updateUser);
           //     }

           //     trans.Commit();
           // }
           // catch (Exception)
           // {
           //     if (trans != null)
           //     {
           //         trans.Rollback();
           //     }
           //     throw;
           // }
           // finally
           // {
           //     if (conn != null)
           //     {
           //         conn.Close();
           //     }
           // }
        //}

        public void UpdateEmployeeReceptions(long employeeID, DataTable dt, string updateUser)
        {
            string idToDelete = string.Empty;
            int deptCode = -1;
            int employeeId, receptionDay, itemID, remarkId;
            string itemType, remarkText, openingHour, closingHour;
            string receptionRoom = string.Empty;
            DateTime? validFrom = null, validTo = null;
            DataRow[] rows = dt.Select("receptionDay is not null");
            bool? receiveGuests = null;

            int agreementType = -1;

            DoctorDB dal = new DoctorDB();
            dal.DeleteEmployeeReception(employeeID, deptCode, agreementType);

            foreach (DataRow row in rows)
            {
                deptCode = Convert.ToInt32(row["deptCode"]);
                employeeId = Convert.ToInt32(row["EmployeeID"]);
                agreementType = Convert.ToInt32(row["agreementType"]);
                receptionDay = Convert.ToInt32(row["receptionDay"]);
                openingHour = row["openingHour"].ToString();
                closingHour = row["closingHour"].ToString();
                if (row["receptionRoom"] != DBNull.Value)
                {
                    receptionRoom = row["receptionRoom"].ToString();
                }
                receiveGuests = Convert.ToBoolean(row["receiveGuests"]);
                itemType = row["itemType"].ToString();
                itemID = Convert.ToInt32(row["itemID"]);
                remarkText = row["remarkText"].ToString();
                remarkId = -1;
                if (row["remarkID"] != DBNull.Value)
                {
                    remarkId = Convert.ToInt32(row["remarkID"]);
                }


                validFrom = validTo = null;

                if (row["validFrom"] != DBNull.Value)
                {
                    validFrom = Convert.ToDateTime(row["validFrom"]);
                }
                if (row["validTo"] != DBNull.Value)
                {
                    validTo = Convert.ToDateTime(row["validTo"]);
                }

                dal.InsertEmployeeReception(deptCode, employeeId, agreementType, receptionDay, openingHour, closingHour, receptionRoom, receiveGuests, itemType, itemID,
                                                            remarkText, remarkId, validFrom, validTo, updateUser);
            }

            dal.Update_DeptEmployeeReception_Regular_ThisWeak(employeeID);

        }

        public void UpdateEmployeeReceptions(long employeeID, DataTable dt, string updateUser, bool isMedicalTeam, bool isVirtualDoctor, int currentDeptCode, int agreementType_Old, int agreementType_New)
        {
            string idToDelete = string.Empty;
            int deptCode, employeeId, agreementType, receptionDay, itemID, remarkId;
            int deptCodeTodeleteHours = currentDeptCode;
            int agreementTypeToDeleteHours = agreementType_New;
            string itemType, remarkText, openingHour, closingHour;
            string receptionRoom = string.Empty;
            DateTime? validFrom = null, validTo = null;
            bool? receiveGuests = null;

            DataRow[] rows = dt.Select("receptionDay is not null");



            DoctorDB dal = new DoctorDB();
            if (!isMedicalTeam && !isVirtualDoctor)
            {
                deptCodeTodeleteHours = -1;
                agreementTypeToDeleteHours = -1;
            }
            dal.DeleteEmployeeReception(employeeID, deptCodeTodeleteHours, agreementTypeToDeleteHours);

            foreach (DataRow row in rows)
            {
                deptCode = Convert.ToInt32(row["deptCode"]);
                employeeId = Convert.ToInt32(row["EmployeeID"]);
                agreementType = Convert.ToInt32(row["agreementType"]);
                if(deptCode == currentDeptCode && agreementType == agreementType_Old)
                    agreementType = agreementType_New;
                receptionDay = Convert.ToInt32(row["receptionDay"]);
                openingHour = row["openingHour"].ToString();
                closingHour = row["closingHour"].ToString();
                if (row["receptionRoom"] != DBNull.Value)
                {
                    receptionRoom = row["receptionRoom"].ToString();
                }
                else
                {
                    receptionRoom = string.Empty;           
                }
                receiveGuests = Convert.ToBoolean(row["receiveGuests"]);
                itemType = row["itemType"].ToString();
                itemID = Convert.ToInt32(row["itemID"]);
                remarkText = row["remarkText"].ToString();
                remarkId = -1;
                if (row["remarkID"] != DBNull.Value)
                {
                    remarkId = Convert.ToInt32(row["remarkID"]);
                }


                validFrom = validTo = null;

                if (row["validFrom"] != DBNull.Value)
                {
                    validFrom = Convert.ToDateTime(row["validFrom"]);
                }
                if (row["validTo"] != DBNull.Value)
                {
                    validTo = Convert.ToDateTime(row["validTo"]);
                }

                dal.InsertEmployeeReception( deptCode, employeeId, agreementType, receptionDay, openingHour, closingHour, receptionRoom, receiveGuests, itemType, itemID,
                                                            remarkText, remarkId, validFrom, validTo, updateUser);
            }

            dal.Update_DeptEmployeeReception_Regular_ThisWeak(employeeID);

        }

        public void UpdateEmployeeReceptions(long employeeID, DataTable dt, string updateUser, bool isMedicalTeam)
        {
            string idToDelete = string.Empty;
            int deptCode, employeeId, receptionDay, itemID, remarkId;
            int currentDeptCode = -1;
            int agreementType = -1;
            string itemType, remarkText, openingHour, closingHour;
            string receptionRoom = string.Empty;
            DateTime? validFrom = null, validTo = null;
            DataRow[] rows = dt.Select("receptionDay is not null");
            bool? receiveGuests = null;


            DoctorDB dal = new DoctorDB();
            if (!isMedicalTeam)
                currentDeptCode = -1;
            dal.DeleteEmployeeReception(employeeID, currentDeptCode, agreementType);

            foreach (DataRow row in rows)
            {
                deptCode = Convert.ToInt32(row["deptCode"]);
                employeeId = Convert.ToInt32(row["EmployeeID"]);
                agreementType = Convert.ToInt32(row["agreementType"]);
                receptionDay = Convert.ToInt32(row["receptionDay"]);
                openingHour = row["openingHour"].ToString();
                closingHour = row["closingHour"].ToString();
                if (row["receptionRoom"] != DBNull.Value)
                {
                    receptionRoom = row["receptionRoom"].ToString();
                }
                itemType = row["itemType"].ToString();
                itemID = Convert.ToInt32(row["itemID"]);
                remarkText = row["remarkText"].ToString();
                remarkId = -1;
                if (row["remarkID"] != DBNull.Value)
                {
                    remarkId = Convert.ToInt32(row["remarkID"]);
                }


                validFrom = validTo = null;

                if (row["validFrom"] != DBNull.Value)
                {
                    validFrom = Convert.ToDateTime(row["validFrom"]);
                }
                if (row["validTo"] != DBNull.Value)
                {
                    validTo = Convert.ToDateTime(row["validTo"]);
                }

                dal.InsertEmployeeReception(deptCode, employeeId, agreementType, receptionDay, openingHour, closingHour, receptionRoom, receiveGuests, itemType, itemID,
                                                            remarkText, remarkId, validFrom, validTo, updateUser);
            }

        }

    }


}





