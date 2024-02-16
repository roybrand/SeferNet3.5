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
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using System.Text;
using SeferNet.Globals;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using SeferNet.UI;
using System.Collections.Generic;
using System.Linq;
/// <summary>
/// zoom clinic displays about 5 sections on the page.
/// Each section gets its data from a differnet datatable.
/// All datatables are part of one dataset.
/// The dataset is filled by one sp (rpc_deptOverView) with about 5 select statements
/// </summary>
public partial class ZoomClinic : System.Web.UI.Page
{
    DataSet m_dsClinic; //m_dsClinic is main DataSet on the page containing all the relevant dataTables
    Facade applicFacade = Facade.getFacadeObject();
    UserInfo currentUser;
    SessionParams sessionParams;    
    int m_DeptCode;
    bool m_isDeptPermittedForUser;
    string deptName = "";
    bool isCommunity;
    bool isMushlam;
    bool isHospital;
    int subUnitTypeCode = -1;
    private Dictionary<string, string> dicTabs = new Dictionary<string, string>() 
    {
        { "tb_clinicDetails", "divClinicDetailsBut,trDeptDetails,tdClinicDetailsTab" },
        { "tb_clinicReception", "divClinicHoursBut,trDeptReception,tdClinicHoursTab" },
        { "tb_clinicServices", "divDoctorsEmployeesBut,trDoctors,tdDoctorsEmployeesTab" },
        { "tb_services", "divDoctorsEmployeesBut,trDoctors,tdDoctorsEmployeesTab" },
        { "tb_clinicMedicalAspects", "divMedicalAspectsBut,trMedicalAspects,tdMedicalAspectsTab" },
        { "tb_clinicMushlamServices", "divMushlamServicesBut,trMushlamServices,tdMushlamServicesTab" }
    };
    private DateTime m_closestReceptionChange = DateTime.MaxValue;
    Int64 remarkEmployeeID = 0;
    string RemarkCategoriesForAbsence = System.Configuration.ConfigurationManager.AppSettings["RemarkCategoriesForAbsence"].ToString();
    string RemarkCategoriesForClinicActivity = System.Configuration.ConfigurationManager.AppSettings["RemarkCategoriesForClinicActivity"].ToString();

    public int CurrentMushlamServiceCode { get; set; }


    public int DeptCode
    {
        get
        {
            return m_DeptCode;
        }
    }    
    private string CurrentSort
    {
        get
        {
            if (ViewState["currentSort"] != null)
                return ViewState["currentSort"].ToString();
            return "ActiveForSort";
        }
        set
        {
            ViewState["currentSort"] = value;
        }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        ClientScript.RegisterStartupScript(typeof(string), "SetTabToBeShownOnLoad", "SetTabToBeShownOnLoad();", true);
        
        sessionParams = SessionParamsHandler.GetSessionParams();
        currentUser = Session["currentUser"] as UserInfo;

        if (!IsPostBack)
        {
            GetQueryString();

            m_isDeptPermittedForUser = applicFacade.IsDeptPermitted(m_DeptCode);

            sessionParams.DeptCode = m_DeptCode;
            Context.Items["currDeptCode"] = m_DeptCode;
            sessionParams.CallerUrl = Request.Url.OriginalString;
            sessionParams.CurrentEntityToReport = Enums.IncorrectDataReportEntity.Dept;

            SessionParamsHandler.SetSessionParams(sessionParams);

            if (sessionParams.MarkEmployeeInClinicSelected || sessionParams.MarkServiceInClinicSelected || Request.QueryString["seltab"] != null) 
            {
                if (Request.QueryString["seltab"] != null)
                {
                    try
                    {
                        txtTabToBeShown.Text = dicTabs[Request.QueryString["seltab"].ToString()];
                    }
                    catch
                    { 
                     txtTabToBeShown.Text = sessionParams.CurrentTab_ZoomClinic;                   
                    }
                }
                else
                {
                    txtTabToBeShown.Text = sessionParams.CurrentTab_ZoomClinic;
                }
            }

            BindPageData();
        }
        else   
        {      
            sessionParams.CurrentTab_ZoomClinic = txtTabToBeShown.Text;
            m_DeptCode = sessionParams.DeptCode;

            if (m_DeptCode == 0)
            {
                Response.Redirect(PagesConsts.SEARCH_CLINICS_URL);
                Response.End();
            }
        }

        if (Master.IsPostBackAfterLoginLogout)
            m_isDeptPermittedForUser = applicFacade.IsDeptPermitted(m_DeptCode);

    }

    private void GetQueryString()
    {
        if (!Int32.TryParse(Request.QueryString["deptCode"], out m_DeptCode))
        {
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["index"]))
        {
            Int32.TryParse(Request.QueryString["index"], out sessionParams.LastRowIndexOnSearchPage);
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        toggleUpdateButtons();//display update buttons by permissions

        if ((Session[ConstsSession.CLINIC_IS_HOSPITAL] != null && (bool)Session[ConstsSession.CLINIC_IS_HOSPITAL])
              &&
           (((Session[ConstsSession.CLINIC_HAS_MEDICAL_ASPECTS] != null && (bool)Session[ConstsSession.CLINIC_HAS_MEDICAL_ASPECTS])) || currentUser != null))
        {
            tdMedicalAspectsTab.Style["display"] = "inline";
        }
        else
        {
            tdMedicalAspectsTab.Style["display"] = "none";
            if(txtTabToBeShown.Text.IndexOf("MedicalAspects") >= 0)
                txtTabToBeShown.Text = string.Empty;
        }
    }

    public void BindPageData()
    {
        BindDeptDetails();
        BindGeneralRemarks();
        BindEmployeeAndServiceRemarks();
        BindHandicapped();

        BindUpdateLables();
        bindSubClinics();
        bindServices();
    }

    private void bindSubClinics()
    {
        frmSubClinics.Attributes["src"] = "DeptSubClinics.aspx?deptCode=" + m_DeptCode
            + "&isCommunity=" + isCommunity
            + "&isMushlam=" + isMushlam + "&isHospital=" + isHospital
            + "&subUnitTypeCode=" + subUnitTypeCode;
    }
    private void bindServices()
    {
        string qScrollTop = "";
        if (Request.QueryString["scrtop"] != null)
            qScrollTop = "&scrtop=" + Request.QueryString["scrtop"].ToString();

        frmDeptServices.Attributes["src"] = "DeptServices.aspx?deptCode=" + m_DeptCode
            + "&isCommunity=" + isCommunity
            + "&isMushlam=" + isMushlam + "&isHospital=" + isHospital
            + "&subUnitTypeCode=" + subUnitTypeCode + qScrollTop;
    }


    

    public void BindDeptDetails()
    {
        this.m_dsClinic = applicFacade.getClinicDetails(m_DeptCode, RemarkCategoriesForAbsence, RemarkCategoriesForClinicActivity);
        this.dvClinicDetails.DataSource = m_dsClinic.Tables["deptDetails"];
        DataRow currentRow = m_dsClinic.Tables["deptDetails"].Rows[0];

        this.ViewState["DeptCode"] = m_DeptCode;
        this.ViewState["DeptName"] = m_dsClinic.Tables["deptDetails"].Rows[0]["deptName"].ToString();
        this.Master.setDeptNameInSession();
        SessionParamsHandler.SetDeptNameInSession(ViewState["DeptName"].ToString());
        this.dvClinicDetails.DataBind();

        this.isCommunity = (bool)currentRow["IsCommunity"];
        this.isMushlam = (bool)currentRow["IsMushlam"];
        this.isHospital = (bool)currentRow["isHospital"];
        this.Session[ConstsSession.CLINIC_IS_HOSPITAL] = isHospital;

        if(currentRow["subUnitTypeCode"] != null && currentRow["subUnitTypeCode"].ToString() != string.Empty )
            subUnitTypeCode = (int)currentRow["subUnitTypeCode"];

        Label lblAdministrativeManagerNameCaption = this.dvClinicDetails.FindControl("lblAdministrativeManagerNameCaption") as Label;
        Label lblAdministrativeManagerName = this.dvClinicDetails.FindControl("lblAdministrativeManagerName") as Label;

        Label lblDeputyHeadOfDepartmentCaption = this.dvClinicDetails.FindControl("lblDeputyHeadOfDepartmentCaption") as Label;
        Label lblDeputyHeadOfDepartment = this.dvClinicDetails.FindControl("lblDeputyHeadOfDepartment") as Label;

        Label lblSecretaryNameCaption = this.dvClinicDetails.FindControl("lblSecretaryNameCaption") as Label;
        Label lblSecretaryName = this.dvClinicDetails.FindControl("lblSecretaryName") as Label;

        if (this.isHospital)
        {
            lblAdministrativeManagerNameCaption.Style.Add("display", "none");
            lblAdministrativeManagerName.Style.Add("display", "none");
        }
        else
        {
            lblDeputyHeadOfDepartmentCaption.Style.Add("display", "none");
            lblDeputyHeadOfDepartment.Style.Add("display", "none");
            lblSecretaryNameCaption.Style.Add("display", "none");
            lblSecretaryName.Style.Add("display", "none");
        }

        if (currentRow["managerName"] == null || currentRow["managerName"].ToString() == string.Empty)
        {
            Label lblmanagerNameCaption = this.dvClinicDetails.FindControl("lblmanagerNameCaption") as Label;
            lblmanagerNameCaption.Style.Add("display", "none");
        }

        if (currentRow["administrativeManagerName"] == null || currentRow["administrativeManagerName"].ToString() == string.Empty)
        {
            lblAdministrativeManagerNameCaption.Style.Add("display", "none");
        }

        Label lblGeriatricsManagerCaption = this.dvClinicDetails.FindControl("lblGeriatricsManagerCaption") as Label;
        if (currentRow["GeriatricsManagerName"] == null || currentRow["GeriatricsManagerName"].ToString() == string.Empty)
        {
            lblGeriatricsManagerCaption.Style.Add("display", "none");
        }

        Label lblPharmacologyManagerCaption = this.dvClinicDetails.FindControl("lblPharmacologyManagerCaption") as Label;
        if (currentRow["pharmacologyManagerName"] == null || currentRow["pharmacologyManagerName"].ToString() == string.Empty)
        {
            lblPharmacologyManagerCaption.Style.Add("display", "none");
        }

        if (currentRow["deputyHeadOfDepartment"] == null || currentRow["deputyHeadOfDepartment"].ToString() == string.Empty)
        {
            lblDeputyHeadOfDepartmentCaption.Style.Add("display", "none");
        }

        if (currentRow["secretaryName"] == null || currentRow["secretaryName"].ToString() == string.Empty)
        {
            lblSecretaryNameCaption.Style.Add("display", "none");
        }

        if (currentRow["typeUnitCode"] != null && currentRow["typeUnitCode"].ToString() != string.Empty)
        {
            if ((int)currentRow["typeUnitCode"] == 65 || (int)currentRow["typeUnitCode"] == 60)
                sessionParams.isDistrictOrHospital = true;
            else
                sessionParams.isDistrictOrHospital = false;
        }
        else
            sessionParams.isDistrictOrHospital = false;

        CheckBox cbAllowContactHospitalUnit = this.dvClinicDetails.FindControl("cbAllowContactHospitalUnit") as CheckBox;
        cbAllowContactHospitalUnit.Checked = Convert.ToBoolean(currentRow["AllowContactHospitalUnit"]);

        // dicide whether to display mushlam tab
        if (m_dsClinic.Tables["MushlamServices"].Rows.Count > 0)
        {
            frmMushlamServices.Attributes["src"] = "MushlamServices.aspx?deptCode=" + DeptCode + "&isCommunity=" + isCommunity +
                                                    "&isMushlam=" + isMushlam + "&isHospital=" + isHospital + "&subUnitTypeCode=" + subUnitTypeCode +
                                                    "&deptName=" + currentRow["deptName"].ToString().Replace("\"", "''");
            tdMushlamServicesTab.Style["display"] = "inline";
        }

        // dicide whether to display tdMedicalAspectsTab 
        this.Session[ConstsSession.CLINIC_HAS_MEDICAL_ASPECTS] = Convert.ToBoolean(currentRow["HasMedicalAspects"]);

        this.frmMedicalAspects.Attributes["src"] = "MedicalAspects.aspx?deptCode=" + DeptCode + "&isCommunity=" + isCommunity +
                                                "&isMushlam=" + isMushlam + "&isHospital=" + isHospital + "&subUnitTypeCode=" + subUnitTypeCode +
                                                "&deptName=" + currentRow["deptName"].ToString().Replace("\"", "''");
    
        UIHelper.SetImageForDeptAttribution(ref imgAttributed_1, isCommunity, isMushlam, isHospital, subUnitTypeCode);
        UIHelper.SetImageForDeptAttribution(ref imgAttributed_2, isCommunity, isMushlam, isHospital, subUnitTypeCode);

        if(Convert.ToInt16(currentRow["showUnitInInternet"]) == 1)
            imgNotShowClinicInInternet.Style.Add("display", "none");
    }

    public void BindGeneralRemarks()
    {
        GridView gvRemarks = dvClinicDetails.FindControl("gvRemarks") as GridView;
        gvRemarks.DataSource = m_dsClinic.Tables["generalRemarks"];
        gvRemarks.DataBind();
    }
    public void BindEmployeeAndServiceRemarks()
    {
        GridView gvEmployeeAndServiceRemarks = dvClinicDetails.FindControl("gvEmployeeAndServiceRemarks") as GridView;
        gvEmployeeAndServiceRemarks.DataSource = m_dsClinic.Tables["EmployeeAndServiceRemarks"];
        gvEmployeeAndServiceRemarks.DataBind();
    }


    public bool BindHandicapped()
    {
        Label lblHandicapped = dvClinicDetails.FindControl("lblHandicapped") as Label;
        HtmlTableCell tdHandicappedCaption = dvClinicDetails.FindControl("tdHandicappedCaption") as HtmlTableCell;        

        if (this.m_dsClinic.Tables["HandicappedFacilities"].Rows.Count == 0)
        {
            tdHandicappedCaption.InnerText = "";
            tdHandicappedCaption.Style.Add("color", "black");
            tdHandicappedCaption.Style.Add("text-decoration", "none");
            tdHandicappedCaption.Style.Add("cursor", "auto");

            lblHandicapped.Text = "אין";
        }
        else
        {
            GridView gvHandicapped = this.dvClinicDetails.FindControl("gvHandicapped") as GridView;

            gvHandicapped.DataSource = this.m_dsClinic.Tables["HandicappedFacilities"];
            gvHandicapped.DataBind();
            gvHandicapped.HeaderStyle.CssClass = "DisplayNone";

            foreach (GridViewRow row in gvHandicapped.Rows)
            {
                row.Cells[0].Text = row.Cells[0].Text.Replace("\r\n", "<br>");
            }

            tdHandicappedCaption.InnerText = "פרוט";
            lblHandicapped.Text = "יש";
        }
       
        return true;
    }

    public void BindUpdateLables()
    {
        DataRow row = m_dsClinic.Tables[0].Rows[0];

        deptName = lblDeptName.Text = row["deptName"].ToString();
        lblDeptName_Reception.Text = row["deptName"].ToString();

        if (m_dsClinic.Tables["deptLastUpdateDates"] == null || m_dsClinic.Tables["deptLastUpdateDates"].Rows.Count == 0)
        {
            return;
        }

        lblUpdateDateFld.Text = Convert.ToDateTime(m_dsClinic.Tables["deptLastUpdateDates"].Rows[0]["LastUpdateDateOfDept"]).ToString("dd/MM/yyyy");

        if (m_dsClinic.Tables["deptLastUpdateDates"].Rows[0]["deptReceptionUpdateDate"] != DBNull.Value)
            lblUpdateDateFld_Reception.Text = 
                        (Convert.ToDateTime(m_dsClinic.Tables["deptLastUpdateDates"].Rows[0]["deptReceptionUpdateDate"])).ToString("dd/MM/yyyy");
    }

    protected void dvClinicDetails_DataBound(object sender, EventArgs e)
    {
        DetailsView dv = sender as DetailsView;
        DataRowView row = dv.DataItem as DataRowView;
        bindPhonesAndFaxes(dv);
        bindDeptQueueOrder(dv);
    }

    protected void dvClinicDetails_DataBinding(object sender, EventArgs e)
    {
        DataRow row = m_dsClinic.Tables[0].Rows[0];

        if (row["house"].ToString().Length > 0)
            row["street"] = row["street"] + "<b>&nbsp;&nbsp;&nbsp;בית:&nbsp;</b>" + row["house"];

        if (row["floor"].ToString().Length > 0)
            row["street"] = row["street"] + "<b>&nbsp;&nbsp;&nbsp;קומה:&nbsp;</b>" + row["floor"];

        if (row["flat"].ToString().Length > 0)
            row["street"] = row["street"] + "<b>&nbsp;&nbsp;&nbsp;חדר:&nbsp;</b>" + row["flat"];

        row["street"] = "<font color='#525552'>" + row["street"] + "</font>";

        if (row["email"].ToString().Length > 0)
            row["email"] = "<a href='mailto:" + row["email"] + "'>" + row["email"] + "</a>";
    }

    private void bindPhonesAndFaxes(DetailsView dv)
    {
        GridView gvPhones = dv.FindControl("gvPhones") as GridView;
        GridView gvFax = dv.FindControl("gvFax") as GridView;
        GridView gvWhatsApp = dv.FindControl("gvWhatsApp") as GridView;
        DataView dvPhones = new DataView(m_dsClinic.Tables["DeptPhones"]);

        dvPhones.RowFilter = "phoneType = 1";
        gvPhones.DataSource = dvPhones;
        gvPhones.DataBind();

        dvPhones.RowFilter = "phoneType = 2";
        gvFax.DataSource = dvPhones;
        gvFax.DataBind();

        dvPhones.RowFilter = "phoneType = 6";
        gvWhatsApp.DataSource = dvPhones;
        gvWhatsApp.DataBind();
    }

    private void bindDeptQueueOrder(DetailsView dv)
    {
        Panel pnlQueueOrder = dv.FindControl("pnlQueueOrder") as Panel;
        
        bool HasQueueOrder = Convert.ToBoolean(m_dsClinic.Tables["deptDetails"].Rows[0]["HasQueueOrder"]);
        
        if (HasQueueOrder)
        {
            pnlQueueOrder.Visible = true;

            string queueOrderDescription = m_dsClinic.Tables["deptDetails"].Rows[0]["QueueOrderDescription"].ToString();
            Label lblQueueOrderDescription = dv.FindControl("lblQueueOrderDescription") as Label;
                
            if (m_dsClinic.Tables["DeptQueueOrderMethods"].Rows.Count == 0)
            {
                lblQueueOrderDescription.Visible = true;
                lblQueueOrderDescription.Text = queueOrderDescription;
            }
            else
            {
                lblQueueOrderDescription.Visible = false;
                HtmlTableCell tdDeptQueueOrderMethods = dv.FindControl("tdDeptQueueOrderMethods") as HtmlTableCell;
                string ToggleID = "0";

                List<int> listDeptQueueOrderMethods = (from queueOrder in m_dsClinic.Tables["DeptQueueOrderMethods"].AsEnumerable()
                                                       select queueOrder.Field<int>("QueueOrderMethod")).ToList();

                tdDeptQueueOrderMethods.InnerHtml = UIHelper.GetInnerHTMLForQueueOrder(listDeptQueueOrderMethods, ToggleID, "divServicesAndEvents", true);

                Label lblDeptQueueOrderPhones = dv.FindControl("lblDeptQueueOrderPhones") as Label;
                lblDeptQueueOrderPhones.Text = m_dsClinic.Tables["deptDetails"].Rows[0]["phonesForQueueOrder"].ToString();


                if (m_dsClinic.Tables["HoursForDeptQueueOrder"].Rows.Count > 0)
                {
                    GridView gvDeptQueueOrderHours = dv.FindControl("gvDeptQueueOrderHours") as GridView;
                    gvDeptQueueOrderHours.DataSource = m_dsClinic.Tables["HoursForDeptQueueOrder"];
                    gvDeptQueueOrderHours.DataBind();
                }
            }
        }
        else
        {
            pnlQueueOrder.Visible = false;
            //((Panel)dv.FindControl("pnlAdministrative")).CssClass = string.Empty;
        }
    }

    

    

    

    protected void btnUpdateClinicDetails_Click(object sender, EventArgs e)
    {
        Response.Redirect(@"~/Admin/UpdateClinicDetails.aspx", true);
    }

     

    private void toggleUpdateButtons()
    {
        String[] updateButtonsArr = new string[] { "divUpdateClinicDetails","divUpdateClinicReception",
            "tdUpdateClinicRemarks"};
        
        if (currentUser != null)
        {
            if ((m_isDeptPermittedForUser && !sessionParams.isDistrictOrHospital) || currentUser.IsAdministrator)
            {
                for (int i = 0; i < updateButtonsArr.Length; i++)
                {
                    UIHelper.FindControlRecursive(this.Master, updateButtonsArr[i]).Visible = true;
                }
            }
            else
            {
                for (int i = 0; i < updateButtonsArr.Length; i++)
                {
                    UIHelper.FindControlRecursive(this.Master, updateButtonsArr[i]).Visible = false;
                }
            }
         }
        else 
        {
            for (int i = 0; i < updateButtonsArr.Length; i++)
            {
                UIHelper.FindControlRecursive(this.Master, updateButtonsArr[i]).Visible = false;
            }

        }
    }
    
    

    protected void txtSelectedDeptCode_TextChanged(object sender, EventArgs e)
    {        
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();

        if (Convert.ToInt32(txtSelectedDeptCode.Text) == sessionParams.DeptCode)
            return;
                
        sessionParams.CurrentTab_ZoomClinic = string.Empty;
        Response.Redirect("ZoomClinic.aspx?DeptCode=" + txtSelectedDeptCode.Text, true);
    }

    

    protected void btnUpdateReception_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Admin/UpdateDeptReceptionHours.aspx", true);
    }

    protected void btnAddRemarks_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Admin/AddRemark.aspx?deptCode=" + m_DeptCode);
    }

    

    
    protected void btnUpdateClinicRemarks_Click(object sender, EventArgs e)
    {
        Response.Redirect(@"~/Admin/UpdateRemarks.aspx", true);
    }

    
    
    

    private void BindDeptPhones(GridView gvPhones)
    {
        gvPhones.DataSource = m_dsClinic.Tables["DeptPhones"];
        gvPhones.DataBind();
    }


    protected void gvRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            Label lblRemark = e.Row.FindControl("lblRemark") as Label;

            Image imgInternet = e.Row.FindControl("imgInternet") as Image;
            if (Convert.ToBoolean(dvRowView["displayInInternet"]) != true)
            {
                imgInternet.Style.Add("display", "inline");
                imgInternet.ImageUrl = "~/Images/Applic/pic_NotShowInInternet.gif";
                imgInternet.ToolTip = "לא תוצג באינטרנט";
            }
            else
            {
                imgInternet.ImageUrl = "~/Images/vSign.gif";
                //imgInternet.Style.Add("display", "none");
                imgInternet.Visible = false;
            }

            if (Convert.ToInt32(dvRowView["deptCode"]) == -1) // sweepingRemark
            {
                lblRemark.Style.Add("color", "#628e02");
                e.Row.Style.Add("color", "#628e02");
            }

            string[] RemarkCategoriesForClinicActivityArr = RemarkCategoriesForClinicActivity.Split(',');
            for (int i = 0; i < RemarkCategoriesForClinicActivityArr.Length; i++)
            {
                if (RemarkCategoriesForClinicActivityArr[i] == dvRowView["RemarkCategoryID"].ToString())
                {
                    lblRemark.Style.Add("color", "Red");
                    e.Row.Style.Add("color", "Red");
                }
            }
        }
    }

    

    protected void btnBack_Click(object sender, ImageClickEventArgs e)
    {
        sessionParams = SessionParamsHandler.GetSessionParams();

        if (sessionParams.LastSearchPageURL == null)    // is session expired?
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);

        Response.Redirect(sessionParams.LastSearchPageURL.ToString() + "?RepeatSearch=1");
    }

    protected void gvEmployeeAndServiceRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
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


            if (dvRowView["employeeID"] != DBNull.Value && (Convert.ToInt64(dvRowView["employeeID"])) == remarkEmployeeID)
            {
                Label lblEmployeeName = e.Row.FindControl("lblEmployeeName") as Label;
                lblEmployeeName.Visible = false;
            }
            else
            {
                remarkEmployeeID = Convert.ToInt64(dvRowView["employeeID"]);
            }

            string[] RemarkCategoriesForAbsenceArr = RemarkCategoriesForAbsence.Split(',');
            for (int i = 0; i < RemarkCategoriesForAbsenceArr.Length; i++)
            {
                if (RemarkCategoriesForAbsenceArr[i] == dvRowView["RemarkCategoryID"].ToString())
                {
                    lblRemark.CssClass = "LabelBoldRed_13";
                }
            }

        }
    }

}

