using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using System.Data;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.Globals;
using System.Data;

public partial class Admin_UpdateProfessionsForInternet : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!this.IsPostBack)
        {
            this.BindGrid();
        }

        ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "SetDivScrollPosition", "SetDivScrollPosition();", true);
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        this.ProfessionCode.SetSortDirection(SortDirection.Ascending);
        DataTable dt = this.GetDataFromDB();

        this.gvProfessionsResults.EditIndex = -1;
        this.BindGrid();
    }

    protected void gvProfessionsResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView rowDetails = (DataRowView)e.Row.DataItem;

            Label lblShowProfessionInInternet = (Label)e.Row.FindControl("lblShowProfessionInInternet");

            byte showProfessionInInternet = (byte)rowDetails["ShowProfessionInInternet"];

            if (lblShowProfessionInInternet != null)
            {

                if (showProfessionInInternet == 0)
                    lblShowProfessionInInternet.Text = "לא";
                else if (showProfessionInInternet == 1)
                    lblShowProfessionInInternet.Text = "כן";
            }

            CheckBox cbShowProfessionInInternet = (CheckBox)e.Row.FindControl("cbShowProfessionInInternet");

            if (cbShowProfessionInInternet != null)
            {
                if (showProfessionInInternet == 0)
                    cbShowProfessionInInternet.Checked = false;
                else if (showProfessionInInternet == 1)
                    cbShowProfessionInInternet.Checked = true;
            }
        }
    }

    private DataTable GetDataFromDB()
    {
        int? professionCode = null;

        if (!string.IsNullOrEmpty(this.txtProfessionCode.Text))
        {
            professionCode = Convert.ToInt32(this.txtProfessionCode.Text);
        }

        string ProfessionDescription = (this.txtProfessionDescription.Text == string.Empty) ? null : this.txtProfessionDescription.Text;

        DataSet ds = Facade.getFacadeObject().GetProfessionsForInternet( professionCode, ProfessionDescription );
        
        if (ds != null)
        {
            if (this.ViewState["ProfessionsDT"] != null)
            {
                this.ViewState.Remove("ProfessionsDT");
            }

            this.ViewState.Add("ProfessionsDT", ds.Tables[0]);
            return ds.Tables[0];
        }

        return null;
    }

    private void BindGrid()
    {
        DataTable dt;
        if (this.ViewState["ProfessionsDT"] != null)
        {
            dt = this.ViewState["ProfessionsDT"] as DataTable;
        }
        else
        {
            dt = this.GetDataFromDB();
        }
        
        if (dt != null)
        {
            DataView dv = dt.DefaultView;
            if (this.ViewState["sortExpresion"] != null)
            {
                dv.Sort = this.ViewState["sortExpresion"].ToString();
            }

            this.gvProfessionsResults.DataSource = dv;
            this.gvProfessionsResults.DataBind();
            this.divResults.Visible = true;
        }
    }

    protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        if (row != null)
        {
            this.gvProfessionsResults.EditIndex = row.RowIndex;
            this.BindGrid();
        }
    }
    
    protected void imgCancel_Click(object sender, ImageClickEventArgs e)
    {
        this.gvProfessionsResults.EditIndex = -1;
        this.BindGrid();
    }

    protected void gvProfessionsResults_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int rowInd = e.RowIndex;

        Label lblProfessionCode = this.gvProfessionsResults.Rows[rowInd].FindControl("lblProfessionCode") as Label;

        int ProfessionCode = Convert.ToInt32(lblProfessionCode.Text);

        TextBox tb = this.gvProfessionsResults.Rows[rowInd].FindControl("txtProfessionDescriptionForInternet") as TextBox;
        string professionDescriptionForInternet = (tb == null ? "" : tb.Text);

        TextBox tbProfessionExtraData = this.gvProfessionsResults.Rows[rowInd].FindControl("txtProfessionExtraData") as TextBox;
        string professionExtraData = tbProfessionExtraData.Text;

        CheckBox cbShowProfessionInInternet = this.gvProfessionsResults.Rows[rowInd].FindControl("cbShowProfessionInInternet") as CheckBox;

        byte showProfessionInInternet = 0;
        if (cbShowProfessionInInternet.Checked)
            showProfessionInInternet = 1;
        else
            showProfessionInInternet = 0;

        Facade.getFacadeObject().UpdateProfessionForInternet(ProfessionCode, professionDescriptionForInternet, professionExtraData, showProfessionInInternet);

        this.gvProfessionsResults.EditIndex = -1;
        this.GetDataFromDB();
        this.BindGrid();
    }

    protected void btnSort_Click(object sender, EventArgs e)
    {
        SortableColumnHeader columnToSortBy = sender as SortableColumnHeader;
        string CurrentSort = columnToSortBy.ColumnIdentifier.ToString();
        DataView dvCurrentResults = null;
        SortDirection newSortDirection = (SortDirection)columnToSortBy.CurrentSortDirection;
        string direction = "asc";
        
        if (newSortDirection.ToString() == "Descending")
        {
            direction = "desc";
        }

        string sort = String.Empty;
        sort = CurrentSort + " " + direction;
        foreach (Control ctrl in this.divHeaders.Controls)
        {
            if (ctrl is SortableColumnHeader && ctrl != columnToSortBy)
            {
                ((SortableColumnHeader)ctrl).ResetSort();
            }
        }

        this.ViewState["sortExpresion"] = sort;
        dvCurrentResults = ((DataTable)ViewState["ProfessionsDT"]).DefaultView;
        dvCurrentResults.Sort = sort;

        this.gvProfessionsResults.DataSource = dvCurrentResults;
        this.gvProfessionsResults.DataBind();
    }
}