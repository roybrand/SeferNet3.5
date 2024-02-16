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
using System.Globalization;

using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.BusinessObject;
using System.Data.SqlClient;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.DataLayer;
using SeferNet.FacadeLayer;
using SeferNet.Globals;

public partial class ErrorsReportSimulVcSefer : AdminBasePage
{
    Facade applicFacade;
    UserInfo currentUser;
    System.Collections.Generic.List<UserPermission> PermissionList;
    int deptCode; 
    SessionParams sessionParams;
    string errorMessage;

    protected void Page_Load(object sender, EventArgs e)
    {
        currentUser = Session["currentUser"] as UserInfo;

        sessionParams = SessionParamsHandler.GetSessionParams();

        applicFacade = Facade.getFacadeObject();
        
        if(!IsPostBack)
            BindDropDowns();

        gvErrorsList.DataSource = applicFacade.GetErrorsListSimulVcSefer(Convert.ToInt32(ddlInterfaceErrorCodes.SelectedValue)).Tables[0];
        gvErrorsList.DataBind();
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        UserManager mng = new UserManager();

        SetVisibility();
    }

    void SetVisibility()
    {
        if (gvErrorsList.Rows.Count > 0)
        {
            trNoErrors.Style.Add("display", "none");
            trErrorsListHeader.Style.Add("display", "inline");
            gvErrorsList.Style.Add("display", "inline");
        }
        else
        {
            trNoErrors.Style.Add("display", "inline");
            trErrorsListHeader.Style.Add("display", "none");
            gvErrorsList.Style.Add("display", "none");
        }
    }

    void BindDropDowns()
    {
        UIHelper.BindDropDownToCachedTable(ddlInterfaceErrorCodes, "View_InterfaceErrorCodes", "errorDesc");
    }

    protected void ddlInterfaceErrorCodes_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvErrorsList.DataSource = applicFacade.GetErrorsListSimulVcSefer(Convert.ToInt32(ddlInterfaceErrorCodes.SelectedValue)).Tables[0];
        gvErrorsList.DataBind();
    }

    protected void deptCodeLink_Click(object sender, EventArgs e)
    {
        LinkButton deptCodeLink = sender as LinkButton;
        GridViewRow row = deptCodeLink.Parent.Parent as GridViewRow;
        int deptCode = Convert.ToInt32(deptCodeLink.Text);

        string pageCounter = SessionParamsHandler.GetPageCounter();

        SessionParamsHandler.SetDeptCodeInSession(deptCode);
        Response.Redirect("../Public/ZoomClinic.aspx?DeptCode=" + deptCode.ToString(), true);
    }
    protected void gvErrorsList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            Image imgDetailes = e.Row.FindControl("imgDetailes") as Image;
            imgDetailes.Attributes.Add("onClick", "return OpenClinicDetailesPopUp(" + dvRowView["deptCode"].ToString() + ")");
        }
    }
}
