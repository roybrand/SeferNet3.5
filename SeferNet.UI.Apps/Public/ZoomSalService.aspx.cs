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
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using System.Text;
using SeferNet.Globals;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using SeferNet.UI;
using System.Collections.Generic;
using System.Linq;
using System.Drawing;
using System.Web.Services;

public partial class ZoomSalService : System.Web.UI.Page
{
    DataSet m_dsService; //m_dsService is main DataSet on the page containing all the relevant dataTables
    DataSet m_dsServiceTarifon;
    DataSet m_dsServiceICD9;
    DataSet m_dsServiceInternetDetails;
    SessionParams sessionParams;
    int currentGroupCode = 0;
    UserInfo currentUserInfo;

    Facade applicFacade = Facade.getFacadeObject();
        
    public int m_ServiceCode
    {
        get
        {
            if (this.ViewState["ServiceCode"] != null)
                return (int)this.ViewState["ServiceCode"];
            else
                return 0;
        }
        set
        {
            this.ViewState["ServiceCode"] = value;
        }
    }

    bool m_isDeptPermittedForUser;

    private Dictionary<int, string> dicTabs = new Dictionary<int, string>() 
    { 
        { 1,  "divSalServiceDetailsBut,trSalServiceDetails,tdSalServiceDetailsTab" } ,
        { 2 , "divSalServiceTarifonBut,trSalServiceTarifon,tdSalServiceTarifonTab" } , 
        { 3 , "divSalServiceICD9But,trSalServiceICD9,tdSalServiceICD9Tab" } ,
        { 4 , "divSalServiceInternetDetailsBut,trSalServiceInternetDetails,tdSalServiceInternetDetailsTab" },
        { 5 , "divMushlamServicesBut,trMushlamServices,tdMushlamServicesTab" },
    };

    private SelectedSalServicesTab selectedTab;
    public SelectedSalServicesTab SelectedTab
    {
        get
        {
            if (this.ViewState["SelectedTab"] != null)
                return (SelectedSalServicesTab)this.ViewState["SelectedTab"];
            else
            {
                if (this.selectedTab == null || this.selectedTab == 0)
                {
                    this.ViewState["SelectedTab"] = SelectedSalServicesTab.ServiceDetails;
                    this.selectedTab = SelectedSalServicesTab.ServiceDetails;
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
        ServiceDetails = 1,
        Tarifon = 2,
        ICD9 = 3,
        InternetDetails = 4,
        MushlamServices = 5
    }

    public int CurrentMushlamServiceCode { get; set; }

    public int ServiceCode
    {
        get
        {
            return m_ServiceCode;
        }
    }

    private string CurrentSort
    {
        get
        {
            if (ViewState["currentSort"] != null)
                return ViewState["currentSort"].ToString();
            return "ActiveForSort";
        }
        set
        {
            ViewState["currentSort"] = value;
        }
    }

    private bool IsHistoryDetails
    {
        get
        {
            return (this.ddlSalServiceUpdateDates.SelectedIndex > 0);
        }
    }

    public SessionParams_SalServices SessionParams
    {
        get
        {
            if (this.Session["SessionParams_SalServices"] == null)
                this.Session["SessionParams_SalServices"] = new SessionParams_SalServices();

            return (SessionParams_SalServices)this.Session["SessionParams_SalServices"];
        }
    }

    public bool isAdvanceSearch = false;
    public string advanceSearchWord_ReplacedText = "";
    public const string AdvanceSearch_ReplacedTextFormat = "<span class=\"AdvanceSearchMark\">{0}</span>";

    #region Public permissions members

    public bool IsAdministrator = false;
    public bool CanManageTarifonViews = false;
    public bool CanViewTarifon = false;
    public bool CanManageInternetSalServices = false;

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        this.ClientScript.RegisterStartupScript(typeof(string), "SetTabToBeShownOnLoad", "SetTabToBeShownOnLoad();", true);

        if (!this.IsPostBack)
        {
            this.GetQueryString();

            this.m_isDeptPermittedForUser = this.applicFacade.IsDeptPermitted(m_ServiceCode);

            this.Context.Items["currServiceCode"] = m_ServiceCode;

            this.BindPageData();
        }

        if (this.Master.IsPostBackAfterLoginLogout)
        {
            this.m_isDeptPermittedForUser = this.applicFacade.IsDeptPermitted(m_ServiceCode);
            this.BindSalServiceInternetDetails();
        }

        sessionParams = SessionParamsHandler.GetSessionParams();
        sessionParams.DeptCode = -1;
        sessionParams.EmployeeID = -1;
        sessionParams.CallerUrl = Request.Url.OriginalString;
        sessionParams.CurrentEntityToReport = Enums.IncorrectDataReportEntity.SalService;
        sessionParams.ServiceCode = m_ServiceCode;

        SessionParamsHandler.SetSessionParams(sessionParams);
    }

    private void GetQueryString()
    {
        int iServiceCode = 0;
        if (!Int32.TryParse(this.Request.QueryString["ServiceCode"], out iServiceCode))
        {
            this.Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);
        }

        if (!string.IsNullOrEmpty(this.Request.QueryString["index"]))
        {
            int _LastRowIndexOnSearchPage = 0;
            if (int.TryParse(this.Request.QueryString["index"] , out _LastRowIndexOnSearchPage))
            {
                this.SessionParams.LastRowIndexOnSearchPage = _LastRowIndexOnSearchPage;
            }
        }

        if (!string.IsNullOrEmpty(this.Request.QueryString["tab"]))
        {
            int _LastSelectedTabOnSearchPage = 0;
            if (int.TryParse(this.Request.QueryString["tab"], out _LastSelectedTabOnSearchPage))
            {
                this.SessionParams.LastSelectedTabOnSearchPage = _LastSelectedTabOnSearchPage;
            }
        }

        this.m_ServiceCode = iServiceCode;
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        this.toggleUpdateButtons(); //display update buttons by permissions
    }

    public void BindPageData()
    {
        if (!this.SessionParams.IsEmpty)
        {
            // If the current search params contains search query that is associated with advance search make sure the "searched text" will be marked.
            if (!string.IsNullOrEmpty(this.SessionParams.AdvanceSearchText) && !string.IsNullOrEmpty(this.SessionParams.AdvanceSearchText))
            {
                this.isAdvanceSearch = true;
            }
        }

        this.SetPageViewByPermissions();

        this.BindSalServiceDetails();
        this.BindSalServiceTarifon();
        this.BindSalServiceICD9();
        this.BindSalServiceInternetDetails();

        // Set the selected tab:
        if (this.Request.QueryString["seltab"] != null)
        {
            int tabIndex = 0;
            if (int.TryParse(this.Request.QueryString["seltab"], out tabIndex))
            {
                if ( tabIndex > 3)
                {
                    if (currentUserInfo == null)
                    {
                        this.ClientScript.RegisterStartupScript(typeof(string), "SelectedTabIsForRegesteredOnlyAlert", "setTimeout(SelectedTabIsForRegesteredOnlyAlert, 100)", true);
                    }
                    else
                    {
                        if (!this.CanManageInternetSalServices)
                        {
                            //this.ClientScript.RegisterStartupScript(typeof(string), "SelectedTabIsForPermittedOnlyAlert", "setTimeout(SelectedTabIsForPermittedOnlyAlert,100);", true);
                            this.txtTabToBeShown.Text = this.dicTabs[tabIndex];     
                        }
                        else
                        { 
                            this.txtTabToBeShown.Text = this.dicTabs[tabIndex];                              
                        }
                    }
                }
                else
                { 
                    this.txtTabToBeShown.Text = this.dicTabs[tabIndex];               
                }
            }
        }
    }

    private void SetPageViewByPermissions()
    {
        UserManager userManager = new UserManager();
        currentUserInfo = userManager.GetUserInfoFromSession();

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

            this.phSalServiceTarifonTab.Visible = true;// (canViewTarifon || canManageTarifonViews || this.IsAdministrator);
            this.phSalServiceTarifon.Visible = true;// (canViewTarifon || canManageTarifonViews || this.IsAdministrator);
            
        }
        else
        {
            //this.Response.Redirect("SearchClinics.aspx");
            this.phSalServiceTarifonTab.Visible = true;
            this.phSalServiceTarifon.Visible = true;
        }
    }

    public void BindSalServiceDetails()
    {
        // Check the selected date of the service details to see if the latest details should be taken from the database or they should be taken as history details:
        // Enter here only if this is the first load of the page - to bind the general view of the page.

        if (this.ddlSalServiceUpdateDates.SelectedIndex == 0 || !this.IsPostBack)
        {
            this.lblDatefrom.Text = string.Empty;

            this.m_dsService = this.applicFacade.GetSalServiceDetails(this.m_ServiceCode);

            if (this.m_dsService != null && this.m_dsService.Tables.Count > 0 && this.m_dsService.Tables[0].Rows.Count > 0)
            {
                DataRow drServiceDetails = this.m_dsService.Tables[0].Rows[0];

                if (!this.IsPostBack)
                {
                    UIHelper.SetImageForDeptAttribution(ref this.imgAttributed_1, false, false, false, 0);
                    UIHelper.SetImageForDeptAttribution(ref this.imgAttributed_2, false, false, false, 0);
                    UIHelper.SetImageForDeptAttribution(ref this.imgAttributed_3, false, false, false, 0);
                    UIHelper.SetImageForDeptAttribution(ref this.imgAttributed_4, false, false, false, 0);
                }

                int iscanceled = 0;
                if (drServiceDetails["IsCanceled"] != DBNull.Value)
                    iscanceled = Convert.ToInt32(drServiceDetails["IsCanceled"]);

                int includeInBasket = Convert.ToInt32(drServiceDetails["IncludeInBasket"]);
                //int formcode = Convert.ToInt32(drServiceDetails["FormCode"]);
                int limiter = Convert.ToInt32(drServiceDetails["Limiter"]);

                #region IncludeInBasket View

                ColorConverter ccConvertor = new ColorConverter();


                if (iscanceled == 1)
                {
                    if (drServiceDetails["DEL_DATE"] != DBNull.Value)
                    {
                        DateTime delDate = (DateTime)drServiceDetails["DEL_DATE"];

                        this.lblIncludeInBasket.ForeColor = (Color)ccConvertor.ConvertFromString("#aa0e1c");
                        this.lblIncludeInBasket.Font.Size = FontUnit.Parse("24px");
                        this.lblIncludeInBasket.Text = "מבוטל";
                        this.tdIncludeInBasket.Style.Add("border", "1px solid #aa0e1c");

                        this.lblDatefrom.ForeColor = (Color)ccConvertor.ConvertFromString("#aa0e1c");
                        this.lblDatefrom.Font.Size = FontUnit.Parse("16px");
                        this.lblDatefrom.Text = "   מבוטל מתאריך:  " + delDate.ToString("dd/MM/yyyy");

                    }
                    else
                    {
                        this.lblIncludeInBasket.ForeColor = (Color)ccConvertor.ConvertFromString("#e36c09");
                        this.lblIncludeInBasket.Font.Size = FontUnit.Parse("26px");
                        this.lblIncludeInBasket.Text = "בסל מוגבל";
                        this.tdIncludeInBasket.Style.Add("border", "1px solid #e36c09");
                    }
                }
                else
                {
                    if (includeInBasket == 1)
                    {
                        this.lblIncludeInBasket.Text = "כלול בסל";
                        this.lblIncludeInBasket.Font.Size = FontUnit.Parse("26px");
                        this.lblIncludeInBasket.ForeColor = (Color)ccConvertor.ConvertFromString("#62a61f");
                        this.tdIncludeInBasket.Style.Add("border", "1px solid #62a61f");
                    }
                    else
                    {
                        if (limiter > 0)
                        {
                            this.lblIncludeInBasket.Text = "בסל מוגבל";
                            this.lblIncludeInBasket.ForeColor = (Color)ccConvertor.ConvertFromString("#e36c09");
                            this.lblIncludeInBasket.Font.Size = FontUnit.Parse("26px");
                            this.tdIncludeInBasket.Style.Add("border", "1px solid #e36c09");
                        }
                        else
                        {
                            this.lblIncludeInBasket.Text = "לא כלול בסל";
                            this.lblIncludeInBasket.Font.Size = FontUnit.Parse("26px");
                            this.lblIncludeInBasket.ForeColor = (Color)ccConvertor.ConvertFromString("#aa0e1c");
                            this.tdIncludeInBasket.Style.Add("border", "1px solid #aa0e1c");
                        }
                    }
                }

                #endregion

                string serviceName = drServiceDetails["ServiceName"].ToString();
                if (this.isAdvanceSearch)
                {
                    this.advanceSearchWord_ReplacedText = string.Format(AdvanceSearch_ReplacedTextFormat, this.SessionParams.AdvanceSearchText);
                    serviceName = serviceName.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                }

                // Don't mark the text in the title.
                this.lblSalServiceName.Text = drServiceDetails["ServiceName"].ToString();
                this.lblSalServiceCode.Text = drServiceDetails["ServiceCode"].ToString() + " - ";
                this.lblSalServiceMIN_CODE.Text = drServiceDetails["MIN_CODE"].ToString() + " - ";

                this.lblSalServiceName2.Text = drServiceDetails["ServiceName"].ToString();
                this.lblSalServiceCode2.Text = drServiceDetails["ServiceCode"].ToString() + " - ";
                this.lblSalServiceMIN_CODE2.Text = drServiceDetails["MIN_CODE"].ToString() + " - ";

                this.lblSalServiceName3.Text = drServiceDetails["ServiceName"].ToString();
                this.lblSalServiceCode3.Text = drServiceDetails["ServiceCode"].ToString() + " - ";
                this.lblSalServiceMIN_CODE3.Text = drServiceDetails["MIN_CODE"].ToString() + " - ";

                this.lblSalServiceName4.Text = drServiceDetails["ServiceName"].ToString();
                this.lblSalServiceCode4.Text = drServiceDetails["ServiceCode"].ToString() + " - ";
                this.lblSalServiceMIN_CODE4.Text = drServiceDetails["MIN_CODE"].ToString() + " - ";



                #region General Details

                this.lblServiceCode.Text = drServiceDetails["ServiceCode"].ToString();
                this.lblMinCode.Text = drServiceDetails["Min_Code"].ToString();

                this.phGovernmentServiceCode.Visible = false;

                this.lblServiceName.Text = serviceName;
                this.lblServiceNameEnglish.Text = drServiceDetails["EngName"].ToString();

                this.lblLimitationComment.Text = drServiceDetails["LimitationComment"].ToString();
                this.lblFormType.Text = drServiceDetails["FormType"].ToString();

                #endregion

                #region Service Additional Details

                StringBuilder sbSynonyms = new StringBuilder();

                string synonym1 = drServiceDetails["Synonym1"].ToString();
                string synonym2 = drServiceDetails["Synonym2"].ToString();
                string synonym3 = drServiceDetails["Synonym3"].ToString();
                string synonym4 = drServiceDetails["Synonym4"].ToString();
                string synonym5 = drServiceDetails["Synonym5"].ToString();

                if (this.isAdvanceSearch)
                {
                    synonym1 = synonym1.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                    synonym2 = synonym2.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                    synonym3 = synonym3.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                    synonym4 = synonym4.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                    synonym5 = synonym5.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                }

                if (!string.IsNullOrEmpty(synonym1))
                {
                    this.lblSynonym.Text += synonym1;
                    sbSynonyms.Append(synonym1);
                }

                if (!string.IsNullOrEmpty(synonym2))
                {
                    if (!string.IsNullOrEmpty(this.lblSynonym.Text))
                        this.lblSynonym.Text += "<br/>" + synonym2;
                    else
                        this.lblSynonym.Text += synonym2;

                    if (sbSynonyms.Length > 0)
                        sbSynonyms.Append(", ");

                    sbSynonyms.Append(synonym2);
                }

                if (!string.IsNullOrEmpty(synonym3))
                {
                    if (!string.IsNullOrEmpty(this.lblSynonym.Text))
                        this.lblSynonym.Text += "<br/>" + synonym3;
                    else
                        this.lblSynonym.Text += synonym3;

                    if (sbSynonyms.Length > 0)
                        sbSynonyms.Append(", ");

                    sbSynonyms.Append(synonym3);
                }

                if (!string.IsNullOrEmpty(synonym4))
                {
                    if (!string.IsNullOrEmpty(this.lblSynonym.Text))
                        this.lblSynonym.Text += "<br/>" + synonym4;
                    else
                        this.lblSynonym.Text += synonym4;

                    if (sbSynonyms.Length > 0)
                        sbSynonyms.Append(", ");

                    sbSynonyms.Append(synonym4);
                }


                if (!string.IsNullOrEmpty(synonym5))
                {
                    if (!string.IsNullOrEmpty(this.lblSynonym.Text))
                        this.lblSynonym.Text += "<br/>" + synonym5;
                    else
                        this.lblSynonym.Text += synonym5;

                    if (sbSynonyms.Length > 0)
                        sbSynonyms.Append(", ");

                    sbSynonyms.Append(synonym5);
                }

                this.lblInterDetails_Synonym.Text = sbSynonyms.ToString();

                if (!string.IsNullOrEmpty(drServiceDetails["BudgetDesc"].ToString()))
                    this.lblBudgetDesc.Text = drServiceDetails["BudgetCode"].ToString() + " - " + drServiceDetails["BudgetDesc"].ToString();

                if (!string.IsNullOrEmpty(drServiceDetails["EshkolDesc"].ToString()))
                    this.lblEshkolDesc.Text = drServiceDetails["EshkolCode"].ToString() + " - " + drServiceDetails["EshkolDesc"].ToString();

                if (!string.IsNullOrEmpty(drServiceDetails["PaymentRules"].ToString()))
                    this.lblPaymentRules.Text = drServiceDetails["PaymentCode"] + " - " + drServiceDetails["PaymentRules"].ToString();

                // Omri Return Codes binding:
                DataTable dtOmriReturns = this.m_dsService.Tables[3];
                if (dtOmriReturns.Rows.Count > 0)
                {
                    StringBuilder sbOmriReturns = new StringBuilder();
                    for (int i = 0; i < dtOmriReturns.Rows.Count; i++)
                    {
                        DataRow drOmriReturns = dtOmriReturns.Rows[i];

                        sbOmriReturns.Append(drOmriReturns["ReturnCode"]);
                        sbOmriReturns.Append(" - ");
                        sbOmriReturns.Append(drOmriReturns["ReturnDescription"]);
                        sbOmriReturns.Append("<br />");
                    }

                    this.lblOmriReturns.Text = sbOmriReturns.ToString();
                }

                #endregion

                DataTable dtGeneralManagementComment = this.m_dsService.Tables[4];
                if (dtGeneralManagementComment.Rows.Count > 0)
                {
                    StringBuilder sbGeneralManagementComment = new StringBuilder();

                    for (int i = 0; i < dtGeneralManagementComment.Rows.Count; i++)
                    {
                        DataRow drGeneralManagementComment = dtGeneralManagementComment.Rows[i];

                        if (drGeneralManagementComment["Description"].ToString().Length > 1)
                        {
                            string description = drGeneralManagementComment["Description"].ToString();
                            if (this.isAdvanceSearch)
                            {
                                description = description.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                            }

                            sbGeneralManagementComment.Append(description);
                        }

                        sbGeneralManagementComment.Append(Environment.NewLine);
                        sbGeneralManagementComment.Append("<br/>");
                    }

                    this.lblGeneralManagementInstructions.Text = sbGeneralManagementComment.ToString();
                }

                #region Management Instructions

                DataTable dtManagementGuidances = this.m_dsService.Tables[5];
                if (dtManagementGuidances.Rows.Count > 0)
                {
                    StringBuilder sbManagementGuidances = new StringBuilder();

                    // Set the header of the "Management Guidances" table:
                    sbManagementGuidances.Append("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"600\">" + Environment.NewLine);
                    sbManagementGuidances.Append("<tr>" + Environment.NewLine);
                    sbManagementGuidances.Append("<td>אבחנה</td>" + Environment.NewLine);
                    sbManagementGuidances.Append("<td>גיל</td>" + Environment.NewLine);
                    sbManagementGuidances.Append("<td>שרות כללית/ב''ח ציבורי/מכון בהסדר </td>" + Environment.NewLine);
                    sbManagementGuidances.Append("<td>טיפול</td>" + Environment.NewLine);
                    sbManagementGuidances.Append("<td>הערה</td>" + Environment.NewLine);
                    sbManagementGuidances.Append("</tr>" + Environment.NewLine);


                    DataTable dtManagementGuidances_Unified = dtManagementGuidances.Copy();
                    dtManagementGuidances_Unified.Rows.Clear();

                    StringBuilder sbDiagnostics = new StringBuilder();
                    StringBuilder sbAge = new StringBuilder();
                    StringBuilder sbPublicFacility = new StringBuilder();
                    StringBuilder sbTreatment = new StringBuilder();
                    StringBuilder sbComment = new StringBuilder();

                    int entrance = 0;
                    bool newEntrance = false;

                    for (int i = 0; i < dtManagementGuidances.Rows.Count; i++)
                    {
                        DataRow drManagementGuidances = dtManagementGuidances.Rows[i];

                        // Check if this is a new row (Is there is '*' in the TableBreak Column)
                        if ((drManagementGuidances["TableBreak"].ToString() == "*" && i > 0))
                        {
                            // Add the current values string builders values as a new row to the new datatable 'dtManagementGuidances_Unified'
                            DataRow newGuidancesRow = dtManagementGuidances_Unified.NewRow();

                            newGuidancesRow["diagnostics"] = sbDiagnostics.ToString();
                            newGuidancesRow["Age"] = sbAge.ToString();
                            newGuidancesRow["PublicFacility"] = sbPublicFacility.ToString();
                            newGuidancesRow["Treatment"] = sbTreatment.ToString();
                            newGuidancesRow["Comment"] = sbComment.ToString();

                            dtManagementGuidances_Unified.Rows.Add(newGuidancesRow);

                            // After adding the new row clear all the previous values:
                            sbDiagnostics.Clear();
                            sbAge.Clear();
                            sbPublicFacility.Clear();
                            sbTreatment.Clear();
                            sbComment.Clear();
                        }
                        else if ((int)drManagementGuidances["entrance"] != entrance && entrance != 0)
                        {
                            newEntrance = true;
                        }

                        if (!string.IsNullOrEmpty(drManagementGuidances["diagnostics"].ToString()))
                        {
                            //if (sbDiagnostics.Length > 0)
                            //    sbDiagnostics.Append(" ");

                            if (newEntrance)
                                sbDiagnostics.Append("<br />");

                            if (sbDiagnostics.Length > 0)
                                sbDiagnostics.Append(" ");

                            sbDiagnostics.Append(drManagementGuidances["diagnostics"]);
                        }

                        if (!string.IsNullOrEmpty(drManagementGuidances["age"].ToString()))
                        {
                            if (sbAge.Length > 0)
                                sbAge.Append("<br />");
                            sbAge.Append(drManagementGuidances["age"]);
                        }

                        if (!string.IsNullOrEmpty(drManagementGuidances["publicfacility"].ToString()))
                        {
                            //if (sbPublicFacility.Length > 0)
                            //    sbPublicFacility.Append(" ");

                            if (newEntrance)
                                sbPublicFacility.Append("<br />");

                            if (sbPublicFacility.Length > 0)
                                sbPublicFacility.Append(" ");

                            sbPublicFacility.Append(drManagementGuidances["publicfacility"]);
                        }

                        if (!string.IsNullOrEmpty(drManagementGuidances["treatment"].ToString()))
                        {
                            //if (sbTreatment.Length > 0)
                            //    sbTreatment.Append(" ");

                            if (newEntrance)
                                sbTreatment.Append("<br />");

                            if (sbTreatment.Length > 0)
                                sbTreatment.Append(" ");

                            sbTreatment.Append(drManagementGuidances["treatment"]);
                        }

                        if (!string.IsNullOrEmpty(drManagementGuidances["comment"].ToString()))
                        {
                            //if (sbComment.Length > 0)
                            //    sbComment.Append(" ");

                            if (newEntrance)
                                sbComment.Append("<br />");

                            if (sbComment.Length > 0)
                                sbComment.Append(" ");

                            sbComment.Append(drManagementGuidances["comment"]);
                        }

                        entrance = (int)drManagementGuidances["entrance"];
                        newEntrance = false;

                        if (i == dtManagementGuidances.Rows.Count - 1)
                        {
                            // Add the current values string builders values as a new row to the new datatable 'dtManagementGuidances_Unified'
                            DataRow newGuidancesRow = dtManagementGuidances_Unified.NewRow();

                            newGuidancesRow["diagnostics"] = sbDiagnostics.ToString();
                            newGuidancesRow["Age"] = sbAge.ToString();
                            newGuidancesRow["PublicFacility"] = sbPublicFacility.ToString();
                            newGuidancesRow["Treatment"] = sbTreatment.ToString();
                            newGuidancesRow["Comment"] = sbComment.ToString();

                            dtManagementGuidances_Unified.Rows.Add(newGuidancesRow);

                            // After adding the new row clear all the previous values:
                            sbDiagnostics.Clear();
                            sbAge.Clear();
                            sbPublicFacility.Clear();
                            sbTreatment.Clear();
                            sbComment.Clear();
                        }
                    }

                    this.rGuidances.DataSource = dtManagementGuidances_Unified;
                    this.rGuidances.DataBind();
                }

                #endregion

                #region Medical Instructions

                DataTable dtMedicalInstructions = this.m_dsService.Tables[6];
                if (dtMedicalInstructions.Rows.Count > 0)
                {
                    StringBuilder sbMedicalInstructions = new StringBuilder();

                    for (int i = 0; i < dtMedicalInstructions.Rows.Count; i++)
                    {
                        DataRow drMedicalInstructions = dtMedicalInstructions.Rows[i];

                        sbMedicalInstructions.Append("<span dir='rtl'>");
                        sbMedicalInstructions.Append(drMedicalInstructions["Description"].ToString().Trim());
                        sbMedicalInstructions.Append("</span>");
                        sbMedicalInstructions.Append(Environment.NewLine);
                        sbMedicalInstructions.Append("<br/>");
                    }

                    this.lblMedicalInstructions.Text = sbMedicalInstructions.ToString();
                    if (this.SessionParams.AdvanceSearchText != null && this.SessionParams.AdvanceSearchText != string.Empty)
                        lblMedicalInstructions.Text = lblMedicalInstructions.Text.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);

                }
                else
                {
                    lblMedicalInstructions.Text = string.Empty;
                }


                #endregion

                this.lblUpdateDateFld.Text = Convert.ToDateTime(this.m_dsService.Tables[1].Rows[0]["LastSalUpdateDate"]).ToString("dd/MM/yyyy");
                this.lblUpdateDateFld_Tarifon.Text = Convert.ToDateTime(this.m_dsService.Tables[1].Rows[0]["LastSalUpdateDate"]).ToString("dd/MM/yyyy");
                this.lblUpdateDateFld_ICD9.Text = Convert.ToDateTime(this.m_dsService.Tables[1].Rows[0]["LastSalUpdateDate"]).ToString("dd/MM/yyyy");
                this.lblUpdateDateFld_InternetDetails.Text = Convert.ToDateTime(this.m_dsService.Tables[1].Rows[0]["LastSalUpdateDate"]).ToString("dd/MM/yyyy");

                // Bind sal services update dates combo:
                this.ddlSalServiceUpdateDates.DataSource = this.m_dsService.Tables[2];
                this.ddlSalServiceUpdateDates.DataBind();
                //this.ddlSalServiceUpdateDates.Items.Insert(0, new ListItem(this.lblUpdateDateFld.Text, this.lblUpdateDateFld.Text));

                #region Sal
                frmMushlamServices.Attributes["src"] = "MushlamServices.aspx?salServiceCode=" + ServiceCode +
                    "&ServiceName=" +
                    drServiceDetails["MIN_CODE"].ToString() + " - " +
                    drServiceDetails["ServiceCode"].ToString() + " - " +
                    drServiceDetails["ServiceName"].ToString();


                #endregion 
            }
        }
        else
        {
            if (this.ddlSalServiceUpdateDates.Items.Count > 0)
            {
                DateTime dtUpdateDate = DateTime.Parse(this.ddlSalServiceUpdateDates.SelectedValue);

                // Though we need the history details of the service we might need some current details of service.
                this.m_dsService = this.applicFacade.GetSalServiceDetails(this.m_ServiceCode);
                DataRow drServiceDetails = this.m_dsService.Tables[0].Rows[0];

                DataSet dsHistoryServiceDetails = this.applicFacade.GetSalServiceHistoryDetails(this.m_ServiceCode, dtUpdateDate);

                if (dsHistoryServiceDetails.Tables.Count > 0 && dsHistoryServiceDetails.Tables[0].Rows.Count > 0)
                {
                    DataRow drServiceHistoryDetails = dsHistoryServiceDetails.Tables[0].Rows[0];

                    int isCanceled = Convert.ToInt32(drServiceHistoryDetails["isCanceled"]);
                    int includeInBasket = Convert.ToInt32(drServiceHistoryDetails["IncludeInBasket"]);
                    //int formcode = Convert.ToInt32(drServiceHistoryDetails["FormCode"]);
                    int limiter = Convert.ToInt32(drServiceHistoryDetails["Limiter"]);

                    #region General Details

                    #region IncludeInBasket View

                    ColorConverter ccConvertor = new ColorConverter();

                    if (isCanceled == 1)
                    {
                        DateTime delDate = (DateTime)drServiceDetails["DEL_DATE"];
                        this.lblIncludeInBasket.ForeColor = (Color)ccConvertor.ConvertFromString("#aa0e1c");
                        this.lblIncludeInBasket.Font.Size = FontUnit.Parse("24px");
                        this.lblIncludeInBasket.Text = "מבוטל";
                        this.tdIncludeInBasket.Style.Add("border", "1px solid #aa0e1c");

                        //this.lblDatefrom.ForeColor = (Color)ccConvertor.ConvertFromString("#aa0e1c");
                        //this.lblDatefrom.Font.Size = FontUnit.Parse("16px");
                        //this.lblDatefrom.Text = delDate.ToString("dd/MM/yyyy");
                    }
                    else
                    {
                        if (includeInBasket == 1)
                        {
                            this.lblIncludeInBasket.Text = "כלול בסל";
                            this.lblIncludeInBasket.Font.Size = FontUnit.Parse("26px");
                            this.lblIncludeInBasket.ForeColor = (Color)ccConvertor.ConvertFromString("#62a61f");
                            this.tdIncludeInBasket.Style.Add("border", "1px solid #62a61f");
                        }
                        else
                        {
                            if (limiter > 0)
                            {
                                this.lblIncludeInBasket.Text = "בסל מוגבל";
                                this.lblIncludeInBasket.ForeColor = (Color)ccConvertor.ConvertFromString("#e36c09");
                                this.lblIncludeInBasket.Font.Size = FontUnit.Parse("26px");
                                this.tdIncludeInBasket.Style.Add("border", "1px solid #e36c09");
                            }
                            else
                            {
                                this.lblIncludeInBasket.Text = "לא כלול בסל";
                                this.lblIncludeInBasket.Font.Size = FontUnit.Parse("26px");
                                this.lblIncludeInBasket.ForeColor = (Color)ccConvertor.ConvertFromString("#aa0e1c");
                                this.tdIncludeInBasket.Style.Add("border", "1px solid #aa0e1c");
                            }
                        }
                    }

                    #endregion

                    this.lblServiceCode.Text = drServiceHistoryDetails["ServiceCode"].ToString();

                    string governmentServiceCode = drServiceHistoryDetails["GovernmentServiceCode"].ToString();

                    int guidancesType = 0;
                    if (drServiceHistoryDetails["GuidancesType"] != null && drServiceHistoryDetails["GuidancesType"] != DBNull.Value)
                        guidancesType = (int)drServiceHistoryDetails["GuidancesType"];

                    if (string.IsNullOrEmpty(governmentServiceCode) || governmentServiceCode == "00000")
                    {
                        if (guidancesType == 9)
                            this.lblMinCode.Text = drServiceHistoryDetails["InternalGovernmentServiceCode"].ToString();
                        else
                            this.lblMinCode.Text = drServiceDetails["Min_Code"].ToString();
                    }
                    else
                    {
                        this.lblMinCode.Text = governmentServiceCode;
                        if (governmentServiceCode.ToLower().StartsWith("K"))
                        {
                            this.phGovernmentServiceCode.Visible = true;
                        }
                    }

                    #endregion

                    #region Service Additional Details

                    this.lblSynonym.Text = "";
                    this.lblBudgetDesc.Text = "";
                    this.lblEshkolDesc.Text = "";
                    this.lblPaymentRules.Text = "";
                    this.lblOmriReturns.Text = "";

                    #endregion

                    DataTable dtManagementGuidances = dsHistoryServiceDetails.Tables[1];
                    if (dtManagementGuidances.Rows.Count > 0)
                    {
                    #region Management Instructions
                        StringBuilder sbManagementGuidances = new StringBuilder();

                        // Set the header of the "Management Guidances" table:
                        sbManagementGuidances.Append("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"600\">" + Environment.NewLine);
                        sbManagementGuidances.Append("<tr>" + Environment.NewLine);
                        sbManagementGuidances.Append("<td>אבחנה</td>" + Environment.NewLine);
                        sbManagementGuidances.Append("<td>גיל</td>" + Environment.NewLine);
                        sbManagementGuidances.Append("<td>שרות כללית/ב''ח ציבורי/מכון בהסדר </td>" + Environment.NewLine);
                        sbManagementGuidances.Append("<td>טיפול</td>" + Environment.NewLine);
                        sbManagementGuidances.Append("<td>הערה</td>" + Environment.NewLine);
                        sbManagementGuidances.Append("</tr>" + Environment.NewLine);


                        DataTable dtManagementGuidances_Unified = dtManagementGuidances.Copy();
                        dtManagementGuidances_Unified.Rows.Clear();

                        StringBuilder sbDiagnostics = new StringBuilder();
                        StringBuilder sbAge = new StringBuilder();
                        StringBuilder sbPublicFacility = new StringBuilder();
                        StringBuilder sbTreatment = new StringBuilder();
                        StringBuilder sbComment = new StringBuilder();

                        int entrance = 0;
                        bool newEntrance = false;

                        for (int i = 0; i < dtManagementGuidances.Rows.Count; i++)
                        {
                            DataRow drManagementGuidances = dtManagementGuidances.Rows[i];

                            // Check if this is a new row (Is there is '*' in the TableBreak Column) Or if its the last row...
                            if ((drManagementGuidances["TableBreak"].ToString() == "*" && i > 0) || i == dtManagementGuidances.Rows.Count - 1)
                            {
                                // Add the current values string builders values as a new row to the new datatable 'dtManagementGuidances_Unified'
                                DataRow newGuidancesRow = dtManagementGuidances_Unified.NewRow();

                                newGuidancesRow["diagnostics"] = sbDiagnostics.ToString();
                                newGuidancesRow["Age"] = sbAge.ToString();
                                newGuidancesRow["PublicFacility"] = sbPublicFacility.ToString();
                                newGuidancesRow["Treatment"] = sbTreatment.ToString();
                                newGuidancesRow["Comment"] = sbComment.ToString();

                                dtManagementGuidances_Unified.Rows.Add(newGuidancesRow);

                                // After adding the new row clear all the previous values:
                                sbDiagnostics.Clear();
                                sbAge.Clear();
                                sbPublicFacility.Clear();
                                sbTreatment.Clear();
                                sbComment.Clear();
                            }
                            else if ((int)drManagementGuidances["entrance"] != entrance && entrance != 0)
                            {
                                newEntrance = true;
                            }

                            if (!string.IsNullOrEmpty(drManagementGuidances["diagnostics"].ToString()))
                            {
                                //if (sbDiagnostics.Length > 0)
                                //    sbDiagnostics.Append(" ");

                                if (newEntrance)
                                    sbDiagnostics.Append("<br />");

                                if (sbDiagnostics.Length > 0)
                                    sbDiagnostics.Append(" ");

                                sbDiagnostics.Append(drManagementGuidances["diagnostics"]);
                            }

                            if (!string.IsNullOrEmpty(drManagementGuidances["age"].ToString()))
                            {
                                if (sbAge.Length > 0)
                                    sbAge.Append("<br />");

                                sbAge.Append(drManagementGuidances["age"]);
                            }

                            if (!string.IsNullOrEmpty(drManagementGuidances["publicfacility"].ToString()))
                            {
                                //if (sbPublicFacility.Length > 0)
                                //    sbPublicFacility.Append(" ");

                                if (newEntrance)
                                    sbPublicFacility.Append("<br />");

                                sbPublicFacility.Append(drManagementGuidances["publicfacility"]);
                            }

                            if (!string.IsNullOrEmpty(drManagementGuidances["treatment"].ToString()))
                            {
                                if (newEntrance)
                                    sbTreatment.Append("<br />");
                                else
                                {
                                    if (sbTreatment.Length > 0)
                                        sbTreatment.Append(" ");

                                    sbTreatment.Append(drManagementGuidances["treatment"].ToString().Replace(" ,", ","));
                                }

                                if (!string.IsNullOrEmpty(drManagementGuidances["comment"].ToString()))
                                {
                                    if (newEntrance)
                                        sbComment.Append("<br />");
                                    else
                                    {
                                        if (sbComment.Length > 0)
                                            sbComment.Append(" ");
                                    }

                                    sbComment.Append(drManagementGuidances["comment"].ToString().Replace(" ,", ","));
                                }

                                entrance = (int)drManagementGuidances["entrance"];
                                newEntrance = false;
                            }

                            this.rGuidances.DataSource = dtManagementGuidances_Unified;
                            this.rGuidances.DataBind();
                        }

                    #endregion

                    }

                    DataTable dtGeneralManagementComment = dsHistoryServiceDetails.Tables[3];
                    #region General Management Instructions
                    if (dtGeneralManagementComment.Rows.Count > 0)
                    {
                        StringBuilder sbGeneralManagementComment = new StringBuilder();

                        for (int i = 0; i < dtGeneralManagementComment.Rows.Count; i++)
                        {
                            DataRow drGeneralManagementComment = dtGeneralManagementComment.Rows[i];

                            if (drGeneralManagementComment["Description"].ToString().Length > 1)
                            {
                                string description = drGeneralManagementComment["Description"].ToString();
                                if (this.isAdvanceSearch)
                                {
                                    description = description.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                                }

                                sbGeneralManagementComment.Append(description);
                            }

                            sbGeneralManagementComment.Append(Environment.NewLine);
                            sbGeneralManagementComment.Append("<br/>");
                        }

                        this.lblGeneralManagementInstructions.Text = sbGeneralManagementComment.ToString();
                    }
                    #endregion

                    DataTable dtMedicalInstructions = dsHistoryServiceDetails.Tables[2];
                    #region Medical Instructions
                    if (dtMedicalInstructions.Rows.Count > 0)
                    {

                        StringBuilder sbMedicalInstructions = new StringBuilder();

                        for (int i = 0; i < dtMedicalInstructions.Rows.Count; i++)
                        {
                            DataRow drMedicalInstructions = dtMedicalInstructions.Rows[i];

                            sbMedicalInstructions.Append(drMedicalInstructions["Description"]);
                            sbMedicalInstructions.Append(Environment.NewLine);
                            sbMedicalInstructions.Append("<br/>");
                        }

                        this.lblMedicalInstructions.Text = sbMedicalInstructions.ToString();
                        if (this.SessionParams.AdvanceSearchText != null && this.SessionParams.AdvanceSearchText != string.Empty)
                            lblMedicalInstructions.Text = lblMedicalInstructions.Text.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                    }
                    else
                    {
                        lblMedicalInstructions.Text = string.Empty;
                    }

                    #endregion

                }
                #region clear
                if (dsHistoryServiceDetails.Tables[1].Rows.Count == 0)//dtManagementGuidances
                { 
                }
                if (dsHistoryServiceDetails.Tables[3].Rows.Count == 0)//dtGeneralManagementComment
                {
                    this.lblGeneralManagementInstructions.Text = string.Empty;
                }
                if (dsHistoryServiceDetails.Tables[2].Rows.Count == 0)//dtMedicalInstructions
                {
                    this.lblMedicalInstructions.Text = string.Empty;
                }

                    //DataTable dt = new DataTable();
                    //this.rGuidances.DataSource = dt;
                    //this.rGuidances.DataBind();

                #endregion
            }
        }
            // Hozrei Sherut - Vadim Rasin - 05.03.2013
        if (Convert.ToBoolean(m_dsService.Tables[0].Rows[0]["ServiceReturnExist"]))
        {
            this.hlHozreiSherut.Visible = true;

            int formCode = Convert.ToInt16(m_dsService.Tables[0].Rows[0]["FormCode"].ToString());
            if (formCode == 1 || formCode == 8) // אשפוז  או אשפוז דיפרנציאלי 
                this.hlHozreiSherut.NavigateUrl = "http://portal.clalit.org.il/sites/Communities/hozrimarchiv/lists/" + this.lblServiceCode.Text + @"/AllItems.aspx";
            else
                this.hlHozreiSherut.NavigateUrl = "http://portal.clalit.org.il/sites/Communities/hozrimarchiv/HozrimAmbulatory/Lists/" + this.lblServiceCode.Text + @"/AllItems.aspx";
            
            this.SetHistoryGeneralView();
        }
        else 
        {
            this.hlHozreiSherut.Visible = false;
        }
    }

    private void SetHistoryGeneralView()
    {
        if (this.ddlSalServiceUpdateDates.SelectedIndex == 0 || !this.IsPostBack)
        {
            // Set normal view
            //this.tblGeneralServiceDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#f7f7f7";
            this.tblAdditionalServiceDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#f7f7f7";
            this.tblGuidances.Style[HtmlTextWriterStyle.BackgroundColor] = "#f7f7f7";
            this.tblMedicalInstructions.Style[HtmlTextWriterStyle.BackgroundColor] = "#f7f7f7";
            
            this.tblAdditionalServiceDetails.Visible = true;
        }
        else
        {
            // Set history view
            //this.tblGeneralServiceDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#D4D4D4";
            //this.tblAdditionalServiceDetails.Style[HtmlTextWriterStyle.BackgroundColor] = "#D4D4D4";
            this.tblGuidances.Style[HtmlTextWriterStyle.BackgroundColor] = "#D4D4D4";
            this.tblMedicalInstructions.Style[HtmlTextWriterStyle.BackgroundColor] = "#D4D4D4";

            //this.tblAdditionalServiceDetails.Visible = false;
        }
    }

    protected void ddlSalServiceUpdateDates_SelectedIndexChanged(object sender, EventArgs e)
    {
        this.BindSalServiceDetails();
    }

    public void BindAdditionalDetails()
    {
        
    }

    public void BindSalServiceTarifon()
    {
        this.m_dsServiceTarifon = this.applicFacade.GetSalServiceTarifon(this.m_ServiceCode, !(this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) );

        if (this.m_dsServiceTarifon != null && this.m_dsServiceTarifon.Tables.Count > 0 && this.m_dsServiceTarifon.Tables[0].Rows.Count > 0)
        {
            this.rSalServiceTarifon.DataSource = m_dsServiceTarifon;
            this.rSalServiceTarifon.DataBind();
        }
    }

    public void BindSalServiceICD9()
    {
        this.m_dsServiceICD9 = this.applicFacade.GetSalServiceICD9(this.m_ServiceCode);

        if (this.m_dsServiceICD9 != null && this.m_dsServiceICD9.Tables.Count > 0 && this.m_dsServiceICD9.Tables[0].Rows.Count > 0)
        {
            this.rSalServiceICD9.DataSource = m_dsServiceICD9;
            this.rSalServiceICD9.DataBind();
        }
        else
        {
            this.lblICD9Title.Text = "לא נמצאו קודי פרוצדורה מקושרים";
        }
    }

    public void BindSalServiceInternetDetails()
    {
        UserManager userManager = new UserManager();
        UserInfo currentUserInfo = userManager.GetUserInfoFromSession();
        bool canManageInternetSalServices = false;
        if (currentUserInfo != null)
            canManageInternetSalServices = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageInternetSalServices, -1);

        this.tdSalServiceInternetDetailsTab.Visible = true;
        this.trSalServiceInternetDetails.Visible = true;

        if (!this.IsPostBack)
        {
            // Bind the comboboxes of the tab:
            // Bind Sal body organs combo;
            //this.ddlSalCategory_InternetDetails.DataSource = this.applicFacade.GetSalCategories(null, string.Empty);
            //this.ddlSalCategory_InternetDetails.DataBind();

            // Bind Sal categories combo;
            this.ddlSalBodyOrgans_InternetDetails.DataSource = this.applicFacade.GetSalBodyOrgans();
            this.ddlSalBodyOrgans_InternetDetails.DataBind();
        }

        this.m_dsServiceInternetDetails = this.applicFacade.GetSalServiceInternetDetails(this.m_ServiceCode);

        if (this.m_dsServiceInternetDetails != null && this.m_dsServiceInternetDetails.Tables.Count > 0 && this.m_dsServiceInternetDetails.Tables[0].Rows.Count > 0)
        {
            // Bind the details of the internet details tab:
            DataRow drInternetDetails = this.m_dsServiceInternetDetails.Tables[0].Rows[0];

            if (drInternetDetails["FromAgePrivilege"] != DBNull.Value)
            {
                short fromAgePrivilege = (short)drInternetDetails["FromAgePrivilege"];
                if (fromAgePrivilege > 0)
                    this.lblFromAge_InternetDetails.Text = fromAgePrivilege.ToString();
            }

            if (drInternetDetails["UntilAgePrivilege"] != DBNull.Value)
            {
                short untilAgePrivilege = (short)drInternetDetails["UntilAgePrivilege"];
                if (untilAgePrivilege > 0)
                    this.lblToAge_InternetDetails.Text = untilAgePrivilege.ToString();
            }

            if (drInternetDetails["GenderPrivilege"] != DBNull.Value)
            {
                short genderPrivilege = (short)drInternetDetails["GenderPrivilege"];
                switch (genderPrivilege)
                {
                    case 1:
                        this.lblGenderPrivilege_InternetDetails.Text = "זכר";
                        break;
                    case 2:
                        this.lblGenderPrivilege_InternetDetails.Text = "נקבה";
                        break;
                }
            }

            if (drInternetDetails["EntitlementCheck"] != DBNull.Value)
            {
                byte entitlementCheck = (byte)drInternetDetails["EntitlementCheck"];
                switch (entitlementCheck)
                {
                    case 0:
                        this.lblEntitlementCheck_InternetDetails.Text = "לא";
                        break;
                    case 1:
                        this.lblEntitlementCheck_InternetDetails.Text = "כן";
                        break;
                }
            }

            if (drInternetDetails["OrganName"] != DBNull.Value)
            {
                this.lblSalBodyOrgan_InternetDetails.Text = drInternetDetails["OrganName"].ToString();
                this.ddlSalBodyOrgans_InternetDetails.SelectedValue = drInternetDetails["SalOrganCode"].ToString();
            }

            //if (drInternetDetails["SalCategoryDescription"] != DBNull.Value)
            //{
            //    this.lblSalCategoryDescription_InternetDetails.Text = drInternetDetails["SalCategoryDescription"].ToString();
            //    this.ddlSalCategory_InternetDetails.SelectedValue = drInternetDetails["SalCategoryID"].ToString();
            //}

            this.lblServiceNameForInternet_InternetDetails.Text = drInternetDetails["ServiceNameForInternet"].ToString();
            this.txtServiceNameForInternet_InternetDetails.Text = drInternetDetails["ServiceNameForInternet"].ToString();

            this.lblSynonymsForInternet_InternetDetails.Text = drInternetDetails["Synonyms"].ToString();
            this.txtSynonymsForInternet_InternetDetails.Text = drInternetDetails["Synonyms"].ToString();

            this.lblRefund_InternetDetails.Text = drInternetDetails["Refund"].ToString();
            this.txtRefund_InternetDetails.Text = drInternetDetails["Refund"].ToString();

            this.lblServiceDetails_InternetDetails.Text = drInternetDetails["ServiceDetails"].ToString();
            string serviceDetails = drInternetDetails["ServiceDetails"].ToString();
            serviceDetails = serviceDetails.Replace("<br>", "\r\n");
            this.txtServiceDetails_InternetDetails.Text = serviceDetails;

            this.lblServiceBrief_InternetDetails.Text = drInternetDetails["ServiceBrief"].ToString();
            string serviceBrief = drInternetDetails["ServiceBrief"].ToString();
            serviceBrief = serviceBrief.Replace("<br>", "\r\n");
            this.txtServiceBrief_InternetDetails.Text = serviceBrief;

            this.lblServiceDetailsInternet.Text = drInternetDetails["ServiceDetailsInternet"].ToString();
            string serviceDetailsInternet = drInternetDetails["ServiceDetailsInternet"].ToString();
            //serviceDetailsInternet = serviceDetailsInternet.Replace("<br>", "\r\n");
            this.txtServiceDetailsInternet.Text = serviceDetailsInternet;

            // Get the professions from the dataset and bind the list.
            DataTable dtProfessions = m_dsServiceInternetDetails.Tables[1];
            string professions = "";
            for (int i = 0; i < dtProfessions.Rows.Count; i++)
            {
                if (i > 0)
                    professions += "<br/>";

                byte? showProfessionInInternet = (byte?)dtProfessions.Rows[i]["showProfessionInInternet"];
                if (showProfessionInInternet.HasValue && showProfessionInInternet.Value == 1)
                {
                    // Add Internet Icon Image
                    professions += "<img src=\"../Images/internet.gif\" width=\"15\" height=\"15\" border=\"0\" />&nbsp;";
                }

                professions += dtProfessions.Rows[i]["Description"];
            }

            this.lblProfessions_InternetDetails.Text = professions;

            DataTable dtSalCategories = m_dsServiceInternetDetails.Tables[2];
            string salCategories = "";
            for (int i = 0; i < dtSalCategories.Rows.Count; i++)
            {
                if (i > 0)
                    salCategories += "<br/>";
                salCategories += dtSalCategories.Rows[i]["SalCategoryDescription"];
            }
            this.lblSalCategories_InternetDetails.Text = salCategories;


            // Get the sal categories from the dataset and bind the list.
            if (drInternetDetails["QueueOrder"] != DBNull.Value)
            {
                byte queueOrder = (byte)drInternetDetails["QueueOrder"];
                switch (queueOrder)
                {
                    case 0:
                        this.lblQueueOrder_InternetDetails.Text = "לא";
                        break;
                    case 1:
                        this.lblQueueOrder_InternetDetails.Text = "כן";
                        break;
                }
                this.ddlQueueOrder_InternetDetails.SelectedValue = drInternetDetails["QueueOrder"].ToString();
            }

            if (drInternetDetails["Treatment"] != DBNull.Value)
            {
                byte treatment = (byte)drInternetDetails["Treatment"];
                switch (treatment)
                {
                    case 0:
                        this.lblTreatment_InternetDetails.Text = "לא";
                        break;
                    case 1:
                        this.lblTreatment_InternetDetails.Text = "כן";
                        break;
                }
                this.ddlTreatment_InternetDetails.SelectedValue = drInternetDetails["Treatment"].ToString();
            }

            if (drInternetDetails["Diagnosis"] != DBNull.Value)
            {
                byte diagnosis = (byte)drInternetDetails["Diagnosis"];
                switch (diagnosis)
                {
                    case 0:
                        this.lblDiagnosis_InternetDetails.Text = "לא";
                        break;
                    case 1:
                        this.lblDiagnosis_InternetDetails.Text = "כן";
                        break;
                }
                this.ddlDiagnosis_InternetDetails.SelectedValue = drInternetDetails["Diagnosis"].ToString();
            }

            if (drInternetDetails["ShowServiceInInternet"] != DBNull.Value)
            {
                byte showServiceInInternet = (byte)drInternetDetails["ShowServiceInInternet"];
                switch (showServiceInInternet)
                {
                    case 0:
                        this.lblShowServiceInInternet_InternetDetails.Text = "לא";
                        break;
                    case 1:
                        this.lblShowServiceInInternet_InternetDetails.Text = "כן";
                        break;
                }
                this.ddlShowServiceInInternet_InternetDetails.SelectedValue = drInternetDetails["showServiceInInternet"].ToString();
            }

            if (drInternetDetails["UpdateComplete"] != DBNull.Value)
            {
                byte updateComplete = (byte)drInternetDetails["UpdateComplete"];
                switch (updateComplete)
                {
                    case 0:
                        this.lblUpdateComplete_InternetDetails.Text = "לא";
                        break;
                    case 1:
                        this.lblUpdateComplete_InternetDetails.Text = "כן";
                        break;
                }
                this.ddlUpdateComplete_InternetDetails.SelectedValue = drInternetDetails["updateComplete"].ToString();
            }
        }

        this.btnSalServiceInternetDetailsTab.OnClientClick = "SetTabToBeShown('divSalServiceInternetDetailsBut','" + trSalServiceInternetDetails.ClientID + "','" + this.tdSalServiceInternetDetailsTab.ClientID + "','4'); return false;";

        if (currentUserInfo != null && (currentUserInfo.IsAdministrator || canManageInternetSalServices))
        { }
        else
        {
            // The current user is not an administrator or not logged - dont show the "internet details" tab
            this.tdSalServiceInternetDetailsTab.Visible = false;
            this.trSalServiceInternetDetails.Visible = false;
            // Move from "פרטי אינטרנט" Tab after Logout
            if (this.txtTabToBeShown.Text.IndexOf("Internet") > 0)
                txtTabToBeShown.Text = string.Empty;
        }

    }

    /// <summary>
    /// Returns html history table that contains the change log history of the tarifon.
    /// </summary>
    /// <param name="paramsData">comma seperated parameters needed for the binding of the history of the tarifon html table response.</param>
    /// <returns></returns>
    [WebMethod]
    public static string BindHistoryTarifon(string paramsData)
    {
        string[] paramsDataArr = paramsData.Split(';');

        int serviceCode = 0;
        byte populationsCode = 0;
        byte subPopulationsCode = 0;

        int.TryParse(paramsDataArr[0].Split(':')[1], out serviceCode);
        byte.TryParse(paramsDataArr[1].Split(':')[1], out populationsCode);
        byte.TryParse(paramsDataArr[2].Split(':')[1], out subPopulationsCode);

        // Get the data f the history from the database & build the html table as a response to the page.
        DataSet dsHistoryTarifon = Facade.getFacadeObject().GetSalServiceTarifonHistory( serviceCode , populationsCode , subPopulationsCode );

        StringBuilder sbHistoryTarifonHtmlTable = new StringBuilder();

        if (dsHistoryTarifon != null && dsHistoryTarifon.Tables.Count > 0 && dsHistoryTarifon.Tables[0].Rows.Count > 0)
        {
            sbHistoryTarifonHtmlTable.Append("<table border\"0\" cellpading=\"0\" cellspacing=\"0\" style=\"width:350px; border:1px solid gray;background-color:#FEFEFE;\">" + Environment.NewLine);
            sbHistoryTarifonHtmlTable.Append("<tr>" + Environment.NewLine);

            sbHistoryTarifonHtmlTable.Append("<td valign=\"middle\" style=\"padding-right:6px;background-color:#E8F4FD;height:20px\" align=\"right\">" + Environment.NewLine);
            sbHistoryTarifonHtmlTable.Append("<span class=\"LabelCaptionBlue_14\" style=\"font-weight:bold;font-size:14px;color:#2889E4;padding-top:2px;padding-bottom:2px\">היסטוריית תעריפים</span>" + Environment.NewLine);
            sbHistoryTarifonHtmlTable.Append("</td>" + Environment.NewLine);
            
            sbHistoryTarifonHtmlTable.Append("<td style=\"width:90px;background-color:#E8F4FD\" align=\"left\">" + Environment.NewLine);
            sbHistoryTarifonHtmlTable.Append("<span class=\"LabelCaptionBlue_14\" style=\"font-weight:bold;font-size:14px;color:#2889E4;padding-top:2px;padding-bottom:2px\">תעריף</span>" + Environment.NewLine);
            sbHistoryTarifonHtmlTable.Append("</td>" + Environment.NewLine);

            sbHistoryTarifonHtmlTable.Append("<td style=\"background-color:#E8F4FD;padding-left:32px;width:86px\" align=\"left\">" + Environment.NewLine);
            sbHistoryTarifonHtmlTable.Append("<span class=\"LabelCaptionBlue_14\" style=\"font-weight:bold;font-size:14px;color:#2889E4;padding-top:2px;padding-bottom:2px\">נכונות</span>" + Environment.NewLine);
            sbHistoryTarifonHtmlTable.Append("</td>" + Environment.NewLine);

            //sbHistoryTarifonHtmlTable.Append("<td style=\"width:26px\">" + Environment.NewLine);
            //sbHistoryTarifonHtmlTable.Append("&nbsp;" + Environment.NewLine);
            //sbHistoryTarifonHtmlTable.Append("</td>" + Environment.NewLine);

            sbHistoryTarifonHtmlTable.Append("</tr>" + Environment.NewLine);

            for (int i = 0; i < dsHistoryTarifon.Tables[0].Rows.Count; i++)
            {
                DataRow drTarifonHistory = dsHistoryTarifon.Tables[0].Rows[i];
                
                double tariffNew = 0;
                DateTime updateDate = (DateTime)drTarifonHistory["TrueDate"];

                if (drTarifonHistory["tariffNew"] != DBNull.Value)
                    tariffNew = Convert.ToDouble(drTarifonHistory["tariffNew"]);

                string bgColor = "";
                if (i % 2 == 0)
                    bgColor = "#FEFEFE";
                else
                    bgColor = "#E8F4FD";

                sbHistoryTarifonHtmlTable.Append("<tr style=\"background-color:" + bgColor + "\" >" + Environment.NewLine);
                
                sbHistoryTarifonHtmlTable.Append("<td>&nbsp;</td>" + Environment.NewLine);
                sbHistoryTarifonHtmlTable.Append("<td align=\"left\"; class=\"RegularLabel\" style=\"font-weight:bold;padding-top:2px;padding-bottom:2px\">" + tariffNew.ToString("0,0.00") + "</td>" + Environment.NewLine);
                sbHistoryTarifonHtmlTable.Append("<td align=\"left\" style=\"padding-left:30px;padding-top:2px;padding-bottom:2px\"><span class=\"RegularLabel\">" + updateDate.ToString("dd/MM/yyyy") + "</span></td>" + Environment.NewLine);
                //sbHistoryTarifonHtmlTable.Append("<td>&nbsp;</td>" + Environment.NewLine);

                sbHistoryTarifonHtmlTable.Append("</tr>" + Environment.NewLine);
            }

            sbHistoryTarifonHtmlTable.Append("</table>" + Environment.NewLine);
        }

        return sbHistoryTarifonHtmlTable.ToString();
    }

    protected void rSalServiceTarifon_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            DataRowView rowData = (DataRowView)e.Item.DataItem;

            Label lblTariffNew = (Label)e.Item.FindControl("lblTariffNew");

            double tariffNew = 0;
            if (double.TryParse(rowData["TariffNew"].ToString(), out tariffNew))
            {
                if (tariffNew > 0 || Convert.ToInt16(rowData["PopulationGiven"]) == 1)
                {
                    lblTariffNew.Text = tariffNew.ToString("0,0.00");
                }
                else
                {
                    lblTariffNew.Text = "לא ניתן";
                    lblTariffNew.Font.Bold = true;
                }
            }
        }
    }

    protected void rSalServiceICD9_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            DataRowView rowData = (DataRowView)e.Item.DataItem;
            Label lblGroupCode = (Label)e.Item.FindControl("lblGroupCode");
            HtmlTableCell tdBorder1 = (HtmlTableCell)e.Item.FindControl("tdBorder1");
            HtmlTableCell tdBorder2 = (HtmlTableCell)e.Item.FindControl("tdBorder2");
            HtmlTableCell tdBorder3 = (HtmlTableCell)e.Item.FindControl("tdBorder3");

            if (rowData["GroupCode"].ToString() == "0" || string.IsNullOrEmpty(rowData["GroupCode"].ToString()))
            {

                // If the group code is empty or 0 then display empty cell.
                lblGroupCode.Text = "";
            }
            else
            {
                if (Convert.ToInt32(rowData["GroupCode"].ToString()) != currentGroupCode)
                {
                    currentGroupCode = Convert.ToInt32(rowData["GroupCode"].ToString());
                    tdBorder1.Style.Add("border-top", "1px solid black");
                    tdBorder2.Style.Add("border-top", "1px solid black");
                    tdBorder3.Style.Add("border-top", "1px solid black");
                }
                else
                {
                    lblGroupCode.Text = "";
                }
            }
        }
    }

    private void toggleUpdateButtons()
    {
        
    }

    protected void dvSalServiceDetails_DataBound(object sender, EventArgs e)
    {
        DetailsView dv = sender as DetailsView;
        DataRowView row = dv.DataItem as DataRowView;
    }

    protected void dvSalServiceDetails_DataBinding(object sender, EventArgs e)
    {
        if (this.m_dsService != null && this.m_dsService.Tables.Count > 0 && this.m_dsService.Tables[0].Rows.Count > 0)
        {
            DataRow row = this.m_dsService.Tables[0].Rows[0];
        }
    }

    protected void btnBack_Click(object sender, ImageClickEventArgs e)
    {
        string selectedIndex = this.Request["Index"];
        string selectedPageIndex = this.Request["spi"];

        if (sessionParams.LastSearchPageURL.ToString().IndexOf("SearchClinics.aspx") > 0)
        {
            Response.Redirect(sessionParams.LastSearchPageURL.ToString() + "?RepeatSearch=1");
        }

        this.Response.Redirect("../SearchSalServices.aspx?RepeatSearch=1&index=" + selectedIndex + "&spi=" + selectedPageIndex);
    }

    protected void btnUpdateSalServiceInternetDetails_Click(object sender, EventArgs e)
    {
        // Bind the edit view to the 4 tab - sal service internet details:
        //if 
        this.ViewState["InternetDetailsEditView"] = true;
        this.BindInternetDetailsEditView();
    }

    private void BindInternetDetailsEditView()
    {
        bool isEditView = false;
        if (this.ViewState["InternetDetailsEditView"] != null)
        {
            isEditView = (bool)this.ViewState["InternetDetailsEditView"];
        }

        this.lblServiceNameForInternet_InternetDetails.Visible = !isEditView;
        this.txtServiceNameForInternet_InternetDetails.Visible = isEditView;

        this.lblSynonymsForInternet_InternetDetails.Visible = !isEditView;
        this.txtSynonymsForInternet_InternetDetails.Visible = isEditView;

        //this.lblSalCategoryDescription_InternetDetails.Visible = !isEditView;
        //this.ddlSalCategory_InternetDetails.Visible = isEditView;

        this.lblSalBodyOrgan_InternetDetails.Visible = !isEditView;
        this.ddlSalBodyOrgans_InternetDetails.Visible = isEditView;

        this.lblRefund_InternetDetails.Visible = !isEditView;
        this.txtRefund_InternetDetails.Visible = isEditView;
        
        this.lblServiceDetails_InternetDetails.Visible = !isEditView;
        this.txtServiceDetails_InternetDetails.Visible = isEditView;

        this.txtServiceBrief_InternetDetails.Visible = isEditView;
        this.lblServiceBrief_InternetDetails.Visible = !isEditView;

        this.txtServiceDetailsInternet.Visible = isEditView;
        this.lblServiceDetailsInternet.Visible = !isEditView;

        this.lblQueueOrder_InternetDetails.Visible = !isEditView;
        this.ddlQueueOrder_InternetDetails.Visible = isEditView;

        this.lblTreatment_InternetDetails.Visible = !isEditView;
        this.ddlTreatment_InternetDetails.Visible = isEditView;

        this.lblDiagnosis_InternetDetails.Visible = !isEditView;
        this.ddlDiagnosis_InternetDetails.Visible = isEditView;

        this.lblShowServiceInInternet_InternetDetails.Visible = !isEditView;
        this.ddlShowServiceInInternet_InternetDetails.Visible = isEditView;

        this.lblUpdateComplete_InternetDetails.Visible = !isEditView;
        this.ddlUpdateComplete_InternetDetails.Visible = isEditView;

        this.phEditInternetDetails.Visible = !isEditView;
        this.phUpdateCancelInternetDetails.Visible = isEditView;
    }

    protected void btnSaveSalServiceInternetDetails_Click(object sender, EventArgs e)
    {
        // Save the new internet details of the sal service to the database:

        int serviceCode = int.Parse(this.lblServiceCode.Text);
        string serviceNameForInternet = this.txtServiceNameForInternet_InternetDetails.Text;
        string synonyms = this.txtSynonymsForInternet_InternetDetails.Text;

        string refund = this.txtRefund_InternetDetails.Text;
        int salOrganCode = int.Parse(this.ddlSalBodyOrgans_InternetDetails.SelectedValue);
        //int salCategoryID = int.Parse(this.ddlSalCategory_InternetDetails.SelectedValue);

        string serviceDetails = this.txtServiceDetails_InternetDetails.Text.Replace("\r\n" , "<br>");
        string serviceBrief = this.txtServiceBrief_InternetDetails.Text.Replace("\r\n", "<br>");
        string serviceDetailsInternet = this.txtServiceDetailsInternet.Text;
        byte queueOrder = byte.Parse(this.ddlQueueOrder_InternetDetails.SelectedValue);
        byte treatment = byte.Parse(this.ddlTreatment_InternetDetails.SelectedValue);
        byte diagnosis = byte.Parse(this.ddlDiagnosis_InternetDetails.SelectedValue);
        byte showServiceInInternet = byte.Parse(this.ddlShowServiceInInternet_InternetDetails.SelectedValue);
        byte updateComplete = byte.Parse(this.ddlUpdateComplete_InternetDetails.SelectedValue);

        UserManager userManager = new UserManager();
        UserInfo currentUserInfo = userManager.GetUserInfoFromSession();

        if (currentUserInfo != null)
        {
            this.applicFacade.UpdateSalServiceInternetDetails(serviceCode, serviceNameForInternet,
                serviceDetails, serviceBrief, serviceDetailsInternet, queueOrder, showServiceInInternet, updateComplete, currentUserInfo.UserAD,
                diagnosis, treatment, salOrganCode, synonyms, refund);
        }
        else
        {
            // The session of the user has ended refresh to him the page.
            this.Response.Redirect("ZoomSalService.aspx?ServiceCode=" + serviceCode);
        }
        
        // Set the form back to readonly view.
        this.ViewState["InternetDetailsEditView"] = false;
        this.BindInternetDetailsEditView();
        this.BindSalServiceInternetDetails();
    }

    protected void btnCancelSalServiceInternetDetails_Click(object sender, EventArgs e)
    {
        // Set the form back to readonly view.
        this.ViewState["InternetDetailsEditView"] = false;
        this.BindInternetDetailsEditView();
    }

    public void rGuidances_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            if (this.isAdvanceSearch)
            {
                Label lblDiagnostics = (Label)e.Item.FindControl("lblDiagnostics");
                Label lblAge = (Label)e.Item.FindControl("lblAge");
                Label lblPublicFacility = (Label)e.Item.FindControl("lblPublicFacility");
                Label lblTreatment = (Label)e.Item.FindControl("lblTreatment");
                Label lblComment = (Label)e.Item.FindControl("lblComment");

                lblDiagnostics.Text = lblDiagnostics.Text.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                lblAge.Text = lblAge.Text.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                lblPublicFacility.Text = lblPublicFacility.Text.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                lblTreatment.Text = lblTreatment.Text.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
                lblComment.Text = lblComment.Text.Replace(this.SessionParams.AdvanceSearchText, this.advanceSearchWord_ReplacedText);
            }

            HtmlTableCell tdAge = (HtmlTableCell)e.Item.FindControl("tdAge");
            tdAge.Style[HtmlTextWriterStyle.BackgroundColor] = (this.ddlSalServiceUpdateDates.SelectedIndex == 0) ? "#f6fbff" : "";
        }
    }
}

