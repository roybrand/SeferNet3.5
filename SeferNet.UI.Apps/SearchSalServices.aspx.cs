using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using Clalit.SeferNet.GeneratedEnums;
using SeferNet.BusinessLayer.BusinessObject;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;
using MapsManager;
using SeferNet.Globals;
using SeferNet.BusinessLayer.WorkFlow;
using Clalit.Infrastructure.ServicesManager;
using Clalit.Infrastructure.ServiceInterfaces;
using System.Data;
using SeferNet.FacadeLayer;
using System.Web.Services;
using System.Web.UI.HtmlControls;

public partial class SearchSalServices : System.Web.UI.Page
{
    #region Paging Properties & Fields

    private SortingAndPagingParameters _sortingAndPagingParameters;
    public SortingAndPagingParameters sortingAndPagingParameters
    {
        get
        {
            if (this.Session["SortingAndPagingParameters"] != null)
            {
                this._sortingAndPagingParameters = (SortingAndPagingParameters)this.Session["SortingAndPagingParameters"];
                return this._sortingAndPagingParameters;
            }
            else
            {
                this._sortingAndPagingParameters = new SortingAndPagingParameters();
                this.Session["SortingAndPagingParameters"] = this._sortingAndPagingParameters;
                return this._sortingAndPagingParameters;
            }
        }
        set
        {
            this._sortingAndPagingParameters = value;
            this.Session["SortingAndPagingParameters"] = this._sortingAndPagingParameters;
        }
    }

    public int totalPages
    {
        get
        {
            int retVal = 0;

            if (this.pageSize > 0)
            {
                retVal = this.totalRecords / this.pageSize;
                if ((retVal * this.pageSize) < this.totalRecords)
                    retVal += 1;
            }

            return retVal;
        }
    }

    public int totalRecords
    {
        get
        {
            if (this.ViewState["totalRecords"] != null && this.ViewState["totalRecords"] is int)
                return (int)this.ViewState["totalRecords"];
            else
                return 0;
        }
        set
        {
            this.ViewState["totalRecords"] = value;
        }
    }

    public int pageSize { get; set; }

    /// <summary>
    ///  Gets or Sets the real page index number ( index starting from 0) 
    /// </summary>
    public int CurrentPageIndex
    {
        get
        {
            if (this.ViewState["CurrentPageIndex"] != null && this.ViewState["CurrentPageIndex"] is int)
                return (int)this.ViewState["CurrentPageIndex"];
            else
                return 0;
        }
        set
        {
            this.ViewState["CurrentPageIndex"] = value;
        }
    }

    /// <summary>
    ///  Gets or Sets the real page number (real page numebr starts from 0!) 
    /// </summary>
    public int currentPage
    {
        get
        {
            return this.CurrentPageIndex + 1;
        }
        set
        {
            this.CurrentPageIndex = value - 1;
        }
    }

    private SelectedSalServicesTab selectedTab;
    public SelectedSalServicesTab SelectedTab
    {
        get
        {
            if (this.ViewState["SelectedTab"] != null)
                return (SelectedSalServicesTab)this.ViewState["SelectedTab"];
            else
            {
                if (!this.SessionParams.IsEmpty && !string.IsNullOrEmpty(this.Request.QueryString["RepeatSearch"]) )
                {
                    if (this.SessionParams.LastSelectedTabOnSearchPage == 1)
                    {
                        this.SelectedTab = SelectedSalServicesTab.SalServices;
                    }
                    else if (this.SessionParams.LastSelectedTabOnSearchPage == 2)
                    {
                        this.SelectedTab = SelectedSalServicesTab.Populations;
                    }
                }

                if (this.selectedTab == null || this.selectedTab == 0)
                {
                    this.ViewState["SelectedTab"] = SelectedSalServicesTab.SalServices;
                    this.selectedTab = SelectedSalServicesTab.SalServices;
                }

                return this.selectedTab;
            }
        }
        set
        {
            this.selectedTab = value;
            this.ViewState["SelectedTab"] = value;
        }
    }

    public enum SelectedSalServicesTab
    {
        SalServices = 1,
        Populations = 2,
        NewTests = 3
    }

    #endregion

    #region Public permissions members

    public bool IsAdministrator = false;
    public bool CanManageTarifonViews = false;
    public bool CanViewTarifon = false;
    public bool CanManageInternetSalServices = false;

    #endregion

    public SessionParams_SalServices SessionParams
    {
        get
        {
            if (this.Session["SessionParams_SalServices"] == null)
                this.Session["SessionParams_SalServices"] = new SessionParams_SalServices();

            return (SessionParams_SalServices)this.Session["SessionParams_SalServices"];
        }
    }

    static string _DefaltPageName;

    static SearchSalServices()
    {
        _DefaltPageName = SearchPageStatusParameters.GetDefaultPageName();
    }

    string highlightedSearhTab = "HighlightedSearhTab";
    string notHighlightedSearhTab = "NotHighlightedSearhTab";
    string multiLineLabelCss = "MultiLineLabel";
    string HighlightedSearhTabRight = "HighlightedSearhTabRight";
    string HighlightedSearhTabLeft = "HighlightedSearhTabLeft";
    string NotHighlightedSearhTabRight = "NotHighlightedSearhTabRight";
    string NotHighlightedSearhTabLeft = "NotHighlightedSearhTabLeft";
    string NotHighlightedSearhTabMiddle = "NotHighlightedSearhTabMiddle";
    string HighlightedSearhTabMiddle = "HighlightedSearhTabMiddle";
    string TDNotHighlightedSearchTab = "TDNotHighlightedSearchTab";
    string TDHighlightedSearchTab = "TDHighlightedSearchTab";
    bool canManageInternet = false;

    #region SearchPageStatusParameters


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
    }

    public void ResetLastSelectedRowIndex()
    {
        SessionParamsHandler.GetSessionParams().LastRowIndexOnSearchPage = -1;
    }

    #endregion

    protected void Page_Prerender(object sender, EventArgs e)
    {
        SessionParamsHandler.SetLastSearchPageURL("SearchSalServices.aspx");

        if(Session[ConstsSession.IS_POST_BACK_AFTER_LOGIN_LOGOUT] != null && Session[ConstsSession.IS_POST_BACK_AFTER_LOGIN_LOGOUT].ToString() != string.Empty)
            this.BindGridView_PagedSorted();

        // Open PopUp on page first visit
        //if (Session["ShowEnterSalServicesPopUp"] == null)
        //{
        //    Session["ShowEnterSalServicesPopUp"] = false;
        //    ScriptManager.RegisterStartupScript(this.UpdatePanelTop, this.GetType(), "ShowEnterSalServicesPopUp", "ShowEnterSalServicesPopUp();", true);
        //}
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (ConfigurationManager.AppSettings["PageSizeForSearchPages"] != null)
            this.pageSize = int.Parse(ConfigurationManager.AppSettings["PageSizeForSearchPages"].ToString());
        else
            this.pageSize = 50;

        this.checkPermissionToViewPage();

        SetRbConditions();

        ScriptManager.RegisterStartupScript(this.UpdatePanelTop, this.GetType(), "SetDateControls", "SetDateControls();", true);

        if (!this.IsPostBack)
        {
            this.aSearchClinics.Attributes.Add("class", this.notHighlightedSearhTab);
            this.tdClinicInnerTdLeft.Attributes["class"] = this.NotHighlightedSearhTabLeft;
            this.tdClinicInnerTdRight.Attributes["class"] = this.NotHighlightedSearhTabRight;
            this.tdClinicInnerTdMiddle.Attributes["class"] = this.NotHighlightedSearhTabMiddle;
            this.tdClinicTab.Attributes["class"] = this.TDNotHighlightedSearchTab;

            this.aSearchDoctors.Attributes.Add("class", this.notHighlightedSearhTab);
            this.tdDoctorInnerTdLeft.Attributes["class"] = this.NotHighlightedSearhTabLeft;
            this.tdDoctorInnerTdRight.Attributes["class"] = this.NotHighlightedSearhTabRight;
            this.tdDoctorInnerTdMiddle.Attributes["class"] = this.NotHighlightedSearhTabMiddle;
            this.tdDoctorTab.Attributes["class"] = this.TDNotHighlightedSearchTab;

            this.aSearchSalServices.Attributes.Add("class", this.highlightedSearhTab);
            this.tdSalServicesInnerTdLeft.Attributes["class"] = this.HighlightedSearhTabLeft;
            this.tdSalServicesInnerTdRight.Attributes["class"] = this.HighlightedSearhTabRight;
            this.tdSalServicesInnerTdMiddle.Attributes["class"] = this.HighlightedSearhTabMiddle;
            this.tdSalServiceTab.Attributes["class"] = this.TDHighlightedSearchTab;

            int tryResult;

            if (!string.IsNullOrEmpty(this.Request.QueryString["RepeatSearch"]))
            {
                this.CheckSessionParams();

                this.Need2RebindGrid = true;

                this.SetVisibilityTabsPanels();
                this.BindGridView_PagedSorted();

                this.divSalServicesSearchResults.Style[HtmlTextWriterStyle.PaddingTop] = "16px";
            }
            else if (!string.IsNullOrEmpty(this.Request.QueryString["AdvanceSearchText"])
                    || (!string.IsNullOrEmpty(this.Request.QueryString["ServiceCode"]) && int.TryParse(this.Request.QueryString["ServiceCode"].ToString(), out tryResult))
                    || !string.IsNullOrEmpty(this.Request.QueryString["HealthOfficeCode"]))
            {
                if(!string.IsNullOrEmpty(this.Request.QueryString["AdvanceSearchText"]))
                {
                    this.txtExtendedSearch.Text = HttpUtility.UrlDecode(this.Request.QueryString["AdvanceSearchText"].ToString());
                }

                if (!string.IsNullOrEmpty(this.Request.QueryString["ServiceCode"]))
                {
                    if(int.TryParse(this.Request.QueryString["ServiceCode"].ToString(), out tryResult) == true)
                    {
                        this.txtClalitServiceCode.Text = tryResult.ToString();
                        this.txtClalitServiceCode_TextChanged(null, null);
                    }
                }

                if (!string.IsNullOrEmpty(this.Request.QueryString["HealthOfficeCode"]))
                {
                    this.txtHealthOfficeCode.Text = this.Request.QueryString["HealthOfficeCode"].ToString();
                }
                //------------------------------------------------
                this.Need2RebindGrid = true;

                this.SetVisibilityTabsPanels();
                this.BindGridView_PagedSorted();

                this.divSalServicesSearchResults.Style[HtmlTextWriterStyle.PaddingTop] = "16px";

            }
            else { }

            this.BindDefaultView();

            // set DataSet for "Search Sal Services report" to null not to show results left from the previous search
            if (string.IsNullOrEmpty(this.Request.QueryString["RepeatSearch"]))
            {
                Session["SalServicesDataSet"] = null;
            }
        }
        else
        {
            this.SetVisibilityTabsPanels();
            this.pAdminComments.Visible = false;
        }

        if (this.IsPostBack)
            this.divSalServicesSearchResults.Style[HtmlTextWriterStyle.PaddingTop] = "";

        var sessionParams = SessionParamsHandler.GetSessionParams();
        sessionParams.DeptCode = -1;
        sessionParams.EmployeeID = -1;
        sessionParams.CallerUrl = Request.Url.OriginalString;
        sessionParams.CurrentEntityToReport = Enums.IncorrectDataReportEntity.SalService;

        SessionParamsHandler.SetSessionParams(sessionParams);
    }
    void SetRbConditions()
    {
        if (!Page.IsPostBack)
        {
            rbConditions.Items.Add(new ListItem("נכון להיום", Enums.SalServicesSearchConditions.CurrentDay.ToString()));
            rbConditions.Items.Add(new ListItem("עודכנו", Enums.SalServicesSearchConditions.BasketApproveDate.ToString()));
            rbConditions.Items.Add(new ListItem("נוספו", Enums.SalServicesSearchConditions.AddedDate.ToString()));
            rbConditions.Items.Add(new ListItem("בוטלו", Enums.SalServicesSearchConditions.CanceledDate.ToString()));
            if (canManageInternet)
                rbConditions.Items.Add(new ListItem("עודכנו לאינטרנט", Enums.SalServicesSearchConditions.InternetUpdatedDate.ToString()));
            rbConditions.SelectedValue = Enums.SalServicesSearchConditions.CurrentDay.ToString();
        }
        else
        {
            if (canManageInternet)
            {
                if (rbConditions.Items.FindByValue(Enums.SalServicesSearchConditions.InternetUpdatedDate.ToString()) == null)
                    rbConditions.Items.Add(new ListItem("עודכנו לאינטרנט", Enums.SalServicesSearchConditions.InternetUpdatedDate.ToString()));
            }
            else
            {
                if (rbConditions.Items.FindByValue(Enums.SalServicesSearchConditions.InternetUpdatedDate.ToString()) != null)
                {
                    if (rbConditions.SelectedValue == Enums.SalServicesSearchConditions.InternetUpdatedDate.ToString())
                        rbConditions.SelectedValue = Enums.SalServicesSearchConditions.CurrentDay.ToString();
                    ListItem LI = new ListItem("עודכנו לאינטרנט", Enums.SalServicesSearchConditions.InternetUpdatedDate.ToString());
                    rbConditions.Items.Remove(LI);

                }
            }
        }

    }
    private void checkPermissionToViewPage()
    {
        UserManager userManager = new UserManager();
        UserInfo currentUserInfo = userManager.GetUserInfoFromSession();

        if (currentUserInfo != null && this.User.Identity.IsAuthenticated)
        {
            this.IsAdministrator = currentUserInfo.IsAdministrator;
            this.CanManageTarifonViews = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageTarifonViews, -1);
            this.CanViewTarifon = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ViewTarifon, -1);
            this.CanManageInternetSalServices = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageInternetSalServices, -1);

            //if (!currentUserInfo.IsAdministrator && !currentUserInfo.HasDistrictPermission && !canManageTarifonViews && !canViewTarifon)
            //{
            //    this.Response.Redirect("SearchClinics.aspx");
            //}

            //this.tabPopulations.Visible = (canViewTarifon || canManageTarifonViews || currentUserInfo.IsAdministrator);
            //this.tabPopulations.Visible = (canViewTarifon || canManageTarifonViews || currentUserInfo.IsAdministrator);

            if (this.CanManageInternetSalServices || this.IsAdministrator)
            {
                this.phInternetDetails1.Visible = true;
                this.phInternetDetails2.Visible = true;
                canManageInternet = true;
            }
            else
            { 
                this.phInternetDetails1.Visible = false;
                this.phInternetDetails2.Visible = false;
                canManageInternet = false;
            }
        }
        else
        {
            this.phInternetDetails1.Visible = false;
            this.phInternetDetails2.Visible = false;
            canManageInternet = false;
        }

        if (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator)
            this.pPopulationsHeaderGrid.Width = Unit.Pixel(1816);
        else
            //this.pPopulationsHeaderGrid.Width = Unit.Pixel(970);
            this.pPopulationsHeaderGrid.Width = Unit.Pixel(970);

        if (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator)
            this.pPopulationsGrid.Width = Unit.Pixel(1816);
        else
            this.pPopulationsGrid.Width = Unit.Pixel(970);

        //if (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator)
        //    tblPopulationsGrid.Style[HtmlTextWriterStyle.Width] = "1800px";
        //else
        //    tblPopulationsGrid.Style[HtmlTextWriterStyle.Width] = "7800px";
    }

    private void BindDefaultView()
    {
        if (this.phInternetDetails1.Visible && this.phInternetDetails2.Visible)
        {
            // Bind internet categories:
            Facade applicFacade = Facade.getFacadeObject();
            DataSet dsSalCategories = applicFacade.GetSalCategories(null, string.Empty);
            if (dsSalCategories != null && dsSalCategories.Tables.Count > 0 && dsSalCategories.Tables[0].Rows.Count > 0)
            {
                this.ddlSalCategory.DataSource = dsSalCategories;
                this.ddlSalCategory.DataBind();
                this.ddlSalCategory.Items.Insert(0 , new ListItem("" , "0"));
            }

            // Bind body organs:
            DataSet dsBodyOrgans = applicFacade.GetSalBodyOrgans();
            if (dsBodyOrgans != null && dsBodyOrgans.Tables.Count > 0 && dsBodyOrgans.Tables[0].Rows.Count > 0)
            {
                this.ddlBodyOrgan.DataSource = dsBodyOrgans;
                this.ddlBodyOrgan.DataBind();
            }
        }

        #region Admin Comments - Vadim Rasin 16/10/13

        // Make sure the user hasn't pressed back button - if he did no message should be displayed.
        if (string.IsNullOrEmpty(this.Request.QueryString["RepeatSearch"]))
        {
            string title = null;

            string comment = null;

            DateTime? startDate = new DateTime?();

            DateTime? expiredDate = DateTime.Now;

            byte? active = 1;

            DataSet dsAdminComments = Facade.getFacadeObject().GetAdminCommentsForSalServices(title, comment, startDate, expiredDate, active);

            if (dsAdminComments != null && dsAdminComments.Tables[0].Rows.Count > 0)
            {
                foreach (DataRow dr in dsAdminComments.Tables[0].Rows)
                {
                    dr["Comment"] = dr["Comment"].ToString().Replace("\n", "<br/>");
                }
                this.rAdminComments.DataSource = dsAdminComments;
                this.rAdminComments.DataBind();
            }
            else
            {
                this.pAdminComments.Visible = false;
            }
        }
        else
        {
            this.pAdminComments.Visible = false;
        }

        #endregion
    }

    private void CheckSessionParams()
    {
        if (this.SessionParams != null && !this.SessionParams.IsEmpty)
        {
            if (this.SessionParams.IncludeInBasket.HasValue)
                if (this.ddlSalIncluded.Items.FindByValue(this.SessionParams.IncludeInBasket.Value.ToString()) != null)
                    this.ddlSalIncluded.SelectedValue = this.SessionParams.IncludeInBasket.Value.ToString();

            if (this.SessionParams.Common.HasValue)
                if (this.ddlCommon.Items.FindByValue(this.SessionParams.Common.Value.ToString()) != null)
                    this.ddlCommon.SelectedValue = this.SessionParams.Common.Value.ToString();

            //if (this.SessionParams.Limiter.HasValue)
            //    if (this.ddlLimiter.Items.FindByValue(this.SessionParams.Limiter.Value.ToString()) != null)
            //        this.ddlLimiter.SelectedValue = this.SessionParams.Limiter.Value.ToString();

            if (this.SessionParams.ShowServiceInInternet.HasValue)
                if (this.ddlInternet.Items.FindByValue(this.SessionParams.ShowServiceInInternet.Value.ToString()) != null)
                    this.ddlInternet.SelectedValue = this.SessionParams.ShowServiceInInternet.Value.ToString();

            if (this.SessionParams.IsActive.HasValue)
                if (this.ddlIsActive.Items.FindByValue(this.SessionParams.IsActive.Value.ToString()) != null)
                    this.ddlIsActive.SelectedValue = this.SessionParams.IsActive.Value.ToString();

            if (!string.IsNullOrEmpty(this.SessionParams.AdvanceSearchText))
                this.txtExtendedSearch.Text = this.SessionParams.AdvanceSearchText;

            if (this.SessionParams.ServiceCode.HasValue)
            {
                this.txtClalitServiceCode.Text = this.SessionParams.ServiceCode.Value.ToString();
                this.txtClalitServiceCode_TextChanged(null, null);
            }

            if (!string.IsNullOrEmpty(this.SessionParams.ServiceName))
                this.txtClalitServiceDesc.Text = this.SessionParams.ServiceName;

            if (!string.IsNullOrEmpty(this.SessionParams.HealthOfficeCode))
                this.txtHealthOfficeCode.Text = this.SessionParams.HealthOfficeCode;

            if (!string.IsNullOrEmpty(this.SessionParams.HealthOfficeDesc))
                this.txtHealthOfficeDesc.Text = this.SessionParams.HealthOfficeDesc;

            if (!string.IsNullOrEmpty(this.SessionParams.GroupCodes))
            {
                // Check if its one group or more.
                if (this.SessionParams.GroupCodes.IndexOf(",") > -1)
                {
                    this.txtGroupsListCodes.Text = this.SessionParams.GroupCodes;
                    this.txtGroupsList.Text = this.SessionParams.GroupDescription;
                    this.txtGroupsList_ToCompare.Text = this.SessionParams.GroupDescription;
                }
                else
                {
                    this.txtGroupCode.Text = this.SessionParams.GroupCodes;
                    this.txtGroupCode_TextChanged(null, null);
                }
            }

            if (!string.IsNullOrEmpty(this.SessionParams.ProfessionCodes))
            {
                // Check if its one group or more.
                if (this.SessionParams.ProfessionCodes.IndexOf(",") > -1)
                {
                    this.txtProfessionsListCodes.Text += this.SessionParams.ProfessionCodes;
                    this.txtProfessionsList.Text += this.SessionParams.ProfessionDescription;
                    this.txtProfessionsList_ToCompare.Text += this.SessionParams.ProfessionDescription;
                }
                else
                {
                    this.txtProfessionCode.Text = this.SessionParams.ProfessionCodes;
                    this.txtProfessionCode_TextChanged(null, null);
                }
            }

            if (!string.IsNullOrEmpty(this.SessionParams.OmriCodes))
            {
                // Check if its one group or more.
                if (this.SessionParams.OmriCodes.IndexOf(",") > -1)
                {
                    this.txtOmriCodeList.Text = this.SessionParams.OmriCodes;
                    this.txtOmriDescList.Text = this.SessionParams.OmriDescription;
                    this.txtOmriDescList_ToCompare.Text = this.SessionParams.OmriDescription;
                }
                else
                {
                    this.txtOmriCode.Text = this.SessionParams.OmriCodes;
                    this.txtOmriCode_TextChanged(null, null);
                }
            }

            if (!string.IsNullOrEmpty(this.SessionParams.ICD9Codes))
            {
                if (this.SessionParams.ICD9Codes.IndexOf(",") > -1)
                { 
                    this.txtICD9CodeList.Text = this.SessionParams.ICD9Codes;
                    this.txtICD9Desc.Text = this.SessionParams.ICD9Description;
                    this.txtICD9Desc_ToCompare.Text = this.SessionParams.ICD9Description;                
                }
                else
                {
                    this.txtICD9Code.Text = this.SessionParams.ICD9Codes;
                    this.txtICD9Desc.Text = this.SessionParams.ICD9Description;
                }

                this.txtICD9Code_TextChanged(null, null);
            }

            if (!string.IsNullOrEmpty(this.SessionParams.PopulationCodes))
            {
                this.txtPopulationsListCodes.Text = this.SessionParams.PopulationCodes;
                this.txtPopulationsList.Text = this.SessionParams.PopulationDescription;
                this.txtPopulationsList_ToCompare.Text = this.SessionParams.PopulationDescription;
            }

            if (this.SessionParams.SalCategoryID>0)
                this.ddlSalCategory.SelectedValue = this.SessionParams.SalCategoryID.ToString();

            if (this.SessionParams.SalOrganCode > 0)
                this.ddlBodyOrgan.SelectedValue = this.SessionParams.SalOrganCode.ToString();

            if (!string.IsNullOrEmpty(this.SessionParams.Condition))
            {
                this.rbConditions.SelectedValue = SessionParams.Condition;

                if (SessionParams.Condition == Enums.SalServicesSearchConditions.InternetUpdatedDate.ToString())
                { 
                    if (this.SessionParams.InternetUpdated_ToDate.HasValue)
                        this.txtToDate.Text = this.SessionParams.InternetUpdated_ToDate.Value.ToString("dd/MM/yyyy");

                    if (this.SessionParams.InternetUpdated_FromDate.HasValue)
                        this.txtFromDate.Text = this.SessionParams.InternetUpdated_FromDate.Value.ToString("dd/MM/yyyy");
                }

                if (SessionParams.Condition == Enums.SalServicesSearchConditions.CanceledDate.ToString())
                { 
                    if (this.SessionParams.DEL_DATE_ToDate.HasValue)
                        this.txtToDate.Text = this.SessionParams.DEL_DATE_ToDate.Value.ToString("dd/MM/yyyy");

                    if (this.SessionParams.DEL_DATE_FromDate.HasValue)
                        this.txtFromDate.Text = this.SessionParams.DEL_DATE_FromDate.Value.ToString("dd/MM/yyyy");
                }

                if (SessionParams.Condition == Enums.SalServicesSearchConditions.AddedDate.ToString())
                {
                    if (this.SessionParams.ADD_DATE_ToDate.HasValue)
                        this.txtToDate.Text = this.SessionParams.ADD_DATE_ToDate.Value.ToString("dd/MM/yyyy");

                    if (this.SessionParams.ADD_DATE_FromDate.HasValue)
                        this.txtFromDate.Text = this.SessionParams.ADD_DATE_FromDate.Value.ToString("dd/MM/yyyy");
                }

                if (SessionParams.Condition == Enums.SalServicesSearchConditions.BasketApproveDate.ToString())
                {
                    if (this.SessionParams.BasketApproveToDate.HasValue)
                        this.txtToDate.Text = this.SessionParams.BasketApproveToDate.Value.ToString("dd/MM/yyyy");

                    if (this.SessionParams.BasketApproveFromDate.HasValue)
                        this.txtFromDate.Text = this.SessionParams.BasketApproveFromDate.Value.ToString("dd/MM/yyyy");

                }
            }
        }
    }

    protected void txtClalitServiceCode_TextChanged(object sender, EventArgs e)
    {
        // Get the clalit service code's description by the code text:
        string clalitServiceCode = this.txtClalitServiceCode.Text;

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        int iClalitServiceCode = 0;

        if (int.TryParse(clalitServiceCode, out iClalitServiceCode))
        {
            ds = applicFacade.GetServiceCodeDescription_ForSearchSalServices(iClalitServiceCode);


            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                string sClalitServiceDescription = ds.Tables[0].Rows[0]["ServiceName"].ToString();

                this.txtClalitServiceDesc.Text = sClalitServiceDescription;
            }
        }
        else
        {
            this.txtClalitServiceCode.Text = string.Empty;
            this.txtClalitServiceDesc.Text = string.Empty;
        }
    }

    protected void txtHealthOfficeCode_TextChanged(object sender, EventArgs e)
    {
        // Get the health office code's description by the code text:
        string healthOfficeCode = this.txtHealthOfficeCode.Text;

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        if (!string.IsNullOrEmpty(healthOfficeCode))
        {
            ds = applicFacade.GetHealthOfficeCodeDescription_ForSearchSalServices(healthOfficeCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                string sHealthOfficeDescription = ds.Tables[0].Rows[0]["Description"].ToString();

                this.txtHealthOfficeDesc.Text = sHealthOfficeDescription;
            }
        }
        else
        {
            this.txtHealthOfficeDesc.Text = string.Empty;
        }
    }

    protected void txtGroupCode_TextChanged(object sender, EventArgs e)
    {
        // Get the group code's description by the code text:
        string groupCode = this.txtGroupCode.Text;

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        int iGroupCode = 0;

        if (int.TryParse(groupCode, out iGroupCode))
        {
            ds = applicFacade.GetGroupCodeDescription_ForSearchSalServices(iGroupCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                string sGroupDescription = ds.Tables[0].Rows[0]["GroupDesc"].ToString();

                this.txtGroupsList.Text = sGroupDescription;
            }
        }
    }

    protected void txtProfessionCode_TextChanged(object sender, EventArgs e)
    {
        // Get the profession code's description by the code text:
        string professionCode = this.txtProfessionCode.Text;

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        int iProfessionCode = 0;

        if (int.TryParse(professionCode, out iProfessionCode))
        {
            ds = applicFacade.GetProfessionCodeDescription_ForSearchSalServices(iProfessionCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                string sProfessionDescription = ds.Tables[0].Rows[0]["Description"].ToString();

                this.txtProfessionsList.Text = sProfessionDescription;
            }
        }
    }

    protected void txtOmriCode_TextChanged(object sender, EventArgs e)
    {
        // Get the profession code's description by the code text:
        string omriReturnCode = this.txtOmriCode.Text;

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        int iOmriReturnCode = 0;

        if (int.TryParse(omriReturnCode, out iOmriReturnCode))
        {
            ds = applicFacade.GetOmriReturnCodeDescription_ForSearchSalServices(iOmriReturnCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                string sOmriReturn = ds.Tables[0].Rows[0]["ReturnDescription"].ToString();

                this.txtOmriDescList.Text = sOmriReturn;
            }
        }
    }

    protected void txtICD9Code_TextChanged(object sender, EventArgs e)
    {
        // Get the profession code's description by the code text:
        string ICD9Code = this.txtICD9Code.Text;

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        if (!string.IsNullOrEmpty(ICD9Code))
        {
            ds = applicFacade.GetICD9CodeDescription_ForSearchSalServices(ICD9Code);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                string sICD9Description = ds.Tables[0].Rows[0]["name"].ToString();

                this.txtICD9Desc.Text = sICD9Description;
            }
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        this.Need2RebindGrid = true;

        this.SessionParams.uniqueSearchParamater = Guid.NewGuid().ToString();

        this.SetVisibilityTabsPanels();
        this.BindGridView_PagedSorted();
    }

    private void SetVisibilityTabsPanels()
    {
        this.pServicesHeaderGrid.Visible = false;
        this.pPopulationsHeaderGrid.Visible = false;
        //this.pNewTestsHeaderGrid.Visible = false;

        this.pServicesGrid.Visible = false;
        this.pPopulationsGrid.Visible = false;
        //this.pNewTestsGrid.Visible = false;

        this.tabServices_RightTab.Attributes["class"] = "divRightTabNotSelected";
        this.tabServices_CenterTab.Attributes["class"] = "divCenterTabNotSelected";
        this.tabServices_LeftTab.Attributes["class"] = "divLeftTabNotSelected";

        this.tabPopulations_RightTab.Attributes["class"] = "divRightTabNotSelected";
        this.tabPopulations_CenterTab.Attributes["class"] = "divCenterTabNotSelected";
        this.tabPopulations_LeftTab.Attributes["class"] = "divLeftTabNotSelected";

        this.tabNewTests_RightTab.Attributes["class"] = "divRightTabNotSelected";
        this.tabNewTests_CenterTab.Attributes["class"] = "divCenterTabNotSelected";
        this.tabNewTests_LeftTab.Attributes["class"] = "divLeftTabNotSelected";

        switch (this.SelectedTab)
        {
            case SelectedSalServicesTab.SalServices:
                this.pServicesHeaderGrid.Visible = true;
                this.pServicesGrid.Visible = true;

                this.tabServices_RightTab.Attributes["class"] = "divRightTabSelected";
                this.tabServices_CenterTab.Attributes["class"] = "divCenterTabSelected";
                this.tabServices_LeftTab.Attributes["class"] = "divLeftTabSelected";

                this.phExportToExcel.Visible = false;
                break;

            case SelectedSalServicesTab.Populations:
                this.pPopulationsHeaderGrid.Visible = true;
                this.pPopulationsGrid.Visible = true;

                this.tabPopulations_RightTab.Attributes["class"] = "divRightTabSelected";
                this.tabPopulations_CenterTab.Attributes["class"] = "divCenterTabSelected";
                this.tabPopulations_LeftTab.Attributes["class"] = "divLeftTabSelected";

                this.phExportToExcel.Visible = true;
                break;

            case SelectedSalServicesTab.NewTests:
                //this.pNewTestsHeaderGrid.Visible = true;
                //this.pNewTestsGrid.Visible = true;

                this.tabNewTests_RightTab.Attributes["class"] = "divRightTabSelected";
                this.tabNewTests_CenterTab.Attributes["class"] = "divCenterTabSelected";
                this.tabNewTests_LeftTab.Attributes["class"] = "divLeftTabSelected";
                break;
        }
    }

    protected void lbSalServicesTab_Click(object sender, EventArgs e)
    {
        LinkButton lbSalServicesTab = (LinkButton)sender;

        this.SelectedTab = (SelectedSalServicesTab)Enum.Parse(typeof(SelectedSalServicesTab), lbSalServicesTab.CommandArgument);

        this.Need2RebindGrid = true;

        this.SetVisibilityTabsPanels();
        this.BindGridView_PagedSorted();
    }

    protected void repServicesList_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        DataRowView currentRow = e.Item.DataItem as DataRowView;

        int serviceCode = Convert.ToInt32(currentRow["serviceCode"]);

        int limiter = Convert.ToInt32(currentRow["Limiter"]);
        int includeInBasket = Convert.ToInt32(currentRow["IncludeInBasket"]);

        bool isCanceled = (bool)currentRow["IsCanceled"];
        

        if ( includeInBasket == 1 || limiter == 1 )
        {
            if (limiter == 1)
            {
                PlaceHolder pLimiter = (PlaceHolder)e.Item.FindControl("pLimiter_" + limiter);
                pLimiter.Visible = true;
            }

            if (includeInBasket == 0 && limiter == 1)
            {
                PlaceHolder pIncludeInBasket2 = (PlaceHolder)e.Item.FindControl("pIncludeInBasket_2");
                pIncludeInBasket2.Visible = true;
            }
            else
            {
                PlaceHolder pIncludeInBasket = (PlaceHolder)e.Item.FindControl("pIncludeInBasket_" + includeInBasket);
                pIncludeInBasket.Visible = true;
            }
        }

        int hasComments = Convert.ToInt32(currentRow["HasComments"]);
        if (hasComments == 1)
        {
            PlaceHolder pHasComments = (PlaceHolder)e.Item.FindControl("pHasComments_" + hasComments);
            pHasComments.Visible = true;
        }

        if (currentRow["ShowServiceInInternet"] != DBNull.Value)
        {
            byte showServiceInInternet = (byte)currentRow["ShowServiceInInternet"];
            if (showServiceInInternet == 1)
            {
                byte updateComplete = (currentRow["ShowServiceInInternet"] != DBNull.Value) ? (byte)currentRow["ShowServiceInInternet"] : (byte)0;
                PlaceHolder phShowServiceInInternet_Complete = (PlaceHolder)e.Item.FindControl("pShowServiceInInternet_Complete" + updateComplete.ToString());
                phShowServiceInInternet_Complete.Visible = true;
            }
        }

        HyperLink lnkToSalService1 = e.Item.FindControl("lnkToSalService1") as HyperLink;
        HyperLink lnkToSalService2 = e.Item.FindControl("lnkToSalService2") as HyperLink;

        lnkToSalService1.NavigateUrl = "Public/ZoomSalService.aspx?ServiceCode=" + currentRow["ServiceCode"].ToString() + "&Index=" +
            e.Item.ItemIndex + "&SearchId=" + this.SessionParams.uniqueSearchParamater + "&spi=" + CurrentPageIndex + "&tab=1";
        lnkToSalService2.NavigateUrl = lnkToSalService1.NavigateUrl;

        HtmlTableRow rowServiceDetails = (HtmlTableRow)e.Item.FindControl("rowServiceDetails");
        if (e.Item.ItemType == ListItemType.AlternatingItem )
            rowServiceDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#FEFEFE";
        else
            rowServiceDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#F3F3F3";

        // handle scroll inside results div
        if (e.Item.ItemIndex == this.SessionParams.LastRowIndexOnSearchPage &&
            this.SessionParams.LastSelectedTabOnSearchPage == 1 &&
            this.Request.QueryString["RepeatSearch"] != null &&
            this.Request.QueryString["spi"] == CurrentPageIndex.ToString())
        {
            this.SetScrollToLastSearch(e.Item.FindControl("pnlLink"), lnkToSalService1);
            rowServiceDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#dbdbda";
            //((HtmlTableRow)e.Item.FindControl("trClinic")).Attributes.Remove("class");
            //((HtmlTableRow)e.Item.FindControl("trClinic")).Attributes.Add("class", "trPlain_marked");
        }

        if (isCanceled)
        {
            if (string.IsNullOrEmpty(rowServiceDetails.Attributes["class"]) || rowServiceDetails.Attributes["class"].IndexOf("Canceled") == -1)
            {
                rowServiceDetails.Attributes["class"] = rowServiceDetails.Attributes["class"] + " Canceled";
            }
        }
        
    }

    public void SetScrollToLastSearch(Control containerControl, Control controlNeededToBeFocused)
    {
        HyperLink lnkToSelected = new HyperLink();
        lnkToSelected.NavigateUrl = "#" + controlNeededToBeFocused.ClientID;
        containerControl.Controls.Add(lnkToSelected);
        this.Page.ClientScript.RegisterStartupScript(this.GetType(), "goToSelected", "setTimeout('" + lnkToSelected.ClientID + ".click();', 1000 );", true);
    }

    protected void repPopulationsList_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        DataRowView currentRow = e.Item.DataItem as DataRowView;

        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            int serviceCode = Convert.ToInt32(currentRow["serviceCode"]);

            HyperLink lnkToSalService1 = e.Item.FindControl("lnkToSalService1") as HyperLink;
            HyperLink lnkToSalService2 = e.Item.FindControl("lnkToSalService2") as HyperLink;

            lnkToSalService1.NavigateUrl = "Public/ZoomSalService.aspx?ServiceCode=" + currentRow["ServiceCode"].ToString() + "&Index=" +
                e.Item.ItemIndex + "&SearchId=" + this.SessionParams.uniqueSearchParamater + "&spi=" + CurrentPageIndex + "&tab=2";
            lnkToSalService2.NavigateUrl = lnkToSalService1.NavigateUrl;

            HtmlTableRow rowServiceTarifonDetails = (HtmlTableRow)e.Item.FindControl("rowServiceTarifonDetails");
            if (e.Item.ItemType == ListItemType.AlternatingItem)
                rowServiceTarifonDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#FEFEFE";
            else
                rowServiceTarifonDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#F3F3F3";

            // handle scroll inside results div
            if (e.Item.ItemIndex == this.SessionParams.LastRowIndexOnSearchPage &&
                this.SessionParams.LastSelectedTabOnSearchPage == 2 &&
                this.Request.QueryString["RepeatSearch"] != null)
            {
                this.SetScrollToLastSearch(e.Item.FindControl("pnlLink"), lnkToSalService1);
                rowServiceTarifonDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#dbdbda";
            }

            bool isCanceled = (bool)currentRow["IsCanceled"];
            if (isCanceled)
            {
                if (string.IsNullOrEmpty(rowServiceTarifonDetails.Attributes["class"]) || rowServiceTarifonDetails.Attributes["class"].IndexOf("Canceled") == -1)
                {
                    rowServiceTarifonDetails.Attributes["class"] = rowServiceTarifonDetails.Attributes["class"] + " Canceled";
                }
            }

            if (!(this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator))
            {

                tdPopulationsServiceCode.Style[HtmlTextWriterStyle.Width] = "76px";
                tdPopulationsMinCode.Style[HtmlTextWriterStyle.Width] = "75px";

                tdPopulationsServiceName.Style[HtmlTextWriterStyle.Width] = "321px";
                rowServiceTarifonDetails.Cells[2].Style[HtmlTextWriterStyle.Width] = "300px";

                tdPopulationsIshtatfutAzmit.Style[HtmlTextWriterStyle.Width] = "117px";
                rowServiceTarifonDetails.Cells[4].Style[HtmlTextWriterStyle.Width] = "110px";

                tdPopulationsTaarifZiburiBet.Style[HtmlTextWriterStyle.Width] = "118px";
                rowServiceTarifonDetails.Cells[5].Style[HtmlTextWriterStyle.Width] = "110px";

                tdPopulationsMimunEtzLemecutah.Style[HtmlTextWriterStyle.Width] = "118px";
                rowServiceTarifonDetails.Cells[11].Style[HtmlTextWriterStyle.Width] = "110px";

                tdPopulationsHechzerim.Style[HtmlTextWriterStyle.Width] = "";
                rowServiceTarifonDetails.Cells[13].Style[HtmlTextWriterStyle.Width] = "110px";
            }
            else 
            {
                tdPopulationsServiceCode.Style[HtmlTextWriterStyle.Width] = "70px";
                tdPopulationsMinCode.Style[HtmlTextWriterStyle.Width] = "70px";

                tdPopulationsServiceName.Style[HtmlTextWriterStyle.Width] = "150px";
                rowServiceTarifonDetails.Cells[2].Style[HtmlTextWriterStyle.Width] = "150px";//

                tdPopulationsIshtatfutAzmit.Style[HtmlTextWriterStyle.Width] = "70px";
                rowServiceTarifonDetails.Cells[4].Style[HtmlTextWriterStyle.Width] = "70px";//

                tdPopulationsTaarifZiburiBet.Style[HtmlTextWriterStyle.Width] = "70px";
                rowServiceTarifonDetails.Cells[5].Style[HtmlTextWriterStyle.Width] = "70px";//

                tdPopulationsMimunEtzLemecutah.Style[HtmlTextWriterStyle.Width] = "70px";
                rowServiceTarifonDetails.Cells[11].Style[HtmlTextWriterStyle.Width] = "70px";//

                tdPopulationsHechzerim.Style[HtmlTextWriterStyle.Width] = "70px";
                rowServiceTarifonDetails.Cells[13].Style[HtmlTextWriterStyle.Width] = "70px"; //           
            }


            rowServiceTarifonDetails.Cells[3].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[6].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[7].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[8].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[9].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[10].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[12].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[14].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[15].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[16].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[17].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[18].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[19].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[20].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[21].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[22].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            rowServiceTarifonDetails.Cells[23].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);

            for (int i = 3; i <= 22; i++)
            {
                //rowServiceTarifonDetails.Cells[i].Style[HtmlTextWriterStyle.PaddingRight] = ( this.User.Identity.IsAuthenticated) ? "4px" : "30px";
            }
        }
    }

    protected void repNewTestsList_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        DataRowView currentRow = e.Item.DataItem as DataRowView;

        int serviceCode = Convert.ToInt32(currentRow["serviceCode"]);
    }

    #region Paging / Sorting Events

    protected void btnSort_Click(object sender, EventArgs e)
    {
        SortableColumnHeader columnToSortBy = sender as SortableColumnHeader;

        if (columnToSortBy.CurrentSortDirection.HasValue)
            this.sortingAndPagingParameters.SortingOrder = (int)columnToSortBy.CurrentSortDirection.Value;

        this.sortingAndPagingParameters.OrderBy = columnToSortBy.ColumnIdentifier.ToString();

        this.BindGridView_PagedSorted();
    }

    protected void btnNextPage_Click(object sender, EventArgs e)
    {
        this.currentPage = this.currentPage + 1;

        this.sortingAndPagingParameters.CurrentPage = this.currentPage;

        //call the interface who calls the searchPage
        this.BindGridView_PagedSorted();
    }

    protected void btnPreviousPage_Click(object sender, EventArgs e)
    {
        this.CurrentPageIndex--;

        if (this.currentPage < 1)
            this.currentPage = 1;

        sortingAndPagingParameters.CurrentPage = currentPage;

        //call the interface who calls the searchPage
        this.BindGridView_PagedSorted();
    }

    protected void btnLastPage_Click(object sender, EventArgs e)
    {
        this.currentPage = this.sortingAndPagingParameters.TotalPages;

        this.sortingAndPagingParameters.CurrentPage = currentPage;

        //call the interface who calls the searchPage
        this.BindGridView_PagedSorted();
    }

    protected void btnFirstPage_Click(object sender, EventArgs e)
    {
        this.currentPage = 1;

        this.sortingAndPagingParameters.CurrentPage = currentPage;

        //call the interface who calls the searchPage
        this.BindGridView_PagedSorted();
    }

    public void ddlCarrentPage_SelectedIndexChanged(object sender, EventArgs e)
    {
        this.currentPage = Convert.ToInt32(this.ddlCarrentPage.SelectedValue);

        this.sortingAndPagingParameters.CurrentPage = currentPage;

        this.BindGridView_PagedSorted();
    }

    #endregion

    private DataSet GetDataSource()
    {
        // Get the datasource for the current selected search tab and store the search params in the session.
        bool cancelledSelected = false;

        DataSet ds;
        if (this.Need2RebindGrid)
        {
            byte? salIncluded = byte.Parse(this.ddlSalIncluded.SelectedValue);
            byte? common = byte.Parse(this.ddlCommon.SelectedValue);
            //byte? limiter = byte.Parse(this.ddlLimiter.SelectedValue);
            byte? showServiceInInternet = byte.Parse(this.ddlInternet.SelectedValue);
            byte? isActive = byte.Parse(this.ddlIsActive.SelectedValue);

            string advanceSearch = this.txtExtendedSearch.Text;

            int clalitServiceCode = new int();
            if (!string.IsNullOrEmpty(this.txtClalitServiceCode.Text))
                int.TryParse(this.txtClalitServiceCode.Text, out clalitServiceCode);

            string clalitServiceDescription = this.txtClalitServiceDesc.Text.Trim();

            string healthOfficeCode = this.txtHealthOfficeCode.Text;
            string HealthOfficeDesc = this.txtHealthOfficeDesc.Text;

            string groupCodes = this.txtGroupsListCodes.Text.Trim();
            if (string.IsNullOrEmpty(groupCodes) && !string.IsNullOrEmpty(this.txtGroupCode.Text))
                groupCodes = this.txtGroupCode.Text;

            string professionCodes = this.txtProfessionsListCodes.Text.Trim();
            if (string.IsNullOrEmpty(professionCodes) && !string.IsNullOrEmpty(this.txtProfessionCode.Text))
                professionCodes = this.txtProfessionCode.Text;

            string omriCodes = this.txtOmriCodeList.Text.Trim();
            if (string.IsNullOrEmpty(omriCodes) && !string.IsNullOrEmpty(this.txtOmriCode.Text))
                omriCodes = this.txtOmriCode.Text;

            string icd9Code = string.Empty;
            if (!string.IsNullOrEmpty(this.txtICD9Code.Text))
                icd9Code = this.txtICD9Code.Text;
            else if (!string.IsNullOrEmpty(this.txtICD9CodeList.Text))
                icd9Code = this.txtICD9CodeList.Text;

            string populationsListCodes = this.txtPopulationsListCodes.Text;

            int salCategoryID = 0;
            int salOrganCode = 0;
            string condition = string.Empty;

            UserManager userManager = new UserManager();
            UserInfo currentUserInfo = userManager.GetUserInfoFromSession();
            bool canManageInternetSalServices = false;
            if (currentUserInfo != null && this.User.Identity.IsAuthenticated)
            {
                canManageInternetSalServices = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageInternetSalServices, -1);
                if (canManageInternetSalServices)
                {
                    int.TryParse(this.ddlSalCategory.SelectedValue, out salCategoryID);
                    int.TryParse(this.ddlBodyOrgan.SelectedValue, out salOrganCode);
                }
            }

            DateTime? dtBasketApproveFromDate = new DateTime?();
            DateTime? dtBasketApproveToDate = new DateTime?();
            DateTime? dtADD_DATE_FromDate = new DateTime?();
            DateTime? dtADD_DATE_ToDate = new DateTime?();
            DateTime? dtDEL_DATE_FromDate = new DateTime?();
            DateTime? dtDEL_DATE_ToDate = new DateTime?();
            DateTime? dtInternetUpdated_FromDate = new DateTime?();
            DateTime? dtInternetUpdated_ToDate = new DateTime?();

            if (!string.IsNullOrEmpty(this.txtFromDate.Text))
            {
                if(this.rbConditions.SelectedValue == Enums.SalServicesSearchConditions.BasketApproveDate.ToString())
                    dtBasketApproveFromDate = DateTime.Parse(this.txtFromDate.Text);

                if(this.rbConditions.SelectedValue == Enums.SalServicesSearchConditions.AddedDate.ToString())
                    dtADD_DATE_FromDate = DateTime.Parse(this.txtFromDate.Text);

                if (this.rbConditions.SelectedValue == Enums.SalServicesSearchConditions.CanceledDate.ToString())
                    dtDEL_DATE_FromDate = DateTime.Parse(this.txtFromDate.Text);

                if(this.rbConditions.SelectedValue == Enums.SalServicesSearchConditions.InternetUpdatedDate.ToString())
                    dtInternetUpdated_FromDate = DateTime.Parse(this.txtFromDate.Text);
            }

            if (!string.IsNullOrEmpty(this.txtToDate.Text))
            {
                if(this.rbConditions.SelectedValue == Enums.SalServicesSearchConditions.BasketApproveDate.ToString())
                    dtBasketApproveToDate = DateTime.Parse(this.txtToDate.Text);

                if (this.rbConditions.SelectedValue == Enums.SalServicesSearchConditions.AddedDate.ToString())
                    dtADD_DATE_ToDate = DateTime.Parse(this.txtToDate.Text);

                if (this.rbConditions.SelectedValue == Enums.SalServicesSearchConditions.CanceledDate.ToString())
                    dtDEL_DATE_ToDate = DateTime.Parse(this.txtToDate.Text);

                if (this.rbConditions.SelectedValue == Enums.SalServicesSearchConditions.InternetUpdatedDate.ToString())
                    dtInternetUpdated_ToDate = DateTime.Parse(this.txtToDate.Text);
            }

            condition = rbConditions.SelectedValue.ToString();
            if (this.rbConditions.SelectedValue == Enums.SalServicesSearchConditions.CanceledDate.ToString())
                    cancelledSelected = true;

            #region Store search params in session

            // Set the session params of the search so the "reportOnIncorrectData" will work.
            SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
            sessionParams.CurrentEntityToReport = Enums.IncorrectDataReportEntity.Dept;
            sessionParams.DeptCode = 58738;


            this.SessionParams.IncludeInBasket = salIncluded;
            this.SessionParams.Common = common;
            //this.SessionParams.Limiter = limiter;
            this.SessionParams.ShowServiceInInternet = showServiceInInternet;
            this.SessionParams.IsActive = isActive;

            this.SessionParams.AdvanceSearchText = advanceSearch;
            if (clalitServiceCode > 0)
                this.SessionParams.ServiceCode = clalitServiceCode;
            else
                this.SessionParams.ServiceCode = null;
            this.SessionParams.ServiceName = clalitServiceDescription;
            this.SessionParams.HealthOfficeCode = healthOfficeCode;
            this.SessionParams.HealthOfficeDesc = HealthOfficeDesc;
            this.SessionParams.GroupCodes = groupCodes;
            this.SessionParams.ProfessionCodes = professionCodes;
            this.SessionParams.OmriCodes = omriCodes;
            this.SessionParams.ICD9Codes = this.txtICD9CodeList.Text;
            if(this.txtICD9Code.Text != string.Empty)
                this.SessionParams.ICD9Codes = this.txtICD9Code.Text;
            this.SessionParams.ICD9Description = this.txtICD9Desc.Text;
            this.SessionParams.PopulationCodes = populationsListCodes;

            this.SessionParams.SalCategoryID = salCategoryID;
            this.SessionParams.SalOrganCode = salOrganCode;

            // Save the array of the names so item will not need to be rebinded when the user goes back to the search page.
            this.SessionParams.GroupDescription = this.txtGroupsList.Text;
            this.SessionParams.ProfessionDescription = this.txtProfessionsList.Text;
            this.SessionParams.OmriDescription = this.txtOmriDescList.Text;
            this.SessionParams.PopulationDescription = this.txtPopulationsList.Text;

            this.SessionParams.BasketApproveFromDate = dtBasketApproveFromDate;
            this.SessionParams.BasketApproveToDate = dtBasketApproveToDate;
            this.SessionParams.ADD_DATE_FromDate = dtADD_DATE_FromDate;
            this.SessionParams.ADD_DATE_ToDate = dtADD_DATE_ToDate;

            this.SessionParams.DEL_DATE_FromDate = dtDEL_DATE_FromDate;
            this.SessionParams.DEL_DATE_ToDate = dtDEL_DATE_ToDate;
            this.SessionParams.InternetUpdated_FromDate = dtInternetUpdated_FromDate;
            this.SessionParams.InternetUpdated_ToDate = dtInternetUpdated_ToDate;

            this.SessionParams.Condition = condition;

            if (this.rbConditions.SelectedValue != Enums.SalServicesSearchConditions.CurrentDay.ToString())
                isActive = 3; // select All

            #endregion

            Facade applicFacade = Facade.getFacadeObject();

            switch (this.SelectedTab)
            {
                case SelectedSalServicesTab.SalServices:
                    ds = applicFacade.GetSalServices(salIncluded, common, showServiceInInternet , isActive , this.User.Identity.IsAuthenticated , advanceSearch, clalitServiceCode, clalitServiceDescription, healthOfficeCode,
                            HealthOfficeDesc, groupCodes, professionCodes, omriCodes, icd9Code, populationsListCodes , salCategoryID ,salOrganCode ,
                            dtBasketApproveFromDate, dtBasketApproveToDate, dtADD_DATE_FromDate, dtADD_DATE_ToDate,
                            cancelledSelected, dtDEL_DATE_FromDate, dtDEL_DATE_ToDate, dtInternetUpdated_FromDate, dtInternetUpdated_ToDate);

                    this.Session["SalServicesDataSet"] = ds;

                    break;
                    
                case SelectedSalServicesTab.Populations:
                    ds = applicFacade.GetSalServices_Populations(salIncluded, common, showServiceInInternet, isActive, this.User.Identity.IsAuthenticated, advanceSearch, clalitServiceCode, clalitServiceDescription, healthOfficeCode,
                            HealthOfficeDesc, groupCodes, professionCodes, omriCodes, icd9Code, populationsListCodes, salCategoryID, salOrganCode, dtBasketApproveFromDate, dtBasketApproveToDate,
                            dtADD_DATE_FromDate, dtADD_DATE_ToDate, cancelledSelected, dtDEL_DATE_FromDate, dtDEL_DATE_ToDate, dtInternetUpdated_FromDate, dtInternetUpdated_ToDate);
                    break;

                case SelectedSalServicesTab.NewTests:
                    ds = applicFacade.GetSalServices_NewTests(salIncluded, common, advanceSearch, clalitServiceCode, clalitServiceDescription, healthOfficeCode,
                            HealthOfficeDesc, groupCodes, professionCodes, omriCodes, icd9Code, populationsListCodes, dtBasketApproveFromDate,
                            dtBasketApproveToDate, dtADD_DATE_FromDate, dtADD_DATE_ToDate, cancelledSelected, dtDEL_DATE_FromDate, dtDEL_DATE_ToDate);
                    break;

                default:
                    goto case SelectedSalServicesTab.SalServices;
            }

            this.Session["GridViewDataSet"] = ds;

            this.ResetPagingSortingData();

            this.Need2RebindGrid = false;
        }
        else
        {
            ds = (DataSet)this.Session["GridViewDataSet"];
        }

        if (ds == null)
        {
            //throw new NullReferenceException("There datasource returned emepty for sal services grid.");
            this.totalRecords = 0;
        }
        else
        {
            this.totalRecords = ds.Tables[0].Rows.Count;
        }

        return ds;
    }

    private bool Need2RebindGrid
    {
        get
        {
            if (this.ViewState["Need2RebindGrid"] != null && this.ViewState["Need2RebindGrid"] is bool)
                return (bool)this.ViewState["Need2RebindGrid"];
            else
                return false;
        }
        set
        {
            this.ViewState["Need2RebindGrid"] = value;
        }
    }

    private void BindGridView_PagedSorted()
    {
        DataSet ds = this.GetDataSource();

        pnlTabs.Visible = true;
        this.divSalServicesSearchResults.Style[HtmlTextWriterStyle.Display] = "inline-block";

        if (ds != null)
        {
            DataView dvSalServices = new DataView(ds.Tables[0]);
            dvSalServices.Sort = this.sortingAndPagingParameters.OrderBy;
            if (this.sortingAndPagingParameters.SortingOrder > 0 || !string.IsNullOrEmpty(this.sortingAndPagingParameters.OrderBy))
            {
                switch (this.sortingAndPagingParameters.SortingOrder)
                {
                    case 0:
                        dvSalServices.Sort += " ASC";
                        break;
                    case 1:
                        dvSalServices.Sort += " DESC";
                        break;
                    default:
                        goto case 1;
                }
            }

            // Set the current page index from the querystring:
            if (!this.IsPostBack && !string.IsNullOrEmpty(this.Request.QueryString["spi"]))
                this.CurrentPageIndex = int.Parse(this.Request.QueryString["spi"]);

            PagedDataSource pdsDataSource = new PagedDataSource();

            pdsDataSource.AllowPaging = true;
            pdsDataSource.DataSource = dvSalServices;
            pdsDataSource.PageSize = this.pageSize;
            pdsDataSource.CurrentPageIndex = this.CurrentPageIndex;

            this.SetPagingControls(this.totalRecords);

            switch (this.SelectedTab)
            {
                case SelectedSalServicesTab.SalServices:
                    this.repServicesList.DataSource = pdsDataSource;
                    this.repServicesList.DataBind();
                    break;
                case SelectedSalServicesTab.Populations:
                    this.repPopulationsList.DataSource = pdsDataSource;
                    this.repPopulationsList.DataBind();
                    break;
                case SelectedSalServicesTab.NewTests:
                    //this.repNewTestsList.DataSource = pdsDataSource;
                    //this.repNewTestsList.DataBind();
                    break;
            }

            ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustGridsHieght", "AdjustGridsHieght();", true);
        }
    }

    public void SetPagingControls(int? numberOfRecords)
    {
        if (numberOfRecords != null)
        {
            this.totalRecords = (int)numberOfRecords;
        }

        if (this.currentPage == 1)
        {
            this.btnFirstPage.Enabled = false;
            this.btnPreviousPage.Enabled = false;
        }
        else
        {
            this.btnFirstPage.Enabled = true;
            this.btnPreviousPage.Enabled = true;
        }

        if (this.currentPage == this.totalPages)
        {
            this.btnNextPage.Enabled = false;
            this.btnLastPage.Enabled = false;
        }
        else
        {
            this.btnNextPage.Enabled = true;
            this.btnLastPage.Enabled = true;
        }

        if (this.totalRecords < 1)
        {
            this.btnNextPage.Enabled = false;
            this.btnLastPage.Enabled = false;
        }

        this.lblTotalRecords.Text = "נמצאו" + "&nbsp;" + this.totalRecords + "&nbsp;" + "רשומות";
        this.lblPageFromPages.Text = "(" + "&nbsp;" + "עמוד" + "&nbsp;" + this.currentPage + "&nbsp;" + "מתוך" + "&nbsp;" + this.totalPages + "&nbsp;" + ")";

        if (this.totalRecords < 1)
            this.lblPageFromPages.Text = string.Empty;

        this.ddlCarrentPage.Items.Clear();
        if (this.totalPages > 1)
        {
            for (int i = 1; i <= totalPages; i++)
            {
                this.ddlCarrentPage.Items.Add(i.ToString());
                if (i == currentPage)
                    this.ddlCarrentPage.Items[i - 1].Selected = true;
            }
            this.ddlCarrentPage.Enabled = true;
        }
        else
        {
            this.ddlCarrentPage.Enabled = false;
        }

        this.sortingAndPagingParameters.TotalPages = totalPages;
    }

    public void ResetPagingSortingData()
    {
        this.CurrentPageIndex = 0;

        this.sortingAndPagingParameters = new SortingAndPagingParameters();
    }

    protected void bExportToExcel_Click(object sender, EventArgs e)
    {
        DataSet dsExcelDataSource = this.GetDataSource();
        if (dsExcelDataSource != null && dsExcelDataSource.Tables.Count > 0)
        {
            //dsExcelDataSource.Tables[0].Columns[];

            this.ExportToExcel(dsExcelDataSource.Tables[0]);
        }
    }

    public void ExportToExcel(DataTable dt)
    {
        if (dt.Rows.Count > 0)
        {
            string filename = "PopulationsStats-" + DateTime.Now.ToShortDateString() + ".xls";
            System.IO.StringWriter tw = new System.IO.StringWriter();
            System.Web.UI.HtmlTextWriter hw = new System.Web.UI.HtmlTextWriter(tw);

            DataGrid dgGrid = new DataGrid();

            dgGrid.AutoGenerateColumns = false;

            // Set columns for the excel grid rendering:

            BoundColumn bcServiceCode = new BoundColumn();
            bcServiceCode.DataField = "ServiceCode";
            bcServiceCode.HeaderText = "קוד שרות";

            BoundColumn bcMIN_CODE = new BoundColumn();
            bcMIN_CODE.DataField = "MIN_CODE";
            bcMIN_CODE.HeaderText = "קוד מ.ב.";

            BoundColumn bcServiceName = new BoundColumn();
            bcServiceName.DataField = "ServiceName";
            bcServiceName.HeaderText = "תיאור עברי/אנגלי";

            BoundColumn bcIthashbenutPnimit = new BoundColumn();
            bcIthashbenutPnimit.DataField = "IthashbenutPnimit";
            bcIthashbenutPnimit.HeaderText = "התחשבנות פנימית";

            BoundColumn bcIshtatfutAzmit = new BoundColumn();
            bcIshtatfutAzmit.DataField = "IshtatfutAzmit";
            bcIshtatfutAzmit.HeaderText = "השתתפות עצמית";

            BoundColumn bcTaarifZiburiBet = new BoundColumn();
            bcTaarifZiburiBet.DataField = "TaarifZiburiBet";
            bcTaarifZiburiBet.HeaderText = "תעריף ציבורי ב'";

            BoundColumn bcTeunotDrahim = new BoundColumn();
            bcTeunotDrahim.DataField = "TeunotDrahim";
            bcTeunotDrahim.HeaderText = "תאונות דרכים";

            BoundColumn bcTaarifMale = new BoundColumn();
            bcTaarifMale.DataField = "TaarifMale";
            bcTaarifMale.HeaderText = "תעריף מלא";

            BoundColumn bcKatsatPnimi = new BoundColumn();
            bcKatsatPnimi.DataField = "KatsatPnimi";
            bcKatsatPnimi.HeaderText = "קצ\"ת פנימי";

            BoundColumn bcKlalitMushlam = new BoundColumn();
            bcKlalitMushlam.DataField = "KlalitMushlam";
            bcKlalitMushlam.HeaderText = "כללית מושלם";

            BoundColumn bcKatsatHizoni = new BoundColumn();
            bcKatsatHizoni.DataField = "KatsatHizoni";
            bcKatsatHizoni.HeaderText = "קצ\"ת חיצוני";

            BoundColumn bcMimunEtzLemecutah = new BoundColumn();
            bcMimunEtzLemecutah.DataField = "MimunEtzLemecutah";
            bcMimunEtzLemecutah.HeaderText = "מימון עצ למבוטח";

            BoundColumn bcOvdimZarim = new BoundColumn();
            bcOvdimZarim.DataField = "OvdimZarim";
            bcOvdimZarim.HeaderText = "עובדים זרים";

            BoundColumn bcHechzerim = new BoundColumn();
            bcHechzerim.DataField = "Hechzerim";
            bcHechzerim.HeaderText = "החזרים";

            BoundColumn bcBituahOhMeyuhad = new BoundColumn();
            bcBituahOhMeyuhad.DataField = "BituahOhMeyuhad";
            bcBituahOhMeyuhad.HeaderText = "ביטוח אוכ מיוחד";

            BoundColumn bcTaarifeyShuk = new BoundColumn();
            bcTaarifeyShuk.DataField = "TaarifeyShuk";
            bcTaarifeyShuk.HeaderText = "תעריפי שוק";

            BoundColumn bcTikzuvBetHolim = new BoundColumn();
            bcTikzuvBetHolim.DataField = "TikzuvBetHolim";
            bcTikzuvBetHolim.HeaderText = "תקצוב בתי\"ח";

            BoundColumn bcTaarifAlef = new BoundColumn();
            bcTaarifAlef.DataField = "TaarifAlef";
            bcTaarifAlef.HeaderText = "תעריף א'";

            BoundColumn bcTaarifZiburiZam = new BoundColumn();
            bcTaarifZiburiZam.DataField = "TaarifZiburiZam";
            bcTaarifZiburiZam.HeaderText = "תעריף ציבורי זמ";

            BoundColumn bcTaarifZiburiGemel = new BoundColumn();
            bcTaarifZiburiGemel.DataField = "TaarifZiburiGemel";
            bcTaarifZiburiGemel.HeaderText = "תעריף ציבורי גמל";

            BoundColumn bcZahalBeklalitHova = new BoundColumn();
            bcZahalBeklalitHova.DataField = "ZahalBeklalitHova";
            bcZahalBeklalitHova.HeaderText = "צהל בכללית חובה";

            BoundColumn bcZahalBeklalitKeva = new BoundColumn();
            bcZahalBeklalitKeva.DataField = "ZahalBeklalitKeva";
            bcZahalBeklalitKeva.HeaderText = "צהל בכללית חובה";

            BoundColumn bcTaarifZiburiEskemim = new BoundColumn();
            bcTaarifZiburiEskemim.DataField = "TaarifZiburiEskemim";
            bcTaarifZiburiEskemim.HeaderText = "תעריף ציבורי הסכמים";

            dgGrid.Columns.Add(bcServiceCode);
            dgGrid.Columns.Add(bcMIN_CODE);
            dgGrid.Columns.Add(bcServiceName);
            dgGrid.Columns.Add(bcIthashbenutPnimit);
            dgGrid.Columns.Add(bcIshtatfutAzmit);
            dgGrid.Columns.Add(bcTaarifZiburiBet);
            dgGrid.Columns.Add(bcTeunotDrahim);
            dgGrid.Columns.Add(bcTaarifMale);
            dgGrid.Columns.Add(bcKatsatPnimi);
            dgGrid.Columns.Add(bcKlalitMushlam);
            dgGrid.Columns.Add(bcKatsatHizoni);
            dgGrid.Columns.Add(bcMimunEtzLemecutah);
            dgGrid.Columns.Add(bcOvdimZarim);
            dgGrid.Columns.Add(bcHechzerim);
            dgGrid.Columns.Add(bcBituahOhMeyuhad);
            dgGrid.Columns.Add(bcTaarifeyShuk);
            dgGrid.Columns.Add(bcTikzuvBetHolim);
            dgGrid.Columns.Add(bcTaarifAlef);
            dgGrid.Columns.Add(bcTaarifZiburiZam);
            dgGrid.Columns.Add(bcTaarifZiburiGemel);
            dgGrid.Columns.Add(bcZahalBeklalitHova);
            dgGrid.Columns.Add(bcZahalBeklalitKeva);
            dgGrid.Columns.Add(bcTaarifZiburiEskemim);


            dgGrid.Columns[3].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[6].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[7].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[8].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[9].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[10].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[12].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[14].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[15].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[16].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[17].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[18].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[19].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[20].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[21].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);
            dgGrid.Columns[22].Visible = (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator);


            dgGrid.DataSource = dt;
            dgGrid.DataBind();

            //Get the HTML for the control.
            dgGrid.RenderControl(hw);

            Response.Clear();
            Response.ContentType = "application/vnd.ms-excel";
            Response.Write("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-1255\" />");
   
            //Write the HTML back to the browser.
            //Response.ContentType = "application/vnd.ms-excel";
            //Response.ContentType = "application/excel";
            //Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            Response.AppendHeader("Content-Disposition", "attachment; filename=" + filename + "");
            //Response.ContentEncoding = System.Text.Encoding.GetEncoding("Windows-1255");
            //Response.ContentEncoding = System.Text.Encoding.Default;
            //Response.BinaryWrite(System.Text.Encoding.GetEncoding("Windows-1255").GetPreamble());
            //HttpContext.Current.Response.ContentEncoding = System.Text.UnicodeEncoding.UTF8;
            //HttpContext.Current.Response.ContentEncoding = System.Text.Encoding.GetEncoding("windows-1255");

            Response.Write(tw.ToString());
            Response.End();
        }
    }

    #region Autocomplete services

    [WebMethod]
    public static string ClalitServiceCode_AutoComplete(string clalitServiceCode)
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        int iClalitServiceCode = 0;
        string sClalitServiceDescription = string.Empty;

        if (int.TryParse(clalitServiceCode, out iClalitServiceCode))
        {
            ds = applicFacade.GetServiceCodeDescription_ForSearchSalServices(iClalitServiceCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                sClalitServiceDescription = ds.Tables[0].Rows[0]["ServiceName"].ToString();
            }
        }

        return sClalitServiceDescription;
    }

    [WebMethod]
    public static string HealthOfficeCode_AutoComplete(string healthOfficeCode)
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        string sHealthOfficeDescription = string.Empty;

        if (!string.IsNullOrEmpty(healthOfficeCode))
        {
            ds = applicFacade.GetHealthOfficeCodeDescription_ForSearchSalServices(healthOfficeCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                sHealthOfficeDescription = ds.Tables[0].Rows[0]["Description"].ToString();
            }
        }

        return sHealthOfficeDescription;
    }

    [WebMethod]
    public static string GroupCode_AutoComplete(string groupCode)
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        int iGroupCode = 0;
        string sGroupDescription = string.Empty;

        if (int.TryParse(groupCode, out iGroupCode))
        {
            ds = applicFacade.GetGroupCodeDescription_ForSearchSalServices(iGroupCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                sGroupDescription = ds.Tables[0].Rows[0]["GroupDesc"].ToString();
            }
        }

        return sGroupDescription;
    }

    [WebMethod]
    public static string ProfessionCode_AutoComplete(string professionCode)
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        int iProfessionCode = 0;
        string sProfessionDescription = string.Empty;

        if (int.TryParse(professionCode, out iProfessionCode))
        {
            ds = applicFacade.GetProfessionCodeDescription_ForSearchSalServices(iProfessionCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                sProfessionDescription = ds.Tables[0].Rows[0]["Description"].ToString();
            }
        }

        return sProfessionDescription;
    }

    // Omri auto complete
    [WebMethod]
    public static string OmriCode_AutoComplete(string omriCode)
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        int iOmriReturnCode = 0;
        string sOmriReturn = string.Empty;

        if (int.TryParse(omriCode, out iOmriReturnCode))
        {
            ds = applicFacade.GetOmriReturnCodeDescription_ForSearchSalServices(iOmriReturnCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                sOmriReturn = ds.Tables[0].Rows[0]["ReturnDescription"].ToString();
            }
        }

        return sOmriReturn;
    }
    
    [WebMethod]
    public static string ICD9Code_AutoComplete(string icd9Code)
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        string sICD9Description = string.Empty;

        if (!string.IsNullOrEmpty(icd9Code))
        {
            ds = applicFacade.GetICD9CodeDescription_ForSearchSalServices(icd9Code);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                sICD9Description = ds.Tables[0].Rows[0]["name"].ToString();
            }
        }

        return sICD9Description;
    }

    #endregion

}