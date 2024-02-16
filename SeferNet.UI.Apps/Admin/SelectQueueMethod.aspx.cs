using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Data;
using System.Text;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;

public partial class Admin_SelectQueueMethod : AdminPopupBasePage
{

    ReceptionHoursManager _receptionManager = new ReceptionHoursManager();
    bool _validationExecuted = false;
    SessionParams sessionParams;

    #region Properties

    public int ServiceID
    {
        get
        {
            return (int)ViewState["ServiceID"];
        }

        set
        {
            ViewState["ServiceID"] = value;
        }
    }

    public int DeptEmployeeID 
    {
        get
        {
            return (int)ViewState["DeptEmployeeID"];
        }
        set
        {
            ViewState["DeptEmployeeID"] = value;
        }
    }

    public int DeptCode
    {
        get
        {
            return (int)ViewState["DeptCode"];
        }
        set
        {
            ViewState["DeptCode"] = value;
        }
    }

    public int x_Dept_Employee_ServiceID
    {
        get
        {
            return (int)ViewState["x_Dept_Employee_ServiceID"];
        }
        set
        {
            ViewState["x_Dept_Employee_ServiceID"] = value;
        }
    }

    public string DeptPhone
    {
        get
        {
            if (ViewState["deptPhone"] != null)
            {
                return ViewState["deptPhone"].ToString();
            }
            else
            {
                return string.Empty;
            }
        }

        set
        {
            ViewState["deptPhone"] = value;
        }
    }

    public DataTable SelectedQueueOrderHoursDt
    {
        get
        {

                if (ViewState["SelectedQueueOrderHours"] != null)
                    return (DataTable)ViewState["SelectedQueueOrderHours"];
                else
                    return null;
        }

    }

    private DataTable SelectedQueueOrderMethodsDt
    {
        get
        {
            if (ViewState["SelectedQueueOrderMethods"] != null)
                return (DataTable)ViewState["SelectedQueueOrderMethods"];
            else
                return null;
        }
        set
        {
            ViewState["SelectedQueueOrderMethods"] = value;
        }

    }

    public DataTable AllQueueOrderMethodsDt
    {
        get
        {
            if (ViewState["AllQueueOrderMethods"] != null)
                return (DataTable)ViewState["AllQueueOrderMethods"];
            else
                return null;
        }

        set
        {
            ViewState["AllQueueOrderMethods"] = value;
        }
    }

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            GetQueryString();
            BindQueueOrderMethods();
        }
    }

    private void GetQueryString()
    {
        DeptCode = DeptEmployeeID = ServiceID = x_Dept_Employee_ServiceID = 0;

        if (!string.IsNullOrEmpty(Request.QueryString["DeptCode"]))
        {
            DeptCode = Convert.ToInt32(Request.QueryString["DeptCode"]);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["DeptEmployeeID"]))
        {
            DeptEmployeeID = Convert.ToInt32(Request.QueryString["DeptEmployeeID"]);
        }
        

        if (!string.IsNullOrEmpty(Request.QueryString["ServiceID"]))
        {
            ServiceID = Convert.ToInt32(Request.QueryString["ServiceID"]);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["x_Dept_Employee_ServiceID"]))
        {
            x_Dept_Employee_ServiceID = Convert.ToInt32(Request.QueryString["x_Dept_Employee_ServiceID"]);
        }
    }

    private void BindQueueOrderMethods()
    {
        QueueOrderMethodBO bo = new QueueOrderMethodBO();

        // bind queue order radio button list
        DataSet ds = bo.GetDicQueueOrderMethods();

        DataTable dtQueueOrder = ds.Tables["QueueOrder"];
        AllQueueOrderMethodsDt = ds.Tables["QueueOrderMethods"];
        string selectedMethodID = string.Empty;

        rbList.DataSource = dtQueueOrder;
        rbList.DataTextField = "QueueOrderDescription";
        rbList.DataValueField = "QueueOrder";
        rbList.DataBind();

        // save dept phone anyway        
        DeptBO deptBo = new DeptBO();
        if (DeptCode == 0)
        {
            sessionParams = SessionParamsHandler.GetSessionParams();
            DeptPhone = deptBo.GetMainDeptPhone(sessionParams.DeptCode);
        }
        else
            DeptPhone = deptBo.GetMainDeptPhone(DeptCode);

        // employee queue order is requested
        if (DeptEmployeeID != 0)  
        {
            ds = bo.GetEmployeeInDeptQueueOrderMethods(DeptEmployeeID);
            if (DeptPhone == string.Empty)
                DeptPhone = deptBo.GetMainDeptPhoneByDeptEmployeeID(DeptEmployeeID);
        }
        else          
        {
             // dept queue order is requested
            if(DeptCode != 0)
            {
                ds = bo.GetDeptQueueOrderMethods(DeptCode);
            }

            else
            {
                ds = bo.GetEmployeeServiceQueueOrderMethods(x_Dept_Employee_ServiceID);
            }

        }
        
        queueHoursControl.dtOriginalData = ds.Tables[1].Copy();

        _receptionManager.GenerateHoursGridTable(ds.Tables[1]);
        queueHoursControl.SourceData = ds.Tables[1];
        queueHoursControl.DataBind();


        rbList.SelectedIndex = -1;

        SelectedQueueOrderMethodsDt = ds.Tables[0];
        if (ds.Tables[0].Rows.Count > 0)
        {

            selectedMethodID = ds.Tables[0].Rows[0]["QueueOrder"].ToString();

            rbList.SelectedValue = selectedMethodID;
        }

        rptQueueOrderMethods.Visible = (rbList.SelectedValue == "3");

        if (rbList.SelectedIndex == -1)
        {
            btnSave.Enabled = false;
        }

        
        // bind queue order methods checkbox list
        rptQueueOrderMethods.DataSource = AllQueueOrderMethodsDt;
        rptQueueOrderMethods.DataBind();


    }


    protected void rptQueueOrderMethods_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        DataRowView row = e.Item.DataItem as DataRowView;
        Label lblPhone = e.Item.FindControl("lblPhone") as Label;

        CheckBox chk = e.Item.FindControl("chkQueueOrderMethod") as CheckBox;
        chk.Text = row["QueueOrderMethodDescription"].ToString();

        // set hidden value
        HiddenField hiddenValue = e.Item.FindControl("hiddenValue") as HiddenField;
        hiddenValue.Value = row["QueueOrderMethod"].ToString();


        if (SelectedQueueOrderMethodsDt != null)
        {
            if (SelectedQueueOrderMethodsDt.Select("QueueOrderMethod=" + row["QueueOrderMethod"]).Length > 0)
            {
                chk.Checked = true;
            }
        }


        if (row["ShowPhonePicture"].ToString() == "1")
        {
            if (row["SpecialPhoneNumberRequired"].ToString() == "1") // special phone
            {
                Panel pnlPhone = e.Item.FindControl("pnlSpecialNumber") as Panel;
                pnlPhone.Visible = true;
                chk.Attributes.Add("onclick", "ToggleDivHours(this);");

                UserControls_PhonesGridUC phone = e.Item.FindControl("phoneUC") as UserControls_PhonesGridUC;
                phone.EnableAdding = false;
                phone.EnableBlankData = true;
                phone.EnableDeleting = false;

                DataTable sourceDt = new DataTable();
                Phone.CreateTableStructure(ref sourceDt);

                if (chk.Checked)
                {
                    pnlPhone.Style.Add("display", "block");
                    hiddenDivHoursStyle.Value = "block";
                    divHours.Style.Add("display", "block");
                    sourceDt.ImportRow(SelectedQueueOrderMethodsDt.Select("QueueOrderMethod=" + row["QueueOrderMethod"])[0]);
                    phone.SourcePhones = sourceDt;
                    ViewState["enableValidators"] = true;
                }
                else
                {
                    sourceDt.Rows.Add(sourceDt.NewRow());
                    phone.SourcePhones = sourceDt;
                    divHours.Style.Add("display", "none");
                    hiddenDivHoursStyle.Value = "none";
                    DisableValidators();
                    ViewState["enableValidators"] = false;
                }
            }
            else
            {
                if (!string.IsNullOrEmpty(DeptPhone))
                {
                    lblPhone.Visible = true;
                    lblPhone.Text = DeptPhone;
                }
                else
                {
                    chk.Checked = false;
                    chk.Enabled = false;
                }
            }
        }
    }

    protected void rbList_SelectedIndexChanged(object sender, EventArgs e)
    {
        btnSave.Enabled = true;
        rptQueueOrderMethods.Visible = rbList.SelectedValue == "3";
        
        divHours.Style["display"] = "none";
        if (rbList.SelectedValue == "3")
        {
            divHours.Style["display"] = hiddenDivHoursStyle.Value;
            if (ViewState["enableValidators"] != null)
            {
                if ((bool)ViewState["enableValidators"] == false)
                {
                    DisableValidators();
                }
            }
        }
    }

    private void DisableValidators()
    {
        ClientScript.RegisterStartupScript(this.GetType(), "validators", "DisableValidators();", true);
    }
    
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            int queueOrderMethodID;
            HiddenField hiddenValue;
            string selectedText = string.Empty;
            int selectedMethod = Convert.ToInt32(rbList.SelectedValue);

            if (SelectedQueueOrderMethodsDt != null)
            {
                SelectedQueueOrderMethodsDt.Clear();
            }

            if (selectedMethod == 3)
            {
                foreach (RepeaterItem item in rptQueueOrderMethods.Items)
                {

                    CheckBox chkItem = item.FindControl("chkQueueOrderMethod") as CheckBox;
                    UserControls_PhonesGridUC phone = item.FindControl("phoneUC") as UserControls_PhonesGridUC;

                    if (chkItem.Checked)
                    {
                        DataRow newRow = SelectedQueueOrderMethodsDt.NewRow();

                        Label lblPhone = (Label)item.FindControl("lblPhone");
                        if (lblPhone.Visible)
                        {
                            newRow["deptPhone"] = lblPhone.Text;
                            selectedText += lblPhone.Text + " , ";
                        }
                        else
                        {
                            selectedText += chkItem.Text + " , ";
                        }



                        if (item.FindControl("pnlSpecialNumber").Visible)
                        {
                            // validate the phone control
                            if (!Page.IsValid)
                            {
                                hiddenDivHoursStyle.Value = "block";
                                divHours.Style.Add("display", "block");
                                return;
                            }
                            else
                            {
                                SaveSpecialPhone(ref newRow, phone.ReturnData());
                                selectedText += phone.ReturnPhoneNumber(newRow) + " , ";
                            }
                        }

                        hiddenValue = item.FindControl("hiddenValue") as HiddenField;
                        queueOrderMethodID = Convert.ToInt32(hiddenValue.Value);
                        newRow["QueueOrderMethod"] = queueOrderMethodID;

                        SelectedQueueOrderMethodsDt.Rows.Add(newRow);
                    }
                    else
                    {
                        phone.EnableBlankData = true;
                    }
                }
                selectedText = selectedText.Substring(0, selectedText.Length - 2);
            }
            else
            {
                selectedText = rbList.SelectedItem.Text;

            }


            // save queue order methods 
            SaveQueueOrderMethods(selectedMethod);

            string returnStr = "text = '" + selectedText + "';" +
                               "window.returnValue = text;" +
                               "self.close();";

            string str = "";
            if (DeptEmployeeID != 0) { 
                str += "parent.SetQueueEmployeeInClinic('" + selectedText + "');";
            }

            if (x_Dept_Employee_ServiceID != 0) { 
                str += "parent.SetQueueEmployeeServiceInClinic();";
            }

            if (DeptCode != 0) { 
                str += "parent.SetQueueInClinic('" + selectedText + "');";
            }

            str += "SelectJQueryClose();";

            // Two methods - temporarily
            if (DeptEmployeeID != 0 || x_Dept_Employee_ServiceID != 0 || DeptCode != 0)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "close", str, true);
            }
            else 
            {
                ClientScript.RegisterStartupScript(this.GetType(), "close", returnStr, true);
            }

        }
    }


    private void SaveQueueOrderMethods(int selectedQueueOrderMethod)
    {
        UserInfo currentUser = Session["currentUser"] as UserInfo;
        QueueOrderMethodBO bo = new QueueOrderMethodBO();
        DataSet ds = new DataSet();
        bool result;
        SelectedQueueOrderMethodsDt.TableName = "Methods";
        ds.Tables.Add(SelectedQueueOrderMethodsDt);
        sessionParams = SessionParamsHandler.GetSessionParams();

        if (hiddenDivHoursStyle.Value == "block")
        {
            DataTable hoursDt = queueHoursControl.ReturnData();
            hoursDt.TableName = "hours";
            ds.Tables.Add(hoursDt);
        }
        
        if (DeptEmployeeID != 0)  // employee queue order
        {
            result = bo.UpdateEmployeeQueueOrderMethods(DeptEmployeeID, selectedQueueOrderMethod, ds, currentUser.UserNameWithPrefix);
            if (result)
            {
                UserManager userManager = new UserManager();

                userManager.Insert_LogChange((int)SeferNet.Globals.Enums.ChangeType.EmployeeInClinicQueueOrder_Update, currentUser.UserID, sessionParams.DeptCode, null, DeptEmployeeID, null, null, null, null);
            }
        }
        else
        {
            if (ServiceID != 0)  // Service queue order
            {
                bo.UpdateServiceQueueOrderMethods(ServiceID, DeptCode, selectedQueueOrderMethod, ds, currentUser.UserNameWithPrefix);
            }
            else if (DeptCode != 0)   // dept queue order
            {
                bo.UpdateDeptQueueOrderMethods(DeptCode, selectedQueueOrderMethod, ds, currentUser.UserNameWithPrefix);
            }
            else 
            {
                bo.UpdateEmployeeServiceQueueOrderMethods(x_Dept_Employee_ServiceID, selectedQueueOrderMethod, ds, currentUser.UserNameWithPrefix);
            }
        }
    }

    private void SaveSpecialPhone(ref DataRow newRow, DataTable dt)
    {
        if (dt.Rows.Count > 0)
        {
            DataRow existRow = dt.Rows[0];
            newRow["prePrefix"] = existRow["prePrefix"];
            newRow["prefixCode"] = existRow["prefixCode"];
            newRow["prefixText"] = existRow["prefixText"];
            newRow["Phone"] = existRow["Phone"];
            newRow["extension"] = existRow["extension"];
        }
    }

    protected void vldQueueMethod_ServerValidate(object sender, ServerValidateEventArgs e)
    {
        if (rptQueueOrderMethods.Visible)
        {
            bool checkedItem = false;

            foreach (RepeaterItem item in rptQueueOrderMethods.Items)
            {
                CheckBox currCheckbox = item.FindControl("chkQueueOrderMethod") as CheckBox;
                if (currCheckbox.Checked)
                {
                    checkedItem = true;
                }

                if (item.FindControl("pnlSpecialNumber").Visible)
                {
                    // phone control
                    if (currCheckbox.Checked)
                    {
                        //if (!_validationExecuted)
                        //{
                        //    _validationExecuted = true;
                        //    Page.Validate();
                            
                        //}

                        hiddenDivHoursStyle.Value = "block";
                        divHours.Style.Add("display", "block");
                    }
                    else
                    {
                        hiddenDivHoursStyle.Value = "none";
                        divHours.Style.Add("display", "none");
                    }
                }
            }

            e.IsValid = checkedItem;
        }
        
    }
}
