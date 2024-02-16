using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class ReportParametres
    {

        string m_DistrictCodes;
        int m_DistrictCode;
        string m_AdminClinicCodes;
        int m_AdminClinicCode;
        string m_CitiesCodes;
        int m_CityCode;
        string m_StatusCodes;
        int m_StatusCode;
        string m_UnitTypeCodes;
        int m_UnitTypeCode;
        string m_SubUnitTypeCodes;
        int m_SubUnitTypeCode;
        int m_SectorCode;
        string m_SectorCodes;
        int m_ProfessionCode;
        string m_ProfessionCodes;


        public int DistrictCode
        {
            get { return m_DistrictCode; }
            set { m_DistrictCode = value; }
        }

        public string DistrictCodes
        {
            get { return m_DistrictCodes; }
            set { m_DistrictCodes = value; }
        }

        public int AdminClinicCode
        {
            get { return m_AdminClinicCode; }
            set { m_AdminClinicCode = value; }
        }

        public string AdminClinicCodes
        {
            get { return m_AdminClinicCodes; }
            set { m_AdminClinicCodes = value; }
        }

        public int CityCode
        {
            get { return m_CityCode; }
            set { m_CityCode = value; }
        }

        public string CitiesCodes
        {
            get { return m_CitiesCodes; }
            set { m_CitiesCodes = value; }
        }

        public int StatusCode
        {
            get { return m_StatusCode; }
            set { m_StatusCode = value; }
        }

        public string StatusCodes
        {
            get { return m_StatusCodes; }
            set { m_StatusCodes = value; }
        }
        public int UnitTypeCode
        {
            get { return m_UnitTypeCode; }
            set { m_UnitTypeCode = value; }
        }

        public string UnitTypeCodes
        {
            get { return m_UnitTypeCodes; }
            set { m_UnitTypeCodes = value; }
        }

        public int SubUnitTypeCode
        {
            get { return m_SubUnitTypeCode; }
            set { m_SubUnitTypeCode = value; }
        }

        public string SubUnitTypeCodes
        {
            get { return m_SubUnitTypeCodes; }
            set { m_SubUnitTypeCodes = value; }
        }

        public int SectorCode
        {
            get { return m_SectorCode; }
            set { m_SectorCode = value; }
        }

        public string SectorCodes
        {
            get { return m_SectorCodes; }
            set { m_SectorCodes = value; }
        }

        public int ProfessionCode
        {
            get { return m_ProfessionCode; }
            set { m_ProfessionCode = value; }
        }

        public string ProfessionCodes
        {
            get { return m_ProfessionCodes; }
            set { m_ProfessionCodes = value; }
        }


    }
}
