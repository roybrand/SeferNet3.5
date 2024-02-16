using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;

namespace SeferNet.UI.Apps.Templates
{
    public partial class ZoomSalService_PrintOptions : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            UserManager userManager = new UserManager();
            UserInfo currentUserInfo = userManager.GetUserInfoFromSession();
            bool IsAdministrator = false;
            bool CanManageTarifonViews = false;
            bool CanViewTarifon = false;
            bool CanManageInternetSalServices = false;

            if (currentUserInfo != null && User.Identity.IsAuthenticated)
            {
                IsAdministrator = currentUserInfo.IsAdministrator;
                CanManageTarifonViews = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageTarifonViews, -1);
                CanViewTarifon = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ViewTarifon, -1);
                CanManageInternetSalServices = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageInternetSalServices, -1);

                if (!CanManageInternetSalServices)
                {
                    divInternet.Visible = false;
                }
            }
            else
            {
                divInternet.Visible = false;
            }
        }
    }
}