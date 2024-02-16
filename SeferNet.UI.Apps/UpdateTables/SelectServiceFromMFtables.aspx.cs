using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Data;

public partial class UpdateTables_SelectServiceFromMFtables : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        acSearchService.ContextKey = lstChkMFTables.SelectedValue;
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string tableNum = string.Empty;
        string prefixText = null;


        foreach (ListItem item in lstChkMFTables.Items)
        {
            if (item.Selected)
            {
                tableNum += item.Value;
            }
        }

        if (!string.IsNullOrEmpty(txtSearchOldDesc.Text))
            prefixText = txtSearchOldDesc.Text;

        ManageItemsBO bo = new ManageItemsBO();
        DataSet ds = bo.GetServicesFromMFTables(prefixText, tableNum);

        gvResults.DataSource = ds;
        gvResults.DataBind();
        pnlResults.Visible = true;
    }


    protected void gvResults_DataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView currRow = e.Row.DataItem as DataRowView;
            LinkButton lnkSelect = e.Row.FindControl("lnkSelect") as LinkButton;
            Label lblSelected = e.Row.FindControl("lblSelected") as Label;
            
                        

            if (Convert.ToBoolean(currRow["Selected"]) == true)
            {
                lnkSelect.Visible = false;
                lblSelected.Text = "כן";
            }
            else
            {
                e.Row.ForeColor = System.Drawing.Color.Blue;
                lnkSelect.Attributes.Add("onclick", "SelectService(" + currRow["ServiceCode"] + ",'" + currRow["Description"] + "');");
                lblSelected.Text = "לא";
            }

        }
    }
}