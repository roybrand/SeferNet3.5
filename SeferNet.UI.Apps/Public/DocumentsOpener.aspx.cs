using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Public_DocumentsOpener : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //string fileName = ConfigHelper.GetEventFilesStoragePath() + lnk.CommandArgument;
        string fileName = ConfigHelper.GetEventFilesStoragePath() + Request.QueryString["file"].ToString();

        Page.ClientScript.RegisterStartupScript(typeof(string), "Close", "Close();", true);
        string fileExtension = Request.QueryString["file"].ToString().Substring(Request.QueryString["file"].ToString().LastIndexOf('.') + 1);
        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition", "inline;filename=" + Request.QueryString["file"].ToString());

        switch (fileExtension)
        {
            case "docx":
                Response.ContentType = "application/ms-word";
                break;
            case "doc":
                Response.ContentType = "application/ms-word";
                break;
            case "xls":
                Response.ContentType = "application/ms-excel";
                break;
            case "xlsx":
                Response.ContentType = "application/ms-excel";
                break;
            case "pdf":
                Response.ContentType = "application/pdf";
                break;

        }
        //Response.ContentType = "application/ms-word";
        //Response.ContentType = "application/pdf";

        Response.WriteFile(fileName);
        Response.Flush();
        Response.End();

    }
}