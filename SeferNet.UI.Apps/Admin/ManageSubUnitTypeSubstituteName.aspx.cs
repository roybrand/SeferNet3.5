using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Globalization;

using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.BusinessObject;
using System.Data.SqlClient;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.DataLayer;
using SeferNet.FacadeLayer;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using SeferNet.Globals;

public partial class ManageSubUnitTypeSubstituteName : AdminBasePage
{
    private Facade applicFacade;
	private UserManager userManager;	

    private int currentUnitTypeCode;
    private System.Drawing.Color currentColor;
	#region -------------- Properties -------------------

	private DataTable DataSubUnitTypesWithSubstituteNames
	{
		get
		{
            if (ViewState["SubUnitTypesWithSubstituteNames"] != null)
			{
                return (DataTable)ViewState["SubUnitTypesWithSubstituteNames"];
			}
			else
			{
				return null;
			}
		}
		set
		{
            ViewState["SubUnitTypesWithSubstituteNames"] = value;
		}
	}

	public string CurrentFilter
	{
		get
		{
			return string.Empty;
		}
	}

	public string CurrentSort
	{
		get
		{
            if (ViewState["CurrentSubstituteNamesSort"] != null)
			{
                return ViewState["CurrentSubstituteNamesSort"].ToString();
			}
			else
			{
				return null;
			}
		}
		set
		{
            ViewState["CurrentSubstituteNamesSort"] = value;
		}
	}

	#endregion -------------- Properties -------------------

	protected void Page_Load(object sender, EventArgs e)
	{
		this.userManager = new UserManager();
		this.applicFacade = Facade.getFacadeObject();
		

        if (!this.IsPostBack)
        {
            this.CurrentSort = this.hdrRemarkID.ColumnIdentifier.ToString(); // default sort field

            this.BindGrid();

        }
        else
        {
            ScriptManager.RegisterClientScriptBlock(UpdatePanel1, typeof(UpdatePanel), "SetDivScrollPosition", "SetDivScrollPosition()", true);
        }
	}

	#region  --------------Binding--------------

	private void BindGrid()
	{
        DataSet ds = this.applicFacade.getSubUnitTypesWithSubstituteNames();

		if (ds == null || ds.Tables.Count == 0)
			return;

        DataTable tblSubUnitTypesWithSubstituteNames = ds.Tables[0];

        if (tblSubUnitTypesWithSubstituteNames.Rows.Count == 0)
		{
			this.trNoDataFound.Style.Add("display", "inline");
		}
		else
		{
			this.trNoDataFound.Style.Add("display", "none");
            this.DataSubUnitTypesWithSubstituteNames = tblSubUnitTypesWithSubstituteNames;
			this.RefreshGrid();
		}	
		
	}

	private void RefreshGrid()
	{
        DataView dv = new DataView(this.DataSubUnitTypesWithSubstituteNames, "",
							this.CurrentSort, DataViewRowState.CurrentRows);
        this.gvSubUnitTypeSubstituteName.DataSource = dv;
        this.gvSubUnitTypeSubstituteName.DataBind();
	}

	#endregion -------------- Binding --------------------

	#region -------------- Events Handlers ----------------
	
	protected void btnSort_Click(object sender, EventArgs e)
	{
		SortableColumnHeader currentHeader = sender as SortableColumnHeader;

        this.ResetGridViewSortableHeaders(this.gvSubUnitTypeSubstituteName, currentHeader);

		string sort = currentHeader.ColumnIdentifier.ToString() + " " + currentHeader.GetStringValueOfCurrentSort();
		this.CurrentSort = sort;

		this.GridClearSelection();
		this.RefreshGrid();
	}

    protected void gvSubUnitTypeSubstituteName_RowDataBound(object sender, GridViewRowEventArgs e)
	{
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            if (Convert.ToInt32(dvRowView["UnitTypeCode"]) == currentUnitTypeCode)
            {
                e.Row.BackColor = currentColor;
                e.Row.FindControl("lblUnitTypeCode").Visible = false;
                e.Row.FindControl("lblUnitTypeName").Visible = false;
            }
            else
            {
                if (currentColor == System.Drawing.Color.White)
                    currentColor = System.Drawing.Color.FromArgb(230, 230, 230);
                else
                    currentColor = System.Drawing.Color.White;

                e.Row.BackColor = currentColor;

                for(int i=0; i < e.Row.Controls.Count; i++)
                {
                    DataControlFieldCell td = (DataControlFieldCell)e.Row.Controls[i];
                    td.Style.Add("border-top", "solid 1px gray");
                }

               currentUnitTypeCode = Convert.ToInt32(dvRowView["UnitTypeCode"]);
            }

            ImageButton btnDelete = e.Row.FindControl("btnDelete") as ImageButton;
            if(dvRowView["SubstituteName"].ToString() == string.Empty)
                btnDelete.Style.Add("display", "none");

            ImageButton btnEdit = e.Row.FindControl("btnEdit") as ImageButton;
            if (dvRowView["SubUnitTypeCode"].ToString() == string.Empty)
                btnEdit.Style.Add("display", "none");

            if (e.Row.RowIndex == gvSubUnitTypeSubstituteName.EditIndex)
            { 
                for(int i=0; i < e.Row.Controls.Count; i++)
                {
                    DataControlFieldCell td = (DataControlFieldCell)e.Row.Controls[i];
                    td.Style.Add("border-top", "solid 2px #298AE5");
                    td.Style.Add("border-bottom", "solid 2px #298AE5");
                    if (i == 0)
                        td.Style.Add("border-right", "solid 2px #298AE5");
                    if (i == e.Row.Controls.Count - 1)
                        td.Style.Add("border-left", "solid 2px #298AE5");
                 }

                btnDelete.Style.Add("display", "none");
            }
        }

	}

	protected void btnEdit_Click(object sender, EventArgs e)
	{
		ImageButton btnEdit = sender as ImageButton;
        int unitTypeCode = Convert.ToInt32(btnEdit.Attributes["UnitTypeCode"]);
        int subUnitTypeCode = Convert.ToInt32(btnEdit.Attributes["SubUnitTypeCode"]);
		//this.SaveParametersFromControls(RemarkID);

		GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
		if (row == null) return;
        gvSubUnitTypeSubstituteName.EditIndex = row.RowIndex;
			this.RefreshGrid();
	}

	protected void btnCancelUdateRow_Click(object sender, EventArgs e)
	{
        this.gvSubUnitTypeSubstituteName.EditIndex = -1;
		this.RefreshGrid();
	}

	protected void btnSaveUpdateRow_Click(object sender, EventArgs e)
	{
		GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
		if (row == null) return;
        string substituteName = (row.FindControl("txtSubstituteName") as TextBox).Text;
        int unitTypeCode = int.Parse((row.FindControl("lblUnitTypeCode") as Label).Text);
        int subUnitTypeCode = int.Parse((row.FindControl("lblSubUnitTypeCode") as Label).Text);

        applicFacade.InsertSubUnitTypeSubstituteName(unitTypeCode, subUnitTypeCode, substituteName, userManager.GetUserNameForLog());

        this.gvSubUnitTypeSubstituteName.EditIndex = -1;
		this.BindGrid();
	}

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        ImageButton btnDelete = sender as ImageButton;
        int unitTypeCode = Convert.ToInt32(btnDelete.Attributes["UnitTypeCode"]);
        int subUnitTypeCode = Convert.ToInt32(btnDelete.Attributes["SubUnitTypeCode"]);

        applicFacade.DeleteSubUnitTypeSubstituteName(unitTypeCode, subUnitTypeCode);

        BindGrid();
    }

	#endregion -------------- Events Handlers --------------

	#region ---------- private ----------------

	private void GridClearSelection()
	{
        //this.gvSubUnitTypeSubstituteName.SelectedIndex = -1;
	}

	// not used in this page
	private void SaveParametersFromControls(int CategoryID)
	{
		GeneralRemarkParameters parameters = new GeneralRemarkParameters();
		parameters.RemarkCategory = CategoryID;

		// gvRemarkCategories SortColumnIdentifier and SortDirection
		Enums.SortableData? sortColumnIdentifier;
		SortDirection? sortDirection;
        this.GetGridSortingInfo(this.gvSubUnitTypeSubstituteName, out sortColumnIdentifier, out sortDirection);
		parameters.SortColumnIdentifier = sortColumnIdentifier;
		parameters.SortDirection = sortDirection;

        SessionParamsHandler.GeneralRemarkParametersUI = parameters;
	}

	// not used in this page
	private void SetGridParametersFromSession()
	{
        GeneralRemarkParameters parameters = SessionParamsHandler.GeneralRemarkParametersUI;
		if (parameters == null)
			return;

        this.SetGridSortingInfo(this.gvSubUnitTypeSubstituteName, parameters.SortColumnIdentifier, parameters.SortDirection);

	}

	/// <summary>
	/// Reset all GridView Sortable Headers to default instead of currentHeader.
	/// </summary>
	/// <param name="gridView"></param>
	/// <param name="currentHeader"></param>
	private void ResetGridViewSortableHeaders(GridView gridView, SortableColumnHeader currentHeader)
	{
		foreach (Control contr in this.GridViewHeaders.Controls)
		{
			foreach (Control header in contr.Controls)
			{
				//SortableColumnHeader header = ctrl.FindControl("sortHeader") as SortableColumnHeader;
				if (header is SortableColumnHeader && header != currentHeader)
				{
					((SortableColumnHeader)header).ResetSort();
				}
			}
		}
	}

	private void GetGridSortingInfo(GridView gridView, out Enums.SortableData? sortColumnIdentifier, out SortDirection? sortDirection)
	{
		sortColumnIdentifier = null;
		sortDirection = null;

		foreach (Control contr in this.GridViewHeaders.Controls)
		{
			foreach (Control header in contr.Controls)
			{
				//SortableColumnHeader header = ctrl.FindControl("sortHeader") as SortableColumnHeader;
				if (header is SortableColumnHeader
					&& ((SortableColumnHeader)header).CurrentSortDirection != null)
				{
					sortDirection = ((SortableColumnHeader)header).CurrentSortDirection;
					sortColumnIdentifier = ((SortableColumnHeader)header).ColumnIdentifier;
					return;
				}
			}
		}
	}

	private void SetGridSortingInfo(GridView gridView, Enums.SortableData? sortColumnIdentifier, SortDirection? sortDirection)
	{
		if (sortColumnIdentifier == null 
			|| sortDirection == null)
			return;

		foreach (Control contr in this.GridViewHeaders.Controls)
		{
			foreach (Control header in contr.Controls)
			{
				//SortableColumnHeader header = ctrl.FindControl("sortHeader") as SortableColumnHeader;
				if (header is SortableColumnHeader
					&& ((SortableColumnHeader)header).ColumnIdentifier == sortColumnIdentifier)
				{
					((SortableColumnHeader)header).SetSortDirection((SortDirection)sortDirection);
					// applay sort to gvRemarkCategories
					this.btnSort_Click(header, null);
					return;
				}
			}
		}
	}

	#endregion ------------- private ----------------
    
}
