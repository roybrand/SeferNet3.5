using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;
using SeferNet.FacadeLayer;
using Clalit.SeferNet.EntitiesBL;
using System.Data;
using Clalit.SeferNet.GeneratedEnums;

public partial class SelectDepts : System.Web.UI.Page
{
    private bool MultiSelectMode = false;
    private bool RequireUserPermisions = false;

    public UserInfo CurrentUser
    {
        get
        {
            return new UserManager().GetUserInfoFromSession(); ;
        }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        string loadTitleScript;
        loadTitleScript = "<script>document.title = 'בחירת יחידות';</script>";
        //ClentSc RegisterClientScriptBlock("postbackTitle", loadTitleScript);
        ClientScript.RegisterClientScriptBlock(this.GetType(), "clientScript", loadTitleScript);

        switch (Request.QueryString["MultiSelect"])
        {
            case "1" :
                MultiSelectMode = true;
                break;
            default:
                MultiSelectMode = false;
                break;
        }

        switch (Request.QueryString["RequireUserPermisions"])
        {
            case "1" :
                RequireUserPermisions = true;
                break;
            default:
                RequireUserPermisions = false;
                break;
        }

        if (!IsPostBack)
        {
            BindInitialData();

            if (!RequireUserPermisions)
            {
                divExplanationForUser.Visible = true;

                Facade applicFacade = Facade.getFacadeObject();
                ddlDistrict.SelectedValue = applicFacade.getDeptDistrict(SessionParamsHandler.GetDeptCodeFromSession()).ToString();
            }

        }
        else
        { 
            divExplanationForUser.Visible = false;

            if (txtSelectedDeptCodes.Text != string.Empty)
            {
                //Response.Redirect(@"~/Public/ZoomDoctor.aspx");
                Session["DeptCodesToBeAddedToEmployee"] = txtSelectedDeptCodes.Text;

                SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
                string strEmployeeID = sessionParams.EmployeeID.ToString();
                string parentLocation = "ZoomDoctor.aspx?EmployeeID=" + strEmployeeID;
                ScriptManager.RegisterClientScriptBlock(this.Page, this.GetType(), "RedirectScript", "window.parent.location = '" + parentLocation + "'", true);
            }

        }



        btnSelect.Attributes.Add("onclick", "return ReturnSelectedDeptsMulty()");
        btnCancel.Attributes.Add("onclick", "Close()");
        if (Request.QueryString["useForPrint"] != null)
        {
            SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
            hdnSelectedDeptCode.Value = sessionParams.DeptCode.ToString();
            btnCancel.Text = "המשך";
        }
        btnClear.Attributes.Add("onclick", "Clean()");

        if (!MultiSelectMode)
        {
            tdCbHeader.Visible = false;
            divBtnSelect.Visible = false;
        }

    }

    private void BindInitialData()
    {
        BindDistricts(CurrentUser);

        if (RequireUserPermisions)
            acCities.ContextKey = CurrentUser.DistrictCode.ToString();
        else
            acCities.ContextKey = ddlDistrict.SelectedValue;


        acDeptName.ContextKey = string.Empty;

        if (RequireUserPermisions)
        {
            if (CurrentUser.DistrictCode != -1)
            {
                acDeptName.ContextKey = CurrentUser.DistrictCode.ToString();
            }
        }

    }

    private void BindDistricts(UserInfo currentUser)
    {
        ddlDistrict.DataTextField = View_DeptAddressAndPhonesBL.DeptNameColumnName;
        ddlDistrict.DataValueField = View_DeptAddressAndPhonesBL.DeptCodeColumnName;

        ddlDistrict.DataSource = Facade.getFacadeObject().GetAllDistrictsWithDetails();
        ddlDistrict.DataBind();

        if (RequireUserPermisions)
        {
                //currentUser.MaxPermissionType == Enums.UserPermissionType.District ||
                                               //currentUsercurrentUser.MaxPermissionType == Enums.UserPermissionType.AdminClinic)

            if (currentUser.HasAdminClinicPermission || currentUser.HasDistrictPermission)
            {
                ddlDistrict.SelectedValue = currentUser.DistrictCode.ToString();
                ddlDistrict.Enabled = false;
            }
        }

        ddlDistrict.Items.Insert(0, new ListItem("הכל", "-1"));
    }

    protected void BtnSearch_OnClick(object sender, EventArgs e)
    {
        int deptCode = -1, cityCode = -1, districtCode = -1, unitTypeCode = -1;
        string deptName = string.Empty;
        Facade facade = Facade.getFacadeObject();

        if (!string.IsNullOrEmpty(hdnSelectedDeptCode.Value))
        {
            hdnSelectedDeptCode.Value = hdnSelectedDeptCode.Value.Split(',')[0];

            deptCode = Convert.ToInt32(hdnSelectedDeptCode.Value);
        }
        else
        {
            if (!string.IsNullOrEmpty(txtDeptCode.Text.Trim()))
            {
                deptCode = Convert.ToInt32(txtDeptCode.Text);
            }
            else
            {
                if (!string.IsNullOrEmpty(txtDeptName.Text))
                {
                    deptName = txtDeptName.Text;
                }
            }
        }

        if (!string.IsNullOrEmpty(hdnSelectedCityCode.Value))
        {
            cityCode = Convert.ToInt32(hdnSelectedCityCode.Value);
        }

        if (ddlDistrict.SelectedValue != "-1")
        {
            districtCode = Convert.ToInt32(ddlDistrict.SelectedValue);
        }

        if (!string.IsNullOrEmpty(hdnSelectedUnitTypeCode.Value))
        {
            unitTypeCode = Convert.ToInt32(hdnSelectedUnitTypeCode.Value);
        }

        DataSet ds;

        if (Request.QueryString["useForPrint"] != null)
        {
            if (!string.IsNullOrEmpty(txtDeptCode.Text.Trim()))
            {
                deptCode = Convert.ToInt32(txtDeptCode.Text);
            }
            else
            {
                deptCode = -1;

                if (!string.IsNullOrEmpty(txtDeptName.Text.Trim()))
                {
                    deptName = txtDeptName.Text.Trim();
                }
            }

            ds = facade.GetDeptListByParams(deptCode, deptName, cityCode, districtCode, unitTypeCode);
        }
        else
        { 
            ds = facade.GetDeptListByParams(deptCode, deptName, cityCode, districtCode, unitTypeCode);
        }

        gvDepts.Visible = true;

        if (ds != null && ds.Tables[0].Rows.Count > 0)
        {
            pnlResults.Visible = true;
            lblNoResults.Visible = false;

            gvDepts.DataSource = ds;
            gvDepts.DataBind();
        }
        else
        {
            pnlResults.Visible = false;
            lblNoResults.Visible = true;
        }
    }

    protected void btnClear_OnClick(object sender, EventArgs e)
    {
        txtDeptName.Text = txtDeptCode.Text = txtCityName.Text = txtUnitType.Text = string.Empty;

        hdnSelectedCityCode.Value = hdnSelectedDeptCode.Value = hdnSelectedUnitTypeCode.Value = string.Empty;

        pnlResults.Visible = lblNoResults.Visible = false;


        if (RequireUserPermisions)
        {
            if (CurrentUser.IsAdministrator)
            {
                ddlDistrict.SelectedIndex = 0;
            }
        }
        else
        { 
            ddlDistrict.SelectedIndex = 0;
        }
    }

    protected void ddlDistricts_selectedIndexChanged(object sender, EventArgs e)
    {
        acDeptName.ContextKey = ddlDistrict.SelectedValue;
        acCities.ContextKey = ddlDistrict.SelectedValue;

        txtDeptName.Text = string.Empty;
    }

    protected void lnkDept_clicked(object sender, EventArgs e)
    {
        LinkButton lnkDept = sender as LinkButton;

        int deptCodeToAdd = Convert.ToInt32(lnkDept.CommandName);

        long employeeId = SessionParamsHandler.GetEmployeeIdFromSession();
        Facade facade = Facade.getFacadeObject();

        facade.InsertDoctorInClinic(deptCodeToAdd, employeeId, Convert.ToInt32(eDIC_AgreementTypes.Community), CurrentUser.UserNameWithPrefix, true, string.Empty, false);

        ClientScript.RegisterStartupScript(this.GetType(), "close", "this.close();", true);
    }

    protected void gvDepts_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            LinkButton linkButton = e.Row.FindControl("lnkDeptName") as LinkButton;
            DataRowView row = e.Row.DataItem as DataRowView;
            string deptCode = row["DeptCode"].ToString();
            linkButton.Attributes.Add("onclick", "ReturnSelectedDept(" + deptCode + ")");

            System.Web.UI.HtmlControls.HtmlInputCheckBox cbSelectedDept = e.Row.FindControl("cbSelectedDept") as System.Web.UI.HtmlControls.HtmlInputCheckBox;
            if (!MultiSelectMode)
                cbSelectedDept.Visible = false;
        }
    }
}
