using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using SeferNet.DataLayer;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.Globals;
using System.Collections.Generic;
using System.Linq;

public partial class SelectPopUp : System.Web.UI.Page
{
    private string unitTypeCodes = "65";
	private string m_selectedValuesList;
    private string m_permittedDistricts;
    private string m_selectedDistricts;
    private string membershipValues;
	private PopupType m_popupType;
    private bool m_IsSingleSelectMode;
	private string membership = null;
	private int sectorType = -1;
	private int? serviceCode = null;
    private bool isCommunity = false;
    private bool isMushlam = false;
    private bool isHospitals = false;
	private int m_deptCode;
	private int m_employeeID;
	private int m_deptEmployeeID;
	private Facade facade = Facade.getFacadeObject();
    DataSet ds;

	protected void Page_Load(object sender, EventArgs e)
	{
		this.GetQueryString();

		if (!Page.IsPostBack) 
		{
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
			BindDataByDemand();
		}

		if (m_popupType == PopupType.Positions)
		{ 
			this.multiSelectList.OnConfirmClick += new EventHandler(multiSelectList_OnConfirmClick);		
		}

		if (m_popupType == PopupType.ServicesForEmployeeInClinic)
		{ 
			//this.multiSelectList.OnConfirmClick += new EventHandler(multiSelectList_OnConfirmClick);
			this.multiSelectList.ShowAddProfessionsButton = true;
			this.multiSelectList.OnAddFromFullListClick += new EventHandler(multiSelectList_OnAddProfessionsClick);
		}

	}

	private void BindDataByDemand()
	{
		//this.GetQueryString();

		switch (m_popupType)
		{
			case PopupType.Professions:
				HandleProfessions();
				break;

			case PopupType.Services:
				HandleServices(); // used in ReportsParameters.aspx only
				break;

			case PopupType.UnitType:
				HandleUnitTypes();
				break;

			case PopupType.District:
				HandleDistricts(false);
				break;

			case PopupType.UserPermittedDistrictsForReports:
				HandleDistricts(true);
				break;

			case PopupType.HandicappedFacilities:
				HandleFacilities();
				break;

			case PopupType.Languages:
				HandleLanguages();
				break;

			case PopupType.Cities:
				HandleCities();
				break;

			case PopupType.Admins:
				HandleAdmins();
				break;

			case PopupType.ObjectType:
				HandleObjectType();
				break;

			case PopupType.Events:
				HandleEvents();
				break;

			case PopupType.ServicesAndEvents:
				HandleServicesAndEvents();
				break;

			case PopupType.ServicesNew:
				this.HandleServicesNew();
				break;

            case PopupType.ServiceCategories:
                this.HandleServiceCategories();
                break;

			case PopupType.DeptAndServicesRemarks: 
				HandleRemarks();
				break;

            case PopupType.MF_Specialities051:
                this.GetMF_Specialities051();
                break;

			case PopupType.Membership:
				this.HandleMembership();
				break;

            case PopupType.ProfessionsForSalServices:
                HandleProfessionsForSalServices();
                break;

            case PopupType.GroupsForSalServices:
                HandleGroupsForSalServices();
                break;

            case PopupType.PopulationsForSalServices:
                HandlePopulationsForSalServices();
                break;

            case PopupType.OmriReturnsForSalServices:
                HandleOmriReturnsForSalServices();
                break;

            case PopupType.Clinics:
                HandleClinics();
                break;

            case PopupType.ICD9:
                HandleICD9();
                break;

            case PopupType.ChangeType:
                ChangeType();
                break;

            case PopupType.UpdateUser:
                UpdateUser();
                break;

            case PopupType.QueueOrders:
				HandleQueueOrders();
                break;

            case PopupType.MedicalAspects:
				GetMedicalAspects();
                break;

			case PopupType.Positions:
				HandleEmployeePositions();
				break;

			case PopupType.ServicesForEmployeeInClinic:
				HandleServicesForEmployeeInClinic();
				break;

			default:
				multiSelectList.ShowNoResults();
				break;
		}

		if (ds.Tables.Count > 1)
		{
			DataColumnCollection columns = ds.Tables[ds.Tables.Count - 1].Columns;
			if (columns.Contains("SelectedElementsMaxNumber"))
			{
				this.multiSelectList.SelectedElementsMaxNumber = Convert.ToInt32(ds.Tables[ds.Tables.Count - 1].Rows[0]["SelectedElementsMaxNumber"]);
				this.multiSelectList.SelectedElementsHebrewName = ds.Tables[ds.Tables.Count - 1].Rows[0]["NameToShowInHebrew"].ToString();
			}
			else
			{
				this.multiSelectList.SelectedElementsMaxNumber = -1;
				this.multiSelectList.SelectedElementsHebrewName = string.Empty;
			}
		}
		else
		{ 
			this.multiSelectList.SelectedElementsMaxNumber = -1;
			this.multiSelectList.SelectedElementsHebrewName = string.Empty;		
		}

	}

    private void HandleServiceCategories()
    {
		lblHeader.Text = "ניתן לבחור תחום שירות אחד או יותר מהרשימה";
		Page.Title = "בחר תחום שירות";
        ds = Facade.getFacadeObject().GetServiceCategoriesExtended(serviceCode, m_selectedValuesList);
        BindTreeView(ref ds, "serviceCategoryDescription", "serviceCategoryID", null, "selected");
    }

	private void HandleServicesAndEvents()
	{
		lblHeader.Text = "ניתן לבחור שירות או פעילות אחת או יותר מהרשימה";
		Page.Title = "בחר שירות או פעילות";

		this.GetServicesAndEvents(m_selectedValuesList, this.sectorType, this.membership);

		multiSelectList.ShowAddProfessionsButton = true;
	}
	
	private void HandleCities()
	{
		lblHeader.Text = "ניתן לבחור עיר אחת או יותר מהרשימה";
		Page.Title = "בחר עיר";
		GetCities(m_selectedDistricts, m_selectedValuesList);

		multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleAdmins()
	{
		lblHeader.Text = "ניתן לבחור מנהלת אחת או יותר מהרשימה";
		Page.Title = "בחר מנהלת";
		GetAdmins(m_selectedValuesList);

		multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleClinics()
	{
		lblHeader.Text = "ניתן לבחור מרפאה אחת או יותר מהרשימה";
        Page.Title = "בחר מרפאה";

		this.multiSelectList.IsSingleSelectMode = this.m_IsSingleSelectMode;

		GetClinics(m_selectedValuesList);

		multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleQueueOrders()
	{
		lblHeader.Text = "ניתן לבחור אופן זימון אחת או יותר מהרשימה";
        Page.Title = "בחר אופן זימון";
		GetQueueOrders(m_selectedValuesList);

		multiSelectList.ShowAddProfessionsButton = true;
	}
	private void GetMedicalAspects()
	{
		lblHeader.Text = "ניתן לבחור היבט אחד או יותר מהרשימה";
        Page.Title = "היבטים למרפאה";
		GetMedicalAspects(m_selectedValuesList);

		multiSelectList.ShowAddProfessionsButton = true;
	}

	//private void HandleServicesForEmployeeInClinic()
	//{
	//	if (!IsPostBack)
	//	{
	//		lblHeader.Text = "ניתן לבחור שירות אחד או יותר מהרשימה";
	//		Page.Title = "בחירת שירותים";
	//		//lblMainHeader.Text = "הגדרת תפקידים לרופא";
	//		this.multiSelectList.CheckedColumnField = "linkedToEmpInDept";

	//		GetEmployeePositions();
	//	}
	//	//this.multiSelectList.OnConfirmClick += new EventHandler(multiSelectList_OnConfirmClick);
	//	this.multiSelectList.ShowAddProfessionsButton = false;
	//}

	private void HandleServicesForEmployeeInClinic()
	{
		if (!IsPostBack)
		{
			lblHeader.Text = "ניתן לבחור שירות אחד או יותר מהרשימה";
			Page.Title = "בחירת שירותים";
			//lblMainHeader.Text = "הגדרת שירותים לרופא";
			this.multiSelectList.ButtonAddItemsText = "הוספת שירותים לרשימת השירותים";

			this.GetEmployeeServices(true);
		}
		this.multiSelectList.OnConfirmClick += new EventHandler(multiSelectList_OnConfirmClick);
		this.multiSelectList.ShowAddProfessionsButton = true;
		this.multiSelectList.OnAddFromFullListClick += new EventHandler(multiSelectList_OnAddProfessionsClick);
	}

	private void GetEmployeeServices(bool IsLinkedToEmployeeOnly)
	{
		EmployeeServiceInDeptBO bo = new EmployeeServiceInDeptBO();
		ds = bo.GetEmployeeServicesExtended(m_employeeID, m_deptCode, m_deptEmployeeID, IsLinkedToEmployeeOnly, null);

		this.multiSelectList.ImageTypeField = "AgreementType";
		BindTreeView(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "LinkedToEmployeeInDept", "LinkedToEmployeeInDept"); // fixed

		DataRow[] selectedRows = ds.Tables[0].Select("LinkedToEmployeeInDept = 1");

		string ServiceSeparatedValuesBefore = string.Empty;

		for (int i = 0; i < selectedRows.Length; i++)
		{
			ServiceSeparatedValuesBefore += selectedRows[i]["ServiceCode"].ToString() + ',';
		}
		ViewState["ServiceSeparatedValuesBefore"] = ServiceSeparatedValuesBefore;

	}

	private void HandleEmployeePositions()
	{
		if (!IsPostBack)
		{
			lblHeader.Text = "ניתן לבחור תפקיד אחד או יותר מהרשימה";
			Page.Title = "בחירת תפקידים";
			//lblMainHeader.Text = "הגדרת תפקידים לרופא";
			this.multiSelectList.CheckedColumnField = "linkedToEmpInDept";

			GetEmployeePositions();
		}
		//this.multiSelectList.OnConfirmClick += new EventHandler(multiSelectList_OnConfirmClick);
		this.multiSelectList.ShowAddProfessionsButton = false;
	}

	private void GetEmployeePositions()
	{
		EmployeePositionsBO bo = new EmployeePositionsBO();
		ds = bo.GetEmployeePositionsInDept(m_deptEmployeeID);

		BindTreeView(ref ds, "positionDescription", "positionCode", null, "linkedToEmpInDept", null); // toDo: fix
	}

	private void HandleServicesNew()
	{
		lblHeader.Text = "ניתן לבחור תחום שירות אחד או יותר מהרשימה";
		Page.Title = "בחר תחום שירות";
		this.GetServicesNew(m_selectedValuesList, this.sectorType, this.membership,this.isCommunity,this.isMushlam,this.isHospitals);

		multiSelectList.ShowAddProfessionsButton = true;
	}
	
	private void HandleProfessions()
	{
		lblHeader.Text = "ניתן לבחור מקצוע אחד או יותר מהרשימה";
		Page.Title = "בחר מקצוע";
		this.GetProfessions(this.m_selectedValuesList, this.sectorType, this.membership);

		this.multiSelectList.ShowAddProfessionsButton = true;
	}

    private void HandleProfessionsForSalServices()
	{
		lblHeader.Text = "ניתן לבחור מקצוע אחד או יותר מהרשימה";
		Page.Title = "בחר מקצוע";
        this.GetProfessionsForSalServices(this.m_selectedValuesList, this.membership);

		this.multiSelectList.ShowAddProfessionsButton = true;
	}

    private void HandleGroupsForSalServices()
	{
		lblHeader.Text = "ניתן לבחור קבוצה אחת או יותר מהרשימה";
		Page.Title = "בחר קבוצה";
        this.GetGroupsForSalServices(this.m_selectedValuesList, this.membership);

		this.multiSelectList.ShowAddProfessionsButton = true;
	}

    private void HandlePopulationsForSalServices()
	{
		lblHeader.Text = "ניתן לבחור אוכלוסייה אחת או יותר מהרשימה";
		Page.Title = "בחר קבוצה";
        this.GetPopulationsForSalServices(this.m_selectedValuesList, this.membership);

		this.multiSelectList.ShowAddProfessionsButton = true;
	}

    private void HandleOmriReturnsForSalServices()
    {
        lblHeader.Text = "ניתן לבחור החזר עומרי אחד או יותר מהרשימה";
        Page.Title = "בחר קוד החזר עומרי";
        this.GetOmriReturnsForSalServices(this.m_selectedValuesList, this.membership);

        this.multiSelectList.ShowAddProfessionsButton = true;
    }

    private void HandleICD9()
    {
        lblHeader.Text = "ניתן לבחור החזר ICD9 אחד או יותר מהרשימה";
        Page.Title = "בחר קוד החזר ICD9";
        this.GetICD9ReturnsForSalServices(this.m_selectedValuesList, this.membership);

        this.multiSelectList.ShowAddProfessionsButton = true;
    }

    private void ChangeType()
    {
        lblHeader.Text = "ניתן לבחור פעולה אחד או יותר מהרשימה";
        Page.Title = "בחר פעולות לתיעות";
        this.GetChangeTypes(this.m_selectedValuesList, this.membership);

        this.multiSelectList.ShowAddProfessionsButton = true;
    }

    private void UpdateUser()
    {
        lblHeader.Text = "ניתן לבחור מעדכן אחד או יותר מהרשימה";
        Page.Title = "בחר המעדכן";
        this.UpdateUser(this.m_selectedValuesList, this.membership);

        this.multiSelectList.ShowAddProfessionsButton = true;
    }

	private void HandleServices()
	{
		lblHeader.Text = "ניתן לבחור שירות אחד או יותר מהרשימה";
		Page.Title = "בחר שירות";
		this.GetServices(this.m_selectedValuesList, this.sectorType, this.membership);
		this.multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleUnitTypes()
	{
		lblHeader.Text = "ניתן לבחור סוג יחידה אחד או יותר מהרשימה";
		Page.Title = "בחר סוג יחידה";
		this.GetUnitTypes();
		multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleObjectType()
	{
		lblHeader.Text = "ניתן לבחור טיפוס אחד או יותר מהרשימה";
		Page.Title = "בחר טיפוס";
		this.GetObjectTypes(m_selectedValuesList);
		multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleEvents()
	{
		lblHeader.Text = "ניתן לבחור פעילות אחד או יותר מהרשימה";
		Page.Title = "בחר פעילות";
		this.GetEvents(m_selectedValuesList);
		multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleDistricts(bool isUserPermittedDistrictsForReports)
	{
		lblHeader.Text = "ניתן לבחור מחוז אחד או יותר מהרשימה";
		Page.Title = "בחר מחוז";
		if (isUserPermittedDistrictsForReports)
		{
			this.GetUserPermittedDistrictsForReports(m_selectedValuesList, unitTypeCodes);
		}
		else
		{
            this.GetDistricts(m_selectedValuesList, unitTypeCodes, m_permittedDistricts);
		}
		multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleFacilities()
	{
		lblHeader.Text = "ניתן לבחור הערכות לנכים אחד או יותר מהרשימה";
		Page.Title = "בחר הערכות לנכים";
		GetFacilities(m_selectedValuesList);
		multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleLanguages()
	{
		lblHeader.Text = "ניתן לבחור שפה אחד או יותר מהרשימה";
		Page.Title = "בחר שפה";
		GetLanguages(m_selectedValuesList);
		multiSelectList.ShowAddProfessionsButton = true;
	}
	
	private void HandleMembership()
	{
		lblHeader.Text = "ניתן לבחור חברות אחד או יותר מהרשימה";
		Page.Title = "בחר חברות";
		this.GetMembership(m_selectedValuesList);
		//multiSelectList.ShowAddProfessionsButton = true;
	}

	private void HandleRemarks()
	{
		lblHeader.Text = "ניתן לבחור הערה אחד או יותר מהרשימה";
		Page.Title = "בחר הערה";
		this.GetRemarks(m_selectedValuesList, 1, 1, 0, 0, 0);
		multiSelectList.ShowAddProfessionsButton = true;
	}

	private void GetCities(string selectedDistricts, string citiesCodesSelected)
	{
		//if (Session["cities"] == null)
		//{
			Facade applicFacade = Facade.getFacadeObject();
			ds = applicFacade.getCitiesDistrictsWithSelectedCodes(citiesCodesSelected, selectedDistricts);
			Session["cities"] = ds;
		//}
		//else
		//{
		//	ds = (DataSet)Session["cities"];
		//}

		BindTreeView(ref ds, "cityName", "cityCode", "districtCode", "selected");
	}

	private void GetServicesNew(string ServicesNewCodesSelected, int sectorType, string membership, bool isCommunity, bool isMushlam, bool isHospitals)
	{
		Facade applicFacade = Facade.getFacadeObject();
		ds = applicFacade.GetServicesNewBySector(ServicesNewCodesSelected, sectorType, true, true,
			isCommunity,isMushlam, isHospitals);

		this.multiSelectList.ImageTypeField = "AgreementType";
		BindTreeView(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "selected");
	}

	private void GetServicesAndEvents(string ServicesNewCodesSelected, int sectorType, string membership)
	{
		Facade applicFacade = Facade.getFacadeObject();

		ds = applicFacade.GetServicesNewAndEventsBySector(ServicesNewCodesSelected, sectorType,
			StringHelper.ConverAgreementNamesListToBoolArray(membership));
		
		this.multiSelectList.ImageTypeField = "AgreementType";
		BindTreeView(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "selected");
	}

	private void GetProfessions(string professionCodesSelected, int sectorType, string membership)
	{
		Facade applicFacade = Facade.getFacadeObject();

		ds = applicFacade.GetServicesNewBySector(professionCodesSelected, sectorType, false, true,
		true, true, true);
		
		this.multiSelectList.ImageTypeField = "AgreementType";
		BindTreeView(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "selected");
	}

    private void GetProfessionsForSalServices(string professionCodesSelected , string membership )
    {
        Facade applicFacade = Facade.getFacadeObject();

        if (professionCodesSelected.Trim().EndsWith(","))
            professionCodesSelected = professionCodesSelected.Trim().Remove(professionCodesSelected.Length - 1, 1);

        ds = applicFacade.GetProfessionsForSalServices( professionCodesSelected );

        BindTreeView(ref ds, "Description", "Code", null , "selected");
    }

    private void GetGroupsForSalServices(string groupCodesSelected, string membership)
    {
        Facade applicFacade = Facade.getFacadeObject();

        if (groupCodesSelected.Trim().EndsWith(","))
            groupCodesSelected = groupCodesSelected.Trim().Remove(groupCodesSelected.Length - 1, 1);

        ds = applicFacade.GetGroupsForSalServices( groupCodesSelected );

        //this.multiSelectList.ImageTypeField = "AgreementType";
        BindTreeView(ref ds, "GroupDesc", "GroupCode", null , "selected");
    }

    private void GetPopulationsForSalServices(string populationCodesSelected, string membership)
    {
        Facade applicFacade = Facade.getFacadeObject();

        if (populationCodesSelected.Trim().EndsWith(","))
            populationCodesSelected = populationCodesSelected.Trim().Remove(populationCodesSelected.Length - 1, 1);

        ds = applicFacade.GetPopulationsForSalServices(populationCodesSelected);

        BindTreeView(ref ds, "PopulationsDesc", "PopulationsCode", null , "selected");
    }

    private void GetOmriReturnsForSalServices(string omriReturnCodesSelected, string membership)
    {
        Facade applicFacade = Facade.getFacadeObject();

        if (omriReturnCodesSelected.Trim().EndsWith(","))
            omriReturnCodesSelected = omriReturnCodesSelected.Trim().Remove(omriReturnCodesSelected.Length - 1, 1);

        ds = applicFacade.GetOmriReturnsForSalServices(omriReturnCodesSelected);

        BindTreeView(ref ds, "ReturnDescription", "ReturnCode" , null , "selected");
    }

    private void GetICD9ReturnsForSalServices(string ICD9ReturnCodesSelected, string membership)
    {
        Facade applicFacade = Facade.getFacadeObject();

        if (ICD9ReturnCodesSelected.Trim().EndsWith(","))
            ICD9ReturnCodesSelected = ICD9ReturnCodesSelected.Trim().Remove(ICD9ReturnCodesSelected.Length - 1, 1);

        ds = applicFacade.GetICD9ReturnsForSalServices(ICD9ReturnCodesSelected);

        BindTreeView(ref ds, "ICD9ReturnDescription", "ICD9ReturnCode", null, "selected");
    }

    private void GetChangeTypes(string ChangeTypeIDSelected, string membership)
    {
        Facade applicFacade = Facade.getFacadeObject();

        if (ChangeTypeIDSelected.Trim().EndsWith(","))
            ChangeTypeIDSelected = ChangeTypeIDSelected.Trim().Remove(ChangeTypeIDSelected.Length - 1, 1);

        ds = applicFacade.GetChangeTypes(ChangeTypeIDSelected);

        BindTreeView(ref ds, "ChangeTypeDescription", "ChangeTypeCode", null, "selected");
    }

    private void UpdateUser(string UpdateUserSelected, string membership)
    {
        Facade applicFacade = Facade.getFacadeObject();

        if (UpdateUserSelected.Trim().EndsWith(","))
            UpdateUserSelected = UpdateUserSelected.Trim().Remove(UpdateUserSelected.Length - 1, 1);

        ds = applicFacade.GetUpdateUser(UpdateUserSelected);

        BindTreeView(ref ds, "UserName", "UserID", null, "selected");
    }
	private void GetServices(string serviceCodesSelected, int sectorType, string membership)
	{
		Facade applicFacade = Facade.getFacadeObject();

        bool community = false;
        bool mushlam = false;
        bool hospitals = false;

        if (membership.IndexOf("Community") >= 0)
            community = true;
        if (membership.IndexOf("Mushlam") >= 0)
            mushlam = true;
        if (membership.IndexOf("Hospitals") >= 0)
            hospitals = true;

		ds = applicFacade.GetServicesNewBySector(serviceCodesSelected, sectorType, true, false,
        community, mushlam, hospitals);

		this.multiSelectList.ImageTypeField = "AgreementType";
		BindTreeView(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "selected");
	}

	private void GetUnitTypes()
	{
		Facade applicFacade = Facade.getFacadeObject();
        Dictionary<Enums.SearchMode, bool> agreementTypes = StringHelper.ConverAgreementNamesListToBoolArray(membershipValues);
        ds = applicFacade.GetUnitTypesExtended(m_selectedValuesList, agreementTypes);

		BindTreeView(ref ds, "UnitTypeName", "UnitTypeCode", null, "selected");
	}

	private void GetObjectTypes(string selectedValuesList)
	{
		Facade applicFacade = Facade.getFacadeObject();
		ds = applicFacade.GetObjectTypesExtended(selectedValuesList);

		BindTreeView(ref ds, "Description", "ID", null, "selected");
	}

	private void GetEvents(string selectedValuesList)
	{
		Facade applicFacade = Facade.getFacadeObject();
		ds = applicFacade.GetEventsExtended(selectedValuesList);

		BindTreeView(ref ds, "EventName", "EventCode", null, "selected");
	}

    private void GetDistricts(string selectedValuesList, string unitTypeCodes, string permittedDistricts)
	{
		Facade applicFacade = Facade.getFacadeObject();
        ds = applicFacade.GetDistrictsExtended(selectedValuesList, unitTypeCodes, permittedDistricts);

		this.BindTreeView(ref ds, "districtName", "districtCode", null, "selected");
	}

	private void GetUserPermittedDistrictsForReports(string selectedValuesList, string unitTypeCodes)
	{
		UserManager usMang = new UserManager();
		ds = usMang.getUserPermittedDistrictsForReports(usMang.GetUserIDFromSession(), unitTypeCodes);
		this.BindTreeView(ref ds, "districtName", "districtCode", null, null, selectedValuesList);
	}

	private void GetAdmins(string selectedValuesList)
	{
		string[] selectedValues = selectedValuesList.Split(';');
		string selectedAdmins = string.Empty;
		string districts = string.Empty;
		districts = selectedValues[0];
		selectedAdmins = selectedValues[1];

		Facade applicFacade = Facade.getFacadeObject();
		ds = applicFacade.GetAdminsExtended(selectedAdmins, districts);

		BindTreeView(ref ds, "adminName", "adminCode", null, "selected");
	}

	private void GetClinics(string selectedValuesList)
	{
		string[] selectedValues = selectedValuesList.Split(';');
		string selectedAdmins = string.Empty;
		string districts = string.Empty;
        string selectedClinics = string.Empty;
        string unitTypeListCodes = string.Empty;
        string subUnitTypeCode = string.Empty;
        string populationSector = string.Empty;


		districts = selectedValues[0];
		selectedAdmins = selectedValues[1];
		selectedClinics = selectedValues[2];
        unitTypeListCodes = selectedValues[3];
        subUnitTypeCode = selectedValues[4];
        populationSector = selectedValues[5];
        if(populationSector == "-1")
            populationSector = string.Empty;

		Facade applicFacade = Facade.getFacadeObject();
        ds = applicFacade.GetClinicsExtended(selectedClinics, selectedAdmins, districts, unitTypeListCodes, subUnitTypeCode, populationSector);

        BindTreeView(ref ds, "clinicName", "clinicCode", null, "selected");
	}

	private void GetQueueOrders(string selectedValuesList)
	{
		string[] selectedValues = selectedValuesList.Split(';');

		QueueOrderMethodBO bo = new QueueOrderMethodBO();
		ds = bo.GetDicQueueOrderMethodsAndOptionsCombined(selectedValuesList);

		BindTreeView(ref ds, "QueueOrderDescription", "QueueOrderCode", null, "selected");
	}
	private void GetMedicalAspects(string selectedValuesList)
	{
		string[] selectedValues = selectedValuesList.Split(';');

		EmployeeServiceInDeptBO bo = new EmployeeServiceInDeptBO();
		ds = bo.GetMedicalAspects((int)m_deptCode, false, null);

		//QueueOrderMethodBO bo = new QueueOrderMethodBO();
		//ds = bo.GetDicQueueOrderMethodsAndOptionsCombined(selectedValuesList);

		BindTreeView(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "LinkedToEmployee", "LinkedToEmployeeInDept");
	}

	private void GetFacilities(string selectedValuesList)
	{
		Facade applicFacade = Facade.getFacadeObject();
		ds = applicFacade.GetHandicappedFacilitiesExtended(selectedValuesList);

		BindTreeView(ref ds, "FacilityDescription", "FacilityCode", null, "selected");
	}

	private void GetLanguages(string selectedValuesList)
	{
		Facade applicFacade = Facade.getFacadeObject();
		ds = applicFacade.GetLanguagesExtended(selectedValuesList);

		BindTreeView(ref ds, "languageDescription", "languageCode", null, "selected");
	}

	private void GetRemarks(string selectedCodes, byte linkedToDept, byte linkedToServiceInClinic, byte linkedToDoctor,
				byte linkedToDoctorInClinic, byte linkedToReceptionHours)
	{
		Facade applicFacade = Facade.getFacadeObject();
		ds = applicFacade.GetRemarksExtended(selectedCodes, linkedToDept, linkedToServiceInClinic, linkedToDoctor,
				linkedToDoctorInClinic, linkedToReceptionHours);
		if (ds == null) return;

		RemarkManager remarkManager = new RemarkManager();
		foreach (DataRow row in ds.Tables[0].Rows)
		{
			string remarkText = remarkManager.GetRemarkTextForView(row["RemarkDescription"].ToString());
			row["RemarkDescription"] = remarkText;
		}

		BindTreeView(ref ds, "RemarkDescription", "RemarkCode", null, "selected");
	}

	private void GetMF_Specialities051()
	{
		// if Single Select Mode - check selectedValues count. 
		string[] codes = this.m_selectedValuesList.Split(new char[2] {',',';'});
		if (this.m_IsSingleSelectMode 
			&& codes.Length > 1)
		{
			this.m_selectedValuesList = codes[0];
		}

		Facade applicFacade = Facade.getFacadeObject();
		ds = applicFacade.GetMF_Specialities051(null, null, m_selectedValuesList);
		
		this.multiSelectList.IsSingleSelectMode = this.m_IsSingleSelectMode;
		BindTreeView(ref ds, "Description", "Code", null, "Selected");

		this.multiSelectList.ShowAddProfessionsButton = true;
	}

	private void GetMembership(string selectedValuesList)
	{
		Facade applicFacade = Facade.getFacadeObject();
		ds = applicFacade.getGeneralDataTable("DIC_Membership");

		BindTreeView(ref ds, "MembershipDescription", "MembershipID", null, null, this.m_selectedValuesList);
	}

	private bool GetQueryString()
	{
		try
		{
			m_selectedValuesList = string.Empty;

			if (Request.QueryString["SelectedValuesList"] != null)
			{
				m_selectedValuesList = Request.QueryString["SelectedValuesList"].ToString();
			}

            if (Request.QueryString["PermittedDistricts"] != null)
			{
                m_permittedDistricts = Request.QueryString["PermittedDistricts"].ToString();
			}

            if (Request.QueryString["SelectedDistrictCodes"] != null)
			{
                m_selectedDistricts = Request.QueryString["SelectedDistrictCodes"].ToString();
			}

            if (Request.QueryString["membershipValues"] != null)
            {
                membershipValues = Request.QueryString["membershipValues"].ToString();
            }

            if (Request.QueryString["unitTypeCodes"] != null)
            {
                unitTypeCodes = Request.QueryString["unitTypeCodes"].ToString();
            }

			if (Request.QueryString["popupType"] != null)
			{
				m_popupType = (PopupType)Enum.Parse(typeof(PopupType), Request.QueryString["popupType"]);
			}
			
			if (Request.QueryString["IsSingleSelectMode"] != null)
			{
				this.m_IsSingleSelectMode = bool.Parse(Request.QueryString["IsSingleSelectMode"]);
			}
			
			if (!string.IsNullOrEmpty(Request.QueryString["sectorType"]))
			{
				this.sectorType = Convert.ToInt32(Request.QueryString["sectorType"]);
			}
			
			if (!string.IsNullOrEmpty(Request.QueryString["AgreementTypes"]))
			{
				this.membership = Request.QueryString["AgreementTypes"];
			}
			
			if (!string.IsNullOrEmpty(Request.QueryString["serviceCode"]))
			{
				serviceCode = Convert.ToInt32(Request.QueryString["serviceCode"]);
			}

            if (!string.IsNullOrEmpty(Request.QueryString["isInCommunity"]))
            {
                if (Request.QueryString["isInCommunity"].ToString() == "true" || Request.QueryString["isInCommunity"].ToString() == "1")
                    this.isCommunity = true;
                else
                    this.isCommunity = false;
            }

            if (!string.IsNullOrEmpty(Request.QueryString["isInMushlam"]))
            {
                if (Request.QueryString["isInMushlam"].ToString() == "true" || Request.QueryString["isInMushlam"].ToString() == "1")
                    this.isMushlam = true;
                else
                    this.isMushlam = false;
            }

            if (!string.IsNullOrEmpty(Request.QueryString["isInHospitals"]))
            {
                if (Request.QueryString["isInHospitals"].ToString() == "true" || Request.QueryString["isInHospitals"].ToString() == "1")
                    this.isHospitals = true;
                else
                    this.isHospitals = false;
            }

			if (!string.IsNullOrEmpty(Request.QueryString["returnValuesTo"]))
			{
				this.multiSelectList.WhereToReturnSelectedValues = Request.QueryString["returnValuesTo"].ToString();
			}

			if (!string.IsNullOrEmpty(Request.QueryString["returnTextTo"]))
			{
				this.multiSelectList.WhereToReturnSelectedText = Request.QueryString["returnTextTo"].ToString();
			}

			if (!string.IsNullOrEmpty(Request.QueryString["functionToExecute"]))
			{
				this.multiSelectList.FunctionToBeExecutedOnParent = Request.QueryString["functionToExecute"].ToString();
			}

			if (Request.QueryString["deptCode"] != null)
			{
				this.m_deptCode = Convert.ToInt32(Request.QueryString["deptCode"]);
			}

			if (Request.QueryString["employeeID"] != null)
			{
				this.m_employeeID = Convert.ToInt32(Request.QueryString["employeeID"]);
			}

			if (Request.QueryString["deptEmployeeID"] != null)
			{
				this.m_deptEmployeeID = Convert.ToInt32(Request.QueryString["deptEmployeeID"]);
			}

		}
		catch
		{
			return false;
		}

		return true;
	}

	private void BindTreeView(ref DataSet ds, string textField, string valueField, string parentCodeField, string checkedField)
	{
		this.BindTreeView(ref ds, textField, valueField, parentCodeField, checkedField, null);
	}

	private void BindTreeView(ref DataSet ds, string textField, string valueField, string parentCodeField, string checkedField, string selectedCodesList)
	{
		if (ds != null && ds.Tables[0].Rows.Count > 0)
		{
			this.multiSelectList.DataSource = ds;
			this.multiSelectList.TextField = textField;
			this.multiSelectList.ValueField = valueField;
			this.multiSelectList.ParentCodeField = parentCodeField;
			this.multiSelectList.CheckedColumnField = checkedField;
			this.multiSelectList.SelectedCodesList = this.ConvertSeparatedStringToList(selectedCodesList);
            if( ds.Tables[0].Columns.Contains("isReadOnly"))
                this.multiSelectList.CheckBoxReadOnlyField = "isReadOnly";
			
			Control div = multiSelectList.FindControl("divButtonAdd") as Control;

			if (m_popupType != PopupType.ServicesForEmployeeInClinic || this.multiSelectList.ButtonAddItemsText == string.Empty)
			{
				if (div != null)
					div.Visible = false;
			}

			this.multiSelectList.DataBind();
			this.multiSelectList.HideNoResults();
		}
		else
		{
			multiSelectList.ShowNoResults();
			lblHeader.Visible = false;
		}
	}

	private List<int> ConvertSeparatedStringToList(string valuesStr)
	{
		List<int> valuesList = new List<int>();
		if (string.IsNullOrWhiteSpace(valuesStr))
			return valuesList;
		

		string[] codesArr = valuesStr.Split(new char[] { ',', ';' });
		
		foreach (string codeStr in codesArr)
		{
			int code;
			if (int.TryParse(codeStr, out code))
			{
				valuesList.Add(code);
			}
		}

		return valuesList;
	}

	protected void multiSelectList_OnConfirmClick(object sender, EventArgs e)
	{
		UserInfo user = HttpContext.Current.Session["currentUser"] as UserInfo;
		string SelectedValues = Session["SelectedCodes"].ToString();

		UpdateNewSelectionsInDB(SelectedValues, user.UserNameWithPrefix, user.UserID);
	}

	private void UpdateNewSelectionsInDB(string seperatedValues, string userName, long UserID)
	{
		bool result = false;

		switch (m_popupType)
		{
			case PopupType.Positions:

				facade.UpdateEmployeePositionsInDept(m_employeeID, m_deptCode, m_deptEmployeeID, seperatedValues, userName);
				break;

			case PopupType.ServicesForEmployeeInClinic:
				result = facade.UpdateEmployeeServicesInDept(m_deptEmployeeID, seperatedValues, userName, m_deptCode);

				if (result)
				{
					if (ViewState["ServiceSeparatedValuesBefore"] != null)
					{
						string[] ServiceSeparatedValuesBefore = ViewState["ServiceSeparatedValuesBefore"].ToString().Split(',');
						string[] ServiceSeparatedValuesAfter = seperatedValues.Split(',');
						for (int i = 0; i < ServiceSeparatedValuesAfter.Count(); i++)
						{
							string newServiceCode = ServiceSeparatedValuesAfter[i];

							for (int ii = 0; ii < ServiceSeparatedValuesBefore.Count(); ii++)
							{
								if (ServiceSeparatedValuesAfter[i] == ServiceSeparatedValuesBefore[ii])
								{
									newServiceCode = string.Empty;
								}
							}

							if (newServiceCode != string.Empty)
								facade.Insert_LogChange((int)SeferNet.Globals.Enums.ChangeType.EmployeeInClinicService_Add, UserID, m_deptCode, null, m_deptEmployeeID, -1, null, Convert.ToInt32(newServiceCode), null);

						}
					}
				}

				break;

			default:
				break;
		}
	}

	protected void multiSelectList_OnAddProfessionsClick(object sender, EventArgs e)
	{
		GetQueryString();

		lblHeader.Visible = true;

		//switch (m_popupType)
		//{
		//	case PopupType.Services:
		//		this.GetEmployeeServices(false);
		//		break;
		//}
		if (m_popupType == PopupType.Services || m_popupType == PopupType.ServicesForEmployeeInClinic)
		{
			this.GetEmployeeServices(false);
		}
	}
}
