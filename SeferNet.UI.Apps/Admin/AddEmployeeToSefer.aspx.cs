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
using SeferNet.Globals;
using SeferNet.BusinessLayer.ClalitOnlineWS_NEW;
using System.IO;
using System.Net;
using SeferNet.UI.Apps.GetEmployeeDetailes;
using SeferNet.UI.Apps.AppCode;
using System.Text.RegularExpressions;
using System.Collections.Generic;

public partial class AddEmployeeToSefer : AdminBasePage
{

    Facade applicFacade;
    int gender = 0;
    int employeeID;
    int licenseNumber;
    string firstName;
    string lastName;
    string selectedItemValue;
    DataSet m_dsEmployeeList;
    UserInfo currentUser;

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            applicFacade = Facade.getFacadeObject();
            currentUser = Session["currentUser"] as UserInfo;

            if (!IsPostBack)
            {
                UIHelper.BindDropDownToCachedTable(ddlSector, "View_EmployeeSector", "IsDoctor");

                //string shortUserName = currentUser.UserNameNoPrefix;
                DataSet dsDistricts = applicFacade.getUserPermittedDistricts(currentUser.UserID);
                if (dsDistricts.Tables[0].Rows.Count > 1)
                {
                    ListItem lstItem = new ListItem("בחר", "-1");
                    ddlDistrict.Items.Add(lstItem);
                }
                ddlDistrict.DataSource = dsDistricts.Tables[0];
                ddlDistrict.DataBind();
                DataTable dtSectors = applicFacade.getGeneralDataTable("EmployeeSector").Tables[0];

                for (int i = 0; i < dtSectors.Rows.Count; i++)
                {
                    if (Convert.ToBoolean(dtSectors.Rows[i]["IsDoctor"]))
                    {
                        selectedItemValue = dtSectors.Rows[i]["EmployeeSectorCode"].ToString();
                        UIHelper.SetDDLSelectedItem(ddlSector, selectedItemValue);
                    }
                }
            }

            if (IsPostBack && txtSelectedEmployeeID.Text != string.Empty)
            {
                /// Add new Employee to Sefer
                bool results = false;
                bool isDental = false;
                Int64 NewEmployeeID = 0;
                int profLicence = 0;
                bool isVirtualDoctor = cbVirtualDoctor.Checked;

                int employeeSectorCode = Convert.ToInt32(ddlSector.SelectedValue);
                int selectedEmployeeID = Convert.ToInt32(txtSelectedEmployeeID.Text);
                string updateUser = Master.getUserName();
                int primaryDistrict = Convert.ToInt32(ddlDistrict.SelectedValue);

                DataSet dsEmployeeFromMF = applicFacade.GetEmployeeListForSpotting_MF(string.Empty, string.Empty, -1, selectedEmployeeID);
                string firstName = dsEmployeeFromMF.Tables[0].Rows[0]["FirstName"].ToString();
                string lastName = dsEmployeeFromMF.Tables[0].Rows[0]["lastName"].ToString();
                gender = Convert.ToInt32(dsEmployeeFromMF.Tables[0].Rows[0]["Gender"]);

                results = applicFacade.InsertEmployeeIntoSefer(selectedEmployeeID, lastName, firstName,
                    employeeSectorCode, primaryDistrict, isVirtualDoctor, updateUser, gender, profLicence, isDental, ref NewEmployeeID);

                if (results == true)
                {
                    SessionParamsHandler.SetEmployeeIDInSession(selectedEmployeeID);
                    Response.Redirect(@"~/Admin/updateEmployee.aspx", false);
                }
                else
                {
                    txtSelectedEmployeeID.Text = string.Empty;

                    //    lblError.Text = "לא מצליח להוסיף העובד למרפאה";
                }
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.Page_Load", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    //int GetProfLicence(long employeeID)
    //{
    //    int profLicence = 0;

    //    GetEmployeeDetailsByIDClient service = new GetEmployeeDetailsByIDClient();

    //    GetEmployeeDetailsByIDMessageInfo messageInfo = new GetEmployeeDetailsByIDMessageInfo();

    //    messageInfo.RequestID = Guid.NewGuid().ToString();
    //    messageInfo.RequestDatetime = DateTime.Now;
    //    messageInfo.RequestingApplication = Convert.ToInt32(ConfigurationManager.AppSettings["RequestingApplication"]);
    //    messageInfo.ServingApplication = Convert.ToInt32(ConfigurationManager.AppSettings["ServingApplication"]);
    //    messageInfo.RequestingSite = Convert.ToInt32(ConfigurationManager.AppSettings["RequestingSite"]);
    //    messageInfo.ServingSite = Convert.ToInt32(ConfigurationManager.AppSettings["ServingSite"]);

    //    GetEmployeeDetailsByIDParameters parameters = new GetEmployeeDetailsByIDParameters();

    //    parameters.EmployeeID = employeeID.ToString();

    //    GetEmployeeDetailsByID_Request requestEmp = new GetEmployeeDetailsByID_Request();
    //    requestEmp.MessageInfo = messageInfo;
    //    requestEmp.Parameters = parameters;

    //    var response = service.GetEmployeeDetailsByIDAction(requestEmp);

    //    GetEmployeeDetailsByIDResults results = response.Results;

    //    GetEmployeeDetailsByIDProfessionalLicenses professionalLicensesField = results.ProfessionalLicenses;

    //    if (professionalLicensesField != null && professionalLicensesField.Count > 0)
    //    {
    //        DateTime startDate = Convert.ToDateTime("1900-01-01");

    //        for (int i = 0; i < professionalLicensesField.Count; i++ )
    //        {
    //            if(professionalLicensesField[i].TypeCode == "01")
    //            {
    //                if (Convert.ToDateTime(professionalLicensesField[i].StartDate) > startDate )
    //                {
    //                    profLicence = Convert.ToInt32(professionalLicensesField[i].LicenseNumber);
    //                    startDate = Convert.ToDateTime(professionalLicensesField[i].StartDate);
    //                }
    //            }
    //        }
    //    }

    //    return profLicence;
    //}

    protected void Page_PreRender(object sender, EventArgs e)
    {
        try
        {
            //modalAddEmployeeToSefer.Show();
            if (gvEmployeeList.Rows.Count > 1)
                lblSelectIfMoreThenOne.Style.Add("display", "inline");
            else
                lblSelectIfMoreThenOne.Style.Add("display", "none");

            AutoCompleteFirstName.ContextKey = txtLastName.Text;

            AutoCompleteLastName.ContextKey = txtFirstName.Text;
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.Page_PreRender", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, false);
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.btnCancel_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void btnSelect_Click(object sender, EventArgs e)
    {
        try
        {
            applicFacade = Facade.getFacadeObject();

            if (txtEmployeeID.Text != string.Empty)
                employeeID = Convert.ToInt32(txtEmployeeID.Text);
            else
                employeeID = -1;

            if (txtLicenseNumber.Text != string.Empty)
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

            m_dsEmployeeList = applicFacade.GetEmployeeListForSpotting_MF(firstName, lastName, licenseNumber, employeeID);

            gvEmployeeList.DataSource = m_dsEmployeeList.Tables[0];
            gvEmployeeList.DataBind();
            gvEmployeeList.Style.Add("display", "inline");

            if (m_dsEmployeeList.Tables[0].Rows.Count >= 1000)
            {
                lblError.Text = "There are too many records <br> Only top 1000 are shown !";
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.btnSelect_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void btnSelect_Demografia_Click(object sender, EventArgs e)
    {
        try
        {
            string district = ddlDistrict.SelectedValue;
            string tzNumber = txtEmployeeID_Demografia.Text;
            string fullTzNumber = tzNumber;
            if (tzNumber.Length > 1)
                tzNumber = tzNumber.Remove(tzNumber.Length - 1);

            EmployeeDetailsFromWS employeeDetailsFromWS = new EmployeeDetailsFromWS(tzNumber, district);
            DemogResults demogResults = employeeDetailsFromWS.LoadPatientDetails();

            if (demogResults != null)
            {
                bool results = true;
                Int64 NewEmployeeID = 0;
                int profLicence = 0;
                bool isVirtualDoctor = cbVirtualDoctor.Checked;
                bool isDental = cbDentist.Checked;
                string lastName = demogResults.LastName.Trim();
                string firstName = demogResults.FirstName.Trim();
                int fullID = Convert.ToInt32(demogResults.PatientId.ToString() + demogResults.CheckNumber.ToString());
                int employeeSectorCode = Convert.ToInt32(ddlSector.SelectedValue);
                string updateUser = Master.getUserName();
                int primaryDistrict = Convert.ToInt32(ddlDistrict.SelectedValue);

                gender = demogResults.Sex;

                if (Convert.ToInt32(fullTzNumber) != fullID)
                {
                    SessionParamsHandler.RemoveEmployeeCodeFromSession();
                    lblError.Text = "!ספרת הביקורת שהוקלדה אינה נכונה, לא ניתן לקלוט נותן שירות למערכת";
                    return;
                }

                results = applicFacade.IsEmployeeExistsInEmployee(fullID);

                if (results == true)
                {
                    SessionParamsHandler.RemoveEmployeeCodeFromSession();
                    lblError.Text = "נותן השירות הנבחר כבר קיים במערכת";
                    return;
                }


                if (!isVirtualDoctor)
                {
                    try
                    {
                        GetEmployeeDetailesByID getEmployeeDetailesByID = new GetEmployeeDetailesByID();
                        profLicence = getEmployeeDetailesByID.GetProfLicence(fullID, isDental);
                    }
                    catch (Exception ex)
                    {
                    }
                }

                if (isDental && profLicence == 0)
                {
                    SessionParamsHandler.RemoveEmployeeCodeFromSession();
                    lblError.Text = "אין רישיון מקצועי לנותן שירות";
                    return;
                }

                results = applicFacade.InsertEmployeeIntoSefer(fullID, lastName, firstName,
                    employeeSectorCode, primaryDistrict, isVirtualDoctor, updateUser, gender, profLicence, isDental, ref NewEmployeeID);

                if (results == true)
                {
                    SessionParamsHandler.SetEmployeeIDInSession(fullID);
                    Response.Redirect(@"~/Admin/updateEmployee.aspx", false);
                }
                else
                {
                    SessionParamsHandler.RemoveEmployeeCodeFromSession();

                    lblError.Text = "לא מצליח להוסיף העובד למרפאה";
                }
            }
            else
            {
                lblError.Text = "עובד זה לא קיים בדמוגרפיה";
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.btnSelect_Demografia_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void ddlSector_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            DataTable dtSectors = applicFacade.getGeneralDataTable("EmployeeSector").Tables[0];

            cbVirtualDoctor.Checked = false;

            for (int i = 0; i < dtSectors.Rows.Count; i++)
            {
                if (dtSectors.Rows[i]["EmployeeSectorCode"].ToString() == ddlSector.SelectedValue)
                {
                    if (Convert.ToBoolean(dtSectors.Rows[i]["IsDoctor"]))
                    {
                        trParameters.Style.Add("display", "inline");
                        trSelectIfMoreThenOne.Style.Add("display", "inline");
                        trEmployeeList.Style.Add("display", "inline");
                        cbVirtualDoctor.Style.Add("display", "inline");
                        cbDentist.Style.Add("display", "inline");

                        trDemografia.Style.Add("display", "none");
                        txtEmployeeID_Demografia.Text = string.Empty;
                    }
                    else
                    {
                        txtFirstName.Text = string.Empty;
                        txtLastName.Text = string.Empty;
                        txtEmployeeID.Text = string.Empty;
                        txtLicenseNumber.Text = string.Empty;

                        trParameters.Style.Add("display", "none");
                        trSelectIfMoreThenOne.Style.Add("display", "none");
                        trEmployeeList.Style.Add("display", "none");
                        cbVirtualDoctor.Style.Add("display", "none");
                        cbDentist.Style.Add("display", "none");

                        gvEmployeeList.DataSource = null;
                        gvEmployeeList.DataBind();

                        trDemografia.Style.Add("display", "inline");
                    }
                }
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.ddlSector_SelectedIndexChanged", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void cbVirtualDoctor_CheckedChanged(object sender, EventArgs e)
    {
        try
        {
            if (cbVirtualDoctor.Checked)
            {
                txtFirstName.Text = string.Empty;
                txtLastName.Text = string.Empty;
                txtEmployeeID.Text = string.Empty;
                txtLicenseNumber.Text = string.Empty;

                ddlSector.Enabled = false;
                cbDentist.Checked = false;

                trParameters.Style.Add("display", "none");
                trSelectIfMoreThenOne.Style.Add("display", "none");
                trEmployeeList.Style.Add("display", "none");

                tdAddVirtual.Style.Add("display", "inline");

                gvEmployeeList.DataSource = null;
                gvEmployeeList.DataBind();

                trDemografia.Style.Add("display", "none");
            }
            else
            {
                ddlSector.Enabled = true;

                trParameters.Style.Add("display", "inline");
                trSelectIfMoreThenOne.Style.Add("display", "inline");
                trEmployeeList.Style.Add("display", "inline");

                tdAddVirtual.Style.Add("display", "none");

                trDemografia.Style.Add("display", "none");
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.cbVirtualDoctor_CheckedChanged", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void cbDentist_CheckedChanged(object sender, EventArgs e)
    {
        try
        {
            if (cbDentist.Checked)
            {
                txtFirstName.Text = string.Empty;
                txtLastName.Text = string.Empty;
                txtEmployeeID.Text = string.Empty;
                txtLicenseNumber.Text = string.Empty;

                ddlSector.Enabled = false;

                trParameters.Style.Add("display", "none");
                trSelectIfMoreThenOne.Style.Add("display", "none");
                trEmployeeList.Style.Add("display", "none");

                tdAddVirtual.Style.Add("display", "none");
                tdDentist.Style.Add("display", "inline");

                gvEmployeeList.DataSource = null;
                gvEmployeeList.DataBind();

                trDemografia.Style.Add("display", "inline");
            }
            else
            {
                ddlSector.Enabled = true;

                trParameters.Style.Add("display", "inline");
                trSelectIfMoreThenOne.Style.Add("display", "inline");
                trEmployeeList.Style.Add("display", "inline");

                tdAddVirtual.Style.Add("display", "inline");

                trDemografia.Style.Add("display", "none");
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.cbDentist_CheckedChanged", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void btnAddVirtual_Click(object sender, EventArgs e)
    {
        try
        {
            /// Add virtual Employee to Sefer

            bool result = true;
            bool isDental = false;
            Int64 NewEmployeeID = 0;
            bool isVirtualDoctor = cbVirtualDoctor.Checked;
            lastName = "רופא";
            firstName = "וירטואלי";
            int employeeSectorCode = Convert.ToInt32(ddlSector.SelectedValue);
            int selectedEmployeeID = 0;
            string updateUser = Master.getUserName();
            int primaryDistrict = Convert.ToInt32(ddlDistrict.SelectedValue);
            //????? Get new virtual employeeID ??????????
            result = applicFacade.InsertEmployeeIntoSefer(selectedEmployeeID, lastName, firstName,
                employeeSectorCode, primaryDistrict, isVirtualDoctor, updateUser, gender, 0, isDental, ref NewEmployeeID);

            if (result == true)
            {
                SessionParamsHandler.SetEmployeeIDInSession(NewEmployeeID);
                Response.Redirect(@"~/Admin/updateEmployee.aspx");
            }
            else
            {
                txtSelectedEmployeeID.Text = string.Empty;
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.btnAddVirtual_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        try
        {
            txtEmployeeID.Text = string.Empty;
            txtFirstName.Text = string.Empty;
            txtLastName.Text = string.Empty;
            txtLicenseNumber.Text = string.Empty;

            gvEmployeeList.DataSource = null;
            gvEmployeeList.DataBind();
            gvEmployeeList.Style.Add("display", "none");
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.btnClear_Click", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    protected void gvEmployeeList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        try
        {
            GridViewRow row = e.Row;
            String employeeID = "", firstName = "", lastName = "", gender = "";
            if (row.RowType != DataControlRowType.Header)
            {
                if (row.Cells.Count > 1)
                {
                    firstName = row.Cells[0].Text;
                    lastName = row.Cells[1].Text;
                    gender = row.Cells[4].Text;
                    employeeID = row.Cells[2].Text;
                    row.Cells[4].Style.Add("display", "none");

                    row.Attributes.Add("onclick", "GetEmployeeID('" + employeeID + "');");
                    row.Attributes.Add("onmouseover", "LightOnMouseOver(this)");
                    row.Attributes.Add("onmouseout", "LightOffOnMouseOver(this)");
                }
            }
        }
        catch (Exception exception)
        {
            this.sendErrorToEmail("AddEmployeeToSefer.gvEmployeeList_RowDataBound", exception.ToString());
            this.displayError(exception.Message);
        }
    }

    private void sendErrorToEmail(string functionName, string exception)
    {
        try
        {
            string developersEmails = ConfigurationManager.AppSettings["DevelopersEmail"];

            string[] developersEmailsArray = developersEmails.Split(';');

            List<string> developersEmailsList = new List<string>();

            if (developersEmailsArray.Length > 0)
            {
                foreach (string item in developersEmailsArray)
                {
                    if (isEmailValid(item))
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
        SeferMasterPage master = (SeferMasterPage)(this.Master);
        master.DisplayPopup(message);
    }
}
