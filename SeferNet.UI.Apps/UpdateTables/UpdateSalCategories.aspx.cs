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

public partial class Admin_UpdateSalCategories : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

        if (this.IsPostBack && this.hdNewSalCategoryDescription.Value != "")
        {
            this.AddNewSalCategory();
        }
        else
        {
            if (!this.IsPostBack)
            {
                this.BindGrid();
            }
        }
    }

    protected void AddNewSalCategory()
    {
        string salCategoryDescription = hdNewSalCategoryDescription.Value;
        DateTime dtAdd_Date = DateTime.Now;

        Facade.getFacadeObject().AddSalCategory(salCategoryDescription, dtAdd_Date);

        this.txtNewSalCategoryDescription.Text = string.Empty;
        this.hdNewSalCategoryDescription.Value = "";

        this.btnSearch_Click(null, null);
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        this.ServiceCode.SetSortDirection(SortDirection.Ascending);
        DataTable dt = this.GetDataFromDB();

        this.gvSalCategoriesResults.EditIndex = -1;
        this.BindGrid();
    }

    private DataTable GetDataFromDB()
    {
        int? salCategoryID = null;

        if (!string.IsNullOrEmpty(this.txtSalCategoryID.Text))
        {
            salCategoryID = Convert.ToInt32(this.txtSalCategoryID.Text);
        }

        string salCategoryDescription = (this.txtSalCategoryDescription.Text == string.Empty) ? null : this.txtSalCategoryDescription.Text;

        DataSet ds = Facade.getFacadeObject().GetSalCategories( salCategoryID, salCategoryDescription );
        
        if (ds != null)
        {
            if (this.ViewState["SalCategoriesDT"] != null)
            {
                this.ViewState.Remove("SalCategoriesDT");
            }

            this.ViewState.Add("SalCategoriesDT", ds.Tables[0]);
            return ds.Tables[0];
        }

        return null;
    }

    private void BindGrid()
    {
        DataTable dt;
        if (this.ViewState["SalCategoriesDT"] != null)
        {
            dt = this.ViewState["SalCategoriesDT"] as DataTable;
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

            this.gvSalCategoriesResults.DataSource = dv;
            this.gvSalCategoriesResults.DataBind();
            this.divResults.Visible = true;
        }
    }

    protected void gvSalCategoriesResults_OnRowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int salCategoryID = Convert.ToInt32(e.Values[0]);
        Facade.getFacadeObject().DeleteSalCategory(salCategoryID);

        // rebind grid
        this.GetDataFromDB();
        this.BindGrid();
    }

    protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        if (row != null)
        {
            this.gvSalCategoriesResults.EditIndex = row.RowIndex;
            this.BindGrid();
        }
    }
    
    protected void imgCancel_Click(object sender, ImageClickEventArgs e)
    {
        this.gvSalCategoriesResults.EditIndex = -1;
        this.BindGrid();
    }

    protected void gvSalCategoriesResults_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int rowInd = e.RowIndex;

        Label lblSalCategoryID = this.gvSalCategoriesResults.Rows[rowInd].FindControl("lblSalCategoryID") as Label;

        int salCategoryID = Convert.ToInt32(lblSalCategoryID.Text);

        TextBox tb = this.gvSalCategoriesResults.Rows[rowInd].FindControl("txtSalCategoryDescription") as TextBox;
        string salCategoryDescription = (tb == null ? "" : tb.Text);

        Facade.getFacadeObject().UpdateSalCategory(salCategoryID, salCategoryDescription);

        this.gvSalCategoriesResults.EditIndex = -1;
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
        dvCurrentResults = ((DataTable)ViewState["SalCategoriesDT"]).DefaultView;
        dvCurrentResults.Sort = sort;

        this.gvSalCategoriesResults.DataSource = dvCurrentResults;
        this.gvSalCategoriesResults.DataBind();
    }
}