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
using SeferNet.BusinessLayer.BusinessObject;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class EmployeeBO
    {

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

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployee(long employeeID)
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetEmployee(employeeID); 
        }       

        public DataSet GetAllEmployeeDegrees()
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetAllEmployeeDegrees();
        }

        //[DataObjectMethod(DataObjectMethodType.Delete)]
        //public void DeleteEmployee(int employeeID)
        //{
        //    DoctorDB doctorDB = new DoctorDB();
        //    doctorDB.DeleteEmployee(employeeID);
        //}

        //[DataObjectMethod(DataObjectMethodType.Update)]
        //public int UpdateEmployee(long employeeID, int degreeCode, string firstName, string lastName,
        //    int EmployeeSectorCode, int sex, int primaryDistrict, string email, bool showEmailInInternet, Phone homePhone, Phone cellPhone, string updateUser)
        //{

        //    DoctorDB doctorDB = new DoctorDB();
        //    PhoneDB phoneDB = new PhoneDB(conn.ConnectionString);

        //    SqlTransaction trans = null;
        //    int Error = 0;
        //    int count = 0;

        //    try
        //    {
        //        conn.Open();
        //        trans = conn.BeginTransaction();

        //        Error = doctorDB.UpdateEmployee( employeeID, degreeCode, firstName, lastName, EmployeeSectorCode, sex,
        //                primaryDistrict, email, showEmailInInternet, updateUser);

        //        if (Error != 0)
        //        {
        //            if (trans != null)
        //                trans.Rollback();
        //            return Error;
        //        }

        //        Error = phoneDB.DeleteEmployeePhones(trans, employeeID);
        //        if (Error != 0)
        //        {
        //            if (trans != null)
        //                trans.Rollback();
        //            return Error;
        //        }

        //        if (homePhone != null && homePhone.PhoneNumber != -1)
        //        {
        //            count = phoneDB.InsertEmployeePhone(trans, employeeID, 1, 1,
        //                homePhone.PrePrefix, homePhone.PreFix, homePhone.PhoneNumber, homePhone.Extension,
        //                Convert.ToInt16(homePhone.IsUnListed), updateUser);
        //            if (count == 0)
        //            {
        //                if (trans != null)
        //                    trans.Rollback();
        //                return Error;
        //            }
        //        }

        //        if (cellPhone != null && cellPhone.PhoneNumber != -1)
        //        {
        //            count = phoneDB.InsertEmployeePhone(trans, employeeID, 3, 1,
        //                cellPhone.PrePrefix, cellPhone.PreFix, cellPhone.PhoneNumber, cellPhone.Extension,
        //                Convert.ToInt16(cellPhone.IsUnListed), updateUser);
        //            if (count == 0)
        //            {
        //                if (trans != null)
        //                    trans.Rollback();
        //                return Error;
        //            }
        //        }


        //        trans.Commit();
        //        return Error;
        //    }
        //    catch (Exception)
        //    {
        //        if (trans != null)
        //        {
        //            trans.Rollback();
        //        }

        //        throw;
        //    }
        //    finally
        //    {
        //        conn.Close();
        //    }
        //}

        public DataSet GetAllEmployeeStatus(long employeeID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetAllEmployeeStatuses(employeeID); 
        }

        public bool IsEmployeeDoctor(long employeeID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.CheckIfEmployeeIsDoctor(employeeID);
        }

        public DateTime? GetClosestNotActiveStatusDate(int employeeID)
        {
            DoctorDB dal = new DoctorDB();
            return null;
        }

        public DataSet GetEmployeeCurrentStatus(long employeeID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetCurrentStatusForEmployee(employeeID);
        }

        public void IsVirtualDoctorOrMedicalTeam(long employeeID, ref bool isVirtualDoctor, ref bool isMedicalTeam)
        {
            DoctorDB dal = new DoctorDB();
            DataSet ds = dal.IsVirtualDoctorOrMedicalTeam(employeeID);

            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                isVirtualDoctor =  Convert.ToBoolean(ds.Tables[0].Rows[0]["IsVirtualDoctor"]);
                isMedicalTeam = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsMedicalTeam"]);
            }
        }

        public bool IsEmployeeIsDoctor(long employeeID, int? licenseNumber)
        {
            DoctorDB dal = new DoctorDB();            
            
            return dal.CheckIfEmployeeExistsInDoctorsList(employeeID, licenseNumber);
        }

        public bool IsEmployeeExistsInEmployee(long employeeID)
        {
            DoctorDB dal = new DoctorDB();

            return dal.CheckIfEmployeeExistsInEmployee(employeeID);
        }

        public bool IsProfessionAllowedForEmployee(long employeeID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.IsProfessionAllowedForEmployee(employeeID);
        }

        public DataSet GetEmployeeDeptsByText(string prefixText, long employeeID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetEmployeeDeptsByText(prefixText, employeeID);
        }

        public DataSet GetRelatedDeptsForEmployeeRemark(int employeeRemarkID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetRelatedDeptsForEmployeeRemark(employeeRemarkID);
        }

        public bool IsEmployeeQueueOrderEnabledInDept(long EmployeeID, int DeptCode, out bool queueOrderIsMandatory)
        {
            if (IsEmployeeDoctor(EmployeeID))
            {
                QueueOrderMethodBO bo = new QueueOrderMethodBO();
                queueOrderIsMandatory = true;
                return  bo.CheckIfQueueOrderEnabled(EmployeeID, DeptCode);
            }
            else
            {
                queueOrderIsMandatory = false;
                return IsEmployeeParaMedicalOrSiudSector(EmployeeID);                
            } 
        }

        private bool IsEmployeeParaMedicalOrSiudSector(long EmployeeID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.IsEmployeeParaMedicalOrSiudSector(EmployeeID);
        }
    }
}





