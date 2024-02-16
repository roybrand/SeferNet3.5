using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Clalit.Infrastructure.ServicesManager;
using Clalit.Infrastructure.ServiceInterfaces;
using System.Data;
using Clalit.SeferNet.GeneratedEnums;
using SeferNet.BusinessLayer.BusinessObject;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;
using MapsManager;
using SeferNet.Globals;
using SeferNet.BusinessLayer.WorkFlow;

public partial class SearchMasterPage : System.Web.UI.MasterPage, ISearchMasterPage
{
    static string _DefaltPageName;

    public bool IsPostBackAfterLoginLogout
    {
        get
        {
            return Master.IsPostBackAfterLoginLogout;
        }
    }

    public string uniqueSearchParamater
    {
        get
        {
            if (Session["UniqueSearchParameter"] != null)
                return Session["UniqueSearchParameter"].ToString();
            else
                return string.Empty;
        }

        set
        {
            Session["UniqueSearchParameter"] = value;
        }
    }

    public string ControlIdsUpdatingControl { get; set; }

    /// <summary>
    /// property to be accessed from the pages that use the master page
    /// </summary>
    /// <returns></returns>
    public AjaxControlToolkit.ModalPopupExtender GetModalPopupGrayScreen()
    {
        return modalPopupGrayScreen;
    }

    static SearchMasterPage()
    {
        _DefaltPageName = SearchPageStatusParameters.GetDefaultPageName();
    }

    public void InitUpdatePanelTrigger()
    {
        this.ControlIdsUpdatingControl = this.Master.BtnToDo_Submeet.ID;
        //add button clicks that will trigger the update panel to be refreshed
        //we do it because we want the hdnClinicJson to be refreshed so later we can access it from the js 
        // and refresh the map according to it 
        if (string.IsNullOrEmpty(ControlIdsUpdatingControl) == false)
        {
            string[] controlsTriggerUpdatePanel = ControlIdsUpdatingControl.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string controlId in controlsTriggerUpdatePanel)
            {
                AsyncPostBackTrigger trigger = new AsyncPostBackTrigger();
                trigger.EventName = "Click";
                trigger.ControlID = controlId;
                UpdatePanelTop.Triggers.Add(trigger);

            }
        }
    }

    SearchPageStatusParameters searchPageStatusParameters;

    public SortingAndPagingInfoController PagingControlsController;

    public event EventHandler btnSubmit_ClickEvent;

    #region Page events

    protected override void OnInit(EventArgs e)
    {
        //TEMP!!! to be removed after map is fixed
        //chkShowMap.Style.Add("display", "none");
        //

        //oninit event order
        // 1.uc/master page
        // 2.page 

        base.OnInit(e);



        //add button clicks that will trigger the update panel to be refreshed
        //we do it because we want the hdnClinicJson to be refreshed so later we can access it from the js 
        // and refresh the map according to it     

        //AsyncPostBackTrigger trigger = new AsyncPostBackTrigger();
        //trigger.EventName = "Click";
        //trigger.ControlID = DeptMapControl.BtnTriggerPostBack;
        //UpdatePanelGrd.Triggers.Add(trigger);

        ////<Triggers>
        ////          <asp:AsyncPostBackTrigger ControlID="btnSubmit" EventName="Click" />
        //// </Triggers>

        //DeptMapControl.RowMapImageClick_NonClosestPointSearch_Occured += new RowMapImageClick_NonClosestPointSearch_OccuredDelegate(DeptMapControl_RowMapImageClick_NonClosestPointSearch_Occured);
        // this has to be run before page load because the page that sits on this master page  needs the data bind
        //ready when it loads

        SetSearchStatusInSession();
        setSelectSearchPage();
        if (!IsPostBack)
        {
            HandleBinding();
            this.InitializeViewFromGlobalResources();
            Master.HideMainHeader();
        }

        InitUpdatePanelTrigger();
    }

    private void setSelectSearchPage()
    {
        if (Request.Url.ToString().Contains("SearchEvents.aspx"))
        {
            searchPageStatusParameters.SelectSearchPage = SearchPageStatusParameters.eSearchPageName.SearchEvents;
        }
        else
        {
            if (Request.Url.ToString().Contains("SearchDoctors.aspx"))
            {
                searchPageStatusParameters.SelectSearchPage = SearchPageStatusParameters.eSearchPageName.SearchDoctors;
            }
            else
            {
                if (Request.Url.ToString().Contains("SearchClinics.aspx"))
                {
                    searchPageStatusParameters.SelectSearchPage = SearchPageStatusParameters.eSearchPageName.SearchClinics;
                }
            }
        }

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // load  event order
        // 1. page 
        // 2. uc / master page

        // synchronise context key because it might have changed on client
        autoCompleteCities.ContextKey = txtDistrictCodes.Text + ";" + Session["Culture"];
        autoCompleteStreets.ContextKey = txtCityCode.Text;

        autoCompleteNeighborhood.ContextKey = txtCityCode.Text;
        
        RefreshMapOnRepeatSearch_IfRequired();

        SearchParametersBase searchParameters;
        if (!IsPostBack && (Request.Url.ToString().Contains("SearchDoctors.aspx"))) // removed because logic of extended search:  || Request.Url.ToString().Contains("SearchClinics.aspx")))
        {
            if (Session["doctorSearchParameters"] != null)
            {
                searchParameters = Session["doctorSearchParameters"] as SearchParametersBase;
                this.RefreshSearchMode(searchParameters.CurrentSearchModeInfo);
            }
        }

        if (this.IsPostBackAfterLoginLogout)
        {
            UserManager userManager = new UserManager();
            UserInfo currentUserInfo = userManager.GetUserInfoFromSession();
            //if (currentUserInfo != null)
            //{
            //    bool canManageTarifonViews = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageTarifonViews, -1);
            //    bool canViewTarifon = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ViewTarifon, -1);

            //    if (canManageTarifonViews || canViewTarifon || currentUserInfo.IsAdministrator)
            //    {
            //        this.tdSalServiceTab.Visible = true;
            //    }
            //    else
            //    {
            //        this.tdSalServiceTab.Visible = false;
            //    }
            //}
            //else
            //{
            //    this.tdSalServiceTab.Visible = false;
            //}

            ((UpdatePanel)this.Master.FindControl("upContent")).Update();
        }
    }

    private void SetParametersToSearchModeControl()
    {
        if (this.Session[ConstsSession.SEARCH_MODE_CONTROL_PARAMETERS] != null)
        {
            SearchModeSelectParameters searchModeSelectParameters = (SearchModeSelectParameters)Session[ConstsSession.SEARCH_MODE_CONTROL_PARAMETERS];
            SetParametersToSearchModeControl(searchModeSelectParameters);
        }
    }

    public void SetParametersToSearchModeControl(SearchModeSelectParameters searchModeSelectParameters)
    {
        this.lstSearchModes.IsHospitalsModeSelected = searchModeSelectParameters.Hospitals;
        this.lstSearchModes.IsCommunityModeSelected = searchModeSelectParameters.Community;
        this.lstSearchModes.IsMushlamModeSelected = searchModeSelectParameters.Mushlam;
        this.lstSearchModes.AllModesSelected = searchModeSelectParameters.All;
    }

    public void SetSearchModeControlParametersToSession()
    {
        SearchModeSelectParameters searchModeSelectParameters = new SearchModeSelectParameters();

        searchModeSelectParameters.Hospitals = lstSearchModes.IsHospitalsModeSelected;
        searchModeSelectParameters.Community = lstSearchModes.IsCommunityModeSelected;
        searchModeSelectParameters.Mushlam = lstSearchModes.IsMushlamModeSelected;
        searchModeSelectParameters.All = lstSearchModes.AllModesSelected;

        this.Session[ConstsSession.SEARCH_MODE_CONTROL_PARAMETERS] = searchModeSelectParameters;
    }

    void Page_PreRender(object sender, EventArgs e)
    {
        if (cbShowHideMap.Checked == true)
        {
            this.btnShowMap.Style.Add("display", "none");
            this.btnHideMap.Style.Add("display", "inline");
            this.divButtonsShowHideMap.Style.Add("display", "inline");
        }
        else
        {
            this.btnShowMap.Style.Add("display", "inline");
            this.btnHideMap.Style.Add("display", "none");
        }

        if (Request.Url.ToString().Contains("SearchEvents.aspx"))
            this.lstSearchModes.IsHiddenMode = true;

        if (Request.Url.ToString().Contains("HospitalsOnly"))
        {
            this.lstSearchModes.IsHospitalsModeSelected = true;
            this.lstSearchModes.IsCommunityModeSelected = false;
            this.lstSearchModes.IsMushlamModeSelected = false;
            this.lstSearchModes.AllModesSelected = false;
        }

        this.SetParametersToSearchModeControl();

        UserManager userManager = new UserManager();
        UserInfo currentUserInfo = userManager.GetUserInfoFromSession();
        //if (currentUserInfo != null)
        //{
        //    bool canManageTarifonViews = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageTarifonViews, -1);
        //    bool canViewTarifon = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ViewTarifon, -1);

        //    if (canManageTarifonViews || canViewTarifon || currentUserInfo.IsAdministrator)
        //    {
        //        this.tdSalServiceTab.Visible = true;
        //    }
        //    else
        //    {
        //        this.tdSalServiceTab.Visible = false;
        //    }
        //}
        //else
        //{
        //    this.tdSalServiceTab.Visible = false;
        //}
    }

    #endregion

    #region Initilization

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

    public void InitializeViewFromGlobalResources()
    {
        this.lblOpenInHour.CssClass = multiLineLabelCss;
        this.lblReceptionDays.CssClass = multiLineLabelCss;
        this.lblreceptionFromCaption.CssClass = multiLineLabelCss;
        this.lblReceptionToCaption.CssClass = multiLineLabelCss;

        this.aSearchClinics.Attributes.Add("class", (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchClinics) == true ? highlightedSearhTab : notHighlightedSearhTab);
        this.tdClinicInnerTdLeft.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchClinics) == true ? HighlightedSearhTabLeft : NotHighlightedSearhTabLeft;
        this.tdClinicInnerTdRight.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchClinics) == true ? HighlightedSearhTabRight : NotHighlightedSearhTabRight;
        this.tdClinicInnerTdMiddle.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchClinics) == true ? HighlightedSearhTabMiddle : NotHighlightedSearhTabMiddle;
        this.tdClinicTab.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchClinics) == true ? TDHighlightedSearchTab : TDNotHighlightedSearchTab;

        this.aSearchDoctors.Attributes.Add("class", (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchDoctors) == true ? highlightedSearhTab : notHighlightedSearhTab);
        this.tdDoctorInnerTdLeft.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchDoctors) == true ? HighlightedSearhTabLeft : NotHighlightedSearhTabLeft;
        this.tdDoctorInnerTdRight.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchDoctors) == true ? HighlightedSearhTabRight : NotHighlightedSearhTabRight;
        this.tdDoctorInnerTdMiddle.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchDoctors) == true ? HighlightedSearhTabMiddle : NotHighlightedSearhTabMiddle;
        this.tdDoctorTab.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchDoctors) == true ? TDHighlightedSearchTab : TDNotHighlightedSearchTab;

        this.aSearchSalServices.Attributes.Add("class", (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchSalServices) == true ? highlightedSearhTab : notHighlightedSearhTab);
        this.tdSalServiceInnerTdLeft.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchSalServices) == true ? HighlightedSearhTabLeft : NotHighlightedSearhTabLeft;
        this.tdSalServiceInnerTdRight.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchSalServices) == true ? HighlightedSearhTabRight : NotHighlightedSearhTabRight;
        this.tdSalServiceInnerTdMiddle.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchSalServices) == true ? HighlightedSearhTabMiddle : NotHighlightedSearhTabMiddle;
        this.tdSalServiceTab.Attributes["class"] = (searchPageStatusParameters.SelectSearchPage == SearchPageStatusParameters.eSearchPageName.SearchSalServices) == true ? TDHighlightedSearchTab : TDNotHighlightedSearchTab;


        InitializeViewFromGlobalResources_MapSearchControls();
    }

    #endregion

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (btnSubmit_ClickEvent != null)
        {
            this.SetSearchModeControlParametersToSession();
            this.btnSubmit_ClickEvent(sender, e);
        }
    }

    

    private void HandleBinding()
    {
        this.BindReceptionDaysControls();
    }

    public void ClearFields()
    {
        //call clear fields method on the page
        //call clear methods on the master page
        this.ClearReceptionTimeInfo();
        this.ClearFields_MapSearchControls();
    }

    public void SetSearchParametersByControls(SearchParametersBase searchParameters)
    {
        this.SetReceptionTimeParametersByControls(searchParameters);
        this.SetSearchModeParameters(searchParameters);
        this.SetMapSearchParametersByControls(searchParameters);
    }

    public void SetSearchModeParameters(SearchParametersBase searchParameters)
    {
        searchParameters.CurrentSearchModeInfo = new SearchModeInfo();

        ListItem listItem = null;
        foreach (Enums.SearchMode selectedMode in this.lstSearchModes.SelectedSearchModes)
        {
            switch (selectedMode)
            {
                case Enums.SearchMode.All:
                    listItem = lstSearchModes.LstModes.Items.FindByValue(Enums.SearchMode.All.ToString());
                    searchParameters.CurrentSearchModeInfo.AllModesSelected = true;
                    break;
                case Enums.SearchMode.Mushlam:
                    searchParameters.CurrentSearchModeInfo.IsMushlamSelected = true;
                    break;
                case Enums.SearchMode.Community:
                    searchParameters.CurrentSearchModeInfo.IsCommunitySelected = true;
                    break;
                case Enums.SearchMode.Hospitals:
                    searchParameters.CurrentSearchModeInfo.IsHospitalsSelected = true;
                    break;
                default:
                    break;
            }
        }
    }

    public List<Enums.SearchMode> GetSelectedSearchMode()
    {
        return this.lstSearchModes.SelectedSearchModes;
    }

    public void RefreshControlsByParameters(SearchParametersBase searchParameters)
    {
        this.RefreshReceptionTimeInfoControls(searchParameters.CurrentReceptionTimeInfo);
        this.RefreshSearchMode(searchParameters.CurrentSearchModeInfo);
        this.RefreshMapInfoSearchControlsByParameters(searchParameters);
    }

    private void RefreshSearchMode(SearchModeInfo searchMode)
    {
        //this.lstSearchModes.SearchMode = searchMode;
        if (searchMode == null)
            searchMode = new SearchModeInfo();
        this.lstSearchModes.SearchMode = searchMode;

        if (searchMode.AllModesSelected != null)
        {
            if ((bool)searchMode.AllModesSelected)
            {
                this.lstSearchModes.AllModesSelected = true;
                this.lstSearchModes.IsCommunityModeSelected = true;
                this.lstSearchModes.IsMushlamModeSelected = true;
                this.lstSearchModes.IsHospitalsModeSelected = true;
            }
        }
        else
        {
            this.lstSearchModes.IsCommunityModeSelected = (searchMode.IsCommunitySelected != null) ? (bool)searchMode.IsCommunitySelected : false;
            this.lstSearchModes.IsMushlamModeSelected = (searchMode.IsMushlamSelected != null) ? (bool)searchMode.IsMushlamSelected : false;
            this.lstSearchModes.IsHospitalsModeSelected = (searchMode.IsHospitalsSelected != null) ? (bool)searchMode.IsHospitalsSelected : false;
            
            if (searchMode.IsHospitalsSelected != null)
            {
                this.lstSearchModes.IsHospitalsModeSelected = true;
            }
            else
            {
                this.lstSearchModes.IsHospitalsModeSelected = false;
            }
        }

    }

    public void SetScrollToLastSearch(Control containerControl, Control controlNeededToBeFocused)
    {
        HyperLink lnkToSelected = new HyperLink();
        lnkToSelected.NavigateUrl = "#" + controlNeededToBeFocused.ClientID;
        containerControl.Controls.Add(lnkToSelected);
        this.Page.ClientScript.RegisterStartupScript(this.GetType(), "goToSelected", lnkToSelected.ClientID + ".click(); ", true);
    }

    public void ResetSortingAndPaging(Control columnsContainerControl, SortableColumnHeader currentColumnSortBy)
    {
        foreach (Control ctrl in columnsContainerControl.Controls)
        {
            if (ctrl is SortableColumnHeader && ctrl != currentColumnSortBy)
            {
                ((SortableColumnHeader)ctrl).ResetSort();
            }
        }

        this.PagingControlsController.currentPage = 1;
        this.PagingControlsController.ResetSortingAndPagingParameters();
    }

    public void ReOrderSearch(Control containerControl, SortableColumnHeader columnToSortBy)
    {
        this.ResetSortingAndPaging(containerControl, columnToSortBy);

        this.PagingControlsController.ReOrderSearch(columnToSortBy.ColumnIdentifier.ToString(), (SortDirection)columnToSortBy.CurrentSortDirection);
    }

    public void SetSortingByDistanceAsc()
    {
        this.PagingControlsController.currentPage = 1;
        this.PagingControlsController.pageSize = 1000;

        this.PagingControlsController.sortingAndPagingParameters.OrderBy = "distance";
        this.PagingControlsController.sortingAndPagingParameters.SortingOrder = Convert.ToInt32(SortDirection.Ascending);
    }

    public void SetPagingControls(int numberOfRecords)
    {
        this.PagingControlsController.SetPagingControls(numberOfRecords);
    }

    public void RepeatLastSearch()
    {
        this.PagingControlsController.RepeatLastSearch();
    }

    public SearchPagingAndSortingDBParams GetPagingAndSortingDBParams()
    {
        return new SearchPagingAndSortingDBParams(  this.PagingControlsController.pageSize, this.PagingControlsController.currentPage,
                                                    this.PagingControlsController.sortingAndPagingParameters.SortingOrder,
                                                    this.PagingControlsController.sortingAndPagingParameters.OrderBy);
    }

    public void ReSortResults(Control columnsContainerControl, SortableColumnHeader columnToSortBy, DataView currentDataView,
                                                                        CompositeDataBoundControl resultsContainerControl)
    {
        this.ReOrderSearch(columnsContainerControl, columnToSortBy);

        if (this.IsClosestPointsSearchMode)
        {
            currentDataView.Sort = columnToSortBy.ColumnIdentifier.ToString() + " " + columnToSortBy.GetStringValueOfCurrentSort();

            resultsContainerControl.DataSource = currentDataView;
            resultsContainerControl.DataBind();
        }
        else
        {
            this.PagingControlsController.BindDataAndPaging();
        }
    }

    public void ReSortResults(Control columnsContainerControl, SortableColumnHeader columnToSortBy, DataView currentDataView,
                                                                        Repeater resultsContainerControl)
    {
        this.ReOrderSearch(columnsContainerControl, columnToSortBy);

        if (IsClosestPointsSearchMode)
        {
            currentDataView.Sort = columnToSortBy.ColumnIdentifier.ToString() + " " + columnToSortBy.GetStringValueOfCurrentSort();

            resultsContainerControl.DataSource = currentDataView;
            resultsContainerControl.DataBind();
        }
        else
        {
            this.PagingControlsController.BindDataAndPaging();
        }
    }


    /// <summary>
    /// sets the tab index by the given order
    /// </summary>
    /// <param name="arrOfControls">array of control ordered by the desired tab order </param>
    /// <param name="ctrlToBeFocused">the control needed to be focused first</param>
    public void SetTabIndexes(WebControl[] arrOfControls, Control ctrlToBeFocused)
    {
        for (short i = 1; i < arrOfControls.Length + 1; i++)
        {
            arrOfControls[i - 1].TabIndex = i;
        }

        if (ctrlToBeFocused != null)
        {
            this.Page.ClientScript.RegisterStartupScript(this.GetType(), "focus", "setTimeout(\" + document.getElementById('" +
                                                                ctrlToBeFocused.ClientID + "').focus();\",1000);", true);
        }
        //ctrlToBeFocused.Focus();
    }


    #region SearchPageStatusParameters

    private void SetSearchStatusInSession()
    {
        if (Session["SearchPageStatusParameters"] != null)
        {
            this.searchPageStatusParameters = (SearchPageStatusParameters)this.Session["SearchPageStatusParameters"];
            if (!this.IsPostBack)
            {
                this.searchPageStatusParameters.ShowSearchResult = true;
                this.Session["SearchPageStatusParameters"] = this.searchPageStatusParameters;
            }
        }
        else
        {
            this.searchPageStatusParameters = new SearchPageStatusParameters();
            this.Session["SearchPageStatusParameters"] = this.searchPageStatusParameters;

            //redirect to default page
            string[] pagePathParts = HttpContext.Current.Request.FilePath.Split(new char[] { '/' }, StringSplitOptions.RemoveEmptyEntries);
            string currentPageName = pagePathParts[pagePathParts.Length - 1];

            if (currentPageName != _DefaltPageName)
            {
                this.Response.Redirect(_DefaltPageName);
            }
        }

        //meaning we need to save the page that we just opened
        if (!this.IsPostBack)
        {
            this.searchPageStatusParameters.SetSelectedSearchPage(this.Request.Url.AbsolutePath);
        }

        if (this.cbNotShowSearchParameters.Checked == true)
        {
            this.searchPageStatusParameters.ShowSearchResult = false;
            // divGvServicesAndEventList.Style.Add("height", "360px");
        }
        else
        {
            this.searchPageStatusParameters.ShowSearchResult = true;
            // divGvServicesAndEventList.Style.Add("height", "335px");
        }
    }

    public Control GetDivButtonShowHide()
    {
        Control ctl = this.divButtonsShowHideMapContainer.FindControl(divButtonsShowHideMap.ID);
        this.divButtonsShowHideMapContainer.Controls.Remove(ctl);
        return ctl;
    }

    public void ResetLastSelectedRowIndex()
    {
        SessionParamsHandler.GetSessionParams().LastRowIndexOnSearchPage = -1;        
    }
    #endregion

    #region Reception time - days,hours criterias

    #region Get, Set methods

    public void SetReceptionTimeParametersByControls(SearchParametersBase searchParameters)
    {
        searchParameters.CurrentReceptionTimeInfo = GetReceptionTimeInfo();
    }

    private ReceptionTimeInfo GetReceptionTimeInfo()
    {
        ReceptionTimeInfo retVal = new ReceptionTimeInfo();

        retVal.ReceptionDays = UIHelper.getSelectedValuesFromCheckBoxList(cblReceptionDays);
        retVal.FromHour = this.txtFromHour.Text;
        retVal.ToHour = this.txtToHour.Text;
        retVal.InHour = this.txtAtHour.Text;
        retVal.OpenNow = this.cbOpenNow.Checked;

        return retVal;
    }

    //private ReceptionTimeInfo _ReceptionTimeToPopulateControls;

    public void RefreshReceptionTimeInfoControls(ReceptionTimeInfo receptionTime)
    {
        if (receptionTime != null)
        {
            string strReceptionDays = receptionTime.ReceptionDays;

            if (string.IsNullOrEmpty(strReceptionDays) == false)
            {
                string[] itemsArr = strReceptionDays.Split(',');
                for (int i = 0; i < cblReceptionDays.Items.Count; i++)
                {
                    for (int j = 0; j < itemsArr.Length; j++)
                    {
                        if (this.cblReceptionDays.Items[i].Value == itemsArr[j])
                            this.cblReceptionDays.Items[i].Selected = true;
                    }
                }
            }

            this.txtFromHour.Text = receptionTime.FromHour;
            this.txtToHour.Text = receptionTime.ToHour;
            this.txtAtHour.Text = receptionTime.InHour;
            this.cbOpenNow.Checked = receptionTime.OpenNow;
        }
    }

    #endregion

    private void BindReceptionDaysControls()
    {
        ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
        DataTable tbl = cacheHandler.getCachedDataTable(eCachedTables.DIC_ReceptionDays.ToString());
        DataView dv = new DataView(tbl, string.Format("{0} = 1", eDIC_ReceptionDaysEnum.UseInSearch), eDIC_ReceptionDaysEnum.ReceptionDayName.ToString(), DataViewRowState.CurrentRows);

        this.cblReceptionDays.DataSource = dv;
        this.cblReceptionDays.DataBind();
    }

    public void ClearReceptionTimeInfo()
    {
        for (int i = 0; i < this.cblReceptionDays.Items.Count; i++)
        {
            this.cblReceptionDays.Items[i].Selected = false;
        }

        this.txtFromHour.Text = string.Empty;
        this.txtToHour.Text = string.Empty;
        this.txtAtHour.Text = string.Empty;
    }

    #endregion

    #region MapSearchControls

    public TextBox TxtDistrictCodes
    {
        get
        {
            return this.txtDistrictCodes;
        }
    }

    public TextBox TxtDistrictList
    {
        get
        {
            return this.txtDistrictList;
        }
    }

    public TextBox TxtCity
    {
        get
        {
            return this.txtCityName;
        }

    }

    public TextBox TxtFromHour
    {
        get { return this.txtFromHour; }
    }

    public TextBox TxtToHour
    {
        get { return this.txtToHour; }
    }

    public TextBox TxtAtHour
    {
        get { return this.txtAtHour; }
    }

    public DropDownList DdlNumberOfRecordsToShow
    {
        get
        {

            return this.ddlNumberOfRecordsToShow;
        }
    }

    private void InitializeViewFromGlobalResources_MapSearchControls()
    {
        string notValidChar = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "NotValidChar_ErrorMess") as string;
        string notValidWords = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "PreservedWord_ErrorMess") as string;
        string notValidInteger = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "IntegerOnly_ErrorMess") as string;

        //---- Neighborhood
        this.VldRegexNeighborhood.ErrorMessage = string.Format(notValidChar, this.lblNeighborhood.Text);
        this.VldRegexNeighborhood.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.VldPreservedWordsNeighborhood.ErrorMessage = string.Format(notValidWords, this.lblNeighborhood.Text);

        //---- Street
        this.VldRegexStreet.ErrorMessage = string.Format(notValidChar, this.lblStreet.Text);
        this.VldRegexStreet.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.VldPreservedWordsStreet.ErrorMessage = string.Format(notValidWords, this.lblStreet.Text);

        //---- Site


        //---- House
        this.vldRegexHouse.ErrorMessage = string.Format(notValidChar, this.lblHome.Text);
        this.vldRegexHouse.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.vldPreservedWordsHouse.ErrorMessage = string.Format(notValidWords, this.lblHome.Text);

        this.lblCityName.CssClass = multiLineLabelCss;
        this.lblHome.CssClass = multiLineLabelCss;
        this.lblNeighborhood.CssClass = multiLineLabelCss;
        //this.lblNumberOfRecordsToShow.CssClass = multiLineLabelCss;
        this.lblDistrict.CssClass = multiLineLabelCss;

        this.lblStreet.CssClass = multiLineLabelCss;
    }

    public void ClearFields_MapSearchControls()
    {
        this.txtDistrictCodes.Text = string.Empty;
        this.txtDistrictList.Text = string.Empty;
        this.txtCityName.Text = String.Empty;
        this.txtCityCode.Text = String.Empty;

        this.txtNeighborhoodAndSite.Text = String.Empty;
        this.txtStreet.Text = String.Empty;

        this.txtHouse.Text = String.Empty;
    }

    /// <summary>
    /// gets the map information from the controls
    /// </summary>
    /// <param name="isCalculateCoordinates">if yes to goes to the web service 
    /// to get the coordinates by the controls adress information </param>
    /// <returns></returns>
    public MapSearchInfo GetMapInfo(bool isCalculateCoordinates)
    {
        MapSearchInfo retVal = new MapSearchInfo();

        retVal.CityName = this.txtCityName.Text;
        retVal.CityNameOnly = this.txtCityNameOnly.Text;
        retVal.Neighborhood = this.txtNeighborhoodAndSite.Text;
        retVal.NeighborhoodCode = this.txtNeighborhoodAndSiteCode.Text;
        retVal.Site = this.txtIsSite.Text;
        retVal.Street = this.txtStreet.Text;
        retVal.House = this.txtHouse.Text;

        if (isCalculateCoordinates == true)
        {
            this.CalculatedXYCoords(retVal);
        }

        return retVal;
    }

    public bool IsClosestPointsSearchMode
    {
        get
        {
            return this.cbIsClosestPointsSearchMode.Checked;
        }
    }

    public void CalculatedXYCoords(MapSearchInfo mapSearchInfo)
    {
        if (this.txtCityName.Text != string.Empty &&
                    (this.txtStreet.Text != string.Empty ||
                    this.txtNeighborhoodAndSite.Text != string.Empty ||
            //txtSite.Text != string.Empty ||
                    this.txtHouse.Text != string.Empty ||
                    this.cbIsClosestPointsSearchMode.Checked == true)
            )
        {
            string city = this.txtCityNameOnly.Text;
            int cityCode = int.Parse(this.txtCityCode.Text);
            string street = this.txtStreet.Text;
            int number = 0;
            string region = this.txtNeighborhoodAndSite.Text;
            //string atar = txtSite.Text;
            int.TryParse(txtHouse.Text, out number);

            MapCoordinatesClient cli = new MapCoordinatesClient(MapHelper.GetMapApplicationEnvironmentController());
            cli.XYSearchAccuracyState = MapCoordinatesClient.XYSearchAccuracyMode.FindBestStreetSpot;
            //CoordInfo coordInfoToReturn = cli.GetXY(city, street, number, region, atar);

            /* This function need to be change by Arik.*/
            string neighbourhoodOrInstituteCode = txtNeighborhoodAndSiteCode.Text;
            int? isSite;
            CoordInfo coordInfo;
            
            //if (txtIsSite.Text.Trim() == string.Empty)
            //    isSite = null;
            //else
            //    isSite = Convert.ToInt32(txtIsSite.Text);
            if (mapSearchInfo.Site == "1")
                isSite = 1;
            else if (mapSearchInfo.Site == "0")
                isSite = 0;
            else
                isSite = null;

            if (isSite == null)
                coordInfo = cli.GetXY(cityCode, street, number, string.Empty, string.Empty);
            else if (isSite == 1)
                coordInfo = cli.GetXY(cityCode, street, number, string.Empty, neighbourhoodOrInstituteCode);
            else
                coordInfo = cli.GetXY(cityCode, street, number, neighbourhoodOrInstituteCode, string.Empty);

            //CoordInfo coordInfoToReturn = cli.GetXY(cityCode, street, number, region, "");
            if (coordInfo != null)
            {
                mapSearchInfo.CoordinatX = coordInfo.X;
                mapSearchInfo.CoordinatY = coordInfo.Y;
            }
        }
    }

    private void RefreshMapInfoSearchControlsByParameters(SearchParametersBase clinicSearchParameters)
    {
        this.txtDistrictCodes.Text = clinicSearchParameters.DistrictCodes;
        this.txtDistrictList.Text = clinicSearchParameters.DistrictText;

        if (clinicSearchParameters.ShowMapSearchControls == true)
            this.cbIsClosestPointsSearchMode.Checked = true;
        else
            this.cbIsClosestPointsSearchMode.Checked = false;

        if (clinicSearchParameters.MapInfo != null)
        {
            this.txtCityCode.Text = clinicSearchParameters.MapInfo.CityCode.ToString();
            this.txtCityName.Text = clinicSearchParameters.MapInfo.CityName;
            this.txtCityNameOnly.Text = clinicSearchParameters.MapInfo.CityNameOnly;
            this.txtNeighborhoodAndSite.Text = clinicSearchParameters.MapInfo.Neighborhood;
            this.txtNeighborhoodAndSiteCode.Text = clinicSearchParameters.MapInfo.NeighborhoodCode;
            this.txtStreet.Text = clinicSearchParameters.MapInfo.Street;
            this.txtIsSite.Text = clinicSearchParameters.MapInfo.Site;
            this.txtHouse.Text = clinicSearchParameters.MapInfo.House;
        }
        this.ddlNumberOfRecordsToShow.SelectedValue = clinicSearchParameters.NumberOfRecordsToShow.ToString();
    }

    private void SetMapSearchParametersByControls(SearchParametersBase clinicSearchParameters)
    {
        clinicSearchParameters.DistrictCodes = this.txtDistrictCodes.Text;
        //clinicSearchParameters.DistrictNames = txtDistrictList.Text;
        clinicSearchParameters.DistrictText = this.txtDistrictList.Text;// ???

        if (this.cbIsClosestPointsSearchMode.Checked == true)
        {
            clinicSearchParameters.ShowMapSearchControls = true;
            if (this.ddlNumberOfRecordsToShow.SelectedIndex != -1)
            {
                clinicSearchParameters.NumberOfRecordsToShow = Convert.ToInt32(this.ddlNumberOfRecordsToShow.SelectedValue);
            }
            else
            {
                clinicSearchParameters.NumberOfRecordsToShow = null;
            }
        }
        else
        {
            clinicSearchParameters.ShowMapSearchControls = false;
            clinicSearchParameters.NumberOfRecordsToShow = null;
        }

        clinicSearchParameters.MapInfo = GetMapInfo(true);

        int cityCode = 0;
        if (int.TryParse(txtCityCode.Text.Trim(), out cityCode) == true)
        {
            clinicSearchParameters.MapInfo.CityCode = cityCode;
        }
    }

    #endregion

    #region Map

    public void RefreshMap(int? focusedDeptCode, DataTable dtResult, double? coordinateX, double? coordinateY, bool isNewLoad)
    {
        //there are 2 modes
        //1. find the closest depts to a given x,y coordinates
        //2. find one given dept

        DeptMapPopulateInfo deptMapInfo = SearchPageHelper.GetDeptMapPopulateInfo(focusedDeptCode, dtResult, coordinateX, coordinateY);
        DeptMapControl.RefreshMapDepts(deptMapInfo.AllDeptCodes, deptMapInfo.CoordX, deptMapInfo.CoordY, deptMapInfo.FocusedDeptCode, isNewLoad, true);
    }

    /// <summary>
    ///  when we have repeat search in closest point search mode we will want to load the map statically on start up
    ///because the user may want to see the results on the map  - in the normal situation  we load the map with markers
    ///when the user press submit
    /// </summary>
    public void RefreshMapOnRepeatSearch_IfRequired()
    {
        //special case -repeat last search
        if (Request.QueryString["RepeatSearch"] != null && IsClosestPointsSearchMode == true && this.IsPostBack == false)
        {
            //DeptMapControl.InitMapFrameOnStartup();
            //Page.ClientScript.RegisterStartupScript(typeof(string), "SpreadClosestPointsOnMap", "SpreadClosestPointsOnMap();", true);

            //ISearchPageController pageController = Page as ISearchPageController;

            //RefreshMap(null, pageController.DTSearchResults, pageController.PageSearchParameters.MapInfo.CoordinatX,
            //  pageController.PageSearchParameters.MapInfo.CoordinatY, true);

            Page.ClientScript.RegisterStartupScript(typeof(string), "RaiseClickSubmit", "RaiseClickSubmit();", true);
        }
    }

    /// <summary>
    /// showing/hiding the map - the master has its own conditions
    ///   whether to show the map but the using page can also have conditions for it, so the page can decide
    ///   that it doesn't want to show the map in some condition\s.
    ///   it's like allowing to show the map
    /// </summary>
    public bool IsAllowShowMap_PageCondition
    {
        get { return cbAllowShowMap_PageCondition.Checked; }
        set { cbAllowShowMap_PageCondition.Checked = value; }
    }

    #endregion

}
