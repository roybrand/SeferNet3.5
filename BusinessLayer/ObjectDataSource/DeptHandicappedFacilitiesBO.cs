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
    public class DeptHandicappedFacilitiesBO
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
        public DataSet GetHandicappedFacilitiesExtended(string selectedFacilities)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetHandicappedFacilitiesExtended(selectedFacilities); 
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetHandicappedFacilitiesInDept(int deptCode)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetHandicappedFacilitiesInDept(deptCode); 
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetHandicappedFacilitiesForDept(int deptCode)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetHandicappedFacilitiesForDept(deptCode);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteDeptHandicappedFacilities(int deptCode, int facilityCode)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.DeleteDeptHandicappedFacilities( deptCode, facilityCode);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertDeptHandicappedFacilities(int deptCode, string handicappedFacilities)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.InsertDeptHandicappedFacilities(deptCode, handicappedFacilities);
        }

    }
}





