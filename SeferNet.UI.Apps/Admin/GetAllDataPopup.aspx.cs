using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Data;
using SeferNet.FacadeLayer;

public partial class Admin_GetAllDataPopup : AdminPopupBasePage
{
	private long m_employeeID;
	private int m_deptCode;	
    private PopupType m_popupType;
    private DataSet ds;

    protected void Page_Load(object sender, EventArgs e)
	{
		GetQueryString();

		if (!IsPostBack)
		{
			BindDataByType();
		}

        if(m_popupType != PopupType.MedicalAspects)
		    multiSelectList.OnConfirmClick += new EventHandler(multiSelectList_OnConfirmClick);
	}


	private void BindDataByType()
	{
		switch (m_popupType)
		{
			case PopupType.Positions:
				break;

            case PopupType.Professions:
                this.GetProfessionsForEmployee();
                break;

			case PopupType.Services:
				this.GetServicesForEmployee();
				break;

			case PopupType.Languages:
				this.GetLanuguaegsForEmployee();
				break;

            case PopupType.Expertise:
                this.GetExpertiseForEmployee();
                break;

			case PopupType.MedicalAspects:
                this.GetMedicalAspects();
				break;

			default:
				break;
		}

        DataColumnCollection columns = ds.Tables[ds.Tables.Count - 1].Columns;
        if (columns.Contains("SelectedElementsMaxNumber"))
        {
            this.multiSelectList.SelectedElementsMaxNumber = Convert.ToInt32(ds.Tables[ds.Tables.Count - 1].Rows[0]["SelectedElementsMaxNumber"]);
            this.multiSelectList.SelectedElementsHebrewName = ds.Tables[ds.Tables.Count - 1].Rows[0]["NameToShowInHebrew"].ToString();
        }
        else
        {
            this.multiSelectList.SelectedElementsMaxNumber = -1;
            this.multiSelectList.SelectedElementsHebrewName = string.Empty;
        }

	}


	private void BindTree(ref DataSet ds, string textField, string valueField, string parentCodeField, string checkedField, string readOnlyCheckField)
	{
		this.multiSelectList.DataSource = ds;
		this.multiSelectList.TextField = textField;
		this.multiSelectList.ValueField = valueField;
		this.multiSelectList.ParentCodeField = parentCodeField;
		this.multiSelectList.CheckedColumnField = checkedField;

		this.multiSelectList.SelectedCodesList = SetCodesFromQS();
		
		if (!string.IsNullOrEmpty(readOnlyCheckField))
		{
			this.multiSelectList.CheckBoxReadOnlyField = readOnlyCheckField;
		}
		this.multiSelectList.DataBind();

		// save the initial selected values
		this.ViewState["selectedValues"] = this.multiSelectList.SelectedValues;

	}

	private List<int> SetCodesFromQS()
	{
		List<int> list = null;

		if (!string.IsNullOrEmpty(Request.QueryString["SelectedCodes"]))
		{
			list = new List<int>();

			string[] values = Request.QueryString["SelectedCodes"].Trim().Split(',');

			for (int i = 0; i < values.Length; i++)
			{
				if (!string.IsNullOrEmpty(values[i]))
					list.Add(Convert.ToInt32(values[i]));
			}
		}

		return list;
	}

    private void GetExpertiseForEmployee()
    {
        EmployeeProfessionBO bo = new EmployeeProfessionBO();
        ds = bo.GetEmployeeProfessionsExtended(m_employeeID, -1, true, true);

        UserInfo user = HttpContext.Current.Session["currentUser"] as UserInfo;

        this.multiSelectList.ImageTypeField = "AgreementType";

        if (user.IsAdministrator)
        {
            BindTree(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "ExpertProfession", string.Empty);
        }
        else
        { 
            BindTree(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "ExpertProfession", "ExpertProfession");
        }

        Page.Title = "מומחיות לנותן שירות";
        lblMainHeader.Text = "הגדרת מומחיות לנותן שירות";
        lblHeader.Text = "ניתן לבחור מומחיות אחת או יותר מהרשימה";
    }

	private void GetServicesForEmployee()
	{
		EmployeeServiceInDeptBO bo = new EmployeeServiceInDeptBO();
		ds = bo.GetEmployeeServicesExtended((int)m_employeeID, -1, -1, false, true);
		this.multiSelectList.ImageTypeField = "AgreementType";
		BindTree(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "LinkedToEmployee", "LinkedToEmployeeInDept");

        //if (ds.Tables[1] != null)
        //{
        //    this.multiSelectList.SelectedElementsMaxNumber = Convert.ToInt32( ds.Tables[1].Rows[0]["SelectedElementsMaxNumber"]);
        //    this.multiSelectList.SelectedElementsHebrewName = ds.Tables[1].Rows[0]["NameToShowInHebrew"].ToString();
        //}

        Page.Title = "שירותים לנותן שירות";
        lblMainHeader.Text = "הגדרת שירותים לנותן שירות";
		lblHeader.Text = "ניתן לבחור שירות אחד או יותר מהרשימה";
	}

    private void GetMedicalAspects()
	{
		EmployeeServiceInDeptBO bo = new EmployeeServiceInDeptBO();
        //public DataSet GetEmployeeServicesExtended(int m_empCode, int m_deptCode, bool IsLinkedToEmployeeOnly, bool? isService)
        //public DataSet GetMedicalAspects(int? deptCode, bool isLinkedToDeptOnly, bool? isService)
        ds = bo.GetMedicalAspects((int)m_deptCode, false, null);
		this.multiSelectList.ImageTypeField = "AgreementType";
		BindTree(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "LinkedToEmployee", "LinkedToEmployeeInDept");

        Page.Title = "היבטים למרפאה";
        lblMainHeader.Text = "הגדרת היבטים למרפאה";
        lblHeader.Text = "ניתן לבחור היבט אחד או יותר מהרשימה";
	}

	private void GetLanuguaegsForEmployee()
	{
		EmployeeLanguagesBO bo = new EmployeeLanguagesBO();
		ds = bo.GetLanguagesForEmployeeExtended(m_employeeID);

		BindTree(ref ds, "LanguageDescription", "LanguageCode", null, "LinkedToEmployee", null);

        Page.Title = "שפות לנותן שירות";
        lblMainHeader.Text = "הגדרת שפות לנותן שירות";
		lblHeader.Text = "ניתן לבחור שפה אחת או יותר מהרשימה";
	}

    private void GetProfessionsForEmployee()
    {
        EmployeeProfessionBO bo = new EmployeeProfessionBO();
        ds = bo.GetEmployeeProfessionsExtended(m_employeeID, -1, false, false);

        this.multiSelectList.ImageTypeField = "AgreementType";
        BindTree(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "LinkedToEmployee", "LinkedToEmployeeInDeptOrExpert");

        Page.Title = "מקצועות לנותן שירות";
        lblMainHeader.Text = "הגדרת מקצועות לנותן שירות";
        lblHeader.Text = "ניתן לבחור מקצוע אחד או יותר מהרשימה";
    }

	void multiSelectList_OnConfirmClick(object sender, EventArgs e)
	{
		UpdateSelectedItemsInDB(multiSelectList.SelectedValues);
	}

	private void UpdateSelectedItemsInDB(string selectedValues)
	{
		EmployeeProfessionBO professionsBo = new EmployeeProfessionBO();
		UserInfo user = HttpContext.Current.Session["currentUser"] as UserInfo;
		string userName = user.UserNameWithPrefix;

		if (selectedValues == string.Empty)
		{
			selectedValues = Session["SelectedCodes"].ToString();
			Session["SelectedCodes"] = null;
		}


		switch (m_popupType)
		{
			case PopupType.Professions:
				Facade.getFacadeObject().UpdateEmployeeProfessions(m_employeeID, selectedValues);

				Session["EmployeeID_ToUpdateExpertProfessions"] = m_employeeID;
				Session["EmployeExperteProfessions_SelectedValuesToUpdate"] = selectedValues;
				break;

			case PopupType.Services:
				EmployeeServicesBO servicesBo = new EmployeeServicesBO();
				servicesBo.DeleteAllEmployeeServicesAndInsert(m_employeeID, selectedValues, userName);
				break;

			case PopupType.Languages:
				EmployeeLanguagesBO langBo = new EmployeeLanguagesBO();
				langBo.DeleteAllLanguagesAndInsert(m_employeeID, selectedValues, userName);
				break;

			case PopupType.Expertise:
				Session["EmployeeID_ToUpdateExpertProfessions"] = m_employeeID;
				Session["EmployeExperteProfessions_SelectedValuesToUpdate"] = selectedValues;
				//professionsBo.UpdateEmployeeExpertise(m_employeeID, selectedValues, userName);
				break;
			default:
				break;
		}
	}

	private string GetProfessionsToDelete(string selectedValues)
	{
		string originalSelectedValues = ViewState["selectedValues"].ToString();  // get original selected values

		string[] originalArr = originalSelectedValues.Split(',');
		string[] newArr = selectedValues.Split(',');
		string valuesToDelete = string.Empty;

		for (int i = 0; i < originalArr.Length; i++)   // check if the original value is still selected
		{
			if (!newArr.Contains(originalArr[i]))
			{
				valuesToDelete += originalArr[i] + ",";
			}
		}

		return valuesToDelete;
	}

	private void GetQueryString()
	{
		if (Request.QueryString["employeeID"] != null)
		{
			m_employeeID = Convert.ToInt64(Request.QueryString["employeeID"]);
		}

		if (Request.QueryString["deptCode"] != null)
		{
            m_deptCode = Convert.ToInt32(Request.QueryString["deptCode"]);
		}

		if (Request.QueryString["popupType"] != null)
		{
			m_popupType = (PopupType)Enum.Parse(typeof(PopupType), Request.QueryString["popupType"]);
			this.multiSelectList.PopupType = (int)m_popupType;
		}

		if (!string.IsNullOrEmpty(Request.QueryString["returnValuesTo"]))
		{
			this.multiSelectList.WhereToReturnSelectedValues = Request.QueryString["returnValuesTo"].ToString();
			this.multiSelectList.WhereToReturnSelectedText = Request.QueryString["returnTextTo"].ToString();
		}

		if (!string.IsNullOrEmpty(Request.QueryString["functionToExecute"]))
		{
			this.multiSelectList.FunctionToBeExecutedOnParent = Request.QueryString["functionToExecute"].ToString();
		}
	}
}
