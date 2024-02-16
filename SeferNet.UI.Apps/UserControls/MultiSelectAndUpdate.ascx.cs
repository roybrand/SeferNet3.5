using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Web.UI.HtmlControls;
using System.Text;
using System.Collections;
using Clalit.SeferNet.GeneratedEnums;

public partial class UserControls_MultiSelectAndUpdate : System.Web.UI.UserControl
{
	private bool m_showAddProfessionsButton;
	private string m_selectedItems = string.Empty;
	private string m_disabledItemsText = string.Empty;
	private string m_disabledItemsValues = string.Empty;
	private List<int> _selectedCodesList = null;
	private bool _valuesMustBeChosen = false;
    private int _selectedElementsMaxNumber = -1;
    private string _selectedElementsHebrewName = string.Empty;
	private DataSet dataSource;
	private int popupType;

	public event EventHandler OnAddFromFullListClick;
	public event EventHandler OnConfirmClick;

	#region Properties

    public int SelectedElementsMaxNumber
	{
		get
		{
            return _selectedElementsMaxNumber;
		}
		set
		{
            _selectedElementsMaxNumber = value;
		}
	}

    public string SelectedElementsHebrewName
	{
		get
		{
            return _selectedElementsHebrewName;
		}
		set
		{
            _selectedElementsHebrewName = value;
		}
	}

	public bool ValuesMustBeChosen
	{
		get
		{
			return _valuesMustBeChosen;
		}
		set
		{
			_valuesMustBeChosen = value;
		}
	}

	public List<int> SelectedCodesList
	{
		get
		{
			return _selectedCodesList;
		}
		set
		{
			_selectedCodesList = value;
		}
	}

	protected string DisabledItemsValues
	{
		get
		{
			return m_disabledItemsValues;
		}
	}

	protected string DisabledItemsText
	{
		get
		{
			return m_disabledItemsText;
		}
	}


	public bool IsSingleSelectMode
	{
		get
		{
			if (ViewState["IsSingleSelectMode"] != null)
				return bool.Parse(ViewState["IsSingleSelectMode"].ToString());
			else
				return false; ;
		}
		set
		{
			ViewState["IsSingleSelectMode"] = value;
		}
	}
	public string CheckBoxVisibilityField
	{
		get
		{
			if (ViewState["CheckBoxVisibilityField"] != null)
				return ViewState["CheckBoxVisibilityField"].ToString();
			else
				return null;
		}
		set
		{
			ViewState["CheckBoxVisibilityField"] = value;
		}
	}

	public string CheckedColumnField
	{
		get
		{
			if (ViewState["CheckedColumnField"] != null)
				return ViewState["CheckedColumnField"].ToString();
			else
				return null;
		}
		set
		{
			ViewState["CheckedColumnField"] = value;
		}
	}

	public string ParentCodeField
	{
		get
		{
			if (ViewState["ParentCodeField"] != null)
				return ViewState["ParentCodeField"].ToString();
			else
				return null;
		}
		set
		{
			ViewState["ParentCodeField"] = value;
		}
	}

	public string ValueField
	{
		get
		{
			if (ViewState["valueField"] != null)
				return ViewState["valueField"].ToString();
			else
				return null; 
		}
		set
		{
			ViewState["valueField"] = value;
		}
	}

	public string TextField
	{
		get
		{
			if (ViewState["textField"] != null)
				return ViewState["textField"].ToString();
			else
				return null;
		}
		set
		{
			ViewState["textField"] = value;
		}
	}

	/// <summary>
	/// gets or sets the column name that represents if to enable check box foreach item. 
	/// if the value in the column is "1" - the check box is read only.
	/// </summary>
	public string CheckBoxReadOnlyField
	{
		get
		{
			if (ViewState["checkBoxReadOnlyColumn"] != null)
				return ViewState["checkBoxReadOnlyColumn"].ToString();
			else
				return null;
		}
		set
		{
			ViewState["checkBoxReadOnlyColumn"] = value;
		}
	}

	public string ImageTypeField
	{
		get
		{
			if (ViewState["ImageTypeField"] != null)
				return ViewState["ImageTypeField"].ToString();
			else
				return null;
		}
		set
		{
			ViewState["ImageTypeField"] = value;
		}
	}

	public string SelectedValues
	{
		get
		{
			return this.SelectedCodes.Value;
		}
	}

	public DataSet DataSource
	{
		set
		{
			this.rptItems.DataSource = value;
		}
	}

	public bool ShowAddProfessionsButton
	{
		get
		{
			return m_showAddProfessionsButton;
		}
		set
		{
			m_showAddProfessionsButton = value;
		}
	}

	public string ButtonAddItemsText
	{
		get
		{
			return btnAddProfessions.Text;
		}
		set
		{
			btnAddProfessions.Text = value;
		}
	}

	public string WhereToReturnSelectedValues
	{
		get
		{
			if (ViewState["whereToReturnSelectedValues"] != null)
				return ViewState["whereToReturnSelectedValues"].ToString();
			else
				return null;
		}
		set
		{
			ViewState["whereToReturnSelectedValues"] = value;
			txtWhereToReturnSelectedValues.Text = value;
		}
	}

	public string WhereToReturnSelectedText
	{
		get
		{
			if (ViewState["whereToReturnSelectedText"] != null)
				return ViewState["whereToReturnSelectedText"].ToString();
			else
				return null;
		}
		set
		{
			ViewState["whereToReturnSelectedText"] = value;
			txtWhereToReturnSelectedText.Text = value;
		}
	}

	public string FunctionToBeExecutedOnParent
	{
		get
		{
			if (ViewState["FunctionToBeExecutedOnParent"] != null)
				return ViewState["FunctionToBeExecutedOnParent"].ToString();
			else
				return null;
		}
		set
		{
			ViewState["FunctionToBeExecutedOnParent"] = value;
			txtFunctionToBeExecutedOnParent.Text = value;
		}
	}
	
	public int PopupType
	{
		get
		{
			return this.popupType;
		}
		set
		{
			this.popupType = value;
		}
	}

	#endregion

	protected void Page_Load(object sender, EventArgs e)
	{
		//if (!IsPostBack)
		//{
		ViewState["MultiList"] = this.rptItems.DataSource;
		Page.Form.DefaultButton = btnOk.UniqueID;
		SetClientFucntion();
		if (IsSingleSelectMode)
		{
			tblBtnCheckAll.Visible = false;
		}

		hdnSelectedElementsMaxNumber.Value = SelectedElementsMaxNumber.ToString();
		hdnSelectedElementsHebrewName.Value = SelectedElementsHebrewName.ToString();
		//}

		//if (!ShowAddProfessionsButton)
		//{
		//	divButtonAdd.Visible = false;
		//}

		// Set session "SelectedCodes" to be read on "GetAllDataPopUp"
		Session["SelectedCodes"] = txtSelectedValues.Text;

		Page.ClientScript.RegisterStartupScript(this.GetType(), "BuildCheckedNamesAndCodes", "BuildCheckedNamesAndCodes();", true);

	}

	private void SetClientFucntion()
	{
		btnOk.Attributes.Add("onclick", String.Format("GetValues({0});", this.popupType));

		/*if (OnConfirmClick != null)
		{
			btnOk.Attributes.Add("onclick", "GetValues();");

			//if (txtWhereToReturnSelectedValues.Text != string.Empty)
			//{
			//	btnOk.Attributes.Add("onclick", "GetValues();");
			//}
			//else 
			//{ 
			//	btnOk.Attributes.Add("onclick", "GetValues_old();");			
			//}
		}
		else  // no server event registered
		{
			btnOk.Attributes.Add("onclick", "GetValues();");
			//if (txtWhereToReturnSelectedValues.Text != string.Empty)
			//{
			//	btnOk.Attributes.Add("onclick", "GetValues();");
			//}
			//else 
			//{
			//	btnOk.Attributes.Add("onclick", "GetValues_old();Close();");			
			//}
		}*/

		btnCancel.Attributes.Add("onclick", "SelectJQueryClose();");    // using Jquery dialog

		//if (txtWhereToReturnSelectedValues.Text != string.Empty) 
		//{
		//	btnCancel.Attributes.Add("onclick", "SelectJQueryClose();");	// using Jquery dialog
		//}
		//else 
		//{
		//	btnCancel.Attributes.Add("onclick", "window.close();return false;"); // modal dialog
		//}

		if (this.ParentCodeField == "districtCode")
		{
			txtSearch.Attributes.Remove("onkeyup");
			txtSearch.Attributes.Add("onkeyup", "SearchStringForCities(false);");
		}
	}

	protected void btnAddProfessions_Click(object sender, EventArgs e)
	{
		if (OnAddFromFullListClick != null)
		{
			OnAddFromFullListClick(this, EventArgs.Empty);
		}
	}


	// find how to not close and redirect inside the ascx page
	protected void btnOk_Click(object sender, EventArgs e)
	{
		if (OnConfirmClick != null)
		{
			OnConfirmClick(this, EventArgs.Empty);

			Page.ClientScript.RegisterStartupScript(this.GetType(), "close", "Close();", true);
		}

		Response.Redirect("UpdateEmployeeExpertProfession.aspx");
		//Response.Redirect("~/Admin/UpdateEmployee.aspx");
	}

	protected void rptItems_ItemDataBound(object sender, RepeaterItemEventArgs e)
	{

        Label ItemNameNoQuotes = e.Item.FindControl("ItemNameNoQuotes") as Label;
		Label ItemName = e.Item.FindControl("ItemName") as Label;
		HtmlInputHidden ItemCode = e.Item.FindControl("ItemCode") as HtmlInputHidden;
		//HtmlInputHidden ParentItemCode = e.Item.FindControl("ParentItemCode") as HtmlInputHidden;        
		HtmlInputCheckBox chkItem = e.Item.FindControl("chkItem") as HtmlInputCheckBox;
        Image imgServiceOrProf = e.Item.FindControl("imgServiceOrProf") as Image;
		Image imgItemType = e.Item.FindControl("imgAgreementType") as Image;

		DataRowView dataRow = e.Item.DataItem as DataRowView;
		bool hasParentCode = false;

		string textField = this.TextField;
		string valueField = this.ValueField;
		string checkBoxVisibField = this.CheckBoxVisibilityField;
		string checkBoxReadOnlyField = this.CheckBoxReadOnlyField;
		string imageTypeField = this.ImageTypeField;
	
		if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
		{
			chkItem.Attributes.Add("onclick", "OnCheckBoxClick('" + chkItem.ClientID + "');");

			ItemName.Text = dataRow[textField].ToString();
			ItemCode.Value = dataRow[valueField].ToString();// +"#" + dataRow[textFiel].ToString();

            
            ItemNameNoQuotes.Style.Add("display", "none");
            ItemNameNoQuotes.Text = dataRow[textField].ToString().Replace("\"", "#@#");
			//-------- Visible
			if (!string.IsNullOrEmpty(checkBoxVisibField) && dataRow.Row.Table.Columns.Contains(checkBoxVisibField))
			{
				chkItem.Visible = Convert.ToBoolean(dataRow[checkBoxVisibField]);
			}

			//-------- Disabled 
			if (!string.IsNullOrEmpty(checkBoxReadOnlyField) && dataRow.Row.Table.Columns.Contains(checkBoxReadOnlyField))
			{
				chkItem.Disabled = Convert.ToBoolean(dataRow[checkBoxReadOnlyField]);
			}

			//-------- Checked --- if we get the selected items from a specific list
			if (SelectedCodesList != null && SelectedCodesList.Count > 0)
			{
				if (SelectedCodesList.Contains(Convert.ToInt32(dataRow[valueField]))
					&& (string.IsNullOrEmpty(ParentCodeField)				 //get child item
					|| dataRow[this.ParentCodeField] != System.DBNull.Value))
				{
					chkItem.Checked = true;
				}
				else
				{
					chkItem.Checked = false;
				}
			}

			//------- Checked
			if (!string.IsNullOrEmpty(CheckedColumnField)
				&& dataRow.Row.Table.Columns.Contains(CheckedColumnField)
				&& dataRow[CheckedColumnField] != DBNull.Value)
			{
				chkItem.Checked = Convert.ToBoolean(dataRow[CheckedColumnField]);
			}

			//------- Image
			if (!string.IsNullOrEmpty(imageTypeField)
				&& dataRow.Row.Table.Columns.Contains(imageTypeField)
				&& dataRow[imageTypeField] != DBNull.Value)
			{
				eDIC_AgreementTypes agrType = (eDIC_AgreementTypes)Enum.ToObject( typeof(eDIC_AgreementTypes), (int)dataRow[imageTypeField] );
				UIHelper.SetImageSmallForAgreementType(agrType, imgItemType);
				imgItemType.Style.Add("display", "inline");
			}
			else
			{
                imgItemType.ImageUrl = "~/Images/vSign.gif";
                imgItemType.Style.Add("display", "none");
			}

            //------- ImageimgServiceOrProf
            if (this.ValueField == "ServiceCode")
            {
                if (dataRow["ServiceCategoryID"] != null && dataRow["ServiceCategoryID"].ToString() != string.Empty)
                {
                    if (Convert.ToInt32(dataRow["IsProfession"]) == 1)
                    {
                        imgServiceOrProf.ImageUrl = "~/Images/abc/Mem.gif";
                    }
                    else
                    {
                        imgServiceOrProf.ImageUrl = "~/Images/abc/Sheen.gif";
                    }
                }
                else
                {
                    imgServiceOrProf.Visible = false;
                }
            }
            else
            { 
                imgServiceOrProf.Visible = false;           
            }

			//------ disabled Items Values
			if (chkItem.Checked
				&& chkItem.Disabled)
			{
				m_disabledItemsValues += dataRow[valueField].ToString() + ",";
				m_disabledItemsText += dataRow[textField].ToString() + ",";
			}

			//------ Parent code
			if (this.ParentCodeField != null)
			{
				if (dataRow.Row.Table.Columns.Contains(this.ParentCodeField))
			
				if (dataRow[ParentCodeField] != DBNull.Value
					&& !string.IsNullOrEmpty(dataRow[ParentCodeField].ToString()))
				{
					chkItem.Attributes.Add("ParentItemCode", dataRow[ParentCodeField].ToString());
					hasParentCode = true;
				}
			}
			//------- this is one-level-tree - single list.
			else 
			{
				chkItem.Attributes.Add("ParentItemCode", "-10");
			}

			if (hasParentCode || chkItem.Visible == false)
			{
				((HtmlTableCell)e.Item.FindControl("tdFirst")).Style.Add("padding-right", "21px");
			}
		}

	}

	public void ShowNoResults()
	{
		divResults.Style.Add("display", "none");
		divNoResults.Style.Add("display", "block");
	}

	public void HideNoResults()
	{
		divResults.Style.Add("display", "block");
		divNoResults.Style.Add("display", "none");
	}

}

