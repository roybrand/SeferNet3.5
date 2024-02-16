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
    public class DeptPhonesBO
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
                    _objData = new DataSet("dsDeptPhones");

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
        public DataSet Select(int deptCode, int phoneType)
        {
            GetDeptPhones(deptCode, phoneType);
            return ObjData;
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptPhoneForUpdate(int deptPhoneID)
        {
            PhoneDB phoneDB = new PhoneDB(conn.ConnectionString);
            return phoneDB.GetDeptPhoneForUpdate(deptPhoneID);
        }       

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertDeptPhone(int deptCode, int phoneType, int prePrefix, int prefix, int phone, string remark, string updateUser)
        {
            int extension = 0;
            int phoneOrder = 0;
            PhoneDB phoneDB = new PhoneDB(conn.ConnectionString);
            phoneDB.InsertDeptPhone(deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, remark, updateUser);
        }

        /// <summary>
        /// private method that executes the command to return data from the sql server 
        /// </summary>
        /// <param name="DeptCode"> parameter from Select </param>
        private void GetDeptPhones(int deptCode, int phoneType)
        {
            PhoneDB phoneDB = new PhoneDB(conn.ConnectionString);

            _objData = phoneDB.GetDeptPhones(deptCode, phoneType);

        }


        public DataSet GetDeptMainPhones(int DeptCode)
        {
            PhoneDB dal = new PhoneDB(conn.ConnectionString);
            return dal.GetDeptMainPhones(DeptCode, -1);
        }
    }
}





