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
    public class EmployeeServicesBO
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
        public DataSet GetEmployeeServices(long employeeID)
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetEmployeeServices(employeeID);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteEmployeeService(int employeeID, int serviceCode)
        {
            DoctorDB doctorDB = new DoctorDB();
            doctorDB.DeleteEmployeeService(employeeID, serviceCode);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertEmployeeServices(int employeeID, string serviceCodes, string updateUser)
        {
            DoctorDB doctorDB = new DoctorDB();
            doctorDB.InsertEmployeeServices(employeeID, serviceCodes, updateUser);
        }

        public void DeleteAllEmployeeServicesAndInsert(long employeeID, string selectedValues, string userName)
        {
            SqlTransaction trans = null;
            try
            {
                DoctorDB dal = new DoctorDB();
                conn.Open();
                trans = conn.BeginTransaction();

                dal.DeleteAllEmployeeServices(employeeID);

                if (!string.IsNullOrEmpty(selectedValues))
                {
                    dal.InsertEmployeeServices(employeeID, selectedValues, userName);
                }

                trans.Commit();

            }
            catch (Exception)
            {
                if (conn != null)
                    conn.Close();

                if (trans != null)
                    trans.Rollback();
            }
            finally
            {
                if (conn != null)
                {
                    conn.Close();
                }
            }     
        }

		//public DataSet GetEmployeeServicesFromWholeList(long employeeID)
		//{
		//    DoctorDB doctorDB = new DoctorDB();
		//    return doctorDB.GetServicesForEmployee(employeeID);
		//}
    }
}





