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

namespace SeferNet.UI.Apps.UpdateTables
{
    public partial class CorrectGeneralRemarksText : System.Web.UI.Page
    {
        private Facade applicFacade;
        private UserManager userManager;
		private int current_DIC_remarkID;
		private RemarkManager remarkManager;

		UserInfo currentUser;

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
				int selRequireApproval = -1;

				int.TryParse(this.ddlRemarkType.SelectedValue, out selType);
				int.TryParse(this.ddlRemarkCategory.SelectedValue, out selCategory);
				int.TryParse(this.ddlRemarkStatus.SelectedValue, out selStatus);
				int.TryParse(this.ddlRequireApproval.SelectedValue, out selRequireApproval);

				if (selCategory != -1)
					filter += " RemarkCategoryID = " + selCategory.ToString();

				if (selStatus != -1)
				{
					if (filter.Length != 0)
						filter += " and ";
					filter += " active = " + selStatus.ToString();
				}

				if (selRequireApproval != -1)
				{
					if (filter.Length != 0)
						filter += " and ";
					if (selRequireApproval == 1)
					{ 
						filter += " remarkToCorrect is NOT NULL ";					
					}
					if (selRequireApproval == 0)
					{ 
						filter += " remarkToCorrect is NULL ";					
					}

				}
				// remarkToCorrect
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

					if (filter.Length > 0 && filterByType.Length > 0)
						filter += " and ";

					filter += filterByType;
				}



				if (!string.IsNullOrEmpty(this.txtFilterRemarks.Text))
				{
					if (filter.Length != 0)
						filter += " and ";
					filter = "remark like '%" + this.txtFilterRemarks.Text + "%'";
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
			this.remarkManager = new RemarkManager();

			currentUser = Session["currentUser"] as UserInfo;

			if (!this.IsPostBack)
			{
				this.BinDdlRemarkType();
				this.BindDdlRemarkCategories();
				this.BindDdlRemarkStatus();
				this.BindddlRequireApproval();
				this.CurrentRemarksSort = "remark";// default sort fiebtnSaveNewRemarkText_Clickld
				this.SetParametersFromSession();

				this.BindGvRemarks();
				this.SetGVRemarksParametersFromSession();
			}

			ScriptManager.RegisterClientScriptBlock(this, typeof(UpdatePanel), "hideProgressBarGeneral", "hideProgressBarGeneral()", true);
		}


		#region  --------------Binding--------------

		private void BinDdlRemarkType()
		{
			//DataSet ds = applicFacade.GetRemarksTypes();

			this.ddlRemarkType.Items.Clear();
			this.ddlRemarkType.DataValueField = "ID";
			this.ddlRemarkType.DataTextField = "Remark";

			UIHelper.BindDropDownToCachedTable(this.ddlRemarkType, "RemarksTypes", "ID");

			ListItem defaultItem = new ListItem("הכל", "-1");
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

		private void BindddlRequireApproval()
		{
			this.ddlRequireApproval.DataValueField = "RequireApproval";
			this.ddlRequireApproval.DataTextField = "RequireApprovalDescription";
			this.ddlRequireApproval.Items.Clear();

			//UIHelper.BindDropDownToCachedTable(this.ddlRemarkStatus, eCachedTables.View_ActivityStatus_Binary.ToString(), "statusDescription");

			//-- add default item
			ListItem defItem = new ListItem("הכל", "-1");
			ListItem firstItem = new ListItem("כן", "1");
			ListItem secondItem = new ListItem("לא", "0");
			this.ddlRequireApproval.Items.Insert(0, defItem);
			this.ddlRequireApproval.Items.Insert(1, firstItem);
			this.ddlRequireApproval.Items.Insert(2, secondItem);

			//-- select default item
			this.ddlRequireApproval.SelectedIndex = 0;
		}

		private void BindGvRemarks()
		{
			//btnSave.Enabled = false;  // disable the save untill we click one of the remarks

			DataSet ds = this.applicFacade.GetGeneralRemarksToCorrect(null, userManager.UserIsAdministrator(), -1);// all remarkType, all remarkCategory  

			DataView dv = new DataView(ds.Tables[0], " remarkToCorrect is NOT null ", this.CurrentRemarksSort, DataViewRowState.CurrentRows);

			if (dv.Count == 0)
			{
				btnSendMail.Enabled = false;
				btnSendMail.Style["color"] = "#AEAEAE";
				btnSendMail.Style["cursor"] = "auto";
			}
			else
			{
				btnSendMail.Enabled = true;
				btnSendMail.Style["color"] = "#0069CC";
				btnSendMail.Style["cursor"] = "pointer";
			}
					   
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

		protected void btnSaveNewRemarkText_Click(object sender, EventArgs e)
		{
			current_DIC_remarkID = (int)Session["current_DIC_remarkID"]; 
			UserInfo currentUser = Session["currentUser"] as UserInfo;

			//this.GvRemarksClearSelection();
			//this.RefreshGvRemarks();
			bool correctionResult = ValidateRemarkCorrection(lblRemarkTextOld.Text, txtRemarkTextNew.Text);

			// save corrected remark here
			// *** SAVE ***
			if (correctionResult)
			{
				this.applicFacade.InsertDicGeneralRemarkToCorrect(txtRemarkTextNew.Text, current_DIC_remarkID, currentUser.UserNameWithPrefix);

				this.BindGvRemarks();
			}

			if (!correctionResult)
			{ 
				ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowUpdateRemarkBox", "ShowUpdateRemarkBox();", true);			
			}

			ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "SetScrollPosition", "SetScrollPosition();", true);
		}


		protected void btnDeleteNewRemarkText_Click(object sender, EventArgs e)
		{
			//current_DIC_remarkID = (int)Session["current_DIC_remarkID"]; 
			ImageButton btnDeleteRemark = sender as ImageButton;
			int RemarkID = Convert.ToInt32(btnDeleteRemark.Attributes["RemarkID"]);

			this.applicFacade.DeleteDicGeneralRemarkToCorrect(RemarkID);

			this.BindGvRemarks();
		}

		protected bool ValidateRemarkCorrection(string oldRemarkText, string newRemarkText)
		{
			bool res = false;
			int intTYpe = 0;
			bool maskexists = true;

			List<string> listOldRemarkText = new List<string>();
			List<string> listOldRemarkMask = new List<string>();

			List<string> listNewRemarkText = new List<string>();
			List<string> listNewRemarkMask = new List<string>();

			if (newRemarkText == string.Empty)
			{
				lblValidateNewTextMessage.Text = "ההערה לא יכולה להיות ריקה";
				return false;
			}

			string[] arrOldRemarkText = oldRemarkText.Trim().Split('#');
			string[] arrNewRemarkText = newRemarkText.Trim().Split('#');

			for (int i = 0; i < arrOldRemarkText.Length; i++)
			{
				res = int.TryParse(arrOldRemarkText[i], out intTYpe);

				if (res)
				{
					listOldRemarkMask.Add(arrOldRemarkText[i]);
					//arrOldRemarkText[i] = '#' + arrOldRemarkText[i] + '#';
				}
				else
				{
					listOldRemarkText.Add(arrOldRemarkText[i]);
				}
			}


			for (int i = 0; i < arrNewRemarkText.Length; i++)
			{
				res = int.TryParse(arrNewRemarkText[i], out intTYpe);

				if (res)
				{
					listNewRemarkMask.Add(arrNewRemarkText[i]);
				}
				else
				{
					listNewRemarkText.Add(arrNewRemarkText[i]);
				}
			}



			if (listOldRemarkText.Count == listNewRemarkText.Count && listOldRemarkMask.Count == listNewRemarkMask.Count)
			{
				for (int i = 0; i < listOldRemarkMask.Count; i++)
				{
					maskexists = false;

					for (int ii = 0; ii < listNewRemarkMask.Count; ii++)
					{
						if (listOldRemarkMask[i] == listNewRemarkMask[ii])
						{
							maskexists = true;
							listNewRemarkMask[ii] = "00"; // exclude item from comparisson process

							break;
						}
					}
				}

				if (maskexists)
				{
					lblValidateNewTextMessage.Text = String.Empty;
					return true;
				}
				else
				{ 
					lblValidateNewTextMessage.Text = "error";
					return false;					
				}

			}
			else
			{ 
				lblValidateNewTextMessage.Text = "error";
				return false;			
			}

		}

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

				Label lblRemarkTextToCorrect = e.Row.FindControl("lblRemarkTextToCorrect") as Label;

				if (!currentUser.IsAdministrator || lblRemarkTextToCorrect.Text == string.Empty)
				{
					HtmlTable tbl = e.Row.FindControl("tbApproveRemark") as HtmlTable;
					tbl.Attributes.Add("style", "display:none");
				}

				ImageButton btnDeleteRemark = e.Row.FindControl("btnDeleteRemark") as ImageButton;

				if (lblRemarkTextToCorrect.Text == string.Empty)
				{
					//btnDeleteRemark.Attributes.Add("onclick", "return AreYourSure('" + remText + "');");
					btnDeleteRemark.Attributes.Add("style", "display:none");
				}
				//else
				//{
				//	btnDeleteRemark.Attributes.Add("onclick", "return AreYourSure('?האם הנך בטוח שברצונך למחוק את ההערה');");
				//}

			}
		}
		protected void btnApproveRemark_Click(object sender, EventArgs e)
		{
			Button btnApproveRemark = sender as Button;
			current_DIC_remarkID = Convert.ToInt32(btnApproveRemark.Attributes["RemarkID"]);
			string remarkToCorrect = btnApproveRemark.Attributes["RemarkTextToCorrect"].ToString();

			bool result = applicFacade.ApproveDICRemark_AndUpdateRemarks(current_DIC_remarkID, currentUser.UserNameWithPrefix, remarkToCorrect);

			if (!result)
			{
				ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "Alert", "alert('האישור נכשל!');", true);
			}

			this.BindGvRemarks();

			ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "SetScrollPosition", "SetScrollPosition();", true);
		}

		protected void btnEditRemark_Click(object sender, EventArgs e)
		{
			Button btnEditRemark = sender as Button;
			current_DIC_remarkID = Convert.ToInt32(btnEditRemark.Attributes["RemarkID"]);
			Session["current_DIC_remarkID"] = current_DIC_remarkID;

			String OldRemarkText = String.Empty;
			String NewRemarkText = String.Empty;
			lblValidateNewTextMessage.Text = String.Empty;

			//DataSet dataOldRemark = applicFacade.GetGeneralRemarkByRemarkID(current_DIC_remarkID);
			//String OldRemarkText = dataOldRemark.Tables[0].Rows[0]["remark"].ToString();
			//String NewRemarkText = String.Empty;

			//DataSet dataNewRemark = applicFacade.getGeneralRemarks_ToCorrect_ByRemarkID(current_DIC_remarkID);
			//if (dataNewRemark.Tables[0].Rows.Count > 0)
			//{
			//	NewRemarkText = dataNewRemark.Tables[0].Rows[0]["remark"].ToString();
			//}
			//else
			//{
			//	NewRemarkText = OldRemarkText;
			//}


			//int objectIndex = 0;
			//String rowClientID = string.Empty;
			//String ListOfInputID = string.Empty;
			lblRemarkTextOld.Text = btnEditRemark.Attributes["RemarkText"].ToString();
			txtRemarkTextNew.Text = btnEditRemark.Attributes["RemarkTextToCorrect"].ToString();

			//remarkManager.setDICremarkToCorrectTextVariableLength(OldRemarkText, current_DIC_remarkID.ToString(), ref remarkOldPanel, ref objectIndex, rowClientID, ref ListOfInputID);

			ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowUpdateRemarkBox", "ShowUpdateRemarkBox();", true);
			ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "SetScrollPosition", "SetScrollPosition();", true);
		}

		protected void btnSendMail_Click(object sender, EventArgs e)
		{
			string MailTo = System.Configuration.ConfigurationManager.AppSettings["ReportClinicChangeToMail"].ToString();
			string UserName = currentUser.FirstName + ' ' + currentUser.LastName;
			string UserMail = currentUser.Mail;
			string Url = GetAbsoluteUrlToCorrectGeneralRemarks();

			applicFacade.ApplyForChangeDIC_remarks( MailTo, Url, UserName, UserMail);
		}

		private string GetAbsoluteUrlToCorrectGeneralRemarks()
		{
			string HTTPprefix = "http://";
			if (System.Configuration.ConfigurationManager.AppSettings["Is_HTTPS_enabled"].ToString() == "1")
			{
				HTTPprefix = "https://";
			}

			string serverName = Request.ServerVariables["SERVER_NAME"].ToString();
			string[] segmentsURL = Request.Url.Segments;
			string url = string.Empty;
			url = HTTPprefix + serverName + segmentsURL[0] + segmentsURL[1] + "UpdateTables/CorrectGeneralRemarksText.aspx";
			return url;
		}

		#endregion -------------- Events Handlers --------------

		#region ---------- private ----------------

		private void GvRemarksClearSelection()
		{
			this.gvRemarks.SelectedIndex = -1;
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


	}
}