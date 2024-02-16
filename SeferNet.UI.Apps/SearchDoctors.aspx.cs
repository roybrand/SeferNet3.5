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
using SeferNet.UI;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;
using System.Text;
using MapsManager;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServicesManager;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

public partial class Public_SearchDoctors : System.Web.UI.Page, ISearchPageController
{
    private DataSet _dsDoctors;
    private DataSet dsDoctors
    {
        get
        {
            if (_dsDoctors == null)
            {
                return ViewState["dsResults"] as DataSet;
            }
            else
            {
                return _dsDoctors;
            }
        }

        set
        {
            _dsDoctors = value;
        }
    }
    
    UserInfo currentUser;
    string pageCounter = string.Empty;
    SessionParams sessionParams;
    DoctorSearchParameters doctorSearchParameters = new DoctorSearchParameters();
    int currDeptCode = 0;
    long currEmployeeID = 0;
    int deptEmployeeID = 0;
    int currRowNumber = 0;
    int rowStatus = 1;
    string strNotActiveColor = "red";
    string strTemporaryNotActiveColor = "#858585";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        RegisterMasterControlsEvents();

        //transfterring control from  master page to the current page - by removing it from the master and adding it to 
        // a place holder
        //this code MUST BE CALLED every time the page loads
        phButtonsShowHideMap.Controls.Add(Master.GetDivButtonShowHide());

        if (IsPostBack == false)
        {
            //flag to hide map
            Master.IsAllowShowMap_PageCondition = false;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        Master.PagingControlsController = new SortingAndPagingInfoController(this, btnFirstPage, btnPreviousPage, btnNextPage, btnLastPage,
                                                                                        lblTotalRecords, lblPageFromPages, ddlCarrentPage);

        if (!IsPostBack)
        {
            handleBinding();

            ViewState["currentGvDataView"] = null;
            ddlStatus.SelectedValue = (Convert.ToInt32(clinicStatus.Active)).ToString();

            this.InitializeViewFromGlobalResources();



        }

        pageCounter = SessionParamsHandler.GetPageCounter();

        // take care about "read only" textBoxes not to lose their values after post back       
        txtProfessionList.Text = Request[txtProfessionList.UniqueID];

        //txtServiceList.Text = Request[txtServiceList.UniqueID];
        txtLanguageList.Text = Request[txtLanguageList.UniqueID];
        txtHandicappedFacilitiesList.Text = Request[txtHandicappedFacilitiesList.UniqueID];

        // clear selected TAB at "ZoomDoctor.aspx"        
        sessionParams = SessionParamsHandler.GetSessionParams();
        sessionParams.CurrentTab_ZoomDoctor = null;
        SessionParamsHandler.SetSessionParams(sessionParams);

        if (!IsPostBack)
        {
            if (Request.QueryString["RepeatSearch"] != null)
            {
                RepeatLastSearch();

                //if (sessionParams.LastRowIndexOnSearchPage != null)
                //    gvDoctorsList.SelectedIndex = Convert.ToInt32(sessionParams.LastRowIndexOnSearchPage);


            }

            ClientScript.RegisterStartupScript(this.GetType(), "ActionOnSearchModeChanged_Refresh", "ActionOnSearchModeChanged_Refresh();", true);

        }
        else
        {
            //gvDoctorsList.SelectedIndex = -1;
            txtAgreementType.Text = ddlAgreementType.SelectedValue;

            ScriptManager sm = ScriptManager.GetCurrent(Page);
            if (sm != null)
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "ActionOnSearchModeChanged_Refresh", "ActionOnSearchModeChanged_Refresh();", true);
            }
        }

        ddlAgreementType.Attributes.Add("onchange", "SetTxtAgreementType();");

        Master.SetTabIndexes(new WebControl[] {txtLastName, txtFirstName, Master.TxtDistrictList, Master.TxtCity, txtProfessionList, 
                                               txtLicenseNumber, ddlSex, txtLanguageList, ddlExpert, ddlAgreementType, 
                                               ddlStatus, txtHandicappedFacilitiesList, Master.TxtFromHour, Master.TxtToHour, Master.TxtAtHour}, null);

    }

    protected void Page_Prerender(object sender, EventArgs e)
    {
        currentUser = Session["currentUser"] as UserInfo;
        if (currentUser != null)
            trEmployeeID.Style.Add("display", "inline");
        else
            trEmployeeID.Style.Add("display", "none");

        SessionParamsHandler.SetLastSearchPageURL("SearchDoctors.aspx"); //??? what the  hell is that

        this.InitializeControls();

        if (txtProfessionList.Text == string.Empty)
            divReceiveGuests.Disabled = true;
        else
        {
            divReceiveGuests.Disabled = true;

            string ServicesToReceiveGuests = txtProfessionsRelevantForReceivigGuests.Text;
            var relevantServices = ServicesToReceiveGuests.Split(',');
            var selectedServices = txtProfessionListCodes.Text.Split(',');

            for (int i = 0; i < relevantServices.Length; i++)
            {
                for (int ii = 0; ii < selectedServices.Length; ii++)
                {
                    if (relevantServices[i] == selectedServices[ii])
                    {
                        divReceiveGuests.Disabled = false;
                    }
                }
            }
        }
    }

    private void RegisterMasterControlsEvents()
    {

        //Master.btnClear_ClickEvent += btnClear_Click;
        Master.btnSubmit_ClickEvent += btnSubmit_Click;
    }

    private void InitializeControls()
    {
        UserManager mgr = new UserManager();
        string IsUserLoggedIn = string.Empty;
        if (!string.IsNullOrWhiteSpace(mgr.GetLoggedinUserNameWithPrefix()))
        {
            IsUserLoggedIn = "1";
        }

        this.txtLastName.Attributes.Add("onFocus",
            "UpdateAutoCompleteName('" + IsUserLoggedIn + "','" + txtFirstName.ClientID + "','"
            + this.acLastName.BehaviorID + "');");

        this.txtFirstName.Attributes.Add("onFocus",
            "UpdateAutoCompleteName('" + IsUserLoggedIn + "','" + txtLastName.ClientID + "','"
            + this.acFirstName.BehaviorID + "');");
    }

    private void InitializeViewFromGlobalResources()
    {
        string notValidChar = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "NotValidChar_ErrorMess") as string;
        string notValidInteger = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "IntegerOnly_ErrorMess") as string;
        string notValidWords = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "PreservedWord_ErrorMess") as string;

        //---- First Name
        this.VldRegexFistName.ErrorMessage = string.Format(notValidChar, this.lblFirstNameCaption.Text);
        this.VldRegexFistName.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.vldPreservedWordsFistName.ErrorMessage = string.Format(notValidWords, this.lblFirstNameCaption.Text);

        //---- Last Name
        this.VldRegexLastName.ErrorMessage = string.Format(notValidChar, this.lblLastNameCaption.Text);
        this.VldRegexLastName.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.vldPreservedWordsLastName.ErrorMessage = string.Format(notValidWords, this.lblLastNameCaption.Text);

        //----- ClinicKod
        this.vldIntLicenseNumber.ErrorMessage = string.Format(notValidInteger, this.lblLicenseNumber.Text);

        //---------- EmployeeID
        this.vldIntEmployeeIDCompare.ErrorMessage = string.Format(notValidInteger, this.lblLicenseNumber.Text);

        string multiLineLabelCss = "MultiLineLabel";


        this.lblEmployeeID.CssClass = multiLineLabelCss;
        this.lblEmployeeSectorCode.CssClass = multiLineLabelCss;
        this.lblExpert.CssClass = multiLineLabelCss;
        this.lblHandicappedFacilities.CssClass = multiLineLabelCss;
        this.lblFirstNameCaption.CssClass = multiLineLabelCss;
        this.lblLastNameCaption.CssClass = multiLineLabelCss;
        this.lblLanguageCaption.CssClass = multiLineLabelCss;
        this.lblLicenseNumber.CssClass = multiLineLabelCss;
        this.lblProfessionCaption.CssClass = multiLineLabelCss;
        this.lblPosition.CssClass = multiLineLabelCss;
        //this.lblServices.CssClass = multiLineLabelCss;
        this.lblStatusCaption.CssClass = multiLineLabelCss;
        this.lblSex.CssClass = multiLineLabelCss;
        this.lblAgreementType.CssClass = multiLineLabelCss;
    }

    private void RestoreSearchParameters()
    {
        if (Session["doctorSearchParameters"] != null)
        {



            doctorSearchParameters = Session["doctorSearchParameters"] as DoctorSearchParameters;
            txtFirstName.Text = doctorSearchParameters.FirstName;
            txtLastName.Text = doctorSearchParameters.LastName;
            txtEmployeeID.Text = doctorSearchParameters.EmployeeID.ToString();

            txtProfessionListCodes.Text = doctorSearchParameters.ServiceCode;
            txtProfessionList.Text = doctorSearchParameters.ServiceText;

            txtQueueOrderCodes.Text = doctorSearchParameters.QueueOrderMethodsAndOptionsCodes;
            txtQueueOrder.Text = doctorSearchParameters.QueueOrderMethodsAndOptions;

            //txtServiceListCodes.Text = doctorSearchParameters.ServiceCode;
            //txtServiceList.Text = doctorSearchParameters.ServiceText;

            ddlExpert.SelectedValue = doctorSearchParameters.ExpertProfession.ToString();

            txtLanguageListCodes.Text = doctorSearchParameters.LanguageCode;
            txtLanguageList.Text = doctorSearchParameters.LanguageText;

            ddlEmployeeSectorCode.SelectedValue = doctorSearchParameters.EmployeeSectorCode.ToString();
            BindDdlPosition();
            ddlPosition.SelectedValue = doctorSearchParameters.PositionCode.ToString();

            ddlSex.SelectedValue = doctorSearchParameters.Sex.ToString();
            if (doctorSearchParameters.AgreementType != null)
                ddlAgreementType.SelectedValue = Enum.Parse(typeof(eDIC_AgreementTypes), doctorSearchParameters.AgreementType.ToString()).ToString();
            txtAgreementType.Text = ddlAgreementType.SelectedValue;

            txtHandicappedFacilitiesCodes.Text = doctorSearchParameters.HandicappedFacilitiesCodes;
            txtHandicappedFacilitiesList.Text = doctorSearchParameters.HandicappedFacilitiesDescriptions;
            cbNotReceiveGuests.Checked = doctorSearchParameters.ReceiveGuests;
            txtLicenseNumber.Text = doctorSearchParameters.LicenseNumber.ToString();
            ddlStatus.SelectedValue = doctorSearchParameters.Status.ToString();
            Master.RefreshControlsByParameters(doctorSearchParameters);


        }
    }

    private void RepeatLastSearch()
    {
        RestoreSearchParameters();

        Master.RepeatLastSearch();

        //gvDoctorsList.Visible = true;

        ShowGridAndRelatedControls();
    }


    private void BindDdlPosition()
    {
        int employeeSectorSelected = Convert.ToInt32(ddlEmployeeSectorCode.SelectedValue);

        string filter = string.Empty;
        if (employeeSectorSelected != -1)
            filter = "relevantSector = " + employeeSectorSelected.ToString();
        else
            filter = " ";

        ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
        DataTable tblPositions = cacheHandler.getCachedDataTable(eCachedTables.View_Positions.ToString());
        DataView dvSubUnitType = new DataView(tblPositions, filter, "positionDescription", DataViewRowState.OriginalRows);
        ddlPosition.Items.Clear();
        ListItem itm = new ListItem("הכל", "-1");
        ddlPosition.Items.Add(itm);

        ddlPosition.DataSource = dvSubUnitType;
        ddlPosition.DataBind();

        if (ddlPosition.Items.Count > 1)
        {
            ddlPosition.Style.Add("display", "inline");
            lblPosition.Style.Add("display", "inline");
        }
        else
        {
            ddlPosition.Style.Add("display", "none");
            lblPosition.Style.Add("display", "none");
        }
    }

    private void handleBinding()
    {
        // bind all relevant dropdownlists to cached views
        UIHelper.BindDropDownToCachedTable(ddlEmployeeSectorCode, eCachedTables.View_EmployeeSector.ToString(), "");

        UIHelper.BindDropDownToCachedTable(ddlStatus, eCachedTables.DIC_ActivityStatus.ToString(), eDIC_ActivityStatusEnum.statusDescription.ToString());
        ListItem lItem = new ListItem("הכל", "-1");
        ddlStatus.Items.Insert(0, lItem);

        //UIHelper.BindDropDownToCachedTable(ddlPosition, "View_Positions", "positionDescription");
        UIHelper.BindDropDownToCachedTable(ddlSex, eCachedTables.DIC_Gender.ToString(), eDIC_GenderEnum.sex.ToString());

        UIHelper.BindDropDownToCachedTable(ddlAgreementType, eCachedTables.DIC_AgreementTypes.ToString(),
                                                                                        eDIC_AgreementTypesEnum.AgreementTypeID.ToString());

        UIHelper.BindDropDownToCachedTable(ddlAgreementTypeClone, eCachedTables.DIC_AgreementTypes.ToString(),
                                                                                        eDIC_AgreementTypesEnum.AgreementTypeID.ToString());

        SetEmployeeSectorDefaultValue();

        txtProfessionsRelevantForReceivigGuests.Text = ConfigurationManager.AppSettings["ServicesRelevantForReceivingGuests"].ToString();
    }

    private void SetEmployeeSectorDefaultValue()
    {
        //if we are in not RepeatSearch mode we set a default  value
        if (Request.QueryString["RepeatSearch"] == null)
        {
            ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
            // Make "רופא" selected (default value)
            //DataTable tblEmployeeSector = cacheHandler.getCachedDataTable(eCachedTables.EmployeeSector.ToString());
            //DataRow[] dataRow = tblEmployeeSector.Select(string.Format("{0} = 1", eEmployeeSectorEnum.IsDoctor));
            //ddlEmployeeSectorCode.SelectedValue = dataRow[0][eEmployeeSectorEnum.EmployeeSectorCode.ToString()].ToString();

            BindDdlPosition();
        }
    }

    private void ClearFields()
    {
        txtLastName.Text = String.Empty;
        txtFirstName.Text = String.Empty;
        txtLicenseNumber.Text = String.Empty;
        txtEmployeeID.Text = String.Empty;
        txtProfessionList.Text = String.Empty;
        ddlExpert.SelectedValue = "-1";
        txtLanguageListCodes.Text = String.Empty;
        txtLanguageListCodes.Text = String.Empty;

        ddlSex.SelectedValue = "-1";
        ddlStatus.SelectedValue = (Convert.ToInt32(clinicStatus.Active)).ToString();
        ddlEmployeeSectorCode.SelectedValue = "-1";
        ddlAgreementType.SelectedValue = "-1";
        txtHandicappedFacilitiesCodes.Text = String.Empty;
        txtHandicappedFacilitiesList.Text = String.Empty;
        txtLicenseNumber.Text = String.Empty;
        ddlPosition.SelectedValue = "-1";
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearFields();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
        sessionParams.DeptCode = 0;
        sessionParams.EmployeeID = 0;

        Session["RenewSearch"] = true;

        ViewState["currentGvDataView"] = null;

        Master.uniqueSearchParamater = Guid.NewGuid().ToString();

        Master.ResetSortingAndPaging(tdSortingButtons, null);

        LoadDataAndPopulate();

        ShowGridAndRelatedControls();
        sessionParams.totalRows = TotalNumberOfRecords;
        SessionParamsHandler.SetSessionParams(sessionParams);
        //Master.SetPagingControls(TotalNumberOfRecords);
        Master.SetPagingControls(sessionParams.totalRows);

        if (Master.IsClosestPointsSearchMode == true)
        {
            Master.RefreshMap(null, dsDoctors.Tables["Results"], doctorSearchParameters.MapInfo.CoordinatX, doctorSearchParameters.MapInfo.CoordinatY, true);
            ViewState["dsResults"] = dsDoctors;
        }
        else
        {
            ViewState["dsResults"] = null;
        }

        //extra flags

        //flag to show the map, the map is shown only if there is a grid visible, otherwise no point to 
        //show it
        Master.IsAllowShowMap_PageCondition = true;
    }

    protected void btnSort_Click(object sender, EventArgs e)
    {
        SortableColumnHeader columnToSortBy = sender as SortableColumnHeader;

        Session["RenewSearch"] = true;

        DataView dvCurrentResults = null;
        if (Master.IsClosestPointsSearchMode == true)
        {
            dvCurrentResults = ((DataTable)ViewState["currentGvDataView"]).DefaultView;
        }
        doctorSearchParameters = (DoctorSearchParameters)Session["doctorSearchParameters"];

        Master.ReSortResults(tdSortingButtons, columnToSortBy, dvCurrentResults, repDoctorList);
    }

    protected void ddlEmployeeSectorCode_SelectedIndexChanged(object sender, EventArgs e)
    {
        //if (ddlEmployeeSectorCode.SelectedIndex != 0)
        //{
        //    ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
        //    DataTable tblEmployeeSector = cacheHandler.getCachedDataTable(eCachedTables.EmployeeSector.ToString());
        //    DataRow[] dataRow = tblEmployeeSector.Select("EmployeeSectorCode = " + ddlEmployeeSectorCode.SelectedValue);
        //    int RelevantForProfession = Convert.ToInt32(dataRow[0]["RelevantForProfession"]);
        //    if (RelevantForProfession == 1)
        //    {
        //        txtProfessionList.Style.Add("display", "inline");
        //        lblProfessionCaption.Style.Add("display", "inline");
        //        btnProfessionListPopUp.Style.Add("display", "inline");
        //    }
        //    else
        //    {
        //        txtProfessionList.Style.Add("display", "none");
        //        lblProfessionCaption.Style.Add("display", "none");
        //        btnProfessionListPopUp.Style.Add("display", "none");

        //        txtProfessionList.Text = string.Empty;
        //        txtProfessionList_ToCompare.Text = string.Empty;
        //        txtProfessionListCodes.Text = string.Empty;
        //    }
        //}
        //else
        //{
        //    txtProfessionList.Style.Add("display", "inline");
        //    lblProfessionCaption.Style.Add("display", "inline");
        //    btnProfessionListPopUp.Style.Add("display", "inline");

        //    lblLicenseNumber.Style.Add("display", "inline");
        //    txtLicenseNumber.Style.Add("display", "inline");
        //}

        BindDdlPosition();


        if (ddlEmployeeSectorCode.SelectedIndex != 0 && ddlEmployeeSectorCode.SelectedIndex != 1)
        {
            tdSpeciality.Style.Add("display", "none");
            tdSpecialityLabel.Style.Add("display", "none");
            ddlExpert.SelectedValue = "-1";


        }
        else
        {
            tdSpeciality.Style.Add("display", "inline");
            tdSpecialityLabel.Style.Add("display", "inline");
        }

    }   


    #region gridview logic

    private void getParamsForQuery()
    {
        doctorSearchParameters = new DoctorSearchParameters();

        doctorSearchParameters.FirstName = txtFirstName.Text;
        doctorSearchParameters.LastName = txtLastName.Text;
        doctorSearchParameters.ServiceCode = txtProfessionListCodes.Text;
        doctorSearchParameters.ServiceText = txtProfessionList.Text;

        doctorSearchParameters.LanguageCode = txtLanguageListCodes.Text;
        doctorSearchParameters.LanguageText = txtLanguageList.Text;
        doctorSearchParameters.HandicappedFacilitiesCodes = txtHandicappedFacilitiesCodes.Text;
        doctorSearchParameters.HandicappedFacilitiesDescriptions = txtHandicappedFacilitiesList.Text;
        doctorSearchParameters.ReceiveGuests = cbNotReceiveGuests.Checked;

        doctorSearchParameters.QueueOrderMethodsAndOptions = txtQueueOrder.Text;
        doctorSearchParameters.QueueOrderMethodsAndOptionsCodes = txtQueueOrderCodes.Text;

        if (ddlExpert.SelectedIndex != -1)
        {
            doctorSearchParameters.ExpertProfession = Convert.ToInt32(ddlExpert.SelectedValue);
        }

        if (ddlEmployeeSectorCode.SelectedIndex != -1)
        {
            doctorSearchParameters.EmployeeSectorCode = Convert.ToInt32(ddlEmployeeSectorCode.SelectedValue);
            doctorSearchParameters.EmployeeSectorDescription = ddlEmployeeSectorCode.SelectedItem.Text;
        }

        if (ddlSex.SelectedIndex != -1)
        {
            doctorSearchParameters.Sex = Convert.ToInt32(ddlSex.SelectedValue);
        }

        if (ddlAgreementType.SelectedIndex != -1)
        {
            doctorSearchParameters.AgreementType = Enum.Parse(typeof(eDIC_AgreementTypes), ddlAgreementType.SelectedValue).GetHashCode();
        }

        if (ddlStatus.SelectedIndex != -1)
        {
            doctorSearchParameters.Status = Convert.ToInt32(ddlStatus.SelectedValue);
        }

        long employeeId = -1;
        if (long.TryParse(txtEmployeeID.Text.Trim(), out employeeId) == true)
        {
            doctorSearchParameters.EmployeeID = Convert.ToInt64(txtEmployeeID.Text.Trim());

        }

        int licenseNumber = -1;
        if (int.TryParse(txtLicenseNumber.Text.Trim(), out licenseNumber) == true)
        {
            doctorSearchParameters.LicenseNumber = licenseNumber;
        }

        if (ddlPosition.SelectedIndex != 0)
        {
            doctorSearchParameters.PositionCode = Convert.ToInt32(ddlPosition.SelectedValue);
            doctorSearchParameters.PositionDescription = ddlPosition.SelectedItem.Text;
        }


        Master.SetSearchParametersByControls(doctorSearchParameters);
        ClinicSearchParameters clinicSearchParameters;
        clinicSearchParameters = (ClinicSearchParameters)Session["clinicSearchParameters"];
        if (clinicSearchParameters != null)
            Master.SetSearchModeParameters(clinicSearchParameters);
        else
        {
            clinicSearchParameters = new ClinicSearchParameters();
            Master.SetSearchModeParameters(clinicSearchParameters);
        }
        Session["clinicSearchParameters"] = clinicSearchParameters;
        Session["doctorSearchParameters"] = doctorSearchParameters;

        if (Master.IsClosestPointsSearchMode == true)
        {
            Master.ResetSortingAndPaging(tdSortingButtons, null);
            Master.SetSortingByDistanceAsc();
        }
    }

    private void BindGridView()
    {
        Facade applicFacade = Facade.getFacadeObject();
        string SelectedCodesLis = string.Empty;

        if (Session["RenewSearch"] != null && Convert.ToBoolean(Session["RenewSearch"]) == true)
        {
            Session["AllSelectedCodesList"] = null;
            Session["RenewSearch"] = null;

            dsDoctors = applicFacade.getDoctorList_PagedSorted(doctorSearchParameters, Master.GetPagingAndSortingDBParams());

            Session["AllSelectedCodesList"] = dsDoctors.Tables["AllSelectedCodes"];

            if (dsDoctors != null)
            {
                if (Master.IsClosestPointsSearchMode == true)
                {
                    ViewState["currentGvDataView"] = dsDoctors.Tables["Results"];
                }
            }

            if (dsDoctors.Tables["RowsCount"] != null)
            {
                sessionParams = SessionParamsHandler.GetSessionParams();
                sessionParams.totalRows = Convert.ToInt32(dsDoctors.Tables["RowsCount"].Rows[0][0]);
                SessionParamsHandler.SetSessionParams(sessionParams);
            }
            else
            {
                sessionParams = SessionParamsHandler.GetSessionParams();
                sessionParams.totalRows = 0;
                SessionParamsHandler.SetSessionParams(sessionParams);
            }
        }
        else
        {
            if (Session["AllSelectedCodesList"] != null)
            {
                SearchPagingAndSortingDBParams searchPagingAndSortingDBParams = Master.GetPagingAndSortingDBParams();

                int pageSize = (int)searchPagingAndSortingDBParams.PageSize;

                int startingRow = ((int)searchPagingAndSortingDBParams.StartingPage - 1) * pageSize;

                DataTable dtSelectedCodes = (DataTable)Session["AllSelectedCodesList"];

                if (dtSelectedCodes.Rows.Count >= startingRow)
                {
                    int toRow = startingRow + pageSize - 1;

                    if (toRow > dtSelectedCodes.Rows.Count)
                        toRow = dtSelectedCodes.Rows.Count;

                    for (int i = startingRow; i < toRow; i++)
                    {
                        SelectedCodesLis = SelectedCodesLis + "," + Convert.ToString(dtSelectedCodes.Rows[i][0]);
                    }
                }

                dsDoctors = applicFacade.getDoctorList_PagedSorted(SelectedCodesLis, searchPagingAndSortingDBParams.IsOrderDescending, doctorSearchParameters.IsGetEmployeesReceptionInfo);
            }
        }

        foreach (DataRow dr in dsDoctors.Tables[0].Rows)
        {
            if (dr["IsCommunity"] == DBNull.Value)
                dr["IsCommunity"] = 0;

            if (dr["IsMushlam"] == DBNull.Value)
                dr["IsMushlam"] = 0;

            if (dr["IsHospital"] == DBNull.Value)
                dr["IsHospital"] = 0;

            if (dr["xcoord"] == DBNull.Value)
                dr["xcoord"] = 0;

            if (dr["ycoord"] == DBNull.Value)
                dr["ycoord"] = 0;

            if (dr["services"] == DBNull.Value)
                dr["services"] = string.Empty;

            if (dr["positions"] == DBNull.Value)
                dr["positions"] = string.Empty;

            if (dr["EmployeeLanguage"] == DBNull.Value)
                dr["EmployeeLanguage"] = string.Empty;

            if (dr["EmployeeLanguageDescription"] == DBNull.Value)
                dr["EmployeeLanguageDescription"] = string.Empty;

            if (dr["fax"] == DBNull.Value)
                dr["fax"] = string.Empty;

            if (dr["phone"] == DBNull.Value)
                dr["phone"] = string.Empty;

            if (dr["QueueOrderDescription"] == DBNull.Value)
                dr["QueueOrderDescription"] = string.Empty;
        }

        repDoctorList.DataSource = dsDoctors;
        repDoctorList.DataBind();
    }

    

    #endregion

    #region Paging events

    protected void btnNextPage_Click(object sender, EventArgs e)
    {
        Master.PagingControlsController.btnNextPage_Click(sender, e);
    }

    protected void btnFirstPage_Click(object sender, EventArgs e)
    {
        Master.PagingControlsController.btnFirstPage_Click(sender, e);
    }

    protected void btnLastPage_Click(object sender, EventArgs e)
    {
        Master.PagingControlsController.btnLastPage_Click(sender, e);
    }

    protected void btnPreviousPage_Click(object sender, EventArgs e)
    {
        Master.PagingControlsController.btnPreviousPage_Click(sender, e);
    }

    protected void ddlCarrentPage_SelectedIndexChanged(object sender, EventArgs e)
    {
        Master.PagingControlsController.ddlCarrentPage_SelectedIndexChanged(sender, e);
    }
    #endregion

    #region ISearchPageController Members

    public void LoadDataAndPopulate(bool isFromCache = false)
    {
        getParamsForQuery();
        BindGridView();
    }


    public int TotalNumberOfRecords
    {
        get
        {
            //if (dsDoctors != null && dsDoctors.Tables["rowsCount"] != null && dsDoctors.Tables["rowsCount"].Rows.Count > 0)
            //    return Convert.ToInt32(dsDoctors.Tables["rowsCount"].Rows[0][0]);
            //else
            //    return 0;

            sessionParams = SessionParamsHandler.GetSessionParams();

            if(sessionParams != null)
                return sessionParams.totalRows;
            else
                return 0;
        }
    }

    


    public SearchParametersBase PageSearchParameters
    {
        get { return doctorSearchParameters; }
    }

    public DataTable DTSearchResults
    {
        get
        {
            DataTable dtToReturn = null;
            if (dsDoctors != null && dsDoctors.Tables.Contains("Results") == true)
            {
                dtToReturn = dsDoctors.Tables["Results"];
            }
            return dtToReturn;
        }
    }

    #endregion

    private void ShowGridAndRelatedControls()
    {
        trPagingButtons.Style.Add("display", "inline");
        trSortingButtons.Style.Add("display", "inline");
        trSearchResults.Style.Add("display", "inline");

        if (doctorSearchParameters.CurrentReceptionTimeInfo != null
            && ((doctorSearchParameters.CurrentReceptionTimeInfo.FromHour != null && doctorSearchParameters.CurrentReceptionTimeInfo.FromHour != string.Empty)
                || (doctorSearchParameters.CurrentReceptionTimeInfo.InHour != null && doctorSearchParameters.CurrentReceptionTimeInfo.InHour != string.Empty)
                || doctorSearchParameters.CurrentReceptionTimeInfo.OpenNow == true
                || (doctorSearchParameters.CurrentReceptionTimeInfo.ReceptionDays != null && doctorSearchParameters.CurrentReceptionTimeInfo.ReceptionDays != string.Empty))
            )
        {
            //lblFromHour_ToHour_search_alert.Visible = true; /

            if (doctorSearchParameters.CurrentReceptionTimeInfo.FromHour != null && doctorSearchParameters.CurrentReceptionTimeInfo.FromHour != string.Empty)
            {

                lblReceptionParameters_With_FromHour_search_alert.Visible = true;
                lblReceptionParameters_WithNO_FromHour_search_alert.Visible = false;
            }
            else
            {
                lblReceptionParameters_With_FromHour_search_alert.Visible = false;
                lblReceptionParameters_WithNO_FromHour_search_alert.Visible = true;
            }
        }
        else
        {
            lblFromHour_ToHour_search_alert.Visible = false;
            lblReceptionParameters_With_FromHour_search_alert.Visible = false;
            lblReceptionParameters_WithNO_FromHour_search_alert.Visible = false;
        }
    }



    protected void setLablesColor(int statusType, HyperLink lnkDeptCode, HyperLink lnkToDoctor,
        Label lblAddress, Label lblCityName, Label lblPhone,
        Label lblEmployeeName, Label lblExpert, Label lblPositions)
    {
        string strColor = (statusType == 0 ? strNotActiveColor : strTemporaryNotActiveColor);

        lnkDeptCode.Style.Add("color", strColor);
        lnkToDoctor.Style.Add("color", strColor);
        lblAddress.Style.Add("color", strColor);
        lblCityName.Style.Add("color", strColor);
        lblPhone.Style.Add("color", strColor);
        lblEmployeeName.Style.Add("color", strColor);
        lblExpert.Style.Add("color", strColor);
        lblPositions.Style.Add("color", strColor);
    }
    
    
    protected void repDoctorList_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        DataRowView dvRowView = e.Item.DataItem as DataRowView;

        Label lbl = e.Item.FindControl("MapOrderNumber") as Label;
        if (Master.IsClosestPointsSearchMode == true)
        {
            lbl.Text = (e.Item.ItemIndex + 1).ToString();
            HtmlTableCell tc = e.Item.FindControl("tdMapOrder") as HtmlTableCell;
            tc.Style.Add("display", "block");
            tc = e.Item.FindControl("tdDocName") as HtmlTableCell;
            tc.Style.Remove("width");
            tc.Style.Add("width", "173px");
            tdMapHeader.Style.Add("width", "35px");
            tdDocNameHeader.Style.Add("width", "169px");
        }
        else
        {
            lbl.Visible = false;

            HtmlTableCell tc = e.Item.FindControl("tdMapOrder") as HtmlTableCell;
            tc.Style.Add("display", "none");
            tc = e.Item.FindControl("tdDocName") as HtmlTableCell;
            tc.Style.Remove("width");
            tc.Style.Add("width", "183px");
            tdMapHeader.Style.Add("width", "25px");
            tdDocNameHeader.Style.Add("width", "179px");
        }

        // handle scroll inside results div
        HyperLink lnkDeptCode = e.Item.FindControl("lnkDeptCode") as HyperLink;
        if (e.Item.ItemIndex == sessionParams.LastRowIndexOnSearchPage &&
                                            Request.QueryString["RepeatSearch"] != null)
        {
            Master.SetScrollToLastSearch(e.Item.FindControl("pnlLink"), lnkDeptCode);
            ((HtmlTableRow)e.Item.FindControl("trDoctor")).Attributes.Remove("class");
            ((HtmlTableRow)e.Item.FindControl("trDoctor")).Attributes.Add("class", "trPlain_marked");

        }

        Image imgMap = e.Item.FindControl("imgMap") as Image;
        SearchPageHelper.PrepareGridRowMapData(dvRowView, e.Item.ItemIndex, imgMap, doctorSearchParameters.MapInfo.CoordinatX,
                                                                    doctorSearchParameters.MapInfo.CoordinatY, repDoctorList.ClientID, Master.IsClosestPointsSearchMode);

        string rowIdentifierUrl = "&index=" + e.Item.ItemIndex + "&searchId=" + Master.uniqueSearchParamater;

        lnkDeptCode.NavigateUrl = "Public/ZoomClinic.aspx?DeptCode=" + dvRowView["deptCode"].ToString() + rowIdentifierUrl;

        Image imgReception = e.Item.FindControl("imgReception") as Image;
        currDeptCode = Convert.ToInt32(dvRowView["deptCode"]);
        currEmployeeID = Convert.ToInt64(dvRowView["EmployeeID"]);
        deptEmployeeID = Convert.ToInt32(dvRowView["deptEmployeeID"]);
        currRowNumber = Convert.ToInt32(dvRowView["RowNumber"]);
        bool doctorHasReceptionHours = (Convert.ToInt32(dvRowView["HasReception"]) > 0 ? true : false);
        bool doctorHasRemarks = (Convert.ToInt32(dvRowView["HasRemarks"]) > 0 ? true : false);
        UIHelper.setClockRemarkImage(imgReception, doctorHasReceptionHours, doctorHasRemarks, "Green",
            "OpenReceptionWindow(" + deptEmployeeID + ")",
            "הקש להצגת שעות קבלה", "הקש להצגת הערות", "הקש להצגת שעות קבלה והערות");

        Image imgReceiveGuests = e.Item.FindControl("imgReceiveGuests") as Image;

        if (Convert.ToInt32(dvRowView["ReceiveGuests"]) == 1)
        {
            imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuests.png";
            imgReceiveGuests.ToolTip = "הרופא מקבל אורחים";
        }
        else if (Convert.ToInt32(dvRowView["ReceiveGuests"]) == 0)
        {
            imgReceiveGuests.ImageUrl = "~/Images/Applic/NOTreceiveGuests.png";
            imgReceiveGuests.ToolTip = "הרופא אינו מקבל אורחים";
        }
        else if (Convert.ToInt32(dvRowView["ReceiveGuests"]) == 2)
        {
            imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuestsPartTime.png";
            imgReceiveGuests.ToolTip = "הרופא מקבל אורחים לפעמים";
        }
        else if (Convert.ToInt32(dvRowView["ReceiveGuests"]) == -1)
        {
            imgReceiveGuests.Visible = false;
        }

        Image imgPhoneRemark = e.Item.FindControl("imgPhoneRemark") as Image;

        if (dvRowView.Row.Table.Columns["remark"] != null)
        {
            if (dvRowView["remark"] != DBNull.Value && dvRowView["remark"].ToString() != string.Empty)
            {
                imgPhoneRemark.ImageUrl = "~/Images/Applic/phone_remark.png";
                imgPhoneRemark.ToolTip = dvRowView["remark"].ToString();
            }
            else
            {
                imgPhoneRemark.Visible = false;
            }
        }
        else
        {
            imgPhoneRemark.Visible = false;
        }

        HyperLink lnkEmployeeName = e.Item.FindControl("lnkEmployeeName") as HyperLink;
        lnkEmployeeName.NavigateUrl = "Public/ZoomDoctor.aspx?EmployeeID=" + currEmployeeID + rowIdentifierUrl;
        Label lblEmployeeName = e.Item.FindControl("lblEmployeeName") as Label;
        if (Convert.ToInt16(dvRowView["IsMedicalTeam"]) == 1 || Convert.ToInt16(dvRowView["IsVirtualDoctor"]) == 1)
        {
            lnkEmployeeName.Style.Add("display", "none");

            lblEmployeeName.Visible = true;
        }

        rowStatus = int.Parse(dvRowView["EmployeeStatusInDept"].ToString());
        if (rowStatus != 1)
        {
            Label lblAddress = e.Item.FindControl("lblAddress") as Label;
            Label lblCityName = e.Item.FindControl("lblCityName") as Label;
            Label lblPhone = e.Item.FindControl("lblPhone") as Label;
            Label lblExpert = e.Item.FindControl("lblExpert") as Label;
            Label lblPositions = e.Item.FindControl("lblPositions") as Label;

            setLablesColor(rowStatus, lnkDeptCode, lnkEmployeeName, lblAddress, lblPhone, lblCityName, lblEmployeeName, lblExpert, lblPositions);
        }

        Label lblTemporarilyInactive = e.Item.FindControl("lblTemporarilyInactive") as Label;

        if (rowStatus != 2) // Temporarily Inactive
        {
            lblTemporarilyInactive.Style.Add("display", "none");
        }

        #region Queue Order

        DataView dvQueueOrders = new DataView(dsDoctors.Tables["QueueOrderMethods"], "DeptCode=" + currDeptCode +
                                                    " AND EmployeeID=" + currEmployeeID, string.Empty, DataViewRowState.OriginalRows);
        DataTable distinctValues = dvQueueOrders.ToTable(true, "QueueOrder", "QueueOrderDescription", "Marker", "RowNumber");

        GridView gvQueueOrderCombinations = e.Item.FindControl("gvQueueOrderCombinations") as GridView;
        gvQueueOrderCombinations.DataSource = distinctValues;
        gvQueueOrderCombinations.DataBind();

        #endregion

        Image imgAgreementType = e.Item.FindControl("imgAgreementType") as Image;
        if (dvRowView["AgreementType"] != DBNull.Value)
        {
            eDIC_AgreementTypes agreement = (eDIC_AgreementTypes)Enum.Parse(typeof(eDIC_AgreementTypes),
                                                                        dvRowView["AgreementType"].ToString());

            UIHelper.SetImageForAgreementType(agreement, imgAgreementType);
        }

        Image imgRecComm = e.Item.FindControl("imgRecepAndComment") as Image; // for clinic reception  hours & remarks

        bool clinicHasReceptionHours = (Convert.ToInt32(dvRowView["countReception"]) > 0 ? true : false);
        bool clinicHasRemarks = (Convert.ToInt32(dvRowView["countDeptRemarks"]) > 0 ? true : false);

        //if (Convert.ToInt32(currentRow["ShowRemarkPicture"]) > 0 && Convert.ToInt32(currentRow["ShowRemarkPicture"]) < 4)
        //{
        //    clinicHasRemarks = true;
        //}

        string ServiceCodes = "0";
        if (doctorSearchParameters.ServiceCode != null && doctorSearchParameters.ServiceCode != string.Empty)
        {
            ServiceCodes = doctorSearchParameters.ServiceCode;
        }

        UIHelper.setClockRemarkImage(imgRecComm, clinicHasReceptionHours, clinicHasRemarks, "Blue",
        "return OpenReceptionWindowDialog(" + currDeptCode.ToString() + ",'" + ServiceCodes + "')",
        "הקש להצגת שעות קבלה", "הקש להצגת הערות", "הקש להצגת שעות קבלה והערות");

        if (dvRowView.DataView.Table.Columns.Contains("IsCommunity"))
        { 
            Image imgAttributed = e.Item.FindControl("imgAttributed") as Image;

            bool isCommunity = (bool)dvRowView["IsCommunity"];
            bool isMushlam = (bool)dvRowView["IsMushlam"];
            bool isHospital = (bool)dvRowView["isHospital"];

            int subUnitTypeCode = (int)dvRowView["subUnitTypeCode"];

            UIHelper.SetImageForDeptAttribution(ref imgAttributed, isCommunity, isMushlam, isHospital, subUnitTypeCode);        
        }

    }

    protected void gvQueueOrderCombinations_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.RowIndex > 0)
            {
                HtmlTableCell tdProfessions = e.Row.FindControl("tdProfessions") as HtmlTableCell;
                tdProfessions.Style.Add("border-top", "1px solid #cfe9bd");

                HtmlTableCell tdQueueOrder = e.Row.FindControl("tdQueueOrder") as HtmlTableCell;
                tdQueueOrder.Style.Add("border-top", "1px solid #cfe9bd");
            }

            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            string marker = dvRowView["marker"].ToString();

            // make DataSource for Professions and bind it to "gvProfessions"
            GridView gvProfessions = e.Row.FindControl("gvProfessions") as GridView;

            DataView dvProfessions = new DataView(dsDoctors.Tables["QueueOrderMethods"], string.Format("DeptCode={0} AND EmployeeID={1} AND Marker='{2}'", currDeptCode, currEmployeeID, marker), string.Empty, DataViewRowState.OriginalRows);

            DataTable tdProf = dvProfessions.ToTable(true, "ServiceDescription");

            gvProfessions.DataSource = tdProf;
            gvProfessions.DataBind();

            if (dvRowView["QueueOrder"] != DBNull.Value && Convert.ToInt16(dvRowView["QueueOrder"]) != 3)
            {
                Label lblQueueOrder = e.Row.FindControl("lblQueueOrder") as Label;
                lblQueueOrder.Visible = true;
                lblQueueOrder.Text = dvRowView["QueueOrderDescription"].ToString();
            }
            else
            {
                //DataView dvQueueOrders = new DataView(dsDoctors.Tables["QueueOrderMethods"], "DeptCode=" + currDeptCode +
                //                                         " AND EmployeeID=" + currEmployeeID, string.Empty, DataViewRowState.OriginalRows);

                List<int> queueOrders = (from queueOrder in dsDoctors.Tables["QueueOrderMethods"].AsEnumerable()
                                         where queueOrder.Field<long>("employeeID") == currEmployeeID
                                            && queueOrder.Field<int>("deptCode") == currDeptCode
                                            && queueOrder.Field<string>("Marker") == marker
                                         select queueOrder.Field<int>("QueueOrderMethod")).ToList();


                if (queueOrders.Count > 0)
                {
                    Literal litQueueOrder = e.Row.FindControl("litQueueOrder") as Literal;
                    Label lblDeptEmployeeQueueOrderPhones = e.Row.FindControl("lblDeptEmployeeQueueOrderPhones") as Label;

                    litQueueOrder.Text = UIHelper.GetInnerHTMLForQueueOrder(queueOrders,
                                                "tblQueueOrderPhonesAndHours" + currRowNumber.ToString() + "_" + marker, null, null);

                    DataView dvPhones = new DataView(dsDoctors.Tables["QueueOrderMethods"], string.Format("DeptCode={0} AND EmployeeID={1} AND Marker='{2}'", currDeptCode, currEmployeeID, marker), string.Empty, DataViewRowState.OriginalRows);
                    DataTable distinctPhones = dvPhones.ToTable(true, "DeptPhone", "Marker");
                    DataRow[] phonesArr = distinctPhones.Select();
                    //if (phonesArr.Length > 0 && phonesArr[0]["DeptPhone"].ToString() != string.Empty)
                    //{
                    //    lblDeptEmployeeQueueOrderPhones.Text = phonesArr[0]["DeptPhone"].ToString();
                    //}

                    //DataTable distinctQOPhones = dvPhones.ToTable(true, "QueueOrderPhone", "Marker");
                    //phonesArr = distinctQOPhones.Select();

                    if (phonesArr.Length > 0 && phonesArr[0]["DeptPhone"].ToString() != string.Empty)
                    {
                        for (int i = 0; i < phonesArr.Length; i++)
                        {
                            if (!string.IsNullOrEmpty(lblDeptEmployeeQueueOrderPhones.Text))
                            {
                                lblDeptEmployeeQueueOrderPhones.Text += ", ";
                            }

                            lblDeptEmployeeQueueOrderPhones.Text += phonesArr[i]["DeptPhone"].ToString();
                        }

                        //if (!string.IsNullOrEmpty(lblDeptEmployeeQueueOrderPhones.Text))
                        //{
                        //    lblDeptEmployeeQueueOrderPhones.Text += ", ";
                        //}

                        //lblDeptEmployeeQueueOrderPhones.Text = phonesArr[0]["QueueOrderPhone"].ToString();

                        GridView gvQueueOrderHours = e.Row.FindControl("gvDeptEmployeeQueueOrderHours") as GridView;

                        DataView dvQueueOrderHours = new DataView(dsDoctors.Tables["QueueOrderMethods"], "DeptCode=" + currDeptCode +
                                      " AND EmployeeID=" + currEmployeeID + " AND Marker=" + marker + " AND FromHour IS NOT NULL"
                                      , string.Empty, DataViewRowState.OriginalRows);
                        DataTable distinctQueueOrderHours = dvQueueOrderHours.ToTable(true, "ReceptionDayName", "FromHour", "ToHour", "Marker");

                        gvQueueOrderHours.DataSource = distinctQueueOrderHours;
                        gvQueueOrderHours.DataBind();

                    }
                }

            }

        }

    }

    protected void gvProfessions_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            switch (rowStatus)
            { 
                case 0:
                    e.Row.Cells[0].Attributes.CssStyle.Add("color", strNotActiveColor);
                    break;
                case 2:
                    e.Row.Cells[0].Attributes.CssStyle.Add("color", strTemporaryNotActiveColor);
                    break;
            }

        }
    }

    private void sendErrorToEmail(string functionName, string exception)
    {
        try
        {
            string developersEmails = ConfigurationManager.AppSettings["DevelopersEmail"];

            string[] developersEmailsArray = developersEmails.Split(';');

            List<string> developersEmailsList = new List<string>();

            if (developersEmailsArray.Length > 0)
            {
                foreach (string item in developersEmailsArray)
                {
                    if (isEmailValid(item))
                    {
                        developersEmailsList.Add(item);
                    }
                }
            }

            if (developersEmailsList.Count > 0)
            {
                new System.Threading.Thread(() =>
                {
                    string userEmail = String.Empty;

                    SeferNet.BusinessLayer.BusinessObject.UserInfo userInfo = (SeferNet.BusinessLayer.BusinessObject.UserInfo)Session["currentUser"];

                    try
                    {
                        userInfo = (SeferNet.BusinessLayer.BusinessObject.UserInfo)Session["currentUser"];
                    }
                    catch
                    {
                        userInfo = null;
                    }

                    if (userInfo != null)
                    {
                        userEmail = userInfo.Mail;
                    }

                    SeferNet.BusinessLayer.WorkFlow.EmailHandler.SendEmail("Error in " + functionName, "User " + userEmail + " got an error.<br/><br/>" + exception, "sefernet@clalit.org.il", developersEmailsList, "", "", "", System.Text.Encoding.UTF8);

                }).Start();
            }
        }
        catch
        {

        }
    }

    bool isEmailValid(string email)
    {
        Regex regex = new Regex(@"^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$");
        Match match = regex.Match(email);
        if (match.Success) return true;
        else return false;
    }
}

