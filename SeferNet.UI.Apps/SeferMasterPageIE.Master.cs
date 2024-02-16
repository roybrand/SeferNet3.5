using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.FacadeLayer;
using System.Web.Security;
using System.Text;
using System.Globalization;
using System.Data;
using System.Xml.XPath;
using AjaxControlToolkit;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.Globals;
using System.Web.Configuration;
using SeferNet.UI.Apps.CentralLogRegularService;

    //public partial class SeferMasterPageIE : System.Web.UI.MasterPage
    //{
    //    protected void Page_Load(object sender, EventArgs e)
    //    {

    //    }
    //}

public partial class SeferMasterPageIE : System.Web.UI.MasterPage, ICallbackEventHandler
{
    private Facade applicFacade;

    public string strSessionTimeoutInSeconds = ((int)(((SessionStateSection)System.Configuration.ConfigurationManager.GetSection("system.web/sessionState")).Timeout.TotalMinutes) * 60).ToString();
    static Dictionary<string, List<string>> _CallbackFunctionsDictionary = new Dictionary<string, List<string>>();

    public string waitingTimeBeforeKillingSessionInMinutes = System.Configuration.ConfigurationManager.AppSettings["waitingTimeBeforeKillingSessionInMinutes"].ToString();
    public Button BtnToDo_Submeet
    {
        get
        {
            return ToDo_Submeet;
        }
    }

    public bool IsPostBackAfterLoginLogout
    {
        get
        {
            return hdnAfterLoginLogout.Value != string.Empty;
        }
    }

    public string PreviousPage
    {
        get
        {
            return ViewState["previousPage"].ToString();
        }
        set
        {
            ViewState["previousPage"] = value;
        }
    }

    static SeferMasterPageIE()
    {
        _CallbackFunctionsDictionary.Add("OnLogoutFinished", new List<string> { });
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(hdnAfterLoginLogout.Value))
            hdnAfterLoginLogout.Value = string.Empty;

        handleError();

    }

    protected void Page_Init(object sender, EventArgs e)
    {
        UserInfo currentUser = Session["currentUser"] as UserInfo;
        if (currentUser == null)
        {
            string[] RestrictedFoldersForNotLoggedUsers = System.Configuration.ConfigurationManager.AppSettings["RestrictedFoldersForNotLoggedUsers"].ToString().Split(',');

            string currFolder = HttpContext.Current.Request.Url.Segments[2];
            foreach (string s in RestrictedFoldersForNotLoggedUsers)
            {
                if (currFolder == s)
                {
                    Response.Redirect(PagesConsts.SEARCH_CLINICS_URL);
                    Response.End();
                }
            }
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        Page.Header.DataBind();

        #region Login

        if (Session[ConstsSession.IS_POST_BACK_AFTER_LOGIN_LOGOUT] != null && Session[ConstsSession.IS_POST_BACK_AFTER_LOGIN_LOGOUT].ToString() == "1")
        {
            hdnAfterLoginLogout.Value = Session[ConstsSession.IS_POST_BACK_AFTER_LOGIN_LOGOUT].ToString();
        }

        SetControlsByUserLoginState();

        AsyncCallbackHelper asyncCallbackHelper = new AsyncCallbackHelper(this, _CallbackFunctionsDictionary);

        #endregion

        //tdMainHeader.InnerHtml = UIHelper.GetStrbyImg(Page.Title);
        SessionParamsHandler.IncrementPageCounter();
        Label lblError = pageContent.FindControl("lblError") as Label;
        if (lblError != null)
            lblError.Text = string.Empty;

        lblLastTimeEntry.Visible = false;

        Session[ConstsSession.IS_POST_BACK_AFTER_LOGIN_LOGOUT] = hdnAfterLoginLogout.Value.ToString();
        hdnHttpsEnabled.Value = System.Configuration.ConfigurationManager.AppSettings["Is_HTTPS_enabled"].ToString();

        if (!IsPostBack || IsPostBackAfterLoginLogout)
        {
            //if (IsPostBackAfterLoginLogout && (GetCurrentPageName() == "SearchSalServices" || GetCurrentPageName() == "ZoomSalService"))
            //{
            //    this.Response.Redirect("~/SearchClinics.aspx");
            //}

            this.SetSiteMenuSql(GetCurrentPageName());

            if (IsPostBackAfterLoginLogout && Session["UserLoginInformation"] != null)
            {
                UserLoginInformation userLoginInformation = (UserLoginInformation)Session["UserLoginInformation"];

                UserManager userManager = new UserManager(getUserName());
                UserInfo currentUser = userManager.GetUserInfoFromSession();

                if (userLoginInformation.FailedAttemptsCount == 0)
                {
                    lblLastTimeEntry.Visible = true;
                    lblLastTimeEntry.Text =
                        string.Concat("שלום ", currentUser.FirstName, " ", currentUser.LastName, " כניסתך האחרונה: " + userLoginInformation.LastLoginAttemptedLoginDate.ToString());
                }
                else
                {
                    string messageText =
                        string.Concat("היו ",
                                    userLoginInformation.FailedAttemptsCount,
                                    " נסיונות כושלים להכנס למערכת לפני הכניסה הנוכחית",
                                    @"\n\r",
                                    userLoginInformation.UserIP,
                                    " ניסיון אחרון היה ממחשב בשם ",
                                    @"\n\r",
                                    userLoginInformation.UserName.Replace(@"\", @"\\"),
                                    " על ידי משתמש בשם "
                                    );

                    //string messageText = "There were " + userLoginInformation.FailedAttemptsCount.ToString() + " failed attempts to login" +  @"\n\r";
                    //messageText += "The last one was at " + userLoginInformation.LastLoginAttemptedLoginDate.ToString();
                    ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "LoginFailureAlert", "alert('" + messageText + "');", true);
                }
                if (userLoginInformation.LoginFromOtherIpExists)
                {
                    string messageText =
                        string.Concat("לידעתך,", @"\n\r",
                                    "יש כרגע משתמש עם היוזר שלך במחשב אחר שכתובתו ",
                                    @"\n\r", userLoginInformation.UserNameReal.Replace(@"\", @"\\")
                                    );
                    ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "LoginFromOtherIpExistsAlert", "alert('" + messageText + "');", true);
                }

                Session["UserLoginInformation"] = null;
            }

        }

        this.SiteMenuSql.MenuItemClick += new MenuEventHandler(SiteMenuSql_MenuItemClick);

        if (this.SiteMenuSql.UniqueID == HttpContext.Current.Request["__EVENTTARGET"])
        {
            string eventArgsStr = HttpContext.Current.Request["__EVENTARGUMENT"];
            if (!string.IsNullOrEmpty(eventArgsStr) && eventArgsStr != "\\" && eventArgsStr != ("\\" + ConstsSystem.EMPTY))
            {
                if (eventArgsStr.IndexOf("http:") >= 0)
                {
                    eventArgsStr = eventArgsStr.Substring(eventArgsStr.IndexOf("http:"));
                    this.SiteMenuSql_MenuItemClicked(eventArgsStr);
                }
                else
                {
                    string[] eventArgs = eventArgsStr.Split(new char[] { '~' });
                    this.SiteMenuSql_MenuItemClicked("~" + eventArgs[eventArgs.Length - 1]);
                }
            }
        }

        lblPageTitle.Text = Page.Title;

        this.InitializeControlsFromGlobalResources();
    }

    private string GetCurrentPageName()
    {
        try
        {
            string[] filePathElements = Context.Request.FilePath.Split('/');
            string fileName = filePathElements[filePathElements.Length - 1];
            fileName = fileName.Substring(0, fileName.IndexOf('.'));
            return fileName;
        }
        catch
        {
            return string.Empty;
        }
    }

    private void SetTimeoutCheck()
    {
        // set only if we are not in the main pages
        //hfCounter.Value = (60 * + Session.Timeout).ToString();
        //Page.ClientScript.RegisterStartupScript(this.GetType(), "timeout", "var sessionTimeout = 200;" +
        //                                                           "var inter = window.setInterval('CheckTimeout()',2000);", true);
        //Page.ClientScript.RegisterStartupScript(this.GetType(), "timeout", " = 60 *" + Session.Timeout.ToString() + ";" +
        //                                                       "var inter = window.setInterval('CheckTimeout()',10000);", true);
    }

    private void SetControlsByUserLoginState()
    {
        //string userNameTxtBox = @"CLALIT\" + txtUserName.Text.Trim();
        //check if the use is logged in 
        //*******if yes it marks the label logout
        //*******if no it marks the label login

        //UserManager mgr = new UserManager(userNameTxtBox);
        UserManager mgr = new UserManager();
        UserInfo loggedInUser = mgr.GetUserInfoFromSession();

        if (loggedInUser == null)
        {
            lblLogin.Text = "Login";
            lblLogin.Attributes.Add("OnClick", "OpenLoginJQueryDialog(345, 330, 'Login')");
        }
        else
        {
            lblLogin.Text = "Logout";
            lblLogin.Attributes.Add("OnClick", "Logout()");
        }

        //CentralLogServiceClient
    }

    private void InitializeControlsFromGlobalResources()
    {
        //if (this.IsPostBack) return;

        foreach (BaseValidator val in this.Page.Validators)
        {
            val.Text = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "ErrorChar") as string;
            if (val is MaskedEditValidator)
            {
                ((MaskedEditValidator)val).InvalidValueBlurredMessage = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "ErrorChar") as string;
            }
        }
    }

    #region ICallbackEventHandler Members

    public string GetCallbackResult()
    {
        string retVal = string.Empty;

        //call web service here and return its result to JS 
        retVal = result;

        return retVal;
        //throw new NotImplementedException();
    }

    string result = string.Empty;
    public void RaiseCallbackEvent(string eventArgument)
    {
        LoginService srv = new LoginService();

        string[] arr = eventArgument.Split(new char[] { ';' });

        if (arr[0] == "OnLogoutFinished")
        {
            result = srv.GetLogoutResult().ToString();
        }
    }

    #endregion

    private void SetSiteMenuSql(string currentPageName)
    {
        applicFacade = Facade.getFacadeObject();
        List<Enums.UserPermissionType> userPermissionsList = null;

        try
        {
            UserManager userManager = new UserManager(getUserName());
            UserInfo currentUser = userManager.GetUserInfoFromSession();

            if (currentUser != null)
                userPermissionsList = userManager.GetUserPermissionsForMenuViewing(currentUser);

            //if (currentUser != null && currentUser.UserPermissions != null)
            //{
            //    userHighestPermission = 4; //view

            //    for (int i = 0; i < currentUser.UserPermissions.Count; i++)
            //    {
            //        UserPermission userPermision = (UserPermission)currentUser.UserPermissions[i];
            //        if (userPermision.iPermissionType == 5)
            //        {
            //            userHighestPermission = 5; //admin
            //            break;
            //        }

            //        if (userPermision.iPermissionType < userHighestPermission)
            //        {
            //            userHighestPermission = userPermision.iPermissionType;
            //        }
            //    }

            //}
            //else
            //    userHighestPermission = 0;

        }
        catch
        {
            userPermissionsList = new List<Enums.UserPermissionType>();
            userPermissionsList.Add(Enums.UserPermissionType.AvailableToAll);
        }

        DataSet ds = applicFacade.GetMainMenuData(userPermissionsList, currentPageName);

        DataSet hDS = new DataSet();

        for (int i = 0; i < ds.Tables.Count; i++)
        {
            DataTable dtParCld = ds.Tables[i].Copy();
            dtParCld.TableName = "Layer_" + i;
            hDS.Tables.Add(dtParCld);
        }

        for (int i = 0; i < hDS.Tables.Count - 1; i++)
        {
            hDS.Relations.Add("Parent_Child_" + i, hDS.Tables["Layer_" + i].Columns["ItemID"],
                hDS.Tables["Layer_" + (i + 1)].Columns["ParentID"], true);
        }

        if (SiteMenuSql.Items.Count > 0)
        {
            SiteMenuSql.Items.Clear();
        }

        foreach (DataRow parentRow in hDS.Tables["Layer_0"].Rows)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(parentRow["Title"].ToString());

            string itemText = sb.ToString();

            MenuItem parentItem = new MenuItem(itemText, parentRow["Url"].ToString());

            SiteMenuSql.Items.Add(parentItem);
            AddChildMenuItems(parentItem, parentRow, 0);
        }

        //SiteMenuSql.MenuItemClick += new MenuEventHandler(SiteMenuSql_MenuItemClick);
    }

    public string getUserName()
    {
        UserManager mgr = new UserManager();
        return mgr.GetUserNameForLog();
    }

    private void AddChildMenuItems(MenuItem upperItem, DataRow parentDataRow, int Layer)
    {
        int rows = parentDataRow.GetChildRows("Parent_Child_" + Layer).GetLength(0);
        int i = 0;
        foreach (DataRow childRow in parentDataRow.GetChildRows("Parent_Child_" + Layer))
        {
            string url = childRow["Url"].ToString();
            //if (url.ToLower().IndexOf("searchsalservices.aspx") > -1)
            //{
            //    UserManager userManager = new UserManager();
            //    UserInfo currentUserInfo = userManager.GetUserInfoFromSession();

            //    if (currentUserInfo != null && this.Page.User.Identity.IsAuthenticated)
            //    {
            //        bool canManageTarifonViews = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageTarifonViews, -1);
            //        bool canViewTarifon = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ViewTarifon, -1);

            //        if (!currentUserInfo.IsAdministrator && !canManageTarifonViews && !canViewTarifon)
            //        {
            //            // If the current user isn't administrator & can't manage tarifon views and can't can view tarifon then don't add the "SearchSalServices.aspx" option to the top menu.
            //            continue;
            //        }
            //    }
            //    else
            //    {
            //        continue;
            //    }
            //}

            StringBuilder sb2 = new StringBuilder();
            sb2.Append(childRow["Title"].ToString());

            string itemText2 = sb2.ToString();
            MenuItem childItem = new MenuItem(itemText2, url);


            upperItem.ChildItems.Add(childItem);
            AddChildMenuItems(childItem, childRow, Layer + 1);
            i++;
        }
    }

    protected void SiteMenuSql_MenuItemClicked(string selItemValue)
    {
        //MenuItem selItem = this.SiteMenuSql.SelectedItem;
        //if (selItem == null) return;

        if (selItemValue == "0")
        {
            this.Page.ClientScript.RegisterStartupScript(this.GetType(), "showLoginPopUp", "ShowLoginPopUp()");
        }
        else
        {
            if (selItemValue != string.Empty)
            {
                if (selItemValue.IndexOf('#') > 0)
                {
                    string[] UrlAndWindowParameters = selItemValue.Split('#');

                    string newValue = UrlAndWindowParameters[0];

                    if (selItemValue.IndexOf("http:") < 0)
                    {
                        newValue = newValue.Substring(selItemValue.IndexOf('/') + 1);
                        string serverName = Request.ServerVariables["SERVER_NAME"].ToString();
                        string[] segmentsURL = Request.Url.Segments;
                        int Url_Port = Request.Url.Port;
                        serverName = serverName + ":" + Url_Port.ToString();

                        string current_HTTP_prefix = Request.Url.AbsoluteUri.Substring(0, Request.Url.AbsoluteUri.IndexOf(':'));

                        if (System.Configuration.ConfigurationManager.AppSettings["Is_HTTPS_enabled"].ToString() == "1")
                        {
                            //newValue = @"https://" + serverName + segmentsURL[0] + segmentsURL[1] + newValue;
                            newValue = current_HTTP_prefix + @"://" + serverName + segmentsURL[0] + segmentsURL[1] + newValue;
                        }
                        else
                        {
                            newValue = @"http://" + serverName + segmentsURL[0] + segmentsURL[1] + newValue;
                        }
                    }

                    string[] WindowParameters = UrlAndWindowParameters[1].Split(';');
                    string IsWinDialog = "0";
                    string sizeX = "";
                    string sizeY = "";
                    string resize = "1";

                    if (WindowParameters.Length > 1)
                    {
                        IsWinDialog = WindowParameters[0].ToString();
                        sizeX = WindowParameters[1].ToString();
                        sizeY = WindowParameters[2].ToString();
                        resize = WindowParameters[3].ToString();
                    }


                    ScriptManager.RegisterClientScriptBlock(UpdatePanelMenu, typeof(UpdatePanel), "OpenInNewWindow", "OpenInNewWindow('" + newValue + "','" + IsWinDialog + "','" + sizeX + "','" + sizeY + "','" + resize + "');", true);

                }
                else if (selItemValue.IndexOf('#') == 0)
                    return;

                else
                    Response.Redirect(selItemValue);
            }
        }

    }

    protected void SiteMenuSql_MenuItemClick(object sender, MenuEventArgs e)
    {
        //Session["SelectedItemText"] = e.Item.Text;

        //The currentGvDataSet is used to persist a dataset behind
        // a gridview. It changes the dataset it holds according to the page.
        // This is why it should be set to null when we move from page to page.
        //Session["currentGvDataSet"] = null;


        //lblMessage.Text = "לחצת על" + e.Item.Value;

        //--------------------------------------------------
        //if (e.Item.Value == "0")
        //{
        //    //RegisterStartupScript(typeof(string), "HideTdMainHeaderOnMaster", "HideTdMainHeaderOnMaster();", true);

        //    Page.RegisterStartupScript("showLoginPopUp", "ShowLoginPopUp()");
        //}
        //else
        //{
        //    if (e.Item.Value != string.Empty)
        //    {
        //        if (e.Item.Value.IndexOf('#') > 0)
        //        {
        //            string[] UrlAndWindowParameters = e.Item.Value.Split('#');

        //            string newValue = UrlAndWindowParameters[0];

        //            if (e.Item.Value.IndexOf("http:") < 0)
        //            {
        //                newValue = newValue.Substring(e.Item.Value.IndexOf('/') + 1);
        //                string serverName = Request.ServerVariables["SERVER_NAME"].ToString();
        //                string[] segmentsURL = Request.Url.Segments;
        //                newValue = @"http://" + serverName + segmentsURL[0] + segmentsURL[1] + newValue;
        //            }

        //            string[] WindowParameters = UrlAndWindowParameters[1].Split(';');
        //            string IsWinDialog = "0";
        //            string sizeX = "";
        //            string sizeY = "";
        //            string resize = "1";

        //            if (WindowParameters.Length > 1)
        //            {
        //                IsWinDialog = WindowParameters[0].ToString();
        //                sizeX = WindowParameters[1].ToString();
        //                sizeY = WindowParameters[2].ToString();
        //                resize = WindowParameters[3].ToString();
        //            }


        //            Page.ClientScript.RegisterStartupScript(typeof(string), "OpenInNewWindow", "OpenInNewWindow('" + newValue + "','" + IsWinDialog + "','" + sizeX + "','" + sizeY + "','" + resize + "');", true);
        //        }
        //        else if (e.Item.Value.IndexOf('#') == 0)
        //            return;

        //        //else if (e.Item.Value.IndexOf(ConstsSystem.EMPTY) == 0)
        //        //    return;

        //        else
        //            Response.Redirect(e.Item.Value);
        //    }
        //}

    }

    //protected void dsMenuXml_Init(object sender, EventArgs e)
    //{
    //    setMenu();
    //    RemoveIrrelevantMenuItems();
    //}

    //private void setMenu()
    //{
    //    UserManager mng = new UserManager();

    //    string menuXpath = mng.getMenuXpathForUser(Session["currentUser"] as UserInfo);
    //    //dsMenuXml.XPath = menuXpath;
    //}

    //public void RemoveIrrelevantMenuItems()
    //{

    //    int currentUserPermissionType = Convert.ToInt32(Session["currentUserPermissionType"]);
    //    //if user is not permitted to administer users
    //    // 1 is district administrator
    //    // 5 is system administrator
    //    if (currentUserPermissionType > 1 && currentUserPermissionType != 5)
    //    {
    //        string[] MenuItemsArr = new string[] { "~/Admin/UserAdministration.aspx" };
    //        RemoveIrrelevantMenuItems(MenuItemsArr);

    //    }
    //}

    //public void RemoveIrrelevantMenuItems(string[] MenuItems)
    //{
    //    m_menuItemsToRemoveArr = MenuItems;
    //}

    protected void SiteMenu_MenuItemClick(object sender, MenuEventArgs e)
    {
        this.Session["SelectedItemText"] = e.Item.Text;

        //The currentGvDataSet is used to persist a dataset behind
        // a gridview. It changes the dataset it holds according to the page.
        // This is why it should be set to null when we move from page to page.
        this.Session["currentGvDataSet"] = null;

        //lblMessage.Text = "לחצת על" + e.Item.Value;
        this.Response.Redirect(e.Item.Value);
    }

    public void setDeptNameInSession()
    {
        //update the deptname field, in the object stored in session, with the selected deptcode
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
        if (this.ViewState["DeptName"] != null)
        {
            sessionParams.DeptName = this.ViewState["DeptName"].ToString();
        }
    }

    private void handleError()
    {
        if (!IsPostBack)
        {
            if (this.Session["ErrorMessage"] != null)
            {
                string ErrorMsg = this.Session["ErrorMessage"].ToString();

                Label lblError = this.pageContent.FindControl("lblError") as Label;
                if (lblError != null)
                    lblError.Text = ErrorMsg;
                else
                {
                    this.Page.ClientScript.RegisterStartupScript(typeof(string), "displayErrorMsg", "alert(' " + ErrorMsg + "');", true);
                }

                this.Session["ErrorMessage"] = null;
            }
        }
    }

    public void HideMainHeader()
    {
        this.lblPageTitle.Style.Add("display", "none");
    }

    //protected void ToDoSubmit_Click(object sender, EventArgs e)
    //{
    //}

    public void DisplayPopup(string message)
    {
        this.popup.Attributes["class"] = "popup popup_open";
        this.popupLabel.Text = message;
    }

    protected void ClosePopup_Click(object sender, EventArgs e)
    {
        this.popup.Attributes["class"] = "popup";
        this.popupLabel.Text = string.Empty;
    }
}