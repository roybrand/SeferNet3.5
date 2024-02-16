using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.FacadeLayer;
using System.Data;
using System.IO;
using SeferNet.Globals;
using SeferNet.UI;

public partial class UpdateClinicEvents : AdminBasePage
{

    UserInfo currentUser;
    Facade applicFacade;
    DataSet m_dsEvent;
    DataRow dr_event;
    DataTable dtDeptEventMeetings;
    DataTable dtDeptEventPhones;
    DataTable dtDeptFirstPhone;
    DataTable dtDeptEventFiles;
    DataTable dtEvMeet;
    ClinicEventParameters clinicEventParameters;
    bool deptEventsAreValid = true;
    int currentDeptCode = 0;
    string errorMessage;



    protected int CurrentDeptEventID
    {
        get
        {
            return (int)ViewState["CurrentEventID"];
        }
        set
        {
            ViewState["CurrentEventID"] = value;
        }
    }    
        
    protected bool UpdateExistingEventMode
    {
        get
        {
            if (ViewState["UpdateExistingEventMode"] != null)
                return (bool)ViewState["UpdateExistingEventMode"];
            else
                return false;
        }
        set
        {
            ViewState["UpdateExistingEventMode"] = value;
        }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();
        currentUser = Session["currentUser"] as UserInfo;        
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
        clinicEventParameters = new ClinicEventParameters();

        ClientScript.RegisterStartupScript(typeof(string), "ddlPayOrder_OnChange", "ddlPayOrder_OnChange();", true);      

        if (Session["clinicEventParameters"] != null)
            clinicEventParameters = Session["clinicEventParameters"] as ClinicEventParameters;


        currentDeptCode = sessionParams.DeptCode;

        if (currentDeptCode == 0)    // is session expired?
        {
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);
        }


        lblDeptName.Text = "ב" + SessionParamsHandler.GetDeptNameFromSession();


        if (!IsPostBack)
        {
            ClearPageSessions();

            if (Request.UrlReferrer != null)
                Master.PreviousPage = Request.UrlReferrer.ToString();

            dtDeptFirstPhone = applicFacade.GetDeptFirstPhone(currentDeptCode).Tables[0];

            if (sessionParams.ServiceCode != null || Request.QueryString["eventID"] != null) // update event
            {
                UpdateExistingEventMode = true;
                if (Request.QueryString["eventID"] != null)
                {
                    CurrentDeptEventID = Convert.ToInt32(Request.QueryString["eventID"].ToString());
                    sessionParams.ServiceCode = CurrentDeptEventID;
                }
                else
                    CurrentDeptEventID = (int)sessionParams.ServiceCode;
                m_dsEvent = applicFacade.GetDeptEventForUpdate(CurrentDeptEventID);
                ReadDataToTemporaryTablesAndControls();

                SetUserControlsData();
            }
            else // insert event
            {
                CurrentDeptEventID = 0;

                m_dsEvent = applicFacade.GetDeptEventForUpdate(CurrentDeptEventID);
                ReadDataToTemporaryTablesAndControls();
            }
        }
        else
        {
            //restore data from session to "clinicEventParameters" and "tables"
            if (Session["clinicEventParameters"] != null)
            {
                clinicEventParameters = Session["clinicEventParameters"] as ClinicEventParameters;


                dtDeptEventMeetings = ViewState["dtDeptEventMeetings"] as DataTable;
                dtDeptEventPhones = ViewState["dtDeptEventPhones"] as DataTable;

                RefreshDeptEventMeetingsFromGridView(); //!!!!!!!!!
                //RestoreSelectedFromAttributedTexBoxes();
            }
        }

    }

    void SetUserControlsData()
    {
        DataTable dtPh = new DataTable();
        Phone.CreateTableStructure(ref dtPh);

        for (int i = 0; i < dtDeptEventPhones.Rows.Count; i++)
        {
            DataRow dr = dtPh.NewRow();
            dr["prePrefix"] = dtDeptEventPhones.Rows[i]["prePrefix"];
            dr["prefixCode"] = dtDeptEventPhones.Rows[i]["prefixCode"];
            dr["prefixText"] = dtDeptEventPhones.Rows[i]["prefixText"];
            dr["phone"] = dtDeptEventPhones.Rows[i]["phone"];
            dr["phoneID"] = DBNull.Value;
            dr["phoneOrder"] = dtDeptEventPhones.Rows[i]["phoneOrder"];
            dr["phoneType"] = DBNull.Value;
            dr["extension"] = dtDeptEventPhones.Rows[i]["extension"];
            dtPh.Rows.Add(dr);

        }

        dtEvMeet = CreateDataTableEventMeetings();

        for (int i = 0; i < dtDeptEventMeetings.Rows.Count; i++)
        {
            DataRow dr = dtEvMeet.NewRow();
            dr["OrderNumber"] = dtDeptEventMeetings.Rows[i]["OrderNumber"];
            dr["Date"] = dtDeptEventMeetings.Rows[i]["Date"];
            dr["OpeningHour"] = dtDeptEventMeetings.Rows[i]["OpeningHour"];
            dr["ClosingHour"] = dtDeptEventMeetings.Rows[i]["ClosingHour"];
            dtEvMeet.Rows.Add(dr);

        }

        gvEventParticulars.DataSource = dtEvMeet;
        gvEventParticulars.DataBind();


        gvAttachedFiles.DataSource = dtDeptEventFiles;
        gvAttachedFiles.DataBind();
    }

    private DataTable CreateDataTableEventMeetings()
    {
        DataTable dt = new DataTable();
        DataColumn column = null;
        DataRow dr = dt.NewRow();

        column = new DataColumn("OrderNumber");
        dt.Columns.Add(column);
        column = new DataColumn("Date");
        dt.Columns.Add(column);
        column = new DataColumn("OpeningHour");
        dt.Columns.Add(column);
        column = new DataColumn("ClosingHour");
        dt.Columns.Add(column);

        return dt;
    }

    protected void RefreshDeptEventMeetingsFromGridView()
    {
        DataTable tblTemp = dtDeptEventMeetings.Copy();
        try
        {
            dtDeptEventMeetings.Clear();
            DateTime checkDate;

            for (int i = 0; i < gvEventParticulars.Rows.Count; i++)
            {
                if (gvEventParticulars.Rows[i].RowType == DataControlRowType.DataRow)
                {
                    TextBox txtDate = gvEventParticulars.Rows[i].FindControl("txtDate") as TextBox;
                    TextBox txtFromHour = gvEventParticulars.Rows[i].FindControl("txtFromHour") as TextBox;
                    TextBox txtToHour = gvEventParticulars.Rows[i].FindControl("txtToHour") as TextBox;

                    DataRow dr = dtDeptEventMeetings.NewRow();

                    dr["Date"] = Convert.ToDateTime(txtDate.Text);
                    dr["OpeningHour"] = txtFromHour.Text;
                    checkDate = Convert.ToDateTime(dr["OpeningHour"]);
                    dr["ClosingHour"] = txtToHour.Text;
                    checkDate = Convert.ToDateTime(dr["ClosingHour"]);
                    dtDeptEventMeetings.Rows.Add(dr);

                    if(Convert.ToDateTime(dr["OpeningHour"]) >= Convert.ToDateTime(dr["ClosingHour"]))
                        deptEventsAreValid = false;

                }
            }
            // empty rows list - is valid
            //if(gvEventParticulars.Rows.Count < 1)
            //    deptEventsAreValid = false;
        }
        catch
        {
            deptEventsAreValid = false;
            dtDeptEventMeetings = tblTemp.Copy();
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        #region Bind Controls

        if (!IsPostBack)
        {
            BindDropDownLists();
            BindPageControls();
        }
        if (UpdateExistingEventMode) // update event
        {
            lblEventName.Text = clinicEventParameters.EventName;
            trEventName.Style.Add("display", "none");
        }
        else
        {
            trEventName.Style.Add("display", "inline");
        }

        #endregion

        if (cbUpdateFromDeptPhones.Checked)
        {
            if (ddlPhonePrePrefix.Items.FindByValue(txtDeptFirstPhone_PrePrefix.Text) != null)
                ddlPhonePrePrefix.Items.FindByValue(txtDeptFirstPhone_PrePrefix.Text).Selected = true;

            if (ddlPhonePrefix.Items.FindByValue(txtDeptFirstPhone_Prefix.Text) != null)
                ddlPhonePrefix.Items.FindByValue(txtDeptFirstPhone_Prefix.Text).Selected = true;

            txtPhone.Text = txtDeptFirstPhone_Phone.Text;
            txtExtension.Text = txtDeptFirstPhone_Extension.Text;
            pnlPhone.Disabled = true;
        }


        cbUpdateFromDeptPhones.Attributes.Add("onClick", "UpdateFromDeptPhones()");
        txtDate.Attributes.Add("onChange", "ShowDayOfWeek(this,'" + txtDay.ClientID + "')");

    }

    private void BindPageControls()
    {
        if (CurrentDeptEventID != 0)
        {
            cbDisplayInInternet.Checked = clinicEventParameters.DisplayInInternet;
            txtEventDescription.Text = clinicEventParameters.EventDescription;
            txtTargetPopulation.Text = clinicEventParameters.TargetPopulation;
            ddlRegistrationStatus.SelectedValue = clinicEventParameters.RegistrationStatus.ToString();
            if (clinicEventParameters.PayOrder <= 0)
            {
                clinicEventParameters.PayOrder = -1;
            }
            ddlPayOrder.SelectedValue = clinicEventParameters.PayOrder.ToString();
            ddlEventName.SelectedValue = clinicEventParameters.EventCode.ToString();
            txtMemberPrice.Text = clinicEventParameters.MemberPrice.ToString();
            txtFullMemberPrice.Text = clinicEventParameters.FullMemberPrice.ToString();
            txtCommonPrice.Text = clinicEventParameters.CommonPrice.ToString();
            txtRemark.Text = clinicEventParameters.Remark;
            txtFromDate.Text = clinicEventParameters.FromDate.ToString("d");
            txtToDate.Text = clinicEventParameters.ToDate.ToString("d");

            BindDeptPhone();
        }
        else
        {
            txtMemberPrice.Text = string.Empty;
            txtFullMemberPrice.Text = string.Empty;
            txtCommonPrice.Text = string.Empty;
            txtFromDate.Text = DateTime.Today.ToShortDateString();
            txtToDate.Text = string.Empty;
        }

        if (dtDeptEventPhones.Rows.Count > 0)
        {
            ddlPhonePrefix.SelectedValue = dtDeptEventPhones.Rows[0]["prefixCode"].ToString();
            ddlPhonePrePrefix.SelectedValue = dtDeptEventPhones.Rows[0]["prePrefix"].ToString();
            txtPhone.Text = dtDeptEventPhones.Rows[0]["phone"].ToString();
            txtExtension.Text = dtDeptEventPhones.Rows[0]["extension"].ToString();
        }

        gvEventParticulars.DataSource = null;
        gvEventParticulars.DataBind();

        gvEventParticulars.DataSource = dtDeptEventMeetings;
        gvEventParticulars.DataBind();
    }

    private void BindDeptPhone()
    {
        if (clinicEventParameters.ShowPhonesFromDept)
        {
            pnlPhone.Disabled = true;
            cbUpdateFromDeptPhones.Checked = true;

            txtPhone.Text = dtDeptFirstPhone.Rows[0]["phone"].ToString();
            ddlPhonePrefix.SelectedValue = dtDeptFirstPhone.Rows[0]["prefix"].ToString();
            ddlPhonePrePrefix.SelectedValue = dtDeptFirstPhone.Rows[0]["prePrefix"].ToString();
            txtExtension.Text = dtDeptFirstPhone.Rows[0]["extension"].ToString();
        }
        else
        {
            cbUpdateFromDeptPhones.Checked = pnlPhone.Disabled = false;
        }

    }

    private void ReadDataToTemporaryTablesAndControls()
    {
        if (m_dsEvent.Tables["DeptEvent"].Rows.Count > 0)
        {
            dr_event = m_dsEvent.Tables["DeptEvent"].Rows[0];
            clinicEventParameters.DeptEventID = Convert.ToInt32(dr_event["DeptEventID"].ToString());
            clinicEventParameters.DeptCode = Convert.ToInt32(dr_event["DeptCode"].ToString());
            clinicEventParameters.EventCode = Convert.ToInt32(dr_event["EventCode"].ToString());
            clinicEventParameters.EventName = dr_event["EventName"].ToString();
            clinicEventParameters.EventDescription = dr_event["EventDescription"].ToString();
            clinicEventParameters.MeetingsNumber = Convert.ToInt32(dr_event["MeetingsNumber"]);
            clinicEventParameters.RepeatingEvent = Convert.ToBoolean(dr_event["RepeatingEvent"]);
            clinicEventParameters.FromDate = Convert.ToDateTime(dr_event["FromDate"]);
            clinicEventParameters.ToDate = Convert.ToDateTime(dr_event["ToDate"]);
            clinicEventParameters.RegistrationStatus = Convert.ToInt32(dr_event["RegistrationStatus"]);
            clinicEventParameters.PayOrder = Convert.ToInt32(dr_event["PayOrder"]);
            clinicEventParameters.CommonPrice = dr_event["CommonPrice"].ToString();
            clinicEventParameters.MemberPrice = dr_event["MemberPrice"].ToString();
            clinicEventParameters.FullMemberPrice = dr_event["FullMemberPrice"].ToString();
            clinicEventParameters.TargetPopulation = dr_event["TargetPopulation"].ToString();
            clinicEventParameters.Remark = dr_event["Remark"].ToString();
            clinicEventParameters.DisplayInInternet = Convert.ToBoolean(dr_event["displayInInternet"]);
            clinicEventParameters.ShowPhonesFromDept = Convert.ToBoolean(dr_event["ShowPhonesFromDept"]);
        }
        Session["clinicEventParameters"] = clinicEventParameters;

        dtDeptEventMeetings = m_dsEvent.Tables["DeptEventParticulars"];
        ViewState["dtDeptEventMeetings"] = dtDeptEventMeetings;

        dtDeptEventPhones = m_dsEvent.Tables["DeptEventPhones"];
        ViewState["dtDeptEventPhones"] = dtDeptEventPhones;

        dtDeptEventFiles = m_dsEvent.Tables["DeptEventFiles"];

        txtDeptFirstPhone_PrePrefix.Text = dtDeptFirstPhone.Rows[0]["prePrefix"].ToString();
        txtDeptFirstPhone_Prefix.Text = dtDeptFirstPhone.Rows[0]["prefix"].ToString();
        txtDeptFirstPhone_Phone.Text = dtDeptFirstPhone.Rows[0]["phone"].ToString();
        txtDeptFirstPhone_Extension.Text = dtDeptFirstPhone.Rows[0]["extension"].ToString();
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        RedirectToCaller();
    }

    private void RedirectToCaller()
    {
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
        string selTab = "";
        sessionParams.MarkServiceInClinicSelected = true; // service and events are treated the same

        /* Check if the refferer is zoomClinic */
        if (Request.QueryString["seltab"] != null)
        {
            if (sessionParams.CallerUrl.IndexOf("?") > 0)
                selTab = "&seltab=" + Request.QueryString["seltab"].ToString();
            else
                selTab = "?seltab=" + Request.QueryString["seltab"].ToString();
            
            string[] splitRef = sessionParams.CallerUrl.Split('?');
            splitRef[1] = RequestHelper.removeFromQueryString(splitRef[1], "seltab");
            sessionParams.CallerUrl = splitRef[0] + "?" + splitRef[1] + selTab;
        }
        Response.Redirect(sessionParams.CallerUrl);
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        bool result = false;
        if (!deptEventsAreValid)
        {
            Session["ErrorMessage"] = "The data of EventMeetings are wrong";
            return;
        }

        if (UpdateExistingEventMode)
        {
            result = UpdateDeptEvent();

            if (result == true)
            {
                RedirectToCaller();
            }
        }
        // new event adding
        else
        {
            result = InsertDeptEvent();
            if (result == true)
            {
                RedirectToCaller();
            }
        }
    }

    private bool UpdateDeptEvent()
    {
        applicFacade = Facade.getFacadeObject();

        int eventID = CurrentDeptEventID;
        int eventCode = Convert.ToInt32(ddlEventName.SelectedValue);
        int deptCode = SessionParamsHandler.GetDeptCodeFromSession();
        string updateUser = Master.getUserName();
        bool phonesFromDept = cbUpdateFromDeptPhones.Checked;

        string eventDescription = txtEventDescription.Text;
        DateTime fromDate = Convert.ToDateTime(txtFromDate.Text);
        DateTime toDate = Convert.ToDateTime(txtToDate.Text);
        int registrationStatus = Convert.ToInt32(ddlRegistrationStatus.SelectedValue);
        int payOrder = Convert.ToInt32(ddlPayOrder.SelectedValue);

        object commonPrice;
        if (txtCommonPrice.Text != string.Empty)
            commonPrice = (float)Convert.ToDecimal(txtCommonPrice.Text);
        else
            commonPrice = System.DBNull.Value;

        object memberPrice;
        if (txtMemberPrice.Text != string.Empty)
            memberPrice = (float)Convert.ToDecimal(txtMemberPrice.Text);
        else
            memberPrice = System.DBNull.Value;

        //float memberPrice = (float)Convert.ToDecimal(txtMemberPrice.Text);
        object fullMemberPrice;
        if (txtFullMemberPrice.Text != string.Empty)
            fullMemberPrice = (float)Convert.ToDecimal(txtFullMemberPrice.Text);
        else
            fullMemberPrice = System.DBNull.Value;

        //float fullMemberPrice = (float)Convert.ToDecimal(txtFullMemberPrice.Text);
        string targetPopulation = txtTargetPopulation.Text;
        string remark = txtRemark.Text;
        int displayInInternet = Convert.ToInt32(cbDisplayInInternet.Checked);

        int meetingsNumber = dtDeptEventMeetings.Rows.Count;

        object[] inputParamsDeptEvent = new object[] {
            deptCode,
            eventID, 
            eventCode, 
            eventDescription,
            meetingsNumber,
            fromDate,
            toDate,
            registrationStatus,
            payOrder,
            commonPrice,
            memberPrice,
            fullMemberPrice,
            targetPopulation,
            remark,
            displayInInternet,
            phonesFromDept,
            updateUser };

        dtDeptEventPhones.Clear();

        if (!phonesFromDept)
        {
            DataRow dr = dtDeptEventPhones.NewRow();
            if (txtPhone.Text != string.Empty)
                dr["phone"] = txtPhone.Text;
            else
                dr["phone"] = System.DBNull.Value;

            if (txtExtension.Text != string.Empty)
                dr["extension"] = txtExtension.Text;
            else
                dr["extension"] = System.DBNull.Value;

            if (Convert.ToInt32(ddlPhonePrefix.SelectedValue) >= 0)
                dr["prefixCode"] = Convert.ToInt32(ddlPhonePrefix.SelectedValue);
            else
                dr["prefixCode"] = System.DBNull.Value;

            if (Convert.ToInt32(ddlPhonePrePrefix.SelectedValue) >= 0)
                dr["prePrefix"] = Convert.ToInt32(ddlPhonePrePrefix.SelectedValue);
            else
                dr["prePrefix"] = System.DBNull.Value;

            if (dr["phone"] != System.DBNull.Value)
                dtDeptEventPhones.Rows.Add(dr);
        }

        dtDeptEventMeetings.AcceptChanges();

        bool result =  applicFacade.UpdateDeptEventTransaction(deptCode, updateUser, inputParamsDeptEvent, dtDeptEventMeetings, 
                                                            dtDeptEventPhones, phonesFromDept, ref errorMessage);

        return result;
    }

    private bool InsertDeptEvent()
    {
        bool result = false;
        applicFacade = Facade.getFacadeObject();
        int newEventID = 0;

        int eventID = clinicEventParameters.DeptEventID;
        int eventCode = Convert.ToInt32(ddlEventName.SelectedValue);
        int deptCode = SessionParamsHandler.GetDeptCodeFromSession();
        string updateUser = Master.getUserName();

        string eventDescription = txtEventDescription.Text;
        DateTime fromDate = Convert.ToDateTime(txtFromDate.Text);
        DateTime toDate = Convert.ToDateTime(txtToDate.Text);
        int registrationStatus = Convert.ToInt32(ddlRegistrationStatus.SelectedValue);
        int payOrder = Convert.ToInt32(ddlPayOrder.SelectedValue);

        object commonPrice;
        if (txtCommonPrice.Text != string.Empty)
            commonPrice = (float)Convert.ToDecimal(txtCommonPrice.Text);
        else
            commonPrice = System.DBNull.Value;

        object memberPrice;
        if (txtMemberPrice.Text != string.Empty)
            memberPrice = (float)Convert.ToDecimal(txtMemberPrice.Text);
        else
            memberPrice = System.DBNull.Value;

        //float memberPrice = (float)Convert.ToDecimal(txtMemberPrice.Text);
        object fullMemberPrice;
        if (txtFullMemberPrice.Text != string.Empty)
            fullMemberPrice = (float)Convert.ToDecimal(txtFullMemberPrice.Text);
        else
            fullMemberPrice = System.DBNull.Value;

        //float fullMemberPrice = (float)Convert.ToDecimal(txtFullMemberPrice.Text);
        string targetPopulation = txtTargetPopulation.Text;
        string remark = txtRemark.Text;
        int displayInInternet = Convert.ToInt32(cbDisplayInInternet.Checked);

        int numberOfMeetings = dtDeptEventMeetings.Rows.Count;

        object[] inputParamsDeptEvent = new object[] {
            deptCode,
            eventID, 
            eventCode, 
            eventDescription,
            numberOfMeetings,
            fromDate,
            toDate,
            registrationStatus,
            payOrder,
            commonPrice,
            memberPrice,
            fullMemberPrice,
            targetPopulation,
            remark,
            displayInInternet,
            updateUser,
            cbUpdateFromDeptPhones.Checked };

        dtDeptEventPhones.Clear();
        DataRow dr = dtDeptEventPhones.NewRow();
        if (txtPhone.Text != string.Empty)
            dr["phone"] = txtPhone.Text;
        else
            dr["phone"] = System.DBNull.Value;

        if (txtExtension.Text != string.Empty)
            dr["extension"] = txtExtension.Text;
        else
            dr["extension"] = System.DBNull.Value;

        if (Convert.ToInt32(ddlPhonePrefix.SelectedValue) >= 0)
            dr["prefixCode"] = Convert.ToInt32(ddlPhonePrefix.SelectedValue);
        else
            dr["prefixCode"] = System.DBNull.Value;

        if(Convert.ToInt32(ddlPhonePrePrefix.SelectedValue) >= 0)
            dr["prePrefix"] = Convert.ToInt32(ddlPhonePrePrefix.SelectedValue);
        else
            dr["prePrefix"] = System.DBNull.Value;

        if(dr["phone"] != System.DBNull.Value)
            dtDeptEventPhones.Rows.Add(dr);

        dtDeptEventMeetings.AcceptChanges();

        newEventID = applicFacade.InsertDeptEvent(deptCode, inputParamsDeptEvent, 
                                                            dtDeptEventMeetings, dtDeptEventPhones, cbUpdateFromDeptPhones.Checked);
        if (newEventID > 0)
        {
            result = true;
        }
        else
        {
            result = false;
        }
        return result;
    }

    private void BindDropDownLists()
    {
        UIHelper.BindDropDownToCachedTable(ddlPayOrder, "DIC_DeptEventPayOrder", "PayOrder");
        UIHelper.BindDropDownToCachedTable(ddlRegistrationStatus, "DIC_RegistrationStatus", "registrationStatus");
        UIHelper.BindDropDownToCachedTable(ddlEventName, "View_Events", "EventName");
        UIHelper.BindDropDownToCachedTable(ddlPhonePrefix, "DIC_PhonePrefix", "prefixValue");
    }

    protected void gvEventParticulars_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            TextBox txtDate = e.Row.FindControl("txtDate") as TextBox;
            TextBox txtDay = e.Row.FindControl("txtDay") as TextBox;
            TextBox txtFromHour = e.Row.FindControl("txtFromHour") as TextBox;
            TextBox txtToHour = e.Row.FindControl("txtToHour") as TextBox;
            TextBox txtDuration = e.Row.FindControl("txtDuration") as TextBox;

            if (txtDate.Text != string.Empty)
            {
                string[] strDOW = { "א`", "ב`", "ג`", "ד`", "ו`", "ה`", "ש`" };
                DateTime DT = Convert.ToDateTime(txtDate.Text);
                int DOW = Convert.ToInt32(DT.DayOfWeek);
                txtDay.Text = strDOW[DOW];
            }
            else
            {
                txtDate.Text = DateTime.Today.ToShortDateString();
            }

            if (txtFromHour.Text != string.Empty && txtToHour.Text != string.Empty)
            {
                string[] fromHour = txtFromHour.Text.Split(':');
                string[] toHour = txtToHour.Text.Split(':');
                decimal res = (Convert.ToInt32(toHour[0]) - Convert.ToInt32(fromHour[0]))
                    + (Convert.ToDecimal(toHour[1]) - Convert.ToDecimal(fromHour[1])) / 60;
                txtDuration.Text = res.ToString("0.0");
            }
            if (txtFromDate.Text == String.Empty)
                txtFromDate.Text = DateTime.Today.ToShortDateString();

            txtDate.Attributes.Add("onChange", "ShowDayOfWeek(this,'" + txtDay.ClientID + "')");
            //txtFromHour.Attributes.Add("onChange", "ShowDuration('" + txtFromHour.ClientID + "','" + txtToHour.ClientID + "','" + txtDuration.ClientID + "')");
            //txtToHour.Attributes.Add("onChange", "ShowDuration('" + txtFromHour.ClientID + "','" + txtToHour.ClientID + "','" + txtDuration.ClientID + "')");

            txtFromHour.Attributes.Add("onBlur", "ShowDuration('" + txtFromHour.ClientID + "','" + txtToHour.ClientID + "','" + txtDuration.ClientID + "')");
            txtFromDate.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtFromDate.ClientID + "')";
            txtDate.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtDate.ClientID + "')";
            txtToHour.Attributes.Add("onBlur", "ShowDuration('" + txtFromHour.ClientID + "','" + txtToHour.ClientID + "','" + txtDuration.ClientID + "')");

        }
    }
    protected void gvEventParticulars_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        dtDeptEventMeetings.Rows[e.RowIndex].Delete();
        dtDeptEventMeetings.AcceptChanges();

        gvEventParticulars.DataSource = null;
        gvEventParticulars.DataBind();

        gvEventParticulars.DataSource = dtDeptEventMeetings;
        gvEventParticulars.DataBind();

        ViewState["dtDeptEventMeetings"] = dtDeptEventMeetings;
    }

    void ClearPageSessions()
    {
        Session["deptEventMeetingRowIndexToBeDeleted"] = null;
    }

    protected void btnAddDeptEventParticulars_Click(object sender, EventArgs e)
    {
        DateTime dateToAdd;
        if (!DateTime.TryParse(txtDate.Text, out dateToAdd)) return;
        
        string fromHourToAdd = txtFromHour.Text;
        string toHourToAdd = txtToHour.Text;
        int particularsToAdd = Convert.ToInt32(txtNumberParticularsToAdd.Text);
        for (int i = 0; i < particularsToAdd; i++)
        { 
            DataRow dr = dtDeptEventMeetings.NewRow();
            dr["Date"] = dateToAdd.AddDays(i * 7);
            dr["OpeningHour"] = txtFromHour.Text;
            dr["ClosingHour"] = txtToHour.Text;
            dtDeptEventMeetings.Rows.Add(dr);
        }

        dtDeptEventMeetings.AcceptChanges();
        /// new sorting
        SortDataTable(dtDeptEventMeetings, "Date");

        gvEventParticulars.DataSource = null;
        gvEventParticulars.DataBind();

        gvEventParticulars.DataSource = dtDeptEventMeetings;
        gvEventParticulars.DataBind();

        ViewState["dtDeptEventMeetings"] = dtDeptEventMeetings;

        txtDay.Text = string.Empty;
        txtDate.Text = string.Empty;
        txtFromHour.Text = string.Empty;
        txtToHour.Text = string.Empty;
        txtNumberParticularsToAdd.Text = string.Empty;
    }

    private void SortDataTable(DataTable dt, string sort)
    {
        DataTable newDT = dt.Clone();
        int rowCount = dt.Rows.Count;

        DataRow[] foundRows = dt.Select(null, sort); // Sort with Column name 
        for (int i = 0; i < rowCount; i++)
        {
            object[] arr = new object[dt.Columns.Count];
            for (int j = 0; j < dt.Columns.Count; j++)
            {
                arr[j] = foundRows[i][j];
            }
            DataRow data_row = newDT.NewRow();
            data_row.ItemArray = arr;
            newDT.Rows.Add(data_row);
        }

        //clear the incoming dt 
        dt.Rows.Clear();

        for (int i = 0; i < newDT.Rows.Count; i++)
        {
            object[] arr = new object[dt.Columns.Count];
            for (int j = 0; j < dt.Columns.Count; j++)
            {
                arr[j] = newDT.Rows[i][j];
            }

            DataRow data_row = dt.NewRow();
            data_row.ItemArray = arr;
            dt.Rows.Add(data_row);
        }
    }

    protected void AddFile_Click(object sender, EventArgs e)
    {
        if (inputUploadFile.PostedFile != null)
        {
            string targetPath = ConfigHelper.GetEventFilesStoragePath();
            char underscore = '_';
            string oldFileName = inputUploadFile.PostedFile.FileName;
            string extension = oldFileName.Substring(oldFileName.LastIndexOf('.') + 1);
            string fileDisplayName = oldFileName.Substring(oldFileName.LastIndexOf('\\') + 1);
            

            string newFileName = clinicEventParameters.DeptCode.ToString() + underscore +
                             clinicEventParameters.DeptEventID.ToString() + underscore +
                             DateTime.Now.Date.Day.ToString() + DateTime.Now.Date.Month.ToString() + DateTime.Now.Date.Year.ToString() +
                             DateTime.Now.TimeOfDay.Hours.ToString() + DateTime.Now.TimeOfDay.Minutes.ToString() +
                             DateTime.Now.TimeOfDay.Seconds.ToString() + "." + extension;

            string savedFileName = targetPath + newFileName;

            inputUploadFile.PostedFile.SaveAs(savedFileName);
            
            Facade.getFacadeObject().AddAttachedFileToDeptEvent(clinicEventParameters.DeptEventID,
                                                    clinicEventParameters.DeptCode, clinicEventParameters.EventCode,
                                                    inputUploadFile.PostedFile.FileName, newFileName);
        }

        BindAttacedFiles();
    }

    protected void FileDelete_Click(object sender, EventArgs e)
    {
        ImageButton btn = sender as ImageButton;

        int deptEventFileID = Convert.ToInt32(btn.CommandArgument);

        Facade.getFacadeObject().DeleteFileAttachedToEvent(deptEventFileID);

        BindAttacedFiles();
    }

    private void BindAttacedFiles()
    {
        DataSet ds = Facade.getFacadeObject().GetDeptEventFiles(clinicEventParameters.DeptEventID);

        gvAttachedFiles.DataSource = ds;
        gvAttachedFiles.DataBind();

    }
}
