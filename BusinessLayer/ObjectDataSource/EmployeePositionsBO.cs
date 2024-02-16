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

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class EmployeePositionsBO
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
    

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployeePositionsInDept(int deptEmployeeID)
        { 
            ClinicDB clininDb = new ClinicDB();
            
            return clininDb.GetEmployeePositionsForPopup(deptEmployeeID);
        }

        [DataObjectMethod(DataObjectMethodType.Insert, true)]
        public void InsertEmployeePositionsInDept(int deptCode, int employeeID, string positionCodes, string updateUser)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.InsertEmployeePositionsInDept(employeeID, deptCode, positionCodes, updateUser);
        }

        [DataObjectMethod(DataObjectMethodType.Update)]
        public void UpdateEmployeePositionInDept(int employeeID, int deptCode, string seperatedValues, string userName)
        {
            SqlTransaction trans = null;
            try
            {
                ClinicDB dal = new ClinicDB();
                conn.Open();
                trans = conn.BeginTransaction();
                
                dal.DeleteAllEmployeePositionInDept(employeeID, deptCode);   // delete the existing positions
                
                if (!string.IsNullOrEmpty(seperatedValues))
                {
                    dal.InsertEmployeePositionsInDept(employeeID, deptCode, seperatedValues, userName); // insert the new positions
                }

                trans.Commit();
            }
            catch (Exception)
            {
                if (conn != null)
                {
                    conn.Close();
                }

                if (trans != null)
                {
                    trans.Rollback();
                    trans = null;
                }

            }            
        }

        public void UpdateEmployeeProfessionLicence(long employeeID, int profLicence, string userName)
        {
            DoctorDB dal = new DoctorDB();
            dal.UpdateEmployeeProfessionLicence(employeeID, profLicence, userName); 
        }

        public DataSet GetEmployeesToUpdateProfessionLicences()
        {
            DoctorDB dal = new DoctorDB();
            DataSet ds = dal.GetEmployeesToUpdateProfessionLicences();
            return ds;
        }

        public DataSet GetX_EmployeeSubSector_ProfLicenseType()
        {
            DoctorDB dal = new DoctorDB();
            DataSet ds = dal.GetX_EmployeeSubSector_ProfLicenseType();
            return ds;
        }
        public int UpdateEmployeeProfessionLicences(DataTable EmployeeProfessionLicences)
        {
            int outputParam = 0;
            DoctorDB dal = new DoctorDB();

            return dal.UpdateEmployeeProfessionLicences(EmployeeProfessionLicences);
        }

        public DataSet GetAllPositionsByName(string prefixText, long employeeID)
        {
            DoctorDB dal = new DoctorDB();

            return dal.GetAllPositionsByName(prefixText, employeeID);
        }
    }


}





