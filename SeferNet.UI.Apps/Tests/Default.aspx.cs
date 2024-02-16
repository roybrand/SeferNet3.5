using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Tests_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {       
        if (!Page.IsPostBack)
        { 
        } 
        this.txtHandicappedFacilitiesCodes.Text = Request[this.txtHandicappedFacilitiesCodes.UniqueID];      
    }            



    protected override void OnInit(EventArgs e)
    {       
        //DataTable dt2 = CreateMorePhone();
        //PhonesGridUCItem1.SourcePhones = dt2;       
        //PhonesGridUCItem1.PhoneType = 2;
        //PhonesGridUCItem1.LabelText = "טלפון";
        base.OnInit(e);
    }


    //private  DataTable CreateOnePhone()
    //{               
    //   DataTable dt = CreateDataTable();        
    //   DataRow dr =dt.NewRow();
    //   dr["prePrefix"] = "1";
    //    dr["prefix"] = "700";
    //    dr["phone"] = "9067188";
    //    dr["employeeID"] = "123";
    //    dr["deptCode"] = "888";
    //    dr["phoneID"] = "986";
    //    dr["phoneOrder"] = "1";
    //    dr["phoneType"] = "2";

    //    dt.Rows.Add(dr);
    //    return dt;
    //}

    private DataTable CreateMorePhone()
    {
        DataTable dt = CreateDataTable();
        DataRow dr = dt.NewRow(); 
        dr["prePrefix"] = "1";
        dr["prefix"] = "52";
        dr["phone"] = "9367236";
        dr["phoneID"] = "986";
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
        dr["phoneOrder"] = "1";
        //dr["phoneType"] = "2";
        dr["extension"] = "2";
        dt.Rows.Add(dr);

        dr = null;
        dr = dt.NewRow();
        dr["prePrefix"] = "1";
        dr["prefix"] = "700";
        dr["phone"] = "8888888";
        dr["phoneID"] = "986";
        dr["phoneOrder"] = "1";
        //dr["phoneType"] = "2";
        dr["extension"] = "2";
        dt.Rows.Add(dr);

       
        dr = null;
        dr = dt.NewRow(); 

        dr["prePrefix"] = "1";
        dr["prefix"] = "700";
        dr["phone"] = "9367236";
        dr["phoneID"] = "986";
        dr["phoneOrder"] = "1";
        //dr["phoneType"] = "2";
        dr["extension"] = "2";
        dt.Rows.Add(dr);
        return dt;
    }


    private DataTable CreateDataTable( )
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

        column = new DataColumn("phoneType");
        dt.Columns.Add(column);

        column = new DataColumn("extension");
        dt.Columns.Add(column);
        
        return dt;
    }


    protected void Button1_Click1(object sender, EventArgs e)
    {
        DataTable dt = PhonesGridUCItem1.SourcePhones;
        if (dt != null)
        {
            GridView1.DataSource = dt;
            GridView1.DataBind();
        }

    }
}
