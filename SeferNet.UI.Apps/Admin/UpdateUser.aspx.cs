using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Data;
using System.Configuration;
using System.Collections;
using System.Web.Security;
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

public partial class UpdateUser : AdminPopupBasePage
{
    UserInfo userInfo;
    UserInfo currentUserInfo;
    Facade applicFacade;
    string permittedDistricts;
    string userPermissions_ViewState = "userPermissions_ViewState";
    string BG_ReadOnly = "#F7F7F7";
    string BG_notReadOnly = "White";

    protected int DefaultDistrict 
    {
        get
        {
            if (ViewState["defaultDistrict"] == null)
                return -1;

            return (int)ViewState["defaultDistrict"];
        }
        set
        {
            ViewState["defaultDistrict"] = value;
        }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();

        UserManager userMenager = new UserManager();
        currentUserInfo = userMenager.GetUserInfoFromSession();

        if (!IsPostBack)
        {
            HandleBinding();
            SetControlPermissions();
            GetUserDataAndBind(Convert.ToInt64(hdnInitialUserID.Text), hdnUserNameFromQueryString.Text, hdnDomainFromQueryString.Text, cbDefinedInAD.Checked);
            SetContextKeys();

            /*int selectedPermission = Convert.ToInt32(ddlPermissionType.SelectedValue);
            if (currentUserInfo.IsAdministrator &&
                (selectedPermission == (int)Enums.UserPermissionType.ViewHiddenAndReports
                || selectedPermission == (int)Enums.UserPermissionType.District
                || selectedPermission == (int)Enums.UserPermissionType.ViewHiddenDetails)
                )
            {
                trDdlDistricts.Style.Add("display", "none");
                //trTxtDistrictList.Style.Remove("display");
            }
            else
            {
                //trTxtDistrictList.Style.Add("display", "none");
                //trDdlDistricts.Style.Remove("display");
            }*/
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        SetControlsAbility(cbDefinedInAD.Checked);
    }

    private void GetUserDataAndBind(Int64 userIDfromQS, string userNameFromQS, string domainFromQS, bool userDefinedInAD)
    {
        DataSet dsUserPermissions;

        if (userIDfromQS == 0) // Add new user case
        {
            cbNewUser.Checked = true;
            return;
        }
        applicFacade = Facade.getFacadeObject();

        if (userDefinedInAD)
        {
            userInfo = applicFacade.GetAllRelevantPropertiesOfUser(domainFromQS, userNameFromQS);
            userInfo.DefinedInAD = userDefinedInAD;
        }
        else
            userInfo = applicFacade.GetUserInfoFromDB(Convert.ToInt64(hdnInitialUserID.Text));

        if (userInfo == null || userInfo.UserID == 0)
            lblError.Text = "המשתמש אינו קיים ב AD";
        else
        {
            lblError.Text = string.Empty;
            SetControlsFromUserInfo(userInfo);

            dsUserPermissions = applicFacade.GetUserPermissions(userInfo.UserID);
            
            
            ViewState[userPermissions_ViewState] = dsUserPermissions.Tables[0];

            DataView dvUserPermissions = new DataView((DataTable)ViewState[userPermissions_ViewState]);

            if (this.currentUserInfo.CanManageTarifonViews && !this.currentUserInfo.IsAdministrator)
            {
                dvUserPermissions.RowFilter = "permissionType = 8";
            }

            this.gvUserPermissions.DataSource = dvUserPermissions;
            this.gvUserPermissions.DataBind();
        }

    }

    private void HandleBinding()
    {
        //ddlDistricts.Enabled = false;

        UIHelper.BindDropDownToCachedTable(ddlUserDomain, "DIC_Domains", "DomainName");
        //UIHelper.BindDropDownToCachedTable(ddlDistricts, "View_AllDistricts", "districtName");
        permittedDistricts = GetPermittedDistricts();

        if (!currentUserInfo.IsAdministrator && permittedDistricts != string.Empty)
        {
            UIHelper.BindDropDownToCachedTable(ddlDistricts, "View_AllDistricts_Extended", " districtCode in (" + permittedDistricts + ") ", "districtName");
            ddlDistricts.Items.RemoveAt(0);
        }
        else
            UIHelper.BindDropDownToCachedTable(ddlDistricts, "View_AllDistricts_Extended", "districtName");

        ddlDistricts.Enabled = false;

        LimitAllowedDistrict();
        BindDdlPermissionType();

        ddlUserDomain.SelectedValue = "CLALIT";

        // 05.09.2012 - Vadim Rasin - If the current user "manage tarifon view" bindings:
        if (this.currentUserInfo.CanManageTarifonViews && !this.currentUserInfo.IsAdministrator)
        {
            this.ddlPermissionType.Enabled = false;
            this.ddlDistricts.Enabled = false;
            this.ddlUserDomain.Enabled = false;
            this.txtUserDescription.Enabled = false;
            
        }
    }

    private void LimitAllowedDistrict()
    {
        //if user is not permitted to administer users
        if (!currentUserInfo.IsAdministrator)
        {
            if (permittedDistricts == string.Empty)
            {
                ddlDistricts.SelectedValue = currentUserInfo.DistrictCode.ToString();
                ddlDistricts.Enabled = false;

                acMinhelet.ContextKey = ddlDistricts.SelectedValue;
                acDept.ContextKey = ddlDistricts.SelectedValue;
                DefaultDistrict = currentUserInfo.DistrictCode;
            }
        }
    }

    private void BindDdlPermissionType()
    {
        UserInfo currentUser = Session["currentUser"] as UserInfo;

        if (currentUser.IsAdministrator)
        {
            UIHelper.BindDropDownToCachedTable(ddlPermissionType, "PermissionTypes", 
                                               "PermissionCode <> " + (int)Enums.UserPermissionType.AvailableToAll, 
                                               "permissionDescription");
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

            if (this.currentUserInfo.CanManageTarifonViews && !this.currentUserInfo.IsAdministrator)
            {
                filter += " and permissionCode =" + (int)Enums.UserPermissionType.ViewTarifon;
            }

            DataView dv = new DataView(tbl, filter, "permissionDescription", DataViewRowState.CurrentRows);

            ddlPermissionType.AppendDataBoundItems = false;
            ddlPermissionType.DataSource = dv;
            ddlPermissionType.DataBind();

            if (this.currentUserInfo.IsAdministrator && !this.currentUserInfo.CanManageTarifonViews)
            {
                ListItem listItem = new ListItem("בחר", "-1");
                ddlPermissionType.Items.Insert(0, listItem);
            }
        }
    }

    private string GetPermittedDistricts()
    {
        permittedDistricts = string.Empty;
        if (currentUserInfo != null)
        { 
            foreach (UserPermission UP in currentUserInfo.UserPermissions)
            {
                if (UP.PermissionType == Enums.UserPermissionType.District)
                {
                    if (permittedDistricts != string.Empty)
                        permittedDistricts = permittedDistricts + ',';
                    permittedDistricts = permittedDistricts + UP.DeptCode.ToString();
                }
            }
        }

        return permittedDistricts;
    }

    private void SetControlPermissions()
    {
        UserManager userManager = new UserManager();
        hdnInitialUserID.Text = Request.QueryString["UserID"].ToString();
        hdnUserNameFromQueryString.Text = Request.QueryString["UserName"].ToString();
        hdnDomainFromQueryString.Text = Request.QueryString["Domain"].ToString();

        if (Convert.ToInt64(hdnInitialUserID.Text) == 0) // add new user
        {
            if (userManager.UserIsAdministrator())
            {
                cbDefinedInAD.Enabled = true;
            }
            else
            {
                cbDefinedInAD.Enabled = false;
            }

            cbDefinedInAD.Checked = true;
        }
        else // udate existed user
        { 
            cbDefinedInAD.Enabled = false;
            cbDefinedInAD.Checked = Convert.ToBoolean(Convert.ToInt16( Request.QueryString["DefinedInAD"]));
        }

        SetControlsAbility(cbDefinedInAD.Checked);
    }

    private void SetControlsAbility(bool userIsInAD)
    {
        if (Convert.ToInt64(hdnInitialUserID.Text) > 0)
        {
            imgBtnAddPermission.Enabled = true;
            btnSave.Enabled = true;
        }
        else
        {
            imgBtnAddPermission.Enabled = false;
            btnSave.Enabled = false;
        }

        if (userIsInAD)
        {
            txtUserID.ReadOnly = true;
            txtUserID.Style.Add("background-color", BG_ReadOnly);
            txtFirstName.ReadOnly = true;
            txtFirstName.Style.Add("background-color", BG_ReadOnly);
            txtLastName.ReadOnly = true;
            txtLastName.Style.Add("background-color", BG_ReadOnly);
            txtUserMail.ReadOnly = true;
            txtUserMail.Style.Add("background-color", BG_ReadOnly);
            txtUserPhone.ReadOnly = true;
            txtUserPhone.Style.Add("background-color", BG_ReadOnly);

            if (Convert.ToInt64(hdnInitialUserID.Text) > 0)
            {
                btnGetUserFromAD.Enabled = false;
                txtUserName.ReadOnly = true;
                ddlUserDomain.Enabled = false;
            }
            else
            {
                btnGetUserFromAD.Enabled = true;
                txtUserName.ReadOnly = false;
                ddlUserDomain.Enabled = true;
            }
            tblBtnConfirm.Visible = false;
        }
        else
        {
            if (Convert.ToInt64(hdnInitialUserID.Text) > 0)
            {
                txtUserID.ReadOnly = true;
                txtUserID.Style.Add("background-color", BG_ReadOnly);
            }
            else
            {
                txtUserID.ReadOnly = false;
                txtUserID.Style.Add("background-color", BG_notReadOnly);
            }
            //txtUserName.ReadOnly = false;
            txtFirstName.ReadOnly = false;
            txtFirstName.Style.Add("background-color", BG_notReadOnly);
            txtLastName.ReadOnly = false;
            txtLastName.Style.Add("background-color", BG_notReadOnly);
            txtUserMail.ReadOnly = false;
            txtUserMail.Style.Add("background-color", BG_notReadOnly);
            txtUserPhone.ReadOnly = false;
            txtUserPhone.Style.Add("background-color", BG_notReadOnly);
            ddlUserDomain.Enabled = true;
            btnGetUserFromAD.Enabled = false;

            if (Convert.ToInt64(hdnInitialUserID.Text) > 0)
                tblBtnConfirm.Visible = false;
            else
                tblBtnConfirm.Visible = true;
        }
    }

    private void SetControlsDefaults()
    {
        //ddlUserDomain.SelectedIndex = 0;
        //txtUserName.Text = string.Empty;
        txtUserID.Text = string.Empty;
        txtFirstName.Text = string.Empty;
        txtLastName.Text = string.Empty;
        txtUserMail.Text = string.Empty;
        txtUserPhone.Text = string.Empty;
        txtUserDescription.Text = string.Empty;
        gvUserPermissions.DataSource = null;
        gvUserPermissions.DataBind();
    }

    protected void btnGetUserFromAD_Click(object sender, EventArgs e)
    {
        SetControlsDefaults();

        string domain = ddlUserDomain.SelectedValue;
        userInfo = applicFacade.GetAllRelevantPropertiesOfUser(domain, txtUserName.Text);

        if (userInfo == null || userInfo.Name == string.Empty)
            lblError.Text = "המשתמש אינו קיים ב AD";
        else
        {
            if (userInfo.UserID == 0)
            {
                lblError.Text = "המשתמש לא אקטיבי ב AD";
            }
            else
            {
                userInfo.DefinedInAD = true;

                lblError.Text = string.Empty;

                //check here whether user exists in our DB or not
                // If already exists and is considered to be added as new user then:
                // popUp "mode" to be changed and userPermissions to be set
                UserInfo userInfoFromDB = applicFacade.GetUserInfoFromDB(userInfo.UserID);
                if (userInfoFromDB != null && userInfoFromDB.UserID == userInfo.UserID)
                {
                    userInfo.DefinedInAD = true;
                    SetControlsFromUserInfo(userInfo);

                    DataSet dsUserPermissions = applicFacade.GetUserPermissions(userInfo.UserID);
                    ViewState[userPermissions_ViewState] = dsUserPermissions.Tables[0];

                    DataView dvUserPermissions = new DataView((DataTable)ViewState[userPermissions_ViewState]);

                    if (this.currentUserInfo.CanManageTarifonViews && !this.currentUserInfo.IsAdministrator )
                    {
                        dvUserPermissions.RowFilter = "permissionType = 8";
                    }

                    this.gvUserPermissions.DataSource = dvUserPermissions;
                    this.gvUserPermissions.DataBind();

                    cbNewUser.Checked = false;
                    return;
                }

                SetControlsFromUserInfo(userInfo);
            }
        }
    }

    private void SetControlsFromUserInfo(UserInfo userInfo)
    { 
        txtUserID.Text = userInfo.UserID.ToString();
        hdnInitialUserID.Text = userInfo.UserID.ToString();

        txtFirstName.Text = userInfo.FirstName.ToString();
        txtLastName.Text = userInfo.LastName.ToString();
        if (userInfo.Phone != null)
            txtUserPhone.Text = userInfo.Phone.ToString();
        else
            txtUserPhone.Text = string.Empty;

        if (userInfo.Mail != null)
            txtUserMail.Text = userInfo.Mail;
        else
            txtUserMail.Text = string.Empty;

        if (userInfo.Description != null)
            txtUserDescription.Text = userInfo.Description;
        else
            txtUserDescription.Text = string.Empty;

        txtUserName.Text = userInfo.UserAD;

        if (userInfo.Domain != null)
            ddlUserDomain.SelectedValue = userInfo.Domain;

        cbDefinedInAD.Checked = userInfo.DefinedInAD;
    }

    protected void btnDeletePermission_Click(object sender, EventArgs e)
    {
        ImageButton btnDeletePermission = sender as ImageButton;
        int userID = Convert.ToInt32(btnDeletePermission.Attributes["UserID"]);
        int permissionType = Convert.ToInt32(btnDeletePermission.Attributes["PermissionType"]);
        int deptCode = Convert.ToInt32(btnDeletePermission.Attributes["deptCode"]);

        int indexToBeRemoved = -1;
        DataTable dtUserPermissions = (DataTable)ViewState[userPermissions_ViewState];
        for (int i = 0; i < dtUserPermissions.Rows.Count; i++)
        {
            if (Convert.ToInt32(dtUserPermissions.Rows[i]["deptCode"]) == deptCode && Convert.ToInt32(dtUserPermissions.Rows[i]["PermissionType"]) == permissionType)
                indexToBeRemoved = i;
        }

        if (indexToBeRemoved >= 0)
        {
            dtUserPermissions.Rows.RemoveAt(indexToBeRemoved);
            dtUserPermissions.AcceptChanges();
        }

        DataView dvUserPermissions = new DataView(dtUserPermissions);

        if (this.currentUserInfo.CanManageTarifonViews && !this.currentUserInfo.IsAdministrator)
        {
            dvUserPermissions.RowFilter = "permissionType = 8";
        }

        this.gvUserPermissions.DataSource = dvUserPermissions;
        this.gvUserPermissions.DataBind();

        ViewState[userPermissions_ViewState] = dtUserPermissions;
    }

    protected void ddlPermissionType_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtMinhelet.Text = string.Empty;
        txtDept.Text = string.Empty;
        hdnMinheletValue.Text = string.Empty;
        hdnDeptCode.Text = string.Empty;

        txtMinhelet.Enabled = txtDept.Enabled = ddlDistricts.Enabled = false;
        int selectedPermission = Convert.ToInt32(ddlPermissionType.SelectedValue);

        //this.txtDistrictList.Enabled = false;
        this.ddlDistricts.Enabled = false;
        //this.btnDistrict.Disabled = true;

        if (ddlPermissionType.SelectedValue == "-1") return;

        if (selectedPermission == (int)Enums.UserPermissionType.AdminClinic)
        {
            txtMinhelet.Enabled = true;
        }
        else
        {
            if (selectedPermission == (int)Enums.UserPermissionType.Clinic)
            {
                txtMinhelet.Enabled = true;
                txtDept.Enabled = true;
            }
        }

        if (selectedPermission == (int)Enums.UserPermissionType.District || 
            selectedPermission == (int)Enums.UserPermissionType.Administrator ||
            selectedPermission == (int)Enums.UserPermissionType.ViewTarifon  ||
            selectedPermission == (int)Enums.UserPermissionType.ManageInternetSalServices ||
            selectedPermission == (int)Enums.UserPermissionType.ManageTarifonViews
            )
        {
            cbErrorReport.Enabled = true;
        }
        else
        { 
            cbErrorReport.Enabled = false;
            cbErrorReport.Checked = false;
        }

        if (selectedPermission == (int)Enums.UserPermissionType.District ||
            selectedPermission == (int)Enums.UserPermissionType.Administrator ||
            selectedPermission == (int)Enums.UserPermissionType.AdminClinic ||
            selectedPermission == (int)Enums.UserPermissionType.ViewHiddenAndReports
            )
        {
            cbTrackingNewClinic.Enabled = true;
        }
        else
        {
            cbTrackingNewClinic.Enabled = false;
            cbTrackingNewClinic.Checked = false;
        }

        if (selectedPermission == (int)Enums.UserPermissionType.District ||
            selectedPermission == (int)Enums.UserPermissionType.Administrator)
        {
            cbTrackingFreeRemark.Enabled = true;
        }
        else
        {
            cbTrackingFreeRemark.Enabled = false;
        }

        // always enable if user is system administrator.  otherwise - always disabled
        permittedDistricts = GetPermittedDistricts();

        /*if(selectedPermission == 5)// admin
            ddlDistricts.Enabled = true;
        */
        //if (/*ddlDistricts.Enabled == false &&*/ permittedDistricts != string.Empty && ddlPermissionType.SelectedValue != "-1")
        //    ddlDistricts.Enabled = true;
        
        ddlDistricts.Enabled = true;

        if (selectedPermission == (int)Enums.UserPermissionType.LanguageManagement)
        {
            cbTrackingNewClinic.Enabled = false;
            cbTrackingNewClinic.Checked = false;
            ddlDistricts.Enabled = false;
        }

        //if (/*currentUserInfo.IsAdministrator &&*/
        /*    (selectedPermission == (int)Enums.UserPermissionType.ViewHiddenAndReports
            || selectedPermission == (int)Enums.UserPermissionType.District
            || selectedPermission == (int)Enums.UserPermissionType.ViewHiddenDetails)
            )
        {
            //trDdlDistricts.Style.Add("display", "none");
            //trTxtDistrictList.Style.Remove("display");

            trTxtDistrictList.Style.Add("display", "none");
            trDdlDistricts.Style.Remove("display");
            ddlDistricts.Enabled = true;

        }
        else
        {
            //trTxtDistrictList.Style.Add("display", "none");
            //trDdlDistricts.Style.Remove("display");

            trDdlDistricts.Style.Add("display", "none");
            trTxtDistrictList.Style.Remove("display");
            ddlDistricts.Enabled = false;
        }*/
    }

    protected void ddlDistricts_selectedChanged(object sender, EventArgs e)
    {
        SetContextKeys();

        txtMinhelet.Text = string.Empty;
        txtDept.Text = string.Empty;

        hdnMinheletValue.Text = string.Empty;
    }

    private void SetContextKeys()
    {
        if (Convert.ToInt32(ddlDistricts.SelectedValue) == -1)
        {
            acMinhelet.ContextKey = string.Empty;
        }
        else
        {
            acMinhelet.ContextKey = ddlDistricts.SelectedValue;

            acDept.ContextKey = ddlDistricts.SelectedValue;
            acDept.ServiceMethod = "GetClinicByName_DeptCodePrefixed_DistrictDepended";
        } 
    }

    protected void TxtMinhelet_Changed(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(hdnMinheletValue.Text) || string.IsNullOrEmpty(txtMinhelet.Text))
        {
            if (Convert.ToInt32(ddlDistricts.SelectedValue) == -1)
            {
                acDept.ContextKey = string.Empty;
            }
            else
            {
                acDept.ContextKey = ddlDistricts.SelectedValue;
                acDept.ServiceMethod = "GetClinicByName_DistrictDepended";
            }
        }
        else
        {
            acDept.ContextKey = hdnMinheletValue.Text;
            acDept.ServiceMethod = "GetClinicByName_AdministrationDepended";
        }

    }

    protected void cbDefinedInAD_CheckedChanged(object sender, EventArgs e)
    {
        hdnInitialUserID.Text = "0";
        lblError.Text = string.Empty;
        SetControlsAbility(cbDefinedInAD.Checked);
        SetControlsDefaults();
    }

    protected void imgBtnAddPermission_Click(object sender, ImageClickEventArgs e)
    {
        DataTable dtUserPermissions = (DataTable)ViewState[userPermissions_ViewState];

        if (dtUserPermissions == null)
            dtUserPermissions = applicFacade.GetUserPermissions(-1).Tables[0];

        Enums.UserPermissionType permissionType = (Enums.UserPermissionType)Enum.Parse(typeof(Enums.UserPermissionType),ddlPermissionType.SelectedValue);
        int deptCode = -1;
        //string deptCodes = string.Empty;
        int[] deptCodes;
        string[] deptNames;

        string deptName = string.Empty;

        //switch (permissionType)
        //{
        //    case Enums.UserPermissionType.District:
        //    case Enums.UserPermissionType.ViewHiddenAndReports:
        //        deptCode = Convert.ToInt32(ddlDistricts.SelectedValue);
        //        deptName = ddlDistricts.SelectedItem.Text;
        //        break;

        //    case Enums.UserPermissionType.AdminClinic:
        //        deptCode = Convert.ToInt32(hdnMinheletValue.Text);
        //        deptName = hdnMinheletText.Text;
        //        break;

        //    case Enums.UserPermissionType.Clinic:
        //        deptCode = Convert.ToInt32(hdnDeptCode.Text);
        //        deptName = hdnDeptText.Text;
        //        break;
           
        //    default:
        //        break;
        //}

        switch (permissionType)
        {
            case Enums.UserPermissionType.District:
            case Enums.UserPermissionType.ViewHiddenAndReports:

                string[] strArr = ddlDistricts.SelectedValue.Split();
                deptCodes = Array.ConvertAll(strArr, int.Parse);
                deptNames = this.ddlDistricts.SelectedItem.Text.Split(',');

                break;
            
            case Enums.UserPermissionType.ViewHiddenDetails:
                strArr = ddlDistricts.SelectedValue.Split(',');
                if (strArr.Length == 1 && strArr[0] == string.Empty)
                {
                    deptCodes = new[] { -1 };
                    deptNames = new[] { string.Empty }; 
                }
                else
                {
                    deptCodes = Array.ConvertAll(strArr, int.Parse);
                    deptNames = ddlDistricts.SelectedItem.Text.Split(',');
                }
                break;
            
            case Enums.UserPermissionType.AdminClinic:
                deptCodes = new int[] {Convert.ToInt32(hdnMinheletValue.Text)};
                deptNames = new string[] {hdnMinheletText.Text};
                break;

            case Enums.UserPermissionType.Clinic:
                deptCodes = new int[] {Convert.ToInt32(hdnDeptCode.Text)};
                deptNames = new string[] {hdnDeptText.Text};
                break;
           
            default:
                deptCodes = new int[] {-1};
                deptNames = new string[] {string.Empty};
                break;
        }

        //Loop is not needed, because deptCodes is not array anymore
        for (int ii = 0; ii < deptCodes.Length; ii++)
        {
            //begin
            DataRow newDataRow = dtUserPermissions.NewRow();
            newDataRow["PermissionType"] = (int)permissionType;
            newDataRow["permissionDescription"] = ddlPermissionType.SelectedItem.Text;
            newDataRow["deptCode"] = deptCodes[ii];
            newDataRow["deptName"] = deptNames[ii].Replace(deptCodes[ii].ToString(), "");
            newDataRow["ErrorReport"] = cbErrorReport.Checked;
            newDataRow["TrackingNewClinic"] = cbTrackingNewClinic.Checked;
            newDataRow["TrackingRemarkChanges"] = cbTrackingFreeRemark.Checked;

            if (cbErrorReport.Checked)
                newDataRow["ErrorReportDescription"] = "כן";
            else
                newDataRow["ErrorReportDescription"] = "לא";

            if (cbTrackingNewClinic.Checked)
                newDataRow["TrackingNewCliniDescription"] = "כן";
            else
                newDataRow["TrackingNewCliniDescription"] = "לא";

            if (cbTrackingFreeRemark.Checked)
                newDataRow["TrackingRemarkChangesDescription"] = "כן";
            else
                newDataRow["TrackingRemarkChangesDescription"] = "לא";

            newDataRow["UserID"] = Convert.ToInt64(txtUserID.Text);

            bool isAlreadyExists = false;
            for (int i = 0; i < dtUserPermissions.Rows.Count; i++)
            {
                if (Convert.ToInt32(dtUserPermissions.Rows[i]["deptCode"]) == deptCode &&
                                    Convert.ToInt32(dtUserPermissions.Rows[i]["PermissionType"]) == (int)permissionType)
                    isAlreadyExists = true;
            }
            if (!isAlreadyExists)
            {
                dtUserPermissions.Rows.Add(newDataRow);
                dtUserPermissions.AcceptChanges();
                this.ViewState[userPermissions_ViewState] = dtUserPermissions;

                DataView dvUserPermissions = new DataView((DataTable)ViewState[userPermissions_ViewState]);

                if (this.currentUserInfo.CanManageTarifonViews && !this.currentUserInfo.IsAdministrator)
                {
                    dvUserPermissions.RowFilter = "permissionType = 8";
                }

                this.gvUserPermissions.DataSource = dvUserPermissions;
                this.gvUserPermissions.DataBind();
            }
            //end
        }
        
        this.ViewState[userPermissions_ViewState] = dtUserPermissions;

        txtMinhelet.Text = string.Empty;
        hdnMinheletText.Text = string.Empty;
        txtDept.Text = string.Empty;
        hdnDeptCode.Text = string.Empty;
        hdnDeptText.Text = string.Empty;
        ddlPermissionType.SelectedIndex = 0;
        ddlDistricts.SelectedIndex = 0;
        cbErrorReport.Checked = false;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        UserInfo userInfoToSave = new UserInfo(); 
        applicFacade = Facade.getFacadeObject();
        bool result = true;
        userInfoToSave.UserID = Convert.ToInt64(txtUserID.Text);
        userInfoToSave.UserAD = txtUserName.Text;
        userInfoToSave.FirstName = txtFirstName.Text;
        userInfoToSave.LastName = txtLastName.Text;
        userInfoToSave.Mail = txtUserMail.Text;
        userInfoToSave.Phone = txtUserPhone.Text;
        userInfoToSave.Description = txtUserDescription.Text;
        userInfoToSave.Domain = ddlUserDomain.SelectedValue;
        userInfoToSave.DefinedInAD = cbDefinedInAD.Checked;

        if (ViewState[userPermissions_ViewState] == null)
            ViewState[userPermissions_ViewState] = new DataTable();

        string updateUserName = currentUserInfo.UserAD;

        result = applicFacade.UpdateUser(userInfoToSave, (DataTable)ViewState[userPermissions_ViewState], cbNewUser.Checked, updateUserName);

        if (result)
        {
            string refreshOpener = "1";
            ClientScript.RegisterStartupScript(typeof(string), "selfClose", "selfClose('" + refreshOpener + "');", true);
        }
        else
        {
            handleError();
        }

    }

    private void handleError()
    {
        if (Session["ErrorMessage"] != null)
        {
            string ErrorMsg = Session["ErrorMessage"].ToString();

            Page.ClientScript.RegisterStartupScript(typeof(string), "displayErrorMsg", "alert(' " + ErrorMsg + "');", true);
            Session["ErrorMessage"] = null;
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        string refreshOpener = "0";
        ClientScript.RegisterStartupScript(typeof(string), "selfClose", "selfClose('" + refreshOpener + "');", true);
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        //check here whether user exists in our DB or not
        // If already exists and is considered to be added as new user then:
        // popUp "mode" to be changed and userPermissions to be set
        UserInfo userInfoFromDB = applicFacade.GetUserInfoFromDB(Convert.ToInt64(txtUserID.Text));
        if (userInfoFromDB != null && userInfoFromDB.UserID == Convert.ToInt64(txtUserID.Text))
        {
            SetControlsFromUserInfo(userInfoFromDB);

            DataSet dsUserPermissions = applicFacade.GetUserPermissions(userInfoFromDB.UserID);
            ViewState[userPermissions_ViewState] = dsUserPermissions.Tables[0];

            DataView dvUserPermissions = new DataView((DataTable)ViewState[userPermissions_ViewState]);

            if (this.currentUserInfo.CanManageTarifonViews && !this.currentUserInfo.IsAdministrator)
            {
                dvUserPermissions.RowFilter = "permissionType = 8";
            }

            this.gvUserPermissions.DataSource = dvUserPermissions;
            this.gvUserPermissions.DataBind();

            cbNewUser.Checked = false;
            //return;
        }

        hdnInitialUserID.Text = txtUserID.Text;
        SetControlsAbility(cbDefinedInAD.Checked);
    }
}
