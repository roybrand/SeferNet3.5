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
using System.Linq;

using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;
using System.Text;
using Clalit.SeferNet.GeneratedEnums;
using System.Collections.Generic;

public partial class zoomDoctor : System.Web.UI.Page
{
    DataSet m_dsDoctor;
    Facade applicFacade = Facade.getFacadeObject();
    string pageCounter = string.Empty;
    int m_deptCode;
    int currentDayCode = 0;
    long _employeeID;
    UserInfo currentUser;
    SessionParams sessionParams;    
    private DateTime m_closestReceptionChange = DateTime.MaxValue;
    private Dictionary<string, string> dicTabs = new Dictionary<string, string>()
    {
        { "tb_EmployeeDetails", "divEmployeeDetailsBut,trEmployeeDetails,tdEmployeeDetailsTab" },
        { "tb_EmployeeHours", "divEmployeeHoursBut,trEmployeeHours,tdEmployeeHoursTab" }
    };

    private int currentProfessionCode = 0;
    private bool printSubProfessionCaption = true;
    private bool printProfessionServiceCaption = true;
    string RemarkCategoriesForAbsence = ConfigurationManager.AppSettings["RemarkCategoriesForAbsence"].ToString();

    long EmployeeID
    {
        get
        {
            if (IsPostBack)
            {
                return SessionParamsHandler.GetEmployeeIdFromSession();
            }

            return _employeeID;
        }
    }
    




    protected void Page_Load(object sender, EventArgs e)
    {	
        sessionParams = SessionParamsHandler.GetSessionParams();
        

        if (!IsPostBack)
        {
            if (!long.TryParse(Request.QueryString["EmployeeID"], out _employeeID))
            {
                Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);
            }          
            
            sessionParams.CallerUrl = Request.Url.OriginalString;
            sessionParams.EmployeeID = _employeeID;
            sessionParams.CurrentEntityToReport = Enums.IncorrectDataReportEntity.Employee;

            if (!string.IsNullOrEmpty(Request.QueryString["index"]))
            {
                Int32.TryParse(Request.QueryString["index"], out sessionParams.LastRowIndexOnSearchPage);
            }

            if (Request.QueryString["seltab"] != null)
            {
                txtTabToBeShown.Text = dicTabs[Request.QueryString["seltab"].ToString()];
            }
            else
            {
                txtTabToBeShown.Text = sessionParams.CurrentTab_ZoomDoctor;
            }
        }
        else
        {
            sessionParams.CurrentTab_ZoomDoctor = txtTabToBeShown.Text;
            SessionParamsHandler.SetSessionParams(sessionParams);
        }

        if (Session["DeptCodesToBeAddedToEmployee"] != null)
        {
            txtDeptsToBeAdded.Text = Session["DeptCodesToBeAddedToEmployee"].ToString();
            Session["DeptCodesToBeAddedToEmployee"] = null;
            AddDeptToEmployee();
        }
    }

    private void AddDeptToEmployee()
    {
        if (txtDeptsToBeAdded.Text.Trim() != string.Empty)
        {
            string[] deptsToBeAdded = txtDeptsToBeAdded.Text.Split(',');
            long employeeId = SessionParamsHandler.GetEmployeeIdFromSession();
            Facade facade = Facade.getFacadeObject();
            UserInfo CurrentUser = new UserManager().GetUserInfoFromSession();

            foreach(string strDeptCode in deptsToBeAdded)
            {
                if (strDeptCode != string.Empty)
                {
                    int deptCodeToAdd = Convert.ToInt32(strDeptCode);
                    facade.InsertDoctorInClinic(deptCodeToAdd, employeeId, Convert.ToInt32(eDIC_AgreementTypes.Community), CurrentUser.UserNameWithPrefix, true, string.Empty, false);
                }
            }

            txtDeptsToBeAdded.Text = string.Empty;
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        currentUser = Session["currentUser"] as UserInfo;

        BindPageData();

        toggleUpdateButtons();//display update buttons by permissions

        if (!IsPostBack)
        {
            ClientScript.RegisterStartupScript(typeof(string), "SetTabToBeShownOnLoad", "SetTabToBeShownOnLoad();", true);
        }
        else
        {
            ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "SetTabToBeShownOnLoad", "SetTabToBeShownOnLoad();", true);
        }

        if (Request.QueryString["NoProfessionLicence"] != null)
        {
            ClientScript.RegisterStartupScript(typeof(string), "NoProfessionLicence", "NoProfessionLicence();", true);
        }
    }

    private void toggleUpdateButtons()
    {
        UserInfo currentUser = Session["currentUser"] as UserInfo;

        HtmlTableCell tdHomePhoneLogin = dvDoctorDetails.FindControl("tdHomePhoneLogin") as HtmlTableCell;
        HtmlTableCell tdCellPhoneLogin = dvDoctorDetails.FindControl("tdCellPhoneLogin") as HtmlTableCell;

        HtmlTableCell tdHomePhone = dvDoctorDetails.FindControl("tdHomePhone") as HtmlTableCell;
        HtmlTableCell tdCellPhone = dvDoctorDetails.FindControl("tdCellPhone") as HtmlTableCell;

        Label lblHomePhone = dvDoctorDetails.FindControl("lblHomePhone") as Label;
        Label lblCellPhone = dvDoctorDetails.FindControl("lblCellPhone") as Label;


        HtmlTableRow trEmployeeID = dvDoctorDetails.FindControl("trEmployeeID") as HtmlTableRow;
        HtmlTable tblUpdateEmployeeRemarks = dvDoctorDetails.FindControl("tblUpdateEmployeeRemarks") as HtmlTable;

        HtmlTableCell tdBtnUpdateEmployeeProfessionLicence = dvDoctorDetails.FindControl("tdBtnUpdateEmployeeProfessionLicence") as HtmlTableCell;


        int employeeDistrict = Convert.ToInt32(m_dsDoctor.Tables["doctorDetails"].Rows[0]["PrimaryDistrict"]);

        // first, hide all update buttons
        tdUpdateEmployee.Style.Add("display", "none");
        tdAddDeptToEmployee.Style.Add("display", "none");
        tdUpdateEmployeeHours.Style.Add("display", "none");
        tblUpdateEmployeeRemarks.Style.Add("display", "none");
        trEmployeeID.Style.Add("display", "none");
        tdBtnUpdateEmployeeProfessionLicence.Style.Add("display", "none");

        // hide "restricted" labels
        dvDoctorDetails.FindControl("lblHomePhoneRestricted").Visible = false;
        dvDoctorDetails.FindControl("lblCellPhoneRestriced").Visible = false;

        if (currentUser != null)
        {
            tdHomePhoneLogin.Style.Add("display", "none");
            tdCellPhoneLogin.Style.Add("display", "none");

            bool homePhoneRestricted = Convert.ToBoolean(m_dsDoctor.Tables["doctorDetails"].Rows[0]["isUnlisted_Home"]);
            bool cellPhoneRestricted = Convert.ToBoolean(m_dsDoctor.Tables["doctorDetails"].Rows[0]["isUnlisted_Cell"]);

            SetPhoneDisplayByPermission(currentUser, "lblHomePhoneRestricted", "tdHomePhone", homePhoneRestricted);

            SetPhoneDisplayByPermission(currentUser, "lblCellPhoneRestriced", "tdCellPhone", cellPhoneRestricted);

            int isDoctor = Convert.ToInt32(m_dsDoctor.Tables["doctorDetails"].Rows[0]["IsDoctor"]);
            int IsVirtualDoctor = Convert.ToInt32(m_dsDoctor.Tables["doctorDetails"].Rows[0]["IsVirtualDoctor"]);


            if (currentUser.CheckIfUserPermitted(Enums.UserPermissionType.District, employeeDistrict) || currentUser.IsAdministrator)
            {
                // update buttons
                tdUpdateEmployee.Style.Add("display", "inline");
                tdAddDeptToEmployee.Style.Add("display", "inline");
                tdUpdateEmployeeHours.Style.Add("display", "inline");
                tblUpdateEmployeeRemarks.Style.Add("display", "inline");
                trEmployeeID.Style.Add("display", "inline");
                if (isDoctor != 1 && IsVirtualDoctor != 1)
                { 
                    tdBtnUpdateEmployeeProfessionLicence.Style.Add("display", "inline");
                }
            }
        }
        else
        {
            if (Convert.ToBoolean(m_dsDoctor.Tables["doctorDetails"].Rows[0]["isUnlisted_Home"]) == true)
            {
                tdHomePhoneLogin.Style.Add("display", "inline");
                tdHomePhone.Style.Add("display", "none");
            }
            else
            {
                tdHomePhoneLogin.Style.Add("display", "none");
                tdHomePhone.Style.Add("display", "inline");
            }

            if (Convert.ToBoolean(m_dsDoctor.Tables["doctorDetails"].Rows[0]["isUnlisted_Cell"]) == true)
            {
                tdCellPhoneLogin.Style.Add("display", "inline");
                tdCellPhone.Style.Add("display", "none");
            }
            else
            {
                tdCellPhoneLogin.Style.Add("display", "none");
                tdCellPhone.Style.Add("display", "inline");
            }
        }

    }

    private void SetPhoneDisplayByPermission(UserInfo currentUser, string restrictedLabelID, string phoneContainerID, bool isPhoneRestricted)
    {
        int employeeDistrict = Convert.ToInt32(m_dsDoctor.Tables["doctorDetails"].Rows[0]["PrimaryDistrict"]);
        HtmlTableCell phoneCell = dvDoctorDetails.FindControl(phoneContainerID) as HtmlTableCell;

        if (isPhoneRestricted)
        {
            dvDoctorDetails.FindControl(restrictedLabelID).Visible = true;

            if (currentUser.CheckIfHiddenDetailsAllowed(employeeDistrict))
            {
                phoneCell.Style.Add("display", "inline");
            }
            else
            {
                phoneCell.Style.Add("display", "none");
            }

        }
        else
        {
            dvDoctorDetails.FindControl(restrictedLabelID).Visible = false;
            phoneCell.Style.Add("display", "inline");
        }
    }


    private void ToggleHiddenDetails(bool display)
    {

    }

    public void BindPageData()
    {
        BindDoctorDetails();
        BindDoctorClinics();
        BindDoctorHours();
        BindUpdateDateLables();
    }

    public bool BindDoctorDetails()
    {
        m_dsDoctor = applicFacade.getDoctorDetails(EmployeeID);

        dvDoctorDetails.DataSource = m_dsDoctor.Tables["doctorDetails"];

        dvDoctorDetails.DataBind();

        string EmployeeName = m_dsDoctor.Tables["doctorDetails"].Rows[0]["EmployeeName"].ToString();
        SessionParamsHandler.SetEmployeeNameToSession(EmployeeName);

        return true;
    }

    public bool BindDoctorClinics()
    {
        currentUser = new UserManager().GetUserInfoFromSession();

        if (currentUser != null)
            gvClinics.DataSource = m_dsDoctor.Tables["clinics"];
        else
        {
            DataView dvClinics = new DataView(m_dsDoctor.Tables["clinics"], "status = 1", "", DataViewRowState.OriginalRows);
            gvClinics.DataSource = dvClinics;
        }

        gvClinics.DataBind();
        
        return true;
    }

    public bool BindDoctorHours()
    {
        DataTable tblDoctorReception = m_dsDoctor.Tables["doctorReceptionHours"];

        //string strSelectConditions = "deptCode = " + m_deptCode.ToString() + " AND professionOrServiceCode = '" + dvRowView["professionOrServiceCode"].ToString() + "'";

        //DataRow[] dr = tblDoctorReception.Select(strSelectConditions, "receptionDay");
        DataRow[] dr = tblDoctorReception.Select();
        DataTable tblDaysForReception_DISTINCT = tblDoctorReception.Clone();
        foreach (DataRow dataR in dr)
        {
            if (tblDaysForReception_DISTINCT.Select("receptionDay = '" + dataR["receptionDay"].ToString() + "'").Length == 0)
            {
                DataRow drNew = tblDaysForReception_DISTINCT.NewRow();
                drNew.ItemArray = dataR.ItemArray;
                tblDaysForReception_DISTINCT.Rows.Add(drNew);
            }
        }

        if (tblDaysForReception_DISTINCT.Rows.Count > 0)
        {
            gvEmployeeReceptionDays_All.DataSource = tblDaysForReception_DISTINCT;
            gvEmployeeReceptionDays_All.DataBind();
        }

        CheckIfNeedExpireWarning();

        return true;
    }

    private void CheckIfNeedExpireWarning()
    {
        if (m_dsDoctor.Tables["doctorClosestReceptionAddDate"].Rows.Count > 0 &&
                            m_dsDoctor.Tables["doctorClosestReceptionAddDate"].Rows[0][0] != DBNull.Value)
        {
            DateTime receptionAddDate = Convert.ToDateTime(m_dsDoctor.Tables["doctorClosestReceptionAddDate"].Rows[0][0]);

            if (receptionAddDate < m_closestReceptionChange)
            {
                m_closestReceptionChange = receptionAddDate;
            }

        }


        if (m_closestReceptionChange < DateTime.MaxValue)
        {
            divExpireWarning.Attributes.Add("onclick", "OpenEmployeeExpirationReceptionWindow('" + EmployeeID + "','" 
                                                                                        + m_closestReceptionChange.ToShortDateString() + "');");
            lblExpireWarning.Text = string.Format(ConstsSystem.EXPIRE_MESSAGE, m_closestReceptionChange.ToShortDateString());
        }

    }

    public void BindUpdateDateLables()
    {
        if (m_dsDoctor.Tables["doctorUpdateDate"] != null)
        {
            if (m_dsDoctor.Tables["doctorUpdateDate"].Rows.Count != 0)
            {
                if (m_dsDoctor.Tables["doctorUpdateDate"].Rows[0][0] != DBNull.Value)
                    lblUpdateDateDetailsFld.Text = Convert.ToDateTime(m_dsDoctor.Tables["doctorUpdateDate"].Rows[0][0]).ToString("dd/MM/yyyy");
            }
        }

        if (m_dsDoctor.Tables["clinicsUpdateDate"] != null)
        {
            if (m_dsDoctor.Tables["clinicsUpdateDate"].Rows.Count != 0)
            { 
                if (m_dsDoctor.Tables["clinicsUpdateDate"].Rows[0][0] != DBNull.Value)
                    lblUpdateDateClinicsFld.Text = (Convert.ToDateTime(m_dsDoctor.Tables["clinicsUpdateDate"].Rows[0][0])).ToString("dd/MM/yyyy");
            }
        }

        if (m_dsDoctor.Tables["receptionUpdateDate"] != null)
        {
            if (m_dsDoctor.Tables["receptionUpdateDate"].Rows.Count != 0)
            { 
                if (m_dsDoctor.Tables["receptionUpdateDate"].Rows[0][0] != DBNull.Value)
                    lblUpdateDateHoursFld.Text = (Convert.ToDateTime(m_dsDoctor.Tables["receptionUpdateDate"].Rows[0][0])).ToString("dd/MM/yyyy");
            }
        }

    }

    protected void dvDoctorDetails_DataBound(object sender, EventArgs e)
    {

        DetailsView dv = sender as DetailsView;

        bindRemarks(dv);

        DataRow row = m_dsDoctor.Tables[0].Rows[0];
        lblName.Text = row["EmployeeName"].ToString();
        lblName_ForHours.Text = row["EmployeeName"].ToString();
        if (row["expert"].ToString().Length > 0)
        {
            lblExpert_ForHours.Text = "&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;" + row["expert"].ToString();
            lblExpert.Text = "&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;" + row["expert"].ToString();
        }

        Image imgShowEmailInInternet = dv.FindControl("imgShowEmailInInternet") as Image;
        if (Convert.ToBoolean(row["showEmailInInternet"]) != true && row["email"].ToString() != string.Empty)
            imgShowEmailInInternet.Style.Add("display", "inline");
        else
            //imgShowEmailInInternet.Style.Add("display", "none");
            imgShowEmailInInternet.Visible = false;

        if (row["privateHospital"] != DBNull.Value)
        {
            Label lblHospital = dv.FindControl("lblHospitalDesc") as Label;
            lblHospital.Text = row["privateHospital"].ToString();
        }

        Label lblPosition = dv.FindControl("lblPositionDesc") as Label;
        int isSurgeon = Convert.ToInt32(row["IsSurgeon"]);
        
        if (row["privateHospitalPosition"] != DBNull.Value)
        {
            lblPosition.Text = row["privateHospitalPosition"].ToString();

            if (isSurgeon == 1)
            {
                lblPosition.Text += "," + ConstsSystem.SURGEON;
            }
        }
        else
        {
            if (isSurgeon == 1)
            {
                lblPosition.Text = ConstsSystem.SURGEON;
            }
        }

    }

    private void bindRemarks(DetailsView dv)
    {
        DataTable dtClinicsForRemarks = m_dsDoctor.Tables["clinicsForRemarks"];
        GridView gvClinicsForRemarks = dv.FindControl("gvClinicsForRemarks") as GridView;
        gvClinicsForRemarks.DataSource = dtClinicsForRemarks;
        gvClinicsForRemarks.DataBind();

    }

    protected void GvProfessions_RowDataBound_tmp(object sender, GridViewRowEventArgs e)
    {
        //GvEmployeeProfessions.Columns[0].ItemStyle.Width = Unit.Pixel(25);
        //GvEmployeeProfessions.Columns[1].ItemStyle.Width = Unit.Pixel(25);

        if (e.Row.RowType != DataControlRowType.DataRow)
            return;

        GridViewRow gvRow = e.Row as GridViewRow;
        Label lblProfessionCode = gvRow.FindControl("lblProfessionCode") as Label;
        Label lblSubProfessionCode = gvRow.FindControl("lblSubProfessionCode") as Label;
        Label lblProfessionServiceCode = gvRow.FindControl("lblProfessionServiceCode") as Label;
        Label lblProfessionDescription = gvRow.FindControl("lblProfessionDescription") as Label;
        Label lblSubProfessionDescription = gvRow.FindControl("lblSubProfessionDescription") as Label;
        Label lblProfessionServiceDescription = gvRow.FindControl("lblProfessionServiceDescription") as Label;
        Label lblExpProfession = gvRow.FindControl("lblExpProfession") as Label;
        Label lblParagraph = gvRow.FindControl("lblParagraph") as Label;

        if (currentProfessionCode != Convert.ToInt32(lblProfessionCode.Text))
        {
            printSubProfessionCaption = true;
            printProfessionServiceCaption = true;
            currentProfessionCode = Convert.ToInt32(lblProfessionCode.Text);
        }

        if (Convert.ToInt32(lblSubProfessionCode.Text) == 0 && Convert.ToInt32(lblProfessionServiceCode.Text) == 0)
        {
            lblSubProfessionDescription.Visible = false;
            lblProfessionServiceDescription.Visible = false;
            lblParagraph.Visible = false;
            //TableCell tblCell = lblProfessionDescription.Parent as TableCell;
            //tblCell.Style.Add("border_top","1px solid red");
        }
        else
        {
            lblProfessionDescription.Visible = false;
            lblExpProfession.Visible = false;

            if (Convert.ToInt32(lblSubProfessionCode.Text) == 0)
            {
                if (printProfessionServiceCaption)
                {
                    lblParagraph.Text = "שירותים:";
                    printProfessionServiceCaption = false;
                }

                lblSubProfessionDescription.Visible = false;
            }

            if (Convert.ToInt32(lblProfessionServiceCode.Text) == 0)
            {

                if (printSubProfessionCaption)
                {
                    lblParagraph.Text = "תתי התמחויות:";
                    printSubProfessionCaption = false;
                }

                lblProfessionServiceDescription.Visible = false;
            }
        }
    }

    protected void gvClinics_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        DataTable dt = new DataTable();

        if (e.Row.RowIndex != -1)
        {
            DataRowView drv = e.Row.DataItem as DataRowView;

            int rowInd = e.Row.DataItemIndex;
            int currDeptCode = Convert.ToInt32(drv["deptCode"]);

            HtmlTable tblEditButton = e.Row.FindControl("tblEditButton") as HtmlTable;
            ImageButton btnDeleteDoctorInClinic = e.Row.FindControl("btnDeleteDoctorInClinic") as ImageButton;
            if (currentUser != null)
            {
                if (applicFacade.IsDeptPermitted(currDeptCode) 
                    || currentUser.IsAdministrator)
                    tblEditButton.Visible = true;
                else
                    tblEditButton.Visible = false;

                if (currentUser.IsAdministrator)
                    btnDeleteDoctorInClinic.Style.Add("display", "inline");
                else
                    btnDeleteDoctorInClinic.Style.Add("display", "none");
            }
            else
            {
                tblEditButton.Visible = false;
            }

            GridView gvServices = e.Row.FindControl("gvServices") as GridView;
            dt = GetDataTableFromCSV(drv["services"].ToString());

            if(dt.Rows.Count > 0)
            {
                if (drv["services"].ToString() != string.Empty)
                {
                    DataView dv = new DataView(m_dsDoctor.Tables["DeptEmployeeServices"], " serviceCode IN (" + drv["services"] + ")", "serviceDescription", DataViewRowState.OriginalRows);

                    gvServices.DataSource = dv;
                    gvServices.DataBind();
                }
            }

            foreach (GridViewRow gvr in gvServices.Rows)
            {
                gvr.Cells[1].Visible = false;
            }

            GridView gvPositions = e.Row.FindControl("gvPositions") as GridView;
            dt = GetDataTableFromCSV(drv["positions"].ToString());
            if(dt.Rows.Count > 0)
            {
                gvPositions.DataSource = dt;
                gvPositions.DataBind();
            }

            // phones
            GridView gvPhone = e.Row.FindControl("gvPhone") as GridView;
            string deptEmployeePhones = drv["phonesOnly"].ToString();

            if (!string.IsNullOrEmpty(deptEmployeePhones))
            {
                DataTable phonesDt = GetDataTableFromCSV(deptEmployeePhones);
                if (phonesDt.Rows.Count > 0)
                {
                    gvPhone.DataSource = phonesDt;
                    gvPhone.DataBind();
                }
            }
            else
            {
                gvPhone.Visible = false;
            }

            // faxes
            string deptEmployeeFax = drv["fax"].ToString();
            GridView gvFax = e.Row.FindControl("gvFax") as GridView;

            if (!string.IsNullOrEmpty(deptEmployeeFax))
            {
                DataTable faxDt = GetDataTableFromCSV(deptEmployeeFax);             
                if (faxDt.Rows.Count > 0)
                {
                    gvFax.DataSource = faxDt;
                    gvFax.DataBind();
                }
            }
            else
            {
                gvFax.Visible = false;
            }

            if (drv["AgreementType"] != DBNull.Value)
            {
                Image imgAgreementType = e.Row.FindControl("imgAgreementType") as Image;
                eDIC_AgreementTypes agreementType = (eDIC_AgreementTypes)Enum.Parse(typeof(eDIC_AgreementTypes), drv["AgreementType"].ToString());
                UIHelper.SetImageForAgreementType(agreementType, imgAgreementType);
            }

            // Queue order methods
            string empServices = drv["Services"].ToString();            
            HtmlTableCell tdEmployeeQueueOrderMethods = e.Row.FindControl("tdEmployeeQueueOrderMethods") as HtmlTableCell;
            string QueueOrderDescription = drv["QueueOrderDescription"].ToString(); 
            DataView dvEmployeeQueueOrderMethods = new DataView();

            if (!string.IsNullOrEmpty(empServices))
            {
                dvEmployeeQueueOrderMethods = new DataView(m_dsDoctor.Tables["EmployeeQueueOrderMethods"],
                    "DeptEmployeeID = " + drv["DeptEmployeeID"] + " AND ServiceCode IN (" + empServices + ")",
                    "QueueOrderMethod", DataViewRowState.OriginalRows);
            }

            if (dvEmployeeQueueOrderMethods.Count == 0 && string.IsNullOrEmpty(QueueOrderDescription)) // check employee in dept queue order
            {
                dvEmployeeQueueOrderMethods = new DataView(m_dsDoctor.Tables["EmployeeQueueOrderMethods"],
                "DeptEmployeeID = " + drv["DeptEmployeeID"] + " AND ServiceCode  = 0",
                "QueueOrderMethod", DataViewRowState.OriginalRows);
            }

            List<int> queueOrderList = (from queueOrder in m_dsDoctor.Tables["EmployeeQueueOrderMethods"].AsEnumerable()
                                        where queueOrder.Field<int>("deptCode") == currDeptCode
                                        && 1 == 1 
                                        orderby queueOrder.Field<int>("queueOrderMethod")
                                        select queueOrder.Field<int>("queueOrderMethod")).ToList();

            int PermitOrderMethods = Convert.ToInt32(drv["PermitOrderMethods"]);

            if (queueOrderList.Count > 0)
                tdEmployeeQueueOrderMethods.InnerHtml = UIHelper.GetInnerHTMLForQueueOrder(dvEmployeeQueueOrderMethods,
                                                                                drv["ToggleID"].ToString(), null, null);
            else
                tdEmployeeQueueOrderMethods.InnerHtml = "<table cellpadding='0' cellspacing='0'><tr><td>" + QueueOrderDescription + "</td></tr></table>";

            // queue order phones and hours
            Label lblQueueOrderPhones = e.Row.FindControl("lblQueueOrderPhones") as Label;
            lblQueueOrderPhones.Text = drv["QueueOrderPhone"].ToString();

            GridView gvQueueOrderHours = e.Row.FindControl("gvQueueOrderHours") as GridView;
            DataView dvServiceQueueOrderHours = new DataView(m_dsDoctor.Tables["HoursForEmployeeQueueOrder"],
                "deptCode = " + drv["deptCode"], "receptionDay", DataViewRowState.OriginalRows);
            gvQueueOrderHours.DataSource = dvServiceQueueOrderHours;
            gvQueueOrderHours.DataBind();

            Image imgClock = e.Row.FindControl("imgClock") as Image;
            bool doctorHasReceptionHours = (Convert.ToInt32(drv["ReceptionDaysCount"]) > 0 ? true : false);
            bool doctorHasRemarks = (Convert.ToInt32(drv["RemarksCount"]) > 0 ? true : false);

            UIHelper.setClockRemarkImage(imgClock, doctorHasReceptionHours, doctorHasRemarks, "Green", "OpenDoctorReceptionWindow(" + drv["DeptEmployeeID"].ToString() + ",'" + empServices + "', null)", "", "", "");

            Image imgRecComm = e.Row.FindControl("imgRecepAndComment") as Image;

            bool clinicHasReceptionHours = (Convert.ToInt32(drv["ClinicReceptionDaysCount"]) > 0 ? true : false);
            bool clinicHasRemarks = false;
            if (Convert.ToInt32(drv["ShowRemarkPicture"]) > 0 && Convert.ToInt32(drv["ShowRemarkPicture"]) < 4)
            {
                clinicHasRemarks = true;
            }

            string ServiceCodes = "0";

            UIHelper.setClockRemarkImage(imgRecComm, clinicHasReceptionHours, clinicHasRemarks, "Blue",
                "return OpenReceptionWindowDialog(" + drv["deptCode"].ToString() + ",'" + ServiceCodes + "')",
                "הקש להצגת שעות קבלה", "הקש להצגת הערות", "הקש להצגת שעות קבלה והערות");

            Enums.Status currStatus = (Enums.Status)Enum.Parse(typeof(Enums.Status), drv["status"].ToString());

            if (currStatus == Enums.Status.NotActive)
            {
                e.Row.CssClass = "notActive";
            }

            Image imgReceiveGuests = e.Row.FindControl("imgReceiveGuests") as Image;

            if (Convert.ToInt32(drv["ReceiveGuests"]) == 1)
            {
                imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuests.png";
                imgReceiveGuests.ToolTip = "הרופא מקבל אורחים";
            }
            else if (Convert.ToInt32(drv["ReceiveGuests"]) == 0)
            {
                imgReceiveGuests.ImageUrl = "~/Images/Applic/NOTreceiveGuests.png";
                imgReceiveGuests.ToolTip = "הרופא אינו מקבל אורחים";
            }
            else if (Convert.ToInt32(drv["ReceiveGuests"]) == 2)
            {
                imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuestsPartTime.png";
                imgReceiveGuests.ToolTip = "הרופא מקבל אורחים לפעמים";
            }
            else if (Convert.ToInt32(drv["ReceiveGuests"]) == -1)
            {
                imgReceiveGuests.Visible = false;
            }

        }
    }

    private DataTable GetDataTableFromCSV(string stringCSV)
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("Column1", string.Empty.GetType());

        string[] itemsCSV = stringCSV.Split(',');

        for (int i = 0; i < itemsCSV.Length; i++)
        {
            dt.Rows.Add(new string[] { itemsCSV[i] });
        }

        return dt;
    }

    protected void updateAbsenceLink_Click(object sender, EventArgs e)
    {
        LinkButton updateAbsenceLink = sender as LinkButton;
        GridViewRow row = updateAbsenceLink.Parent.Parent as GridViewRow;
        int deptCode = Convert.ToInt32(row.Cells[0].Text);

        //update the deptcode field, in the object stored in session, with the selected deptcode
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();

        sessionParams.DeptCode = deptCode;
        sessionParams.EmployeeName = SessionParamsHandler.GetEmployeeNameFromSession();

        Response.Redirect("~/Admin/updateDoctorAbsence.aspx");
    }

    protected void btnUpdateAbsences_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Admin/UpdateDoctorAbsence.aspx",true);
    }

    protected void btnUpdateEmployee_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Admin/updateEmployee.aspx", true);
    }

    protected void btnUpdateEmployeeProfessionLicence_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Admin/updateEmployee.aspx?UpdateProfessionLicence=1", true);
    }
    protected void btnUpdateEmployeeHours_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Admin/updateEmployeeReception.aspx", true);
    }

    protected void btnUpdateEmployeeInDept_Click(object sender, EventArgs e)
    {
    /// It's essential now to be sure there is NO "current deptCode" in session 
    /// as at the page DoctorsInClinic.aspx where we redirect to an action will be taken 
    /// according to what we have in session: "deptCode" OR "employeeID"
        SessionParamsHandler.RemoveDeptCodeFromSession();

        Response.Redirect("~/Admin/DoctorsInClinic.aspx", true);
    }

    protected void dvDoctorDetails_DataBinding(object sender, EventArgs e)
    {
        DataRow row = m_dsDoctor.Tables[0].Rows[0];

        if (row["email"].ToString().Length > 0)
            row["email"] = "<a href='mailto:" + row["email"] + "'>" + row["email"] + "</a>";

    }

    protected void gvClinicsForRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            GridView gvRemarks = e.Row.FindControl("gvRemarks") as GridView;
            DataView dvDoctorRemarks = new DataView(m_dsDoctor.Tables["doctorRemarks"],
                "DeptCode =" + dvRowView["DeptCode"], null, DataViewRowState.CurrentRows);
            gvRemarks.DataSource = dvDoctorRemarks;
            gvRemarks.DataBind();
                
            Label lblClinicName = e.Row.FindControl("lblClinicName") as Label;
            lblClinicName.Text = "הערה ל" + lblClinicName.Text;

        }
    }

    protected void gvRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            Image imgInternet = e.Row.FindControl("imgInternet") as Image;
            if (Convert.ToBoolean(dvRowView["displayInInternet"]) != true)
            {
                imgInternet.Style.Add("display", "inline");
                imgInternet.ImageUrl = "../Images/Applic/pic_NotShowInInternet.gif";
                imgInternet.ToolTip = "לא תוצג באינטרנט";
            }
            else
            {
                //imgInternet.Style.Add("display", "none");
                imgInternet.Visible = false;
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

    protected void gvDoctorRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            Image imgInternet = e.Row.FindControl("imgInternet") as Image;
            if (Convert.ToBoolean(dvRowView["displayInInternet"]) == true)
            {
                imgInternet.Style.Add("display", "inline");
                //imgInternet.ImageUrl = "../Images/Applic/pic_ShowInInternet.gif";
                //imgInternet.ToolTip = "תצוגה באינטרנט";
            }
            else
            {
                //imgInternet.Style.Add("display", "none");
                imgInternet.Visible = false;
            }

        }
    }

    

    protected void gvEmployeeReceptionDays_All_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            GridView gvReceptionHours_All = (GridView)e.Row.FindControl("gvReceptionHours_All");
            DataTable tblDoctorReception = m_dsDoctor.Tables["doctorReceptionHours"];

            DataView dvReceptionHours;
            string strConditions = " receptionDay = " + dvRowView["receptionDay"].ToString();

            dvReceptionHours = new DataView(tblDoctorReception, strConditions, "openingHour", DataViewRowState.CurrentRows);

            if (dvReceptionHours.Count > 0)
            {
                gvReceptionHours_All.DataSource = dvReceptionHours;
                gvReceptionHours_All.DataBind();
            }
        }
    }

    protected void gvReceptionHours_All_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            HtmlTable gvReceptionHours_All = (HtmlTable)e.Row.FindControl("tblReceptionHours_Inner");
            DataTable tblDoctorReception = m_dsDoctor.Tables["doctorReceptionHours"];
            if (currentDayCode != 0 && currentDayCode == Convert.ToInt32(dvRowView["receptionDay"]))
                gvReceptionHours_All.Style.Add("border-top", "1px solid #DDDDDD");

            currentDayCode = Convert.ToInt32(dvRowView["receptionDay"]);

            if (Convert.ToInt32(dvRowView["willExpireIn"]) <= 14)
            {
                m_closestReceptionChange = Convert.ToDateTime(dvRowView["expirationDate"]);
                m_closestReceptionChange = m_closestReceptionChange.AddDays(1);
            }

            Label lblProfessions = e.Row.FindControl("lblProfessions") as Label;
            Label lblServices = e.Row.FindControl("lblServices") as Label;
            lblProfessions.Text = dvRowView["professions&services"].ToString().Split('#')[0];
            lblServices.Text = dvRowView["professions&services"].ToString().Split('#')[1];
        }
    }

    protected void btnEditDoctorInClinic_Click(object sender, EventArgs e)
    {
        Button btnEditDoctorInClinic = sender as Button;
        int deptEmployeeID = Convert.ToInt32(btnEditDoctorInClinic.Attributes["deptEmployeeID"]);

        Response.Redirect(@"~/Admin/UpdateDeptEmployee.aspx?DeptEmployeeID=" + deptEmployeeID, true);
    }

    protected void btnDeleteDoctorInClinic_Click(object sender, EventArgs e)
    {
        ImageButton btnDeleteDoctorInClinic = sender as ImageButton;
        int deptEmployeeID = Convert.ToInt32(btnDeleteDoctorInClinic.Attributes["DeptEmployeeID"]);
        int deptCode = Convert.ToInt32(btnDeleteDoctorInClinic.Attributes["deptCode"]);

        SeferNet.BusinessLayer.ObjectDataSource.DoctorsInClinicBO bo = new SeferNet.BusinessLayer.ObjectDataSource.DoctorsInClinicBO();

        bo.DeleteDoctorInClinic(deptEmployeeID, deptCode);

        txtTabToBeShown.Text = sessionParams.CurrentTab_ZoomDoctor;
    }

    protected void UpdateRemarks_click(object sender, EventArgs e)
    {
        Response.Redirect(@"~/Admin/UpdateEmployeeRemarks.aspx?EmployeeID=" + EmployeeID.ToString());
    }

    protected void AddRemarks_click(object sender, EventArgs e)
    {
        Response.Redirect(@"~/Admin/AddRemark.aspx?EmployeeID=" + EmployeeID.ToString());
    }

    protected void btnBack_Click(object sender, ImageClickEventArgs e)
    {
        sessionParams = SessionParamsHandler.GetSessionParams();

        if (sessionParams.LastSearchPageURL == null)    // is session expired?
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);

        Response.Redirect(sessionParams.LastSearchPageURL.ToString() + "?RepeatSearch=1", true);
    }
}

