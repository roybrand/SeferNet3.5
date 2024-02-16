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
using System.Transactions;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.ObjectDataSource
{ 
    [DataObject(true)]
    public class DoctorsInClinicBO
    {

         internal class Constants
         {
                //public const String SeferNetConnectionString = "SeferNetConnectionString";
         }

    /// <summary>
    /// priviate field for ObjData property
    /// </summary>
    private DataSet _objData;
    /// <summary>
    /// Property to hold our dataset
    /// </summary>
    public DataSet ObjData
    {
        get
        {
            if (_objData == null)
                _objData = new DataSet("dsDoctorsInClinic");

            return _objData;
        }
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
    
    /// <summary>
    /// select method
    /// </summary>
    /// <param name="searchFilter">The parameter used to filter the data with</param>
    /// <returns>System.Data.Dataset</returns>
        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployeeInDeptDetails(int deptEmployeeID)
        {
            ClinicDB clininDb = new ClinicDB();
            _objData = clininDb.GetEmployeeInDeptDetails(deptEmployeeID);
            
            return ObjData;
        }


        [DataObjectMethod(DataObjectMethodType.Insert, true)]
        public void InsertDoctorInClinic(int DeptCode, int employeeID, int agreementType, string updateUser, bool active)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.InsertDoctorInClinic(DeptCode, employeeID, agreementType, updateUser, active);
        }

        [DataObjectMethod(DataObjectMethodType.Update, true)]
        public int updateDoctorsInClinic(int deptCode, long employeeID, int agreementType_Old, int agreementType_new, bool receiveGuests,
            string updateUser, bool showPhonesFromDept)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.updateDoctorsInClinic(deptCode, employeeID, agreementType_Old, agreementType_new, receiveGuests, updateUser, showPhonesFromDept);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteDoctorInClinic(int deptEmployeeID, int deptCode)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.DeleteDoctorInClinic(deptEmployeeID, deptCode);
        }

        public DataSet GetAllEmployeeStatusesInDept(long employeeID, int deptCode)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetAllEmployeeStatusesInDept(employeeID, deptCode);
        }

        public DataSet GetCurrentStatusForEmployeeInDept(int deptEmployeeID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetCurrentStatusForEmployeeInDept(deptEmployeeID);
        }

        public int GetCurrentStatusForEmployeeInDept_byEpmployeeIDandDeptCode(long EmployeeID, int deptCode, int AgreementType)
        {
            DoctorDB dal = new DoctorDB();
            DataSet ds = dal.GetCurrentStatusForEmployeeInDept_byEpmployeeIDandDeptCode(EmployeeID, deptCode, AgreementType);
            return  Convert.ToInt32(ds.Tables[0].Rows[0]["active"]);
        }

    }




}





