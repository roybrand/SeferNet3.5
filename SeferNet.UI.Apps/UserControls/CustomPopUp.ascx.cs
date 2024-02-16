using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_CustomPopUp : System.Web.UI.UserControl
{
    public string mainDirectory = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        mainDirectory = Request.ApplicationPath;
    }
}