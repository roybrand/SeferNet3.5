using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.FacadeLayer;
using CacheAction_ServerNotificationManager;

public partial class UpdateDays : System.Web.UI.Page
{
    

    private bool editRow = false;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            fillGrid();
        }
        

         
    }

    private void fillGrid()
    {
        Facade fc = Facade.getFacadeObject();

        DataSet dsDays = fc.GetReceptionDays(false);
        grDays.DataSource = dsDays;
        grDays.DataBind();
    }
    protected void grDays_RowEditing(object sender, GridViewEditEventArgs e)
    {
        
        grDays.EditIndex = e.NewEditIndex;
        fillGrid();
    }
    protected void grDays_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        Facade fc = Facade.getFacadeObject();
        int receptionDayCode;
        int display;
        int useInSearch;
        GridViewRow row = grDays.Rows[e.RowIndex];

        receptionDayCode = int.Parse(((Label)row.Cells[0].FindControl("lblCode")).Text);
        display = ((CheckBox)row.Cells[3].FindControl("cbDisplay")).Checked ? 1 : 0;
        useInSearch = ((CheckBox)row.Cells[2].FindControl("cbSearch")).Checked ? 1 : 0;

        fc.UpdateReceptionDays(receptionDayCode, display, useInSearch);
        grDays.EditIndex = -1;
        fillGrid();

        ServersNotifierService.RefreshServerInfoList();
        ServersNotifierService.RefreshAllCacheItems();
    }
    protected void grDays_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        CheckBox cbDisplay = null;
        CheckBox cbSearch = null;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            cbDisplay = (CheckBox)e.Row.Cells[3].FindControl("cbDisplay");
            Label lblDisplay = (Label)e.Row.Cells[3].FindControl("lblDisplay");

            cbDisplay.Checked = (lblDisplay.Text == "1" ? true : false);
            lblDisplay.Visible = false;

            cbSearch = (CheckBox)e.Row.Cells[2].FindControl("cbSearch");
            Label lblSearch = (Label)e.Row.Cells[2].FindControl("lblSearch");
            cbSearch.Checked = (lblSearch.Text == "1" ? true : false);
            lblSearch.Visible = false;
        }

        if (editRow && e.Row.RowIndex == grDays.EditIndex)
        {
            cbDisplay.Enabled = true;
            cbSearch.Enabled = true;
            editRow = false;
        }
        
    }
    protected void grDays_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        switch (e.CommandName)
        { 
            case "Edit":
                String strArg = e.CommandArgument.ToString();
                editRow = true;
                break;
        }
        
    }
    protected void grDays_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        grDays.EditIndex = -1;
        fillGrid();
    }
}