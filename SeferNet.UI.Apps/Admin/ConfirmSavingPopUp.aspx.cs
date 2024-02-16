using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ConfirmSavingPopUp : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        GetQueryString();
    }
    private bool GetQueryString()
    {
        try
        {
            if (!string.IsNullOrEmpty(Request.QueryString["functionToExecute"]))
            {
                txtFunctionToExecute.Text = Request.QueryString["functionToExecute"].ToString();
            }
        }
        catch
        {
            return false;
        }

        return true;
    }
}
