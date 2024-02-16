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

public partial class ManageRemarkCategory : AdminBasePage
{
    private Facade applicFacade;
	private UserManager userManager;

	#region -------------- Properties -------------------

	private DataTable DataRemarkCategory
	{
		get
		{
			if (ViewState["RemarkCategory"] != null)
			{
				return (DataTable)ViewState["RemarkCategory"];
			}
			else
			{
				return null;
			}
		}
		set
		{
			ViewState["RemarkCategory"] = value;
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
			if (ViewState["CurrentRemarksSort"] != null)
			{
				return ViewState["CurrentRemarksSort"].ToString();
			}
			else
			{
				return null;
			}
		}
		set
		{
			ViewState["CurrentRemarksSort"] = value;
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
			//this.SetGridParametersFromSession();
		}
	}

	#region  --------------Binding--------------

	private void BindGrid()
	{
		DataSet ds = this.applicFacade.GetDIC_RemarkCategory();

		if (ds == null || ds.Tables.Count == 0)
			return;

		DataTable tblRemarkCategory = ds.Tables[0];

		if ( tblRemarkCategory.Rows.Count == 0)
		{
			this.trNoDataFound.Style.Add("display", "inline");
		}
		else
		{
			this.trNoDataFound.Style.Add("display", "none");
			this.DataRemarkCategory = tblRemarkCategory;
			this.RefreshGrid();
		}	
		
	}

	private void RefreshGrid()
	{
		DataView dv = new DataView(this.DataRemarkCategory, this.CurrentFilter,
							this.CurrentSort, DataViewRowState.CurrentRows);
		this.gvRemarkCategories.DataSource = dv;
		this.gvRemarkCategories.DataBind();
	}

	#endregion -------------- Binding --------------------

	#region -------------- Events Handlers ----------------
	
	protected void btnSort_Click(object sender, EventArgs e)
	{
		SortableColumnHeader currentHeader = sender as SortableColumnHeader;

		this.ResetGridViewSortableHeaders(this.gvRemarkCategories, currentHeader);

		string sort = currentHeader.ColumnIdentifier.ToString() + " " + currentHeader.GetStringValueOfCurrentSort();
		this.CurrentSort = sort;

		this.GridClearSelection();
		this.RefreshGrid();
	}

	protected void gvRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
	{
		
	}

	protected void btnDelete_Click(object sender, EventArgs e)
	{
		ImageButton btnDeleteRemark = sender as ImageButton;
		int RemarkCategoryID = Convert.ToInt32(btnDeleteRemark.Attributes["RemarkCategoryID"]);
		bool result = this.applicFacade.DeleteRemarkCategory(RemarkCategoryID);

		if (!result)
		{

		}
		else
		{
			this.BindGrid();
		}
	}

	protected void btnEdit_Click(object sender, EventArgs e)
	{
		ImageButton btnEdit = sender as ImageButton;
		int RemarkID = Convert.ToInt32(btnEdit.Attributes["RemarkCategoryID"]);
		//this.SaveParametersFromControls(RemarkID);

		GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
		if (row == null) return;
			this.gvRemarkCategories.EditIndex = row.RowIndex;
			this.RefreshGrid();
	}

	protected void btnAdd_Click(object sender, EventArgs e)
	{
		//this.SaveParametersFromControls(-1);
		//this.GridClearSelection();
		TextBox txtCategoryNameH = this.gvRemarkCategories.HeaderRow.FindControl("txtCategoryNameH") as TextBox;
		this.applicFacade.InsertRemarkCategory(txtCategoryNameH.Text);
		this.BindGrid();
	}

	protected void btnCancelUdateRow_Click(object sender, EventArgs e)
	{
		this.gvRemarkCategories.EditIndex = -1;
		this.RefreshGrid();
	}

	protected void btnSaveUpdateRow_Click(object sender, EventArgs e)
	{
		GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
		if (row == null) return;
		string CategoryName = (row.FindControl("txtCategoryNameE") as TextBox).Text;
		int CategoryID = int.Parse((row.FindControl("lblCategoryID") as Label).Text);
		
		this.applicFacade.UpdateRemarkCategory(CategoryID, CategoryName);
		
		this.gvRemarkCategories.EditIndex = -1;
		this.BindGrid();
	}

	#endregion -------------- Events Handlers --------------

	#region ---------- private ----------------

	private void GridClearSelection()
	{
		this.gvRemarkCategories.SelectedIndex = -1;
	}

	// not used in this page
	private void SaveParametersFromControls(int CategoryID)
	{
		GeneralRemarkParameters parameters = new GeneralRemarkParameters();
		parameters.RemarkCategory = CategoryID;

		// gvRemarkCategories SortColumnIdentifier and SortDirection
		Enums.SortableData? sortColumnIdentifier;
		SortDirection? sortDirection;
		this.GetGridSortingInfo(this.gvRemarkCategories, out sortColumnIdentifier, out sortDirection);
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
		
		this.SetGridSortingInfo(this.gvRemarkCategories, parameters.SortColumnIdentifier, parameters.SortDirection);

		// todo: change SelectedRemarkID to SelectedCategoryID  
		// set selection to gvRemarkCategories 
		//if (parameters.SelectedRemarkID != -1)
		//{
		//    foreach (GridViewRow row in this.gvRemarkCategories.Rows)
		//    {
		//        Label lblRemarkID = row.FindControl("lblCategoryID") as Label;
		//        if (lblRemarkID.Text == parameters.SelectedRemarkID.ToString())
		//        {
		//            this.gvRemarkCategories.SelectedIndex = row.RowIndex;
		//            break;
		//        }
		//    }
		//}
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


	//private void SetParametersFromSession()
	//{
	//    GeneralRemarkParameters parameters = this.SessionHandler.GeneralRemarkParametersUI;
	//    if (parameters == null)
	//        return;

	//    this.ddlRemarkType.SelectedValue = parameters.RemarkType.ToString();
	//    this.ddlRemarkCategory.SelectedValue = parameters.RemarkCategory.ToString();
	//    this.ddlRemarkStatus.SelectedValue = parameters.RemarkStatus.ToString();
	//}
}
