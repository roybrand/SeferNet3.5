using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.WorkFlow;
using System.Data;
using SeferNet.FacadeLayer;
using SeferNet.Globals;
using SeferNet.BusinessLayer.BusinessObject;
using Clalit.SeferNet.GeneratedEnums;
using SeferNet.UI.Apps.AppCode;

namespace SeferNet.UI.Apps.Admin
{
    public partial class updateEmployeeLike : System.Web.UI.Page
    {
        private DataRowView m_employeeRow;
        private DataTable m_clinicsForRemarksDt;
        private DataTable m_doctorRemarks;
        private DataTable m_doctorClinics;
        private DataTable m_DeptEmployeeServices;
        private int? _licenseNumber = null;
        private List<int> _doctorsCodes;

        #region Properties

        public List<int> DoctorsCodes
        {
            get
            {
                if (_doctorsCodes == null)
                {
                    if (ViewState["doctorsCodes"] != null)
                        return (List<int>)ViewState["doctorsCodes"];
                    else
                    {
                        _doctorsCodes = new List<int>();
                    }
                }
                return _doctorsCodes;

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
                else
                    return 0;
            }
            set
            {
                ViewState["employeeID"] = value;
            }
        }

        public bool InitialSectorIsDoctor
        {
            get
            {
                if (ViewState["InitialSectorIsDoctor"] != null)
                    return (bool)ViewState["InitialSectorIsDoctor"];
                else
                    return false;
            }
            set
            {
                ViewState["InitialSectorIsDoctor"] = value;
            }
        }

        public int InitialEmployeeSector
        {
            get
            {
                if (ViewState["InitialSectorCode"] == null)
                    return 0;

                return (int)ViewState["InitialSectorCode"];
            }
            set
            {
                ViewState["InitialSectorCode"] = value;
            }
        }

        public bool ProfessionsAllowedForCurrentSector
        {
            get
            {
                if (ViewState["professionsAllowed"] == null)
                {
                    return false;
                }

                return (bool)ViewState["professionsAllowed"];
            }
            set
            {
                ViewState["professionsAllowed"] = value;
            }
        }
        
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["UpdateProfessionLicence"] != null)
                {
                    string NoProfessionLicence = "&NoProfessionLicence=1";
                    GetEmployeeID();
                    UserInfo currentUser = Session["currentUser"] as UserInfo;
                    GetEmployeeDetailesByID getEmployeeDetailesByID = new GetEmployeeDetailesByID();

                    int profLicence = getEmployeeDetailesByID.GetProfLicence(EmployeeID, false);

                    if (profLicence == -1) // error
                    {
                        //profLicence = 0;
                    }
                    else
                    {
                        Facade.getFacadeObject().UpdateEmployeeProfessionLicence(EmployeeID, profLicence, currentUser.UserNameWithPrefix);

                        Facade.getFacadeObject().UpdateEmployeeInClinicPreselected(EmployeeID, null, null);
                    }
                    string redirectTo = "../Public/zoomDoctor.aspx?EmployeeID=" + EmployeeID.ToString();
                    if (profLicence == 0)
                    {
                        redirectTo = redirectTo + NoProfessionLicence;
                    }
                    Response.Redirect(redirectTo);
                }

                InitValidators();

                if (Request.UrlReferrer != null)
                {
                    ViewState["lastPage"] = Request.UrlReferrer.AbsoluteUri;
                }

                GetEmployeeID();

                if (EmployeeID != 0)
                {
                    BindEmployeeDepts();
                    BindEmployeeStatus();
                    BindPhoneDetails();
                    BindHeader();
                    BindInitialDropDowns();
                    BindRemarks();

                    Session["EmployeeID_ToUpdateExpertProfessions"] = EmployeeID;
                    Session["EmployeExperteProfessions_SelectedValuesToUpdate"] = hdnProfessions.Value;
                }

                btnSaveTop.Attributes.Add("disabled", "true");
                //btnSaveBottom.Attributes.Add("disabled", "true");
                

            }
            else
            {
                txtLanguages.Text = Request.Form[txtLanguages.UniqueID].ToString();
                if (Request.Form[txtSpeciality.UniqueID] != null)
                    txtSpeciality.Text = Request.Form[txtSpeciality.UniqueID].ToString();
                else
                    txtSpeciality.Text = string.Empty;
                txtServices.Text = Request.Form[txtServices.UniqueID].ToString();
                if (Request.Form[txtProfessions.UniqueID] != null)
                    txtProfessions.Text = Request.Form[txtProfessions.UniqueID].ToString();
                else
                    txtProfessions.Text = string.Empty;

                btnSaveTop.Attributes.Remove("disabled");
                //btnSaveBottom.Attributes.Remove("disabled");

                //Employee status was apdated and refresh required
                if (cbRebindStatus_FromClient.Checked)
                {
                    cbRebindStatus_FromClient.Checked = false;

                    RebindStatus("text", null);
                }
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SetClientScriptOnChange("setSubmiButtonsEnabled();");
            }
        }

        private void SetClientScriptOnChange(string clientFunction)
        {
            List<DropDownList> ddlControls = new List<DropDownList>();

            GetControlList<DropDownList>(Page.Controls, ddlControls);

            foreach (var childControl in ddlControls)
            {
                childControl.Attributes.Add("onchange", clientFunction + childControl.Attributes["onchange"] ?? string.Empty);
            }

            List<TextBox> txtControls = new List<TextBox>();

            GetControlList<TextBox>(Page.Controls, txtControls);

            foreach (var childControl in txtControls)
            {
                childControl.Attributes.Add("onchange", clientFunction + childControl.Attributes["onchange"] ?? string.Empty);
            }

            List<CheckBox> cbControls = new List<CheckBox>();

            GetControlList<CheckBox>(Page.Controls, cbControls);

            foreach (var childControl in cbControls)
            {
                childControl.Attributes.Add("onclick", clientFunction + childControl.Attributes["onclick"] ?? string.Empty);
            }

            List<CheckBoxList> cblControls = new List<CheckBoxList>();

            GetControlList<CheckBoxList>(Page.Controls, cblControls);

            foreach (var childControl in cblControls)
            {
                childControl.Attributes.Add("onclick", clientFunction + childControl.Attributes["onclick"] ?? string.Empty);
            }

            List<ImageButton> imgbtnControls = new List<ImageButton>();

            GetControlList<ImageButton>(Page.Controls, imgbtnControls);

            foreach (var childControl in imgbtnControls)
            {
                childControl.Attributes.Add("onclick", clientFunction + childControl.Attributes["onclick"] ?? string.Empty);
            }

            List<LinkButton> lnkbtnControls = new List<LinkButton>();

            GetControlList<LinkButton>(Page.Controls, lnkbtnControls);

            foreach (var childControl in lnkbtnControls)
            {
                childControl.Attributes.Add("onclick", clientFunction + childControl.Attributes["onclick"] ?? string.Empty);
            }

        }
        private void GetControlList<T>(ControlCollection controlCollection, List<T> resultCollection)
        where T : Control
        {
            foreach (Control control in controlCollection)
            {
                //if (control.GetType() == typeof(T))
                if (control is T) // This is cleaner
                    resultCollection.Add((T)control);

                if (control.HasControls())
                    GetControlList(control.Controls, resultCollection);
            }
        }

        private void InitValidators()
        {
            //vldFirstName.ErrorMessage = String.Format(HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RequiredField").ToString(),
            //"שם פרטי");

            //vldLastName.ErrorMessage = String.Format(HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RequiredField").ToString(),
            //"שם משפחה");
        }

        private void BindEmployeeStatus()
        {
            EmployeeBO bo = new EmployeeBO();
            DataSet ds = bo.GetEmployeeCurrentStatus(EmployeeID);

            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                hfActive.Value = ds.Tables[0].Rows[0]["status"].ToString();

                lnkStatus.Text = ds.Tables[0].Rows[0]["StatusDescription"].ToString();
            }
            else
            {
                lnkStatus.Text = "לא הוגדר";
            }
        }

        private void BindEmployeeDepts()
        {
            DataSet ds = Facade.getFacadeObject().getDoctorDetails(EmployeeID);

            m_clinicsForRemarksDt = ds.Tables["clinicsForRemarks"];                     // save clinics for remarks for remark method
            m_doctorRemarks = ds.Tables["doctorRemarks"];                               // save doctor remarks 
            m_doctorClinics = ds.Tables["clinics"];
            m_DeptEmployeeServices = ds.Tables["DeptEmployeeServices"];

            // last update date
            //lblUpdateDate.Text = Convert.ToDateTime(ds.Tables["clinicsUpdateDate"].Rows[0][0]).ToShortDateString();

            //gvDoctorsUnits.DataSource = ds.Tables["clinics"];
            //gvDoctorsUnits.DataBind();

        }

        private void BindRemarks()
        {
            //rptRemarks.DataSource = m_clinicsForRemarksDt;
            //rptRemarks.DataBind();
        }

        private void BindInitialDropDowns()
        {
            // sectors
            InitSectors();

            // professions and speciality
            InitProfessionsAndSpeciality();


            // services
            DataSet ds = new DataSet();
            EmployeeServicesBO serviceBo = new EmployeeServicesBO();
            ds = serviceBo.GetEmployeeServices(EmployeeID);
            if (ds != null && ds.Tables[0] != null)
            {
                txtServices.Text = Utils.GetDelimitedContentFromTable(ds.Tables[0], "serviceDescription");
                hdnServices.Value = Utils.GetDelimitedContentFromTable(ds.Tables[0], "serviceCode").Replace(';', ',');
            }

            // languages
            EmployeeLanguagesBO langBo = new EmployeeLanguagesBO();
            ds = langBo.GetLanguagesForEmployee(EmployeeID);
            if (ds != null && ds.Tables[0] != null)
            {
                txtLanguages.Text = Utils.GetDelimitedContentFromTable(ds.Tables[0], "languageDescription");
                hdnLanguages.Value = Utils.GetDelimitedContentFromTable(ds.Tables[0], "languageCode").Replace(';', ',');
            }


            // gender
            ddlGender.DataTextField = "SexDescription";
            ddlGender.DataValueField = "Sex";
            UIHelper.BindDropDownToCachedTable(ddlGender, "DIC_Gender", "sex");
            ddlGender.Items.Insert(0, new ListItem(ConstsSystem.CHOOSE, "0"));

            ddlGender.SelectedValue = m_employeeRow["sex"].ToString();


            // districts
            ddlDistrict.DataTextField = "districtName";
            ddlDistrict.DataValueField = "districtCode";
            UIHelper.BindDropDownToCachedTable(ddlDistrict, "View_AllDistricts", "districtName");
            ddlDistrict.Items.Insert(0, new ListItem(ConstsSystem.CHOOSE, "-1"));
            ddlDistrict.SelectedValue = m_employeeRow["primaryDistrict"].ToString();
        }

        private void InitProfessionsAndSpeciality()
        {
            EmployeeBO bo = new EmployeeBO();

            // allow professions and speciality by employee sector
            if (bo.IsProfessionAllowedForEmployee(EmployeeID))
            {
                // professions
                DataSet ds = new DataSet();
                EmployeeProfessionBO profBo = new EmployeeProfessionBO();
                ds = profBo.GetEmployeeProfessions(EmployeeID);
                if (ds != null && ds.Tables[0] != null)
                {
                    txtProfessions.Text = Utils.GetDelimitedContentFromTable(ds.Tables[0], "professionDescription");
                    hdnProfessions.Value = Utils.GetDelimitedContentFromTable(ds.Tables[0], "ProfessionCode").Replace(';', ',');
                }


                // speciality
                DataTable dt = ds.Tables[0];
                string speciality = string.Empty;

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (dt.Rows[i]["expProfession"] != DBNull.Value)
                    {
                        speciality += dt.Rows[i]["professionDescription"].ToString() + " , ";
                        hdnSpeciality.Value += dt.Rows[i]["professionCode"].ToString() + " , ";
                    }
                }

                if (!string.IsNullOrEmpty(speciality))
                {
                    speciality = speciality.Substring(0, speciality.LastIndexOf(','));
                    txtSpeciality.Text = speciality;
                }

                EnableProfessionsAndSpeciality(true);
            }
            else  // do not allow choosing professions or speciality
            {
                EnableProfessionsAndSpeciality(false);

            }

        }

        private void EnableProfessionsAndSpeciality(bool enable)
        {
            txtProfessions.Enabled = txtSpeciality.Enabled = btnSpeciality.Enabled = enable;

            if (enable)
            {
                btnProfessions.Disabled = false;
                btnProfessions.Attributes.Add("style", "cursor:pointer");

                if (m_DeptEmployeeServices != null && m_DeptEmployeeServices.Rows.Count > 0)
                {
                    btnProfessions.Attributes.Add("onclick", "ConfirmIntentionToChangeProfessions() && OpenPopup(2, '" + txtProfessions.ClientID + "', '"
                                                                            + hdnProfessions.ClientID + "' );return false;");
                }
                else
                {
                    btnProfessions.Attributes.Add("onclick", "OpenPopup(2, '" + txtProfessions.ClientID + "', '" + hdnProfessions.ClientID + "' );return false;");
                }

                //btnSpeciality.OnClientClick = "OpenPopup(5, '" + txtSpeciality.ClientID + "', '" + hdnSpeciality.ClientID + "' );return false;";
                //btnSpeciality.OnClientClick = "OpenUpdateExpertPopUp('" + txtSpeciality.ClientID + "', '" + hdnSpeciality.ClientID + "' );return false;";
            }
            else
            {
                btnProfessions.Disabled = true;
                btnProfessions.Attributes.Add("style", "cursor:default");
            }
        }

        private void InitSectors()
        {
            doctorManager dm = new doctorManager();
            DataSet ds = dm.GetEmployeeSectors(-1);
            ddlSector.DataSource = ds;
            ddlSector.DataTextField = "EmployeeSectorDescription";
            ddlSector.DataValueField = "EmployeeSectorCode";
            ddlSector.DataBind();
            ddlSector.SelectedValue = m_employeeRow["EmployeeSectorCode"].ToString();

            for (int i = 0; i < ddlSector.Items.Count; i++)
            {
                //ddlSector.Items[i].Attributes.Add("isDoctor", ds.Tables[0].Rows[i]["isDoctor"].ToString());
                bool isDoctor = Convert.ToBoolean(ds.Tables[0].Rows[i]["isDoctor"]);
                if (isDoctor)
                {
                    DoctorsCodes.Add(Convert.ToInt32(ddlSector.Items[i].Value));
                }
            }

            ViewState["doctorsCodes"] = DoctorsCodes;

            InitialSectorIsDoctor = DoctorsCodes.Contains(Convert.ToInt32(ddlSector.SelectedValue));
            InitialEmployeeSector = Convert.ToInt32(ddlSector.SelectedValue);
        }

        private void BindHeader()
        {
            EmployeeBO bo = new EmployeeBO();
            EmployeeProfessionBO professionsBo = new EmployeeProfessionBO();
            DataSet ds;
            string speciality = string.Empty;

            // top header
            lblDegree.Text = m_employeeRow["degreeName"].ToString();
            lblFirstName.Text = m_employeeRow["firstName"].ToString();
            lblLastName.Text = m_employeeRow["lastName"].ToString();
            lblSpeciality.Text = m_employeeRow["expert"].ToString();

            // second header
            ds = bo.GetAllEmployeeDegrees();

            ddlDegree.DataTextField = "degreeName";
            ddlDegree.DataValueField = "degreeCode";
            ddlDegree.DataSource = ds.Tables[0];
            ddlDegree.DataBind();
            ddlDegree.SelectedValue = m_employeeRow["degreeCode"].ToString();

            lblFirstNameMF.Text = m_employeeRow["firstName_MF"].ToString();
            lblLastNameMF.Text = m_employeeRow["lastName_MF"].ToString();
            lblIdMF.Text = m_employeeRow["employeeID"].ToString();
            txtFirstName.Text = m_employeeRow["firstName"].ToString();
            txtLastName.Text = m_employeeRow["lastName"].ToString();
            lblLicenseNumber.Text = m_employeeRow["licenseNumber"].ToString() + m_employeeRow["licenseIsDental"].ToString();
            lblProfLicenseNumber.Text = m_employeeRow["ProflicenseNumber"].ToString();
            if (!string.IsNullOrEmpty(txtLanguages.Text))
                _licenseNumber = Convert.ToInt32(txtLanguages.Text);


            // hidden modal popup
            //lblEmployeeProfessions_EmployeeReception.Text = m_employeeRow["expert"].ToString();

        }

        private void GetEmployeeID()
        {
            EmployeeID = SessionParamsHandler.GetEmployeeIdFromSession();
        }

        private void BindPhoneDetails()
        {
            EmployeeBO bo = new EmployeeBO();
            DataTable homePhoneDt = new DataTable();
            DataTable cellPhoneDt = new DataTable();
            DataSet ds = bo.GetEmployee(EmployeeID);


            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                DataTable sourceDt = ds.Tables[0];

                m_employeeRow = ds.Tables[0].DefaultView[0];

                SetTableColumns(homePhoneDt, cellPhoneDt);

                DataRow homeRow = homePhoneDt.NewRow();
                DataRow cellRow = cellPhoneDt.NewRow();

                homeRow["phoneID"] = 1;
                homeRow["phoneOrder"] = 1;

                if (sourceDt.Rows[0]["prePrefix_Home"] != DBNull.Value)
                    homeRow["PrePrefix"] = Convert.ToInt32(sourceDt.Rows[0]["prePrefix_Home"]);

                if (sourceDt.Rows[0]["prefixCode_home"] != DBNull.Value)
                    homeRow["PrefixCode"] = Convert.ToInt32(sourceDt.Rows[0]["prefixCode_home"]);

                if (sourceDt.Rows[0]["prefixText_home"] != DBNull.Value)
                    homeRow["PrefixText"] = Convert.ToInt32(sourceDt.Rows[0]["prefixText_home"]);

                if (sourceDt.Rows[0]["phone_home"] != DBNull.Value)
                    homeRow["phone"] = Convert.ToInt32(sourceDt.Rows[0]["phone_home"]);

                if (sourceDt.Rows[0]["extension_Home"] != DBNull.Value)
                    homeRow["extension"] = Convert.ToInt32(sourceDt.Rows[0]["extension_Home"]);

                cellRow["phoneID"] = 1;
                cellRow["phoneOrder"] = 1;

                if (sourceDt.Rows[0]["prePrefix_cell"] != DBNull.Value)
                    cellRow["PrePrefix"] = Convert.ToInt32(sourceDt.Rows[0]["prePrefix_cell"]);

                if (sourceDt.Rows[0]["prefixCode_cell"] != DBNull.Value)
                    cellRow["PrefixCode"] = Convert.ToInt32(sourceDt.Rows[0]["prefixCode_cell"]);

                if (sourceDt.Rows[0]["prefixText_cell"] != DBNull.Value)
                    cellRow["PrefixText"] = Convert.ToInt32(sourceDt.Rows[0]["prefixText_cell"]);

                if (sourceDt.Rows[0]["phone_cell"] != DBNull.Value)
                    cellRow["phone"] = Convert.ToInt32(sourceDt.Rows[0]["phone_cell"]);

                if (sourceDt.Rows[0]["extension_cell"] != DBNull.Value)
                    cellRow["extension"] = Convert.ToInt32(sourceDt.Rows[0]["extension_cell"]);

                cellPhoneDt.Rows.Add(cellRow);
                homePhoneDt.Rows.Add(homeRow);

                phoneUC.SourcePhones = homePhoneDt;
                cellPhoneUC.SourcePhones = cellPhoneDt;
                phoneUC.EnableAdding = cellPhoneUC.EnableAdding = false;

                chkCellPhoneProtected.Checked = Convert.ToBoolean(sourceDt.Rows[0]["isUnlisted_cell"]);
                chkHomePhoneProtected.Checked = Convert.ToBoolean(sourceDt.Rows[0]["isUnlisted_home"]);

                txtEmail.Text = sourceDt.Rows[0]["email"].ToString();
                chkDisplayOnInternet.Checked = Convert.ToBoolean(sourceDt.Rows[0]["showEmailInInternet"]);

                phoneUC.EnableBlankData = true;
                cellPhoneUC.EnableBlankData = true;
            }
        }

        private void SetTableColumns(DataTable homePhoneDt, DataTable cellPhoneDt)
        {
            Phone.CreateTableStructure(ref homePhoneDt);
            Phone.CreateTableStructure(ref cellPhoneDt);
        }

        private DataTable GetDataTableFromCSV(string stringCSV, string columnName)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add(columnName, string.Empty.GetType());

            string[] itemsCSV = stringCSV.Split(',');

            for (int i = 0; i < itemsCSV.Length; i++)
            {
                dt.Rows.Add(new string[] { itemsCSV[i] });
            }

            return dt;
        }

        private bool CheckIfTablesHasSameHours(DataTable firstDataTable, DataTable secondDataTable)
        {
            for (int i = 0; i < firstDataTable.Rows.Count; i++)
            {
                if (firstDataTable.Rows[i]["receptionDay"].ToString() != secondDataTable.Rows[i]["receptionDay"].ToString() ||
                    firstDataTable.Rows[i]["openingHour"].ToString() != secondDataTable.Rows[i]["openingHour"].ToString() ||
                    firstDataTable.Rows[i]["closingHour"].ToString() != secondDataTable.Rows[i]["closingHour"].ToString() ||
                    firstDataTable.Rows[i]["receptionRemarks"].ToString() != secondDataTable.Rows[i]["receptionRemarks"].ToString())
                {
                    return false;
                }
            }

            return true;
        }

        private void RedirectToLastPage()
        {
            SessionParams sessionParams;
            sessionParams = SessionParamsHandler.GetSessionParams();

            if (sessionParams.CallerUrl != null)
            {
                Response.Redirect(sessionParams.CallerUrl);
            }
            else
            {
                Response.Redirect(PagesConsts.SEARCH_CLINICS_URL);
            }
        }

        #region Events


        protected void ValidateSectorChange(object sender, ServerValidateEventArgs e)
        {
            EmployeeBO bo = new EmployeeBO();
            bool isVirtualDoctor = false, isMedicalTeam = false;
            bool selectedSectorIsDoctor = DoctorsCodes.Contains(Convert.ToInt32(ddlSector.SelectedValue));


            // if the new sector is not allowed professions, and we still have professions from last sector -> error
            if (btnProfessions.Disabled && !string.IsNullOrEmpty(txtProfessions.Text))
            {
                e.IsValid = false;
                vldSectorChange.ErrorMessage = "לא ניתן לשנות סקטור כאשר קיימים מקצועות";
                return;
            }


            // if employee is not doctor, not a virtual doctor, and not a medical team, and the new sector is doctor -> error      
            if (selectedSectorIsDoctor)
            {
                bool isDoctor = bo.IsEmployeeIsDoctor(EmployeeID, _licenseNumber);

                if (!isDoctor)
                {
                    Facade.getFacadeObject().IsVirtualDoctorOrMedicalTeam(EmployeeID, ref isVirtualDoctor, ref isMedicalTeam);

                    if (!isVirtualDoctor && !isMedicalTeam)
                    {
                        if (selectedSectorIsDoctor && !InitialSectorIsDoctor)
                        {
                            vldSectorChange.ErrorMessage = "לא ניתן לשנות סקטור לסקטור רפואה כיוון שנותן שירות לא קיים בטבלת רופאים";
                        }

                    }
                }
            }
        }

        protected void gvRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView dvRowView = e.Row.DataItem as DataRowView;

                Image imgInternet = e.Row.FindControl("imgInternet") as Image;
                if (Convert.ToBoolean(dvRowView["displayInInternet"]) == false)
                {
                    imgInternet.Style.Add("display", "inline");
                    imgInternet.ImageUrl = "../Images/Applic/pic_NotShowInInternet.gif";
                    imgInternet.ToolTip = "לא לתצוגה באינטרנט";
                }
                else
                {
                    imgInternet.Style.Add("display", "none");
                }

            }
        }

        protected void btnSave_click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {

                EmployeeBO bo = new EmployeeBO();
                //int licenceNumber;

                int degreeCode = Convert.ToInt32(ddlDegree.SelectedValue);
                string firstName = txtFirstName.Text;
                string lastName = txtLastName.Text;
                int sex = Convert.ToInt32(ddlGender.SelectedValue);
                //int.TryParse(txtLicenseNumber.Text, out licenceNumber);
                int district = Convert.ToInt32(ddlDistrict.SelectedValue);
                string email = txtEmail.Text;
                bool displayOnInternet = chkDisplayOnInternet.Checked;
                int currentSectorCode = Convert.ToInt32(ddlSector.SelectedValue);
                Facade facade = Facade.getFacadeObject();


                DataTable dt = phoneUC.ReturnData();
                Phone homePhone = null, cellPhone = null;

                if (dt.Rows.Count > 0)
                {
                    homePhone = new Phone(dt.Rows[0]);
                    homePhone.IsUnListed = chkHomePhoneProtected.Checked;
                }

                dt = cellPhoneUC.ReturnData();
                if (dt.Rows.Count > 0)
                {
                    cellPhone = new Phone(dt.Rows[0]);
                    cellPhone.IsUnListed = chkCellPhoneProtected.Checked;
                }

                // save current professions if the initial sector wasn't allowed professions
                if (ProfessionsAllowedForCurrentSector && InitialEmployeeSector != currentSectorCode)
                {
                    facade.UpdateEmployeeProfessions(EmployeeID, hdnProfessions.Value);
                }

                UserInfo currentUser = Session["currentUser"] as UserInfo;
                //Temporary 
                //יש לשייך את נותן השירות למחוז של המעדכן
                //אם המעדכן הוא מנהל מערכת אין לדעת במחוז של נותן השירות
                if (!currentUser.IsAdministrator && currentUser.DistrictCode != -1)
                {
                    district = currentUser.DistrictCode;
                }

                bool result = facade.UpdateEmployeeAndPhones(EmployeeID, degreeCode, firstName,
                    lastName, currentSectorCode, sex, district, email, displayOnInternet, homePhone, cellPhone);

                if (result == true)
                {
                    string redirectTo = "../Public/zoomDoctor.aspx?EmployeeID=" + EmployeeID.ToString();
                    Response.Redirect(redirectTo);
                }
            }
        }

        protected void RebindStatus(object sender, EventArgs e)
        {
            BindEmployeeStatus();
        }

        protected void UpdateDeptEmployeeClick(object sender, EventArgs e)
        {
            GridViewRow row = ((Button)sender).NamingContainer as GridViewRow;
            string deptCode = ((HiddenField)row.FindControl("hiddenDeptCode")).Value;
            Response.Redirect("UpdateDeptEmployee.aspx?DeptCode=" + deptCode + "&EmployeeID=" + EmployeeID);
        }

        protected void btnCancel_click(object sender, EventArgs e)
        {
            GetEmployeeID();
            string redirectTo = "../Public/zoomDoctor.aspx?EmployeeID=" + EmployeeID.ToString();
            Response.Redirect(redirectTo);
        }

        protected void UpdateRemarks_click(object sender, EventArgs e)
        {
            Response.Redirect("UpdateEmployeeRemarks.aspx?EmployeeID=" + EmployeeID.ToString());
        }

        protected void AddRemarks_click(object sender, EventArgs e)
        {
            Response.Redirect("AddRemark.aspx?EmployeeID=" + EmployeeID.ToString());
        }

        protected void rptRemarks_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Label lblDeptName;
                DataRowView row = e.Item.DataItem as DataRowView;

                DataRow[] deptRemarks = m_doctorRemarks.Select("deptCode=" + row["deptCode"].ToString());

                lblDeptName = e.Item.FindControl("lblDeptName") as Label;

                if (deptRemarks.Length > 0)
                {
                    lblDeptName.Visible = true;
                    lblDeptName.Text = "הערה ל" + row["DeptName"].ToString();

                    Repeater rptInnerRemarks = e.Item.FindControl("rptInnerRemarks") as Repeater;
                    rptInnerRemarks.DataSource = deptRemarks;
                    rptInnerRemarks.DataBind();
                }
                else
                {
                    lblDeptName.Visible = false;
                }
            }
        }

        protected void rptInnerRemarks_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Label lblDeptRemark = e.Item.FindControl("lblRemarkForDept") as Label;
                DataRow row = e.Item.DataItem as DataRow;

                if (Convert.ToBoolean(row["DisplayInInternet"]) == false)
                {
                    e.Item.FindControl("imgDontDisplayRemarkOnInternet").Visible = true;
                    //((Image)e.Item.FindControl("imgDontDisplayRemarkOnInternet")).Style.Add("display","inline");
                }

                lblDeptRemark.Text = row["remarkText"].ToString();
            }
        }

        protected void ddlSector_selectedIndexChanged(object sender, EventArgs e)
        {
            int newSelectedSector = Convert.ToInt32(ddlSector.SelectedValue);

            if (string.IsNullOrEmpty(hdnProfessions.Value))
                txtProfessions.Text = hdnProfessions.Value;

            //DataSet ds = Facade.getFacadeObject().GetProfessionsBySector(string.Empty, newSelectedSector);
            DataSet ds = Facade.getFacadeObject().GetServicesNewBySector(string.Empty, newSelectedSector, false, true,
            true, true, true);


            if (ds != null)
            {
                ProfessionsAllowedForCurrentSector = ds.Tables[0].Rows.Count > 0;
            }

            if (ProfessionsAllowedForCurrentSector)
            {
                if (!string.IsNullOrEmpty(txtProfessions.Text) && (newSelectedSector != InitialEmployeeSector))
                {
                    EnableProfessionsAndSpeciality(false);
                }
                else
                {
                    EnableProfessionsAndSpeciality(true);
                    btnProfessions.Attributes.Add("style", "cursor:hand");
                    // Here we put "onclick" - "OpenPopupBySector" fuction instead of "OpenPopup" 
                    // to make possible to rule employee's professions free when changing employee's sector
                    btnProfessions.Attributes.Add("onclick", "confirm('YES?') &&  OpenPopupBySector(2," + newSelectedSector + ",'" + txtProfessions.ClientID + "','" + hdnProfessions.ClientID + "' );return false;");

                    //btnProfessions.Attributes.Add("onclick", "ConfirmIntentionToChangeProfessions() && OpenPopup(2, '" + txtProfessions.ClientID + "', '" + hdnProfessions.ClientID + "' );return false;");
                    //btnProfessions.Attributes.Add("onclick", "OpenPopup(2, '" + txtProfessions.ClientID + "', '" + hdnProfessions.ClientID + "' );return false;");
                }
            }
            else
            {
                EnableProfessionsAndSpeciality(false);
            }
        }
    }
    #endregion
}