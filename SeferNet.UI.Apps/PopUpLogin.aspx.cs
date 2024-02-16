using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.Globals;

namespace SeferNet.UI.Apps
{
    public partial class PopUpLogin : System.Web.UI.Page
    {
        string CallerRelativeVirtualPath = string.Empty;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["error"] != null)
            {
                //if (Convert.ToBoolean(Convert.ToInt32(Request.QueryString["error"])) == true)
                //    lblError.Text = "סיסמא או שם משתמש שגויים. אנא נסה שנית";
                //else
                //lblError.Text = Request.QueryString["error"].ToString();
                //lblError.Text = Request.QueryString["error"].ToString();
                string errText = this.GetGlobalResourceObject("ErrorResource", Request.QueryString["error"].ToString()) as string;

                lblError.Text = errText;
            }

            if (!IsPostBack)
                BindDomains();

            txtUserName.Focus();
        }

        public void BindDomains()
        {
            UIHelper.BindDropDownToCachedTable(ddlUserDomain, "DIC_Domains", "DomainName");
            ddlUserDomain.SelectedValue = "CLALIT";
        }

        public string GetNoPermissionText()
        {
            string retVal = string.Empty;

            object obj = this.GetGlobalResourceObject("ErrorResource", "NoPermissionsForUser");
            if (obj != null)
            {
                retVal = obj.ToString();
            }
            return retVal;
        }

        public string GetUserOrPasswordNotCorrectText()
        {
            string retVal = string.Empty;

            object obj = this.GetGlobalResourceObject("ErrorResource", "WrongUserName");
            if (obj != null)
            {
                retVal = obj.ToString();
            }
            return retVal;
        }

    }
}