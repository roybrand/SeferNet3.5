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
    public class EmployeeRemarksBO
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


        /// <summary>
        /// select method
        /// </summary>
        /// <param name="searchFilter">The parameter used to filter the data with</param>
        /// <returns>System.Data.Dataset</returns>
		//[DataObjectMethod(DataObjectMethodType.Select)]
		//public DataSet GetEmployeeRemarks(long employeeID)
		//{
		//    RemarksDB remarksDB = new RemarksDB(conn.ConnectionString);
		//    return remarksDB.GetEmployeeRemarks(employeeID);
		//}

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteEmployeeRemarks(int employeeRemarkID)
        {
            RemarksDB remarksDB = new RemarksDB(conn.ConnectionString);
            remarksDB.DeleteEmployeeRemarks(employeeRemarkID);
            
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertEmployeeRemarks(int employeeID, string remarkText, int dicRemarkId, string delimitedDepts,
            bool displayInInternet, DateTime? validFrom, DateTime? validTo, DateTime? activeFrom, string updateUser)
        {
            RemarksDB remarksDB = new RemarksDB(conn.ConnectionString);
            bool attributedToAllClinics = false;

            if (delimitedDepts == "0" || string.IsNullOrEmpty(delimitedDepts))  // if all clinics were chosen
            {
                attributedToAllClinics = true;
                delimitedDepts = string.Empty;
            }

            remarksDB.InsertEmployeeRemarks(employeeID, remarkText, dicRemarkId, attributedToAllClinics, delimitedDepts, displayInInternet, 
                                                                                            validFrom, validTo, activeFrom, updateUser);

        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployeeRemarksAttributedToDepts(int employeeRemarkID)
        {
            RemarksDB remarksDB = new RemarksDB(conn.ConnectionString);
            return remarksDB.GetEmployeeRemarksAttributedToDepts(employeeRemarkID);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployeeRemarksForDept(int deptCode, int employeeID)
        {
            RemarksDB remarksDB = new RemarksDB(conn.ConnectionString);
            return remarksDB.GetEmployeeRemarksForDept(deptCode, employeeID);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public int InsertEmployeeRemarksAttributedToDepts(int employeeID, string deptCodes, int attributedToAll,
            int employeeRemarkID, string updateUser)
        {
            RemarksDB remarksDB = new RemarksDB(conn.ConnectionString);
            return remarksDB.InsertEmployeeRemarksAttributedToDepts(employeeID, deptCodes, attributedToAll, employeeRemarkID, updateUser);

        }
    }
}





