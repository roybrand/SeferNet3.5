using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Configuration;

using SeferNet.DataLayer;

namespace SeferNet.BusinessLayer.WorkFlow
{

    public class StreetAndCityManager
    {
        string m_ConnStr;

        public StreetAndCityManager()
        {
            m_ConnStr = ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"].ConnectionString;
        }


        public DataSet getCitiesByNameAndDistrict(string strSearch, string  districtCode)
        {
            DataSet dsCities = new DataSet();
            StreetsAndCitiesDB citiesdb = new StreetsAndCitiesDB(m_ConnStr);

            citiesdb.getCitiesByNameAndDistrict(ref dsCities, strSearch, districtCode);
            dsCities.Tables[0].TableName = "Cities";            

            return dsCities;
        }

        public DataSet GetCitiesAndDistrictsByNameAndDistrict(string strSearch, int districtCode, int deptCode)
        {
            DataSet dsCities = new DataSet();
            StreetsAndCitiesDB citiesdb = new StreetsAndCitiesDB(m_ConnStr);

            citiesdb.GetCitiesAndDistrictsByNameAndDistrict(ref dsCities, strSearch, districtCode, deptCode);
            dsCities.Tables[0].TableName = "Cities";            

            return dsCities;
        }

        public DataSet GetCitiesAndDistrictsByNameAndDistricts(string strSearch, string districtCodes)
        {
            DataSet dsCities = new DataSet();
            StreetsAndCitiesDB citiesdb = new StreetsAndCitiesDB(m_ConnStr);

            citiesdb.GetCitiesAndDistrictsByNameAndDistricts(ref dsCities, strSearch, districtCodes);
            dsCities.Tables[0].TableName = "Cities";            

            return dsCities;
        }

        public DataSet getStreetsByCityCode(int CityCode, string strSearch )
        {
            DataSet dsStreets = new DataSet();
            StreetsAndCitiesDB streetsdb = new StreetsAndCitiesDB(m_ConnStr);

            streetsdb.getStreetsByCityCode(ref dsStreets, CityCode, strSearch);
            dsStreets.Tables[0].TableName = "Streets";

            return dsStreets;
        }

        public DataSet getNeighbourhoodsByCityCode(int CityCode, string strSearch)
        {
            DataSet dsNeighbourhoods = new DataSet();
            StreetsAndCitiesDB streetsdb = new StreetsAndCitiesDB(m_ConnStr);

            streetsdb.getNeighbourhoodsByCityCode(ref dsNeighbourhoods, CityCode, strSearch);

            return dsNeighbourhoods;
        }

        public DataSet GetNeighbourhoodsAndSitesByCityCode(int CityCode, string strSearch)
        {
            DataSet dsNeighbourhoods = new DataSet();
            StreetsAndCitiesDB streetsdb = new StreetsAndCitiesDB(m_ConnStr);

            streetsdb.GetNeighbourhoodsAndSitesByCityCode(ref dsNeighbourhoods, CityCode, strSearch);

            return dsNeighbourhoods;
        }

        public DataSet getSitesByCityCode(int CityCode, string strSearch)
        {
            DataSet dsSites = new DataSet();
            StreetsAndCitiesDB streetsdb = new StreetsAndCitiesDB(m_ConnStr);

            streetsdb.getSitesByCityCode(ref dsSites, CityCode, strSearch);

            return dsSites;
        }
        public DataSet getCitiesDistrictsWithSelectedCodes(string selectedCityCodes, string districtCodes)
        {
            DataSet dsCities = new DataSet();
            StreetsAndCitiesDB streetsdb = new StreetsAndCitiesDB(m_ConnStr);

            streetsdb.getCitiesDistrictsWithSelectedCodes(ref dsCities, selectedCityCodes, districtCodes);

            return dsCities;
        }

    }
}
