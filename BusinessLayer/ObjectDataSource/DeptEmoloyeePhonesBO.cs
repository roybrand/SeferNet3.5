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
using System.Transactions;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class DeptEmoloyeePhonesBO
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

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptEmployeePhones(int deptEmployeeID)
        {
            PhoneDB phoneDB = new PhoneDB(conn.ConnectionString);
            return phoneDB.GetDeptEmployeePhones(deptEmployeeID);
        }

        [DataObjectMethod(DataObjectMethodType.Update)]
        public void UpdateEmplyeePhonesCascadeFromDept(int deptCode, int employeeID, int cascadeUpdateDeptEmployeePhonesFromClinic, string updateUser)
        {
            PhoneDB phoneDB = new PhoneDB(conn.ConnectionString);
            phoneDB.UpdateEmplyeePhonesCascadeFromDept(deptCode, employeeID, cascadeUpdateDeptEmployeePhonesFromClinic, updateUser);
        }

        /// <summary>
        /// Deletes all dep EmployeePhones,and insert the existing phones in the data table
        /// </summary>
        /// <param name="phonesDt"></param>
        /// <param name="updateUser"></param>
        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertDeptEmployeePhones(int deptEmployeeID, DataTable phonesDt, string updateUser)
        {
            PhoneDB phoneDB = new PhoneDB(conn.ConnectionString);
            Phone phone;

            phoneDB.DeleteAllDeptEmployeePhones(deptEmployeeID);

            if (phonesDt.Rows.Count > 0)
            {
                for (int i = 0; i < phonesDt.Rows.Count; i++)
                {
                    phone = new Phone(phonesDt.Rows[i]);

                    phoneDB.InsertDeptEmployeePhone(deptEmployeeID, phone.PhoneType, phone.PrePrefix, phone.PreFix,
                                                    phone.PhoneNumber, phone.Extension, updateUser);
                }
            }

        }

    }
}





