using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.Globals;

public partial class AdminPopupBasePage : System.Web.UI.Page
{
    protected override void OnLoad(EventArgs e)
    {
        CheckSessionAlive();

        base.OnLoad(e);
    }

    private void CheckSessionAlive()
    {
        if (Session["currentUser"] == null)
        {
            ClientScript.RegisterStartupScript(this.GetType(), 
                                               "close", 
                                               "if (window.dialogArguments != '' && window.dialogArguments.location != undefined) "
                                                + "{ " +
                                                    " alert('עבר זמן רב מדי. הינך מועבר לדף הראשי');" +
                                                    " window.dialogArguments.location.href = \"" + Request.ApplicationPath +
                                                    PagesConsts.SEARCH_CLINICS_URL.Replace("~", string.Empty) + "\";" +
                                                    "  window.close(); "
                                                + "}", true);
        }
    }
}