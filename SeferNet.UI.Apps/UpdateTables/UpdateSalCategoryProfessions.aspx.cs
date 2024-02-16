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

public partial class Admin_UpdateSalCategoryProfessions : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack && this.hdNewSalCategoryID.Value != "" && this.hdNewProfessionCode.Value != "")
        {
            this.AddNewSalCategoryToProfession();
        }
        else
        {
            if (!this.IsPostBack)
            {
                this.BindDefaultView();
                this.BindGrid();
            }
        }
        ScriptManager.RegisterStartupScript(this, this.GetType(), "SetScrollPosition", "SetScrollPosition();", true);
    }

    private void BindDefaultView()
    {
        DataSet dsSalCategories = Facade.getFacadeObject().GetSalCategories(null , null);

        this.ddlSalCategory.DataSource = dsSalCategories;
        this.ddlSalCategory.DataBind();
        this.ddlSalCategory.Items.Insert(0, new ListItem("-- בחר --", ""));

        DataSet dsProfessions = Facade.getFacadeObject().GetProfessionsForSalServices(string.Empty);
        DataSet dsProfessions_UnCategorized = Facade.getFacadeObject().GetProfessionsForSalServices_UnCategorized(null, null);
        
        this.ddlProfession.DataSource = dsProfessions;
        this.ddlProfession.DataBind();
        this.ddlProfession.Items.Insert(0, new ListItem("-- בחר --", ""));

        this.BindAddNewControlsValues();
    }

    private void BindAddNewControlsValues()
    {
        //this.ddlNewSalCategory.ClearSelection();

        DataSet dsSalCategories = Facade.getFacadeObject().GetSalCategories(null, null);

        this.ddlNewSalCategory.DataSource = dsSalCategories;
        this.ddlNewSalCategory.DataBind();
        this.ddlNewSalCategory.Items.Insert(0, new ListItem("-- בחר --", ""));
        this.ddlNewSalCategory.SelectedIndex = 0;

        //this.ddlNewProfession.ClearSelection();

        DataSet dsProfessions_UnCategorized = Facade.getFacadeObject().GetProfessionsForSalServices_UnCategorized(null, null);

        this.ddlNewProfession.DataSource = dsProfessions_UnCategorized;
        this.ddlNewProfession.DataBind();
        this.ddlNewProfession.Items.Insert(0, new ListItem("-- בחר --", ""));
        this.ddlNewProfession.SelectedIndex = 0;
    }

    protected void AddNewSalCategoryToProfession()
    {
        int salCategoryID = int.Parse( this.hdNewSalCategoryID.Value);
        int professionCode = int.Parse(this.hdNewProfessionCode.Value);
        DateTime dtAdd_Date = DateTime.Now;

        UserManager userManager = new UserManager();
        UserInfo currentUserInfo = userManager.GetUserInfoFromSession();

        Facade.getFacadeObject().AddSalProfessionToCategory(professionCode, salCategoryID, dtAdd_Date, currentUserInfo.UserAD);

        this.hdNewSalCategoryID.Value = "";
        this.hdNewProfessionCode.Value = string.Empty;

        this.btnSearch_Click(null, null);

        this.BindAddNewControlsValues();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        this.SalCategoryDescription.SetSortDirection(SortDirection.Ascending);
        DataTable dt = this.GetDataFromDB();

        this.gvSalProfessionToCategoriesResults.EditIndex = -1;
        this.BindGrid();
    }

    private DataTable GetDataFromDB()
    {
        int? salCategoryID = null;

        if (!string.IsNullOrEmpty(this.ddlSalCategory.SelectedValue))
        {
            salCategoryID = Convert.ToInt32(this.ddlSalCategory.SelectedValue);
        }

        int? professionCode = null;
        if (!string.IsNullOrEmpty(this.ddlProfession.SelectedValue))
        {
            professionCode = Convert.ToInt32(this.ddlProfession.SelectedValue);
        }

        DataSet ds = Facade.getFacadeObject().GetSalProfessionToCategories(salCategoryID, professionCode);

        if (ds != null)
        {
            if (this.ViewState["SalProfessionToCategoriesDT"] != null)
            {
                this.ViewState.Remove("SalProfessionToCategoriesDT");
            }

            this.ViewState.Add("SalProfessionToCategoriesDT", ds.Tables[0]);
            return ds.Tables[0];
        }

        return null;
    }

    private void BindGrid()
    {
        DataTable dt;
        if (this.ViewState["SalProfessionToCategoriesDT"] != null)
        {
            dt = this.ViewState["SalProfessionToCategoriesDT"] as DataTable;
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

            this.gvSalProfessionToCategoriesResults.DataSource = dv;
            this.gvSalProfessionToCategoriesResults.DataBind();
            this.divResults.Visible = true;
        }
    }

    protected void gvSalProfessionToCategoriesResults_OnRowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int SalProfessionToCategoryID = Convert.ToInt32(e.Values[0]);

        Facade.getFacadeObject().DeleteSalProfessionToCategory(SalProfessionToCategoryID);

        // rebind grid
        this.GetDataFromDB();
        this.BindGrid();

        this.BindAddNewControlsValues();
    }

    protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        if (row != null)
        {
            this.gvSalProfessionToCategoriesResults.EditIndex = row.RowIndex;
            this.BindGrid();
        }

        this.BindAddNewControlsValues();
    }

    protected void imgCancel_Click(object sender, ImageClickEventArgs e)
    {
        this.gvSalProfessionToCategoriesResults.EditIndex = -1;
        this.BindGrid();
    }

    protected void gvSalProfessionToCategoriesResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        GridViewRow row = e.Row;

        if (row.FindControl("ddlSalCategory") != null)
        {
            // get the dropdowns & set the datasource for them and thir selected value:
            DataSet dsSalCategories = Facade.getFacadeObject().GetSalCategories(null, null);

            DropDownList ddlSalCategory = (DropDownList)row.FindControl("ddlSalCategory");
            ddlSalCategory.DataSource = dsSalCategories;
            ddlSalCategory.DataBind();
            ddlSalCategory.Items.Insert(0, new ListItem("-- בחר --", ""));

            int salCategoryId = 0;
            Label lblSalCategoryId = (Label)row.FindControl("lblSalCategoryId");
            salCategoryId = int.Parse(lblSalCategoryId.Text);
            ddlSalCategory.SelectedValue = salCategoryId.ToString();
            if (string.IsNullOrEmpty(ddlSalCategory.SelectedValue))
                ddlSalCategory.SelectedValue = salCategoryId.ToString();

            DataSet dsProfessions = Facade.getFacadeObject().GetProfessionsForSalServices(string.Empty);

            DropDownList ddlProfession = (DropDownList)row.FindControl("ddlProfession");

            ddlProfession.DataSource = dsProfessions;
            ddlProfession.DataBind();
            ddlProfession.Items.Insert(0, new ListItem("-- בחר --", ""));

            int professionCode = 0;
            Label lblProfessionCode = (Label)row.FindControl("lblProfessionCode");
            professionCode = int.Parse(lblProfessionCode.Text);
            if (string.IsNullOrEmpty(ddlProfession.SelectedValue))
                ddlProfession.SelectedValue = professionCode.ToString();

        }
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
        dvCurrentResults = ((DataTable)ViewState["SalProfessionToCategoriesDT"]).DefaultView;
        dvCurrentResults.Sort = sort;

        this.gvSalProfessionToCategoriesResults.DataSource = dvCurrentResults;
        this.gvSalProfessionToCategoriesResults.DataBind();
    }

    protected void ddlNewSalCategory_SelectedIndexChanged(object sender, EventArgs e)
    {
        int? salCategoryId = null;
        if(ddlNewSalCategory.SelectedIndex > 0)
            salCategoryId = Convert.ToInt32(ddlNewSalCategory.SelectedValue);

        DataSet dsProfessions_UnCategorized = Facade.getFacadeObject().GetProfessionsForSalServices_UnCategorized(salCategoryId, null);
        this.ddlNewProfession.Items.Clear();
        this.ddlNewProfession.DataSource = dsProfessions_UnCategorized;
        this.ddlNewProfession.DataBind();
        this.ddlNewProfession.Items.Insert(0, new ListItem("-- בחר --", ""));
        this.ddlNewProfession.SelectedIndex = 0;

        ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowNewSalProfessionToCategory", "ShowNewSalProfessionToCategory();", true);
    }

    protected void btnAddNew_Click(object sender, EventArgs e)
    {
        BindAddNewControlsValues();
        ddlNewSalCategory.Enabled = true;
        btnUpdateSalProfessionToCategory.Visible = false;
        btnAddSalProfessionToCategory.Visible = true;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowNewSalProfessionToCategory", "ShowNewSalProfessionToCategory();", true);
    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        ImageButton btnUpdate = sender as ImageButton;
        int salProfessionToCategoryID = Convert.ToInt32(btnUpdate.Attributes["SalProfessionToCategoryID"]);
        int professionCode = Convert.ToInt32(btnUpdate.Attributes["ProfessionCode"]);
        int salCategoryID = Convert.ToInt32(btnUpdate.Attributes["SalCategoryID"]);

        ddlNewSalCategory.SelectedValue = salCategoryID.ToString();
        ddlNewSalCategory.Enabled = false;

        hdSalProfessionToCategoryID.Value = salProfessionToCategoryID.ToString();

        DataSet dsProfessions_UnCategorized = Facade.getFacadeObject().GetProfessionsForSalServices_UnCategorized(salCategoryID, professionCode);

        this.ddlNewProfession.DataSource = dsProfessions_UnCategorized;
        this.ddlNewProfession.DataBind();
        this.ddlNewProfession.SelectedValue = professionCode.ToString();

        btnUpdateSalProfessionToCategory.Visible = true;
        btnAddSalProfessionToCategory.Visible = false;

        ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowNewSalProfessionToCategory", "ShowNewSalProfessionToCategory();", true);
    }

    protected void btnUpdateSalProfessionToCategory_Click(object sender, EventArgs e)
    {
        int SalProfessionToCategoryID = int.Parse(hdSalProfessionToCategoryID.Value);

        int professionCode = Convert.ToInt32(ddlNewProfession.SelectedValue);
        int salCategoryID = Convert.ToInt32(ddlNewSalCategory.SelectedValue);

        UserManager userManager = new UserManager();
        UserInfo currentUserInfo = userManager.GetUserInfoFromSession();

        Facade.getFacadeObject().UpdateSalProfessionToCategory(SalProfessionToCategoryID, salCategoryID, professionCode, currentUserInfo.UserAD);

        this.GetDataFromDB();
        this.BindGrid();
    }
}