using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Tests_DefaultPhones : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            DataTable dt = CreateMorePhone();        
            gvPhones11.SourcePhones = dt;
            gvPhones11.EnableAdding = true;
           
            gvPhones22.EnableDeleting = true;
            gvPhones22.SourcePhones = dt;


        }
    }


    private DataTable CreateMorePhone()
    {
        DataTable dt = CreateDataTable();
        DataRow dr = dt.NewRow();
        dr["prePrefix"] = "1";
        dr["prefix"] = "700";
        dr["phone"] = "7070700";
        dr["phoneID"] = "985";
        dr["phoneOrder"] = "1";
        //dr["phoneType"] = "2";
        dr["extension"] = "2";
        dt.Rows.Add(dr);

        dr = null;
        dr = dt.NewRow();
        dr["prePrefix"] = "1";
        dr["prefix"] = "53";
        dr["phone"] = "9367236";
        dr["phoneID"] = "986";
        dr["phoneOrder"] = "2";
        //dr["phoneType"] = "2";
        dr["extension"] = "2";
        dt.Rows.Add(dr);

        dr = null;
        dr = dt.NewRow();
        dr["prePrefix"] = "1";
        dr["prefix"] = "700";
        dr["phone"] = "8888888";
        dr["phoneID"] = "987";
        dr["phoneOrder"] = "3";
        //dr["phoneType"] = "2";
        dr["extension"] = "2";
        dt.Rows.Add(dr);


        dr = null;
        dr = dt.NewRow();

        dr["prePrefix"] = "1";
        dr["prefix"] = "700";
        dr["phone"] = "9367236";
        dr["phoneID"] = "988";
        dr["phoneOrder"] = "4";
        //dr["phoneType"] = "2";
        dr["extension"] = "2";
        dt.Rows.Add(dr);
        return dt;
    }


    private DataTable CreateDataTable()
    {
        DataTable dt = new DataTable();
        DataColumn column = null;
        DataRow dr = dt.NewRow();

        column = new DataColumn("prePrefix");
        dt.Columns.Add(column);
        column = new DataColumn("prefix");
        dt.Columns.Add(column);
        column = new DataColumn("phone");
        dt.Columns.Add(column);
        column = new DataColumn("phoneID");
        dt.Columns.Add(column);

        column = new DataColumn("phoneOrder");
        dt.Columns.Add(column);

        //column = new DataColumn("phoneType");
        //dt.Columns.Add(column);

        column = new DataColumn("extension");
        dt.Columns.Add(column);

        return dt;
    }


    protected void btnSave11_Click(object sender, EventArgs e)
    {
        DataTable dt = gvPhones11.ReturnData();
        if (dt != null)
        {
            GridView11.DataSource = dt;
            GridView11.DataBind();
        }

        DataTable dt22 = gvPhones22.ReturnData();
        if (dt22 != null)
        {
            GridView22.DataSource = dt22;
            GridView22.DataBind();
        }
    }



    protected void Button1_Click(object sender, EventArgs e)
    {

    }
}
