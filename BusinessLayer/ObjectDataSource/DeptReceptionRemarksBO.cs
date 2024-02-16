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
    public class DeptReceptionRemarksBO
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
        public DataSet GetDeptServiceReceptionRemarks(int receptionID)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetDeptReceptionRemarks(receptionID);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptReceptionRemarkForUpdate(int deptReceptionRemarkID)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetDeptReceptionRemarkForUpdate(deptReceptionRemarkID);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void Delete(int deptReceptionRemarkID)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.DeleteDeptReceptionRemark(deptReceptionRemarkID);
        }

        [DataObjectMethod(DataObjectMethodType.Update)]
        public void UpdateDeptReceptionRemark(int deptReceptionRemarkID, string remarkText,
            DateTime validFrom, DateTime validTo, int DisplayInInternet, string updateUser)
        {
            if (validFrom == DateTime.MinValue)
                validFrom = Convert.ToDateTime("1/1/1900");
            if (validTo == DateTime.MinValue)
                validTo = Convert.ToDateTime("1/1/1900");

            ClinicDB clinicDB = new ClinicDB();
            clinicDB.UpdateDeptReceptionRemark(deptReceptionRemarkID, remarkText, validFrom, validTo, DisplayInInternet, updateUser);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertDeptReceptionRemark(int receptionID, string remarkText,
            DateTime validFrom, DateTime validTo, int DisplayInInternet, string updateUser)
        {
            if (validFrom == DateTime.MinValue)
                validFrom = Convert.ToDateTime("1/1/1900");
            if (validTo == DateTime.MinValue)
                validTo = Convert.ToDateTime("1/1/1900");

            ClinicDB clinicDB = new ClinicDB();
            clinicDB.InsertDeptReceptionRemark(receptionID, remarkText, validFrom, validTo, DisplayInInternet, updateUser);
        }

    }
}





