using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.BusinessLayer.ObjectDataSource;

public partial class Admin_SelectEmployeeDeptsPopup : AdminPopupBasePage
{

    public int EmployeeRemarkID
    {
        get
        {
            if (ViewState["employeeRemarkID"] != null)
            {
                return Convert.ToInt32(ViewState["employeeRemarkID"]);
            }
            else
                return 0;
        }
        set
        {
            ViewState["employeeRemarkID"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        multiSelectList.OnConfirmClick += new EventHandler(multiSelectList_OnConfirmClick);
        multiSelectList.ValuesMustBeChosen = true;

        if (!IsPostBack)
        {
            EmployeeRemarkID = Convert.ToInt32(Request.QueryString["employeeRemarkID"]);

            if (!string.IsNullOrEmpty(Request.QueryString["returnValuesTo"]))
            {
                this.multiSelectList.WhereToReturnSelectedValues = Request.QueryString["returnValuesTo"].ToString();
            }

            if (!string.IsNullOrEmpty(Request.QueryString["returnTextTo"]))
            {
                this.multiSelectList.WhereToReturnSelectedText = Request.QueryString["returnTextTo"].ToString();
            }

            if (!string.IsNullOrEmpty(Request.QueryString["functionToExecute"]))
            {
                this.multiSelectList.FunctionToBeExecutedOnParent = Request.QueryString["functionToExecute"].ToString();
            }

            BindData();
        }
    }

    private void BindData()
    {
        DataSet ds;
        EmployeeBO bo = new EmployeeBO();
        
        string selectedCodes = Request.QueryString["selectedCodes"];


        ds = bo.GetRelatedDeptsForEmployeeRemark(EmployeeRemarkID);

        multiSelectList.TextField = "DeptName";
        multiSelectList.ValueField = "DeptCode";
        multiSelectList.DataSource = ds;
        multiSelectList.ShowAddProfessionsButton = false;

        
        if (!string.IsNullOrEmpty(selectedCodes))
        {
            multiSelectList.SelectedCodesList = SetGivenSelectedCodes(selectedCodes);
        }
        else
        {
            //multiSelectList.CheckedColumnName = "RemarkRelatedToDept";
        }

        multiSelectList.DataBind();
    }

    private List<int> SetGivenSelectedCodes(string delimitedCodes)
    {
        List<int> list = new List<int>();

        delimitedCodes = delimitedCodes.Replace(';', ',');

        string[] values = delimitedCodes.Split(',');

        for (int i = 0; i < values.Length; i++)
        {
            if (!string.IsNullOrEmpty(values[i]))
                list.Add(Convert.ToInt32(values[i]));
        }


        return list;
    }


    void multiSelectList_OnConfirmClick(object sender, EventArgs e)
    {
        SaveData();
    }

    private void SaveData()
    {
        List<int> listCodes = multiSelectList.SelectedCodesList;
    }
}
