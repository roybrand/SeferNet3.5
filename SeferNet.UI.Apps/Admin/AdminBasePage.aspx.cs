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
using System.Security.Principal;

using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using System.Collections.Generic;
using SeferNet.Globals;

/// <summary>
/// This page is the base page for all pages contained in the "Admin" Folder
/// </summary>
public partial class AdminBasePage : System.Web.UI.Page
{

    //checks whether the user is authenticated and checks user permissions
    protected bool authenticateUser(string userName)
    {
        return true;
    }

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        //UserInfo currentUser = Session["currentUser"] as UserInfo;
        //if (currentUser == null)
        //{
        //    Response.Redirect(PagesConsts.SEARCH_CLINICS_URL);
        //    Response.End();
        //}
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //return;
        //authenticate

        Facade facade = Facade.getFacadeObject();
        string userName = @"CLALIT\"+User.Identity.Name;
        UserManager userManager = new UserManager(userName);

        UserInfo currentUser = userManager.GetUserInfoFromSession();
        //if user has no permissions       

        if (currentUser != null && currentUser.UserPermissions == null)
        {
            Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "PermissionDenied") as string; 

            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL + "?ErrorString=" + Session["ErrorMessage"], true);

            if (Request.UrlReferrer != null)
            {
                string url = Request.UrlReferrer.AbsoluteUri;
                string queryParams = Request.UrlReferrer.Query;
                string fullUrl = string.Empty;
                fullUrl = Request.UrlReferrer.PathAndQuery;
                Response.Redirect(fullUrl, true);
            }
            else
            {
                Response.Redirect(PagesConsts.SEARCH_CLINICS_URL + "?ErrorString=" + Session["ErrorMessage"], true);
            }
        }

        SetCurrentDeptCode();
        checkUserPermissionsForUpdate();
        
    }


    #region check user permissions for update

   
    public void SetCurrentDeptCode()
    {
        int deptCode;
        if (!IsPostBack)
        {
            deptCode = SessionParamsHandler.GetSessionParams().DeptCode;
            if (deptCode == 0)
                return;
            ViewState["currentDeptCode"] = deptCode;
        }
    }
   
    public void checkUserPermissionsForUpdate()
    {
        if (ViewState["currentDeptCode"] != null)
        {
            Facade facade = Facade.getFacadeObject();
            UserInfo currentUser = Session["currentUser"] as UserInfo;
            if (currentUser == null)
            {
                Session["ErrorMessage"] = "עבר זמן רב מהשימוש האחרון במערכת";
                Response.Redirect(PagesConsts.SEARCH_CLINICS_URL + "?ErrorString=" + Session["ErrorMessage"], true);
            }

            if (!currentUser.IsAdministrator)
            {
                if (!facade.IsDeptPermitted(Convert.ToInt32(ViewState["currentDeptCode"])))
                {
                    Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "PermissionDenied") as string;
                    Response.Redirect(PagesConsts.SEARCH_CLINICS_URL + "?ErrorString=" + Session["ErrorMessage"], true);
                }
            }
        }
    }

    #endregion

    

}
