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
using SeferNet.Globals;
using SeferNet.BusinessLayer.BusinessObject;
using System.Collections.Generic;


namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)] 
    public class DeptBO
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
        public DataSet GetUnitTypesExtended(string selectedUnitTypeCodes, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.getUnitTypesExtended(selectedUnitTypeCodes, agreementTypes);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetObjectTypesExtended(string selectedCodes)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.getObjectTypesExtended(selectedCodes);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEventsExtended(string selectedCodes)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.getEventsExtended(selectedCodes);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDistrictsExtended(string selectedDistricts, string unitTypeCodes, string permittedDistricts)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.getDistrictsExtended(selectedDistricts, unitTypeCodes, permittedDistricts);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetAdminsExtended(string p_selectedAdmins, string p_districts)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.getAdminsExtended(p_selectedAdmins, p_districts);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetClinicsExtended(string p_selectedClinics, string p_selectedAdmins, string p_districts, string p_unitTypeListCodes, string p_subUnitTypeCode, string p_populationSector)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetClinicsExtended(p_selectedClinics, p_selectedAdmins, p_districts, p_unitTypeListCodes, p_subUnitTypeCode, p_populationSector);
        }


        public string GetMainDeptPhone(int deptCode)
        {
            ClinicDB dal = new ClinicDB();
            return dal.GetMainDeptPhone(deptCode, 1);
        }

        public string GetMainDeptPhoneByDeptEmployeeID(int deptEmployeeID)
        {
            ClinicDB dal = new ClinicDB();
            return dal.GetMainDeptPhoneByDeptEmployeeID(deptEmployeeID);
        }         

        public DataSet GetDeptListByParams(int deptCode, string deptName, int cityCode, int districtCode, int unitTypeCode)
        {
            ClinicDB dal = new ClinicDB();

            return dal.GetDeptListByParams(deptCode, deptName, cityCode, districtCode, unitTypeCode);
        }

        public Dept GetDeptGeneralBelongings(int deptCode)
        {
            ClinicDB dal = new ClinicDB();
            DataSet ds = dal.GetDeptGeneralBelongings(deptCode);

            return SetDeptBelonging(ds);
        }

        public Dept GetDeptGeneralBelongingsByDeptEmployee(int deptEmployeeID)
        {
            ClinicDB dal = new ClinicDB();
            DataSet ds = dal.GetDeptGeneralBelongingsByDeptEmployee(deptEmployeeID);

            return SetDeptBelonging(ds);
        }


        private Dept SetDeptBelonging(DataSet ds)
        {
            Dept dept = null;
            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {                
                DataTable dt = ds.Tables[0];
                int deptCode = Convert.ToInt32(ds.Tables[0].Rows[0]["DeptCode"]);
                dept = new Dept(deptCode);

                dept.IsCommunity = Convert.ToBoolean(dt.Rows[0]["IsCommunity"]);
                dept.IsMushlam = Convert.ToBoolean(dt.Rows[0]["IsMushlam"]);
                dept.IsHospital = Convert.ToBoolean(dt.Rows[0]["IsHospital"]);
            }

            return dept;
        }
    }
}





