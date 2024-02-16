using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;

public partial class Public_ReportOnIncorrectData : System.Web.UI.Page
{
    UserInfo currentUser;
    SessionParams sessionParams;

    protected void Page_Load(object sender, EventArgs e)
    {
        sessionParams = SessionParamsHandler.GetSessionParams();
        currentUser = Session["currentUser"] as UserInfo;

        if (!IsPostBack)
        {
            if (currentUser != null)
            {
                txtReporterName.Text = currentUser.FirstName + " " + currentUser.LastName;
            }
            else
            {
                bool getUserNameFromAD = false;

                //string[] userName = System.Security.Principal.WindowsIdentity.GetCurrent().Name.Split('\\'); // Get "DOMAIN\\username"
                string userName_Not_Logged = "userName";//string.Empty;
                string useDomain_Not_Logged = "userDomain";//string.Empty;

                //string[] userName = Request.RequestContext.HttpContext.User.Identity.Name.Split('\\');
                //string userNameFullName = Request.RequestContext.HttpContext.User.Identity.Name;

                string[] userNameArr = System.Web.HttpContext.Current.User.Identity.Name.Split('\\'); //PROD
                string[] userNameArrTest = System.Security.Principal.WindowsIdentity.GetCurrent().Name.Split('\\'); //TEST


                if (System.Web.HttpContext.Current.User.Identity.Name != string.Empty)
                {
                    useDomain_Not_Logged = userNameArr[0];
                    userName_Not_Logged = userNameArr[1];

                    //txtReporterName.Text  = Request.RequestContext.HttpContext.User.Identity.Name;

                    getUserNameFromAD = true;
                }
                else if (System.Security.Principal.WindowsIdentity.GetCurrent().Name != string.Empty)
                { 
                    useDomain_Not_Logged = userNameArrTest[0];
                    userName_Not_Logged = userNameArrTest[1]; 

                    getUserNameFromAD = true;
                    //txtReporterName.Enabled = false;                        
                }

                if (getUserNameFromAD)
                { 
                    System.DirectoryServices.AccountManagement.PrincipalContext ctx = new System.DirectoryServices.AccountManagement.PrincipalContext(System.DirectoryServices.AccountManagement.ContextType.Domain, useDomain_Not_Logged);

                    System.DirectoryServices.AccountManagement.UserPrincipal u = System.DirectoryServices.AccountManagement.UserPrincipal.FindByIdentity(ctx, userName_Not_Logged);
                    txtReporterName.Text = u.ToString();               
                }

            }

        }
    }


    protected void btnSave_click(object sender, EventArgs e)
    {
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
        int deptCode = sessionParams.DeptCode;
        long employeeID = sessionParams.EmployeeID;
        string callerPageLink = sessionParams.CallerUrl;
        Enums.IncorrectDataReportEntity currentEntity = sessionParams.CurrentEntityToReport;

        string errorDescription = txtDescription.Text;
        string reportedBy = txtReporterName.Text;
        string selectedTab = sessionParams.SelectedTab_Key;

        if (deptCode != 0 || employeeID != 0 || currentEntity == Enums.IncorrectDataReportEntity.SalService)
        {
            //if (callerPageLink.ToLower().IndexOf("salservice"))

            if (selectedTab != string.Empty)
            {
                int indexOfSearchID = callerPageLink.ToLower().IndexOf("searchid");

                if (indexOfSearchID > 0)
                {
                    callerPageLink = callerPageLink.Substring(0, indexOfSearchID) + "seltab=" + selectedTab;
                }
                else
                { 
                    int indexOfSelectedTab = callerPageLink.ToLower().IndexOf("seltab");

                    if (indexOfSelectedTab > 0)
                    {
                        callerPageLink = callerPageLink.Substring(0, indexOfSelectedTab) + "seltab=" + selectedTab;
                    }
                    else
                    { 
                        callerPageLink = callerPageLink + "&seltab=" + selectedTab;                      
                    }
              
                }
            }

            Facade.getFacadeObject().ReportOnIncorrectData(deptCode, employeeID, currentEntity, errorDescription, callerPageLink, reportedBy);
        }

        ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string),"close", "self.close();", true);
    }
}
