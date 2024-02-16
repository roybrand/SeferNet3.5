using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SeferNet.FacadeLayer
{
    public class ReportParametres
    {

       private int m_ReportType;

       private string m_DistrictCodes = String.Empty;
        private string m_Districts = String.Empty;
       private int m_DistrictCode = -1;
       

       private string m_AdminClinicCodes = String.Empty;
       private string m_AdminClinics = String.Empty;
       private int m_AdminClinicCode = -1;

       private string m_CitiesCodes = String.Empty;
       private string m_Cities = String.Empty;
       private int m_CityCode = -1;

       private string m_StatusCodes = String.Empty;
       private string m_Statuses = String.Empty;
       private int m_StatusCode = -1;

       private string m_UnitTypeCodes = String.Empty;
       private string m_UnitTypes = String.Empty;
       private int m_UnitTypeCode = -1;

       private string m_SubUnitTypeCodes = String.Empty;
       private string m_SubUnitTypes = String.Empty;
       private int m_SubUnitTypeCode;
      
       private string m_SectorCodes = String.Empty;
       private string m_Sectors = String.Empty; 
       private int m_SectorCode = -1;  

     
       private string m_ProfessionCodes = String.Empty;
       private string m_Professions = String.Empty;  
       private int m_ProfessionCode = -1;
      
       private string m_ServiceCodes = String.Empty;                                              
       private string m_Services = String.Empty; 
       private int m_ServiceCode = -1;


       public void ResetReportParametres()
        {
           this.ReportType = 0;

           this.DistrictCode  = 0;
           this.DistrictCodes = string.Empty;  
           this.Districts = string.Empty;

           this.AdminClinicCode = 0;
           this.AdminClinicCodes = string.Empty;  
           this.AdminClinics = string.Empty;

           this.CityCode = 0;
           this.CitiesCodes = string.Empty;
           this.Cities = string.Empty;

           this.StatusCode = 0;
           this.StatusCodes = string.Empty;
           this.Statuses = string.Empty;

           this.UnitTypeCode = 0;
           this.UnitTypeCodes = string.Empty;   
           this.UnitTypes = string.Empty;

           this.SubUnitTypeCode = 0;
           this.SubUnitTypeCodes = string.Empty;  
           this.SubUnitTypes = string.Empty;

           this.SectorCode = 0;
           this.SectorCodes = string.Empty;
           this.Sectors = string.Empty;

           this.ProfessionCode = 0;
           this.ProfessionCodes = string.Empty;
           this.Professions = string.Empty;

           this.ServiceCode = 0;
           this.ServiceCodes = string.Empty;
           this.Services = string.Empty;                                                                      
          
        }

        public int ReportType
        {
            get { return m_ReportType; }
            set { m_ReportType = value; }
        }

        #region DistrictCodes
        public int DistrictCode
        {
            get { return m_DistrictCode; }
            set { m_DistrictCode = value; }
        }

        public string Districts
        {
            get { return m_Districts; }
            set { m_Districts = value; }
        }

        public string DistrictCodes
        {
            get { return m_DistrictCodes; }
            set { m_DistrictCodes = value; }
        } 
        #endregion

        #region AdminClinics
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

        public string AdminClinics
        {
            get { return m_AdminClinics; }
            set { m_AdminClinics = value; }
        } 
        #endregion

        #region Cities
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

        public string Cities
        {
            get { return m_Cities; }
            set { m_Cities = value; }
        }
        
        #endregion

        #region Statuses
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

        public string Statuses
        {
            get { return m_Statuses; }
            set { m_Statuses = value; }
        } 
        #endregion

        #region UnitTypes
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

        public string UnitTypes
        {
            get { return m_UnitTypes; }
            set { m_UnitTypes = value; }
        } 
        #endregion

        #region SubUnitTypes
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

        public string SubUnitTypes
        {
            get { return m_SubUnitTypes; }
            set { m_SubUnitTypes = value; }
        } 
        #endregion

        #region Sectors
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

        public string Sectors
        {
            get { return m_Sectors; }
            set { m_Sectors = value; }
        } 
        #endregion

        #region Professions
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

        public string Professions
        {
            get { return m_Professions; }
            set { m_Professions = value; }
        } 
        #endregion

        #region Services
        public int ServiceCode
        {
            get { return m_ServiceCode; }
            set { m_ServiceCode = value; }
        }

        public string ServiceCodes
        {
            get { return m_ServiceCodes; }
            set { m_ServiceCodes = value; }
        }


        public string Services
        {
            get { return m_Services; }
            set { m_Services = value; }
        } 
        #endregion
    }
}
