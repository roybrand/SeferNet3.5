using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.FacadeLayer;
using SeferNet.Globals;
using SeferNet.BusinessLayer.WorkFlow;

namespace SeferNet.UI.Apps.Admin
{
    public partial class EditRemarkByselectedType_NEW : System.Web.UI.Page
    {
        private Facade applicFacade;
        private UserManager userManager = new UserManager();
		#region ----------- Properties

		private DataTable TableRemarks
		{
			get
			{
				if (ViewState["TableRemarks"] != null)
				{
					return (DataTable)ViewState["TableRemarks"];
				}
				else
				{
					return null;
				}
			}
			set
			{
				ViewState["TableRemarks"] = value;
			}
		}

		private int remarkID
		{
			get
			{
				if (ViewState["remarkID"] != null)
				{
					return (int)ViewState["remarkID"];
				}
				else
				{
					return 0;
				}
			}
			set
			{
				ViewState["remarkID"] = value;
			}
		}

		private string remarkType
		{
			get
			{
				if (ViewState["remarkType"] != null)
				{
					return (string)ViewState["remarkType"];
				}
				else
				{
					return "-1";
				}
			}
			set
			{
				ViewState["remarkType"] = value;
			}
		}

		#endregion

		#region ---------- Binding

		protected void dvGeneralRemarks_DataBound(object sender, EventArgs e)
		{
			Enums.remarkType selRemType = (Enums.remarkType)Enum.Parse(typeof(Enums.remarkType), this.remarkType);
			CheckBox chk = this.dvGeneralRemarks.FindControl("cblinkedToReceptionHours") as CheckBox;

			//---  add new remark mode
			if (this.remarkID == 0)
			{
				this.dvGeneralRemarks.Fields[0].Visible = false;
			}
			//--- update remark mode
			else
			{
				this.dvGeneralRemarks.Fields[0].Visible = true;

				//if (chk != null)
				//{
				//    //chk.Attributes.Add("onchange", "linkedToReceptionHours_CheckedChanged(this)");
				//    chk.Attributes.Add("onchange", "alert('checkBox Changed'); ");
				//    chk.Attributes.Add("onclick", "linkedToReceptionHours_CheckedChanged(this)");
				//}

			}
			//this.linkedToReceptionHours_CheckedChanged(this, null);
		}

		private void BindDvGeneralRemarks()
		{
			DataSet data = this.applicFacade.GetGeneralRemarkByRemarkID(this.remarkID);
			if (data.Tables.Count == 0)
				return;
			// --- insert new remark mode
			if (data.Tables[0].Rows.Count == 0)
			{
				DataRow newRow = data.Tables[0].NewRow();
				newRow["remarkID"] = 0;
				newRow["remark"] = string.Empty;
				newRow["active"] = true;
				newRow["RemarkCategoryID"] = 1;
				newRow["linkedToDept"] = false;
				newRow["linkedToDoctor"] = false;
				newRow["linkedToServiceInClinic"] = false;
				newRow["linkedToReceptionHours"] = false;
				newRow["EnableOverlappingHours"] = false;
				newRow["Factor"] = 1;
				newRow["OpenNow"] = true;
				newRow["ShowForPreviousDays"] = 10;

				Enums.remarkType selRemType = (Enums.remarkType)Enum.Parse(typeof(Enums.remarkType), this.remarkType);

				switch (selRemType)
				{
					case Enums.remarkType.Clinic:
						newRow["linkedToDept"] = true;
						newRow["linkedToReceptionHours"] = true;
						break;
					case Enums.remarkType.Doctor:
					case Enums.remarkType.DoctorInClinic:
						newRow["linkedToDoctor"] = true;
						break;
					case Enums.remarkType.ServiceInClinic:
						newRow["linkedToServiceInClinic"] = true;
						break;
					case Enums.remarkType.ReceptionHours:
						newRow["linkedToReceptionHours"] = true;
						break;

					default:
						newRow["linkedToDept"] = true;
						break;
				}
				data.Tables[0].Rows.Add(newRow);
			}
			//--- update remark mode
			else
			{
				//if (data.Tables[0].Rows[0]["linkedToDept"] as bool? == true)
				//{
				//    data.Tables[0].Rows[0]["linkedToReceptionHours"] = true;
				//}
			}

			this.TableRemarks = data.Tables[0];
			this.dvGeneralRemarks.DataSource = data.Tables[0];
			this.dvGeneralRemarks.DataBind();

			Set_btnSaveAndRenewRemarks();

			txtRemarkText.Text = TableRemarks.Rows[0]["remark"].ToString();
		}

		private void Set_btnSaveAndRenewRemarks()
		{
			bool remarkIsSimple = false;
			if (remarkID != 0)
			{
				string remarkText = TableRemarks.Rows[0]["remark"].ToString();
				if (remarkText.IndexOf('#') < 0)
				{
					remarkIsSimple = true;
				}
			}

			if (userManager.UserIsAdministrator() && remarkID != 0 && remarkIsSimple)
			{
				btnSaveAndRenewRemarks.Enabled = true;
			}
			else
			{
				btnSaveAndRenewRemarks.Enabled = false;
			}

		}


		private void BindDdlRemarkCategories()
		{
			DropDownList ddlRemarkCategory = this.dvGeneralRemarks.FindControl("ddlRemarkCategory") as DropDownList;
			ddlRemarkCategory.DataValueField = "RemarkCategoryID";
			ddlRemarkCategory.DataTextField = "RemarkCategoryName";
			ddlRemarkCategory.Items.Clear();

			UIHelper.BindDropDownToCachedTable(ddlRemarkCategory, "DIC_RemarkCategory", "RemarkCategoryName");

			//-- select default item
			//--- update remark mode
			if (this.remarkID != 0)
			{
				ddlRemarkCategory.SelectedValue = this.TableRemarks.Rows[0]["RemarkCategoryID"].ToString();
			}
			else //--- Insert new remark mode
			{
				ddlRemarkCategory.SelectedValue = "1";
			}
		}

		private void BindDdlRemarkFactor()
		{
			DropDownList ddlRemarkFactor = this.dvGeneralRemarks.FindControl("ddlRemarkFactor") as DropDownList;
			ddlRemarkFactor.DataValueField = "FactorValue";
			ddlRemarkFactor.DataTextField = "FactorDescription";
			ddlRemarkFactor.Items.Clear();

			UIHelper.BindDropDownToCachedTable(ddlRemarkFactor, "WeeklyHoursFactors", "FactorValue DESC");

			//-- select default item
			//--- update remark mode
			if (this.remarkID != 0)
			{
				ddlRemarkFactor.SelectedValue = this.TableRemarks.Rows[0]["Factor"].ToString();
			}
			else //--- Insert new remark mode
			{
				ddlRemarkFactor.SelectedValue = "1";
			}
		}

		private void BindDDlRemarkTags()
		{
			DataView dvRemarkTags = new DataView((DataTable)Session["RemarkTagsTable"]);
			//ddlTags.Items.Add(new ListItem("בחר תגית", "-1"));
			ddlTags.DataSource = dvRemarkTags;
			ddlTags.DataValueField = "RemarkTagValue";
			ddlTags.DataTextField = "RemarkTagText";
			ddlTags.DataBind();
			ddlTags.Items.Insert(0, new ListItem("בחר תגית", "-1"));

		}


		#endregion

		#region ------------ Events handlers

		protected void Page_Load(object sender, EventArgs e)
		{
			this.applicFacade = Facade.getFacadeObject();
			if (!Page.IsPostBack)
			{
				GetRemarkTagsTable();
				this.SavePrevPageToViewState();
				this.remarkID = this.GetSelectedRemarkID_fromRequest();
				this.remarkType = this.GetRemarkType_fromRequest();

				this.BindDvGeneralRemarks();
				this.BindDdlRemarkCategories();
				this.BindDdlRemarkFactor();
				BindDDlRemarkTags();
				// start building remark
				FormRemark();
			}
			else
			{
				FormRemark();
			}
		}


		protected void btnFormRemark_Click(object sender, EventArgs e)
		{
			//string remarkTextNotFormatted = txtRemarkText.Text;
			//HTMLformattedRemark(remarkTextNotFormatted);

			//FormRemark();
		}

		protected void FormRemark()
		{
			string remarkTextNotFormatted = txtRemarkText.Text;
			HTMLformattedRemark(remarkTextNotFormatted);
		}

		protected void GetRemarkTagsTable()
		{
			Facade applicFacade = Facade.getFacadeObject();
			Session["RemarkTagsTable"] = applicFacade.getRemarkTagsToCreateRemark().Tables[0];
		}

		protected void HTMLformattedRemark(string remarkText)
		{
			DataTable RemarkTagsTable = (DataTable)Session["RemarkTagsTable"];

			HtmlGenericControl div;
			HtmlGenericControl divWithButton;
			TextBox txtTextTag;
			ImageButton btnAddTag;
			ImageButton btnRemoveTag;

			int tagKey;

			// remove all controls from Panel
			divRemarkBuilder.Controls.Clear();

			//string[] words = remarkText.Trim().Split('#');
			string[] words = remarkText.Split(new[] { '#' }, StringSplitOptions.RemoveEmptyEntries);

			if (words.Length == 0) // add 1-st "btnAddTag". If remark is empty (new) there is to be option to start with
			{
				divWithButton = new HtmlGenericControl("div");
				btnAddTag = new ImageButton();
				btnAddTag.ImageUrl = "../Images/Applic/phone-direct.png";
				btnAddTag.Click += new ImageClickEventHandler(btnAddTag_Click);
				btnAddTag.ID = "btnAddTag" + 0.ToString();
				//btnAddTag.OnClientClick = "return SetCurrentTagitNumber('" + i.ToString() + "');";
				btnAddTag.OnClientClick = "return SetCurrentTagitNumber('" + 0.ToString() + "','" + btnAddTag.ID.ToString() + "');";

				divWithButton.Controls.Add(btnAddTag);
				divWithButton.Attributes.CssStyle.Add("float", "right");
				divRemarkBuilder.Controls.Add(divWithButton);
				// END of Button to "AddTag"

				div = new HtmlGenericControl("div");
				div.ID = "dv" + 0;
				div.Attributes.CssStyle.Add("float", "right");
			}

			for (int i = 0; i < words.Length; i++)
			{
				// Button to "AddTag"
				divWithButton = new HtmlGenericControl("div");
				btnAddTag = new ImageButton();
				btnAddTag.ImageUrl = "../Images/Applic/phone-direct.png";
				btnAddTag.Click += new ImageClickEventHandler(btnAddTag_Click);
				btnAddTag.ID = "btnAddTag" + i.ToString();
				btnAddTag.OnClientClick = "return SetCurrentTagitNumber('" + i.ToString() + "','" + btnAddTag.ID.ToString() + "');";

				divWithButton.Controls.Add(btnAddTag);
				divWithButton.Attributes.CssStyle.Add("float", "right");
				divRemarkBuilder.Controls.Add(divWithButton);
				// END of Button to "AddTag"

				// button "btnRemoveTag"
				divWithButton = new HtmlGenericControl("div");
				btnRemoveTag = new ImageButton();
				btnRemoveTag.ImageUrl = "../Images/Applic/btn_X_grey.gif";
				btnRemoveTag.Click += new ImageClickEventHandler(btnRemoveTag_Click);
				btnRemoveTag.ID = "btnRemoveTag" + i.ToString();
				btnRemoveTag.OnClientClick = "return SetTagitNumberToBeRemoved('" + i.ToString() + "');";
				divWithButton.Controls.Add(btnRemoveTag);
				divWithButton.Attributes.CssStyle.Add("float", "right");
				divRemarkBuilder.Controls.Add(divWithButton);
				// END of button "btnRemoveTag"

				div = new HtmlGenericControl("div");
				div.ID = "dv" + i;
				div.Attributes.CssStyle.Add("float", "right");

				if (words[i].ToString().Trim() != string.Empty)
				{

					if (int.TryParse(words[i], out tagKey)) // if the word is a number it means it's a tagKey and to be replaced with Tag
					{
						for (int ii = 0; ii < RemarkTagsTable.Rows.Count; ii++)
						{
							if (Convert.ToInt32(RemarkTagsTable.Rows[ii]["RemarkTagKeyMin"]) <= Convert.ToInt32(words[i])
								&& Convert.ToInt32(RemarkTagsTable.Rows[ii]["RemarkTagKeyMax"]) >= Convert.ToInt32(words[i]))
							{
								//div.InnerText = " " + RemarkTagsTable.Rows[ii]["RemarkTagText"].ToString() + " ";
								div.InnerText = RemarkTagsTable.Rows[ii]["RemarkTagText"].ToString();
								div.Attributes.CssStyle.Add("color", "red");
								div.Attributes.CssStyle.Add("font-weight", "bold");
								div.Attributes.CssStyle.Add("padding-left", "5px");
								div.Attributes.CssStyle.Add("padding-right", "5px");
							}
						}
					}
					else // was TextBox, now will be InnerText 
					{
						//txtTextTag = new TextBox();
						//txtTextTag.ID = "txtTextTag_" + i.ToString();
						//txtTextTag.Text = words[i];
						//div.Controls.Add(txtTextTag);
						div.InnerText = words[i];
						div.Attributes.CssStyle.Add("color", "#525552"); // RegularLabel
						div.Attributes.CssStyle.Add("font-weight", "bold");
						div.Attributes.CssStyle.Add("padding-left", "5px");
						div.Attributes.CssStyle.Add("padding-right", "5px");
					}

					divRemarkBuilder.Controls.Add(div);
				}

				if ( i == (words.Length - 1 ) ) // add closing "btnAddTag". To be possible to add element after the last of existing elements
				{
					divWithButton = new HtmlGenericControl("div");
					btnAddTag = new ImageButton();
					btnAddTag.ImageUrl = "../Images/Applic/phone-direct.png";
					btnAddTag.Click += new ImageClickEventHandler(btnAddTag_Click);
					btnAddTag.ID = "btnAddTag" + (i + 1).ToString();
					//btnAddTag.OnClientClick = "return SetCurrentTagitNumber('" + i.ToString() + "');";
					btnAddTag.OnClientClick = "return SetCurrentTagitNumber('" + (i + 1).ToString() + "','" + btnAddTag.ID.ToString() + "');";

					divWithButton.Controls.Add(btnAddTag);
					divWithButton.Attributes.CssStyle.Add("float", "right");
					divRemarkBuilder.Controls.Add(divWithButton);
					// END of Button to "AddTag"

					div = new HtmlGenericControl("div");
					div.ID = "dv" + (i + 1);
					div.Attributes.CssStyle.Add("float", "right");
				}
			}

		}
		
		protected void ddlTags_SelectedIndexChanged(object sender, EventArgs e)
		{
			string remarkTextNotFormatted = txtRemarkText.Text;
			string[] words = remarkTextNotFormatted.Split(new[] { '#' }, StringSplitOptions.RemoveEmptyEntries);

			int newElementNumber = Convert.ToInt32(txtCurrentAddButtonNumber.Text);

			string newRemarkTextNotFormatted = string.Empty;

			int tagKey;

			// go through text elements and add NEW element at "newElementNumber" position
			for (int i = 0; i < words.Length; i++)
			{
				if (i == newElementNumber) // insert New element into this position
				{ 
				
				}

				if (int.TryParse(words[i], out tagKey))
				// if the word is a number it means it's a tagKey and to be replaced with Tag
				{
					newRemarkTextNotFormatted += '#' + words[i] + '#';
				}
				else
				{ }
				//newRemarkTextNotFormatted += words[i];
			}

		}

		protected void imbutAdd_Click(object sender, ImageClickEventArgs e)
		{
			ImageButton button = sender as ImageButton;
			string btnID = button.ID;

			string remarkTextNotFormatted = txtRemarkText.Text;

			string[] words = remarkTextNotFormatted.Split(new[] { '#' }, StringSplitOptions.RemoveEmptyEntries);

			// newElementNumber - index of element to added/inserted 
			int newElementNumber = Convert.ToInt32(txtCurrentAddButtonNumber.Text);

			// newRemarkTextNotFormatted - apdated/new remark text  
			string newRemarkTextNotFormatted = string.Empty;

			int tagKey;

			if (words.Length == 0)
			{
				newRemarkTextNotFormatted += '#' + txtDDLTagsSelectedValue.Text + '#';
			}

			// go through text elements and add NEW element at "newElementNumber" position
			for (int i = 0; i < words.Length; i++)
			{
				if (i == newElementNumber) // insert New element into this position
				{
					newRemarkTextNotFormatted += '#' + txtDDLTagsSelectedValue.Text + '#';
				}

				if (int.TryParse(words[i], out tagKey))
				// if the word is a number it means it's a tagKey and to be replaced with Tag
				{
					newRemarkTextNotFormatted += '#' + words[i] + '#';
				}
				else
				{
					newRemarkTextNotFormatted += words[i];
				}

				if (i == (words.Length - 1) && newElementNumber == words.Length) // Came to last existing element and New element to be added after
				{
					newRemarkTextNotFormatted += '#' + txtDDLTagsSelectedValue.Text + '#';
				}
			}

			// return updated/new remark to  txtRemarkText;
			txtRemarkText.Text = newRemarkTextNotFormatted;

			HTMLformattedRemark(newRemarkTextNotFormatted);
		}
		protected void btnAddTag_Click(object sender, EventArgs e)
		{
			ImageButton button = sender as ImageButton;
			string btnID = button.ID;

			//string remarkTextNotFormatted = txtRemarkText.Text;

			//string[] words = remarkTextNotFormatted.Split(new[] { '#' }, StringSplitOptions.RemoveEmptyEntries);

			//// newElementNumber - index of element to added/inserted 
			//int newElementNumber = Convert.ToInt32(txtCurrentAddButtonNumber.Text);

			//// newRemarkTextNotFormatted - apdated/new remark text  
			//string newRemarkTextNotFormatted = string.Empty;

			//int tagKey;

			//// go through text elements and add NEW element at "newElementNumber" position
			//for (int i = 0; i < words.Length; i++)
			//{
			//	if (i == newElementNumber) // insert New element into this position
			//	{
			//		newRemarkTextNotFormatted += '#' + txtDDLTagsSelectedValue.Text + '#';
			//	}

			//	if (int.TryParse(words[i], out tagKey))
			//	// if the word is a number it means it's a tagKey and to be replaced with Tag
			//	{
			//		newRemarkTextNotFormatted += '#' + words[i] + '#';
			//	}
			//	else
			//	{ 
			//	//newRemarkTextNotFormatted += words[i];
			//	}
			//}

			//HTMLformattedRemark(newRemarkTextNotFormatted);
		}

		protected void btnRemoveTag_Click(object sender, EventArgs e)
		{
			ImageButton button = sender as ImageButton;
			string btnID = button.ID;
		}

		protected void btnSave_Click(object sender, EventArgs e)
		{
			SaveRemark();

			this.MoveToPrevPage();
		}

		protected void btnSaveAndRenewRemarks_Click(object sender, EventArgs e)
		{
			SaveRemark();

			RenewRemarks();

			this.MoveToPrevPage();
		}

		private void RenewRemarks()
		{
			this.applicFacade.RenewRemarks(remarkID, userManager.GetUserNameForLog());
		}

		private void SaveRemark()
		{
			TextBox tbRemark = this.dvGeneralRemarks.FindControl("txtRemark") as TextBox;
			string remarkText = string.Empty;
			if (tbRemark != null && tbRemark.Text != string.Empty)
			{
				//remarkText = Server.HtmlEncode(tbRemark.Text);
				remarkText = tbRemark.Text;
			}

			int remarkCategory = int.Parse((this.dvGeneralRemarks.FindControl("ddlRemarkCategory") as DropDownList).SelectedValue);

			bool active = (this.dvGeneralRemarks.FindControl("cbActive") as CheckBox).Checked;

			bool linkedToDept = (this.dvGeneralRemarks.FindControl("cblinkedToDept") as CheckBox).Checked;
			bool linkedToDoctor = (this.dvGeneralRemarks.FindControl("cblinkedToDoctor") as CheckBox).Checked;
			bool linkedToServiceInClinic = (this.dvGeneralRemarks.FindControl("cblinkedToServiceInClinic") as CheckBox).Checked;
			bool linkedToReceptionHours = (this.dvGeneralRemarks.FindControl("cblinkedToReceptionHours") as CheckBox).Checked;
			bool enableOverlappingHours = (this.dvGeneralRemarks.FindControl("cbEnableOverlappingHours") as CheckBox).Checked;
			float factor = float.Parse((this.dvGeneralRemarks.FindControl("ddlRemarkFactor") as DropDownList).SelectedValue);
			bool openNow = (this.dvGeneralRemarks.FindControl("cbOpenNow") as CheckBox).Checked;

			string showForPreviousDays_str = (this.dvGeneralRemarks.FindControl("txtShowForPreviousDays") as TextBox).Text;
			int showForPreviousDays;
			if (showForPreviousDays_str.Trim() == string.Empty)
			{
				showForPreviousDays = 0;
			}
			else
			{
				showForPreviousDays = Convert.ToInt32(showForPreviousDays_str);
			}

			// insert new remark
			if (this.remarkID == 0)
			{
				this.applicFacade.InsertDicGeneralRemark(
					remarkText,
					remarkCategory,
					active,
					linkedToDept,
					linkedToDoctor,
					false,
					linkedToServiceInClinic,
					linkedToReceptionHours,
					enableOverlappingHours,
					factor,
					openNow,
					showForPreviousDays,
					userManager.GetUserNameForLog()
					);
			}
			// update remark
			else
			{
				this.applicFacade.UpdateDicGeneralRemark(
					this.remarkID,
					remarkText,
					remarkCategory,
					active,
					linkedToDept,
					linkedToDoctor,
					false,
					linkedToServiceInClinic,
					linkedToReceptionHours,
					enableOverlappingHours,
					factor,
					openNow,
					showForPreviousDays,
					userManager.GetUserNameForLog()
					);
			}
		}

		protected void btnCancel_Click(object sender, EventArgs e)
		{
			this.MoveToPrevPage();
		}

		//protected void linkedToReceptionHours_CheckedChanged(object sender, EventArgs e)
		//{
		//	CheckBox chk = this.dvGeneralRemarks.FindControl("cblinkedToReceptionHours") as CheckBox;
		//       HtmlTable tbl = this.dvGeneralRemarks.FindControl("tblRemarkFactor") as HtmlTable;

		//	if (chk != null)
		//	{
		//		if (chk.Checked)
		//		{
		//			this.dvGeneralRemarks.Fields[8].Visible = true;
		//               tbl.Visible = true;
		//           }
		//		else
		//		{
		//			this.dvGeneralRemarks.Fields[8].Visible = false;
		//               tbl.Visible = false;
		//		}
		//	}
		//}

		#endregion

		#region ------------ Private Methods --------------

		private void SavePrevPageToViewState()
		{
			ViewState["PrevPage"] = this.GetPrevPage_fromRequest(); ;
		}

		private void MoveToPrevPage()
		{
			if (ViewState["PrevPage"] != null)
			{
				Response.Redirect(ViewState["PrevPage"].ToString());
			}
		}

		#endregion

		#region ------------ Get Request Variables

		private int GetSelectedRemarkID_fromRequest()
		{
			if (this.Request["selectedRemarkID"] != null
				&& !string.IsNullOrEmpty(this.Request["selectedRemarkID"]))
			{
				int id = 0;
				int.TryParse(this.Request["selectedRemarkID"], out id);
				return id;
			}
			else
				return 0;
		}

		private string GetPrevPage_fromRequest()
		{
			if (Request["PrevPage"] != null && Request["PrevPage"].ToString() != String.Empty)
			{
				return Request["PrevPage"].ToString();
			}
			else
				return string.Empty;
		}

		private string GetRemarkType_fromRequest()
		{
			if (Request["remarkType"] != null && Request["remarkType"].ToString() != String.Empty)
			{
				return Request["remarkType"].ToString();
			}
			else
				return string.Empty;
		}

		#endregion

	}
}