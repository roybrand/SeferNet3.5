using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

public partial class Tests_Test : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
       
           
            ListItem item = new ListItem();
            for (int i = 0; i < 7; i++)
            {
                item.Text = i.ToString();
                item.Value = i.ToString(); 
                //chkBx.Items.Add(item); 
            }


            for (int i = 0; i < 7; i++)
            {
                HtmlTableRow row = new HtmlTableRow();
                for (int j = 0; j < 3; j++)
                {
                    HtmlTableCell cell = new HtmlTableCell();
                    Label lbl = new Label();
                    lbl.Text = j.ToString();
                    cell.Controls.Add(lbl);
                    row.Cells.Add(cell);
                      
                }

                //tblHtml.Rows.Add(row); 
            }


            if (!Page.IsPostBack)
            {
                for (int i = 0; i < 10; i++)
                {
                    TableRow row = new TableRow();
                    for (int j = 0; j < 5; j++)
                    {
                        TableCell cell = new TableCell();
                        CheckBox bx = new CheckBox();
                        bx.ID = "ch_" + i.ToString() + "_" + j.ToString();
                        bx.Text = i.ToString() + "_" + j.ToString();
                        cell.Controls.Add(bx);
                        row.Cells.Add(cell);

                    }

                    //tblAsp.Rows.Add(row);
                }
                
            }
        
    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        //string t = chkBx.Items.Count.ToString();
        //string d = tblHtml.Rows.Count.ToString();
        //string y = tblAsp.Rows.Count.ToString();

        //CheckBox bx = tblAsp.Rows[0].Cells[0].FindControl("ch_0_0") as CheckBox;
        //CheckBox bx1 = tblAsp.Rows[0].Cells[0].FindControl("ch_1_1") as CheckBox;

    }
}
