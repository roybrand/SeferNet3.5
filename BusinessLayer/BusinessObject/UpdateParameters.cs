using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    [Serializable]
    public class ClinicDetailsParameters
    {
        int m_deptCode;
        string m_deptName;
        string m_deptNameFreePart;
        int m_deptType;
        int m_typeUnitCode;
        int m_subUnitTypeCode;
        int m_deptLevel;
        string m_managerName;
        string m_substituteManagerName;
        string m_administrativeManagerName;
        string m_substituteAdministrativeManagerName;

        int m_cityCode;
        string m_cityName;
        string m_street;
        string m_streetName;
        string m_house;
        string m_flat;
        string m_floor;
        string m_addressComment;

        bool m_cascadeUpdateSubDeptPhones;
        bool m_cascadeUpdateEmployeeInClinicPhones;
        string m_email;
        bool m_showEmailInInternet;
        bool m_isCommunity;
        bool m_isMushlam;
        bool m_isHospital;

        string m_transportation;
        int m_parking;

        int m_districtCode;
        int m_administrationCode;
        int m_subAdministrationCode;
        string m_subAdministrationName;
        int m_parentClinicCode;
        string m_parentClinicName;
        int m_populationSectorCode;
        int m_simul228;
        int m_status;
        string m_statusDescription;
        string m_deptNameSimul;
        string m_statusSimul;
        string m_openDateSimul;
        string m_closingDateSimul;
        string m_simulManageDescription;
        int m_sugSimul501;
        int m_tatSugSimul502;
        int m_tatHitmahut503;
        int m_ramatPeilut504;
        string m_sugSimulDesc;
        string m_tatSugSimulDesc;
        string m_tatHitmahutDesc;
        string m_ramatPeilutDesc;
        string m_unitTypeNameSimul;
        int m_unitTypeCodeSimul;

        bool m_showUnitInInternet;
        bool m_allowQueueOrder;
        double m_xcoord;
        double m_ycoord;
        double m_XLongitude;
        double m_YLatitude;
        bool m_updateCoordinatesManually;

        string m_NeighbourhoodOrInstituteCode;
        string m_NeighbourhoodOrInstituteName;
        int? m_IsSite;

        string m_additionaDistrictCodes;
        string m_additionaDistrictNames;

        string m_LinkToBlank17;
        string m_LinkToContactUs;

        string m_Building;

        int? m_TypeOfDefenceCode;
        int? m_DefencePolicyCode;
        bool? m_IsUnifiedClinic;
        bool? m_HasElectricalPanel;
        bool? m_HasGenerator;

        Int64? m_DeptShalaCode;
        int m_ReligionCode;

        int m_AllowContactHospitalUnit;

        public int DeptCode
        {
            get { return m_deptCode; }
            set { m_deptCode = value; }
        }

        public string DeptName
        {
            get { return m_deptName; }
            set { m_deptName = value; }
        }

        public string DeptNameFreePart
        {
            get { return m_deptNameFreePart; }
            set { m_deptNameFreePart = value; }
        }

        public int DeptType
        {
            get { return m_deptType; }
            set { m_deptType = value; }
        }

        public int TypeUnitCode
        {
            get { return m_typeUnitCode; }
            set { m_typeUnitCode = value; }
        }

        public int SubUnitTypeCode
        {
            get { return m_subUnitTypeCode; }
            set { m_subUnitTypeCode = value; }
        }

        public int DeptLevel
        {
            get { return m_deptLevel; }
            set { m_deptLevel = value; }
        }

        public string ManagerName
        {
            get { return m_managerName; }
            set { m_managerName = value; }
        }

        public string SubstituteManagerName
        {
            get { return m_substituteManagerName; }
            set { m_substituteManagerName = value; }
        }

        public string AdministrativeManagerName
        {
            get { return m_administrativeManagerName; }
            set { m_administrativeManagerName = value; }
        }

        public string SubstituteAdministrativeManagerName
        {
            get { return m_substituteAdministrativeManagerName; }
            set { m_substituteAdministrativeManagerName = value; }
        }

        public int CityCode
        {
            get { return m_cityCode; }
            set { m_cityCode = value; }
        }
        public string CityName
        {
            get { return m_cityName; }
            set { m_cityName = value; }
        }

        public string Street
        {
            get { return m_street; }
            set { m_street = value; }
        }

        public string StreetName
        {
            get { return m_streetName; }
            set { m_streetName = value; }
        }

        public string House
        {
            get { return m_house; }
            set { m_house = value; }
        }

        public string Flat
        {
            get { return m_flat; }
            set { m_flat = value; }
        }

        public string Floor
        {
            get { return m_floor; }
            set { m_floor = value; }
        }

        public string AddressComment
        {
            get { return m_addressComment; }
            set { m_addressComment = value; }
        }

        public bool CascadeUpdateSubDeptPhones
        {
            get { return m_cascadeUpdateSubDeptPhones; }
            set { m_cascadeUpdateSubDeptPhones = value; }
        }

        public bool CascadeUpdateEmployeeInClinicPhones
        {
            get { return m_cascadeUpdateEmployeeInClinicPhones; }
            set { m_cascadeUpdateEmployeeInClinicPhones = value; }
        }

        public string Email
        {
            get { return m_email; }
            set { m_email = value; }
        }

        public bool ShowEmailInInternet
        {
            get { return m_showEmailInInternet; }
            set { m_showEmailInInternet = value; }
        }

        public bool IsCommunity
        {
            get { return m_isCommunity; }
            set { m_isCommunity = value; }
        }

        public bool IsMushlam
        {
            get { return m_isMushlam; }
            set { m_isMushlam = value; }
        }

        public bool IsHospital
        {
            get { return m_isHospital; }
            set { m_isHospital = value; }
        }  
      
        public string Transportation
        {
            get { return m_transportation; }
            set { m_transportation = value; }
        }

        public int Parking
        {
            get { return m_parking; }
            set { m_parking = value; }
        }

        public int DistrictCode
        {
            get { return m_districtCode; }
            set { m_districtCode = value; }
        }

        public int AdministrationCode
        {
            get { return m_administrationCode; }
            set { m_administrationCode = value; }
        }

        public int SubAdministrationCode
        {
            get { return m_subAdministrationCode; }
            set { m_subAdministrationCode = value; }
        }

        public string SubAdministrationName
        {
            get { return m_subAdministrationName; }
            set { m_subAdministrationName = value; }
        }

        public int ParentClinicCode
        {
            get { return m_parentClinicCode; }
            set { m_parentClinicCode = value; }
        }

        public string ParentClinicName
        {
            get { return m_parentClinicName; }
            set { m_parentClinicName = value; }
        }

        public int PopulationSectorCode
        {
            get { return m_populationSectorCode; }
            set { m_populationSectorCode = value; }
        }

        public int Simul228
        {
            get { return m_simul228; }
            set { m_simul228 = value; }
        }

        public int Status
        {
            get { return m_status; }
            set { m_status = value; }
        }

        public string StatusDescription
        {
            get { return m_statusDescription; }
            set { m_statusDescription = value; }
        }

        public string DeptNameSimul
        {
            get { return m_deptNameSimul; }
            set { m_deptNameSimul = value; }
        }

        public string StatusSimul
        {
            get { return m_statusSimul; }
            set { m_statusSimul = value; }
        }

        public string OpenDateSimul
        {
            get { return m_openDateSimul; }
            set { m_openDateSimul = value; }
        }

        public string ClosingDateSimul
        {
            get { return m_closingDateSimul; }
            set { m_closingDateSimul = value; }
        }

        public string SimulManageDescription
        {
            get { return m_simulManageDescription; }
            set { m_simulManageDescription = value; }
        }

        public int SugSimul501
        {
            get { return m_sugSimul501; }
            set { m_sugSimul501 = value; }
        }

        public int TatSugSimul502
        {
            get { return m_tatSugSimul502; }
            set { m_tatSugSimul502 = value; }
        }

        public int TatHitmahut503
        {
            get { return m_tatHitmahut503; }
            set { m_tatHitmahut503 = value; }
        }

        public int RamatPeilut504
        {
            get { return m_ramatPeilut504; }
            set { m_ramatPeilut504 = value; }
        }

        public int UnitTypeCodeSimul
        {
            get { return m_unitTypeCodeSimul; }
            set { m_unitTypeCodeSimul = value; }
        }

        public string SugSimulDesc
        {
            get { return m_sugSimulDesc; }
            set { m_sugSimulDesc = value; }
        }

        public string TatSugSimulDesc
        {
            get { return m_tatSugSimulDesc; }
            set { m_tatSugSimulDesc = value; }
        }

        public string TatHitmahutDesc
        {
            get { return m_tatHitmahutDesc; }
            set { m_tatHitmahutDesc = value; }
        }

        public string RamatPeilutDesc
        {
            get { return m_ramatPeilutDesc; }
            set { m_ramatPeilutDesc = value; }
        }

        public string UnitTypeNameSimul
        {
            get { return m_unitTypeNameSimul; }
            set { m_unitTypeNameSimul = value; }
        }

        public bool ShowUnitInInternet
        {
            get { return m_showUnitInInternet; }
            set { m_showUnitInInternet = value; }
        }

        public bool AllowQueueOrder
        {
            get { return m_allowQueueOrder; }
            set { m_allowQueueOrder = value; }
        }

        public double Xcoord
        {
            get { return m_xcoord; }
            set { m_xcoord = value; }
        }

        public double Ycoord
        {
            get { return m_ycoord; }
            set { m_ycoord = value; }
        }

        public double XLongitude
        {
            get { return m_XLongitude; }
            set { m_XLongitude = value; }
        }

        public double YLatitude
        {
            get { return m_YLatitude; }
            set { m_YLatitude = value; }
        }

        public bool UpdateCoordinatesManually
        {
            get { return m_updateCoordinatesManually; }
            set { m_updateCoordinatesManually = value; }
        }

        public string NeighbourhoodOrInstituteCode
        {
            get { return m_NeighbourhoodOrInstituteCode; }
            set { m_NeighbourhoodOrInstituteCode = value; }
        }

        public string NeighbourhoodOrInstituteName
        {
            get { return m_NeighbourhoodOrInstituteName; }
            set { m_NeighbourhoodOrInstituteName = value; }
        }

        public int? IsSite
        {
            get { return m_IsSite; }
            set { m_IsSite = value; }
        }

        public string AdditionaDistrictCodes
        {
            get { return m_additionaDistrictCodes; }
            set { m_additionaDistrictCodes = value; }
        }

        public string AdditionaDistrictNames
        {
            get { return m_additionaDistrictNames; }
            set { m_additionaDistrictNames = value; }
        }

        public string LinkToBlank17
        {
            get { return m_LinkToBlank17; }
            set { m_LinkToBlank17 = value; }
        }

        public string LinkToContactUs
        {
            get { return m_LinkToContactUs; }
            set { m_LinkToContactUs = value; }
        }

        public string Building
        {
            get { return m_Building; }
            set { m_Building = value; }
        }
        public int? TypeOfDefenceCode
        {
            get { return m_TypeOfDefenceCode; }
            set { m_TypeOfDefenceCode = value; }
        }

        public int? DefencePolicyCode
        {
            get { return m_DefencePolicyCode; }
            set { m_DefencePolicyCode = value; }
        }

        public bool? IsUnifiedClinic
        {
            get { return m_IsUnifiedClinic; }
            set { m_IsUnifiedClinic = value; }
        }

        public bool? HasElectricalPanel
        {
            get { return m_HasElectricalPanel; }
            set { m_HasElectricalPanel = value; }
        }
        public bool? HasGenerator
        {
            get { return m_HasGenerator; }
            set { m_HasGenerator = value; }
        }
        public Int64? DeptShalaCode
        {
            get { return m_DeptShalaCode; }
            set { m_DeptShalaCode = value; }
        }

        public int ReligionCode
        {
            get { return m_ReligionCode; }
            set { m_ReligionCode = value; }
        }

        public int AllowContactHospitalUnit
        {
            get { return m_AllowContactHospitalUnit; }
            set { m_AllowContactHospitalUnit = value; }
        }

   } 

    public class ClinicEventParameters
    {
        int m_deptEventID;
        int m_deptCode;
        int m_eventCode;
        string m_eventName;
        string m_eventDescription;
        int m_meetingsNumber;
        bool m_repeatingEvent;
        DateTime m_fromDate;
        DateTime m_toDate;
        int m_registrationStatus;
        int m_payOrder;
        string m_commonPrice;
        string m_memberPrice;
        string m_fullMemberPrice;
        string m_targetPopulation;
        string m_remark;
        bool m_displayInInternet;
        private bool _showPhonesFromDept;



        public bool ShowPhonesFromDept
        {
            get
            {
                return _showPhonesFromDept;
            }
            set
            {
                _showPhonesFromDept = value;
            }
        }
        public int DeptEventID
        {
            get { return m_deptEventID; }
            set { m_deptEventID = value; }
        }
        public int DeptCode
        {
            get { return m_deptCode; }
            set { m_deptCode = value; }
        }
        public int EventCode
        {
            get { return m_eventCode; }
            set { m_eventCode = value; }
        }
        public string EventName
        {
            get { return m_eventName; }
            set { m_eventName = value; }
        }
        public string EventDescription
        {
            get { return m_eventDescription; }
            set { m_eventDescription = value; }
        }
        public int MeetingsNumber
        {
            get { return m_meetingsNumber; }
            set { m_meetingsNumber = value; }
        }
        public bool RepeatingEvent
        {
            get { return m_repeatingEvent; }
            set { m_repeatingEvent = value; }
        }
        public DateTime FromDate
        {
            get { return m_fromDate; }
            set { m_fromDate = value; }
        }
        public DateTime ToDate
        {
            get { return m_toDate; }
            set { m_toDate = value; }
        }
        public int RegistrationStatus
        {
            get { return m_registrationStatus; }
            set { m_registrationStatus = value; }
        }
        public int PayOrder
        {
            get { return m_payOrder; }
            set { m_payOrder = value; }
        }
        public string CommonPrice
        {
            get { return m_commonPrice; }
            set { m_commonPrice = value; }
        }
        public string MemberPrice
        {
            get { return m_memberPrice; }
            set { m_memberPrice = value; }
        }
        public string FullMemberPrice
        {
            get { return m_fullMemberPrice; }
            set { m_fullMemberPrice = value; }
        }
        public string TargetPopulation
        {
            get { return m_targetPopulation; }
            set { m_targetPopulation = value; }
        }
        public string Remark
        {
            get { return m_remark; }
            set { m_remark = value; }
        }
        public bool DisplayInInternet
        {
            get { return m_displayInInternet; }
            set { m_displayInInternet = value; }
        }
        
    }

}
