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
    public class RemarkInfoBO
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
                    _objData = new DataSet("dsRemarks");

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

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet getRemarksTypes()
        {
            RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
            return remarksdb.getRemarksTypes();
        }

        // to delete -
        //[DataObjectMethod(DataObjectMethodType.Delete)]
        //public void Delete(int relatedRemarkID)
        //{
        //    RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
        //    remarksdb.DeleteRemark(relatedRemarkID);
        //}
	[DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetRemarksExtended(string selectedCodes, byte linkedToDept, byte linkedToServiceInClinic, byte linkedToDoctor,
                byte linkedToDoctorInClinic, byte linkedToReceptionHours)
        {
            RemarksDB remarksDB = new RemarksDB(conn.ConnectionString);
            return remarksDB.getRemarksExtended(selectedCodes, linkedToDept, linkedToServiceInClinic, linkedToDoctor,
                linkedToDoctorInClinic, linkedToReceptionHours);
        }
    }
}





