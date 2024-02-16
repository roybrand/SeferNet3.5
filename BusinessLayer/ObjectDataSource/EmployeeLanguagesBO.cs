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
    public class EmployeeLanguagesBO
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
        public DataSet GetLanguagesExtended(string selectedLanguages)
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetLanguagesExtended(selectedLanguages);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetLanguagesForEmployee(long employeeID)
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetLanguagesForEmployee(employeeID);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetLanguagesForEmployeeExtended(long employeeID)
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetLanguagesForEmployeeExtended(employeeID);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteEmployeeLanguages(int employeeID, int languageCode)
        {
            DoctorDB doctorDB = new DoctorDB();
            doctorDB.DeleteEmployeeLanguages(employeeID, languageCode);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertEmployeeLanguages(int employeeID, string languageCodes, string updateUser)
        {
            DoctorDB doctorDB = new DoctorDB();
            doctorDB.InsertEmployeeLanguages(employeeID, languageCodes, updateUser);
        }



        public void DeleteAllLanguagesAndInsert(long employeeID, string seperatedValues, string userName)
        {
            SqlTransaction trans = null;
            try
            {
                DoctorDB dal = new DoctorDB();
                conn.Open();
                trans = conn.BeginTransaction();

                dal.DeleteAllEmployeeLanguages(employeeID);

                if (!string.IsNullOrEmpty(seperatedValues))
                {
                    // link the languages to the employee
                    dal.InsertEmployeeLanguages(employeeID, seperatedValues, userName);
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
    }
}





