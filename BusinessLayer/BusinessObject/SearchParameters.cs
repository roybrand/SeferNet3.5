using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SeferNet.Globals;
using System.Web.UI.WebControls;


namespace SeferNet.BusinessLayer.BusinessObject
{
    public class SearchPageStatusParameters
    {
        public enum eSearchPageName
        {           
            SearchClinics,
            SearchDoctors,
            SearchEvents,
            SearchSalServices 
        }

        static Dictionary<eSearchPageName, string> _SearchPagesNamesDictionary = new Dictionary<eSearchPageName, string>();

        static SearchPageStatusParameters()
        {
            _SearchPagesNamesDictionary.Add(eSearchPageName.SearchClinics, "SearchClinics.aspx");
            _SearchPagesNamesDictionary.Add(eSearchPageName.SearchEvents, "SearchEvents.aspx");
            _SearchPagesNamesDictionary.Add(eSearchPageName.SearchDoctors, "SearchDoctors.aspx");
            _SearchPagesNamesDictionary.Add(eSearchPageName.SearchSalServices, "SearchSalServices.aspx");
        }

        public SearchPageStatusParameters()
        {
            SelectSearchPage = GetDefaultPage();
        }

        bool m_showSearchResult;
        bool m_showDoctorSearch;
        bool m_showClinicSearch;
        bool m_showEventSearch;

        public bool ShowSearchResult
        {
            get { return m_showSearchResult; }
            set { m_showSearchResult = value; }
        }

        public bool ShowDoctorSearch
        {
            get { return m_showDoctorSearch; }
            set { m_showDoctorSearch = value; }
        }

        public bool ShowClinicSearch
        {
            get { return m_showClinicSearch; }
            set { m_showClinicSearch = value; }
        }

        public bool ShowEventSearch
        {
            get { return m_showEventSearch; }
            set { m_showEventSearch = value; }
        }

        public eSearchPageName SelectSearchPage { get; set; }

        public  void SetSelectedSearchPage(string virtualPath)
        {
            string[] pathParts = virtualPath.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
            string[] fileParts = pathParts[pathParts.Length - 1].Split(new string[]{"."},StringSplitOptions.RemoveEmptyEntries);            
            SelectSearchPage = (eSearchPageName)Enum.Parse(typeof(eSearchPageName), fileParts[0],true);
            
            
        }

        public string SelectSearchPageName
        {
            get
            {
                string pageToReturn = string.Empty;
                if (_SearchPagesNamesDictionary.ContainsKey(SelectSearchPage) == true)
                {
                    pageToReturn = _SearchPagesNamesDictionary[SelectSearchPage];
                }
                return pageToReturn;
            }
        }

        public static string GetDefaultPageName()
        {
            return _SearchPagesNamesDictionary[GetDefaultPage()];
        }

        private static eSearchPageName GetDefaultPage()
        {
            return eSearchPageName.SearchClinics;
        }
    }

    public class SortingAndPagingParameters
    {
        string m_orderBy = string.Empty;
        int m_sortingOrder;
        int m_totalPages;
        int m_currentPage;

        public string OrderBy
        {
            get { return m_orderBy; }
            set { m_orderBy = value; }
        }

        public int SortingOrder
        {
            get { return m_sortingOrder; }
            set { m_sortingOrder = value; }
        }

        public int TotalPages
        {
            get { return m_totalPages; }
            set { m_totalPages = value; }
        }

        public int CurrentPage
        {
            get { return m_currentPage; }
            set { m_currentPage = value; }
        }

        public SortingAndPagingParameters()
        {
            m_orderBy = string.Empty;
        }
    }

    public class DoctorSearchParameters : SearchParametersBase
    {
        string m_firstName;
        string m_lastName;
        long? m_employeeID;
        int? m_licenseNumber;
        string m_professionCode;
        string m_professionText;
        string m_serviceCode;
        string m_serviceText;        
        int? m_expertProfession;
        int? m_positionCode;
        string m_positionDescription;
        int? m_employeeSectorCode;
        string m_employeeSectorDescription;
        string m_languageCode;
        string m_languageText;
        int? m_sex;
        int? m_status;
        int? m_agreementType;
        string m_handicappedFacilitiesCodes;
        string m_handicappedFacilitiesDescriptions;
        string m_queueOrderMethodsAndOptions;
        string m_queueOrderMethodsAndOptionsCodes;

        public bool IsGetEmployeesReceptionInfo { get; set; }
        public bool ReceiveGuests { get; set; }

        public string FirstName
        {
            get { return m_firstName; }
            set { m_firstName = value; }
        }

        public string LastName
        {
            get { return m_lastName; }
            set { m_lastName = value; }
        }

        public long? EmployeeID
        {
            get { return m_employeeID; }
            set { m_employeeID = value; }
        }

        public int? LicenseNumber
        {
            get { return m_licenseNumber; }
            set { m_licenseNumber = value; }
        }

        public string ProfessionCode
        {
            get { return m_professionCode; }
            set { m_professionCode = value; }
        }

        public string ProfessionText
        {
            get { return m_professionText; }
            set { m_professionText = value; }
        }

        public string ServiceCode
        {
            get { return m_serviceCode; }
            set { m_serviceCode = value; }
        }

        public string ServiceText
        {
            get { return m_serviceText; }
            set { m_serviceText = value; }
        }

        public int? ExpertProfession
        {
            get { return m_expertProfession; }
            set { m_expertProfession = value; }
        }

        public int? PositionCode
        {
            get { return m_positionCode; }
            set { m_positionCode = value; }
        }

        public string PositionDescription
        {
            get { return m_positionDescription; }
            set { m_positionDescription = value; }
        }

        public int? EmployeeSectorCode
        {
            get { return m_employeeSectorCode; }
            set { m_employeeSectorCode = value; }
        }

        public string EmployeeSectorDescription
        {
            get { return m_employeeSectorDescription; }
            set { m_employeeSectorDescription = value; }
        }

        public string LanguageCode
        {
            get { return m_languageCode; }
            set { m_languageCode = value; }
        }

        public string LanguageText
        {
            get { return m_languageText; }
            set { m_languageText = value; }
        }

        public int? Sex
        {
            get { return m_sex; }
            set { m_sex = value; }
        }

        public int? Status
        {
            get { return m_status; }
            set { m_status = value; }
        }

        public int? AgreementType
        {
            get { return m_agreementType; }
            set { m_agreementType = value; }
        }

        public string HandicappedFacilitiesCodes
        {
            get { return m_handicappedFacilitiesCodes; }
            set { m_handicappedFacilitiesCodes = value; }
        }

        public string HandicappedFacilitiesDescriptions
        {
            get { return m_handicappedFacilitiesDescriptions; }
            set { m_handicappedFacilitiesDescriptions = value; }
        }

        public string QueueOrderMethodsAndOptions
        {
            get { return m_queueOrderMethodsAndOptions; }
            set { m_queueOrderMethodsAndOptions = value; }
        }

        public string QueueOrderMethodsAndOptionsCodes
        {
            get { return m_queueOrderMethodsAndOptionsCodes; }
            set { m_queueOrderMethodsAndOptionsCodes = value; }
        }

        public DoctorSearchParameters()
        {    
         
        }

        public override void PrepareParametersForDBQuery()
        {
            base.PrepareParametersForDBQuery();

            StringHelper.CleanStringAndSetToNullIfRequired(ref m_firstName);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_lastName);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_professionCode);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_serviceCode);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_languageCode);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_handicappedFacilitiesCodes);

            //sets to value or null
            //the defualt is ususally -1 meaning 'All' so in this case we send no value ( 'null' ) to the query so it won't filter by it
            if (m_employeeID <= 0)
            {
                m_employeeID = null;
            }

            if (m_licenseNumber <= 0)
            {
                m_licenseNumber = null;
            }

            if (m_expertProfession < 0)
            {
                m_expertProfession = null;
            }

            if (m_positionCode <= 0)
            {
                m_positionCode = null;
            }

            if (m_employeeSectorCode <= 0)
            {
                m_employeeSectorCode = null;
            }

            if (m_sex <= 0)
            {
                m_sex = null;
            }

            //if (m_status < 0)
            //{
            //    m_status = null;
            //}

            if (m_agreementType < 0)
            {
                m_agreementType = null;
            }
 

            //text only we don't touch 
            //m_serviceText = null;
            //m_professionText = null;
            //m_languageText = null;          
            //m_handicappedFacilitiesDescriptions = null;            
        }
    }

    public class ClinicSearchParameters : SearchParametersBase
    {
        string m_deptName;
        string m_serviceCodes;
        string m_serviceDescriptions;
        string m_unitTypeCodes;
        string m_unitTypeNames;
        string m_subUnitTypeCodes;
        string m_handicappedFacilitiesCodes; 
        string m_handicappedFacilitiesDescriptions;
        int? m_populationSectorCode;
        string m_codeSimul;
        int? m_status;
        string m_clalitServiceCode;
        string m_clalitServiceDescription;
        string m_medicalAspectCode;
        string m_medicalAspectDescription;
        string m_ServiceCodeForMuslam;
        int? m_GroupCode;
        int? m_SubGroupCode;
        bool _isFromCached = false;
        bool m_userIsLogged = false;
        string m_queueOrderMethodsAndOptions;
        string m_queueOrderMethodsAndOptionsCodes;

        public bool IsFromCached {
            get { return _isFromCached; }
            set { _isFromCached = value; }
        }

        public bool UserIsLogged
        {
            get { return m_userIsLogged; }
            set { m_userIsLogged = value; }
        }

        public int? DeptCode { get; set; }
        public bool ReceiveGuests { get; set; }
     
        public string DeptName
        {
            get { return m_deptName; }
            set { m_deptName = value; }
        }

        public string ServiceCodes
        {
            get { return m_serviceCodes; }
            set { m_serviceCodes = value; }
        }

        public string ServiceDescriptions
        {
            get { return m_serviceDescriptions; }
            set { m_serviceDescriptions = value; }
        }

        public string UnitTypeCodes
        {
            get { return m_unitTypeCodes; }
            set { m_unitTypeCodes = value; }
        }

        public string UnitTypeNames
        {
            get { return m_unitTypeNames; }
            set { m_unitTypeNames = value; }
        }

        public string SubUnitTypeCodes
        {
            get { return m_subUnitTypeCodes; }
            set { m_subUnitTypeCodes = value; }
        }

        public string HandicappedFacilitiesCodes
        {
            get { return m_handicappedFacilitiesCodes; }
            set { m_handicappedFacilitiesCodes = value; }
        }

        public string HandicappedFacilitiesDescriptions
        {
            get { return m_handicappedFacilitiesDescriptions; }
            set { m_handicappedFacilitiesDescriptions = value; }
        }

        public int? PopulationSectorCode
        {
            get { return m_populationSectorCode; }
            set { m_populationSectorCode = value; }
        }

        public string CodeSimul
        {
            get { return m_codeSimul; }
            set { m_codeSimul = value; }
        }

        public int? Status
        {
            get { return m_status; }
            set { m_status = value; }
        }

        public string ClalitServiceCode
        {
            get { return m_clalitServiceCode; }
            set { m_clalitServiceCode = value; }
        }

        public string ClalitServiceDescription
        {
            get { return m_clalitServiceDescription; }
            set { m_clalitServiceDescription = value; }
        }

        public string MedicalAspectCode
        {
            get { return m_medicalAspectCode; }
            set { m_medicalAspectCode = value; }
        }

        public string MedicalAspectDescription
        {
            get { return m_medicalAspectDescription; }
            set { m_medicalAspectDescription = value; }
        }

        public bool IsExtendedSearch { get; set; }

        public string ExtendedServiceToSearch { get; set; }

        public string ServiceCodeForMuslam
        {
            get { return m_ServiceCodeForMuslam; }
            set { m_ServiceCodeForMuslam = value; }
        }

        public int? GroupCode
        {
            get { return m_GroupCode; }
            set { m_GroupCode = value; }
        }

        public int? SubGroupCode
        {
            get { return m_SubGroupCode; }
            set { m_SubGroupCode = value; }
        }

        public string QueueOrderMethodsAndOptions
        {
            get { return m_queueOrderMethodsAndOptions; }
            set { m_queueOrderMethodsAndOptions = value; }
        }

        public string QueueOrderMethodsAndOptionsCodes
        {
            get { return m_queueOrderMethodsAndOptionsCodes; }
            set { m_queueOrderMethodsAndOptionsCodes = value; }
        }

        public override void PrepareParametersForDBQuery()
        {            
            base.PrepareParametersForDBQuery();            
           
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_deptName);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_serviceCodes);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_unitTypeCodes);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_subUnitTypeCodes);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_codeSimul);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_handicappedFacilitiesCodes);

            //sets to value or null
            if (DeptCode <= 0)
            {
                DeptCode = null;
            }

            if (m_populationSectorCode <= 0)
            {
                m_populationSectorCode = null;
            }          

            //if (m_status < 0)
            //{
            //    m_status = null;
            //}

            //don't touch those they are just  for the ui
            //m_professionDescriptions;
           // m_unitTypeNames;
            //m_handicappedFacilitiesDescriptions
        }
   
    }

    public class ClinicSearchParametersForMushlamServices
    {
        string m_ServiceCodeForMuslam;
        int? m_GroupCode;
        int? m_SubGroupCode;
        string m_ServiceDescriptionForMuslam;

        public string ServiceCodeForMuslam
        {
            get { return m_ServiceCodeForMuslam; }
            set { m_ServiceCodeForMuslam = value; }
        }

        public int? GroupCode
        {
            get { return m_GroupCode; }
            set { m_GroupCode = value; }
        }

        public int? SubGroupCode
        {
            get { return m_SubGroupCode; }
            set { m_SubGroupCode = value; }
        }

        public string ServiceDescriptionForMuslam
        {
            get { return m_ServiceDescriptionForMuslam; }
            set { m_ServiceDescriptionForMuslam = value; }
        }
    }

    public class ServiceAndEventSearchParameters : SearchParametersBase
    {
        string m_Events;
		string m_EventCodes;
		string m_serviceCodes;
		string m_serviceName;

        string m_deptName;
        string m_unitTypeCodes;
        string m_unitTypeNames;
        string m_subUnitTypeCodes;

        int? m_agreementType;

        string m_handicappedFacilitiesCodes;
        string m_handicappedFacilitiesDescriptions;
        Enums.Status m_status;

        public string Events
        {
            get { return m_Events; }
            set { m_Events = value; }
        }        
         
        public string EventCodes
        {
            get { return m_EventCodes; }
            set { m_EventCodes = value; }
        }

		public string ServiceCodes
		{
			get { return m_serviceCodes; }
			set { m_serviceCodes = value; }
		}

		public string ServiceName
		{
			get { return m_serviceName; }
			set { m_serviceName = value; }
		}

        public int? DeptCode { get; set; }

        public string DeptName
        {
            get { return m_deptName; }
            set { m_deptName = value; }
        }

        public string UnitTypeCodes
        {
            get { return m_unitTypeCodes; }
            set { m_unitTypeCodes = value; }
        }

        public string UnitTypeNames
        {
            get { return m_unitTypeNames; }
            set { m_unitTypeNames = value; }
        }

        public string SubUnitTypeCodes
        {
            get { return m_subUnitTypeCodes; }
            set { m_subUnitTypeCodes = value; }
        }

        public string HandicappedFacilitiesCodes
        {
            get { return m_handicappedFacilitiesCodes; }
            set { m_handicappedFacilitiesCodes = value; }
        }

        public string HandicappedFacilitiesDescriptions
        {
            get { return m_handicappedFacilitiesDescriptions; }
            set { m_handicappedFacilitiesDescriptions = value; }
        }

        public int? AgreementType
        {
            get { return m_agreementType; }
            set { m_agreementType = value; }
        }


        public override void PrepareParametersForDBQuery()
        {
            base.PrepareParametersForDBQuery();

            StringHelper.CleanStringAndSetToNullIfRequired(ref m_deptName);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_Events);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_unitTypeCodes);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_subUnitTypeCodes);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_handicappedFacilitiesCodes);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_EventCodes);

            //sets to value or null
            if (DeptCode <= 0)
            {
                DeptCode = null;
            }

            if (m_agreementType < 0)
            {
                m_agreementType = null;
            }

            //don't touch those they are just  for the ui
            //m_professionDescriptions;
            // m_unitTypeNames;
            //m_handicappedFacilitiesDescriptions
        }

        public Enums.Status Status  
        {
            get
            {
                return m_status;
            }
            set
            {
                m_status = value;
            }
        }
    }

    public class SweepingRemarksParameters
    { 
        string m_districtCodes = string.Empty;
        string m_districtNames = string.Empty;
        string m_administrationCodes = string.Empty;
        string m_administrationNames = string.Empty;
        string m_unitTypeCodes = string.Empty;
        string m_unitTypeNames = string.Empty;
        string m_populationSectorCodes = string.Empty;
        string m_populationSectorNames = string.Empty;
        int m_subUnitTypeCode = -1;
        int m_remarkID = 0;
        int m_relatedRemarkID = 0;
        int m_dicRemarkID = 0;
        string m_servicesParameter = string.Empty;
        string m_servicesNameParameter = string.Empty;
        string m_cityCodes = string.Empty;
        string m_cityName = string.Empty;
        string m_freeText = string.Empty;

        public string DistrictCodes
        {
            get { return m_districtCodes; }
            set { m_districtCodes = value; }
        }

        public string DistrictNames
        {
            get { return m_districtNames; }
            set { m_districtNames = value; }
        }

        public string AdministrationCodes
        {
            get { return m_administrationCodes; }
            set { m_administrationCodes = value; }
        }

        public string AdministrationNames
        {
            get { return m_administrationNames; }
            set { m_administrationNames = value; }
        }

        public string UnitTypeCodes
        {
            get { return m_unitTypeCodes; }
            set { m_unitTypeCodes = value; }
        }

        public string UnitTypeNames
        {
            get { return m_unitTypeNames; }
            set { m_unitTypeNames = value; }
        }

        public string PopulationSector
        {
            get { return m_populationSectorCodes; }
            set { m_populationSectorCodes = value; }
        }

        public string PopulationSectorNames
        {
            get { return m_populationSectorNames; }
            set { m_populationSectorNames = value; }
        }

        public int RemarkID
        {
            get { return m_remarkID; }
            set { m_remarkID = value; }
        }

        public int RelatedRemarkID
        {
            get { return m_relatedRemarkID; }
            set { m_relatedRemarkID = value; }
        }

        public int DicRemarkID
        {
            get { return m_dicRemarkID; }
            set { m_dicRemarkID = value; }
        }

        public int SubUnitTypeCode
        {
            get { return m_subUnitTypeCode; }
            set { m_subUnitTypeCode = value; }
        }

        public string CityCodes
        {
            get { return m_cityCodes; }
            set { m_cityCodes = value; }
        }

        public string CityName
        {
            get { return m_cityName; }
            set { m_cityName = value; }
        }

        public string FreeText
        {
            get { return m_freeText; }
            set { m_freeText = value; }
        }

        public string ServicesParameter
        {
            get { return m_servicesParameter; }
            set { m_servicesParameter = value; }
        }
        public string ServicesNameParameter
        {
            get { return m_servicesNameParameter; }
            set { m_servicesNameParameter = value; }
        }
    }

    public class SearchParametersBase
    {
        int? m_numberOfRecordsToShow;
        string m_districtCodes;
        string m_districtText;
        bool m_showMapSearchControls;
     
        public string DistrictCodes
        {
            get { return m_districtCodes; }
            set { m_districtCodes = value; }
        }

        public string DistrictText
        {
            get { return m_districtText; }
            set { m_districtText = value; }
        }

        public MapSearchInfo MapInfo { get; set; }

        public ReceptionTimeInfo CurrentReceptionTimeInfo { get; set; }

		public SearchModeInfo CurrentSearchModeInfo { get; set; }

        public bool ShowMapSearchControls
        {
            get { return m_showMapSearchControls; }
            set { m_showMapSearchControls = value; }
        }

        public int? NumberOfRecordsToShow
        {
            get { return m_numberOfRecordsToShow; }
            set { m_numberOfRecordsToShow = value; }
        }

        public virtual void PrepareParametersForDBQuery()
        {
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_districtCodes);

            //sets to value or null
            if (m_numberOfRecordsToShow <= 0)
            {
                m_numberOfRecordsToShow = null;
            }

            //don't touch those they are just  for the ui
            //m_districtText;

            CurrentReceptionTimeInfo.PrepareParametersForDBQuery();
            MapInfo.PrepareParametersForDBQuery();
        }

        public SearchParametersBase()
        {
           
          
        }
    }

	public class GeneralRemarkParameters
	{
		public int RemarkType { get; set; }
		public int RemarkCategory { get; set; }
		public int RemarkStatus { get; set; }
		public int SelectedRemarkID { get; set; }
		public Enums.SortableData? SortColumnIdentifier { get; set; }
		public SortDirection? SortDirection { get; set; }
	}

	public class SearchModeSelectParameters
	{
        public bool All { get; set; }
        public bool Mushlam { get; set; }
        public bool Community { get; set; }
        public bool Hospitals { get; set; }
 	}

}
