using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ShowHelp : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string fileName = Request.QueryString["file"].ToString();
        string src = string.Empty;

        string serverName = Request.ServerVariables["SERVER_NAME"].ToString();
        string[] segmentsURL = Request.Url.Segments;

        if (fileName != null)
        {
            src = "http://" + serverName + segmentsURL[0] + segmentsURL[1] + segmentsURL[2] + fileName + ".pdf";
            frmWord.Attributes.Add("src", src);
        }

    }
}
