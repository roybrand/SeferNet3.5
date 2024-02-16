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

public partial class BlackListForSimul : AdminBasePage
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
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        UserManager mng = new UserManager();
    }

    protected void btnBackToOpener_Click(object sender, EventArgs e)
    {
        sessionParams.ServiceCode = null;
        SessionParamsHandler.SetSessionParams(sessionParams);

        Response.Redirect(@"~/Public/ZoomClinic.aspx");
    }


    protected void btnUpdateBlackList_Click(object sender, EventArgs e)
    {
        int codeSimul = Convert.ToInt32(txtCodeSimul.Text);
        int seferSherut = Convert.ToInt32(ddlIsForSeferSherut.SelectedValue);
        string userName = Master.getUserName();
        bool result = true;
        result = applicFacade.InsertSimulExceptions(codeSimul, seferSherut, userName);

        if (result == true)
        {
            ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "okMessage", "OkMessage();", true);
        }
        else 
        {
            lblGeneralError.Text = errorMessage;
        }
    }
}
