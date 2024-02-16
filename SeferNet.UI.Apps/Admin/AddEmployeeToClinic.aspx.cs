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
using SeferNet.UI;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using Clalit.SeferNet.GeneratedEnums;



public partial class AddEmployeeToClinic : System.Web.UI.Page
{

    Facade applicFacade;

    long employeeID;
    int licenseNumber;
    string firstName;
    string lastName;
    DataSet m_dsEmployeeList;
    SessionParams sessionParams;

    protected void Page_Load(object sender, EventArgs e)
    {
        this.Form.DefaultButton = this.btnSelect.UniqueID.ToString(); 

        applicFacade = Facade.getFacadeObject();
        int deptCode = SessionParamsHandler.GetDeptCodeFromSession();

        if (IsPostBack && txtSelectedEmployeeID.Text != string.Empty)
        {
            //insert new Employee into Clinic
            int DeptEmployeeID = 0;
            long selectedEmployeeID = Convert.ToInt64(txtSelectedEmployeeID.Text);
            string updateUser = Master.getUserName();            
            bool active = true;
            string email = string.Empty;
            bool showEmailInInternet = false;
            int agreementType = -1; // -1 as NOT DEFINED
            SessionParamsHandler.SetEmployeeIDInSession(selectedEmployeeID);

            DeptEmployeeID = applicFacade.InsertDoctorInClinic(deptCode, selectedEmployeeID, agreementType, updateUser, active, email, showEmailInInternet);

            if (DeptEmployeeID != 0)
            {               
                sessionParams = SessionParamsHandler.GetSessionParams();
                sessionParams.CallerUrl = @"~/Public/ZoomClinic.aspx?DeptCode=" + deptCode;
                SessionParamsHandler.SetSessionParams(sessionParams);

                Response.Redirect(@"~/Admin/UpdateDeptEmployee.aspx?DeptCode=" + deptCode + "&EmployeeID=" + selectedEmployeeID + "&DeptEmployeeID=" + DeptEmployeeID);
            }
            else
            {
                txtSelectedEmployeeID.Text = string.Empty;
                SessionParamsHandler.RemoveEmployeeCodeFromSession();

                Session["ErrorMessage"] = "לא מצליח להוסיף העובד למרפאה";
            }
        }

        DataSet ds = applicFacade.GetClinicTeamAgreementsInDept(deptCode);
        if (ds.Tables[0].Rows.Count > 0)
        {
            DataRow dr = ds.Tables[0].Rows[0];

            if (Convert.ToBoolean(dr["IsCommunity"]))
            {
                tblSelectClinicTeam_Community.Attributes.Remove("class");

                if (Convert.ToBoolean(dr["HasCommunityTeam"]))
                    btnSelectClinicTeam_Community.Enabled = false;
                else
                    btnSelectClinicTeam_Community.Enabled = true;
            }
            else
                tblSelectClinicTeam_Community.Attributes.Add("class", "DisplayNone");

            if (Convert.ToBoolean(dr["IsMushlam"]))
            {
                tblSelectClinicTeam_Mushlam.Attributes.Remove("class");

                if (Convert.ToBoolean(dr["HasMushlamTeam"]))
                    btnSelectClinicTeam_Mushlam.Enabled = false;
                else
                    btnSelectClinicTeam_Mushlam.Enabled = true;
            }
            else
                tblSelectClinicTeam_Mushlam.Attributes.Add("class", "DisplayNone");

            if (Convert.ToBoolean(dr["IsHospital"]))
            {
                tblSelectClinicTeam_Hospital.Attributes.Remove("class");

                if (Convert.ToBoolean(dr["HasHospitalTeam"]))
                    btnSelectClinicTeam_Hospital.Enabled = false;
                else
                    btnSelectClinicTeam_Hospital.Enabled = true;
            }
            else
                tblSelectClinicTeam_Hospital.Attributes.Add("class", "DisplayNone");
        }
        else 
        {
            tblSelectClinicTeam_Community.Attributes.Add("class", "DisplayNone");
            tblSelectClinicTeam_Mushlam.Attributes.Add("class", "DisplayNone");
            tblSelectClinicTeam_Hospital.Attributes.Add("class", "DisplayNone");
        }

        //DataSet ds = applicFacade.GetEmployeeClinicTeam(deptCode);
        //if (ds.Tables[0].Rows.Count > 0)
        //    btnSelectClinicTeam.Enabled = false;
        //else
        //    btnSelectClinicTeam.Enabled = true;

        //AutoCompleteFirstName.ContextKey = Session["Culture"].ToString() + "," + txtLastName.Text;
        //AutoCompleteLastName.ContextKey = Session["Culture"].ToString() + "," + txtFirstName.Text;

    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (gvEmployeeList.Rows.Count > 1)
            lblSelectIfMoreThenOne.Style.Add("display", "inline");
        else
            lblSelectIfMoreThenOne.Style.Add("display", "none");

        InitializeAutoCompleteControls();
    }

    private void InitializeAutoCompleteControls()
    {
        UserManager mgr = new UserManager();
        string IsUserLoggedIn = string.Empty;
        if (!string.IsNullOrWhiteSpace(mgr.GetLoggedinUserNameWithPrefix()))
        {
            IsUserLoggedIn = "1";
        }

        this.txtLastName.Attributes.Add("onFocus",
            "UpdateAutoCompleteName('" + txtFirstName.ClientID + "','"
            + AutoCompleteLastName.BehaviorID + "');");

        this.txtFirstName.Attributes.Add("onFocus",
            "UpdateAutoCompleteName('" + txtLastName.ClientID + "','"
            + AutoCompleteFirstName.BehaviorID + "');");
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();        
        sessionParams.MarkEmployeeInClinicSelected = true;
        Response.Redirect(@"~/Public/ZoomClinic.aspx?DeptCode=" + sessionParams.DeptCode.ToString());
    }

    protected void btnSelect_Click(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();

        if(txtEmployeeID.Text != string.Empty)
            employeeID = Convert.ToInt64(txtEmployeeID.Text);
        else 
            employeeID = -1;

        if(txtLicenseNumber.Text != string.Empty)
            licenseNumber = Convert.ToInt32(txtLicenseNumber.Text);
        else 
            licenseNumber = -1;

        if (txtFirstName.Text != string.Empty)
            firstName = txtFirstName.Text.Trim();
        else
            firstName = string.Empty;

        if (txtLastName.Text != string.Empty)
            lastName = txtLastName.Text.Trim();
        else
            lastName = string.Empty;
        int deptCode = SessionParamsHandler.GetDeptCodeFromSession();
        m_dsEmployeeList = applicFacade.GetEmployeeListForSpotting(firstName, lastName, licenseNumber, employeeID, deptCode);

        gvEmployeeList.DataSource = m_dsEmployeeList.Tables[0];
        gvEmployeeList.DataBind();
        gvEmployeeList.Style.Add("display", "inline");
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtEmployeeID.Text = string.Empty;
        txtFirstName.Text = string.Empty;
        txtLastName.Text = string.Empty;
        txtLicenseNumber.Text = string.Empty;

        gvEmployeeList.DataSource = null;
        gvEmployeeList.DataBind();
        gvEmployeeList.Style.Add("display", "none");
    }

    protected void btnSelectClinicTeam_Click(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();
        int agreementType = Convert.ToInt32(((System.Web.UI.WebControls.WebControl)(sender)).Attributes["AgreementType"]);
        int DeptEmployeeID = 0;
        int deptCode = SessionParamsHandler.GetDeptCodeFromSession();
        long selectedEmployeeID = 0;

        DataSet ds = applicFacade.GetEmployeeClinicTeam(0);
        if (ds.Tables[0].Rows.Count == 1)
            selectedEmployeeID = Convert.ToInt64(ds.Tables[0].Rows[0]["EmployeeID"]);
        else 
        {
            SessionParamsHandler.RemoveEmployeeCodeFromSession();
            Session["ErrorMessage"] = "צוות המרפאה אינו קיים במערכת";
        }

        string updateUser = Master.getUserName();
        bool active = true;
        string email = string.Empty;
        bool showEmailInInternet = false;

        SessionParamsHandler.SetEmployeeIDInSession(selectedEmployeeID);

        DeptEmployeeID = applicFacade.InsertDoctorInClinic(deptCode, selectedEmployeeID, agreementType, updateUser, active, email, showEmailInInternet);

        if (DeptEmployeeID != 0)
        {
            //DataSet dsDeptEmployeeID = applicFacade.GetDeptEmployeeID(deptCode, selectedEmployeeID);
            //int deptEmployeeID = Convert.ToInt32(dsDeptEmployeeID.Tables[0].Rows[0]["deptEmployeeID"]);
            sessionParams = SessionParamsHandler.GetSessionParams();            
            sessionParams.CallerUrl = @"~/Public/ZoomClinic.aspx?DeptCode=" + deptCode;
            SessionParamsHandler.SetSessionParams(sessionParams);

            Response.Redirect(@"~/Admin/UpdateDeptEmployee.aspx?DeptEmployeeID=" + DeptEmployeeID);
        }
        else
        {
            txtSelectedEmployeeID.Text = string.Empty;
            SessionParamsHandler.RemoveEmployeeCodeFromSession();

            Session["ErrorMessage"] = "לא מצליח להוסיף העובד למרפאה";
        }

        AutoCompleteFirstName.ContextKey = Session["Culture"].ToString() + "," + txtLastName.Text;
        AutoCompleteLastName.ContextKey = Session["Culture"].ToString() + "," + txtFirstName.Text;

    }
}
