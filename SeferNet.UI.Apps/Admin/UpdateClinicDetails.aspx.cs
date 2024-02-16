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
using SeferNet.FacadeLayer;
using SeferNet.UI;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Text;
using System.Globalization;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using MapsManager;
using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using System.Collections.Generic;
using SeferNet.Globals;
using SeferNet.Coordinates.Services;

public partial class UpdateClinicDetails : AdminBasePage
{
    DataSet m_dsDept;
    Facade applicFacade = Facade.getFacadeObject();
    UserInfo currentUser;
    DataTable dtDeptHandicappedFacilities;
    DataTable dtDeptPhones;
    DataTable dtDeptDirectPhones;
    DataTable dtDeptFaxes;
    DataTable dtDeptWhatsApp;
    DataTable dtDeptRemarks;

    CultureInfo culture = new CultureInfo("en-US");

    ClinicDetailsParameters clinicDetailsParameters;
    SessionParams sessionParams;
    protected int CurrentDeptCode = 0;

    double coordinateX;
    double coordinateY;
    double XLongitude;
    double YLatitude;

    bool getCoordXYfromWServiceOK;
    bool needToUpdateCoordinates;

    bool phonesHasChanged;
    bool addressHasChanged;
    bool ClinicStatus_TemporarilyInactive_FirstTime;

    // Clinic name update handling
    int previousClinicType;
    int newClinicType;
    string deptNameFreePart;
    string previousCityName;
    string newCityName;
    string previousDistrictName;
    string newDistrictName;

    protected void Page_Load(object sender, EventArgs e)
    {
        Form.DefaultButton = btnUpdate_Bottom.UniqueID;

        currentUser = Session["currentUser"] as UserInfo;


        sessionParams = SessionParamsHandler.GetSessionParams();

        CurrentDeptCode = sessionParams.DeptCode;

        if (CurrentDeptCode == 0 || currentUser == null)    // is session expired?
        {
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);
        }

        if (ViewState["ClinicStatus_TemporarilyInactive_FirstTime"] != null)
        {
            ClinicStatus_TemporarilyInactive_FirstTime = Convert.ToBoolean(ViewState["ClinicStatus_TemporarilyInactive_FirstTime"]);
        }

        SetUserControls();

        if (!IsPostBack)
        {
            //read data from SQL to "clinicDetailsParameters" and "tables" (into session as well)
            m_dsDept = applicFacade.GetDeptDetailsForUpdate(CurrentDeptCode);
            ReadClinicDetailsParameters();

            txtDeptCode.Text = clinicDetailsParameters.DeptCode.ToString();

            SetUserControlsData();
            SetQueueOrderVisibility();

            BindDropDownLists();
            BindDeptDeptQueueOrderHeadLine();
            BindDeptDetails();

            BindDeptRemarks();

            bool isHospital = bool.Parse(m_dsDept.Tables[0].Rows[0]["IsHospital"].ToString());
            if (isHospital)
            {
                autoCompleteDistricts.ContextKey = "60,65";
                btnDistrictsPopUp.Attributes.Add("onclick", "SelectDistricts('60,65');return false;");
            }
            else
            {
                autoCompleteDistricts.ContextKey = "65";
                btnDistrictsPopUp.Attributes.Add("onclick", "SelectDistricts('65');return false;");
            }

            btnUpdate.Attributes.Add("disabled", "true");
            btnUpdate_Bottom.Attributes.Add("disabled", "true");

            DataSet ds_statuses = applicFacade.GetAllStatuses(CurrentDeptCode, 0, 0, Enums.EntityTypesStatus.Dept);

            if (ds_statuses.Tables[0].Rows.Count == 1
                && Convert.ToInt32(ds_statuses.Tables[0].Rows[0]["Status"]) == 2)
            {
                ClinicStatus_TemporarilyInactive_FirstTime = true;
            }
            else
            {
                ClinicStatus_TemporarilyInactive_FirstTime = false;
            }

            ViewState["ClinicStatus_TemporarilyInactive_FirstTime"] = ClinicStatus_TemporarilyInactive_FirstTime;

        }
        else
        {
            //restore data from session to "clinicDetailsParameters" and "tables"
            if (ViewState["clinicDetailsParameters"] != null)
            {
                clinicDetailsParameters = ViewState["clinicDetailsParameters"] as ClinicDetailsParameters;
            }

            if (txtStreetCode.Text != string.Empty)
                txtNeighborhoodAndSite.Enabled = false;
            else
                txtNeighborhoodAndSite.Enabled = true;

            btnUpdate.Attributes.Remove("disabled");
            btnUpdate_Bottom.Attributes.Remove("disabled");
        }

        if (txtNewClinicName.Text != string.Empty)
        {
            lblDeptName.Text = txtNewClinicName.Text.Replace("`", "'"); 
        }

        if (currentUser.IsAdministrator || (currentUser.IsDistrictPermitted(clinicDetailsParameters.DistrictCode) && ClinicStatus_TemporarilyInactive_FirstTime))
        {
            tblOpenDeptNameLB.Style.Add("display", "inline");
            ddlUnitType.Enabled = true;
            if (ddlSubUnitType.Items.Count > 0)
            {
                ddlSubUnitType.Enabled = true;
            }
        }
        else
        {
            tblOpenDeptNameLB.Style.Add("display", "none");
            ddlUnitType.Enabled = false;
            ddlSubUnitType.Enabled = false;
        }

        bool makeEnabled = false;
        DataTable hospitals = applicFacade.getDistrictsByUnitType("60").Tables[0];
        foreach (DataRow dr in hospitals.Rows)
        {
            if (clinicDetailsParameters.DistrictCode == (int)dr["districtCode"] && ddlSubUnitType.Items.Count > 0)
            {
                makeEnabled = true;
            }
        }

        if (makeEnabled)
        {
            ddlSubUnitType.Enabled = true;
        }

        string hospitaAdminMail = System.Configuration.ConfigurationManager.AppSettings["ReportClinicOfHospitalTypeChangeToMail"].ToString();

        hospitaAdminMail = hospitaAdminMail.Remove(hospitaAdminMail.IndexOf(';'), hospitaAdminMail.Length - hospitaAdminMail.IndexOf(';'));

        if (currentUser.IsAdministrator
            || (currentUser.IsDistrictPermitted(clinicDetailsParameters.DistrictCode) && !ClinicStatus_TemporarilyInactive_FirstTime)
            || (clinicDetailsParameters.IsHospital && currentUser.Mail.ToUpper() == hospitaAdminMail.ToUpper()))
        {
            btnDeptStatus.Enabled = true;
            btnDeptStatus.OnClientClick = "return UpdateStatus();";
        }
        else
        {
            btnDeptStatus.Enabled = false;
            btnDeptStatus.OnClientClick = "return false;";
        }

        if (!ClinicStatus_TemporarilyInactive_FirstTime)
        {
            tblSendMailToChangeStatusToActive.Style.Add("display", "none");
        }

        SetDropDownSelected_ClientFunction();

        if (currentUser.IsAdministrator)
        {
            autoCompleteCities.ContextKey = "-1_" + clinicDetailsParameters.DeptCode;
            //cbShowEmailInInternet.Enabled = true;
        }
        else
        {
            autoCompleteCities.ContextKey = ddlDistrict.SelectedValue + "_" + clinicDetailsParameters.DeptCode;

            cbIsCommunity.Enabled = false;
            cbIsMushlam.Enabled = false;
            cbIsHospital.Enabled = false;

            //cbShowEmailInInternet.Enabled = false;
        }

        autoCompleteStreets.ContextKey = txtCityCode.Text;

        autoCompleteNeighborhood.ContextKey = txtCityCode.Text;

        if (cbManualCoordinates.Checked)
        {
            txtCoordinateX.Enabled = true;
            txtCoordinateY.Enabled = true;
        }
        else
        {
            txtCoordinateX.Enabled = false;
            txtCoordinateY.Enabled = false;
        }

        HandleLightBoxes();

        lblQueueOrder.Text = txtQueueOrder.Text;

        //Session["newCityName"] = txtCityName.Text;
        Session["newCityName"] = RemoveDistrictNameFromCityName(txtCityName.Text); //ddlDistrict

        if (Session["newCityName"] != null)
        {
            if (Session["newCityName"].ToString() != Session["previousCityName"].ToString())
            {
                cbDeptNameToBeChangedManually.Checked = ClinicNameToBeUpdatedManually();
            }
        }

        if (Session["NewStatusDescription"] != null)
        {
            btnDeptStatus.Text = Session["NewStatusDescription"].ToString();
        }

        if (cbCauseUpdateRemarksClick.Checked)
        {
            cbCauseUpdateRemarksClick.Checked = false;
            btnUpdateRemarks_Click("Text", null);
        }

        if (cbCauseAddRemarksClick.Checked)
        {
            cbCauseAddRemarksClick.Checked = false;
            btnAddRemarks_Click("Text", null);
        }

    }

    private string RemoveDistrictNameFromCityName(string cityName)
    {
        int substringIndex = cityName.IndexOf(" - מחוז");

        if (substringIndex > 0)
            return cityName.Substring(0, cityName.IndexOf(" - מחוז"));
        else
            return cityName;
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
    private void SetUserControlsData()
    {
        DataTable dtPh = new DataTable();

        Phone.CreateTableStructure(ref dtPh);

        for (int i = 0; i < dtDeptPhones.Rows.Count; i++)
        {
            DataRow dr = dtPh.NewRow();
            dr["prePrefix"] = dtDeptPhones.Rows[i]["prePrefix"];//"1";
            dr["prefixCode"] = dtDeptPhones.Rows[i]["prefixCode"];
            dr["prefixText"] = dtDeptPhones.Rows[i]["prefixText"];
            dr["phone"] = dtDeptPhones.Rows[i]["phone"];
            dr["phoneID"] = DBNull.Value;
            dr["phoneOrder"] = dtDeptPhones.Rows[i]["phoneOrder"];
            dr["extension"] = dtDeptPhones.Rows[i]["extension"];

            if (dtDeptPhones.Rows[i]["extension"] != null)
            {
                dr["remark"] = dtDeptPhones.Rows[i]["remark"];
            }

            dtPh.Rows.Add(dr);
        }

        ClinicPhonesUC.SourcePhones = dtPh;

        ViewState["dtDeptPhones"] = dtPh;

        DataTable dtFx = new DataTable();

        Phone.CreateTableStructure(ref dtFx);

        for (int i = 0; i < dtDeptFaxes.Rows.Count; i++)
        {
            DataRow dr = dtFx.NewRow();
            dr["prePrefix"] = dtDeptFaxes.Rows[i]["prePrefix"];//"1";
            dr["prefixCode"] = dtDeptFaxes.Rows[i]["prefixCode"];
            dr["prefixText"] = dtDeptFaxes.Rows[i]["prefixText"];
            dr["phone"] = dtDeptFaxes.Rows[i]["phone"];
            dr["phoneID"] = DBNull.Value;
            dr["phoneOrder"] = dtDeptFaxes.Rows[i]["phoneOrder"];
            dr["extension"] = dtDeptFaxes.Rows[i]["extension"];

            if (dtDeptFaxes.Rows[i]["extension"] != null)
            {
                dr["remark"] = dtDeptFaxes.Rows[i]["remark"];
            }

            dtFx.Rows.Add(dr);
        }

        ClinicFaxesUC.SourcePhones = dtFx;

        ViewState["dtDeptFaxes"] = dtFx;


        DataTable dtDirPh = new DataTable();

        Phone.CreateTableStructure(ref dtDirPh);

        for (int i = 0; i < dtDeptDirectPhones.Rows.Count; i++)
        {
            DataRow dr = dtDirPh.NewRow();
            dr["prePrefix"] = dtDeptDirectPhones.Rows[i]["prePrefix"];//"1";
            dr["prefixCode"] = dtDeptDirectPhones.Rows[i]["prefixCode"];
            dr["prefixText"] = dtDeptDirectPhones.Rows[i]["prefixText"];
            dr["phone"] = dtDeptDirectPhones.Rows[i]["phone"];
            dr["phoneID"] = DBNull.Value;
            dr["phoneOrder"] = dtDeptDirectPhones.Rows[i]["phoneOrder"];
            dr["extension"] = dtDeptDirectPhones.Rows[i]["extension"];

            if (dtDeptDirectPhones.Rows[i]["extension"] != null)
            {
                dr["remark"] = dtDeptDirectPhones.Rows[i]["remark"];
            }

            dtDirPh.Rows.Add(dr);
        }

        ClinicDirectPhonesUC.SourcePhones = dtDirPh;

        ViewState["dtDeptDirectPhones"] = dtDirPh;


        DataTable dtWAppPh = new DataTable();

        Phone.CreateTableStructure(ref dtWAppPh);

        for (int i = 0; i < dtDeptWhatsApp.Rows.Count; i++)
        {
            DataRow dr = dtWAppPh.NewRow();
            dr["prePrefix"] = dtDeptWhatsApp.Rows[i]["prePrefix"];//"1";
            dr["prefixCode"] = dtDeptWhatsApp.Rows[i]["prefixCode"];
            dr["prefixText"] = dtDeptWhatsApp.Rows[i]["prefixText"];
            dr["phone"] = dtDeptWhatsApp.Rows[i]["phone"];
            dr["phoneID"] = DBNull.Value;
            dr["phoneOrder"] = dtDeptWhatsApp.Rows[i]["phoneOrder"];
            dr["extension"] = dtDeptWhatsApp.Rows[i]["extension"];

            if (dtDeptWhatsApp.Rows[i]["extension"] != null)
            {
                dr["remark"] = dtDeptWhatsApp.Rows[i]["remark"];
            }

            dtWAppPh.Rows.Add(dr);
        }

        ClinicWhatsAppUC.SourcePhones = dtWAppPh;

        ViewState["dtDeptWhatsApp"] = dtWAppPh;
    }

    private void SetDropDownSelected_ClientFunction()
    {
        ddlPopulationSector.Attributes.Add("onchange", "SetDropDownSelected(" + ddlPopulationSector.ClientID + "," + txt_ddlPopulationSector.ClientID + " )");
        ddlParking.Attributes.Add("onchange", "SetDropDownSelected(" + ddlParking.ClientID + "," + txt_ddlParking.ClientID + " )");
        ddlUnitType.Attributes.Add("onchange", "SetDropDownSelected(" + ddlUnitType.ClientID + "," + txt_ddlUnitType.ClientID + " )");
    }



    private void HandleLightBoxes()
    {
        if (cbDeptNameLB_IsOpened.Checked == true)
        {
            ClientScript.RegisterStartupScript(typeof(string), "OpenDeptNameLB", "OpenDeptNameLB();", true);
        }
    }

    void ReadClinicDetailsParameters()
    {
        clinicDetailsParameters = new ClinicDetailsParameters();
        DataRow dr_dept = m_dsDept.Tables["DeptDetails"].Rows[0];

        clinicDetailsParameters.DeptName = dr_dept["deptName"].ToString();
        clinicDetailsParameters.DeptNameFreePart = dr_dept["deptNameFreePart"].ToString();
        clinicDetailsParameters.DeptType = Convert.ToInt32(dr_dept["deptType"]);
        clinicDetailsParameters.IsCommunity = Convert.ToBoolean(dr_dept["IsCommunity"]);
        clinicDetailsParameters.IsMushlam = Convert.ToBoolean(dr_dept["IsMushlam"]);
        clinicDetailsParameters.IsHospital = Convert.ToBoolean(dr_dept["IsHospital"]);
        clinicDetailsParameters.TypeUnitCode = Convert.ToInt32(dr_dept["typeUnitCode"]);
        clinicDetailsParameters.SubUnitTypeCode = Convert.ToInt32(dr_dept["subUnitTypeCode"]);
        clinicDetailsParameters.DeptLevel = Convert.ToInt32(dr_dept["deptLevel"]);
        clinicDetailsParameters.ManagerName = dr_dept["managerName"].ToString();
        clinicDetailsParameters.SubstituteManagerName = dr_dept["substituteManagerName"].ToString();
        clinicDetailsParameters.AdministrativeManagerName = dr_dept["administrativeManagerName"].ToString();
        clinicDetailsParameters.SubstituteAdministrativeManagerName = dr_dept["substituteAdministrativeManagerName"].ToString();
        clinicDetailsParameters.CityCode = Convert.ToInt32(dr_dept["cityCode"]);
        clinicDetailsParameters.CityName = dr_dept["CityName"].ToString();
        clinicDetailsParameters.Street = dr_dept["StreetCode"].ToString(); // from dept
        clinicDetailsParameters.StreetName = dr_dept["streetName"].ToString(); // from streets
        clinicDetailsParameters.House = dr_dept["house"].ToString();
        clinicDetailsParameters.Flat = dr_dept["flat"].ToString();
        clinicDetailsParameters.Floor = dr_dept["floor"].ToString();
        clinicDetailsParameters.Building = dr_dept["Building"].ToString();
        clinicDetailsParameters.AddressComment = dr_dept["addressComment"].ToString();
        clinicDetailsParameters.Email = dr_dept["email"].ToString();
        clinicDetailsParameters.LinkToBlank17 = dr_dept["LinkToBlank17"].ToString();
        clinicDetailsParameters.LinkToContactUs = dr_dept["LinkToContactUs"].ToString();
        clinicDetailsParameters.ShowEmailInInternet = Convert.ToBoolean(dr_dept["showEmailInInternet"]);
        clinicDetailsParameters.Transportation = dr_dept["transportation"].ToString();
        clinicDetailsParameters.Parking = Convert.ToInt32(dr_dept["parking"]);
        clinicDetailsParameters.DistrictCode = Convert.ToInt32(dr_dept["districtCode"]);
        clinicDetailsParameters.AdministrationCode = Convert.ToInt32(dr_dept["administrationCode"]);
        clinicDetailsParameters.SubAdministrationCode = Convert.ToInt32(dr_dept["subAdministrationCode"]);
        clinicDetailsParameters.SubAdministrationName = dr_dept["subAdministrationName"].ToString();
        clinicDetailsParameters.ParentClinicCode = Convert.ToInt32(dr_dept["parentClinicCode"]);
        clinicDetailsParameters.ParentClinicName = dr_dept["parentClinicName"].ToString();
        clinicDetailsParameters.PopulationSectorCode = Convert.ToInt32(dr_dept["populationSectorCode"]);
        clinicDetailsParameters.DeptCode = Convert.ToInt32(dr_dept["deptCode"]);
        if (dr_dept["Simul228"] != DBNull.Value)
            clinicDetailsParameters.Simul228 = Convert.ToInt32(dr_dept["Simul228"]);
        clinicDetailsParameters.StatusDescription = dr_dept["statusDescription"].ToString();
        clinicDetailsParameters.DeptNameSimul = dr_dept["deptNameSimul"].ToString();
        clinicDetailsParameters.StatusSimul = dr_dept["statusSimul"].ToString();
        clinicDetailsParameters.OpenDateSimul = dr_dept["openDateSimul"].ToString();
        clinicDetailsParameters.ClosingDateSimul = dr_dept["closingDateSimul"].ToString();
        clinicDetailsParameters.SimulManageDescription = dr_dept["SimulManageDescription"].ToString();
        clinicDetailsParameters.SugSimul501 = dr_dept["SugSimul501"] != DBNull.Value ? Convert.ToInt32(dr_dept["SugSimul501"]) : 0;
        clinicDetailsParameters.TatSugSimul502 = dr_dept["TatSugSimul502"] != DBNull.Value ? Convert.ToInt32(dr_dept["TatSugSimul502"]) : 0;
        clinicDetailsParameters.TatHitmahut503 = dr_dept["TatHitmahut503"] != DBNull.Value ? Convert.ToInt32(dr_dept["TatHitmahut503"]) : 0;
        clinicDetailsParameters.RamatPeilut504 = dr_dept["RamatPeilut504"] != DBNull.Value ? Convert.ToInt32(dr_dept["RamatPeilut504"]) : 0;
        clinicDetailsParameters.SugSimulDesc = dr_dept["SugSimulDesc"].ToString();
        clinicDetailsParameters.TatSugSimulDesc = dr_dept["TatSugSimulDesc"].ToString();
        clinicDetailsParameters.TatHitmahutDesc = dr_dept["TatHitmahutDesc"].ToString();
        clinicDetailsParameters.RamatPeilutDesc = dr_dept["RamatPeilutDesc"].ToString();
        clinicDetailsParameters.UnitTypeNameSimul = dr_dept["UnitTypeNameSimul"].ToString();
        clinicDetailsParameters.UnitTypeCodeSimul = dr_dept["UnitTypeCodeSimul"] != DBNull.Value ? Convert.ToInt32(dr_dept["UnitTypeCodeSimul"]) : 0;
        clinicDetailsParameters.ShowUnitInInternet = Convert.ToBoolean(dr_dept["showUnitInInternet"]);
        clinicDetailsParameters.AllowQueueOrder = Convert.ToBoolean(dr_dept["AllowQueueOrder"]);
        clinicDetailsParameters.Xcoord = Convert.ToDouble(dr_dept["xcoord"]);
        clinicDetailsParameters.Ycoord = Convert.ToDouble(dr_dept["ycoord"]);
        clinicDetailsParameters.XLongitude = Convert.ToDouble(dr_dept["XLongitude"]);
        clinicDetailsParameters.YLatitude = Convert.ToDouble(dr_dept["YLatitude"]);
        clinicDetailsParameters.UpdateCoordinatesManually = Convert.ToBoolean(dr_dept["UpdateManually"]);
        clinicDetailsParameters.NeighbourhoodOrInstituteCode = dr_dept["NeighbourhoodOrInstituteCode"].ToString();
        clinicDetailsParameters.NeighbourhoodOrInstituteName = dr_dept["NeighbourhoodOrInstituteName"].ToString();
        if (dr_dept["IsSite"] != DBNull.Value)
            clinicDetailsParameters.IsSite = Convert.ToInt32(dr_dept["IsSite"]);
        clinicDetailsParameters.AdditionaDistrictCodes = dr_dept["AdditionaDistrictCodes"].ToString();
        clinicDetailsParameters.AdditionaDistrictNames = dr_dept["AdditionaDistrictNames"].ToString();
        clinicDetailsParameters.ReligionCode = Convert.ToInt32(dr_dept["ReligionCode"]);
        clinicDetailsParameters.AllowContactHospitalUnit = Convert.ToInt32(dr_dept["AllowContactHospitalUnit"]);

        if (dr_dept["TypeOfDefenceCode"] != DBNull.Value)
            clinicDetailsParameters.TypeOfDefenceCode = Convert.ToInt32(dr_dept["TypeOfDefenceCode"]);
        if (dr_dept["DefencePolicyCode"] != DBNull.Value)
            clinicDetailsParameters.DefencePolicyCode = Convert.ToInt32(dr_dept["DefencePolicyCode"]);
        if (dr_dept["HasElectricalPanel"] != DBNull.Value)
            clinicDetailsParameters.HasElectricalPanel = Convert.ToBoolean(dr_dept["HasElectricalPanel"]);
        if (dr_dept["HasGenerator"] != DBNull.Value)
            clinicDetailsParameters.HasGenerator = Convert.ToBoolean(dr_dept["HasGenerator"]);
        if (dr_dept["IsUnifiedClinic"] != DBNull.Value)
            clinicDetailsParameters.IsUnifiedClinic = Convert.ToBoolean(dr_dept["IsUnifiedClinic"]);

        if (dr_dept["DeptShalaCode"] != DBNull.Value)
            clinicDetailsParameters.DeptShalaCode = Convert.ToInt64(dr_dept["DeptShalaCode"]);

        ViewState["clinicDetailsParameters"] = clinicDetailsParameters;

        ViewState["previeusUnitTypeCode"] = Convert.ToInt32(dr_dept["typeUnitCode"]);
        ViewState["previeusUnitTypeName"] = dr_dept["UnitTypeName"].ToString();

        ViewState["deptStatus"] = Convert.ToInt32(dr_dept["status"]);

        dtDeptRemarks = m_dsDept.Tables["Remarks"];
        dtDeptHandicappedFacilities = m_dsDept.Tables["DeptHandicappedFacilities"];
        dtDeptPhones = m_dsDept.Tables["DeptPhones"];
        dtDeptFaxes = m_dsDept.Tables["DeptFaxes"];
        dtDeptDirectPhones = m_dsDept.Tables["DeptDirectPhones"];
        dtDeptWhatsApp = m_dsDept.Tables["WhatsAppPhones"];

    }

    public void BindDeptDetails()
    {
        lblDeptName.Text = clinicDetailsParameters.DeptName;
        cbShowUnitInInternet.Checked = clinicDetailsParameters.ShowUnitInInternet;
        cbIsCommunity.Checked = clinicDetailsParameters.IsCommunity;
        cbIsMushlam.Checked = clinicDetailsParameters.IsMushlam;
        cbIsHospital.Checked = clinicDetailsParameters.IsHospital;
        ddlDistrict.SelectedValue = clinicDetailsParameters.DistrictCode.ToString();
        txtDistrictCodes.Text = clinicDetailsParameters.AdditionaDistrictCodes.ToString();
        txtDistrictList.Text = clinicDetailsParameters.AdditionaDistrictNames.ToString();

        ddlAdministration.SelectedValue = clinicDetailsParameters.AdministrationCode.ToString();
        ddlPopulationSector.SelectedValue = clinicDetailsParameters.PopulationSectorCode.ToString();
        txtSubAdministrationCode.Text = clinicDetailsParameters.SubAdministrationCode.ToString();
        txtSubAdministrationName.Text = clinicDetailsParameters.SubAdministrationName;
        txtParentClinicCode.Text = clinicDetailsParameters.ParentClinicCode.ToString();
        txtParentClinicName.Text = clinicDetailsParameters.ParentClinicName;

        btnDeptStatus.Text = clinicDetailsParameters.StatusDescription;
        lblDeptCode.Text = clinicDetailsParameters.DeptCode.ToString();
        if (clinicDetailsParameters.Simul228 != 0)
            lblSimul228.Text = clinicDetailsParameters.Simul228.ToString();

        txtCityName.Text = clinicDetailsParameters.CityName;
        txtCityCode.Text = clinicDetailsParameters.CityCode.ToString();
        txtStreet.Text = clinicDetailsParameters.StreetName; // "street" field from "dept"
        txtStreetCode.Text = clinicDetailsParameters.Street;
        txtHouse.Text = clinicDetailsParameters.House;
        txtFlat.Text = clinicDetailsParameters.Flat;
        txtFloor.Text = clinicDetailsParameters.Floor;
        txtBuilding.Text = clinicDetailsParameters.Building;
        txtLinkToBlank17.Text = clinicDetailsParameters.LinkToBlank17;
        txtLinkToContactUs.Text = clinicDetailsParameters.LinkToContactUs;
        txtAddressComment.Text = clinicDetailsParameters.AddressComment;
        txtIsSite.Text = clinicDetailsParameters.IsSite.ToString();
        txtNeighborhoodAndSiteCode.Text = clinicDetailsParameters.NeighbourhoodOrInstituteCode;
        txtNeighborhoodAndSite.Text = clinicDetailsParameters.NeighbourhoodOrInstituteName;
        if (clinicDetailsParameters.Street != string.Empty)
            txtNeighborhoodAndSite.Enabled = false;

        // 29.07.2012 - Vadim Rasin, Show the X/Y Coordinates for the administrator only for update.
        this.txtCoordinateX.Text = clinicDetailsParameters.Xcoord.ToString();
        this.txtCoordinateY.Text = clinicDetailsParameters.Ycoord.ToString();
        this.cbManualCoordinates.Checked = clinicDetailsParameters.UpdateCoordinatesManually;

        txtEmail.Text = clinicDetailsParameters.Email;
        cbShowEmailInInternet.Checked = Convert.ToBoolean(clinicDetailsParameters.ShowEmailInInternet);
        txtTransport.Text = clinicDetailsParameters.Transportation;
        ddlParking.SelectedValue = clinicDetailsParameters.Parking.ToString();

        ddlUnitType.SelectedValue = clinicDetailsParameters.TypeUnitCode.ToString();
        BindSubUnitTypeDdl(Convert.ToInt32(ddlUnitType.SelectedValue));
        if (ddlSubUnitType.Items.Count > 0)
            ddlSubUnitType.SelectedValue = clinicDetailsParameters.SubUnitTypeCode.ToString();
        //ddlDeptLevel.SelectedValue = clinicDetailsParameters.DeptLevel.ToString();

        ddlReligion.SelectedValue = clinicDetailsParameters.ReligionCode.ToString();
        cbAllowContactHospitalUnit.Checked = Convert.ToBoolean(clinicDetailsParameters.AllowContactHospitalUnit);
        if (!clinicDetailsParameters.IsHospital)
        {
            cbAllowContactHospitalUnit.Style.Add("display", "none");
            lbAllowContactHospitalUnit.Style.Add("display", "none");
        }

            lbldeptNameSimul.Text = clinicDetailsParameters.DeptNameSimul;
        lblStatusSimul.Text = clinicDetailsParameters.StatusSimul;
        if (clinicDetailsParameters.OpenDateSimul != string.Empty)
            lblOpenDateSimul.Text = DateTime.Parse(clinicDetailsParameters.OpenDateSimul, culture).ToString("dd/MM/yyyy");
        else
            lblOpenDateSimul.Text = string.Empty;
        if (clinicDetailsParameters.ClosingDateSimul != string.Empty)
            lblClosingDateSimul.Text = DateTime.Parse(clinicDetailsParameters.ClosingDateSimul, culture).ToString("dd/MM/yyyy");
        else
            lblClosingDateSimul.Text = string.Empty;
        lblSimulManageDescription.Text = clinicDetailsParameters.SimulManageDescription;
        lblCodeSugSimul501.Text = clinicDetailsParameters.SugSimul501.ToString();
        lblSugSimul501.Text = clinicDetailsParameters.SugSimulDesc;
        lblCodeTatSugSimul502.Text = clinicDetailsParameters.TatSugSimul502.ToString();
        lblTatSugSimul502.Text = clinicDetailsParameters.TatSugSimulDesc;
        lblCodeTatHitmahut503.Text = clinicDetailsParameters.TatHitmahut503.ToString();
        lblTatHitmahut503.Text = clinicDetailsParameters.TatHitmahutDesc;
        lblCodeRamatPeilut504.Text = clinicDetailsParameters.RamatPeilut504.ToString();
        lblRamatPeilut504.Text = clinicDetailsParameters.RamatPeilutDesc;
        lblUnitTypeNameSimul.Text = clinicDetailsParameters.UnitTypeNameSimul;
        lblUnitTypeCode.Text = clinicDetailsParameters.UnitTypeCodeSimul.ToString();

        /// The logic of "ManagerName" is:
        /// If someone in clinic has "manager" position then we show his(her) hame as "ManagerName"
        /// AND make txtManagerName textbox disabled not to give the user to change it
        /// BUT we need parameter "managerName" for 
        /// SO in this case we'll use txtManagerNameHidden
        /// The same with "administrativeManagerName"
        /// 
        if (clinicDetailsParameters.SubstituteManagerName != string.Empty)
        {
            txtManagerName.Text = clinicDetailsParameters.SubstituteManagerName;
            txtManagerName.Enabled = false;
        }
        else
        {
            txtManagerName.Text = clinicDetailsParameters.ManagerName;
        }
        txtManagerNameHidden.Text = clinicDetailsParameters.SubstituteManagerName;

        if (clinicDetailsParameters.SubstituteAdministrativeManagerName != string.Empty)
        {
            txtAdministrativeManagerName.Text = clinicDetailsParameters.SubstituteAdministrativeManagerName;
            txtAdministrativeManagerName.Enabled = false;
        }
        else
        {
            txtAdministrativeManagerName.Text = clinicDetailsParameters.AdministrativeManagerName;
        }
        txtAdministrativeManagerNameHidden.Text = clinicDetailsParameters.SubstituteAdministrativeManagerName;

        cbHandicappedFacilities.DataSource = dtDeptHandicappedFacilities;
        cbHandicappedFacilities.DataBind();

        // Set TextBoxes attributed to DropDownLists
        //txt_ddlAdministration.Text = clinicDetailsParameters.AdministrationCode.ToString();
        txt_ddlPopulationSector.Text = clinicDetailsParameters.PopulationSectorCode.ToString();
        txt_ddlParking.Text = clinicDetailsParameters.Parking.ToString();
        txt_ddlUnitType.Text = clinicDetailsParameters.TypeUnitCode.ToString();

        if (clinicDetailsParameters.TypeOfDefenceCode != null)
            ddlTypeOfDefence.SelectedValue = clinicDetailsParameters.TypeOfDefenceCode.ToString();

        if (clinicDetailsParameters.IsUnifiedClinic != null)
            ddlUnifiedClinic.SelectedValue = Convert.ToInt16(clinicDetailsParameters.IsUnifiedClinic).ToString();

        if (clinicDetailsParameters.HasElectricalPanel != null)
            ddlElectricalPanel.SelectedValue = Convert.ToInt16(clinicDetailsParameters.HasElectricalPanel).ToString();

        if (clinicDetailsParameters.DefencePolicyCode != null)
            ddlDefencePolicy.SelectedValue = clinicDetailsParameters.DefencePolicyCode.ToString();

        if (clinicDetailsParameters.HasGenerator != null)
            ddlGenerator.SelectedValue = Convert.ToInt16(clinicDetailsParameters.HasGenerator).ToString();

        if (clinicDetailsParameters.DeptShalaCode != null)
            txtlDeptShalaCode.Text = Convert.ToInt64(clinicDetailsParameters.DeptShalaCode).ToString();

        //if (clinicDetailsParameters.ReligionCode != null)
            ddlReligion.SelectedValue = Convert.ToInt32(clinicDetailsParameters.ReligionCode).ToString();

        if (!currentUser.IsAdministrator)
        {
            bool cbPermitted = false;
            List<UserPermission> userPermissions = currentUser.UserPermissions;

            for (int i = 0; i < userPermissions.Count; i++)
            {
                if (currentUser.IsDistrictPermitted(clinicDetailsParameters.DistrictCode))
                    cbPermitted = true;
            }

            if (!cbPermitted)
                cbShowUnitInInternet.Enabled = false;
        }

        if (!clinicDetailsParameters.IsHospital)
        {
            trLinkToBlank.Style.Add("display", "none");
            trLinkToContactUs.Style.Add("display", "none");
        }

        // Clinic name update handling

        Session["deptLevel"] = clinicDetailsParameters.DeptLevel;

        previousClinicType = clinicDetailsParameters.TypeUnitCode;
        Session["previousClinicType"] = previousClinicType;
        Session["previousClinicTypeName"] = ddlUnitType.SelectedItem.Text;

        newClinicType = previousClinicType;
        Session["newClinicType"] = newClinicType;

        if (clinicDetailsParameters.DeptNameFreePart != null && clinicDetailsParameters.DeptNameFreePart != String.Empty)
        {
            cbDeptNameFreePartExists.Checked = true; //???
            deptNameFreePart = clinicDetailsParameters.DeptNameFreePart;
            Session["deptNameFreePart"] = deptNameFreePart;
        }
        else
        {
            deptNameFreePart = string.Empty;
            Session["deptNameFreePart"] = deptNameFreePart;
        }

        previousCityName = clinicDetailsParameters.CityName;
        Session["previousCityName"] = previousCityName;

        newCityName = previousCityName;
        Session["newCityName"] = newCityName;

        previousDistrictName = ddlDistrict.SelectedItem.Text;
        Session["previousDistrictName"] = previousDistrictName;

        newDistrictName = previousDistrictName;
        Session["newDistrictName"] = newDistrictName;
    }

    public void BindDeptDeptQueueOrderHeadLine()
    {
        if (m_dsDept.Tables["DeptQueueOrderMethods_ForHeadline"].Rows.Count == 1)
        {
            lblQueueOrder.Text = m_dsDept.Tables["DeptQueueOrderMethods_ForHeadline"].Rows[0][0].ToString();
            txtQueueOrder.Text = m_dsDept.Tables["DeptQueueOrderMethods_ForHeadline"].Rows[0][0].ToString();
        }
    }

    private void SetQueueOrderVisibility()
    {
        if (clinicDetailsParameters.AllowQueueOrder)
            tblQueueOrder.Style.Add("display", "inline");
        else
            tblQueueOrder.Style.Add("display", "none");
    }

    public bool BindDeptRemarks()
    {
        gvRemarks.DataSource = dtDeptRemarks;
        gvRemarks.DataBind();

        return true;
    }

    private void BindDropDownLists()
    {
        UIHelper.BindDropDownToCachedTable(ddlUnitType, "View_UnitType", "UnitTypeName");
        bool isHospital = bool.Parse(m_dsDept.Tables[0].Rows[0]["IsHospital"].ToString());
        bool isMushlam = bool.Parse(m_dsDept.Tables[0].Rows[0]["isMushlam"].ToString());
        bool isCommunity = bool.Parse(m_dsDept.Tables[0].Rows[0]["IsCommunity"].ToString());
        if (!isHospital)
            UIHelper.BindDropDownToCachedTable(ddlDistrict, "View_AllDistricts", "districtName");
        else
        {

            DataSet ds;
            if (isMushlam || isCommunity)
            {
                /* Get the units that there unitType is district or hospital */
                ds = applicFacade.getDistrictsByUnitType("65,60");
            }
            else
            {
                /* Get only units that there unitType is hospital */
                ds = applicFacade.getDistrictsByUnitType("60");
            }
            UIHelper.BindDropDownToTable(ddlDistrict, ds.Tables[0], "");
        }

        UIHelper.BindDropDownToCachedTable(ddlPopulationSector, "PopulationSectors", "PopulationSectorDescription");
        UIHelper.BindDropDownToCachedTable(ddlParking, "DIC_ParkingInClinic", "parkingInClinicCode");

        if (Convert.ToInt32(clinicDetailsParameters.DeptType) == 3)
        {
            BindAdministrationDdl(Convert.ToInt32(clinicDetailsParameters.DistrictCode));
        }

        UIHelper.BindDropDownToTable(ddlTypeOfDefence, applicFacade.GetTypeOfDefenceList().Tables[0], "");

        UIHelper.BindDropDownToTable(ddlDefencePolicy, applicFacade.GetDefencePolicyList().Tables[0], "");

        ddlUnifiedClinic.Items.Add(new ListItem("לא", "0"));
        ddlUnifiedClinic.Items.Add(new ListItem("כן", "1"));

        ddlElectricalPanel.Items.Add(new ListItem("לא", "0"));
        ddlElectricalPanel.Items.Add(new ListItem("כן", "1"));

        ddlGenerator.Items.Add(new ListItem("לא", "0"));
        ddlGenerator.Items.Add(new ListItem("כן", "1"));

        DataSet dsReligions = applicFacade.getGeneralDataTable("DIC_Religions");
        DataView dvReligions = new DataView(dsReligions.Tables[0]);
        dvReligions.Sort = "ReligionDescription";

        ddlReligion.DataSource = dvReligions;
        ddlReligion.DataTextField = "ReligionDescription";
        ddlReligion.DataValueField = "ReligionCode";
        ddlReligion.DataBind();

    }

    public void BindAdministrationDdl(int districtCode)
    {
        ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();

        DataTable tbl = cacheHandler.getCachedDataTable(eCachedTables.View_AllAdministrations.ToString());
        if (tbl == null)
            return;

        DataView dv = new DataView(tbl, "districtCode =" + districtCode.ToString(), "AdministrationName", DataViewRowState.CurrentRows);

        ddlAdministration.DataSource = dv;
        ddlAdministration.DataBind();
    }

    public void BindSubUnitTypeDdl(int unitTypeCode)
    {
        ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();

        DataTable tbl = cacheHandler.getCachedDataTable(eCachedTables.View_SubUnitTypes.ToString());
        if (tbl == null)
            return;

        string selectCondition = string.Empty;

        if (clinicDetailsParameters.IsMushlam && !clinicDetailsParameters.IsCommunity && !clinicDetailsParameters.IsHospital)
            selectCondition = " AND IsMushlam = 1 ";
        else if (!clinicDetailsParameters.IsMushlam && clinicDetailsParameters.IsCommunity && !clinicDetailsParameters.IsHospital)
            selectCondition = " AND IsCommunity = 1 ";
        else if (!clinicDetailsParameters.IsMushlam && !clinicDetailsParameters.IsCommunity && clinicDetailsParameters.IsHospital)
            selectCondition = " AND IsHospitals = 1 ";

        DataView dv = new DataView(tbl, "UnitTypeCode =" + unitTypeCode.ToString() + selectCondition, "subUnitTypeCode", DataViewRowState.CurrentRows);

        ddlSubUnitType.Items.Clear();
        if (dv.Count > 0)
        {
            ddlSubUnitType.DataSource = dv;
            ListItem lstItm = new ListItem("בחר", "-1");
            ddlSubUnitType.Items.Add(lstItm);
            ddlSubUnitType.DataBind();
            ddlSubUnitType.Enabled = true;
        }
        else
        {
            ddlSubUnitType.Enabled = false;
        }

    }

    protected void ddlDistrict_SelectedIndexChanged(object sender, EventArgs e)
    {
        DataSet dsAdministration = applicFacade.getAdministrationList(Convert.ToInt32(ddlDistrict.SelectedValue));
        int districtCode = Convert.ToInt32(ddlDistrict.SelectedValue);

        if (currentUser.IsAdministrator)
            autoCompleteCities.ContextKey = "-1_" + clinicDetailsParameters.DeptCode;
        else
            autoCompleteCities.ContextKey = ddlDistrict.SelectedValue + "_" + clinicDetailsParameters.DeptCode;

        txtCityCode.Text = string.Empty;
        txtCityName.Text = string.Empty;
        txtStreet.Text = string.Empty;
        txtStreetCode.Text = string.Empty;
        txtHouse.Text = string.Empty;
        txtFloor.Text = string.Empty;
        txtFlat.Text = string.Empty;

        ddlAdministration.Items.Clear();
        ddlAdministration.Items.Add(new ListItem(" ", "-1"));
        ddlAdministration.SelectedValue = "-1";

        BindAdministrationDdl(Convert.ToInt32(ddlDistrict.SelectedValue));

        txtSubAdministrationName.Text = string.Empty;
        txtSubAdministrationCode.Text = string.Empty;

        txtParentClinicName.Text = string.Empty;
        txtParentClinicCode.Text = string.Empty;

        newDistrictName = ddlDistrict.SelectedItem.Text;
        Session["newDistrictName"] = newDistrictName;

        cbDeptNameToBeChangedManually.Checked = ClinicNameToBeUpdatedManually();
    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        string errorMessage = string.Empty;

        if (Page.IsValid)
        {
            bool result = updateClinicInDb();

            if (Session["dtDeptNames"] != null)
            {
                DataTable dtDeptNames = (DataTable)Session["dtDeptNames"];
                int deptLevel = (int)Session["deptLevel"];
                int? displayPriority = (int?)Session["displayPriority"];

                foreach (DataRow dr in dtDeptNames.Rows)
                {
                    dr["deptName"] = dr["deptName"].ToString().Replace("`", "'");
                    dr["deptNameFreePart"] = dr["deptNameFreePart"].ToString().Replace("`", "'");
                }

                bool resultNamem = applicFacade.UpdateDeptNames(CurrentDeptCode, deptLevel, displayPriority, dtDeptNames, currentUser.UserID, ref errorMessage);
            }

            if (result == true)
            {
                // set sessions for update names to null
                CleanAppropriateSessions();

                if (getCoordXYfromWServiceOK == true)
                {
                    if (sessionParams.CallerUrl != null && sessionParams.CallerUrl == "../Admin/NewClinicsList.aspx")
                        Response.Redirect(sessionParams.CallerUrl);
                    else
                        Response.Redirect(@"~/Public/ZoomClinic.aspx?DeptCode=" + CurrentDeptCode, true);
                }
                else
                {
                    errorMessage = "(אירעה תקלה בעדכון קואורדינאטות של היחידה (שאר הפרטים נשמרו בהצלחה" + @"\n\r";
                    errorMessage += ".נא לנסות לשמור את פרטי יחידה שוב במועד מאוחר יותר";
                    Session["ErrorMessage"] = errorMessage;
                    cbMakeRedirectAfterPostBack.Checked = true;
                    ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "MakePostBack", "MakePostBack();", true);
                }
            }
            else
            {
                // care to give an arror message
                lblGeneralError.Text = errorMessage;
            }
        }
    }

    private void CleanAppropriateSessions()
    {
        Session["dtDeptNames"] = null;
        Session["deptLevel"] = null;
        Session["displayPriority"] = null;
        Session["newClinicType"] = null;
        Session["newUnitTypeName"] = null;
        Session["previousClinicType"] = null;
        Session["previousClinicTypeName"] = null;
        Session["deptLevel"] = null;
        Session["deptNameFreePart"] = null;
        Session["previousCityName"] = null;
        Session["newCityName"] = null;
        Session["previousDistrictName"] = null;
        Session["newDistrictName"] = null;
        Session["NewStatusDescription"] = null;
    }
    protected void btnSendMailToChangeStatusToActive_Click(object sender, EventArgs e)
    {
        string MailTo = System.Configuration.ConfigurationManager.AppSettings["ReportClinicChangeToMail"].ToString();

        Dictionary<Enums.SearchMode, bool> agreementTypes = StringHelper.ConverAgreementNamesListToBoolArray("Hospitals");

        /* Get only units that there unitType is hospital */
        DataSet dsHospitals = applicFacade.getDistrictsByUnitType("60");

        int clinicDistrictCode = (ViewState["clinicDetailsParameters"] as ClinicDetailsParameters).DistrictCode;

        foreach (DataRow dr in dsHospitals.Tables[0].Rows)
        {
            if (clinicDistrictCode == Convert.ToInt32(dr["districtCode"]))
            {
                MailTo = System.Configuration.ConfigurationManager.AppSettings["ReportClinicOfHospitalTypeChangeToMail"].ToString();
            }
        }

        string UserName = currentUser.FirstName + ' ' + currentUser.LastName;
        string UserMail = currentUser.Mail;
        string DeptName = lblDeptName.Text;
        string DistrictName = ddlDistrict.Items[ddlDistrict.SelectedIndex].Text;
        string UnitTypeName = ddlUnitType.Items[ddlUnitType.SelectedIndex].Text;
        try
        {
            applicFacade.ApplyForChangeStatusToActive(CurrentDeptCode, GetAbsoluteUrl(CurrentDeptCode), MailTo, UserName, DeptName, DistrictName, UnitTypeName, UserMail);
            btnSendMailToChangeStatusToActive.Enabled = false;
        }
        catch
        {
        }
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
    private bool updateClinicNameAutomatically()
    {
        bool result = false;
        applicFacade = Facade.getFacadeObject();
        DataSet dsDeptNamesAndCo = applicFacade.GetDeptNamesForUpdate(CurrentDeptCode);
        DataTable dtDeptNames = dsDeptNamesAndCo.Tables["DeptNames"];

        DataSet dsDeptDetails = applicFacade.GetDeptDetailsForPopUp(CurrentDeptCode);

        string independentClinicDeptName = applicFacade.GetDefaultDeptNameForIndependentClinic(CurrentDeptCode);
        int clinicType = Convert.ToInt32(dsDeptDetails.Tables[0].Rows[0]["UnitTypeCode"]);
        string clinicTypeText = dsDeptDetails.Tables[0].Rows[0]["UnitTypeName"].ToString();
        string deptNameFreePart = dsDeptDetails.Tables[0].Rows[0]["deptNameFreePart"].ToString();
        string cityName = dsDeptDetails.Tables[0].Rows[0]["cityName"].ToString();

        if (clinicType == 101) //"מרפאה כפרית"
        {
            deptNameFreePart = string.Empty;
        }
        else if (clinicType == 112)
        {
            deptNameFreePart = independentClinicDeptName;
        }

        string deptName = deptNameFreePart;

        if (clinicTypeText != string.Empty)
        {
            if (deptName != string.Empty)
            {
                deptName = deptName + " - ";
            }

            deptName = deptName + clinicTypeText;
        }

        if (cityName != string.Empty)
        {
            if (deptName != string.Empty)
            {
                deptName = deptName + " - ";
            }

            deptName = deptName + cityName;
        }


        DateTime newFromDateS = DateTime.Now;

        if (dtDeptNames.Rows.Count > 0)
            dtDeptNames.Rows[dtDeptNames.Rows.Count - 1]["ToDate"] = newFromDateS.AddDays(-1);

        dtDeptNames.Rows.Add(CurrentDeptCode, deptNameFreePart, deptName, newFromDateS.ToString());

        dtDeptNames.AcceptChanges();

        string errorMessage = string.Empty;

        result = applicFacade.UpdateDeptNamesOnly(CurrentDeptCode, dtDeptNames, currentUser.UserID, ref errorMessage);

        if (result)
        {
            Session["ClinicNameWasChangedForClinicType"] = null;
        }

        return result;
    }

    private bool ClinicNameToBeUpdatedManually() //Or_DataToUpdateAutomaticallyBePrepared
    {
        bool UpdateManually = false;

        previousClinicType = Convert.ToInt32(Session["previousClinicType"]);
        newClinicType = Convert.ToInt32(Session["newClinicType"]);

        if (Session["deptNameFreePart"] != null)
        {
            deptNameFreePart = Session["deptNameFreePart"].ToString();
        }
        else
        {
            deptNameFreePart = string.Empty;
        }

        string newDeptName = deptNameFreePart;


        if (previousClinicType != newClinicType) // Dummy condition
        {
            if (newClinicType == 101) //"מרפאה כפרית"
            {
                deptNameFreePart = string.Empty;
            }
            else if (newClinicType == 112)
            {
                string independentClinicDeptName = applicFacade.GetDefaultDeptNameForIndependentClinic(CurrentDeptCode);
                deptNameFreePart = independentClinicDeptName;
            }

            if (newClinicType != 101 && deptNameFreePart == string.Empty) //"מרפאה כפרית"
            {
                UpdateManually = true;
                return UpdateManually;
            }

            newDeptName = deptNameFreePart;

            if (newDeptName != string.Empty)
            {
                newDeptName = newDeptName + " - ";
            }

            newDeptName = newDeptName + Session["newUnitTypeName"].ToString();
        }
        else
        {
            if (newDeptName != string.Empty)
            {
                newDeptName = newDeptName + " - ";
            }

            newDeptName = newDeptName + Session["previousClinicTypeName"].ToString();
        }

        if (clinicDetailsParameters.IsHospital)
        {
            if (newDeptName != string.Empty)
            {
                newDeptName = newDeptName + " - ";
            }

            //previousDistrictName = Session["previousDistrictName"].ToString();
            //newDeptName = newDeptName + previousDistrictName;

            newDistrictName = Session["newDistrictName"].ToString();
            newDeptName = newDeptName + newDistrictName;
        }
        else
        {
            if (newDeptName != string.Empty)
            {
                newDeptName = newDeptName + " - ";
            }

            newCityName = Session["newCityName"].ToString();
            newDeptName = newDeptName + newCityName;
        }

        if (UpdateManually == false) // Prepare data for Clinic name to be updated
        {
            DataTable dtDeptNames;

            // get dtDeptNames from Session (being changed right now) or from DB (was unchanged)
            if (Session["dtDeptNames"] != null)
            {
                dtDeptNames = (DataTable)Session["dtDeptNames"];
            }
            else
            {
                applicFacade = Facade.getFacadeObject();
                DataSet dsDeptNamesAndCo = applicFacade.GetDeptNamesForUpdate(CurrentDeptCode);
                dtDeptNames = dsDeptNamesAndCo.Tables["DeptNames"];
            }

            DateTime newFromDate = Convert.ToDateTime(DateTime.Now.Day.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Year.ToString());

            if (dtDeptNames.Rows.Count > 0)
            {
                DateTime lastFromDate = Convert.ToDateTime(dtDeptNames.Rows[dtDeptNames.Rows.Count - 1]["FromDate"]);
                lastFromDate = Convert.ToDateTime(lastFromDate.Day.ToString() + "/" + lastFromDate.Month.ToString() + "/" + lastFromDate.Year.ToString());

                if (newFromDate == lastFromDate)
                {
                    dtDeptNames.Rows[dtDeptNames.Rows.Count - 1]["deptNameFreePart"] = deptNameFreePart;
                    dtDeptNames.Rows[dtDeptNames.Rows.Count - 1]["deptName"] = newDeptName;
                }
                else
                {
                    dtDeptNames.Rows[dtDeptNames.Rows.Count - 1]["ToDate"] = newFromDate.AddDays(-1);
                    dtDeptNames.Rows.Add(CurrentDeptCode, deptNameFreePart, newDeptName, newFromDate.ToString());
                }
            }
            else
            {
                dtDeptNames.Rows.Add(CurrentDeptCode, deptNameFreePart, newDeptName, newFromDate.ToString());
            }

            Session["dtDeptNames"] = dtDeptNames;
        }

        lblDeptName.Text = newDeptName;
        lblDeptName.ForeColor = System.Drawing.Color.OrangeRed;

        return UpdateManually;
    }

    private bool ValidateForm()
    {
        bool validated = true;
        string validationMesage = string.Empty;

        return validated;
    }

    private void UpdateDeptNames()
    {
        DataTable dtDeptNames;
        int? displayPriority;
        int deptLevel;
        string errorMessage = string.Empty;
        int deptCode = Convert.ToInt32(lblDeptCode.Text);

        if (Session["dtDeptNames"] != null && Session["deptLevel"] != null)
        {
            dtDeptNames = (DataTable)Session["dtDeptNames"];
            deptLevel = (int)Session["deptLevel"];
            displayPriority = (int?)Session["displayPriority"];

            applicFacade = Facade.getFacadeObject();

            bool result = applicFacade.UpdateDeptNames(deptCode, deptLevel, displayPriority, dtDeptNames, currentUser.UserID, ref errorMessage);
        }
    }

    private bool updateClinicInDb()
    {
        applicFacade = Facade.getFacadeObject();

        bool result = true;



        int deptCode = Convert.ToInt32(lblDeptCode.Text);
        int unitType = Convert.ToInt32(ddlUnitType.SelectedValue);
        int deptType;
        switch (unitType)
        {
            case 65:
                deptType = 1; //district
                break;
            case 802:
                deptType = 2; // admin
                break;
            default:
                deptType = 3; // clinic
                break;
        }
        int subUnitType;
        if (ddlSubUnitType.Items.Count > 0)
            subUnitType = Convert.ToInt32(ddlSubUnitType.SelectedValue);
        else
            subUnitType = -1;

        string managerName;
        if (clinicDetailsParameters.SubstituteManagerName == string.Empty)
            managerName = txtManagerName.Text;
        else
            managerName = clinicDetailsParameters.ManagerName;

        string administrativeManagerName;
        if (clinicDetailsParameters.SubstituteAdministrativeManagerName == string.Empty)
            administrativeManagerName = txtAdministrativeManagerName.Text;
        else
            administrativeManagerName = clinicDetailsParameters.AdministrativeManagerName;

        int districtCode = Convert.ToInt32(ddlDistrict.SelectedValue);
        int administrationCode = Convert.ToInt32(ddlAdministration.SelectedValue);
        int subAdministrationCode;
        if (txtSubAdministrationCode.Text.Trim() == string.Empty)
            subAdministrationCode = -1;
        else
            subAdministrationCode = Convert.ToInt32(txtSubAdministrationCode.Text);

        int parentClinicCode;
        if (txtParentClinicCode.Text.Trim() == string.Empty)
            parentClinicCode = -1;
        else
            parentClinicCode = Convert.ToInt32(txtParentClinicCode.Text);

        int religionCode = Convert.ToInt32(ddlReligion.SelectedValue);

        //int deptLevel = Convert.ToInt32(ddlDeptLevel.SelectedValue);
        int parking = Convert.ToInt32(ddlParking.SelectedValue);
        int populationSectorCode = Convert.ToInt32(ddlPopulationSector.SelectedValue);
        int cityCode = Convert.ToInt32(txtCityCode.Text);
        string streetCode = txtStreetCode.Text;//!!!!!!!!!!!!!!clinicDetailsParameters.Street;
        string streetName = txtStreet.Text;
        int house;
        int.TryParse(txtHouse.Text, out house);

        string flat = txtFlat.Text;
        string floor = txtFloor.Text;
        string addressComment = txtAddressComment.Text;
        string building = txtBuilding.Text;
        string linkToBlank17 = txtLinkToBlank17.Text;
        string linkToContactUs = txtLinkToContactUs.Text;
        string transportation = txtTransport.Text;
        string email = txtEmail.Text;
        string neighbourhoodOrInstituteCode = txtNeighborhoodAndSiteCode.Text;
        int? isSite;
        if (txtIsSite.Text.Trim() == string.Empty)
            isSite = null;
        else
            isSite = Convert.ToInt32(txtIsSite.Text);

        int showEmailInInternet = Convert.ToInt32(cbShowEmailInInternet.Checked);
        int showUnitInInternet = Convert.ToInt32(cbShowUnitInInternet.Checked);
        int isCommunity = Convert.ToInt32(cbIsCommunity.Checked);
        int isMushlam = Convert.ToInt32(cbIsMushlam.Checked);
        int isHospital = Convert.ToInt32(cbIsHospital.Checked);

        int allowContactHospitalUnit = Convert.ToInt32(cbAllowContactHospitalUnit.Checked);

        int cascadeUpdateSubDeptPhones = Convert.ToInt32(cbCascadeUpdateSubClinicPhones.Checked);
        int cascadeUpdateEmployeeInClinicPhones = Convert.ToInt32(cbCascadeUpdateDoctorInClinicPhones.Checked);
        int cascadeUpdateServicesInClinicPhones = Convert.ToInt32(cbCascadeUpdateServicesInClinicPhones.Checked);

        string deptHandicappedFacilities = getCheckboxListSelectedValues(cbHandicappedFacilities);

        int? typeOfDefenceCode = null;
        if (ddlTypeOfDefence.SelectedValue != "-1")
            typeOfDefenceCode = Convert.ToInt16(ddlTypeOfDefence.SelectedValue);

        int? defencePolicyCode = null;
        if (ddlDefencePolicy.SelectedValue != "-1")
            defencePolicyCode = Convert.ToInt16(ddlDefencePolicy.SelectedValue);

        bool? isUnifiedClinic = null;
        if (ddlUnifiedClinic.SelectedValue != "-1")
            isUnifiedClinic = Convert.ToBoolean(Convert.ToInt16(ddlUnifiedClinic.SelectedValue));

        bool? hasElectricalPanel = null;
        if (ddlElectricalPanel.SelectedValue != "-1")
            hasElectricalPanel = Convert.ToBoolean(Convert.ToInt16(ddlElectricalPanel.SelectedValue));

        bool? hasGenerator = null;
        if (ddlGenerator.SelectedValue != "-1")
            hasGenerator = Convert.ToBoolean(Convert.ToInt16(ddlGenerator.SelectedValue));

        Int64? DeptShalaCode = null;
        if (txtlDeptShalaCode.Text != string.Empty)
            DeptShalaCode = Convert.ToInt64(txtlDeptShalaCode.Text);


        //phones & address changed
        dtDeptPhones = (DataTable)ViewState["dtDeptPhones"];
        dtDeptFaxes = (DataTable)ViewState["dtDeptFaxes"];
        dtDeptDirectPhones = (DataTable)ViewState["dtDeptDirectPhones"];
        dtDeptWhatsApp = (DataTable)ViewState["dtDeptWhatsApp"];

        if (!TablesAreTheSame(dtDeptPhones, ClinicPhonesUC.ReturnData()) ||
            !TablesAreTheSame(dtDeptFaxes, ClinicFaxesUC.ReturnData()) ||
            !TablesAreTheSame(dtDeptDirectPhones, ClinicDirectPhonesUC.ReturnData()))
        {
            phonesHasChanged = true;
        }
        else
        {
            phonesHasChanged = false;
        }

        if (clinicDetailsParameters.CityCode != cityCode
            ||
            (clinicDetailsParameters.Street != null && streetCode != null && clinicDetailsParameters.Street != streetCode) ||
            (clinicDetailsParameters.Street != null && streetCode == null) ||
            (clinicDetailsParameters.Street == null && streetCode != null)
            ||
            (clinicDetailsParameters.House != null && house != null && clinicDetailsParameters.House != house.ToString()) ||
            (clinicDetailsParameters.House != null && house == null) ||
            (clinicDetailsParameters.House == null && house != null)
            ||
            (clinicDetailsParameters.Flat != null && flat != null && clinicDetailsParameters.Flat != flat) ||
            (clinicDetailsParameters.Flat != null && flat == null) ||
            (clinicDetailsParameters.Flat == null && flat != null)
            ||
            (clinicDetailsParameters.Floor != null && floor != null && clinicDetailsParameters.Floor != floor) ||
            (clinicDetailsParameters.Floor != null && floor == null) ||
            (clinicDetailsParameters.Floor == null && floor != null)
            ||
            (clinicDetailsParameters.AddressComment != null && addressComment != null && clinicDetailsParameters.AddressComment != addressComment) ||
            (clinicDetailsParameters.AddressComment != null && addressComment == null) ||
            (clinicDetailsParameters.AddressComment == null && addressComment != null)
            ||
            (clinicDetailsParameters.Building != null && building != null && clinicDetailsParameters.Building != building) ||
            (clinicDetailsParameters.Building != null && building == null) ||
            (clinicDetailsParameters.Building == null && building != null)
            )
        {
            addressHasChanged = true;
        }
        else
        {
            addressHasChanged = false;
        }


        dtDeptPhones = ClinicPhonesUC.ReturnData();
        dtDeptFaxes = ClinicFaxesUC.ReturnData();
        dtDeptDirectPhones = ClinicDirectPhonesUC.ReturnData();
        dtDeptWhatsApp = ClinicWhatsAppUC.ReturnData();
        bool allowQueueOrder = clinicDetailsParameters.AllowQueueOrder;
        string updateUser = Master.getUserName();
        UserManager mng = new UserManager();
        long updateUserID = mng.GetUserIDFromSession();
        string additionalDistricts = txtDistrictCodes.Text;

        bool updateCoordinatesManually = cbManualCoordinates.Checked;

        ConverterManager converterManager = new ConverterManager();

        // 29.07.2012 , Vadim Rasin - Calculate the new map coordinates only if the address has been changed.
        if ((clinicDetailsParameters.CityCode != cityCode ||
            clinicDetailsParameters.Street != streetCode ||
            clinicDetailsParameters.House != house.ToString() ||
            clinicDetailsParameters.NeighbourhoodOrInstituteCode != neighbourhoodOrInstituteCode ||
            (clinicDetailsParameters.Xcoord != null && clinicDetailsParameters.Xcoord == 0)
            )
            && updateCoordinatesManually == false
            )
        {
            try
            {
                MapCoordinatesClient cli = new MapCoordinatesClient(MapHelper.GetMapApplicationEnvironmentController());
                cli.XYSearchAccuracyState = MapCoordinatesClient.XYSearchAccuracyMode.FindClosest;
                CoordInfo coordInfo;

                if (isSite == null)
                    coordInfo = cli.GetXY(cityCode, streetName, house, string.Empty, string.Empty);
                else if (isSite == 1)
                    coordInfo = cli.GetXY(cityCode, streetName, house, string.Empty, neighbourhoodOrInstituteCode);
                else
                    coordInfo = cli.GetXY(cityCode, streetName, house, neighbourhoodOrInstituteCode, string.Empty);

                if (coordInfo != null && coordInfo.X > 0)
                {
                    coordinateX = coordInfo.X;
                    coordinateY = coordInfo.Y;
                    XLongitude = coordInfo.XLongitude;
                    YLatitude = coordInfo.YLatitude;
                    getCoordXYfromWServiceOK = true;
                    needToUpdateCoordinates = true;
                }
                else
                {
                    getCoordXYfromWServiceOK = false;
                    needToUpdateCoordinates = false;
                }
            }
            catch (Exception ex)
            {
                getCoordXYfromWServiceOK = false;
                needToUpdateCoordinates = false;

                if (clinicDetailsParameters.Xcoord != null)
                {
                    coordinateX = clinicDetailsParameters.Xcoord;
                    coordinateY = clinicDetailsParameters.Ycoord;
                    XLongitude = clinicDetailsParameters.XLongitude;
                    YLatitude = clinicDetailsParameters.YLatitude;
                }
                else
                {
                    coordinateX = 0;
                    coordinateY = 0;
                    XLongitude = 0;
                    YLatitude = 0;
                }

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetCoordFromMapServer),
                  new WebPageExtraInfoGenerator());
            }
        }
        else
        {
            getCoordXYfromWServiceOK = true;
            needToUpdateCoordinates = false;
        }

        // If the user has changed the coordinates manually - save them in the database
        if (this.txtCoordinateX.Text != clinicDetailsParameters.Xcoord.ToString() ||
            this.txtCoordinateY.Text != clinicDetailsParameters.Ycoord.ToString())
        {
            double _coordinateX;
            double _coordinateY;

            if (double.TryParse(this.txtCoordinateX.Text, out _coordinateX) &&
                double.TryParse(this.txtCoordinateY.Text, out _coordinateY))
            {
                coordinateX = _coordinateX;
                coordinateY = _coordinateY;
                if (_coordinateX == Math.Round(_coordinateX, 0))
                    _coordinateX += 0.000000000001;
                if (_coordinateY == Math.Round(_coordinateY, 0))
                    _coordinateY += 0.000000000001;

                var ConvertResult = ConverterManager.ConvertClalitCoordinates(_coordinateX, _coordinateY);
                if (ConvertResult.Key.HasValue && ConvertResult.Value.HasValue)
                {
                    XLongitude = ConvertResult.Key.Value;
                    YLatitude = ConvertResult.Value.Value;
                }

            }
            else
            {
                // The system failed to parse the new values for the coordinate - dont update the coordinates manually.
                coordinateX = clinicDetailsParameters.Xcoord;
                coordinateY = clinicDetailsParameters.Ycoord;
                XLongitude = clinicDetailsParameters.XLongitude;
                YLatitude = clinicDetailsParameters.YLatitude;
            }

            getCoordXYfromWServiceOK = true;
            needToUpdateCoordinates = true;
        }
        else
        {
            if (coordinateX == 0 && clinicDetailsParameters.Xcoord != 0)
            {
                coordinateX = clinicDetailsParameters.Xcoord;
                coordinateY = clinicDetailsParameters.Ycoord;
                XLongitude = clinicDetailsParameters.XLongitude;
                YLatitude = clinicDetailsParameters.YLatitude;
                needToUpdateCoordinates = false;
            }
        }

        string SPSlocationLink = null;

        object[] inputParamsDept = new object[] {
            deptCode,
            deptType,
            unitType,
            subUnitType,
            managerName,
            administrativeManagerName,
            districtCode,
            administrationCode,
            subAdministrationCode,
            parentClinicCode,
            parking,
            populationSectorCode,
            cityCode,
            streetCode,
            streetName,
            house,
            flat,
            floor,
            addressComment,
            building,
            linkToBlank17,
            linkToContactUs,
            transportation,
            email,
            showEmailInInternet,
            showUnitInInternet,
            allowQueueOrder,
            cascadeUpdateSubDeptPhones,
            cascadeUpdateEmployeeInClinicPhones,
            updateUser,
            neighbourhoodOrInstituteCode,
            isSite,
            additionalDistricts,
            isCommunity,
            isMushlam,
            isHospital,
            typeOfDefenceCode,
            defencePolicyCode,
            isUnifiedClinic,
            hasElectricalPanel,
            hasGenerator,
            DeptShalaCode,
            religionCode,
            allowContactHospitalUnit
        };

        if (Convert.ToInt32(inputParamsDept[3]) == -1) //subUnitType,
            inputParamsDept[3] = null;
        if (Convert.ToInt32(inputParamsDept[6]) == -1) //districtCode
            inputParamsDept[6] = null;
        if (Convert.ToInt32(inputParamsDept[7]) == -1) //administrationCode
            inputParamsDept[7] = null;
        if (Convert.ToInt32(inputParamsDept[8]) == -1) //subAdministrationCode
            inputParamsDept[8] = null;
        if (Convert.ToInt32(inputParamsDept[9]) == -1) //subAdministrationCode
            inputParamsDept[9] = null;
        if (Convert.ToInt32(inputParamsDept[15]) == 0) //house
            inputParamsDept[15] = null;

        try
        {
            result = applicFacade.UpdateDeptDetailsTransaction(
                deptCode, updateUser, updateUserID, inputParamsDept, deptHandicappedFacilities,
                dtDeptPhones, dtDeptFaxes, dtDeptDirectPhones, dtDeptWhatsApp, coordinateX, coordinateY, XLongitude, YLatitude, getCoordXYfromWServiceOK, needToUpdateCoordinates, updateCoordinatesManually, SPSlocationLink,
                phonesHasChanged, addressHasChanged);
        }
        catch (Exception ex)
        {
            result = false;
            lblGeneralError.Text = "לא ניתן לבצע עידכון" + "    " + ex.Message;
        }

        return result;
    }

    public bool TablesAreTheSame(DataTable tbl1, DataTable tbl2)
    {
        if (tbl1.Rows.Count != tbl2.Rows.Count || tbl1.Columns.Count != tbl2.Columns.Count)
            return false;


        for (int i = 0; i < tbl1.Rows.Count; i++)
        {
            for (int c = 0; c < tbl1.Columns.Count; c++)
            {
                if (!Equals(tbl1.Rows[i][c], tbl2.Rows[i][c]))
                    return false;
            }
        }
        return true;
    }

    private void SetUserControls()
    {
        //ClinicPhonesUC.LabelTitle.Text = ":טלפון";

        ClinicFaxesUC.LabelTitle.Text = "&nbsp;&nbsp;:פקס";

        ClinicDirectPhonesUC.LabelTitle.Text = ":טלפון ישיר";

        ClinicPhonesUC.UseRemarks = true;
        ClinicFaxesUC.UseRemarks = true;
        ClinicDirectPhonesUC.UseRemarks = true;
        ClinicWhatsAppUC.UseRemarks = true;

        ClinicPhonesUC.LabelTitleVisibility = false;
        ClinicFaxesUC.LabelTitleVisibility = false;
        ClinicDirectPhonesUC.LabelTitleVisibility = false;
        ClinicWhatsAppUC.LabelTitleVisibility = false;
    }

    protected void btnBackToOpener_Click(object sender, EventArgs e)
    {
        CleanAppropriateSessions();

        if (sessionParams.CallerUrl != null && sessionParams.CallerUrl == "../Admin/NewClinicsList.aspx")
            Response.Redirect(sessionParams.CallerUrl);
        else
            Response.Redirect(@"~/Public/ZoomClinic.aspx?DeptCode=" + CurrentDeptCode, true);
    }

    protected void odsGvClinicPhones_Selecting(object sender, ObjectDataSourceSelectingEventArgs e)
    {
        e.InputParameters["deptCode"] = Convert.ToInt32(ViewState["currentDeptCode"]);
        e.InputParameters["phoneType"] = -1;
    }

    private string getCheckboxListSelectedValues(CheckBoxList cbList)
    {
        string[] itemsArr = new string[cbList.Items.Count];
        bool flag = false;
        for (int i = 0; i < cbList.Items.Count; i++)
        {
            if (cbList.Items[i].Selected)
            {
                itemsArr[i] = cbList.Items[i].Value;
                flag = true;
            }
            else
            {
                itemsArr[i] = "empty";
            }

        }
        if (flag == false)
            return string.Empty;
        string selectedItems = String.Join(",", itemsArr);
        selectedItems = selectedItems.Replace("empty,", "");
        selectedItems = selectedItems.Replace(",empty", "");
        return selectedItems;
    }

    protected void gvDeptStatus_DataBound(object sender, EventArgs e)
    {
        GridView gv = (GridView)sender as GridView;
        for (int i = 0; i < gv.Rows.Count; i++)
        {
            if (gv.Rows[i].RowType == DataControlRowType.DataRow)
            {
                DataRowView rowView = gv.Rows[i].DataItem as DataRowView;
            }
        }
    }

    protected void cbHandicappedFacilities_DataBound(object sender, EventArgs e)
    {
        CheckBoxList cbList = (CheckBoxList)sender as CheckBoxList;
        DataTable tbl = cbList.DataSource as DataTable;
        for (int i = 0; i < cbList.Items.Count; i++)
        {
            if (Convert.ToBoolean(tbl.Rows[i]["CinicHasFacility"]) == true)
                cbList.Items[i].Selected = true;
        }

    }

    protected void ddlUnitType_SelectedIndexChanged(object sender, EventArgs e)
    {
        // "save" DeptType
        DataSet ds = applicFacade.GetUnitTypeWithAttributes(Convert.ToInt32(ddlUnitType.SelectedValue));

        BindSubUnitTypeDdl(Convert.ToInt32(ddlUnitType.SelectedValue));

        clinicDetailsParameters.TypeUnitCode = Convert.ToInt32(ddlUnitType.SelectedValue);
        clinicDetailsParameters.AllowQueueOrder = Convert.ToBoolean(ds.Tables[0].Rows[0]["AllowQueueOrder"]);
        clinicDetailsParameters.ShowUnitInInternet = Convert.ToBoolean(ds.Tables[0].Rows[0]["ShowInInternet"]);

        ViewState["clinicDetailsParameters"] = clinicDetailsParameters;

        SetQueueOrderVisibility();

        previousClinicType = newClinicType;
        Session["previousClinicType"] = previousClinicType;
        Session["previousClinicTypeName"] = Session["newUnitTypeName"];

        newClinicType = clinicDetailsParameters.TypeUnitCode;

        Session["newClinicType"] = newClinicType;
        Session["newUnitTypeName"] = ddlUnitType.SelectedItem.Text;

        cbDeptNameToBeChangedManually.Checked = ClinicNameToBeUpdatedManually();
    }

    protected void btnUpdateRemarks_Click(object sender, EventArgs e)
    {
        if (cbSaveDataBeforeLeave.Checked)
        {
            cbSaveDataBeforeLeave.Checked = false;

            if (ValidateForm())
            {
                updateClinicInDb();
                sessionParams.CallerUrl = "../Admin/UpdateClinicDetails.aspx";

                Response.Redirect("../Admin/UpdateRemarks.aspx");
            }
        }
        else
        {
            cbSaveDataBeforeLeave.Checked = false;
            sessionParams.CallerUrl = "../Admin/UpdateClinicDetails.aspx";

            Response.Redirect("../Admin/UpdateRemarks.aspx");
        }
    }

    protected void btnAddRemarks_Click(object sender, EventArgs e)
    {
        if (cbSaveDataBeforeLeave.Checked)
        {
            cbSaveDataBeforeLeave.Checked = false;

            if (ValidateForm())
            {
                updateClinicInDb();
                sessionParams.CallerUrl = "../Admin/UpdateClinicDetails.aspx";
                Response.Redirect("../Admin/AddRemark.aspx?deptCode=" + CurrentDeptCode);
            }
        }
        else
        {
            cbSaveDataBeforeLeave.Checked = false;
            sessionParams.CallerUrl = "../Admin/UpdateClinicDetails.aspx";

            Response.Redirect("../Admin/AddRemark.aspx?deptCode=" + CurrentDeptCode);
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
                imgInternet.Style.Add("display", "none");
            }

            if (Convert.ToInt32(dvRowView["deptCode"]) == -1) // sweepingRemark
            {
                Label lblRemark = e.Row.FindControl("lblRemark") as Label;
                lblRemark.Style.Add("color", "#628e02");
                e.Row.Style.Add("color", "#628e02");
            }
        }
    }

}


