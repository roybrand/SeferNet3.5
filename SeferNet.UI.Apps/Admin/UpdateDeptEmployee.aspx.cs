using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.FacadeLayer;
using SeferNet.UI;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;
using SeferNet.Globals;
using System.Web.UI.HtmlControls;
using System.Configuration;
using System.Text.RegularExpressions;

public partial class Admin_UpdateDeptEmployee : AdminBasePage
{
    private int m_deptEmployeeID;
    private bool IsDoctor;
    private bool HasServicesSubjectToReceiveGuest;
    DataTable phoneDt;
    DataTable faxDt;
    DataTable employeeServicePhones;
    DataTable employeeServiceQueueOrderMethod;
    DataTable employeeServiceQueueOrderHours;
    DataTable employeeServiceRemarks;
    SessionParams sessionParams;
    DataTable phonesBeforeUpdate;
    DataTable receptionHoursBeforeUpdate;

    public int DeptEmployeeID
    {
        get
        {
            return m_deptEmployeeID;
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

    public int DeptCode
    {
        get
        {
            if (ViewState["deptCode"] != null)
                return Convert.ToInt32(ViewState["deptCode"]);
            return 0;
        }
        set
        {
            ViewState["deptCode"] = value;
        }
    }

    public int DeptCodeForReceptionHoursControl
    {
        get
        {
            if (ViewState["DeptCodeForReceptionHoursControl"] != null)
                return Convert.ToInt32(ViewState["DeptCodeForReceptionHoursControl"]);
            return 0;
        }
        set
        {
            ViewState["DeptCodeForReceptionHoursControl"] = value;
        }
    }

    public int DeptCodeForReceptionHoursControl_DropDownListSelected
    {
        get
        {
            if (ViewState["DeptCodeForReceptionHoursControl_DropDownListSelected"] != null)
                return Convert.ToInt32(ViewState["DeptCodeForReceptionHoursControl_DropDownListSelected"]);
            return 0;
        }
        set
        {
            ViewState["DeptCodeForReceptionHoursControl_DropDownListSelected"] = value;
        }
    }

    public int AgreementType
    {
        get
        {
            if (ViewState["agreementType"] != null)
                return Convert.ToInt32(ViewState["agreementType"]);
            return 0;
        }
        set
        {
            ViewState["agreementType"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            //For each ascx page in this, need to add session for pass error if occur
            int errorNumber = Session["GridReceptionHoursUCErrorNumber"] != null ? int.Parse(Session["GridReceptionHoursUCErrorNumber"].ToString()) : 0;
            string errorMessage = Session["GridReceptionHoursUCErrorMessage"] != null ? Session["GridReceptionHoursUCErrorMessage"].ToString() : "";

            if (errorNumber != 0) displayError(errorMessage);

            sessionParams = SessionParamsHandler.GetSessionParams();
            GetQueryString();

            GetEmployeeProfessionsDetails();

            Session["EmployeeReceiveGuests"] = cbReceiveGuests.Checked;

            if (!IsPostBack)
            {
                BindAgreementTypeDropDown();
                GetEmployeeContactDetails();
                GetEmployeeServices();
                SetReceiveGuestsVisibility();
                
                Session["EmployeeReceiveGuests"] = cbReceiveGuests.Checked;

                if (!GetEmployeeStatus())
                {
                    SetControlsVisibilityByStatus(false);
                }
                else
                {
                    SetControlsVisibilityByStatus(true);
                }

                string onClickFunction = "UpdateEmployeeStatus('0');";
                //string onClick = "UpdateEmployeeStatus(" + lnkStatus.ClientID + ");";

                lnkStatus.Attributes.Add("onclick", onClickFunction);
                //lnkStatus.Attributes.Add("OnClientClick", "if (!UpdateEmployeeStatus('" + lnkStatus.ClientID + "')) return false;");

                DataSet EmployeeDepts = new DataSet();
                Facade.getFacadeObject().GetEmployeeDepts(ref EmployeeDepts, EmployeeID);

                if (EmployeeDepts.Tables[0].Rows.Count > 1)
                {
                    ViewState["EmployeeHasMoreThenOneClinic"] = true;

                    divReceptionInDeptBut_Tab.Visible = divReceptionInAllBut.Visible = false;
                    divReceptionInDeptBut.Visible = divReceptionInAllBut_Tab.Visible = true;
                    DeptCodeForReceptionHoursControl = -1;
                    DeptCodeForReceptionHoursControl_DropDownListSelected = DeptCode;
                }
                else
                {
                    ViewState["EmployeeHasMoreThenOneClinic"] = false;

                    divReceptionInDeptBut_Tab.Visible = divReceptionInAllBut.Visible = true;
                    divReceptionInDeptBut.Visible = divReceptionInAllBut_Tab.Visible = false;

                    DeptCodeForReceptionHoursControl = DeptCode;
                }

                if (Convert.ToBoolean(Session["IsMedicalTeam"]) || Convert.ToBoolean(Session["IsVirtualDoctor"]))
                {
                    divReceptionInDeptBut_Tab.Visible = divReceptionInAllBut.Visible = true;
                    divReceptionInDeptBut.Visible = divReceptionInAllBut_Tab.Visible = false;

                    DeptCodeForReceptionHoursControl = DeptCode;
                    ViewState["EmployeeIsMedicalTeamOrVirtualDoctor"] = true;
                }
                else
                {
                    ViewState["EmployeeIsMedicalTeamOrVirtualDoctor"] = false;
                }
                //gvReceptionHours.DataBind();

                BindReceptionHoursGridView();
                GetEmployeePhones();
                SetQueueOrderDetails();
                SetQueueOrderVisibility();
            }

            if (IsPostBack)
            {
                if (cbReceiveGuestsHasBeenChanged.Checked)
                {
                    Session["EmployeeReceiveGuestsToBeChangedTo"] = cbReceiveGuests.Checked;
                    cbReceiveGuestsHasBeenChanged.Checked = false;
                }

                if (cbRebindServices.Checked)
                {
                    BindEmployeeServices();
                    cbRebindServices.Checked = false;
                }
                if (cbRebindPhones.Checked)
                {
                    BindEmployeeServices();
                    cbRebindPhones.Checked = false;
                }
                // If GridReceptionHoursUC find txtParametersToCopyClinicHoursToEmployeeHours is not empty it will "copy clinic hours"
                if (txtParametersToCopyClinicHoursToEmployeeHours.Text != string.Empty)
                {
                    Session["ParametersToCopyClinicHoursToEmployeeHours"] = txtParametersToCopyClinicHoursToEmployeeHours.Text;
                    txtParametersToCopyClinicHoursToEmployeeHours.Text = string.Empty;
                }
            }
        }
        catch(Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.Page_Load", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    private void SetControlsVisibilityByStatus(bool active)
    {
        if (active)
        {
            trReceptionHours.Style.Add("display", "block");
            trPreviewFutureHours.Style.Add("display", "block");
            trServicesHeader.Style.Add("display", "block");
            trServices.Style.Add("display", "block");
            tblBtnAddService.Style.Add("display", "block");

            trInsteadReceptionHours.Style.Add("display", "none");
            trInsteadServices.Style.Add("display", "none");
        }
        else
        {
            trReceptionHours.Style.Add("display", "none");
            trPreviewFutureHours.Style.Add("display", "none");
            trServicesHeader.Style.Add("display", "none");
            trServices.Style.Add("display", "none");
            tblBtnAddService.Style.Add("display", "none");

            trInsteadReceptionHours.Style.Add("display", "block");
            trInsteadServices.Style.Add("display", "block");
        }

    }

    private void BindAgreementTypeDropDown()
    {
        Dept currentEmployeeDept = Facade.getFacadeObject().GetDeptGeneralBelongingsByEmployee(DeptEmployeeID);
        DeptCode = currentEmployeeDept.DeptCode;

        Facade applicFacade = Facade.getFacadeObject();
        DataTable dt = applicFacade.GetAgreementTypes();

        foreach (DataRow dr in dt.Rows)
        {
            if (currentEmployeeDept.IsCommunity)
            {
                if (int.Parse(dr["OrganizationSectorID"].ToString()) == (int)Enums.SearchMode.Community)
                {
                    ddlAgreementType.Items.Add(new ListItem(dr["AgreementTypeDescription"].ToString(), dr["AgreementTypeID"].ToString()));
                }
            }
            if (currentEmployeeDept.IsMushlam)
            {
                if (int.Parse(dr["OrganizationSectorID"].ToString()) == (int)Enums.SearchMode.Mushlam)
                {
                    ddlAgreementType.Items.Add(new ListItem(dr["AgreementTypeDescription"].ToString(), dr["AgreementTypeID"].ToString()));
                }
            }
            if (currentEmployeeDept.IsHospital)
            {
                if (int.Parse(dr["OrganizationSectorID"].ToString()) == (int)Enums.SearchMode.Hospitals)
                {
                    ddlAgreementType.Items.Add(new ListItem(dr["AgreementTypeDescription"].ToString(), dr["AgreementTypeID"].ToString()));
                }
            }

        }

        ddlAgreementType.Attributes.Add("onChange", "OnAgreementTypeSelectedIndexChange();");

    }

    private void GetEmployeeServices()
    {
        BindEmployeeServices();
        CheckReceptionHoursEnable();
    }

    private void CheckReceptionHoursEnable()
    {
        if (gvServices.Rows.Count == 0)
        {
            pnlReceptionHours.Enabled = false;
        }
        else
        {
            pnlReceptionHours.Enabled = true;
        }
    }

    private bool GetEmployeeStatus()
    {
        DoctorsInClinicBO bo = new DoctorsInClinicBO();
        DataSet ds = bo.GetCurrentStatusForEmployeeInDept(DeptEmployeeID);

        if (ds != null && ds.Tables[0].Rows.Count > 0)
        {
            lnkStatus.Text = ds.Tables[0].Rows[0]["StatusDescription"].ToString();
            if (Convert.ToBoolean(ds.Tables[0].Rows[0]["active"]))
                return true;
            else
                return false;
        }
        else
        {
            lnkStatus.Text = "לא הוגדר";
            return false;
        }
    }

    private void SetDeptPhones()
    {
        DeptPhonesBO bo = new DeptPhonesBO();
        DataSet ds = bo.GetDeptMainPhones(DeptCode);

        BindPhoneDetails(ds);
    }

    private void BindReceptionHoursGridView()
    {
        DataSet receptionDs = new DataSet();
        //DataSet EmployeeDepts = new DataSet();
        bool isVirtualDoctor = false, isMedicalTeam = false;
        ReceptionHoursManager receptionManager = new ReceptionHoursManager();

        //Facade.getFacadeObject().IsVirtualDoctorOrMedicalTeam(EmployeeID, ref isVirtualDoctor, ref isMedicalTeam);

        //Facade.getFacadeObject().GetEmployeeDepts(ref EmployeeDepts, EmployeeID);
        //if (EmployeeDepts.Tables[0].Rows.Count > 1)
        //    gvReceptionHours.EmployeeHasMoreThenOneClinic = true;
        //else
        //    gvReceptionHours.EmployeeHasMoreThenOneClinic = false;

        isMedicalTeam = Convert.ToBoolean(Session["IsMedicalTeam"]);
        isVirtualDoctor = Convert.ToBoolean(Session["IsVirtualDoctor"]);

        if (isMedicalTeam || isVirtualDoctor) // if it's medical team don't show other depts hours
        {
            Facade.getFacadeObject().GetEmployeeReceptions(ref receptionDs, EmployeeID, DeptCode);
            btnReceptionInAllTab.Enabled = false;
            btnReceptionInAllTab.Style.Add("cursor", "default");
        }
        else
        {
            if (ViewState["EmployeeHasMoreThenOneClinic"] != null && !Convert.ToBoolean(ViewState["EmployeeHasMoreThenOneClinic"]))
            {
                Facade.getFacadeObject().GetEmployeeReceptions(ref receptionDs, EmployeeID, DeptCode);
                btnReceptionInAllTab.Enabled = false;
                btnReceptionInAllTab.Style.Add("cursor", "default");
            }
            else 
            {
                Facade.getFacadeObject().GetEmployeeReceptions(ref receptionDs, EmployeeID);            
            }
        }

        DataTable inputDt = receptionDs.Tables[0];
        DataTable groupingDt = receptionDs.Tables[1];

        ViewState["receptionHoursBeforeUpdate"] = inputDt;

        //DataTable viewTbl = receptionManager.GenerateGridTable(ref inputDt, ref groupingDt);

        gvReceptionHours.EnableHoursOverlapp = (isVirtualDoctor || isMedicalTeam);
        gvReceptionHours.EmployeeID = EmployeeID;
        //gvReceptionHours.SourceData = viewTbl;
        gvReceptionHours.ReceptionHoursOfDoctor = IsDoctor;
        gvReceptionHours.HasServicesSubjectToReceiveGuest = HasServicesSubjectToReceiveGuest;
        gvReceptionHours.dtOriginalData = receptionDs.Tables[0];
        gvReceptionHours.Dept = DeptCodeForReceptionHoursControl;//DeptCode;
        gvReceptionHours.DeptCodeForReceptionHoursControl_DropDownListSelected = DeptCodeForReceptionHoursControl_DropDownListSelected;
        gvReceptionHours.EmployeeIsMedicalTeamOrVirtualDoctor = Convert.ToBoolean(ViewState["EmployeeIsMedicalTeamOrVirtualDoctor"]);
        gvReceptionHours.EmployeeHasMoreThenOneClinic = Convert.ToBoolean(ViewState["EmployeeHasMoreThenOneClinic"]);
        gvReceptionHours.DataBind();

    }

    private void GetEmployeeProfessionsDetails()
    {
        EmployeeProfessionInDeptBO bo = new EmployeeProfessionInDeptBO();
        //string professionsString = string.Empty, servicesString = string.Empty ,positionsString = string.Empty;
        string positionsString = string.Empty;
        DataSet ds;

        // positions
        EmployeePositionsBO positionsBo = new EmployeePositionsBO();
        ds = positionsBo.GetEmployeePositionsInDept(m_deptEmployeeID);

        if (ds != null && ds.Tables[0].Rows.Count > 0)
        {
            positionsString = GetDelimitedContentFromTable(ds.Tables[0], "positionDescription");
        }

        txtPositions.Text = positionsString;
    }

    private string GetDelimitedContentFromTable(DataTable dt, string columnName)
    {
        string returnStr = string.Empty;

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (dt.Columns.Contains("LinkedToEmpInDept"))
            {
                if (Convert.ToBoolean(dt.Rows[i]["LinkedToEmpInDept"]))
                {
                    returnStr += dt.Rows[i][columnName].ToString() + "; ";
                }
            }
            else
            {
                returnStr += dt.Rows[i][columnName].ToString() + "; ";
            }
        }


        if (!string.IsNullOrEmpty(returnStr))
        {
            returnStr.Substring(0, returnStr.LastIndexOf(";") + 1);
        }

        return returnStr;
    }

    /// <summary>
    /// gets the query string and set the page members
    /// </summary>
    private void GetQueryString()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["DeptEmployeeID"]))
        {
            string[] splitParam = Request.QueryString["DeptEmployeeID"].Split('_');
            if (splitParam.Length > 1)
            {
                m_deptEmployeeID = Convert.ToInt32(splitParam[0]);
                sessionParams.RowID = Convert.ToInt32(splitParam[1]);
            }
            else
            {
                m_deptEmployeeID = Convert.ToInt32(Request.QueryString["DeptEmployeeID"]);
            }
        }
    }

    /// <summary>
    /// gets employee phones,and bind the phone and fax controls
    /// </summary>
    private void GetEmployeePhones()
    {
        DeptEmoloyeePhonesBO bo = new DeptEmoloyeePhonesBO();

        DataSet ds = bo.GetDeptEmployeePhones(DeptEmployeeID);

        BindPhoneDetails(ds);

        if (!chkShowPhonesFromDept.Checked)
            ViewState["phonesBeforeUpdate"] = ds.Tables[0];
    }

    private void BindPhoneDetails(DataSet ds)
    {
        DataRow currRow;
        DataTable phoneDt = new DataTable();
        DataTable faxDt = new DataTable();

        Phone.CreateTableStructure(ref phoneDt);
        Phone.CreateTableStructure(ref faxDt);

        if (ds.Tables[0].Rows.Count > 0)
        {

            // check if it's dept original phone
            if (ds.Tables[0].Columns.Contains("IsOriginalDeptPhone"))
            {
                chkShowPhonesFromDept.Checked = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsOriginalDeptPhone"]);

            }

            pnlPhones.Enabled = !chkShowPhonesFromDept.Checked;

            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                currRow = ds.Tables[0].Rows[i];
                if (currRow["phoneType"].ToString() == "1")     // it's a phone
                {
                    phoneDt.ImportRow(currRow);
                }
                else                                            // it's a fax
                {
                    faxDt.ImportRow(currRow);
                }
            }
        }
        else
        {
            phoneDt.Rows.Add(phoneDt.NewRow());
            faxDt.Rows.Add(faxDt.NewRow());
        }

        if(phoneDt.Rows.Count == 0)
            phoneDt.Rows.Add(phoneDt.NewRow());

        if(faxDt.Rows.Count == 0)
            faxDt.Rows.Add(faxDt.NewRow());

        phoneUC.LabelTitle.Text = ":טלפונים";
        phoneUC.SourcePhones = phoneDt;
        phoneUC.EnableBlankData = true;
        phoneUC.DataBind();

        faxUC.LabelTitle.Text = ":פקסים";
        faxUC.SourcePhones = faxDt;
        faxUC.EnableBlankData = true;
        faxUC.DataBind();
    }

    private void SetQueueOrderDetails()
    {
        QueueOrderMethodBO queueBo = new QueueOrderMethodBO();

        lblQueuePhones.Text = string.Empty;

        // get queue order details
        DataSet ds = queueBo.GetEmployeeQueueOrderDescription(DeptCode, EmployeeID);

        if (ds != null)
        {
            DataTable dt = ds.Tables[0];
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                lblQueuePhones.Text += dt.Rows[i]["QueueOrderDescription"].ToString() + " , ";
            }
            if (lblQueuePhones.Text.Length > 1)
            {
                lblQueuePhones.Text = lblQueuePhones.Text.Substring(0, lblQueuePhones.Text.Length - 2);
            }
        }
    }

    private void GetEmployeeContactDetails()
    {
        DataSet ds = Facade.getFacadeObject().GetEmployeeInDeptDetails(DeptEmployeeID);
        DataTable dt;

        if (ds != null && ds.Tables[0].Rows.Count > 0)
        {
            dt = ds.Tables[0];
            Session["doctorDetails"] = dt;
            EmployeeID = Convert.ToInt64(dt.Rows[0]["EmployeeID"]);
            AgreementType = Convert.ToInt32(dt.Rows[0]["agreementType"]);
            lblPersonName.Text = dt.Rows[0]["DoctorsName"].ToString();
            lblSector.Text = dt.Rows[0]["EmployeeSectorDescription"].ToString();
            lblReceptionInDeptTab.Text = btnReceptionInDeptTab.Text = "שעות קבלה במרפאה " + dt.Rows[0]["deptName"].ToString();

            if (dt.Rows[0]["agreementType"] != DBNull.Value)
            {
                ddlAgreementType.SelectedValue = dt.Rows[0]["agreementType"].ToString();
                txtAgreementType.Text = dt.Rows[0]["agreementType"].ToString();
            }

            Session["IsMedicalTeam"] = dt.Rows[0]["IsMedicalTeam"];
            Session["IsVirtualDoctor"] = dt.Rows[0]["IsVirtualDoctor"];

            cbReceiveGuests.Checked = Convert.ToBoolean(dt.Rows[0]["ReceiveGuests"]);

            if (Convert.ToInt32(dt.Rows[0]["IsDoctor"]) != 1)
            {
                IsDoctor = false;
            }
            else
            {
                IsDoctor = true;
            }
        }

        ds = Facade.getFacadeObject().GetEmployeeProfessionsPerDept(DeptEmployeeID);
        if (ds != null)
        {
            string doctorSpec = string.Empty;
            dt = ds.Tables[0];

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (!string.IsNullOrEmpty(dt.Rows[i]["ProfessionDescription"].ToString()))
                {
                    doctorSpec += dt.Rows[i]["ProfessionDescription"].ToString() + ",";
                }
            }
            if (string.IsNullOrEmpty(doctorSpec))
            {
                lblSpecialityHeader.Visible = false;
            }
            else
            {
                lblSpecialityHeader.Visible = true;
                if (doctorSpec.Length > 80)
                {
                    lblSpeciality.Text = doctorSpec.Substring(0, doctorSpec.IndexOf(',', 70)) + "...";
                }
                else
                { 
                    lblSpeciality.Text = doctorSpec.Substring(0, doctorSpec.Length - 1);
                }
            }
        }

    }

    private void SetReceiveGuestsVisibility()
    {
        if (!IsDoctor || !HasServicesSubjectToReceiveGuest)
        {
            cbReceiveGuests.Style.Add("display", "none");
        }
    }

    protected void ShowReceptionPreview(object sender, EventArgs e)
    {
        try
        {
            DataRow[] rows;

            string pageUrl = "ReceptionHoursPreview.aspx?Employee=1";

            Session["ReceptionHours"] = null;
            DataTable receptionDt = gvReceptionHours.ReturnData();

            if (receptionDt != null)
            {
                if (gvReceptionHours.Dept != -1)
                {
                    rows = receptionDt.Select("DeptCode=" + DeptCode.ToString());
                    if (rows.Length > 0)
                    {
                        Session["ReceptionHours"] = rows.CopyToDataTable();
                    }

                    pageUrl += "&DeptCode=" + gvReceptionHours.Dept.ToString();
                }
                else
                {
                    rows = receptionDt.Select("ReceptionID IS NOT NULL OR ADD_ID IS NOT NULL");
                    Session["ReceptionHours"] = rows.CopyToDataTable();
                }
            }

            ScriptManager.RegisterStartupScript(this, this.GetType(), "preview", "OpenReceptionHoursPreview('" + pageUrl + "');", true);
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.ShowReceptionPreview", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    private void DeleteEmployeeService(int serviceCode)
    {
        EmployeeServiceInDeptBO bo = new EmployeeServiceInDeptBO();
        bo.DeleteDeptEmployeeService(DeptEmployeeID, serviceCode);

        UserInfo currentUser = new UserManager().GetUserInfoFromSession();

        Facade.getFacadeObject().Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicService_Delete, currentUser.UserID, DeptCode, null, DeptEmployeeID, null, null, serviceCode, null);            

        BindEmployeeServices();
        ReBindProfessionsAndServices();
    }

    private void BindEmployeeServices()
    {
        EmployeeServiceInDeptBO bo = new EmployeeServiceInDeptBO();

        DataSet ds = bo.GetEmployeeServicesInDept(DeptEmployeeID);

        employeeServiceQueueOrderMethod = ds.Tables[1];
        employeeServicePhones = ds.Tables[2];

        employeeServiceQueueOrderHours = ds.Tables[3];

        employeeServiceRemarks = ds.Tables[4];


        HasServicesSubjectToReceiveGuest = false;

        if (ds != null)
        {
            gvServices.DataSource = ds.Tables[0];
            gvServices.DataBind();

            if (ds.Tables[0].Rows.Count == 0)
            {
                pnlServicesHeader.Visible = false;

                pnlQueueOrder.Visible = false;
                rqdQueueOrder.Enabled = false;
            }
            else
            {
                pnlServicesHeader.Visible = true;

                pnlQueueOrder.Visible = true;
                rqdQueueOrder.Enabled = true;


                string ServicesToReceiveGuests = ConfigurationManager.AppSettings["ServicesRelevantForReceivingGuests"].ToString();

                var relevantServices = ServicesToReceiveGuests.Split(',');

                for (int i = 0; i < relevantServices.Length; i++)
                {
                    for (int ii = 0; ii < ds.Tables[0].Rows.Count; ii++)
                    {
                        if (relevantServices[i] == ds.Tables[0].Rows[ii]["serviceCode"].ToString())
                        {
                            HasServicesSubjectToReceiveGuest = true;
                        }
                    }
                }

            }

        }
        else
        {
            pnlServicesHeader.Visible = false;

            pnlQueueOrder.Visible = false;
            rqdQueueOrder.Enabled = false;
        }
    }

    protected void AddRemark(int serviceCode, int? remarkID)
    {
        try
        {
            if (remarkID == null)
            {
                Response.Redirect("AddRemark.aspx?EmployeeID=" + EmployeeID + "&ServiceCode=" + serviceCode + "&DeptCode=" + DeptCode + "&DeptEmployeeID=" + DeptEmployeeID, false);
            }
            else
            {
                Response.Redirect("AddRemark.aspx?EmployeeID=" + EmployeeID + "&ServiceCode=" + serviceCode + "&DeptCode=" + DeptCode + "&DeptEmployeeID=" + DeptEmployeeID + "&RemarkID=" + remarkID, false);
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.AddRemark", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void UpdateEmployeeServiceRemarks(int serviceCode)
    {
        try
        {
            Response.Redirect("UpdateEmployeeServiceRemarks.aspx?EmployeeID=" + EmployeeID + "&ServiceCode=" + serviceCode + "&DeptCode=" + DeptCode + "&DeptEmployeeID=" + DeptEmployeeID, false);
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.UpdateEmployeeServiceRemarks", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    #region Events

    protected void btnReceptionInAllTab_Click(object sender, EventArgs e)
    {
        try
        {
            divReceptionInDeptBut_Tab.Visible = divReceptionInAllBut.Visible = false;
            divReceptionInDeptBut.Visible = divReceptionInAllBut_Tab.Visible = true;
            gvReceptionHours.Dept = -1;
            gvReceptionHours.DataBind();
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.btnReceptionInAllTab_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void btnReceptionInDeptTab_Click(object sender, EventArgs e)
    {
        try
        {
            divReceptionInDeptBut_Tab.Visible = divReceptionInAllBut.Visible = true;
            divReceptionInDeptBut.Visible = divReceptionInAllBut_Tab.Visible = false;
            gvReceptionHours.Dept = DeptCode;
            gvReceptionHours.DataBind();
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.btnReceptionInDeptTab_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void RebindStatus(object sender, EventArgs e)
    {
        try
        {
            RebindReceptionGrid(null, null);

            if (!GetEmployeeStatus())
            {
                SetControlsVisibilityByStatus(false);
            }
            else
            {
                SetControlsVisibilityByStatus(true);
            }

            BindReceptionHoursGridView();
            BindEmployeeServices();
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.RebindStatus", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            bool isPhoneOrFaxValid = this.checkPhoneOrFaxValid();
            
            ClientScript.RegisterStartupScript(typeof(string), "hideProgressBar", " hideProgressBarGeneral()", true);

            /*if (isPhoneOrFaxValid == false && chkShowPhonesFromDept.Checked == false)
            {
                redirect(1, "יש למלא טלפון או פקס");

                return;
            }*/

            if (Page.IsValid)
            {
                UserInfo currentUser = new UserManager().GetUserInfoFromSession();
                bool success = false;

                if (currentUser == null)
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('עבר זמן רב מדי. עליך להזדהות שנית');");
                    Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, false);
                }

                if (!chkShowPhonesFromDept.Checked)
                {
                    phoneDt = phoneUC.ReturnData();
                    for (int i = 0; i < phoneDt.Rows.Count; i++)
                    {
                        phoneDt.Rows[i]["PhoneType"] = "1";
                    }

                    faxDt = faxUC.ReturnData();
                    for (int i = 0; i < faxDt.Rows.Count; i++)
                    {
                        faxDt.Rows[i]["PhoneType"] = "2";
                    }

                    phoneDt.Merge(faxDt);
                }

                DataTable dt = gvReceptionHours.ReturnData();
                int agreementType_Old = Convert.ToInt32(txtAgreementType.Text);
                int agreementType_new = Convert.ToInt32(ddlAgreementType.SelectedValue);

                success = Facade.getFacadeObject().UpdateEmployeeReceptionsAndDetailesInDept(EmployeeID, DeptCode, DeptEmployeeID, agreementType_Old, agreementType_new, cbReceiveGuests.Checked, dt, phoneDt, chkShowPhonesFromDept.Checked, currentUser.UserNameWithPrefix);

                if (ViewState["phonesBeforeUpdate"] != null)
                    phonesBeforeUpdate = (DataTable)ViewState["phonesBeforeUpdate"];

                if (ViewState["receptionHoursBeforeUpdate"] != null)
                    receptionHoursBeforeUpdate = (DataTable)ViewState["receptionHoursBeforeUpdate"];

                if (success && Whether_phones_changed(phonesBeforeUpdate, phoneDt))
                {
                    Facade.getFacadeObject().Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicPhone_Update, currentUser.UserID, DeptCode, null, DeptEmployeeID, null, null, null, null);
                }

                if (success)
                {
                    Report_hours_change(ref receptionHoursBeforeUpdate, ref dt);
                }

                RedirectToParentPage();
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.btnSave_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    private void redirect(int errorNumber, string errorMessage)
    {
        string url = Request.Url.AbsoluteUri;

        Session["GridReceptionHoursUCErrorNumber"] = errorNumber.ToString();
        Session["GridReceptionHoursUCErrorMessage"] = errorMessage;

        Response.Redirect(url, false);
    }

    private bool Whether_phones_changed(DataTable tblBefore, DataTable tblAfter)
    {
        bool hasChanged = true;

        if (tblBefore == null && tblAfter == null)
        {
            return false; 
        }

        if ((tblBefore == null && tblAfter != null) || (tblBefore != null && tblAfter == null) )
        {
            return true; 
        }

        if (tblBefore.Rows.Count != tblAfter.Rows.Count)
        {
            hasChanged = true;
        }
        else 
        {
            for (int i = 0; i < tblBefore.Rows.Count; i++ )
            {
                hasChanged = true;

                for (int ii = 0; ii < tblAfter.Rows.Count; ii++ )
                {
                    if (tblBefore.Rows[i]["phoneType"].ToString() == tblAfter.Rows[ii]["phoneType"].ToString() &&
                        tblBefore.Rows[i]["phoneOrder"].ToString() == tblAfter.Rows[ii]["phoneOrder"].ToString() &&
                        tblBefore.Rows[i]["prePrefix"].ToString() == tblAfter.Rows[ii]["prePrefix"].ToString() &&
                        tblBefore.Rows[i]["prefixCode"].ToString() == tblAfter.Rows[ii]["prefixCode"].ToString() &&
                        tblBefore.Rows[i]["phone"].ToString() == tblAfter.Rows[ii]["phone"].ToString() &&
                        tblBefore.Rows[i]["extension"].ToString() == tblAfter.Rows[ii]["extension"].ToString() 
                        )

                        hasChanged = false;
                }

                if (hasChanged == true)
                    return hasChanged;
            }
        }

        return hasChanged;
    }

    private bool Report_hours_change(ref DataTable tblBefore, ref DataTable tblAfter)
    {
        bool hasChanged = false;
        bool ReceptionID_WasFoundInNewTable = false;
        string remarkBefore, remarkAfter;
        string deptsWhereReceptionsHasBeenChanged = string.Empty;

        UserInfo currentUser = Session["currentUser"] as UserInfo;

        if (tblBefore == null && tblAfter == null)
        {
            return false;
        }

        for (int i = 0; i < tblBefore.Rows.Count; i++)
        {
            hasChanged = true;
            ReceptionID_WasFoundInNewTable = false;

            if (tblBefore.Rows[i]["receptionID"] == DBNull.Value)
                continue;

            for (int ii = 0; ii < tblAfter.Rows.Count; ii++)
            {
                if (tblAfter.Rows[ii]["receptionID"] == DBNull.Value)
                    continue;

                if (tblBefore.Rows[i]["RemarkText"] == DBNull.Value)
                    remarkBefore = string.Empty;
                else
                    remarkBefore = tblBefore.Rows[i]["RemarkText"].ToString();

                if (tblAfter.Rows[ii]["RemarkText"] == DBNull.Value)
                    remarkAfter = string.Empty;
                else
                    remarkAfter = tblAfter.Rows[ii]["RemarkText"].ToString();

                if (Convert.ToInt32(tblBefore.Rows[i]["receptionID"]) == Convert.ToInt32(tblAfter.Rows[ii]["receptionID"]))
                {
                    if ((Convert.ToInt32(tblBefore.Rows[i]["ItemID"]) != Convert.ToInt32(tblAfter.Rows[ii]["ItemID"]) ||
                        Convert.ToInt16(tblBefore.Rows[i]["receptionDay"]) != Convert.ToInt16(tblAfter.Rows[ii]["receptionDay"]) ||

                        tblBefore.Rows[i]["openingHour"].ToString() != tblAfter.Rows[ii]["openingHour"].ToString() ||
                        tblBefore.Rows[i]["closingHour"].ToString() != tblAfter.Rows[ii]["closingHour"].ToString() ||
                        tblBefore.Rows[i]["ReceptionRoom"].ToString() != tblAfter.Rows[ii]["ReceptionRoom"].ToString() ||
                        tblBefore.Rows[i]["ReceiveGuests"].ToString() != tblAfter.Rows[ii]["ReceiveGuests"].ToString() ||

                        remarkBefore != remarkAfter))
                    {
                        if (deptsWhereReceptionsHasBeenChanged.IndexOf(tblBefore.Rows[i]["DeptCode"].ToString()) == -1)
                            deptsWhereReceptionsHasBeenChanged += tblBefore.Rows[i]["DeptCode"].ToString() + ",";
                    }

                    ReceptionID_WasFoundInNewTable = true;
                }

            }

            if (!ReceptionID_WasFoundInNewTable)
            {
                if (deptsWhereReceptionsHasBeenChanged.IndexOf(tblBefore.Rows[i]["DeptCode"].ToString()) == -1)
                    deptsWhereReceptionsHasBeenChanged += tblBefore.Rows[i]["DeptCode"].ToString() + ",";
            }
        }

        if(tblAfter != null)
        {
            for (int ii = 0; ii < tblAfter.Rows.Count; ii++)
            {
                if (tblAfter.Rows[ii]["Add_ID"] != DBNull.Value && tblAfter.Rows[ii]["openingHour"].ToString() != string.Empty)
                {
                    if (deptsWhereReceptionsHasBeenChanged.IndexOf(tblAfter.Rows[ii]["DeptCode"].ToString()) == -1)
                        deptsWhereReceptionsHasBeenChanged += tblAfter.Rows[ii]["DeptCode"].ToString() + ",";
                }
            }
        }

        // Log changes if needed
        if (deptsWhereReceptionsHasBeenChanged.Length > 0)
        {
            deptsWhereReceptionsHasBeenChanged = deptsWhereReceptionsHasBeenChanged.Substring(0, deptsWhereReceptionsHasBeenChanged.Length - 1);
            string[] deptsList = deptsWhereReceptionsHasBeenChanged.Split(',');

            for (int i = 0; i < deptsList.Length; i++)
            {
                Facade.getFacadeObject().Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicHoursAndRemark_Update, currentUser.UserID, Convert.ToInt32(deptsList[i]), EmployeeID, -1, null, null, null, null);
            }
        }

        return hasChanged;

    }

    private void RedirectToParentPage()
    {
        string selTab = "";
        string srcTop = "";
        if (sessionParams != null && sessionParams.CallerUrl != null)
        {
            sessionParams.EmployeeID = EmployeeID;

            if (sessionParams.ServiceCode != 0 && sessionParams.ServiceCode != null)
            {
                sessionParams.MarkServiceInClinicSelected = true;
            }
            else
            {
                sessionParams.MarkEmployeeInClinicSelected = true;
            }

            if (Request.QueryString["seltab"] != null)
            {
                selTab = "&seltab=" + Request.QueryString["seltab"].ToString();
                if (Request.QueryString["scrtop"] != null)
                {
                    srcTop = "&scrtop=" + Request.QueryString["scrtop"].ToString();
                }
                string[] splitRef = sessionParams.CallerUrl.Split('?');
                splitRef[1] = RequestHelper.removeFromQueryString(splitRef[1], "seltab");
                splitRef[1] = RequestHelper.removeFromQueryString(splitRef[1], "scrtop");
                sessionParams.CallerUrl = splitRef[0] + "?" + splitRef[1] + selTab + srcTop;
            }
            Response.Redirect(sessionParams.CallerUrl, false);
        }
        else
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, false);

    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        try
        {
            RedirectToParentPage();
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.btnCancel_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void RebindReceptionGrid(object sender, EventArgs e)
    {
        try
        {
            ReBindProfessionsAndServices();
            SetQueueOrderDetails();
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.RebindReceptionGrid", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void UpdateEmployeeServices(object sender, EventArgs e)
    {
        try
        {
            bool result = false;

            Facade facade = Facade.getFacadeObject();
            string seperatedValues = txtServiceCodes.Text;
            UserInfo currentUser = new UserManager().GetUserInfoFromSession();

            result = facade.UpdateEmployeeServicesInDept(m_deptEmployeeID, seperatedValues, currentUser.UserNameWithPrefix, DeptCode);

            if (result)
            {
                if (ViewState["ServiceSeparatedValuesBefore"] != null)
                {
                    string[] ServiceSeparatedValuesBefore = ViewState["ServiceSeparatedValuesBefore"].ToString().Split(',');
                    string[] ServiceSeparatedValuesAfter = seperatedValues.Split(',');
                    for (int i = 0; i < ServiceSeparatedValuesAfter.Count(); i++)
                    {
                        string newServiceCode = ServiceSeparatedValuesAfter[i];

                        for (int ii = 0; ii < ServiceSeparatedValuesBefore.Count(); ii++)
                        {
                            if (ServiceSeparatedValuesAfter[i] == ServiceSeparatedValuesBefore[ii])
                            {
                                newServiceCode = string.Empty;
                            }
                        }

                        if (newServiceCode != string.Empty)
                            facade.Insert_LogChange((int)SeferNet.Globals.Enums.ChangeType.EmployeeInClinicService_Add, currentUser.UserID, DeptCode, null, DeptEmployeeID, -1, null, Convert.ToInt32(newServiceCode), null);

                    }
                }

                RebindServicesGrid("UpdateEmployeeServices", null);
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.UpdateEmployeeServices", exception.ToString());
            this.displayError(exception.Message);
        }
    }
    
    protected void RebindServicesGrid(object sender, EventArgs e)
    {
        try
        {
            GetEmployeeServices();
            ReBindProfessionsAndServices();
            SetQueueOrderDetails();
            BindReceptionHoursGridView();
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.RebindServicesGrid", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    private void ReBindProfessionsAndServices()
    {
        DataSet receptionDs = new DataSet();
        ReceptionHoursManager receptionManager = new ReceptionHoursManager();

        Facade.getFacadeObject().GetEmployeeReceptions(ref receptionDs, EmployeeID, DeptCode);
        DataTable newProfessionsAndServicesDt = receptionManager.GetProfessionsAndServicesList(receptionDs.Tables[0]);

        if (newProfessionsAndServicesDt.Rows.Count > 0)
        {
            gvReceptionHours.UpdateControl(newProfessionsAndServicesDt);
        }

        CheckReceptionHoursEnable();

    }

    private void SetQueueOrderVisibility()
    {
        EmployeeBO empBO = new EmployeeBO();
        //bool isEmployeeDoctor = empBO.IsEmployeeDoctor(EmployeeID); not in use so no need right now - ran
        bool queueOrderIsMandatory;

        pnlQueueOrder.Visible = empBO.IsEmployeeQueueOrderEnabledInDept(EmployeeID, DeptCode, out queueOrderIsMandatory);
        rqdQueueOrder.Enabled = queueOrderIsMandatory;
    }

    protected void TogglePhonesPanel(object sender, EventArgs e)
    {
        try
        {
            if (chkShowPhonesFromDept.Checked)
            {
                SetDeptPhones();
            }

            pnlPhones.Enabled = !chkShowPhonesFromDept.Checked;
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.TogglePhonesPanel", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void gvServices_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        try
        {
            int serviceCode;
            string command;
            int remarkID;
            string remarkText;

            switch (e.CommandName)
            {
                case "AddEmployeeServiceRemark":
                    serviceCode = Convert.ToInt32(e.CommandArgument);
                    AddRemark(serviceCode, null);
                    break;

                case "UpdateEmployeeServiceRemarks":
                    //command = e.CommandArgument.ToString();
                    serviceCode = Convert.ToInt32(e.CommandArgument);
                    //remarkID = Convert.ToInt32(command.Split('#')[1]);
                    UpdateEmployeeServiceRemarks(serviceCode);
                    break;

                case "Delete":
                    serviceCode = Convert.ToInt32(e.CommandArgument);
                    DeleteEmployeeService(serviceCode);
                    break;

                    //case "CopyEmployeeServiceHoursFromClinicHours":
                    //    serviceCode = Convert.ToInt32(e.CommandArgument);
                    //    CopyEmployeeServiceHoursFromClinicHours(serviceCode);
                    //    break;
                    //case "Edit":
                    //    command = e.CommandArgument.ToString();
                    //    serviceCode = Convert.ToInt32(command.Split('#')[0]);
                    //    remarkID = Convert.ToInt32(command.Split('#')[1]);
                    //    remarkText = command.Split('#')[2].ToString();
                    //    //serviceCode = Convert.ToInt32(e.CommandArgument);
                    //    DeleteServiceRemark(serviceCode, remarkID, remarkText);
                    //    break;
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.gvServices_RowCommand", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void gvServices_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        try
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView row = e.Row.DataItem as DataRowView;

                if (Convert.ToInt32(txtAgreementType.Text) == 5 && Convert.ToBoolean(Session["IsMedicalTeam"]) == true)
                {
                    ImageButton btnDeleteService = e.Row.FindControl("btnDeleteService") as ImageButton;
                    btnDeleteService.Visible = false;
                }

                GridView gvServicePhones = e.Row.FindControl("gvServicePhones") as GridView;
                HtmlTableCell tdEmployeeServiceQueueOrderMethods = e.Row.FindControl("tdEmployeeServiceQueueOrderMethods") as HtmlTableCell;

                DataView dvEmployeeServicePhones = new DataView(employeeServicePhones, "x_Dept_Employee_ServiceID = " + row["x_Dept_Employee_ServiceID"], "", DataViewRowState.CurrentRows);
                Control divLblUpdatePhones = e.Row.FindControl("divLblUpdatePhones");
                if (dvEmployeeServicePhones.Count > 0)
                {
                    gvServicePhones.DataSource = dvEmployeeServicePhones;
                    gvServicePhones.DataBind();

                    divLblUpdatePhones.Visible = false;
                }
                else
                {
                    divLblUpdatePhones.Visible = true;
                }

                DataView dvEmployeeServiceQueueOrderMethod = new DataView(employeeServiceQueueOrderMethod, "serviceCode = " + row["serviceCode"], "", DataViewRowState.CurrentRows);

                string QueueOrderDescription = row["QueueOrderDescription"].ToString();

                if (QueueOrderDescription == "&nbsp;")
                {
                    QueueOrderDescription = "עדכון";
                }

                if (dvEmployeeServiceQueueOrderMethod.Count > 0)
                {
                    tdEmployeeServiceQueueOrderMethods.InnerHtml = UIHelper.GetInnerHTMLForQueueOrder(dvEmployeeServiceQueueOrderMethod, row["ToggleID"].ToString(), "divGvServices", true);// + "<hr style='border-top: 1px solid red'>";
                    tdEmployeeServiceQueueOrderMethods.InnerHtml = tdEmployeeServiceQueueOrderMethods.InnerHtml.Replace("<table ", "<table style='border-bottom: 1px solid blue' ");
                }
                else
                    tdEmployeeServiceQueueOrderMethods.InnerHtml = "<table cellpadding='0' cellspacing='0'><tr><td style='padding-top:5px' class='LooksLikeHRef'>" + QueueOrderDescription + "</td></tr></table>";

                GridView gvEmployeeServiceQueueOrderHours = e.Row.FindControl("gvEmployeeServiceQueueOrderHours") as GridView;
                DataView dvEmployeeServiceQueueOrderHours = new DataView(employeeServiceQueueOrderHours,
                    "serviceCode = " + row["serviceCode"], "receptionDay", DataViewRowState.OriginalRows);
                gvEmployeeServiceQueueOrderHours.DataSource = dvEmployeeServiceQueueOrderHours;
                gvEmployeeServiceQueueOrderHours.DataBind();

                Label lblEmployeeServiceQueueOrderPhones = e.Row.FindControl("lblEmployeeServiceQueueOrderPhones") as Label;
                lblEmployeeServiceQueueOrderPhones.Text = row["phonesForQueueOrder"].ToString();

                Image imgService = e.Row.FindControl("imgService") as Image;
                if (Convert.ToInt32(row["IsService"]) == 1)
                {
                    imgService.ImageUrl = "~/Images/abc/Sheen.gif";
                    imgService.ToolTip = "שירות";
                }
                else
                {
                    imgService.ImageUrl = "~/Images/abc/Mem.gif";
                    imgService.ToolTip = "מקצוע";
                }

                GridView gvServiceRemarks = e.Row.FindControl("gvServiceRemarks") as GridView;
                DataView dvemployeeServiceRemarks = new DataView(employeeServiceRemarks,
                    "serviceCode = " + row["serviceCode"], "RemarkText", DataViewRowState.OriginalRows);
                if (dvemployeeServiceRemarks.Count > 0)
                {
                    gvServiceRemarks.DataSource = dvemployeeServiceRemarks;
                    gvServiceRemarks.DataBind();
                }
                else
                {
                    gvServiceRemarks.Visible = false;
                }

                //Button btnUpdate = e.Row.FindControl("btnUpdate") as Button;
                //btnUpdate.Visible = false;

                //Button btnDelRemark = e.Row.FindControl("btnDeleteRemark") as Button;
                //btnDelRemark.Visible = false;
                //btnDelRemark.Attributes.Add("style", "cursor:default");
                Button btnCopyClinicHours = e.Row.FindControl("btnCopyClinicHours") as Button;
                btnCopyClinicHours.Attributes.Add("onclick", "return GoCopyClinicHoursToEmployeeHours('" + row["serviceCode"].ToString() + ";" + row["deptCode"] + "')");

                LinkButton lnkStatus = e.Row.FindControl("lnkStatus") as LinkButton;
                string clientIDindex = lnkStatus.ClientID.Substring(31, 3);
                lnkStatus.Attributes.Add("onclick", "UpdateEmployeeServiceStatus('" + clientIDindex + "'," + row["serviceCode"].ToString() + "); return false;");

                //UpdateEmployeeServiceStatus(this.id," + Eval("ServiceCode") + "))

            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.gvServices_RowDataBound", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void gvServices_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        try
        {
            BindEmployeeServices();
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.gvServices_RowDeleting", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void gvServices_RowEditing(object sender, GridViewEditEventArgs e)
    {

    }

    /// <summary>
    /// ensure that at least one of fax of phone number is not empty
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CheckPhoneOrFaxValid(object sender, ServerValidateEventArgs e)
    {
        try
        {
            DataTable phoneDT = phoneUC.ReturnData();
            DataTable faxDT = faxUC.ReturnData();
            bool IsMedicalTeam = false;
            if (Session["IsMedicalTeam"] != null)
                IsMedicalTeam = Convert.ToBoolean(Session["IsMedicalTeam"]);

            if (phoneDT == null && faxDT == null)
            {
                e.IsValid = false;
                
                return;
            }

            if (phoneDT.Rows.Count == 0 && faxDT.Rows.Count == 0 && !IsMedicalTeam)
            {
                e.IsValid = false;
            }
            else
            {
                e.IsValid = true;
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.CheckPhoneOrFaxValid", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    private bool checkPhoneOrFaxValid()
    {
        DataTable phoneDT = phoneUC.ReturnData();
        DataTable faxDT = faxUC.ReturnData();
        bool IsMedicalTeam = false;
        if (Session["IsMedicalTeam"] != null) IsMedicalTeam = Convert.ToBoolean(Session["IsMedicalTeam"]);

        if (phoneDT == null && faxDT == null) return false;

        if (phoneDT.Rows.Count == 0 && faxDT.Rows.Count == 0 && !IsMedicalTeam)
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    protected void btnAddRemark_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Redirect("AddRemark.aspx?EmployeeID=" + EmployeeID.ToString() + "&DeptCode=" + DeptCode, false);
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.btnAddRemark_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void btnUpdateRemarks_Click(object sender, EventArgs e)
    {
        try
        {
            Session["currentEmployeeDept"] = DeptCode;
            Response.Redirect("UpdateEmployeeRemarks.aspx?EmployeeID=" + EmployeeID.ToString(), false);
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.btnUpdateRemarks_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void RebindServices(object sender, EventArgs e)
    {
        try
        {
            BindEmployeeServices();
            BindReceptionHoursGridView();
            CheckReceptionHoursEnable();
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.RebindServices", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void RebindServices()
    {
        try
        {
            BindEmployeeServices();
            BindReceptionHoursGridView();
            CheckReceptionHoursEnable();
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("UpdateDeptEmployee.RebindServices", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    #endregion

    private void sendErrorToEmail(string functionName, string exception)
    {
        try
        {
            string developersEmails = ConfigurationManager.AppSettings["DevelopersEmail"];

            string[] developersEmailsArray = developersEmails.Split(';');

            List<string> developersEmailsList = new List<string>();
            
            if(developersEmailsArray.Length > 0)
            {
                foreach(string item in developersEmailsArray)
                {
                    if(isEmailValid(item))
                    {
                        developersEmailsList.Add(item);
                    }
                }
            }

            if (developersEmailsList.Count > 0)
            {
                new System.Threading.Thread(() =>
                {
                    string userEmail = String.Empty;

                    SeferNet.BusinessLayer.BusinessObject.UserInfo userInfo = (SeferNet.BusinessLayer.BusinessObject.UserInfo)Session["currentUser"];

                    try
                    {
                        userInfo = (SeferNet.BusinessLayer.BusinessObject.UserInfo)Session["currentUser"];
                    }
                    catch
                    {
                        userInfo = null;
                    }

                    if (userInfo != null)
                    {
                        userEmail = userInfo.Mail;
                    }

                    SeferNet.BusinessLayer.WorkFlow.EmailHandler.SendEmail("Error in " + functionName, "User " + userEmail + " got an error.<br/><br/>" + exception, "sefernet@clalit.org.il", developersEmailsList, "", "", "", System.Text.Encoding.UTF8);

                }).Start();
            }
        }
        catch
        {

        }
    }

    bool isEmailValid(string email)
    {
        Regex regex = new Regex(@"^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$");
        Match match = regex.Match(email);
        if (match.Success) return true;
        else return false;
    }

    private void displayError(string message)
    {
        SeferMasterPageIE master = (SeferMasterPageIE)(this.Master);
        master.DisplayPopup(message);
    }
}
