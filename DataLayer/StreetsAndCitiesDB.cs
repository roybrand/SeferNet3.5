using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.Data;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class StreetsAndCitiesDB : Base.SqlDal
    {
        

        public StreetsAndCitiesDB(string p_conString)
            : base(p_conString)
        {
        }
        
        public void getStreetsByCityCode(ref DataSet p_ds, int p_cityCode,string p_searchStr)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[2] { p_cityCode, p_searchStr };

            if ( Convert.ToInt32(inputParams[0]) == -1) 
                inputParams[0] = null;

            string spName = "rpc_getStreetsByCityCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void getNeighbourhoodsByCityCode(ref DataSet p_ds, int p_cityCode, string p_searchStr)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[2] { p_cityCode, p_searchStr };

            if ( Convert.ToInt32(inputParams[0]) == -1) 
                inputParams[0] = null;

            string spName = "rpc_getNeighbourhoodsByCityCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void GetNeighbourhoodsAndSitesByCityCode(ref DataSet p_ds, int p_cityCode, string p_searchStr)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[2] { p_cityCode, p_searchStr };

            if ( Convert.ToInt32(inputParams[0]) == -1) 
                inputParams[0] = null;

            string spName = "rpc_getNeighbourhoodsAndSitesByCityCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void getSitesByCityCode(ref DataSet p_ds, int p_cityCode, string p_searchStr)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[2] { p_cityCode, p_searchStr };

            if ( Convert.ToInt32(inputParams[0]) == -1) 
                inputParams[0] = null;

            string spName = "rpc_getSitesByCityCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }
        public void getCitiesDistrictsWithSelectedCodes(ref DataSet p_ds, string selectedCityCodes, string districtCodes)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[2] { selectedCityCodes, districtCodes };

            string spName = "rpc_getCitiesDistrictsWithSelectedCodes";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }

        public void getCitiesByNameAndDistrict(ref DataSet p_ds, string p_searchStr, string p_districtCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_districtCode };

            if (inputParams[0].ToString() == string.Empty)  //search string for CityName
                inputParams[0] = null;


            string spName = "rpc_getCitiesByNameAndDistrict";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, p_districtCode);

        }

        public void GetCitiesAndDistrictsByNameAndDistrict(ref DataSet p_ds, string p_searchStr, int p_districtCode, int p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_searchStr, p_districtCode, p_deptCode };

            if (inputParams[0].ToString() == string.Empty)  //search string for CityName
                inputParams[0] = null;

                string spName = "rpc_getCitiesAndDistrictsByNameAndDistrict";
                DBActionNotification.RaiseOnDBSelect(spName, inputParams);
                p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }

        public void GetCitiesAndDistrictsByNameAndDistricts(ref DataSet p_ds, string p_searchStr, string p_districtCodes)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_searchStr, p_districtCodes };

            if (inputParams[0].ToString() == string.Empty)  //search string for CityName
                inputParams[0] = null;
            if (inputParams[1].ToString() == string.Empty)  //list of district codes
                inputParams[1] = null;


            string spName = "rpc_getCitiesAndDistrictsByNameAndDistricts";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }

    }
}
