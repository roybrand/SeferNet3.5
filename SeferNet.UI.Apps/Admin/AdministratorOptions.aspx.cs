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
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using Clalit.SeferNet.Services;
using Clalit.Infrastructure.CacheManager;
using CacheAction_ServerNotificationManager;
using SeferNet.Globals;
using SeferNet.UI.Apps.AppCode;


/// <summary>
/// This page is the homepage of the administrator/registered user with permissions
/// 
/// </summary>
public partial class Administrators : AdminBasePage
{

    protected void Page_Load(object sender, EventArgs e)
    {}


    /// <summary>
    /// This button refreshes the dataset of all tables that are held in cache
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnRefreshCache_Click(object sender, EventArgs e)
    {

        ServersNotifierService.RefreshServerInfoList();
       ServersNotifierService.RefreshAllCacheItems();    
    }


    protected void btnTestLoadBalanceService_Click(object sender, EventArgs e)
    {
        bool result = ServersNotifierService.TestConnection();       
    }
	protected void btnResetTemplates_Click(object sender, EventArgs e)
	{
		HtmlTemplateParsing.HtmlTemplateDataManager.ResetTemplateFields();
	}
    protected void btnUpdateProfLicence_Click(object sender, EventArgs e)
	{
        GetEmployeeDetailesByID getEmployeeDetailesByID = new GetEmployeeDetailesByID();
        getEmployeeDetailesByID.UpdateProfLicences();
	}

}
