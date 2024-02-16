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
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.FacadeLayer;
using System.Data.SqlClient;
using SeferNet.DataLayer;
using AjaxControlToolkit;
using SeferNet.Globals;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using System.Collections.Generic;

public partial class UserAdministration : AdminBasePage
{
    private Facade applicFacade = Facade.getFacadeObject();
    bool m_InsertPermissionErrorFlag = false;
    bool m_UpdateUserErrorFlag = false;
    bool m_InsertUserErrorFlag = false;
    bool m_RestoreData = false;
    bool m_addNewUser = false;
    DataSet dsUser;
    dvUserPermissionsInfo dvData;
    DvUserInfo dvUserData;
    UserInfo currentUserInfo;
    int m_selectedPermissionType;
    int m_selectedDistrict;
    string expandedUserPermissions_ViewState = "expandedUserPermissionsViewState";
    string expandedUserPermissions_Session = "expandedUserPermissions_Session";
    Hashtable expandedUserPermissions_Hashtable;
    private string permittedDistricts;

    protected Dictionary<Int64, Int64?> ExpandedUserPermissions
    {
        get
        {
            if (ViewState["expandedUserPermissions"] == null)
            {
                ViewState["expandedUserPermissions"] = new Dictionary<Int64, Int64?>();
            }

            return (Dictionary<Int64, Int64?>)ViewState["expandedUserPermissions"];
        }
        set
        {
            ViewState["expandedUserPermissions"] = value;
        }
    }

    private void AddToExpandedUserPermissions(Int64 userID)
    {
        if (Session[expandedUserPermissions_Session] != null)
        {
            expandedUserPermissions_Hashtable = (Hashtable)Session[expandedUserPermissions_Session];
        }
        if (!expandedUserPermissions_Hashtable.ContainsValue(userID))
            expandedUserPermissions_Hashtable.Add(userID, userID);

        Session[expandedUserPermissions_Session] = expandedUserPermissions_Hashtable;
        expandedUserPermissions_Hashtable = (Hashtable)Session[expandedUserPermissions_Session];
    }

    private void RemoveFromExpandedUserPermissions(Int64 userID)
    {
        if (Session[expandedUserPermissions_Session] != null)
        {
            expandedUserPermissions_Hashtable = (Hashtable)Session[expandedUserPermissions_Session];
        }
        if (expandedUserPermissions_Hashtable.ContainsValue(userID))
            expandedUserPermissions_Hashtable.Remove(userID);

        Session[expandedUserPermissions_Session] = expandedUserPermissions_Hashtable;
    }

    private void RemoveAllExpandedUserPermissions()
    {
        if (Session[expandedUserPermissions_Session] != null)
        {
            expandedUserPermissions_Hashtable = (Hashtable)Session[expandedUserPermissions_Session];
        }

        expandedUserPermissions_Hashtable.Clear();

        Session[expandedUserPermissions_Session] = expandedUserPermissions_Hashtable;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        expandedUserPermissions_Hashtable = new Hashtable();
        UserManager userManager = new UserManager();
        currentUserInfo = userManager.GetUserInfoFromSession();

        if (IsPostBack)
        {
            //expandedUserPermissions_Hashtable = (Hashtable)ViewState[expandedUserPermissions_ViewState];
            expandedUserPermissions_Hashtable = (Hashtable)Session[expandedUserPermissions_Session];
            if (txtUserIDToExpand.Text != string.Empty)
            {
                AddToExpandedUserPermissions(Convert.ToInt64(txtUserIDToExpand.Text));
                txtUserIDToExpand.Text = string.Empty;
            }
            if (txtUserIDToCollaps.Text != string.Empty)
            {
                RemoveFromExpandedUserPermissions(Convert.ToInt64(txtUserIDToCollaps.Text));
                txtUserIDToCollaps.Text = string.Empty;
            }

            ScriptManager.RegisterClientScriptBlock(UpdatePanel1, typeof(UpdatePanel), "SetDivScrollPosition", "SetDivScrollPosition()", true);
        }
        else
        {
            Session[expandedUserPermissions_Session] = expandedUserPermissions_Hashtable;
        }


        if (!this.IsPostBack)
        {
            this.checkPermissionToViewPage();

            this.handleBinding();

            this.gvUsers.Visible = false;
        }
        else
        {
            this.gvUsers.Visible = true;
        }
    }

    private void checkPermissionToViewPage()
    {
        // int currentUserPermissionType = Convert.ToInt32(currentUserInfo.MaxPermissionType);
        // if user is not permitted to administer users
        // 1 is district administrator
        // 5 is system administrator

        // SeferNet.Globals.Enums.UserPermissionType.

        // currentUserPermissionType > 1 && currentUserPermissionType != 5)

        // Check If the user can view/edit users that can edit or add "Tarifon Views" which is the page "SearchSalServices."
        if (this.currentUserInfo != null && this.User.Identity.IsAuthenticated)
        {
            bool canManageTarifonViews = this.currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageTarifonViews, -1);

            if (!this.currentUserInfo.IsAdministrator && !this.currentUserInfo.HasDistrictPermission && !canManageTarifonViews)
            {
                throw new ApplicationException("אין הרשאות למשתמש");
            }
        }
    }

    private void LimitDdlUserIsInDomain()
    {
        if (!this.currentUserInfo.IsAdministrator)
        {
            this.ddlUserIsInDomain.SelectedValue = "1";
            this.ddlUserIsInDomain.Enabled = false;
        }
    }

    private void handleBinding()
    {
        permittedDistricts = this.GetPermittedDistricts();

        if (!this.currentUserInfo.IsAdministrator && permittedDistricts != string.Empty)
        {
            UIHelper.BindDropDownToCachedTable(this.ddlDistrict, "View_AllDistricts_Extended", " districtCode in (" + permittedDistricts + ") ", "districtName");
            this.ddlDistrict.Items.RemoveAt(0);
        }
        else
            UIHelper.BindDropDownToCachedTable(this.ddlDistrict, "View_AllDistricts_Extended", "districtName");

        UIHelper.BindDropDownToCachedTable(this.ddlUserDomain, "DIC_Domains", "DomainName");

        this.BindDdlPermissionType();
        //this.LimitDdlUserIsInDomain();

        // 05.09.2012 - Vadim Rasin - If the current user "manage tarifon view" bindings:
        if (this.currentUserInfo.CanManageTarifonViews && !this.currentUserInfo.IsAdministrator)
        {
            this.ddlPermissionType.Enabled = false;
            this.ddlDistrict.Enabled = false;
            //this.ddlUserDomain.Enabled = false;
            //this.ddlReportErrors.Enabled = false;
        }
    }

    private string GetPermittedDistricts()
    {
        permittedDistricts = string.Empty;
        foreach (UserPermission UP in this.currentUserInfo.UserPermissions)
        {
            if (UP.PermissionType == Enums.UserPermissionType.District)
            {
                if (permittedDistricts != string.Empty)
                    permittedDistricts = permittedDistricts + ',';
                permittedDistricts = permittedDistricts + UP.DeptCode.ToString();
            }
        }
        return permittedDistricts;
    }

    private void BindDdlPermissionType()
    {
        if (this.currentUserInfo.IsAdministrator)
        {
            UIHelper.BindDropDownToCachedTable(this.ddlPermissionType, "PermissionTypes",
                "PermissionCode <> " + (int)Enums.UserPermissionType.AvailableToAll, "permissionDescription");
            return;
        }
        else
        {
            ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();

            DataTable tbl = cacheHandler.getCachedDataTable(eCachedTables.PermissionTypes.ToString());

            string filter = "permissionCode <> " + (int)Enums.UserPermissionType.Administrator +
                                " and permissionCode <>" + (int)Enums.UserPermissionType.District +
                                " and permissionCode <>" + (int)Enums.UserPermissionType.AvailableToAll +
                                " and permissionCode <>" + (int)Enums.UserPermissionType.ManageTarifonViews +
                                " and permissionCode <>" + (int)Enums.UserPermissionType.ManageInternetSalServices;

            if (this.currentUserInfo.CanManageTarifonViews)
            {
                filter += " and permissionCode =" + (int)Enums.UserPermissionType.ViewTarifon;
            }

            DataView dv = new DataView(tbl, filter, "permissionDescription", DataViewRowState.CurrentRows);

            this.ddlPermissionType.AppendDataBoundItems = false;
            this.ddlPermissionType.DataSource = dv;
            this.ddlPermissionType.DataBind();
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        RemoveAllExpandedUserPermissions();
        GetParametersAndBindGvUsers();
    }

    private void GetParametersAndBindGvUsers()
    {
        hdnDeptCode.Value = hdnMinheletValue.Value = string.Empty;
        int districtCode = Convert.ToInt32(ddlDistrict.SelectedValue);
        int permissionType = Convert.ToInt32(ddlPermissionType.SelectedValue);
        string userNameAD = txtUserNameSearch.Text.Trim();
        if (userNameAD == string.Empty)
            userNameAD = null;
        string firstName = txtUserFirstNameSearch.Text.Trim();
        if (firstName == string.Empty)
            firstName = null;
        string lastName = txtUserLastNameSearch.Text.Trim();
        if (lastName == string.Empty)
            lastName = null;
        Int64? userID = null;
        string domain = null;
        if (ddlUserDomain.SelectedValue != string.Empty)
            domain = ddlUserDomain.SelectedValue;
        bool? definedInAD = null;
        if (ddlUserIsInDomain.SelectedValue != "-1")
            definedInAD = Convert.ToBoolean(Convert.ToInt16(ddlUserIsInDomain.SelectedValue));
        bool? errorReport = null;
        if (ddlReportErrors.SelectedValue != "-1")
            errorReport = Convert.ToBoolean(Convert.ToInt16(ddlReportErrors.SelectedValue));
        bool? trackingNewClinic = null;
        if (ddlTrackingNewClinic.SelectedValue != "-1")
            trackingNewClinic = Convert.ToBoolean(Convert.ToInt16(ddlTrackingNewClinic.SelectedValue));
        bool? ReportRemarksChange = null;
        if (ddlReportRemarksChange.SelectedValue != "-1")
            ReportRemarksChange = Convert.ToBoolean(Convert.ToInt16(ddlReportRemarksChange.SelectedValue));

        dsUser = applicFacade.GetUserList(districtCode, permissionType, userNameAD, firstName, lastName, userID, domain, definedInAD, errorReport, trackingNewClinic, ReportRemarksChange);
        gvUsers.DataSource = dsUser.Tables[0];
        gvUsers.DataBind();
    }

    protected void btnDeleteUser_Click(object sender, EventArgs e)
    {
        ImageButton btnDeleteUser = sender as ImageButton;
        Int64 userID = Convert.ToInt64(btnDeleteUser.Attributes["UserID"]);
        if (applicFacade.DeleteUser(userID))
            GetParametersAndBindGvUsers();
    }

    protected void btnPlus_Click(object sender, EventArgs e)
    {
        ImageButton btnPlus = sender as ImageButton;
        Int64 userID = Convert.ToInt64(btnPlus.Attributes["UserID"]);

        if (!ExpandedUserPermissions.ContainsKey(userID))
            ExpandedUserPermissions.Add(userID, userID);

        AddToExpandedUserPermissions(userID);

    }

    protected void btnMinus_Click(object sender, EventArgs e)
    {
        ImageButton btnMinus = sender as ImageButton;
        Int64 userID = Convert.ToInt64(btnMinus.Attributes["UserID"]);

        ExpandedUserPermissions.Remove(userID);

        RemoveFromExpandedUserPermissions(userID);
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (ViewState["SelectedrowClientID"] != null)
        {
            string rowind = ViewState["SelectedrowIndex"].ToString();
            string SelectedrowClientID = ViewState["SelectedrowClientID"].ToString();
            ClientScript.RegisterStartupScript(typeof(string), "startPrefix", "selectRowOnLoad('" + SelectedrowClientID + "'," + rowind + ");", true);
        }

        if (Session["InsertUserError"] != null)
        {
            //dvUserDetails.Visible = true;
            Session["InsertUserError"] = null;
        }

        if (IsPostBack)
            GetParametersAndBindGvUsers();

    }

    protected void gvUsers_DataBound(object sender, EventArgs e)
    {
        //if (txtSelectedUserName.Text.Length > 0)
        //    gvUsers.SelectedValue = txtSelectedUserName.Text;

        for (int i = 0; i < gvUsers.Rows.Count; i++)
        {
            if (gvUsers.Rows[i].RowType == DataControlRowType.DataRow)
            {
                Label lblUserID = gvUsers.Rows[i].FindControl("lblUserID") as Label;
                //Label lblUserName = gvUsers.Rows[i].FindControl("lblUserName") as Label;

                if (lblUserID.Text == txtSelectedUserName.Text)
                    gvUsers.SelectedIndex = i;

                //for (int j = 0; j < ServicesList.Length; j++)
                //{
                //    if (lblServiceCode.Text == ServicesList[j])
                //    {
                //        cb.Checked = true;
                //    }
                //}
            }
        }

    }
    protected void gvUsers_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lblUserID = e.Row.FindControl("lblUserID") as Label;
            Label lblDefinedInAD = e.Row.FindControl("lblDefinedInAD") as Label;
            Label lblUserName = e.Row.FindControl("lblUserName") as Label;
            Label lblDomain = e.Row.FindControl("lblDomain") as Label;
            ImageButton btnUpdateUser = e.Row.FindControl("btnUpdateUser") as ImageButton;
            Int64 currentUserID = Convert.ToInt64(lblUserID.Text);
            string[] userName = lblUserName.Text.Split('\\');
            string pureUserName;
            if (userName.Length > 1)
                pureUserName = userName[1];
            else
                pureUserName = userName[0];

            btnUpdateUser.Attributes.Add("onClick", "return OpenUpdateUser('" + currentUserID + "','" + pureUserName + "','" + lblDomain.Text + "','" + lblDefinedInAD.Text + "');");

            ImageButton btnPlus = e.Row.FindControl("btnPlus") as ImageButton;
            btnPlus.Attributes.Add("onClick", "return ExpandUserID('" + currentUserID + "');");

            ImageButton btnMinus = e.Row.FindControl("btnMinus") as ImageButton;
            btnMinus.Attributes.Add("onClick", "return CollapsUserID('" + currentUserID + "');");

            HtmlTableCell tdUserPermissions = e.Row.FindControl("tdUserPermissions") as HtmlTableCell;
            if (expandedUserPermissions_Hashtable.ContainsKey(currentUserID))
            //if (ExpandedUserPermissions.ContainsKey(currentUserID))
            {
                if (dsUser.Tables[1].Rows.Count > 0)
                {
                    tdUserPermissions.Visible = true;
                    btnMinus.Visible = true;
                    btnPlus.Visible = false;

                    DataView dvUserPermissions = new DataView(dsUser.Tables[1], "UserID = " + currentUserID, "", DataViewRowState.CurrentRows);

                    if (this.currentUserInfo.CanManageTarifonViews && !this.currentUserInfo.IsAdministrator)
                    {
                        // The user can manage tarifon and he is not an administrator - show him only the viewtarifon permissions for the users that he is able to see.
                        dvUserPermissions.RowFilter += " And permissionType = 8";
                    }

                    GridView gvUserPermissions = e.Row.FindControl("gvUserPermissions") as GridView;
                    gvUserPermissions.DataSource = dvUserPermissions;
                    gvUserPermissions.DataBind();
                }
            }
            else
            {
                tdUserPermissions.Visible = false;
                btnMinus.Visible = false;
                btnPlus.Visible = true;
            }

        }
    }
    protected void bExportToExcel_Click(object sender, EventArgs e)
    {
        DataSet dsExcelDataSource = this.GetDataSource();
        if (dsExcelDataSource != null && dsExcelDataSource.Tables.Count > 0)
        {
            //dsExcelDataSource.Tables[0].Columns[];
            DataTable dt = dsExcelDataSource.Tables[0];
            this.ExportToExcel(dsExcelDataSource.Tables[0]);
        }
    }

    public void ExportToExcel(DataTable dt)
    {
        if (dt.Rows.Count > 0)
        {
            string filename = "UsersList_" + DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss") + ".xls";
            System.IO.StringWriter tw = new System.IO.StringWriter();
            System.Web.UI.HtmlTextWriter hw = new System.Web.UI.HtmlTextWriter(tw);

            DataGrid dgGrid = new DataGrid();

            dgGrid.AutoGenerateColumns = false;

            // Set columns for the excel grid rendering:

            BoundColumn bcLastName = new BoundColumn();
            bcLastName.DataField = "LastName";
            bcLastName.HeaderText = "שם משפחה";

            BoundColumn bcFirstName = new BoundColumn();
            bcFirstName.DataField = "FirstName";
            bcFirstName.HeaderText = "שם פרטי";

            BoundColumn bcUserName = new BoundColumn();
            bcUserName.DataField = "UserName";
            bcUserName.HeaderText = "שם משתמש";

            BoundColumn bcUserDescription = new BoundColumn();
            bcUserDescription.DataField = "UserDescription";
            bcUserDescription.HeaderText = "פרטים נוספים";

            BoundColumn bcPhoneNumber = new BoundColumn();
            bcPhoneNumber.DataField = "PhoneNumber";
            bcPhoneNumber.HeaderText = "טלפון";

            BoundColumn bcUserID = new BoundColumn();
            bcUserID.DataField = "UserID";
            bcUserID.HeaderText = "ת.ז.";

            BoundColumn bcEmail = new BoundColumn();
            bcEmail.DataField = "Email";
            bcEmail.HeaderText = "מייל";

            BoundColumn bcTrackingRemarkChanges = new BoundColumn();
            bcTrackingRemarkChanges.DataField = "TrackingRemarkChanges";
            bcTrackingRemarkChanges.HeaderText = "הודעה על הוספת הערה ליחידה";

            BoundColumn bcErrorReport = new BoundColumn();
            bcErrorReport.DataField = "ErrorReport";
            bcErrorReport.HeaderText = "דיווח שגויים";

            BoundColumn bcTrackingNewClinic = new BoundColumn();
            bcTrackingNewClinic.DataField = "TrackingNewClinic";
            bcTrackingNewClinic.HeaderText = "הודעה על יחידה חדשה";

            BoundColumn bcMaxUpdateDate = new BoundColumn();
            bcMaxUpdateDate.DataField = "MaxUpdateDate";
            bcMaxUpdateDate.HeaderText = "התאריך האחרון שבו המשתמש עדכן פריט כלשהו בספר השירות";

            BoundColumn bcPermissionDescription = new BoundColumn();
            bcPermissionDescription.DataField = "permissionDescription";
            bcPermissionDescription.HeaderText = "רמת הרשאה";

            BoundColumn bcDeptCode = new BoundColumn();
            bcDeptCode.DataField = "deptCode";
            bcDeptCode.HeaderText = "קוד יחידה";

            BoundColumn bcDeptName = new BoundColumn();
            bcDeptName.DataField = "deptName";
            bcDeptName.HeaderText = "שם יחידה";

            dgGrid.Columns.Add(bcLastName);
            dgGrid.Columns.Add(bcFirstName);
            dgGrid.Columns.Add(bcUserName);
            dgGrid.Columns.Add(bcUserDescription);
            dgGrid.Columns.Add(bcPhoneNumber);
            dgGrid.Columns.Add(bcUserID);
            dgGrid.Columns.Add(bcEmail);

            if (dt.Columns.Contains("TrackingRemarkChanges"))
            { 
                dgGrid.Columns.Add(bcTrackingRemarkChanges);           
            }
            dgGrid.Columns.Add(bcErrorReport);
            dgGrid.Columns.Add(bcTrackingNewClinic);
            dgGrid.Columns.Add(bcMaxUpdateDate);
            dgGrid.Columns.Add(bcPermissionDescription);
            dgGrid.Columns.Add(bcDeptCode);
            dgGrid.Columns.Add(bcDeptName);

            dgGrid.DataSource = dt;
            dgGrid.DataBind();

            //Get the HTML for the control.
            dgGrid.RenderControl(hw);

            Response.Clear();
            Response.ContentType = "application/vnd.ms-excel";
            Response.Write("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-1255\" />");

            Response.AppendHeader("Content-Disposition", "attachment; filename=" + filename + "");

            Response.Write(tw.ToString());
            Response.End();
        }
    }

    private DataSet GetDataSource()
    {
        DataSet dsUsers;

        hdnDeptCode.Value = hdnMinheletValue.Value = string.Empty;
        int districtCode = Convert.ToInt32(ddlDistrict.SelectedValue);
        int permissionType = Convert.ToInt32(ddlPermissionType.SelectedValue);
        string userNameAD = txtUserNameSearch.Text.Trim();
        if (userNameAD == string.Empty)
            userNameAD = null;
        string firstName = txtUserFirstNameSearch.Text.Trim();
        if (firstName == string.Empty)
            firstName = null;
        string lastName = txtUserLastNameSearch.Text.Trim();
        if (lastName == string.Empty)
            lastName = null;
        Int64? userID = null;
        string domain = null;
        if (ddlUserDomain.SelectedValue != string.Empty)
            domain = ddlUserDomain.SelectedValue;
        bool? definedInAD = null;
        if (ddlUserIsInDomain.SelectedValue != "-1")
            definedInAD = Convert.ToBoolean(Convert.ToInt16(ddlUserIsInDomain.SelectedValue));
        bool? errorReport = null;
        if (ddlReportErrors.SelectedValue != "-1")
            errorReport = Convert.ToBoolean(Convert.ToInt16(ddlReportErrors.SelectedValue));
        bool? trackingNewClinic = null;
        if (ddlTrackingNewClinic.SelectedValue != "-1")
            trackingNewClinic = Convert.ToBoolean(Convert.ToInt16(ddlTrackingNewClinic.SelectedValue));
        bool?trackingRemarkChanges = null;
        if (ddlReportRemarksChange.SelectedValue != "-1")
            trackingRemarkChanges = Convert.ToBoolean(Convert.ToInt16(ddlReportRemarksChange.SelectedValue));

        dsUsers = applicFacade.GetUserListForExcell(districtCode, permissionType, userNameAD, firstName, lastName, userID, domain, definedInAD, errorReport, trackingNewClinic, trackingRemarkChanges);

        return dsUsers;
    }

}
