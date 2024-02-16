using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Data;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.FacadeLayer;
using SeferNet.Globals;

public partial class Admin_UpdateStatus : AdminPopupBasePage
{

    public int DeptCode
    {
        get
        {
            if (ViewState["deptCode"] != null)
            {
                return (int)ViewState["deptCode"];
            }
            return 0;
        }
        set
        {
            ViewState["deptCode"] = value;
        }
    }
    public long EmployeeID
    {
        get
        {
            if (ViewState["employeeID"] != null)
            {
                return (long)ViewState["employeeID"];
            }
            return 0;
        }
        set
        {
            ViewState["employeeID"] = value;
        }
    }

    public int DeptEmployeeID
    {
        get
        {
            if (ViewState["deptEmployeeID"] != null)
            {
                return (int)ViewState["deptEmployeeID"];
            }
            return 0;
        }
        set
        {
            ViewState["deptEmployeeID"] = value;
        }
    }


    public int AgreementType
    {
        get
        {
            if (ViewState["agreementType"] != null)
            {
                return (int)ViewState["agreementType"];
            }
            return 0;
        }
        set
        {
            ViewState["agreementType"] = value;
        }
    }
    public int ServiceCode
    {
        get
        {
            if (ViewState["serviceCode"] != null)
            {
                return (int)ViewState["serviceCode"];
            }
            return 0;
        }
        set
        {
            ViewState["serviceCode"] = value;
        }
    }
    private DateTime? _notActiveDate;
    private DataTable StatusTable
    {
        get
        {
            if (ViewState["statusTable"] != null)
            {
                return (DataTable)ViewState["statusTable"];
            }
            return null;
        }

        set
        {
            ViewState["statusTable"] = value;
        }
    }
    private bool _changesHasBeenMade;
    private Enums.EntityTypesStatus currentUpdatedEntity
    {
        get
        {
            return (Enums.EntityTypesStatus)ViewState["currentUpdatedEntity"];
        }
        set
        {
            ViewState["currentUpdatedEntity"] = value;
        }


    }

    protected bool CurrentStatusIsActive
    {
        get
        {
            if (ViewState["currentStatus"] != null)
            {
                return (bool)ViewState["currentStatus"];
            }
            return false;
        }

        set
        {
            ViewState["currentStatus"] = value;
        }
    }



    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            _changesHasBeenMade = false;
            GetQueryString();
            BindData();
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (_changesHasBeenMade)
        {
            btnSaveDeptStatusLB.Enabled = true;
            btnSaveDeptStatusLB.Style["cursor"] = "hand";
        }
        else
        {
            btnSaveDeptStatusLB.Enabled = false;
            btnSaveDeptStatusLB.Style["cursor"] = "default";
        }
    }

    private bool deptPreviousStatus_TempNotActiveNoDate;
    private void BindData()
    {

        UIHelper.BindDropDownToCachedTable(ddlStatus_ToAdd, "DIC_ActivityStatus", "status");

        DataSet ds = null;

        if (DeptCode != 0)
        {
            StatusBO statusBo = new StatusBO();
            _notActiveDate = statusBo.GetClosestNotActiveStatusDate(DeptCode);
            if (_notActiveDate.HasValue)
            {
                lblFutureStatusWarning.Text = "שים לב,סטטוס המרפאה יהפוך ללא פעיל ב-" + _notActiveDate.Value.ToShortDateString();
            }
        }

        SetCurrentMode();

        ds = Facade.getFacadeObject().GetAllStatuses(DeptCode, EmployeeID, ServiceCode, currentUpdatedEntity);

        if (currentUpdatedEntity == Enums.EntityTypesStatus.Dept)
        {
            if (ds.Tables[0].Rows.Count == 1
                && Convert.ToInt32(ds.Tables[0].Rows[0]["Status"]) == 2
                && ds.Tables[0].Rows[0]["ToDate"].ToString() == string.Empty)
            {
                deptPreviousStatus_TempNotActiveNoDate = true;
            }
            else
            {
                deptPreviousStatus_TempNotActiveNoDate = false;
            }

            ViewState["deptPreviousStatus_TempNotActiveNoDate"] = deptPreviousStatus_TempNotActiveNoDate;
        }

        if (ds != null && ds.Tables[0].Rows.Count > 0)
        {
            // calculate the minimum date that can be added
            DataTable dt = ds.Tables[0];
            DateTime maxDate = Convert.ToDateTime(dt.Rows[dt.Rows.Count - 1]["fromDate"]);

            //maxDate = maxDate.AddDays(1);

            if (maxDate.Date < DateTime.Now)
            {
                maxDate = DateTime.Now;
            }
            txtFromDateMinimum_ToAdd.Text = maxDate.ToString();

            // bind the grids
            gvDeptStatus.DataSource = ds;
            gvDeptStatus.DataBind();

            gvDeptStatusHistory.DataSource = ds;
            gvDeptStatusHistory.DataBind();

            StatusTable = ds.Tables[0];
        }
        else
        {
            txtFromDateMinimum_ToAdd.Text = DateTime.Now.ToShortDateString();

            if (ds.Tables[0] != null)
            {
                StatusTable = ds.Tables[0].Clone();
            }
        }
    }

    private void SetCurrentMode()
    {
        if (EmployeeID != 0)
        {
            if (DeptCode != 0)
            {
                if (ServiceCode != 0)
                    currentUpdatedEntity = Enums.EntityTypesStatus.EmployeeServiceInDept;
                else
                    currentUpdatedEntity = Enums.EntityTypesStatus.EmployeeInDept;
            }
            else
                currentUpdatedEntity = Enums.EntityTypesStatus.Employee;
        }
        else
        {
            if (ServiceCode != 0)
                currentUpdatedEntity = Enums.EntityTypesStatus.DeptService;
            else
                currentUpdatedEntity = Enums.EntityTypesStatus.Dept;
        }
    }

    private void GetQueryString()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["deptCode"]))
        {
            DeptCode = Convert.ToInt32(Request.QueryString["deptCode"]);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["employeeID"]))
        {
            EmployeeID = Convert.ToInt64(Request.QueryString["employeeID"]);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["DeptEmployeeID"]))
        {
            DeptEmployeeID = Convert.ToInt32(Request.QueryString["DeptEmployeeID"]);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["ServiceCode"]))
        {
            ServiceCode = Convert.ToInt32(Request.QueryString["ServiceCode"]);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["AgreementType"]))
        {
            AgreementType = Convert.ToInt32(Request.QueryString["AgreementType"]);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["functionToExecute"]))
        {
            txtFunctionToExecute.Text = Request.QueryString["functionToExecute"].ToString();
        }

    }

    private void CalculateMinimumDateToAdd()
    {
        DateTime minDateFrom_ToAdd = DateTime.Now;

        for (int i = 0; i < StatusTable.Rows.Count; i++)
        {
            if (Convert.ToDateTime(StatusTable.Rows[i]["FromDate"]).Date >= minDateFrom_ToAdd.Date)
            {
                minDateFrom_ToAdd = Convert.ToDateTime(StatusTable.Rows[i]["FromDate"]);
                //minDateFrom_ToAdd = minDateFrom_ToAdd.AddDays(1);
            }
        }

        txtFromDateMinimum_ToAdd.Text = minDateFrom_ToAdd.ToString();
    }

    private void CloseWindow(bool saveHasBeenMade)
    {
        string str = "var obj = new Object(); obj.saveHasBeenMade = " + saveHasBeenMade.ToString().ToLower() + ";";
        str = str + "obj.currentStatus = " + "-1" + ";";
        //string str = "window.returnValue = " + saveHasBeenMade.ToString().ToLower() +"; self.close();";
        str = str + "window.returnValue = obj; self.close();";

        ClientScript.RegisterStartupScript(this.GetType(), "close", str, true);
    }

    private void CloseWindow(bool saveHasBeenMade, int currentStatus)
    {
        string[] ArrParams = txtFunctionToExecute.Text.Split(',');

        string currentStatus_Text = "";

        switch (currentStatus)
        {
            case 0:        
                currentStatus_Text = "לא פעיל";
                break;

            case 1:
                currentStatus_Text = "פעיל";
                break;

            case 2:
                currentStatus_Text = "לא פעיל זמנית";
                break;
        }


        var functionToExecute = ArrParams[0];
        string str = string.Empty;

        if (functionToExecute != "")
        {
            switch (functionToExecute)
            {
                case "Update_btnDeptStatus":        // UpdateDept
                    str = "parent.Update_btnDeptStatus(" + currentStatus + ");";
                    break;

                case "RebindStatus_FromClient":     // UpdateEmployee
                    str = "parent.RebindStatus_FromClient();";
                    break;

                case "Update_lnkStatus_EmployeeInDept": // UpdateDeptEmployee - Employee status in Dept
                    str = "parent.Update_lnkStatus_EmployeeInDept(" + currentStatus + "," + ArrParams[1] + ");"; // ArrParams[1] lnkButton index of ID
                    break;

                case "Update_lnkStatus_Service":    // UpdateDeptEmployee - Employee Service status in Dept
                    str = "parent.Update_lnkStatus_Service('" + currentStatus_Text + "','" + ArrParams[1] + "');"; // ArrParams[1] lnkButton index of ID
                    break;
            }
        }

        str += "SelectJQueryClose();";

        ClientScript.RegisterStartupScript(this.GetType(), "close", str, true);
    }

    private void DisplayPeriodsInvalidMessage()
    {
        lblDeptStatusLB_ErrorMessage.Text = "* סטטוס זה הינו זמני, ולכן חובה להוסיף גם את הסטטוס הבא אחריו";
        trDeptStatusLB_ErrorMessage.Style.Add("display", "block");
    }

    private void HidePeriodsInvalidMessage()
    {
        trDeptStatusLB_ErrorMessage.Style.Add("display", "none");
    }

    /// <summary>
    /// check if the last status that was updated is not "not active temporarly"
    /// </summary>
    /// <returns></returns>
    private bool CheckIfStatusesPeriodsAreValid()
    {
        GridViewRow lastRow = gvDeptStatus.Rows[gvDeptStatus.Rows.Count - 1];
        DropDownList ddlStatus = lastRow.FindControl("ddlStatus") as DropDownList;

        if (Convert.ToInt32(ddlStatus.SelectedValue) == 2)
        {
            return false;
        }
        return true;
    }

    protected void gvDeptStatusHistory_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lbl = e.Row.FindControl("lblToDate") as Label;
            if (lbl.Text != string.Empty)
            {
                if (Convert.ToDateTime(lbl.Text).AddDays(1) > DateTime.Now)
                {
                    e.Row.Style.Add("display", "none");
                }
            }
            else
            {
                e.Row.Style.Add("display", "none");
            }
        }
    }

    protected void gvDeptStatus_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        _changesHasBeenMade = true;

        DataTable currDt = StatusTable;

        if (e.RowIndex > 0)
        {
            if (e.RowIndex < (currDt.Rows.Count - 1))
                currDt.Rows[e.RowIndex - 1]["ToDate"] = Convert.ToDateTime(currDt.Rows[e.RowIndex + 1]["FromDate"]).AddDays(-1);
            else
                currDt.Rows[e.RowIndex - 1]["ToDate"] = DBNull.Value; // i.e. - empty date
        }

        currDt.Rows[e.RowIndex].Delete();
        currDt.AcceptChanges();

        StatusTable = currDt;

        gvDeptStatus.DataSource = StatusTable;
        gvDeptStatus.DataBind();

        gvDeptStatusHistory.DataSource = StatusTable;
        gvDeptStatusHistory.DataBind();

        // calculate minimum date so the client validation will be updated
        CalculateMinimumDateToAdd();
    }

    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList ddl = sender as DropDownList;
        GridViewRow row = ddl.NamingContainer as GridViewRow;

        if (row.RowIndex == gvDeptStatus.Rows.Count - 1)
        {
            HidePeriodsInvalidMessage();
        }

        _changesHasBeenMade = true;
        DataTable currDt = StatusTable;
        currDt.Rows[row.RowIndex][0] = Convert.ToInt32(ddl.SelectedValue);
        currDt.Rows[row.RowIndex][1] = ddl.SelectedItem.Text;
        currDt.AcceptChanges();

        StatusTable = currDt;
    }

    protected void btnSaveDeptStatus_Click(object sender, EventArgs e)
    {

        if (Page.IsValid)
        {
            if (CheckIfStatusesPeriodsAreValid())
            {
                // "save" changes for deptStatus
                for (int i = 0; i < gvDeptStatus.Rows.Count; i++)
                {
                    DropDownList ddlStatus = gvDeptStatus.Rows[i].FindControl("ddlStatus") as DropDownList;

                    TextBox txtFromDate = gvDeptStatus.Rows[i].FindControl("txtFromDate") as TextBox;
                    TextBox txtToDate = gvDeptStatus.Rows[i].FindControl("txtToDate") as TextBox;


                    if (StatusTable.Rows[i]["Status"] != null)
                    {
                        StatusTable.Rows[i]["Status"] = Convert.ToInt32(ddlStatus.SelectedValue);

                        StatusTable.Rows[i]["FromDate"] = txtFromDate.Text;

                        if (txtToDate.Text != string.Empty)
                            StatusTable.Rows[i]["ToDate"] = txtToDate.Text;
                        else
                            StatusTable.Rows[i]["ToDate"] = System.DBNull.Value;
                    }
                }

                StatusTable.AcceptChanges();

                UserInfo currentUser = Session["currentUser"] as UserInfo;
                StatusBO bo = new StatusBO();
                Facade facade = Facade.getFacadeObject();

                int currentStatus = facade.UpdateStatus(DeptCode, EmployeeID, DeptEmployeeID, ServiceCode, AgreementType, StatusTable, currentUpdatedEntity, currentUser.UserNameWithPrefix);

                //if it was about clinic and it was activated for the first time after status "Temporarily not active" with NO closing date 

                if (ViewState["deptPreviousStatus_TempNotActiveNoDate"] != null)
                    deptPreviousStatus_TempNotActiveNoDate = Convert.ToBoolean(ViewState["deptPreviousStatus_TempNotActiveNoDate"]);

                if (deptPreviousStatus_TempNotActiveNoDate == true && currentStatus == 1)
                {
                    SendMailToAdministrator();
                }

                switch (currentStatus)
                {
                    case 0:
                        Session["NewStatusDescription"] = "לא פעיל";
                        break;
                    case 1:
                        Session["NewStatusDescription"] = "פעיל";
                        break;
                    case 2:
                        Session["NewStatusDescription"] = "לא פעיל זמנית";
                        break;
                        //default:
                        //    Session["NewStatusDescription"] = "לא פעיל";
                        //    break;
                }



                CloseWindow(true, currentStatus);

                btnSaveDeptStatusLB.Enabled = false;
            }
            else
            {
                DisplayPeriodsInvalidMessage();
            }
        }
    }

    protected void SendMailToAdministrator()
    {
        string MailTo = System.Configuration.ConfigurationManager.AppSettings["ReportClinicChangeToMail"].ToString();

        UserInfo currentUser = Session["currentUser"] as UserInfo;

        string UserName = currentUser.UserNameWithPrefix;

        Facade.getFacadeObject().SendReportClinicActivation(DeptCode, GetAbsoluteUrl(DeptCode), MailTo, UserName);

    }

    private string GetAbsoluteUrl(int deptCode)
    {
        string HTTPprefix = "http://";
        if (System.Configuration.ConfigurationManager.AppSettings["Is_HTTPS_enabled"].ToString() == "1")
        {
            HTTPprefix = "https://";
        }

        string serverName = Request.ServerVariables["SERVER_NAME"].ToString();
        string[] segmentsURL = Request.Url.Segments;
        string url = string.Empty;
        url = HTTPprefix + serverName + segmentsURL[0] + segmentsURL[1] + "Public/ZoomClinic.aspx?DeptCode=" + deptCode.ToString();
        return url;
    }

    protected void gvDeptStatus_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            TextBox txtStatus = e.Row.FindControl("txtStatus") as TextBox;
            TextBox txtFromDate = e.Row.FindControl("txtFromDate") as TextBox;
            TextBox txtToDate = e.Row.FindControl("txtToDate") as TextBox;
            Label lblStatus = e.Row.FindControl("lblStatus") as Label;
            Label lblFromDate = e.Row.FindControl("lblFromDate") as Label;
            Label lblToDate = e.Row.FindControl("lblToDate") as Label;
            DropDownList ddlStatus = e.Row.FindControl("ddlStatus") as DropDownList;
            ImageButton btnRunCalendarTo_DeptStatus = e.Row.FindControl("btnRunCalendarTo_DeptStatus") as ImageButton;
            ImageButton btnRunCalendarFrom_DeptStatus = e.Row.FindControl("btnRunCalendarFrom_DeptStatus") as ImageButton;

            UIHelper.BindDropDownToCachedTable(ddlStatus, "DIC_ActivityStatus", "status");
            ddlStatus.SelectedValue = txtStatus.Text;

            if (!IsPostBack)
            {
                bool statusIsActive = (ddlStatus.SelectedIndex != 0);

                if (!string.IsNullOrEmpty(txtToDate.Text))
                {
                    SetCurrentStatusForWarnings(lblFromDate.Text, txtToDate.Text, statusIsActive);
                }
                else // we don't have ToDate
                {
                    SetCurrentStatusForWarnings(lblFromDate.Text, DateTime.MaxValue.ToShortDateString(), statusIsActive);
                }
            }


            // disable status dropdown if user is not administrator and status is: "not active"
            if (DeptCode != 0)
            {
                UserInfo currentUser = Session["currentUser"] as UserInfo;

                if (currentUser != null && !currentUser.IsAdministrator)
                {
                    if (ddlStatus.SelectedIndex == 0)
                    {
                        ddlStatus.Enabled = false;
                    }
                }
            }

            if (Convert.ToDateTime(txtFromDate.Text).Date >= DateTime.Now.Date)
            {
                ddlStatus.Style.Add("display", "inline");
                lblStatus.Style.Add("display", "none");

                lblFromDate.Style.Add("display", "inline");
                txtFromDate.Style.Add("display", "none");
            }
            else
            {
                ddlStatus.Style.Add("display", "none");
                lblStatus.Style.Add("display", "inline");

                lblFromDate.Style.Add("display", "inline");
                txtFromDate.Style.Add("display", "none");

                e.Row.FindControl("btnDelete").Visible = false;
            }

            if (txtToDate.Text != string.Empty)
            {
                if (Convert.ToDateTime(txtToDate.Text).AddDays(1) > DateTime.Now)
                {
                    e.Row.Style.Add("display", "inline");
                }
                else
                {
                    e.Row.Style.Add("display", "none");
                }

                lblToDate.Style.Add("display", "none");
            }
            else
            {
                e.Row.Style.Add("display", "inline");
                btnRunCalendarTo_DeptStatus.Style.Add("display", "none");
                txtToDate.Style.Add("display", "none");
                lblToDate.Style.Add("display", "inline");
            }

        }
    }

    private void SetCurrentStatusForWarnings(string fromDateString, string toDateString, bool statusIsActive)
    {
        DateTime fromDate = Convert.ToDateTime(fromDateString);
        DateTime toDate = Convert.ToDateTime(toDateString);

        if (fromDate.Date <= DateTime.Now.Date && toDate.Date >= DateTime.Now.Date)
        {
            CurrentStatusIsActive = statusIsActive;
        }
    }

    protected void btnAddDeptStatusLB_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            _changesHasBeenMade = true;

            // Validate !!!!!!
            DateTime fromDate;

            if (StatusTable != null && StatusTable.Rows.Count > 0)
            {
                fromDate = Convert.ToDateTime(StatusTable.Rows[StatusTable.Rows.Count - 1]["FromDate"]);
            }
            else
            {
                fromDate = DateTime.Today.AddDays(-1);
            }

            if (Convert.ToDateTime(txtFromDate_ToAdd.Text).Date < fromDate.Date)
            {
                lblDeptStatusLB_ErrorMessage.Text = "תאריך התחלה אינו תקין";
                trDeptStatusLB_ErrorMessage.Style.Add("display", "block");
                return;
            }
            else
            {
                lblDeptStatusLB_ErrorMessage.Text = string.Empty;
                trDeptStatusLB_ErrorMessage.Style.Add("display", "none");
            }


            if (StatusTable.Rows.Count > 0)
            {
                StatusTable.Rows[StatusTable.Rows.Count - 1]["ToDate"] = Convert.ToDateTime(txtFromDate_ToAdd.Text).AddDays(-1);

                if (Convert.ToDateTime(StatusTable.Rows[StatusTable.Rows.Count - 1]["ToDate"]) < Convert.ToDateTime(StatusTable.Rows[StatusTable.Rows.Count - 1]["FromDate"]))
                {
                    StatusTable.Rows[StatusTable.Rows.Count - 1]["ToDate"] = Convert.ToDateTime(txtFromDate_ToAdd.Text);
                }


            }

            StatusTable.Rows.Add(Convert.ToInt32(ddlStatus_ToAdd.SelectedValue), ddlStatus_ToAdd.SelectedItem.Text, txtFromDate_ToAdd.Text, null);

            txtFromDate_ToAdd.Text = string.Empty;

            StatusTable.AcceptChanges();

            gvDeptStatus.DataSource = StatusTable;
            gvDeptStatus.DataBind();

            gvDeptStatusHistory.DataSource = StatusTable;
            gvDeptStatusHistory.DataBind();

            // calculate minimum date so the client validation will be updated
            CalculateMinimumDateToAdd();
        }
    }

    protected void btnCancelDeptStatus_Click(object sender, EventArgs e)
    {
        CloseWindow(false);
    }
}

