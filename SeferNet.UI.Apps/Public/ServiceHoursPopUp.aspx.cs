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
using System.Collections.Generic;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using System.Linq;

public partial class ServiceHoursPopUp : System.Web.UI.Page
{
    DataSet m_dsService;
    Facade applicFacade;
    private int m_deptCode;
    private int m_agreementType;
    int m_serviceCode;
    long m_employeeID;
    private bool TodayReceptionDialogMode = true;
    private DateTime expirationDate;
    private DateTime closestReceptionChange = DateTime.MaxValue;
    string RemarkCategoriesForAbsence = System.Configuration.ConfigurationManager.AppSettings["RemarkCategoriesForAbsence"].ToString();
    string RemarkCategoriesForClinicActivity = System.Configuration.ConfigurationManager.AppSettings["RemarkCategoriesForClinicActivity"].ToString();
    bool serviceRelevantForReceivingGuests = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        SetWindowMode();
        BindData();

        if (TodayReceptionDialogMode)
        {
            CheckIfExpireWarningIsNeeded();
        }
    }

    private void SetWindowMode()
    {
        applicFacade = Facade.getFacadeObject();
        m_agreementType = Convert.ToInt32(Request.QueryString["agreementType"]);
        m_deptCode = Convert.ToInt32(Request.QueryString["deptCode"]);
        m_employeeID = Convert.ToInt64(Request.QueryString["deptOrEmployeeCode"]);
        m_serviceCode = Convert.ToInt32(Request.QueryString["serviceCode"]);

        serviceRelevantForReceivingGuests = SeferNet.Globals.Utils.IsServiceRelevantForReceivingGuests(m_serviceCode);

        //---- expirationDate
        if (!string.IsNullOrEmpty(Request.QueryString["expirationDate"]) &&
            !string.IsNullOrEmpty(Request.QueryString["expirationDate"].Trim()) &&
            Request.QueryString["expirationDate"].Trim() != "null" &&
            DateTime.TryParse(Request.QueryString["expirationDate"], out expirationDate))
        {
            this.TodayReceptionDialogMode = false;
        }
        else
        {
            expirationDate = DateTime.Now.Date;
            this.TodayReceptionDialogMode = true;
        }

        this.BindLblFromExpDate();

        m_dsService = applicFacade.GetServiceForPopUp_ViaEmployee(m_deptCode, m_employeeID, m_agreementType, m_serviceCode, expirationDate, RemarkCategoriesForAbsence, RemarkCategoriesForClinicActivity);
        m_dsService.Tables[0].TableName = "dept";
        m_dsService.Tables[1].TableName = "service";
        m_dsService.Tables[2].TableName = "deptPhones";
        m_dsService.Tables[3].TableName = "serviceReception";
        m_dsService.Tables[4].TableName = "closestReceptionChange";
        m_dsService.Tables[5].TableName = "remarks";
        m_dsService.Tables[6].TableName = "deptFaxes";
        m_dsService.Tables[7].TableName = "queueOrderMethods";
        m_dsService.Tables[8].TableName = "queueOrderPhones";
        m_dsService.Tables[9].TableName = "queueOrderHours";
        m_dsService.Tables[10].TableName = "servicePhoneAndFaxes";
        m_dsService.Tables[11].TableName = "employeeDetails";
        m_dsService.Tables[12].TableName = "deptRemarks";

        foreach (DataRow dr in m_dsService.Tables["deptRemarks"].Rows)
        {
            dr["RemarkText"] = dr["RemarkText"].ToString().Replace("<a href", "<a target='_blank' href");
        }

        SetDeptDetailsViaPerson();
        setServicePhonesAndFaxes();
        setQueueOrder(m_dsService.Tables["service"],m_dsService.Tables["queueOrderMethods"], m_dsService.Tables["queueOrderPhones"], m_dsService.Tables["queueOrderHours"]);
    }

    private void setQueueOrder(DataTable dtService, DataTable dtOrderMethod, DataTable dtQueueOrderPhones, DataTable dtQueueOrderHours)
    {
        DataView dvOrderMethod = null;
        DataRow dr = null;
        if ((int)dtService.Rows[0]["PermitOrderMethods"] == 0)
        {
            spanQueueOrderCaption.InnerHtml = "<font color='#2889E4'>" + dtService.Rows[0]["QueueOrderDescription"].ToString() + "</font>";
            spanQueueOrderCaption.Style.Add("display", "block");        
        }

        if (dtOrderMethod.Rows.Count > 0)
        {
            dvOrderMethod = new DataView(dtOrderMethod);
            tdEmployeeQueueOrderMethods.InnerHtml = UIHelper.GetInnerHTMLForQueueOrder(dvOrderMethod, m_deptCode.ToString(), null, null);
            spanQueueOrderCaption.Style.Add("display", "block");
        }

        if (dtService.Rows[0]["ServiceQueueOrderPhones"].ToString() != string.Empty)
        {
            lblQueueOrderPhones.Text = dtService.Rows[0]["ServiceQueueOrderPhones"].ToString();
        }

        if (dtQueueOrderHours.Rows.Count > 0)
        {
            DataView dvServiceQueueOrderHours = new DataView(dtQueueOrderHours);
            gvQueueOrderHours.DataSource = dvServiceQueueOrderHours;
            gvQueueOrderHours.DataBind();
        }
    }

    private void CheckIfExpireWarningIsNeeded()
    {
        if (m_dsService.Tables["closestReceptionChange"].Rows[0][0] != DBNull.Value)
        {
            DateTime changeDate = Convert.ToDateTime(m_dsService.Tables["closestReceptionChange"].Rows[0][0]);

            if (changeDate < closestReceptionChange)
            {
                closestReceptionChange = changeDate;
            }
        }
        if (closestReceptionChange < DateTime.MaxValue)
        {
            divExpirationAlert.Visible = true;
            lblExpirationAlert.Text = " שים לב, בתאריך " + closestReceptionChange.ToShortDateString() + " יחולו שינויים בשעות הקבלה";
            divExpirationAlert.Attributes.Add("onclick", "OpenServiceExpirationWindow('"
                + m_deptCode.ToString() + "','"
                + m_employeeID.ToString() + "','"
                + m_serviceCode.ToString() + "','"
                + m_agreementType.ToString() + "','"
               // + m_viaPerson.ToString() + "','"
                + closestReceptionChange + "')");

            divExpirationAlert.Style["display"] = "inline";
        }
    }

    private void BindData()
    {
        //-- shared for viaPerson and ViaClinic  
        DataTable tblServiceReception = m_dsService.Tables["serviceReception"];

        DataView dvServiceReceptionDays = new DataView(m_dsService.Tables["serviceReception"],
            null, null, DataViewRowState.OriginalRows);

        DataRow[] dr = tblServiceReception.Select(null, "receptionDay");
        DataTable tblDaysForReception_DISTINCT = tblServiceReception.Clone();
        foreach (DataRow dataR in dr)
        {
            if (tblDaysForReception_DISTINCT.Select("receptionDay = '" + dataR["receptionDay"].ToString() + "'").Length == 0)
            {
                DataRow drNew = tblDaysForReception_DISTINCT.NewRow();
                drNew.ItemArray = dataR.ItemArray;
                tblDaysForReception_DISTINCT.Rows.Add(drNew);
            }
        }

        if (dvServiceReceptionDays.Count > 0)
        {
            gvServiceReceptionDays.DataSource = tblDaysForReception_DISTINCT;
            gvServiceReceptionDays.DataBind();
        }


        //--- Remarks
        DataTable tblEmployeeRemarks = this.m_dsService.Tables["remarks"];
        if (tblEmployeeRemarks != null &&
            tblEmployeeRemarks.Rows.Count > 0)
        {
            this.gvRemarks.DataSource = tblEmployeeRemarks;
            this.gvRemarks.DataBind();
        }

        DataTable tblClinicRemarks = this.m_dsService.Tables["deptRemarks"];
        if (tblClinicRemarks != null &&
            tblClinicRemarks.Rows.Count > 0)
        {
            this.gvClinicRemarks.DataSource = tblClinicRemarks;
            this.gvClinicRemarks.DataBind();
        }

    }

    private void setServicePhonesAndFaxes()
    {
        int rowCount = m_dsService.Tables["servicePhoneAndFaxes"].Rows.Count;
        string strPhones = "", strFaxes = "";
        
        if (rowCount > 0)
        {
            
            foreach (DataRow dr in m_dsService.Tables["servicePhoneAndFaxes"].Rows)
            {
                if (dr["phoneType"].ToString() != "2") // 2 = fax
                {
                    if (strPhones == string.Empty)
                        strPhones = "טל: " + dr["phone"].ToString();
                }
                else
                {
                    if (strFaxes == string.Empty)
                        strFaxes = "פקס: " + dr["phone"].ToString();
                    
                }

                
            }
            
            if (strPhones != string.Empty)
                divServicePhoneAndFaces.InnerHtml = strPhones;
            if (strPhones != string.Empty && strFaxes != string.Empty)
                divServicePhoneAndFaces.InnerHtml += " | " + strFaxes;
            if (strPhones == string.Empty && strFaxes != string.Empty)
                divServicePhoneAndFaces.InnerHtml = strFaxes;
            
        }
    }

    

    private void setDeptPhonesAndFaxes()
    {
        string phones = string.Empty;
        string faxes = "";
        int countPhonesAndFaxes = 0;
        int countPhones = 0;
        if (m_dsService.Tables["deptPhones"] != null && m_dsService.Tables["deptPhones"].Rows.Count > 0)
        {
            phones = "טל: " + m_dsService.Tables["deptPhones"].Rows[0]["phone"].ToString();
        }
        

        
        countPhones = countPhonesAndFaxes;
        if (m_dsService.Tables["deptFaxes"] != null && m_dsService.Tables["deptFaxes"].Rows.Count > 0)
        {
            faxes = "פקס: " + m_dsService.Tables["deptFaxes"].Rows[0]["fax"].ToString();
        }
        if(phones != string.Empty)
            divDeptPhones_ServiceHours.InnerHtml = phones;
        if (phones != string.Empty && faxes != string.Empty)
            divDeptPhones_ServiceHours.InnerHtml += " | " + faxes;
        if (phones == string.Empty && faxes != string.Empty)
            divDeptPhones_ServiceHours.InnerHtml = faxes;
        
    }
    
    private bool SetDeptDetailsViaPerson()
    {
        if (m_dsService.Tables["dept"] == null || m_dsService.Tables["dept"].Rows.Count < 1)
            return false;

        DataRow dr = m_dsService.Tables["employeeDetails"].Rows[0];
        lblEmployeeName.Text = dr["DegreeName"].ToString() + " " + dr["employeeName"].ToString();

        dr = m_dsService.Tables["dept"].Rows[0];
        
        lblDeptName_ServiceHours.Text = dr["deptName"].ToString();
        lblDeptAddress_ServiceHours.Text = dr["address"].ToString();

        
        
        if (m_dsService.Tables["service"] != null && m_dsService.Tables["service"].Rows.Count > 0)
        {
            this.lblServiceName.Text += m_dsService.Tables["service"].Rows[0]["serviceDescription"].ToString();
        }

        setDeptPhonesAndFaxes();

        return true;
    }

    

    protected void gvServiceReceptionDays_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            GridView gvReceptionHours = (GridView)e.Row.FindControl("gvReceptionHours");

            //if (viaPerson == 0)
            {
                DataView dvServiceReceptionDays = new DataView(m_dsService.Tables["serviceReception"],
                    "receptionDay =" + dvRowView["receptionDay"], null, DataViewRowState.OriginalRows);

                if (dvServiceReceptionDays.Count > 0)
                {
                    gvReceptionHours.DataSource = dvServiceReceptionDays;
                    gvReceptionHours.DataBind();
                }

            }
        }
    }

    protected void gvReceptionHours_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowIndex == -1) return;

        DataRow dr = ((DataRowView)e.Row.DataItem).Row;
        Label lblExpirationAlert = e.Row.FindControl("lblExpirationAlert") as Label;
        HtmlGenericControl divExpirationAlert = e.Row.FindControl("divExpirationAlert") as HtmlGenericControl;

        if (this.TodayReceptionDialogMode && Convert.ToInt32(dr["willExpireIn"]) < 15)
        {
            DateTime receptionChangeDate = Convert.ToDateTime(dr["expirationDate"]);

            if (receptionChangeDate < closestReceptionChange)
            {
                closestReceptionChange = receptionChangeDate.AddDays(1);
            }
        }

        Label lblRemarks = e.Row.FindControl("lblReceptionRemarks") as Label;

        if (string.IsNullOrEmpty(lblRemarks.Text))
        {
            lblRemarks.Visible = false;
        }

        Image imgReceiveGuests = e.Row.FindControl("imgReceiveGuests") as Image;

        if (serviceRelevantForReceivingGuests)
        {
            if (imgReceiveGuests != null && ((System.Data.DataRowView)(e.Row.DataItem))["ReceiveGuests"] != System.DBNull.Value)
            {
                if (Convert.ToBoolean(dr["ReceiveGuests"]) == true)
                {
                    imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuestsSmall.png";
                    imgReceiveGuests.ToolTip = "הרופא מקבל אורחים";
                }
                else if (Convert.ToBoolean(dr["ReceiveGuests"]) == false)
                {
                    imgReceiveGuests.ImageUrl = "~/Images/Applic/NOTreceiveGuestsSmall.png";
                    imgReceiveGuests.ToolTip = "הרופא אינו מקבל אורחים";
                }
            }
            else
            {
                imgReceiveGuests.ImageUrl = "~/Images/Applic/NOTreceiveGuestsSmall.png";
                imgReceiveGuests.ToolTip = "הרופא אינו מקבל אורחים";
            }
        }
        else
        {
            imgReceiveGuests.Visible = false;
        }
    }

    private void BindLblFromExpDate()
    {
        if (this.TodayReceptionDialogMode)
        {
            lblFromExpDate.Style["display"] = "none";
        }
        else
        {
            lblFromExpDate.Text = HttpContext.GetGlobalResourceObject("ApplicResources", "FromExperationDate") as string
                + ":&nbsp;&nbsp;" + expirationDate.ToShortDateString();
            lblFromExpDate.Style["display"] = "inline";
        }
    }

    protected void gvRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            Image imgInternet = e.Row.FindControl("imgInternet") as Image;
            //if(true) // for test using only
            if (Convert.ToBoolean(dvRowView["displayInInternet"]) == true)
            {
                imgInternet.Visible = false;
            }
            else
            {
                imgInternet.Style.Add("display", "inline");
                imgInternet.ImageUrl = "../Images/Applic/pic_NotShowInInternet.gif";
                imgInternet.ToolTip = "לא תוצג באינטרנט";
            }

            string[] RemarkCategoriesForAbsenceArr = RemarkCategoriesForAbsence.Split(',');

            for (int i = 0; i < RemarkCategoriesForAbsenceArr.Length; i++)
            {
                if (RemarkCategoriesForAbsenceArr[i] == dvRowView["RemarkCategoryID"].ToString())
                {
                    Label lblRemark = e.Row.FindControl("lblRemark") as Label;
                    lblRemark.CssClass = "LabelBoldRed_13";
                }
            }
        }
    }

    protected void gvClinicRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            Label lblRemark = e.Row.FindControl("lblRemark") as Label;

            Image imgInternet = e.Row.FindControl("imgInternet") as Image;
            if (Convert.ToBoolean(dvRowView["displayInInternet"]) == false)
            {
                imgInternet.Style.Add("display", "inline");
                imgInternet.ImageUrl = "../Images/Applic/pic_NotShowInInternet.gif";
                imgInternet.ToolTip = "לא לתצוגה באינטרנט";
            }
            else
            {
                imgInternet.Visible = false;
            }

            if (dvRowView["IsSharedRemark"] != DBNull.Value && Convert.ToBoolean(dvRowView["IsSharedRemark"]))
            {
                lblRemark.Style.Add("color", "#628e02");
                e.Row.Style.Add("color", "#628e02");
            }

            string[] RemarkCategoriesForClinicActivityArr = RemarkCategoriesForClinicActivity.Split(',');
            for (int i = 0; i < RemarkCategoriesForClinicActivityArr.Length; i++)
            {
                if (RemarkCategoriesForClinicActivityArr[i] == dvRowView["RemarkCategoryID"].ToString())
                {
                    lblRemark.CssClass = "LabelBoldRed_13";
                }
            }
        }
    }
}


