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

public partial class ManageGeneralRemarksDictionary : AdminBasePage
{
    private Facade applicFacade;
	private UserManager userManager;	

	#region -------------- Properties -------------------
	
	private DataTable AllRemarks
	{
		get
		{
			if (ViewState["AllRemarks"] != null)
			{
				return (DataTable)ViewState["AllRemarks"];
			}
			else
			{
				return null;
			}
		}
		set
		{
			ViewState["AllRemarks"] = value;
		}
	}

	private string CurrentRemarksFilter
	{
		get
		{
			int selType = -1;
			int selCategory = -1;
			int selStatus = -1;
			string filter = string.Empty;

			int.TryParse(this.ddlRemarkType.SelectedValue, out selType);
			int.TryParse(this.ddlRemarkCategory.SelectedValue, out selCategory);
			int.TryParse(this.ddlRemarkStatus.SelectedValue, out selStatus);

			if (selCategory != -1)
				filter += " RemarkCategoryID = " + selCategory.ToString();

			if (selStatus != -1)
			{
				if (filter.Length != 0)
					filter += " and ";
				filter += " active = " + selStatus.ToString();
			}

			//-------- filter by Remark Type 
			if (selType != -1)
			{
				Enums.remarkType selRemType = (Enums.remarkType)Enum.ToObject(typeof(Enums.remarkType), selType);
				string filterByType = string.Empty;

				switch (selRemType)
				{
					case Enums.remarkType.Doctor:
						filterByType = " linkedToDoctor = 1 ";
						break;

					case Enums.remarkType.Clinic:
						filterByType = " linkedToDept = 1 ";
						break;

					case Enums.remarkType.DoctorInClinic:
						filterByType = " linkedToDoctorInClinic = 1 ";
						break;

					case Enums.remarkType.ServiceInClinic:
					case Enums.remarkType.DoctorServiceInClinic:
						filterByType = " linkedToServiceInClinic = 1 ";
						break;

					case Enums.remarkType.ReceptionHours:
						filterByType = " linkedToReceptionHours = 1 ";
						break;

					default:
						break;
				}

				if (filter.Length > 0 && filterByType.Length >0)
					filter += " and ";

				filter += filterByType;
			}



			if (!string.IsNullOrEmpty(this.txtFilterRemarks.Text))
			{
				if (filter.Length != 0)
					filter += " and ";
				 filter += "remark like '%" + this.txtFilterRemarks.Text + "%'";
			}

			return filter;
		}// get
	}

	public string CurrentRemarksSort
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
			this.BinDdlRemarkType();
			this.BindDdlRemarkCategories();
			this.BindDdlRemarkStatus();
			this.CurrentRemarksSort = "remark";// default sort field
			this.SetParametersFromSession();

			this.BindGvRemarks();
			this.SetGVRemarksParametersFromSession();
			
		}
	}

	#region  --------------Binding--------------

	private void BinDdlRemarkType()   
	{
		//DataSet ds = applicFacade.GetRemarksTypes();

		this.ddlRemarkType.Items.Clear();
		this.ddlRemarkType.DataValueField = "ID";
		this.ddlRemarkType.DataTextField = "Remark";

		UIHelper.BindDropDownToCachedTable(this.ddlRemarkType, "RemarksTypes", "ID");

		ListItem defaultItem = new ListItem("הכל" ,"-1");
		this.ddlRemarkType.Items.Insert(0, defaultItem);
		this.ddlRemarkType.SelectedIndex = 0;
	}

	private void BindDdlRemarkCategories()
	{
		// get lookup table from DataBase and bind Ddl
		//Facade applicFacade = Facade.getFacadeObject();
		//DataSet ds = applicFacade.GetGeneralRemarkCategoriesByLinkedTo(null, this.userManager.UserIsAdministrator());

		//this.ddlRemarkCategory.Items.Clear();

		//if (ds != null && ds.Tables[0] != null)
		//{
		//    this.ddlRemarkCategory.DataSource = ds.Tables[0];
		//    this.ddlRemarkCategory.DataBind();
		//}
	
		this.ddlRemarkCategory.DataValueField = "RemarkCategoryID";
		this.ddlRemarkCategory.DataTextField = "RemarkCategoryName";
		this.ddlRemarkCategory.Items.Clear();

		UIHelper.BindDropDownToCachedTable(this.ddlRemarkCategory, "DIC_RemarkCategory", "RemarkCategoryName");

		//-- add default item
		ListItem defItem = new ListItem("הכל", "-1");
		this.ddlRemarkCategory.Items.Insert(0, defItem);

		//-- select default item
		this.ddlRemarkCategory.SelectedIndex = 0;
	}

	private void BindDdlRemarkStatus()
	{
		this.ddlRemarkStatus.DataValueField = "status";
		this.ddlRemarkStatus.DataTextField = "statusDescription";
		this.ddlRemarkStatus.Items.Clear();

		UIHelper.BindDropDownToCachedTable(this.ddlRemarkStatus, eCachedTables.View_ActivityStatus_Binary.ToString(), "statusDescription");

		//-- add default item
		ListItem defItem = new ListItem("הכל", "-1");
		this.ddlRemarkStatus.Items.Insert(0, defItem);

		//-- select default item
		this.ddlRemarkStatus.SelectedIndex = 0;
	}

	private void BindGvRemarks()
	{
		//btnSave.Enabled = false;  // disable the save untill we click one of the remarks
		
		DataSet ds = this.applicFacade.GetGeneralRemarks(null, userManager.UserIsAdministrator(), -1);// all remarkType, all remarkCategory  

		if (ds == null || ds.Tables[0] == null || ds.Tables[0].Rows.Count == 0)
		{
			this.trNoDataFound.Style.Add("display", "inline");
		}
		else
		{
			this.AllRemarks = ds.Tables[0];
			this.RefreshGvRemarks();
			trNoDataFound.Style.Add("display", "none");
		}
		
	}
	
	#endregion -------------- Binding --------------------

	#region -------------- Events Handlers ----------------
	
	protected void btnSearch_Click(object sender, EventArgs e)
	{
		this.GvRemarksClearSelection();
		this.RefreshGvRemarks();
	}

	protected void btnSort_Click(object sender, EventArgs e)
	{
		SortableColumnHeader currentHeader = sender as SortableColumnHeader;

		this.ResetGridViewSortableHeaders(this.gvRemarks, currentHeader);

		string sort = currentHeader.ColumnIdentifier.ToString() + " " + currentHeader.GetStringValueOfCurrentSort();
		this.CurrentRemarksSort = sort;

		this.GvRemarksClearSelection();
		this.RefreshGvRemarks();
	}

	

	protected void gvRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
	{
		if (e.Row.RowType == DataControlRowType.DataRow)
		{
            string remText = "!שים לב, הערות מסוג זה קיימות במערכת";
            remText += "##" + "!מחיקת סוג הערה זה תמחוק את כל ההערות מהסוג הנ``ל בכל המערכת";
            remText += "##" + "?האם ברצונך להמשיך";

		    DataRowView row = e.Row.DataItem as DataRowView;
            ImageButton btnDeleteRemark = e.Row.FindControl("btnDeleteRemark") as ImageButton;

			string remarkID = Convert.ToInt32(row["remarkID"]).ToString();

			if (Convert.ToInt32(row["InUseCount"]) > 0)
            {
				btnDeleteRemark.Attributes.Add("onclick", "SetRemarkIDtoBeDeleted('" + remarkID + "'); return AreYourSure('" + remText + "');");
            }
            else
            {
                btnDeleteRemark.Attributes.Add("onclick", "SetRemarkIDtoBeDeleted('" + remarkID + "'); return AreYourSure('?האם הנך בטוח שברצונך למחוק את ההערה');");
            }

		}
	}

	protected void btnDeleteRemark_Click(object sender, EventArgs e)
	{
		ImageButton btnDeleteRemark = sender as ImageButton;
		int RemarkID = Convert.ToInt32(btnDeleteRemark.Attributes["RemarkID"]);

		this.applicFacade.DeleteGeneralRemark(RemarkID);

		this.BindGvRemarks();
	}

	protected void btnEditRemark_Click(object sender, EventArgs e)
	{
		Button btnEditRemark = sender as Button;
		int RemarkID = Convert.ToInt32(btnEditRemark.Attributes["RemarkID"]);
		this.SaveParametersFromControls(RemarkID);
		this.OpenEditRemarkPage(RemarkID);
	}

	protected void btnAddRemark_Click(object sender, EventArgs e)
	{
		this.SaveParametersFromControls(-1);
		this.GvRemarksClearSelection();
		this.OpenEditRemarkPage(null);
	}
	
	#endregion -------------- Events Handlers --------------

	#region ---------- private ----------------

	private void GvRemarksClearSelection()
	{
		this.gvRemarks.SelectedIndex = -1;
	}

	private void OpenEditRemarkPage(int? RemarkID)
	{
		//this.SaveParametersFromControls();

		string URL = "~/Admin/EditRemarkByselectedType.aspx?remarkType=" + this.ddlRemarkType.SelectedValue
			+ "&PrevPage=ManageGeneralRemarksDictionary.aspx";
		if (RemarkID != null)
		{
			URL += "&selectedRemarkID=" + RemarkID ;
		}
                
		Response.Redirect(URL);
	}

	private void SaveParametersFromControls(int RemarkID)
	{
		GeneralRemarkParameters parameters = new GeneralRemarkParameters();
		parameters.RemarkType = int.Parse(this.ddlRemarkType.SelectedValue);
		parameters.RemarkCategory = int.Parse(this.ddlRemarkCategory.SelectedValue);
		parameters.RemarkStatus = int.Parse(this.ddlRemarkStatus.SelectedValue);

		parameters.SelectedRemarkID = RemarkID;
		
		// gvRemarks SortColumnIdentifier and SortDirection
		Enums.SortableData? sortColumnIdentifier;
		SortDirection? sortDirection;
		this.GetGVRemarksSortingInfo(this.gvRemarks, out sortColumnIdentifier, out sortDirection);
		parameters.SortColumnIdentifier = sortColumnIdentifier;
		parameters.SortDirection = sortDirection;

        SessionParamsHandler.GeneralRemarkParametersUI = parameters;
	}


	private void SetParametersFromSession()
	{
        GeneralRemarkParameters parameters = SessionParamsHandler.GeneralRemarkParametersUI;
		if (parameters == null)
			return;

		this.ddlRemarkType.SelectedValue = parameters.RemarkType.ToString();
		this.ddlRemarkCategory.SelectedValue = parameters.RemarkCategory.ToString();
		this.ddlRemarkStatus.SelectedValue = parameters.RemarkStatus.ToString();
	}

	private void SetGVRemarksParametersFromSession()
	{
        GeneralRemarkParameters parameters = SessionParamsHandler.GeneralRemarkParametersUI;
		if (parameters == null)
			return;
		
		this.SetGVRemarksSortingInfo(this.gvRemarks, parameters.SortColumnIdentifier, parameters.SortDirection);

		// set selection to gvRemarks
		if (parameters.SelectedRemarkID != -1)
		{
			foreach (GridViewRow row in this.gvRemarks.Rows)
			{
				Label lblRemarkID = row.FindControl("lblRemarkID") as Label;
				if (lblRemarkID.Text == parameters.SelectedRemarkID.ToString())
				{
					this.gvRemarks.SelectedIndex = row.RowIndex;
					break;
				}
			}
		}
	}

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

	private void GetGVRemarksSortingInfo(GridView gridView, out Enums.SortableData? sortColumnIdentifier, out SortDirection? sortDirection)
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

	private void SetGVRemarksSortingInfo(GridView gridView, Enums.SortableData? sortColumnIdentifier, SortDirection? sortDirection)
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
					// applay sort to gvRemarks
					this.btnSort_Click(header, null);
					return;
				}
			}
		}
	}

	private void RefreshGvRemarks()
	{
		DataView dv = new DataView(this.AllRemarks, this.CurrentRemarksFilter,
							this.CurrentRemarksSort, DataViewRowState.CurrentRows);
		this.gvRemarks.DataSource = dv;
		this.gvRemarks.DataBind();
	}

	#endregion ------------- private ----------------

	protected void imgCreateExcelReport_Click(object sender, ImageClickEventArgs e)
	{
		Hashtable WhereParameters = ParamsWhere();
		Session["ParamsWhere"] = WhereParameters;

		Session["CurrentReportName"] = "rprt_GeneralRemarksExcell";
		Session["CurrentReportTitle"] = "ניהול טבלת הערות סגורות";

		ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "CreateExcelReport", "CreateExcelReport();", true);
	}

	public Hashtable ParamsWhere()
	{
		Hashtable paramsWhere = new Hashtable();
		string freeText;
		if (txtFilterRemarks.Text.Trim() == String.Empty)
		{
			freeText = "-1";
		}
		else
		{
			freeText = txtFilterRemarks.Text.Trim();
		}

		paramsWhere.Add("FreeText", freeText);
		paramsWhere.Add("RemarkType", ddlRemarkType.SelectedValue);
		paramsWhere.Add("RemarkCategoryID", ddlRemarkCategory.SelectedValue);
		paramsWhere.Add("Status", ddlRemarkStatus.SelectedValue);
		paramsWhere.Add("userIsAdmin", userManager.UserIsAdministrator());

		return paramsWhere;
	}

	protected void btnDeleteSelectedRemarkAfterConfirm_Click(object sender, EventArgs e)
	{
		int RemarkID = Convert.ToInt32(txtRemarkIDtoBeDeleted.Text);
		this.applicFacade.DeleteGeneralRemark(RemarkID);

		this.BindGvRemarks();
	}
}
