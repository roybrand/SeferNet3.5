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
    public class DeptStatusBO
    {

        internal class Constants
        {
            //public const String SeferNetConnectionString = "SeferNetConnectionString";
        }

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
        public DataSet GetDeptStatus(int deptCode)
        {
            ClinicDB clinicDB = new ClinicDB(conn.ConnectionString);
            return clinicDB.GetDeptStatus(deptCode);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptStatusByID(int statusID)
        {
            ClinicDB clinicDB = new ClinicDB(conn.ConnectionString);
            return clinicDB.GetDeptStatusByID(statusID);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertDeptStatus(int deptCode, int status, DateTime fromDate, DateTime toDate, string updateUser)
        {
            ClinicDB clinicDB = new ClinicDB(conn.ConnectionString);
            clinicDB.InsertDeptStatus(deptCode, status, fromDate, toDate, updateUser);
        }


        public DateTime? GetClosestNotActiveStatusDate(int deptCode)
        {
            ClinicDB clinicDB = new ClinicDB(conn.ConnectionString);
            DateTime? date = null;

            DataSet ds = clinicDB.GetClosestNotActiveDate(deptCode, DateTime.Now);
            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
               date = Convert.ToDateTime(ds.Tables[0].Rows[0][0]);
            }
            return date;
        }
    }
}





