using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Data;
using SeferNet.FacadeLayer;
using SeferNet.UI;
using SeferNet.BusinessLayer.BusinessObject;
using System.Text;

public partial class Admin_UpdateEmployeeDataPopup : AdminPopupBasePage
{
    private int m_employeeID;
    private int m_deptCode;
    private int m_deptEmployeeID;
    private PopupType m_popupType;
    private EmployeeProfessionBO bo = new EmployeeProfessionBO();
    private Facade facade = Facade.getFacadeObject();

    protected void Page_Load(object sender, EventArgs e)
    {
        BindDataByDemand();
    }

    private void BindDataByDemand()
    {
        GetQueryString();

        switch (m_popupType)
        {
            case PopupType.Positions:
                HandleEmployeePositions();
                break;

            case PopupType.Services:
                HandleEmployeeServices();
                break;

            default:
                this.multiSelectList.ShowNoResults();
                break;
        }
    }

    private void HandleEmployeeServices()
    {
        if (!IsPostBack)
        {
            lblHeader.Text = "ניתן לבחור שירות אחד או יותר מהרשימה";
            Page.Title = "בחירת שירותים";
            lblMainHeader.Text = "הגדרת שירותים לרופא";
            this.multiSelectList.ButtonAddItemsText = "הוספת שירותים לרשימת השירותים";

            this.GetEmployeeServices(true);
        }
        this.multiSelectList.OnConfirmClick += new EventHandler(multiSelectList_OnConfirmClick);
        this.multiSelectList.ShowAddProfessionsButton = true;
        this.multiSelectList.OnAddFromFullListClick += new EventHandler(multiSelectList_OnAddProfessionsClick);
    }

    private void HandleEmployeePositions()
    {
        if (!IsPostBack)
        {
            lblHeader.Text = "ניתן לבחור תפקיד אחד או יותר מהרשימה";
            Page.Title = "בחירת תפקידים";
            lblMainHeader.Text = "הגדרת תפקידים לרופא";
            this.multiSelectList.CheckedColumnField = "linkedToEmpInDept";

            GetEmployeePositions();
        }
        this.multiSelectList.OnConfirmClick += new EventHandler(multiSelectList_OnConfirmClick);
        this.multiSelectList.ShowAddProfessionsButton = false;
    }

    private void GetEmployeePositions()
    {
        EmployeePositionsBO bo = new EmployeePositionsBO();
        DataSet ds = bo.GetEmployeePositionsInDept(m_deptEmployeeID);

        BindTreeView(ref ds, "positionDescription", "positionCode", null, "linkedToEmpInDept", null); // toDo: fix
    }

    private void GetEmployeeServices(bool IsLinkedToEmployeeOnly)
    {
        EmployeeServiceInDeptBO bo = new EmployeeServiceInDeptBO();
        DataSet ds = bo.GetEmployeeServicesExtended(m_employeeID, m_deptCode, m_deptEmployeeID, IsLinkedToEmployeeOnly, null);

        this.multiSelectList.ImageTypeField = "AgreementType";
        BindTreeView(ref ds, "ServiceDescription", "ServiceCode", "ServiceCategoryID", "LinkedToEmployeeInDept", "LinkedToEmployeeInDept"); // fixed

        DataRow[] selectedRows = ds.Tables[0].Select("LinkedToEmployeeInDept = 1");

        string ServiceSeparatedValuesBefore = string.Empty;

        for (int i = 0; i < selectedRows.Length; i++)
        {
            ServiceSeparatedValuesBefore += selectedRows[i]["ServiceCode"].ToString() + ',';
        }
        ViewState["ServiceSeparatedValuesBefore"] = ServiceSeparatedValuesBefore;

    }

    protected void multiSelectList_OnConfirmClick(object sender, EventArgs e)
    {
        UserInfo user = HttpContext.Current.Session["currentUser"] as UserInfo;

        UpdateNewSelectionsInDB(this.multiSelectList.SelectedValues, user.UserNameWithPrefix, user.UserID);
    }

    private void UpdateNewSelectionsInDB(string seperatedValues, string userName, long UserID)
    {
        bool result = false;

        switch (m_popupType)
        {
            case PopupType.Positions:

                facade.UpdateEmployeePositionsInDept(m_employeeID, m_deptCode, m_deptEmployeeID, seperatedValues, userName);
                break;

            case PopupType.Services:
                result = facade.UpdateEmployeeServicesInDept(m_deptEmployeeID, seperatedValues, userName, m_deptCode);

                if (result)
                { 
                    if(ViewState["ServiceSeparatedValuesBefore"] != null)
                    {
                        string[] ServiceSeparatedValuesBefore = ViewState["ServiceSeparatedValuesBefore"].ToString().Split(',');
                        string[] ServiceSeparatedValuesAfter = seperatedValues.Split(',');
                        for(int i=0; i < ServiceSeparatedValuesAfter.Count(); i++)
                        {
                            string newServiceCode =  ServiceSeparatedValuesAfter[i];

                            for(int ii=0; ii < ServiceSeparatedValuesBefore.Count(); ii++)
                            {
                                if(ServiceSeparatedValuesAfter[i] == ServiceSeparatedValuesBefore[ii])
                                {
                                    newServiceCode = string.Empty;
                                }
                            }

                            if(newServiceCode != string.Empty)
                                facade.Insert_LogChange((int)SeferNet.Globals.Enums.ChangeType.EmployeeInClinicService_Add, UserID, m_deptCode, null, m_deptEmployeeID, -1, null, Convert.ToInt32(newServiceCode), null);

                        }
                    }
                }

                break;

            default:
                break;
        }
    }

    private string GenerateReturnValueString(string text, string value)
    {
        string str;

        str = "var obj = new Object(); " +
              "obj.Text = '" + text + "';" +
              "obj.Value = '" + value + "';" +
              "window.returnValue = obj;" +
              "window.close();";
        return str;
    }

    private bool GetQueryString()
    {
        try
        {
            if (int.TryParse(Request.QueryString["employeeID"], out m_employeeID))
            {
                m_deptCode = Convert.ToInt32(Request.QueryString["deptcode"]);
                m_popupType = (PopupType)Enum.Parse(typeof(PopupType), Request.QueryString["popupType"]);

                int.TryParse(Request.QueryString["deptEmployeeID"], out m_deptEmployeeID);
            }
            else
            {
                return false;
            }
        }
        catch
        {
            return false;
        }

        return true;

    }

    private void BindTreeView(ref DataSet ds, string textField, string valueField, string parentCodeField, string checkedField, string readOnlyCheckField)
    {
        if (ds != null && ds.Tables[0].Rows.Count > 0)
        {
            this.multiSelectList.DataSource = ds;
            this.multiSelectList.TextField = textField;
            this.multiSelectList.ValueField = valueField;
            this.multiSelectList.ParentCodeField = parentCodeField;
            this.multiSelectList.CheckedColumnField = checkedField;
            this.multiSelectList.CheckBoxReadOnlyField = readOnlyCheckField;

            this.multiSelectList.DataBind();
            this.multiSelectList.HideNoResults();
        }
        else
        {
            this.multiSelectList.ShowNoResults();
            lblHeader.Visible = false;
        }
    }

    protected void multiSelectList_OnAddProfessionsClick(object sender, EventArgs e)
    {
        GetQueryString();

        lblHeader.Visible = true;

        switch (m_popupType)
        {
            case PopupType.Services:
                this.GetEmployeeServices(false);
                break;
        }
    }
}
