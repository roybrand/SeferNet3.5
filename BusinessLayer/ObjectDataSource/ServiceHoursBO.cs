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
    public class ServiceHoursBO
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
                    _objData = new DataSet("dsDoctorHours");

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


    

    }
}





