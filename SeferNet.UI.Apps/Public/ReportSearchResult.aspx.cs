using SeferNet.FacadeLayer;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SeferNet.UI.Apps.Public
{
    public partial class ReportSearchResult_aspx : System.Web.UI.Page
    {
        Facade applicFacade;
        DataSet dsSearchResult;

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnGenerateExcel_Click1(object sender, EventArgs e)
        {
            applicFacade = Facade.getFacadeObject();
            dsSearchResult = applicFacade.getCitiesByNameAndDistrict(string.Empty, "160000");

            GridView GridView1 = new GridView();
            GridView1.AllowPaging = false;
            GridView1.DataSource = dsSearchResult.Tables[0];
            GridView1.DataBind();
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=DataTable.xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";
            StringWriter sw = new StringWriter();
            HtmlTextWriter hw = new HtmlTextWriter(sw);
            for (int i = 0; i < GridView1.Rows.Count; i++)
            {
                GridView1.Rows[i].Attributes.Add("class", "textmode");
            }
            GridView1.RenderControl(hw);
            string style = @"<style> .textmode { mso-number-format:\@; } </style>";
            Response.Write(style);
            Response.Output.Write(sw.ToString());
            Response.Flush();
            Response.End();

        }

        protected void btnGenerateExcel_Click(object sender, EventArgs e)
        {
            MemoryStream ms = new MemoryStream();

            applicFacade = Facade.getFacadeObject();
            dsSearchResult = applicFacade.getCitiesByNameAndDistrict(string.Empty, "160000");

            GridView GridView1 = new GridView();
            GridView1.AllowPaging = false;
            GridView1.DataSource = dsSearchResult.Tables[0];
            GridView1.DataBind();
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=DataTable.xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";
            StringWriter sw = new StringWriter();
            HtmlTextWriter hw = new HtmlTextWriter(sw);
            for (int i = 0; i < GridView1.Rows.Count; i++)
            {
                GridView1.Rows[i].Attributes.Add("class", "textmode");
            }
            GridView1.RenderControl(hw);
            string style = @"<style> .textmode { mso-number-format:\@; } </style>";
            Response.Write(style);
            Response.Output.Write(sw.ToString());
            Response.Flush();
            //Response.End();

        }
    }
}