#region system
using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Configuration;
using System.IO;

#endregion

#region Clalit

using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using System.Net;
using System.Text;
using LogClalitLibrary;
using Clalit.Infrastructure.ApplicationFileManager;
using System.Collections.Generic;
using HtmlTemplateManager;
using System.Reflection;
using System.Text.RegularExpressions;
using Clalit.Global.EntitiesDal;
using HtmlTemplateParsing;
using Clalit.SeferNet.EntitiesBL;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using Matrix.Infrastructure.GenericDal;
using SeferNet.Globals;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.SeferNet.Entities;
using Clalit.Infrastructure.ServicesManager;
using SeferNet.BusinessLayer.TemplatesData;
using System.Net.Mail;

#endregion


    /// <summary>
    /// Summary description for FrmSelectTemplate.
    /// </summary>
public partial class FrmSelectTemplate : Page
{
    SessionParams sessionParams;
    Facade applicFacade = Facade.getFacadeObject();
    string templateName;
    string deptCodesInArea = string.Empty;
    string templatePath;
    string templatePathAdditional = string.Empty;

    string deptCodesList;
    string pagingInfo;
    string searchParameters;
    int currentDeptCode;
    int licenseNumber;
    string clientEmail = string.Empty;
    string clalitLogo = string.Empty;
    string clalitAndMushlamLogo = string.Empty;
    string clalitLogo_email = string.Empty;
    string clalitAndMushlamLogo_email = string.Empty;
    bool showClalitLogo = false;
    bool showClalitAndMushlamLogo = false;
    string clalitLogoImage_FullPath = string.Empty;
    string clalitAndMushlamLogoImage_FullPath = string.Empty;
    private List<vReceptionDaysForDisplay> _vReceptionDaysForDisplayList;
    private int pageSize = int.Parse(ConfigurationManager.AppSettings["PageSizeForSearchPages"].ToString());
    private int MaxRecordsToPrint = int.Parse(ConfigurationManager.AppSettings["MaxRecordsNumberToPrint"].ToString());
    private int countHiddenDaysForEmployeeSector = 7;
    ClinicSearchParametersForMushlamServices clinicSearchParametersForMushlamServices = new ClinicSearchParametersForMushlamServices();
    ClinicSearchParameters clinicSearchParameters;

    List<string> segmentsHTML = new List<string>();
    string emptyContainerBeginMarker = "<!-- ##removeifemptycontainerbegin--";
    string emptyContainerEndMarker = "<!-- ##removeifemptycontainerend--";
    string markerSuffix = "## -->";
    string blockBeginMarker = "<!-- ##blockbegin--";
    string blockEndMarker = "<!-- ##blockend--";

    #region controls

    protected System.Web.UI.WebControls.ImageButton imgSendMail;

    #endregion

    #region events

    static FrmSelectTemplate()
    {

    }

    protected void Page_Load(object sender, System.EventArgs e)
    {

        HtmlTemplateParsing.HtmlTemplateDataManager.ResetTemplateFields();
        GetImagePaths();
        GetTemplatePath();
        ExecuteLetter();
        HideCloseButton();
    }

    #region Web Form Designer generated code
    override protected void OnInit(EventArgs e)
    {
        //
        // CODEGEN: This call is required by the ASP.NET Web Form Designer.
        //
        InitializeComponent();
        base.OnInit(e);
    }

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {

    }
    #endregion

    #endregion

    #region privateFunction

    private void GetTemplatePath()
    {
        templateName = Request.QueryString.Get("Template").Trim();
        if (Request.QueryString["NearestDepts"] != null)
            deptCodesInArea = Request.QueryString["NearestDepts"].Trim();

        if (Request.QueryString["CurrentDeptCode"] != null)
            currentDeptCode = Convert.ToInt32(Request.QueryString["CurrentDeptCode"]);

        if (Request.QueryString["ClientEmail"] != null)
            clientEmail = Request.QueryString["ClientEmail"].ToString();

        string physicalApplicationPath = Request.PhysicalApplicationPath;
        if (templateName == "PrintZoomClinicInner" || templateName == "PrintZoomClinicOuter")
        {
            templatePath = physicalApplicationPath + @"Templates\" + "PrintZoomClinic" + ".htm";
        }
        else
        {
            templatePath = physicalApplicationPath + @"Templates\" + templateName + ".htm";
        }

        if (Request.QueryString["IsIndependent"] != null && Request.QueryString["IsIndependent"].ToString() == "1")
        {
            if (Request.QueryString["DoctorLicense"] != null)
            {
                bool isNum = int.TryParse(Request.QueryString["DoctorLicense"].ToString(), out licenseNumber);
                if (isNum)
                {
                    licenseNumber = Convert.ToInt32(Request.QueryString["DoctorLicense"]);
                    templatePathAdditional = physicalApplicationPath + @"Templates\" + "PrintEmployeeDetails" + ".htm";
                }
            }
        }

    }

    private void GetImagePaths()
    {
        string upToImagesPath = string.Empty;
        string[] pathSegments = Server.MapPath(".").Split('\\');
        for (int i = 0; i < pathSegments.Length - 1; i++)
        {
            upToImagesPath += pathSegments[i] + '\\';
        }

        clalitLogoImage_FullPath = upToImagesPath + @"Images\Applic\clalit100logo.gif";
        clalitAndMushlamLogoImage_FullPath = upToImagesPath + @"Images\Applic\clalit-mushlamLogo.gif";
    }

    private void HideCloseButton()
    {
        if (Request.QueryString["CurrentDeptCode"] != null)
            tblCloseButton.Visible = false;
    }

    private string ExceedingMaxOfRecordsExclamation(int tRecords)
    {
        string exclamation = string.Empty;

        if (tRecords > MaxRecordsToPrint)
            exclamation = "<br/><span style='color:Red; font-weight:bold'>" + "שים לב:"
                + "<br/>" + "החיפוש שבוצע מחזיר תוצאות רבות מדי ואין באפשרות המערכת להציג את כולם!"
                + "<br/>" + " כרגע מוצגים " + MaxRecordsToPrint.ToString() + " רשומות מתוך " + tRecords.ToString()
                + "<br/>" + "יש לצמצם את החיפוש" + "</span>";
        return exclamation;
    }

    private void ExecuteLetter()
    {
        string templateData = string.Empty;//get html file from table MNG_GroupTemplates
        string templateFile = string.Empty; //template file
        string action = string.Empty;

        GetAllDeptDetailsForTemplatesParameters deptParams = new GetAllDeptDetailsForTemplatesParameters { DeptCode = 0, IsInternal = false, DeptCodesInArea = string.Empty };

        sessionParams = SessionParamsHandler.GetSessionParams();

        switch (templateName)
        {
            case "PrintZoomClinicInner":
                deptParams.IsInternal = true;
                deptParams.DeptCode = sessionParams.DeptCode;
                break;
            case "PrintZoomClinicOuter":
                deptParams.IsInternal = false;

                if (sessionParams.DeptCode != 0)
                    deptParams.DeptCode = sessionParams.DeptCode;
                else
                    deptParams.DeptCode = currentDeptCode;

                deptParams.DeptCodesInArea = deptCodesInArea;
                break;
            case "PrintClinicList":
                deptParams.IsInternal = false;
                deptParams.DeptCode = 10000;
                GetDeptList_PageAndSearchParameters();
                deptParams.DeptCodesInArea = deptCodesList;
                break;
            case "PrintEmployeeDetails":
                GetEmployee_PageAndSearchParameters();
                break;
            default:
                deptParams.IsInternal = false;
                deptParams.DeptCode = sessionParams.DeptCode;
                break;
        }

        ArrayList block = new ArrayList();

        Hashtable templateVars = new Hashtable(); //variables to send to template

        if (clientEmail != string.Empty)
            txtSendEmailTo.Text = clientEmail;

        if (templateName == "PrintZoomClinicInner" || templateName == "PrintZoomClinicOuter")
        {
            try
            {
                string printOptions = string.Empty;
                GetHTMLfromTemplateZoomClinic(templateName, templatePath, deptParams.DeptCode, deptParams.IsInternal, deptParams.DeptCodesInArea);

                string ClinicListHTML = string.Join("", segmentsHTML.ToArray());

                ltlContent.Text = ClinicListHTML;

                return;
            }
            catch (System.Exception ex)
            {
                //report exception
            }
        }

        else if (templateName == "PrintClinicList")
        {
            try
            {
                string printOptions = string.Empty;
                GetHTMLfromTemplateClinicks(templateName, templatePath, printOptions);

                string ClinicListHTML = string.Join("", segmentsHTML.ToArray());

                ClinicListHTML = ClinicListHTML.Replace("PagingInfo", pagingInfo);
                ClinicListHTML = ClinicListHTML.Replace("SearchParameters", searchParameters);
                ClinicListHTML = ClinicListHTML.Replace("clalitLogo", clalitLogo);
                ClinicListHTML = ClinicListHTML.Replace("clalitAndMushlamLogo", clalitAndMushlamLogo);

                ltlContent.Text = ClinicListHTML;

                return;

            }
            catch (System.Exception ex)
            { }

        }
        else if (templateName == "PrintEmployeeDetails")
        {
            #region PrintEmployeeDetails
            try
            {
                string printOptions = string.Empty;
                GetHTMLfromTemplateEmployees(templateName, templatePath, printOptions);

                string ClinicListHTML = string.Join("", segmentsHTML.ToArray());

                pagingInfo += ExceedingMaxOfRecordsExclamation(sessionParams.totalRows);

                ClinicListHTML = ClinicListHTML.Replace("PagingInfo", pagingInfo);
                ClinicListHTML = ClinicListHTML.Replace("SearchParameters", searchParameters);
                ClinicListHTML = ClinicListHTML.Replace("clalitLogo", clalitLogo);
                ClinicListHTML = ClinicListHTML.Replace("clalitAndMushlamLogo", clalitAndMushlamLogo);

                string newHeader = "פרטי נותני שירות";
                ClinicListHTML = ClinicListHTML.Replace("EmployeeListHeader", newHeader);

                ltlContent.Text = ClinicListHTML;

                return;
            }
            catch (System.Exception ex)
            { }

            #endregion
        }
        else if (templateName == "PrintZoomSalService")
        {
            string printOptions = Request.QueryString.Get("PrintOptions").Trim();

            //try
            //{
            printOptions = Request.QueryString.Get("PrintOptions").Trim();
            //}
            //catch
            //{ }

            try
            {
                ltlContent.Text = GetHTMLfromTemplate(templateName, templatePath, printOptions);
            }
            catch { }
        }
        else if (templateName == "PrintSalServicesList")
        {
            string printOptions = string.Empty;// Request.QueryString.Get("PrintOptions").Trim();
            //printOptions = Request.QueryString.Get("PrintOptions").Trim();

            try
            {
                ltlContent.Text = GetHTMLfromTemplate(templateName, templatePath, printOptions);
            }
            catch { }
        }

    }

    private string GetHTMLfromTemplate(string _templateName, string _templatePath, string _printOptions)
    {
        string _html = string.Empty;
        UserManager userManager = new UserManager();
        UserInfo currentUserInfo = userManager.GetUserInfoFromSession();
        bool IsAdministrator = false;
        bool CanManageTarifonViews = false;
        bool CanViewTarifon = false;
        bool CanManageInternetSalServices = false;

        DataSet dsMain = new DataSet("SalService");

        if (currentUserInfo != null && User.Identity.IsAuthenticated)
        {
            IsAdministrator = currentUserInfo.IsAdministrator;
            CanManageTarifonViews = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageTarifonViews, -1);
            CanViewTarifon = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ViewTarifon, -1);
            CanManageInternetSalServices = currentUserInfo.CheckIfUserPermitted(Enums.UserPermissionType.ManageInternetSalServices, -1);
        }
        else
        {
            //this.phSalServiceTarifonTab.Visible = true;
            //this.phSalServiceTarifon.Visible = true;
        }


        if (templateName == "PrintZoomSalService")
        {
            #region PrintZoomSalService
            int _serviceCode = Convert.ToInt32(sessionParams.ServiceCode);

            DataSet m_dsService = applicFacade.GetSalServiceDetails(_serviceCode);
            //give names to tables
            m_dsService.Tables[0].TableName = "ServiceDetails";
            m_dsService.Tables[4].TableName = "GeneralManagementInstructions";
            //m_dsService.Tables[5].TableName = "GuidancesManagementInstructions";
            m_dsService.Tables[6].TableName = "MedicalInstructions";

            m_dsService.Tables[0].Columns.Add("IncludeInBasketString", typeof(System.String));
            m_dsService.Tables[0].Rows[0]["IncludeInBasketString"] = GetIncludeInBasketString(m_dsService.Tables[0].Rows[0]);

            m_dsService.Tables[0].Columns.Add("Synonym", typeof(System.String));
            m_dsService.Tables[0].Rows[0]["Synonym"] = GetSynonymString(m_dsService.Tables[0].Rows[0]);

            m_dsService.Tables[0].Columns.Add("OmriReturns", typeof(System.String));
            m_dsService.Tables[0].Rows[0]["OmriReturns"] = GetOmriReturns(m_dsService.Tables[3]);


            m_dsService.Tables[1].TableName = "LastUpdateDate";
            m_dsService.Tables[1].Columns.Add("LastSalUpdateDateFormatted", typeof(System.String));
            m_dsService.Tables[1].Rows[0]["LastSalUpdateDateFormatted"] = String.Format("{0:dd/MM/yyyy}", m_dsService.Tables[1].Rows[0]["LastSalUpdateDate"]);

            foreach (DataTable dt in m_dsService.Tables)
            {
                dsMain.Tables.Add(dt.Copy());
            }

            DataTable dtGuidancesManagementInstructions = GetGuidancesManagementInstructions(m_dsService.Tables[5]);
            dtGuidancesManagementInstructions.TableName = "GuidancesManagementInstructions";
            dsMain.Tables.Add(dtGuidancesManagementInstructions);

            DataSet m_dsServiceTarifon = applicFacade.GetSalServiceTarifon(_serviceCode, !(CanViewTarifon || CanManageTarifonViews || IsAdministrator));
            DataTable dtServiceTarifon = m_dsServiceTarifon.Tables[0];
            dtServiceTarifon.Columns.Add("TariffNewString", typeof(System.String));
            foreach (DataRow dr in dtServiceTarifon.Rows)
            {
                dr["TariffNewString"] = string.Empty;
                double tariffNew = 0;
                if (double.TryParse(dr["TariffNew"].ToString(), out tariffNew))
                {
                    if (tariffNew > 0 || Convert.ToInt16(dr["PopulationGiven"]) == 1)
                    {
                        dr["TariffNewString"] = tariffNew.ToString("0,0.00");
                    }
                    else
                    {
                        dr["TariffNewString"] = "לא ניתן";
                    }
                }
            }

            dtServiceTarifon.TableName = "ServiceTarifon";

            if (_printOptions.IndexOf("Taarifon") > 0)
                dsMain.Tables.Add(dtServiceTarifon.Copy());

            if (_printOptions.IndexOf("ICD9") > 0)
            {
                DataSet m_dsServiceICD9 = applicFacade.GetSalServiceICD9(_serviceCode);
                DataTable dtSalServiceICD9 = m_dsServiceICD9.Tables[0];
                dtSalServiceICD9.Columns.Add("GroupCodeString", typeof(System.String));
                dtSalServiceICD9.Columns.Add("class", typeof(System.String));

                int CurrentGroupCode = 0;
                foreach (DataRow dr in dtSalServiceICD9.Rows)
                {
                    dr["GroupCodeString"] = string.Empty;

                    if (Convert.ToInt32(dr["GroupCode"]) != CurrentGroupCode)
                    {
                        dr["GroupCodeString"] = dr["GroupCode"].ToString();
                        CurrentGroupCode = Convert.ToInt32(dr["GroupCode"]);
                        dr["class"] = "tdRemBorderTopDotted";
                    }
                    else
                    {
                        dr["GroupCodeString"] = string.Empty;
                        dr["class"] = string.Empty;
                    }
                }

                dtSalServiceICD9.TableName = "SalServiceICD9";
                dsMain.Tables.Add(dtSalServiceICD9.Copy());

                if (dtSalServiceICD9.Rows.Count == 0)
                {
                    DataTable dtSalServiceICD9_Empty = new DataTable("SalServiceICD9_Empty");
                    dtSalServiceICD9_Empty.Columns.Add("EmptyTableMessage", typeof(System.String));
                    DataRow dr = dtSalServiceICD9_Empty.NewRow();
                    dtSalServiceICD9_Empty.Rows.Add(dr);
                    dtSalServiceICD9_Empty.Rows[0]["EmptyTableMessage"] = "לא נמצאו קודי פרוצדורה מקושרים";
                    dsMain.Tables.Add(dtSalServiceICD9_Empty.Copy());
                }
            }

            DataSet m_dsServiceInternetDetails = applicFacade.GetSalServiceInternetDetails(_serviceCode);
            DataTable dtInternetDetails = m_dsServiceInternetDetails.Tables[0];

            dtInternetDetails.Columns.Add("showServiceInInternetString", typeof(System.String));
            dtInternetDetails.Columns.Add("QueueOrderString", typeof(System.String));
            dtInternetDetails.Columns.Add("GenderPrivilegeString", typeof(System.String));
            dtInternetDetails.Columns.Add("FromAgePrivilegeString", typeof(System.String));
            dtInternetDetails.Columns.Add("UntilAgePrivilegeString", typeof(System.String));
            dtInternetDetails.Columns.Add("TreatmentString", typeof(System.String));
            dtInternetDetails.Columns.Add("EntitlementCheckString", typeof(System.String));
            dtInternetDetails.Columns.Add("DiagnosisString", typeof(System.String));
            dtInternetDetails.Columns.Add("ProfessionsString", typeof(System.String));
            dtInternetDetails.Columns.Add("SalCategoriesString", typeof(System.String));
            dtInternetDetails.Columns.Add("Synonym", typeof(System.String));


            DataRow drInternetDetails = dtInternetDetails.Rows[0];

            if (drInternetDetails["ShowServiceInInternet"] != DBNull.Value && Convert.ToInt32(drInternetDetails["ShowServiceInInternet"]) == 0)
                drInternetDetails["showServiceInInternetString"] = "לא";
            else
                drInternetDetails["showServiceInInternetString"] = "כן";

            if (drInternetDetails["QueueOrder"] != DBNull.Value && Convert.ToInt32(drInternetDetails["QueueOrder"]) == 0)
                drInternetDetails["QueueOrderString"] = "לא";
            else
                drInternetDetails["QueueOrderString"] = "כן";

            if (drInternetDetails["GenderPrivilege"] != DBNull.Value)
            {
                if (Convert.ToInt32(drInternetDetails["GenderPrivilege"]) == 1)
                    drInternetDetails["GenderPrivilegeString"] = "זכר";
                else if (Convert.ToInt32(drInternetDetails["GenderPrivilege"]) == 2)
                    drInternetDetails["GenderPrivilegeString"] = "נקבה";
            }

            if (drInternetDetails["FromAgePrivilege"] != DBNull.Value)
            {
                if (Convert.ToInt32(drInternetDetails["FromAgePrivilege"]) == 0)
                    drInternetDetails["FromAgePrivilegeString"] = "&nbsp;";
                else
                    drInternetDetails["FromAgePrivilegeString"] = Convert.ToInt32(drInternetDetails["FromAgePrivilege"]).ToString();
            }

            if (drInternetDetails["UntilAgePrivilege"] != DBNull.Value)
            {
                if (Convert.ToInt32(drInternetDetails["UntilAgePrivilege"]) == 0)
                    drInternetDetails["UntilAgePrivilegeString"] = "&nbsp;";
                else
                    drInternetDetails["UntilAgePrivilegeString"] = Convert.ToInt32(drInternetDetails["UntilAgePrivilege"]).ToString();
            }

            if (drInternetDetails["Treatment"] != DBNull.Value && Convert.ToInt32(drInternetDetails["Treatment"]) == 0)
                drInternetDetails["TreatmentString"] = "לא";
            else
                drInternetDetails["TreatmentString"] = "כן";

            if (drInternetDetails["EntitlementCheck"] != DBNull.Value && Convert.ToInt32(drInternetDetails["EntitlementCheck"]) == 0)
                drInternetDetails["EntitlementCheckString"] = "לא";
            else
                drInternetDetails["EntitlementCheckString"] = "כן";

            if (drInternetDetails["Diagnosis"] != DBNull.Value && Convert.ToInt32(drInternetDetails["Diagnosis"]) == 0)
                drInternetDetails["DiagnosisString"] = "לא";
            else
                drInternetDetails["DiagnosisString"] = "כן";

            drInternetDetails["ProfessionsString"] = string.Empty;
            if (m_dsServiceInternetDetails.Tables[1].Rows.Count > 0)
            {
                foreach (DataRow dr in m_dsServiceInternetDetails.Tables[1].Rows)
                {
                    if (dr["showProfessionInInternet"] != DBNull.Value && Convert.ToInt16(dr["showProfessionInInternet"]) == 1)
                        drInternetDetails["ProfessionsString"] += "</br>&nbsp;@";
                    else
                        drInternetDetails["ProfessionsString"] += "</br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

                    drInternetDetails["ProfessionsString"] += "&nbsp;&nbsp;" + dr["Description"].ToString();
                }
            }


            drInternetDetails["SalCategoriesString"] = string.Empty;
            //SalCategoryDescription
            if (m_dsServiceInternetDetails.Tables[2].Rows.Count > 0)
            {
                foreach (DataRow dr in m_dsServiceInternetDetails.Tables[2].Rows)
                {
                    drInternetDetails["SalCategoriesString"] += "</br>&nbsp;&nbsp;" + dr["SalCategoryDescription"].ToString();
                }
            }

            drInternetDetails["Synonym"] = GetSynonymString(m_dsService.Tables[0].Rows[0]);

            dtInternetDetails.TableName = "InternetDetails";

            if (_printOptions.IndexOf("Internet") > 0)
                dsMain.Tables.Add(dtInternetDetails.Copy());

            DataSet dsMushlamServices = Facade.getFacadeObject().GetMushlamServicesForSalService(_serviceCode);
            DataTable dtMushlamServices = dsMushlamServices.Tables[0];
            dtMushlamServices.TableName = "MushlamServices";

            if (_printOptions.IndexOf("Mushlam") > 0)
            {
                dsMain.Tables.Add(dtMushlamServices.Copy());

                if (dtMushlamServices.Rows.Count == 0)
                {
                    DataTable dtMushlamServices_Empty = new DataTable("dtMushlamServices_Empty");
                    dtMushlamServices_Empty.Columns.Add("EmptyTableMessage", typeof(System.String));
                    DataRow dr = dtMushlamServices_Empty.NewRow();
                    dtMushlamServices_Empty.Rows.Add(dr);
                    dtMushlamServices_Empty.Rows[0]["EmptyTableMessage"] = "לא נמצאו שירות מושלם מקושרים";
                    dsMain.Tables.Add(dtMushlamServices_Empty.Copy());
                }
            }
            #endregion
        }

        if (templateName == "PrintSalServicesList")
        {
            #region PrintSalServiceList
            if (Session["SalServicesDataSet"] != null)
            {
                DataSet ds = (DataSet)Session["SalServicesDataSet"];
                DataTable dt = ds.Tables[0];

                if(dt.Columns["IncludeInBasket_String"] == null)
                    dt.Columns.Add("IncludeInBasket_String", typeof(System.String));
                if (dt.Columns["ShowServiceInInternet_String"] == null)
                    dt.Columns.Add("ShowServiceInInternet_String", typeof(System.String));
                if (dt.Columns["Limiter_String"] == null)
                    dt.Columns.Add("Limiter_String", typeof(System.String));
                if (dt.Columns["IsCanceled_String"] == null)
                    dt.Columns.Add("IsCanceled_String", typeof(System.String));

                bool _limiter = false;

                foreach (DataRow dr in dt.Rows)
                {
                    if (!DBNull.Value.Equals(dr["ShowServiceInInternet"]))
                    {
                        if (Convert.ToInt16(dr["ShowServiceInInternet"]) == 1)
                            dr["ShowServiceInInternet_String"] = "כן";
                    }

                    if (!DBNull.Value.Equals(dr["Limiter"]))
                    {
                        if (Convert.ToInt16(dr["Limiter"]) == 1)
                        {
                            dr["Limiter_String"] = "כן";
                            _limiter = true;
                        }
                        else
                            _limiter = false;
                    }

                    if (!DBNull.Value.Equals(dr["IncludeInBasket"]))
                    {
                        if (_limiter == true)
                        {
                            if (Convert.ToInt16(dr["IncludeInBasket"]) == 0)
                                dr["IncludeInBasket_String"] = "מוגבל";
                            else
                                dr["IncludeInBasket_String"] = "מוגבל";
                        }
                        else
                        {
                            if (Convert.ToInt16(dr["IncludeInBasket"]) == 1)
                                dr["IncludeInBasket_String"] = "כן";
                            else
                                dr["IncludeInBasket_String"] = "לא";
                        }
                    }

                    if (!DBNull.Value.Equals(dr["IsCanceled"]))
                    {
                        if (Convert.ToInt16(dr["IsCanceled"]) == 1)
                            dr["IsCanceled_String"] = "כן";
                    }
                }

                dt.TableName = "SalServices";
                dsMain.Tables.Add(dt.Copy());
            }
            #endregion
        }

        _html = File.ReadAllText(_templatePath, Encoding.GetEncoding("Windows-1255"));

        int indexSegmentBegin = 0;
        int indexSegmentEnd = 0;
        bool lookingForBegining = true;

        int countSegments = 0;
        foreach (Match m in Regex.Matches(_html, "##removeifemptycontainerbegin"))
            countSegments++;

        if (countSegments > 0)
            countSegments = countSegments * 2 + 1;
        else
            countSegments = 1;

        string[] list_Segments = new string[countSegments];

        if (countSegments == 1) // there are NO ##removeifemptycontainerbegin bloks exist
        {
            list_Segments[0] = _html;
        }
        else
        {
            for (int i = 0; i < countSegments; i++) // split _html into "list_Segments"
            {
                if (lookingForBegining)
                {
                    indexSegmentEnd = _html.IndexOf("<!-- ##removeifemptycontainerbegin", indexSegmentBegin);

                    if (indexSegmentEnd == -1)
                        indexSegmentEnd = _html.Length;

                    list_Segments[i] = _html.Substring(indexSegmentBegin, indexSegmentEnd - indexSegmentBegin);
                }
                else
                {
                    indexSegmentEnd = _html.IndexOf("-->", _html.IndexOf("##removeifemptycontainerend", indexSegmentBegin)) + 3;
                    list_Segments[i] = _html.Substring(indexSegmentBegin, indexSegmentEnd - indexSegmentBegin);
                }

                indexSegmentBegin = indexSegmentEnd;
                lookingForBegining = !lookingForBegining;

            }
        }

        _html = string.Empty;

        foreach (string segment in list_Segments)
        {
            string _segment = segment;

            if (_segment.IndexOf("##blockbegin") == -1)
            {
                _segment = FillHTML_NO_block(dsMain, _segment);
            }
            else
            {
                _segment = FillHTMLwithBlock(dsMain, _segment);
            }

            _html = _html + _segment;

        }


        return _html;
    }

    private string GetHTMLfromTemplateClinicks(string templateName, string _templatePath, string printOptions)
    {
        DataSet dsMain = new DataSet();
        string _html = string.Empty;

        if (templateName == "PrintClinicList")
        {
            Facade applicFacade = Facade.getFacadeObject();

            if (Session["ClinicSearchParametersForMushlamServices"] != null)
            {
                clinicSearchParametersForMushlamServices = (ClinicSearchParametersForMushlamServices)Session["ClinicSearchParametersForMushlamServices"];
            }
            string FoundDeptCodeList = Session["FoundDeptCodeList"].ToString();

            clinicSearchParameters = (ClinicSearchParameters)Session["clinicSearchParameters"];

            DataSet dsClinics = applicFacade.getClinicList_ForPrinting(clinicSearchParameters, clinicSearchParametersForMushlamServices, FoundDeptCodeList);

            dsClinics.Tables[0].TableName = "Depts";
            dsClinics.Tables[1].TableName = "ServiceSuppliers";

            foreach (DataTable dt in dsClinics.Tables)
            {
                dsMain.Tables.Add(dt.Copy());
            }

        }

        _html = File.ReadAllText(_templatePath, Encoding.GetEncoding("Windows-1255"));

        _html = FillHtmlFromDataSet_Recursive(ref dsMain, _html, string.Empty, 0);

        return _html;
    }

    private string GetHTMLfromTemplateEmployees(string templateName, string _templatePath, string printOptions)
    {
        DataSet dsMain = new DataSet();
        string _html = string.Empty;
 
        Facade applicFacade = Facade.getFacadeObject();
        //
        DoctorSearchParameters doctorSearchParameters = HttpContext.Current.Session["doctorSearchParameters"] as DoctorSearchParameters;
        SortingAndPagingParameters sortingAndPagingParameters = HttpContext.Current.Session["SortingAndPagingParameters"] as SortingAndPagingParameters;
        int currentPage = 1;

        doctorSearchParameters.IsGetEmployeesReceptionInfo = true;

        SearchPagingAndSortingDBParams searchPagingAndSortingDBParams
            = new SearchPagingAndSortingDBParams(MaxRecordsToPrint, currentPage, sortingAndPagingParameters.SortingOrder, sortingAndPagingParameters.OrderBy);
        //

        doctorManager doctorMgr = new doctorManager();
        DataSet dsEmployees = null;
        try
        {
            dsEmployees = doctorMgr.getDoctorList_ForPrinting(doctorSearchParameters, searchPagingAndSortingDBParams);

        }
        catch (Exception ex)
        {
            ExceptionHandlingManager mgr = new ExceptionHandlingManager();
            mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDoctorList_PagedSorted),
              new WebPageExtraInfoGenerator());
        }

        dsEmployees.Tables[0].TableName = "Employees";
        dsEmployees.Tables[2].TableName = "EmployeeServices";
        dsEmployees.Tables[3].TableName = "EmployeeServicesReception";
        dsEmployees.Tables[4].TableName = "EmployeeRemarks";
        dsEmployees.Tables[5].TableName = "EmployeeServiceRemarks";

        foreach (DataTable dt in dsEmployees.Tables)
        {
            //if dt.TableName
            dsMain.Tables.Add(dt.Copy());
        }


        _html = File.ReadAllText(_templatePath, Encoding.GetEncoding("Windows-1255"));

        _html = FillHtmlFromDataSet_Recursive(ref dsMain, _html, string.Empty, 0);

        return _html;
    }


    private string GetHTMLfromTemplateZoomClinic(string templateName, string _templatePath, int deptCode, bool isInternal, string deptCodesInArea)
    {
        DataSet dsMain = new DataSet();
        string _html = string.Empty;

        Facade applicFacade = Facade.getFacadeObject();

        DataSet dsClinics = applicFacade.getZoomClinic_ForPrinting(deptCode, isInternal, deptCodesInArea);

        dsClinics.Tables[0].TableName = "deptDetails";
        dsClinics.Tables[1].TableName = "deptRemarks";
        dsClinics.Tables[2].TableName = "deptReceptionHours";
        dsClinics.Tables[3].TableName = "employeeSectors";
        dsClinics.Tables[4].TableName = "employeeServices";
        dsClinics.Tables[5].TableName = "employeeRemarks";
        dsClinics.Tables[6].TableName = "deptServices";
        dsClinics.Tables[7].TableName = "deptServiceRemarks";
        dsClinics.Tables[8].TableName = "deptEvents";
        dsClinics.Tables[9].TableName = "subClinics";
        dsClinics.Tables[10].TableName = "subClinicsRemarks";
        dsClinics.Tables[11].TableName = "subClinicsReceptionHours";
        dsClinics.Tables[12].TableName = "nearbyDepts";
        dsClinics.Tables[13].TableName = "nearbyDeptsRemarks";
        dsClinics.Tables[14].TableName = "nearbyDeptsReceptionHours";

        foreach (DataTable dt in dsClinics.Tables)
        {
            dsMain.Tables.Add(dt.Copy());
        }

        _html = File.ReadAllText(_templatePath, Encoding.GetEncoding("Windows-1255"));

        _html = FillHtmlFromDataSet_Recursive(ref dsMain, _html, string.Empty, 0);

        return _html;
    }

    private string FillHtmlFromDataSet_Recursive(ref DataSet ds, string _html, string dataTableName, int parentID)
    {
        int indexSegmentEnd = 0;
        int indexPreviousSegmentEnd = 0;

        int indexContainerBegin = 0;

        string nameOfTheBlock = string.Empty;
        int lenghtOfTheNameOfTheBlock = 0;

        string fullEmptyContainerBeginMarker = string.Empty;
        string fullEmptyContainerEndMarker = string.Empty;

        string fullBlockBeginMarker = string.Empty;
        string fullBlockEndMarker = string.Empty;

        string currentSegment = string.Empty;
        string noBlockSegment = string.Empty;
        string noContainerSegment = string.Empty;

        string currentContainer = string.Empty;

        int lenghtOfEmptyContainerBeginMarker = emptyContainerBeginMarker.Length;

        string PageHeader = string.Empty;
        string PageFooter = string.Empty;

        bool end_Of_HTML_block = false;

        List<string> containers = new List<string>();

        PageHeader = _html.Substring(0, _html.IndexOf(emptyContainerBeginMarker, 0));

        segmentsHTML.Add(PageHeader);

        indexPreviousSegmentEnd = PageHeader.Length - 1;

        do
        {
            indexContainerBegin = _html.IndexOf(emptyContainerBeginMarker, indexPreviousSegmentEnd);

            if (indexContainerBegin == -1)
                {
                    end_Of_HTML_block = true;
                    continue;
                }

            #region getContainer
            lenghtOfTheNameOfTheBlock = _html.IndexOf("##", indexContainerBegin + lenghtOfEmptyContainerBeginMarker) - (indexContainerBegin + lenghtOfEmptyContainerBeginMarker);

            nameOfTheBlock = _html.Substring(indexContainerBegin + lenghtOfEmptyContainerBeginMarker, lenghtOfTheNameOfTheBlock);

            fullEmptyContainerEndMarker = emptyContainerEndMarker + nameOfTheBlock + markerSuffix;
            fullEmptyContainerBeginMarker = emptyContainerBeginMarker + nameOfTheBlock + markerSuffix;

            indexSegmentEnd = _html.IndexOf(fullEmptyContainerEndMarker, indexContainerBegin) + fullEmptyContainerEndMarker.Length;

            currentContainer = _html.Substring(indexContainerBegin, indexSegmentEnd - indexContainerBegin);
            currentContainer = currentContainer.Replace(fullEmptyContainerBeginMarker, string.Empty);
            currentContainer = currentContainer.Replace(fullEmptyContainerEndMarker, string.Empty);

            FillContainerFromDataSet(ref ds, currentContainer, nameOfTheBlock, 0);

            #endregion

            indexPreviousSegmentEnd = indexSegmentEnd;


        } while (end_Of_HTML_block == false);

        PageFooter = _html.Substring(indexPreviousSegmentEnd, _html.Length - indexPreviousSegmentEnd);

        segmentsHTML.Add(PageFooter);

        return string.Empty;
    }

    private string FillContainerFromDataSet(ref DataSet ds, string currentContainer, string dataTableName, long parentID)
    {
        string block = string.Empty;

        string fullBlockBeginMarker = blockBeginMarker + dataTableName + markerSuffix;
        string fullBlockEndMarker = blockEndMarker + dataTableName + markerSuffix;

        DataRow[] resultsSelected;
        if (parentID == 0)
            resultsSelected = ds.Tables[dataTableName].Select();
        else
            resultsSelected = ds.Tables[dataTableName].Select("ParentCode = " + parentID.ToString());

        if (resultsSelected.Length > 0)
        {
            // "before block" segment
            string blockHeader = currentContainer.Substring(0, currentContainer.IndexOf(fullBlockBeginMarker));

            FillHeaderFooterWithData(ref ds, resultsSelected[0], blockHeader);

            // block itself
            block = currentContainer.Substring(currentContainer.IndexOf(fullBlockBeginMarker), 
                        currentContainer.Length - currentContainer.IndexOf(fullBlockBeginMarker)
                            - (currentContainer.Length - currentContainer.IndexOf(fullBlockEndMarker)));
            block = block.Replace(fullBlockBeginMarker, string.Empty);
            block = block.Replace(fullBlockEndMarker, string.Empty);

            foreach (DataRow dr in resultsSelected)
            {
                FillBlockTemplateWithData(ref ds, dr, block);
            }

            string blockFooter = currentContainer.Substring(currentContainer.IndexOf(fullBlockEndMarker) + fullBlockEndMarker.Length, currentContainer.Length - currentContainer.IndexOf(fullBlockEndMarker) - fullBlockEndMarker.Length);

            FillHeaderFooterWithData(ref ds, resultsSelected[0], blockFooter);
        }

        return string.Empty;        
    }
    private string FillHeaderFooterWithData(ref DataSet ds, DataRow dr, string block)
    {
        int indBegin = 0;
        int indEnd = 0;
        string[] table_field;
        string strValue = string.Empty;
        string toBeReplaced = string.Empty;
        //int ID = Convert.ToInt32(dr["ID"]);

        do
        {
            indBegin = block.IndexOf("##", indBegin) + 2;
            indEnd = block.IndexOf("##", indBegin);
            if (indEnd == -1)
                continue;

            table_field = block.Substring(indBegin, indEnd - indBegin).Split('.');
            try
            {
                if (dr[table_field[1]] != null)
                {
                    strValue = dr[table_field[1]].ToString();
                    toBeReplaced = "##" + table_field[0] + '.' + table_field[1] + "##";
                    strValue = strValue.Replace("&lt;br&gt;", "<br>").Replace("&amp;nbsp;", "&nbsp;").Replace("&amp;minus;", "-");
                    block = block.Replace(toBeReplaced, strValue);
                }
            }
            catch
            {
            }

        } while (indBegin != -1 && indEnd != -1);

        segmentsHTML.Add(block);
        return string.Empty;
    }

    private string FillBlockTemplateWithData(ref DataSet ds, DataRow dr, string block)
    {
        int indBegin = 0;
        int indEnd = 0;
        string[] table_field;
        string strValue = string.Empty;
        string toBeReplaced = string.Empty;
        //*****************************
        int indexSegmentBegin = 0;
        int indexSegmentEnd = 0;

        int indexContainerBegin = 0;

        string nameOfTheBlock = string.Empty;
        int lenghtOfTheNameOfTheBlock = 0;

        string fullEmptyContainerBeginMarker = string.Empty;
        string fullEmptyContainerEndMarker = string.Empty;

        string fullBlockBeginMarker = string.Empty;
        string fullBlockEndMarker = string.Empty;

        string noBlockSegment = string.Empty;
        string noContainerSegment = string.Empty;

        string currentContainer = string.Empty;

        int lenghtOfEmptyContainerBeginMarker = emptyContainerBeginMarker.Length;

        long ID = Convert.ToInt64(dr["ID"]);

        do
        {
            indexContainerBegin = block.IndexOf(emptyContainerBeginMarker, 0); // do it on every cycle as we change block every time

            indBegin = block.IndexOf("##", indBegin) + 2;
            indEnd = block.IndexOf("##", indBegin);
            if (indEnd == -1)
                continue;

            if (indBegin > indexContainerBegin && indexContainerBegin > -1)
            { 
                indBegin = -1;
                continue;
            }

            table_field = block.Substring(indBegin, indEnd - indBegin).Split('.');
            try
            {
                if (dr[table_field[1]] != null)
                {
                    strValue = dr[table_field[1]].ToString();
                    toBeReplaced = "##" + table_field[0] + '.' + table_field[1] + "##";
                    strValue = strValue.Replace("&lt;br&gt;", "<br>").Replace("&amp;nbsp;", "&nbsp;").Replace("&amp;minus;", "-"); 
                    block = block.Replace(toBeReplaced, strValue);
                }
            }
            catch
            {
            }

        } while (indBegin != -1 && indEnd != -1);

        indexContainerBegin = block.IndexOf(emptyContainerBeginMarker, indexSegmentEnd);  
        if (indexContainerBegin > 0) // if there is a container inside
        {
            do {
                    //get the part before container
                    //segmentsHTML.Add(block.Substring(indexSegmentEnd, indexContainerBegin - indexSegmentEnd));
                    FillHeaderFooterWithData(ref ds, dr, block.Substring(indexSegmentEnd, indexContainerBegin - indexSegmentEnd));

                    #region getContainer
                    lenghtOfTheNameOfTheBlock = block.IndexOf("##", indexContainerBegin + lenghtOfEmptyContainerBeginMarker) - (indexContainerBegin + lenghtOfEmptyContainerBeginMarker);

                    nameOfTheBlock = block.Substring(indexContainerBegin + lenghtOfEmptyContainerBeginMarker, lenghtOfTheNameOfTheBlock);

                    fullEmptyContainerEndMarker = emptyContainerEndMarker + nameOfTheBlock + markerSuffix;
                    fullEmptyContainerBeginMarker = emptyContainerBeginMarker + nameOfTheBlock + markerSuffix;

                    indexSegmentEnd = block.IndexOf(fullEmptyContainerEndMarker, indexSegmentBegin) + fullEmptyContainerEndMarker.Length;

                    currentContainer = block.Substring(indexContainerBegin, indexSegmentEnd - indexContainerBegin);
                    currentContainer = currentContainer.Replace(fullEmptyContainerBeginMarker, string.Empty);
                    currentContainer = currentContainer.Replace(fullEmptyContainerEndMarker, string.Empty);

                    fullBlockBeginMarker = blockBeginMarker + nameOfTheBlock + markerSuffix;
                    fullBlockEndMarker = blockEndMarker + nameOfTheBlock + markerSuffix;

                    FillContainerFromDataSet(ref ds, currentContainer, nameOfTheBlock, ID);

                    #endregion
                    // looking for next container inside this block
                    indexContainerBegin = block.IndexOf(emptyContainerBeginMarker, indexSegmentEnd);

                    if(indexContainerBegin == -1)
                    {
                        FillHeaderFooterWithData(ref ds, dr, block.Substring(indexSegmentEnd, block.Length - indexSegmentEnd));
                    }

            } while (indexContainerBegin > 0);
        }
        else
        { 
            segmentsHTML.Add(block);        
        }
        return string.Empty;
    }
    private DataTable GetGuidancesManagementInstructions(DataTable dtManagementGuidances)
    {
        DataTable dtManagementGuidances_Unified = dtManagementGuidances.Copy();

        if (dtManagementGuidances.Rows.Count > 0)
        {
            dtManagementGuidances_Unified.Rows.Clear();

            StringBuilder sbDiagnostics = new StringBuilder();
            StringBuilder sbAge = new StringBuilder();
            StringBuilder sbPublicFacility = new StringBuilder();
            StringBuilder sbTreatment = new StringBuilder();
            StringBuilder sbComment = new StringBuilder();

            int entrance = 0;
            bool newEntrance = false;

            for (int i = 0; i < dtManagementGuidances.Rows.Count; i++)
            {
                DataRow drManagementGuidances = dtManagementGuidances.Rows[i];

                // Check if this is a new row (Is there is '*' in the TableBreak Column)
                if ((drManagementGuidances["TableBreak"].ToString() == "*" && i > 0))
                {
                    // Add the current values string builders values as a new row to the new datatable 'dtManagementGuidances_Unified'
                    DataRow newGuidancesRow = dtManagementGuidances_Unified.NewRow();

                    newGuidancesRow["diagnostics"] = sbDiagnostics.ToString();
                    newGuidancesRow["Age"] = sbAge.ToString();
                    newGuidancesRow["PublicFacility"] = sbPublicFacility.ToString();
                    newGuidancesRow["Treatment"] = sbTreatment.ToString();
                    newGuidancesRow["Comment"] = sbComment.ToString();

                    dtManagementGuidances_Unified.Rows.Add(newGuidancesRow);

                    // After adding the new row clear all the previous values:
                    sbDiagnostics.Clear();
                    sbAge.Clear();
                    sbPublicFacility.Clear();
                    sbTreatment.Clear();
                    sbComment.Clear();
                }
                else if ((int)drManagementGuidances["entrance"] != entrance && entrance != 0)
                {
                    newEntrance = true;
                }

                if (!string.IsNullOrEmpty(drManagementGuidances["diagnostics"].ToString()))
                {
                    if (newEntrance)
                        sbDiagnostics.Append("<br />");

                    if (sbDiagnostics.Length > 0)
                        sbDiagnostics.Append(" ");

                    sbDiagnostics.Append(drManagementGuidances["diagnostics"]);
                }

                if (!string.IsNullOrEmpty(drManagementGuidances["age"].ToString()))
                {
                    if (sbAge.Length > 0)
                        sbAge.Append("<br />");
                    sbAge.Append(drManagementGuidances["age"]);
                }

                if (!string.IsNullOrEmpty(drManagementGuidances["publicfacility"].ToString()))
                {
                    if (newEntrance)
                        sbPublicFacility.Append("<br />");

                    if (sbPublicFacility.Length > 0)
                        sbPublicFacility.Append(" ");

                    sbPublicFacility.Append(drManagementGuidances["publicfacility"]);
                }

                if (!string.IsNullOrEmpty(drManagementGuidances["treatment"].ToString()))
                {
                    //if (sbTreatment.Length > 0)
                    //    sbTreatment.Append(" ");

                    if (newEntrance)
                        sbTreatment.Append("<br />");

                    if (sbTreatment.Length > 0)
                        sbTreatment.Append(" ");

                    sbTreatment.Append(drManagementGuidances["treatment"]);
                }

                if (!string.IsNullOrEmpty(drManagementGuidances["comment"].ToString()))
                {
                    //if (sbComment.Length > 0)
                    //    sbComment.Append(" ");

                    if (newEntrance)
                        sbComment.Append("<br />");

                    if (sbComment.Length > 0)
                        sbComment.Append(" ");

                    sbComment.Append(drManagementGuidances["comment"]);
                }

                entrance = (int)drManagementGuidances["entrance"];
                newEntrance = false;

                if (i == dtManagementGuidances.Rows.Count - 1)
                {
                    // Add the current values string builders values as a new row to the new datatable 'dtManagementGuidances_Unified'
                    DataRow newGuidancesRow = dtManagementGuidances_Unified.NewRow();

                    newGuidancesRow["diagnostics"] = sbDiagnostics.ToString();
                    newGuidancesRow["Age"] = sbAge.ToString();
                    newGuidancesRow["PublicFacility"] = sbPublicFacility.ToString();
                    newGuidancesRow["Treatment"] = sbTreatment.ToString();
                    newGuidancesRow["Comment"] = sbComment.ToString();

                    dtManagementGuidances_Unified.Rows.Add(newGuidancesRow);

                    // After adding the new row clear all the previous values:
                    sbDiagnostics.Clear();
                    sbAge.Clear();
                    sbPublicFacility.Clear();
                    sbTreatment.Clear();
                    sbComment.Clear();
                }
            }


        }
        return dtManagementGuidances_Unified;

    }

    private string FillHTMLwithBlock(DataSet ds, string _segment)
    {
        string _tableName = string.Empty;
        string _HTMLprefix = string.Empty;
        string _HTMLsuffix = string.Empty;
        string _HTMLbody = string.Empty;
        string _HTMLbodyTemplate = string.Empty;

        //How many blocks in _segment?
        int countBlocks = 0;
        foreach (Match m in Regex.Matches(_segment, "##blockbegin"))
            countBlocks++;

        int _indexToBegin = _segment.IndexOf("##blockbegin--") + "##blockbegin--".Length;
        int _indexToEnd = _segment.IndexOf("##", _indexToBegin);
        _tableName = _segment.Substring(_indexToBegin, _indexToEnd - _indexToBegin);

        // check data
        if (ds.Tables[_tableName] == null || ds.Tables[_tableName].Rows.Count == 0)
        {
            _segment = string.Empty;
        }
        else
        {
            // cut HTML prefix
            _HTMLprefix = _segment.Substring(0, _segment.IndexOf("<!-- ##blockbegin"));

            // cut HTML to put into cycle
            _indexToBegin = _indexToBegin + _tableName.Length + "## -->".Length;
            _indexToEnd = _segment.IndexOf("<!-- ##blockend", _indexToBegin);
            _HTMLbodyTemplate = _segment.Substring(_indexToBegin, _indexToEnd - _indexToBegin);

            // cut HTML suffix
            _indexToBegin = _indexToEnd + _segment.IndexOf("<!-- ##blockend--" + _tableName.Length + "## -->".Length);
            _HTMLsuffix = _segment.Substring(_indexToBegin, _segment.Length - _indexToBegin);

            _segment = _HTMLprefix;

            _segment = _segment + FillHTMLwithData(ds.Tables[_tableName], _HTMLbodyTemplate);

            _segment = _segment + _HTMLsuffix;
        }

        return _segment;
    }

    private string FillHTML_NO_block(DataSet ds, string _segment)
    {
        int indBegin = 0, indEnd = 0;
        string tableName = string.Empty;
        string[] table_field;
        string strValue = string.Empty;
        string replacement = string.Empty;

        do
        {
            indBegin = _segment.IndexOf("##", indBegin) + 2;
            indEnd = _segment.IndexOf("##", indBegin);
            if (indEnd == -1)
                continue;

            table_field = _segment.Substring(indBegin, indEnd - indBegin).Split('.');
            try
            {
                if (ds.Tables[table_field[0]] != null)
                {
                    strValue = ds.Tables[table_field[0]].Rows[0][table_field[1]].ToString();
                    replacement = "##" + table_field[0] + '.' + table_field[1] + "##";
                    _segment = _segment.Replace(replacement, strValue);

                }
            }
            catch
            {
            }

        } while (indBegin != -1 && indEnd != -1);

        return _segment;
    }

    private string FillHTMLwithData(DataTable dt, string _HTMLtemplate)
    {
        string _HTMLtoReturn = string.Empty;
        string _HTMLbody = string.Empty;
        int indBegin = 0;
        int indEnd = 0;
        string[] table_field;
        string strValue = string.Empty;
        string replacement = string.Empty;

        foreach (DataRow dr in dt.Rows)
        {
            _HTMLbody = _HTMLtemplate;

            do
            {
                indBegin = _HTMLbody.IndexOf("##", indBegin) + 2;
                indEnd = _HTMLbody.IndexOf("##", indBegin);
                if (indEnd == -1)
                    continue;

                table_field = _HTMLbody.Substring(indBegin, indEnd - indBegin).Split('.');
                try
                {
                    if (dr[table_field[1]] != null)
                    {
                        strValue = dr[table_field[1]].ToString();
                        replacement = "##" + table_field[0] + '.' + table_field[1] + "##";
                        _HTMLbody = _HTMLbody.Replace(replacement, strValue);

                    }
                }
                catch
                {
                }

            } while (indBegin != -1 && indEnd != -1);

            _HTMLtoReturn = _HTMLtoReturn + _HTMLbody;
        }

        return _HTMLtoReturn;
    }

    private string GetIncludeInBasketString(DataRow drServiceDetails)
    {
        string IncludeInBasketString = string.Empty;
        int iscanceled = 0;
        if (drServiceDetails["IsCanceled"] != DBNull.Value)
            iscanceled = Convert.ToInt32(drServiceDetails["IsCanceled"]);

        int includeInBasket = Convert.ToInt32(drServiceDetails["IncludeInBasket"]);

        int limiter = Convert.ToInt32(drServiceDetails["Limiter"]);

        if (iscanceled == 1)
        {
            if (drServiceDetails["DEL_DATE"] != DBNull.Value)
            {
                DateTime delDate = (DateTime)drServiceDetails["DEL_DATE"];

                IncludeInBasketString = "מבוטל";
                IncludeInBasketString = IncludeInBasketString + "&nbsp;<span style='font-weight:normal'>(  מבוטל מתאריך:  " + delDate.ToString("dd/MM/yyyy") + ")</span>";
            }
            else
            {
                IncludeInBasketString = "בסל מוגבל";
            }
        }
        else
        {
            if (includeInBasket == 1)
            {
                IncludeInBasketString = "כלול בסל";
            }
            else
            {
                if (limiter > 0)
                {
                    IncludeInBasketString = "בסל מוגבל";
                }
                else
                {
                    IncludeInBasketString = "לא כלול בסל";
                }
            }
        }



        return IncludeInBasketString;
    }

    private string GetSynonymString(DataRow drServiceDetails)
    {
        string SynonymString = string.Empty;
        StringBuilder sbSynonyms = new StringBuilder();

        string synonym1 = drServiceDetails["Synonym1"].ToString();
        string synonym2 = drServiceDetails["Synonym2"].ToString();
        string synonym3 = drServiceDetails["Synonym3"].ToString();
        string synonym4 = drServiceDetails["Synonym4"].ToString();
        string synonym5 = drServiceDetails["Synonym5"].ToString();

        if (!string.IsNullOrEmpty(synonym1))
        {
            sbSynonyms.Append(synonym1);
        }

        if (!string.IsNullOrEmpty(synonym2))
        {
            if (sbSynonyms.Length > 0)
                sbSynonyms.Append("<br/>");

            sbSynonyms.Append(synonym2);
        }

        if (!string.IsNullOrEmpty(synonym3))
        {
            if (sbSynonyms.Length > 0)
                sbSynonyms.Append("<br/>");

            sbSynonyms.Append(synonym3);
        }

        if (!string.IsNullOrEmpty(synonym4))
        {
            if (sbSynonyms.Length > 0)
                sbSynonyms.Append("<br/>");

            sbSynonyms.Append(synonym4);
        }

        if (!string.IsNullOrEmpty(synonym5))
        {
            if (sbSynonyms.Length > 0)
                sbSynonyms.Append("<br/>");

            sbSynonyms.Append(synonym5);
        }

        return sbSynonyms.ToString();
    }

    private string GetOmriReturns(DataTable dtOmriReturns)
    {
        string OmriReturns = string.Empty;

        if (dtOmriReturns.Rows.Count > 0)
        {
            StringBuilder sbOmriReturns = new StringBuilder();
            for (int i = 0; i < dtOmriReturns.Rows.Count; i++)
            {
                DataRow drOmriReturns = dtOmriReturns.Rows[i];

                sbOmriReturns.Append(drOmriReturns["ReturnCode"]);
                sbOmriReturns.Append(" - ");
                sbOmriReturns.Append(drOmriReturns["ReturnDescription"]);
                sbOmriReturns.Append("<br />");
            }

            OmriReturns = sbOmriReturns.ToString();
        }

        return OmriReturns;
    }

    private string GetTemplateOutputClipForAdditionalEmployee(int licenseNumber)
    {
        string templateOutputClip;
        DoctorSearchParameters doctorSearchParameters = new DoctorSearchParameters();
        doctorSearchParameters.LicenseNumber = licenseNumber;
        doctorSearchParameters.CurrentReceptionTimeInfo = new SeferNet.BusinessLayer.BusinessObject.ReceptionTimeInfo();
        doctorSearchParameters.CurrentReceptionTimeInfo.OpenNow = false;
        doctorSearchParameters.CurrentSearchModeInfo = new SearchModeInfo();
        doctorSearchParameters.CurrentSearchModeInfo.IsCommunitySelected = true;
        doctorSearchParameters.CurrentSearchModeInfo.IsMushlamSelected = true;
        doctorSearchParameters.CurrentSearchModeInfo.IsHospitalsSelected = true;
        doctorSearchParameters.IsGetEmployeesReceptionInfo = true;
        doctorSearchParameters.MapInfo = new MapSearchInfo();

        SearchPagingAndSortingDBParams searchPagingAndSortingDBParams = new SearchPagingAndSortingDBParams(50, 1, 0, string.Empty);

        EmployeeDetailsDataTemplateInfo tmpInfo = Facade.getFacadeObject().GetDoctorTemplate(doctorSearchParameters, searchPagingAndSortingDBParams);
        HtmlTemplateDataManager templateManager = new HtmlTemplateDataManager(tmpInfo, templatePathAdditional);

        templateManager.EmptyFieldHtmlText = "&nbsp;";
        templateManager.Parse();

        templateOutputClip = templateManager.TemplateOutput;

        SetDisplayProperty(ref templateOutputClip);

        int currentPageRecords = tmpInfo.EmployeeDs.Tables[0].Rows.Count;
        string str = "<!--clipbegin-->";
        int indexBegin = templateOutputClip.IndexOf(str) + str.Length;
        str = "<!--clipend-->";
        int indexEnd = templateOutputClip.IndexOf(str);

        templateOutputClip = templateOutputClip.Substring(indexBegin, indexEnd - indexBegin);

        string newHeader = "פרטי נותן שירות נוסף";
        templateOutputClip = templateOutputClip.Replace("EmployeeListHeader", newHeader);
        //str = "<!--headerbegin-->";
        //indexBegin = templateOutputClip.IndexOf(str) + str.Length;
        //str = "<!--headerend-->";
        //indexEnd = templateOutputClip.IndexOf(str);

        //string subStringToReplace = templateOutputClip.Substring(indexBegin, indexEnd - indexBegin);
        //templateOutputClip = templateOutputClip.Replace(subStringToReplace, newHeader);
        //templateOutputClip = templateOutputClip.Replace("<!--headerbegin-->", string.Empty);
        //templateOutputClip = templateOutputClip.Replace("<!--headerend-->", string.Empty);

        return templateOutputClip;
    }

    private void SetDisplayProperty(ref string strContent)
    {
        String _displaySundayProperty = "";
        String _displayMondayProperty = "";
        String _displayTuesdayProperty = "";
        String _displayWednesdayProperty = "";
        String _displayThursdayProperty = "";
        String _displayFridayProperty = "";
        String _displaySaturdayProperty = "";
        String _displayHolHamoeedProperty = "";
        String _displayHolidayEveningProperty = "";
        String _displayHolidayProperty = "";


        EntityFrameworkHelper.ICacheWithEFService cache = ServicesManager.GetService<EntityFrameworkHelper.ICacheWithEFService>();
        _vReceptionDaysForDisplayList = cache.GetCacheEntities(eCachedTables.vReceptionDaysForDisplay.ToString()) as List<vReceptionDaysForDisplay>;

        _displaySundayProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.Sunday);
        _displayMondayProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.Monday);
        _displayTuesdayProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.Tuesday);
        _displayWednesdayProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.Wednesday);
        _displayThursdayProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.Thursday);
        _displayFridayProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.Friday);
        _displaySaturdayProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.Saturday);
        _displayHolHamoeedProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.HolHamoeed);
        _displayHolidayProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.Holiday);
        _displayHolidayEveningProperty = GetDayColumnDisplayProperty(eDIC_ReceptionDays.HolidayEvening);

        strContent = strContent.Replace("#DisplaySundayProperty#", _displaySundayProperty);
        strContent = strContent.Replace("#DisplayMondayProperty#", _displayMondayProperty);
        strContent = strContent.Replace("#DisplayTuesdayProperty#", _displayTuesdayProperty);
        strContent = strContent.Replace("#DisplayWednesdayProperty#", _displayWednesdayProperty);
        strContent = strContent.Replace("#DisplayThursdayProperty#", _displayThursdayProperty);
        strContent = strContent.Replace("#DisplayFridayProperty#", _displayFridayProperty);
        strContent = strContent.Replace("#DisplaySaturdayProperty#", _displaySaturdayProperty);
        strContent = strContent.Replace("#DisplayHolHamoeedProperty#", _displayHolHamoeedProperty);
        strContent = strContent.Replace("#DisplayHolidayProperty#", _displayHolidayProperty);
        strContent = strContent.Replace("#DisplayHolidayEveningProperty#", _displayHolidayEveningProperty);

        // Set the colspan of the remark td and the phone
        strContent = strContent.Replace("colspanRem", countHiddenDaysForEmployeeSector.ToString());
        strContent = strContent.Replace("colspanPhone", (countHiddenDaysForEmployeeSector + 3).ToString());

    }

    private string GetDayColumnDisplayProperty(eDIC_ReceptionDays day)
    {

        string retText = "none";
        vReceptionDaysForDisplay foundItem = _vReceptionDaysForDisplayList.Find(delegate(vReceptionDaysForDisplay itemToSearch)
        {
            return itemToSearch.ReceptionDayCode == (int)day;
        });

        if (foundItem != null)
        {
            retText = "Block";
        }
        else
        {
            int tmpTypeCode = (int)day;
            if (tmpTypeCode != 8 && tmpTypeCode != 9 && tmpTypeCode != 10)
            {
                countHiddenDaysForEmployeeSector--;
            }

        }

        return retText;
    }


    private bool GetEmployee_PageAndSearchParameters()
    {
        string tmpRow = "";
        int countParams = 0;

        if (HttpContext.Current.Session["doctorSearchParameters"] == null)
            return false;
        DoctorSearchParameters doctorSearchParameters = HttpContext.Current.Session["doctorSearchParameters"] as DoctorSearchParameters;

        SetLogoVisibility(doctorSearchParameters.CurrentSearchModeInfo.IsCommunitySelected, doctorSearchParameters.CurrentSearchModeInfo.IsMushlamSelected, doctorSearchParameters.CurrentSearchModeInfo.IsHospitalsSelected);

        if (!string.IsNullOrEmpty(doctorSearchParameters.EmployeeSectorDescription))
        {
            string employeeSectorDescription = doctorSearchParameters.EmployeeSectorDescription;
            tmpRow += "<div class='divParams'>" + "<b>סקטור</b>:&nbsp;&nbsp;" + employeeSectorDescription + "</div>";
            countParams++;

        }

        if (!string.IsNullOrEmpty(doctorSearchParameters.MapInfo.CityNameOnly))
        {
            tmpRow += "<div class='divParams'>" + "<b>ישוב</b>:&nbsp;&nbsp;" + doctorSearchParameters.MapInfo.CityNameOnly + "</div>";
            countParams++;
        }



        if (!string.IsNullOrEmpty(doctorSearchParameters.DistrictText))
        {
            tmpRow += "<div class='divParams'>" + "<b>מחוז</b>:&nbsp;&nbsp;" + doctorSearchParameters.DistrictText + "</div>";
            countParams++;
        }

        if (!string.IsNullOrEmpty(doctorSearchParameters.FirstName))
        {
            tmpRow += "<div class='divParams'>" + "<b>שם פרטי</b>:&nbsp;&nbsp;" + doctorSearchParameters.FirstName + "</div>";
            countParams++;
        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.LastName))
        {
            tmpRow += "<div class='divParams'>" + "<b>שם משפחה</b>:&nbsp;&nbsp;" + doctorSearchParameters.LastName + "</div>";
            countParams++;
        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (doctorSearchParameters.Status != null)
        {
            string statusDescription = getStatusDescription((int)doctorSearchParameters.Status);
            tmpRow += "<div class='divParams'>" + "<b>סטטוס</b>:&nbsp;&nbsp;" + statusDescription + "</div>";
            countParams++;
        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.ServiceText))
        {
            tmpRow += "<div class='divParams'>" + "<b>תחום שירות</b>:&nbsp;&nbsp;" + doctorSearchParameters.ServiceText + "</div>";
            countParams++;
        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.LanguageText))
        {
            tmpRow += "<div class='divParams'>" + "<b>שפות</b>:&nbsp;&nbsp;" + doctorSearchParameters.LanguageText + "</div>";
            countParams++;
        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.CurrentReceptionTimeInfo.ReceptionDays))
        {
            string daysDescription = doctorSearchParameters.CurrentReceptionTimeInfo.ReceptionDays;
            daysDescription = daysDescription.Replace('1', 'א').Replace('2', 'ב').Replace('3', 'ג').Replace('4', 'ד').Replace('5', 'ה').Replace('6', 'ו').Replace('7', 'ש').Replace(",", ", ");
            tmpRow += "<div class='divParams'>" + "<b>ימי פעילות</b>:&nbsp;&nbsp;" + daysDescription + "</div>";
            countParams++;

        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.ExpertProfession.ToString()))
        {
            string expertProfession = doctorSearchParameters.ExpertProfession.ToString();
            expertProfession = expertProfession.Replace("1", "מומחה").Replace("2", "לא מומחה");
            tmpRow += "<div class='divParams'>" + "<b>מומחיות</b>:&nbsp;&nbsp;" + expertProfession + "</div>";
            countParams++;

        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.PositionDescription))
        {
            string positionDescription = doctorSearchParameters.PositionDescription;
            tmpRow += "<div class='divParams'>" + "<b>תפקיד</b>:&nbsp;&nbsp;" + positionDescription + "</div>";
            countParams++;

        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (doctorSearchParameters.AgreementType != null)
        {
            string agreementTypeDescription = getAgreementTypeDescription((int)doctorSearchParameters.AgreementType);
            tmpRow += "<div class='divParams'>" + "<b>סוג הסכם</b>:&nbsp;&nbsp;" + agreementTypeDescription + "</div>";
            countParams++;

        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (doctorSearchParameters.Sex != null)
        {
            string genderDescription = getGenderDescription((int)doctorSearchParameters.Sex);
            tmpRow += "<div class='divParams'>" + "<b>מגדר</b>:&nbsp;&nbsp;" + genderDescription + "</div>";
            countParams++;

        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.HandicappedFacilitiesDescriptions))
        {
            tmpRow += "<div class='divParams'>" + "<b>הערכות לנכים</b>:&nbsp;&nbsp;" + doctorSearchParameters.HandicappedFacilitiesDescriptions + "</div>";
            countParams++;
        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.CurrentReceptionTimeInfo.FromHour))
        {
            tmpRow += "<div class='divParams'>" + "<b>פעיל מ</b>:&nbsp;&nbsp;" + doctorSearchParameters.CurrentReceptionTimeInfo.FromHour + "</div>";
            countParams++;
        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.CurrentReceptionTimeInfo.ToHour))
        {
            tmpRow += "<div class='divParams'>" + "<b>עד</b>:&nbsp;&nbsp;" + doctorSearchParameters.CurrentReceptionTimeInfo.ToHour + "</div>";
            countParams++;
        }

        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);

        if (!string.IsNullOrEmpty(doctorSearchParameters.CurrentReceptionTimeInfo.InHour))
        {
            tmpRow += "<div class='divParams'>" + "<b>פעיל בשעה</b>:&nbsp;&nbsp;" + doctorSearchParameters.CurrentReceptionTimeInfo.InHour + "</div>";
            countParams++;
        }

        countParams = 4;
        checkIfNeedToInsertIntoRow(ref tmpRow, ref countParams);
        return true;

    }

    private string getAgreementTypeDescription(int agreementType)
    {
        string agreementTypeDescription = string.Empty;
        switch (agreementType)
        {
            case 1:
                agreementTypeDescription = "קהילה";
                break;
            case 2:
                agreementTypeDescription = "עצמאי בקהילה";
                break;
        }

        return agreementTypeDescription;
    }

    private string getGenderDescription(int gender)
    {
        string genderDescription = string.Empty;
        switch (gender)
        {
            case 1:
                genderDescription = "גבר";
                break;
            case 2:
                genderDescription = "אישה";
                break;
        }

        return genderDescription;
    }

    private string getStatusDescription(int status)
    {
        string statusDescription = string.Empty;
        switch (status)
        {
            case 0:
                statusDescription = "לא פעיל";
                break;
            case 1:
                statusDescription = "פעיל";
                break;
            case 2:
                statusDescription = "לא פעיל זמנית";
                break;
        }

        return statusDescription;
    }

    private void checkIfNeedToInsertIntoRow(ref string rowControls, ref int controlCounter)
    {
        if (controlCounter == 4)
        {
            searchParameters += "<tr><td class='tdParams'>";
            searchParameters += rowControls;
            searchParameters += "</td></tr>";
            rowControls = "";
            controlCounter = 0;
        }

    }

    private void SetLogoVisibility(bool? IsCommunitySelected, bool? IsMushlamSelected, bool? IsHospitalsSelected)
    {
        string path = string.Empty;
        string[] pathSegments = Server.MapPath(".").Split('\\');
        for (int i = 0; i < pathSegments.Length - 1; i++)
        {
            path += pathSegments[i] + '\\';
        }

        if ((IsCommunitySelected == true && IsMushlamSelected == true)
            ||
            (IsHospitalsSelected == true && IsMushlamSelected == true))
        {
            showClalitLogo = true;
            showClalitAndMushlamLogo = true;
        }
        else if (IsCommunitySelected == true || IsHospitalsSelected == true)
        {
            showClalitLogo = true;
        }
        else if (IsMushlamSelected == true)
        {
            showClalitAndMushlamLogo = true;
        }

        if (showClalitLogo)
        {
            clalitLogo = "<img src='" + clalitLogoImage_FullPath + "'/>";
            clalitLogo_email = "<img src='cid:clalitLogoImageId' />";
        }
        if (showClalitAndMushlamLogo)
        {
            clalitAndMushlamLogo = "<img src='" + clalitAndMushlamLogoImage_FullPath + "'/>";
            clalitAndMushlamLogo_email = "<img src='cid:clalitAndMushlamLogoImageId' />";
        }
    }

    private bool GetDeptList_PageAndSearchParameters()
    {
        string tdOpenLbl = "<td class='tdNorm' style='width:8%; padding-right:5px'>";
        string tdOpenVal = "<td class='tdBold' style='width:25.3%; '>";
        string tdClose = "</td>";
        int currentPageForPrinting = 1;

        deptCodesList = string.Empty;


        ClinicSearchParameters clinicSearchParameters = new ClinicSearchParameters();
        SortingAndPagingParameters sortingAndPagingParameters = new SortingAndPagingParameters();

        if (Session["clinicSearchParameters"] == null || Session["SortingAndPagingParameters"] == null)
            return false;

        clinicSearchParameters = (ClinicSearchParameters)Session["clinicSearchParameters"];
        sortingAndPagingParameters = HttpContext.Current.Session["SortingAndPagingParameters"] as SortingAndPagingParameters;

        SetLogoVisibility(clinicSearchParameters.CurrentSearchModeInfo.IsCommunitySelected, clinicSearchParameters.CurrentSearchModeInfo.IsMushlamSelected, clinicSearchParameters.CurrentSearchModeInfo.IsHospitalsSelected);

        SearchPagingAndSortingDBParams searchPagingAndSortingDBParams
            = new SearchPagingAndSortingDBParams(MaxRecordsToPrint, currentPageForPrinting, sortingAndPagingParameters.SortingOrder, sortingAndPagingParameters.OrderBy);

        Facade applicFacade = Facade.getFacadeObject();
        ClinicSearchParametersForMushlamServices clinicSearchParametersForMushlamServices = new ClinicSearchParametersForMushlamServices();

        DataSet dsClinics = applicFacade.getClinicList_PagedSorted(clinicSearchParameters, clinicSearchParametersForMushlamServices, searchPagingAndSortingDBParams);

        string totalRecords = dsClinics.Tables[1].Rows[0][0].ToString();
        int tRecords = Convert.ToInt32(totalRecords);

        foreach (DataRow dr in dsClinics.Tables[0].Rows)
        {
            if (deptCodesList != string.Empty)
                deptCodesList += ',';
            deptCodesList += dr["deptCode"].ToString();
        }
        // Paging
        int tPages = tRecords / pageSize;
        if ((Convert.ToDecimal(tRecords) / pageSize) > tPages)
            tPages = tPages + 1;

        if (tRecords > 0)
            //pagingInfo = " נמצאו " + totalRecords + " רשומות " + " ( עמוד "
            //    + sortingAndPagingParameters.CurrentPage.ToString() + " מתוך "
            //    + tPages.ToString() + " )";
            pagingInfo = " נמצאו " + totalRecords + " רשומות ";
        else
            pagingInfo = " נמצאו " + totalRecords + " רשומות ";

        pagingInfo += ExceedingMaxOfRecordsExclamation(tRecords);

        int cellCount = 0;

        if (clinicSearchParameters.DeptName != null && clinicSearchParameters.DeptName != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "שם&nbsp;יחידה:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.DeptName + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.DistrictText != null && clinicSearchParameters.DistrictText != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "מחוז:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.DistrictText.Replace(" ", "&nbsp;").Replace(",", ", ") + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.MapInfo.CityNameOnly != null)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "ישוב:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.MapInfo.CityNameOnly + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.MapInfo.Neighborhood != null)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "שכונה:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.MapInfo.Neighborhood + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.MapInfo.Street != null && clinicSearchParameters.MapInfo.Street != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "רחוב:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.MapInfo.Street + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.MapInfo.Site != null)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "אתר:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.MapInfo.Site + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.MapInfo.House != null && clinicSearchParameters.MapInfo.House != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "בית:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.MapInfo.House + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.ServiceDescriptions != null && clinicSearchParameters.ServiceDescriptions != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "מקצוע:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.ServiceDescriptions + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.UnitTypeNames != null && clinicSearchParameters.UnitTypeNames != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "סוג&nbsp;יחידה:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.UnitTypeNames + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.SubUnitTypeCodes != null && clinicSearchParameters.SubUnitTypeCodes != "0")
        {
            string subTypeName = string.Empty;
            switch (clinicSearchParameters.SubUnitTypeCodes)
            {
                case "1":
                    subTypeName = "עצמאית";
                    break;
                case "2":
                    subTypeName = "פרטי בהסכם";
                    break;
                case "3":
                    subTypeName = "משרד הבריאות";
                    break;
            }
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "שיוך:" + tdClose;
            searchParameters += tdOpenVal + subTypeName + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.HandicappedFacilitiesDescriptions != null && clinicSearchParameters.HandicappedFacilitiesDescriptions != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "הערכות לנכים:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.HandicappedFacilitiesDescriptions.Replace(" ", "&nbsp;").Replace(",", ", ") + tdClose;
            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.PopulationSectorCode != null && clinicSearchParameters.PopulationSectorCode != 0)
        {
            string description = string.Empty;
            switch (clinicSearchParameters.PopulationSectorCode)
            {
                case 1:
                    description = "כללי";
                    break;
                case 2:
                    description = "חרדים";
                    break;
                case 3:
                    description = "מיעוטים";
                    break;
                case 4:
                    description = "עולים";
                    break;
            }

            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "מגזר:" + tdClose;
            searchParameters += tdOpenVal + description + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.CodeSimul != null && clinicSearchParameters.CodeSimul != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "קוד סימול:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.CodeSimul + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.Status != null && clinicSearchParameters.Status != -1)
        {
            string description = getStatusDescription((int)clinicSearchParameters.Status);

            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "סטטוס:" + tdClose;
            searchParameters += tdOpenVal + description + tdClose;

            if (cellCount == 2 || cellCount == 5 || cellCount == 8 || cellCount == 11)
                searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.CurrentReceptionTimeInfo.ReceptionDays != null && clinicSearchParameters.CurrentReceptionTimeInfo.ReceptionDays != string.Empty)
        {
            string description = clinicSearchParameters.CurrentReceptionTimeInfo.ReceptionDays;
            description = description.Replace('1', 'א').Replace('2', 'ב').Replace('3', 'ג').Replace('4', 'ד').Replace('5', 'ה').Replace('6', 'ו').Replace('7', 'ש').Replace(",", ", ");

            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "ימי פעילות:" + tdClose;
            searchParameters += tdOpenVal + description + tdClose;

            if (cellCount == 2 || cellCount == 5 || cellCount == 8 || cellCount == 11)
                searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.CurrentReceptionTimeInfo.FromHour != null && clinicSearchParameters.CurrentReceptionTimeInfo.FromHour != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "פעיל מ:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.CurrentReceptionTimeInfo.FromHour + tdClose;

            if (cellCount == 2 || cellCount == 5 || cellCount == 8 || cellCount == 11)
                searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.CurrentReceptionTimeInfo.ToHour != null && clinicSearchParameters.CurrentReceptionTimeInfo.ToHour != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "פעיל עד:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.CurrentReceptionTimeInfo.ToHour + tdClose;

            if (cellCount == 2 || cellCount == 5 || cellCount == 8 || cellCount == 11)
                searchParameters += "</tr>";
            cellCount++;
        }

        if (clinicSearchParameters.CurrentReceptionTimeInfo.InHour != null && clinicSearchParameters.CurrentReceptionTimeInfo.InHour != string.Empty)
        {
            if (TrueCell(cellCount, 0)) searchParameters += "<tr>";
            searchParameters += tdOpenLbl + "פעיל בשעה:" + tdClose;
            searchParameters += tdOpenVal + clinicSearchParameters.CurrentReceptionTimeInfo.InHour + tdClose;

            if (TrueCell(cellCount, 2)) searchParameters += "</tr>";
            cellCount++;
        }



        //if (cellCount == 1 || cellCount == 4 || cellCount == 7 || cellCount == 10 || cellCount == 13)
        //    searchParameters += tdOpenLbl + "&nbsp;" + tdClose + tdOpenVal + "&nbsp;" + tdClose + tdOpenLbl + "&nbsp;" + tdClose + tdOpenVal + "&nbsp;" + tdClose + "</tr>";
        //if (cellCount == 2 || cellCount == 5 || cellCount == 8 || cellCount == 11 || cellCount == 14)
        //    searchParameters += tdOpenLbl + "&nbsp;" + tdClose + tdOpenVal + "&nbsp;" + tdClose + "</tr>";
        //return true;

        if (TrueCell(cellCount, 1))
            searchParameters += tdOpenLbl + "&nbsp;" + tdClose + tdOpenVal + "&nbsp;" + tdClose + tdOpenLbl + "&nbsp;" + tdClose + tdOpenVal + "&nbsp;" + tdClose + "</tr>";
        if (TrueCell(cellCount, 2))
            searchParameters += tdOpenLbl + "&nbsp;" + tdClose + tdOpenVal + "&nbsp;" + tdClose + "</tr>";
        return true;
    }

    private bool TrueCell(int currCell, int startingCell)
    {
        if (((currCell - startingCell) / 3) * 3 == (currCell - startingCell))
            return true;
        else
            return false;
    }

    private string GetSearchParameters()
    {
        ClinicSearchParameters clinicSearchParameters = new ClinicSearchParameters();
        if (Session["clinicSearchParameters"] == null)
            return string.Empty;

        clinicSearchParameters = (ClinicSearchParameters)Session["clinicSearchParameters"];

        return string.Empty;
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSendFax_Click(object sender, System.EventArgs e)
    {
        if (!string.IsNullOrEmpty((txtSendToFax.Text)))
        {
            SendMessage msg = new SendMessage();

            string body = ltlContent.Text;

            if (body.IndexOf(clalitLogo) > 0)
                body = body.Replace(clalitLogo, string.Empty);

            if (body.IndexOf(clalitAndMushlamLogo) > 0)
                body = body.Replace(clalitAndMushlamLogo, string.Empty);

            HTMLFileInfoResult result = HTMLFileTemplateHelper.GetAdjustedHtmlInfo(body, ConstsLangage.HEBREW_ENCODING_HTML);

            body = result.HtmlBody_Modified;
            int indexFrom = body.IndexOf("<!DOCTYPE");
            int indexTo = body.IndexOf("html>");
            string bodyShort = body.Substring(indexFrom, indexTo - indexFrom + "html>".Length);



            string SendToFax = string.Empty;
            string userName = string.Empty;

            try
            {
                SendToFax = "+972-" + txtSendToFax.Text.Substring(1, txtSendToFax.Text.Length - 1);
                msg.SendFax(bodyShort, SendToFax, result.FileMediaTypeForInterfax, userName);

                txtSendToFax.Text = string.Empty;
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();

                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInSendingFax),
                  new WebPageExtraInfoGenerator());
            }
        }
    }

    public const string HEBREW_ENCODING_HTML = "iso-8859-8-i";
    protected void btnSendEmail_Click(object sender, System.EventArgs e)
    {
        string subject = string.Empty;
        string toAddress = txtSendEmailTo.Text;
        Dictionary<string, string> linkedResources = new System.Collections.Generic.Dictionary<string, string>(); // ImageID, ImagePath
        //HTMLFileInfoResult result = HTMLFileTemplateHelper.GetAdjustedHtmlInfo(ltlContent.Text, ConstsLangage.HEBREW_ENCODING_HTML);
        //string body = result.HtmlBody_Modified;
        string body = ltlContent.Text;

        subject += body.Substring(body.IndexOf("<title>") + "<title>".Length, body.IndexOf("</title>") - body.IndexOf("<title>") - "<title>".Length);
        body = body.Substring(body.IndexOf("<!DOCTYPE"), body.IndexOf("</html>") - body.IndexOf("<!DOCTYPE") + 7);
        //body = body.Substring(body.IndexOf("<body>") + "<body>".Length, body.IndexOf("</body>") - body.IndexOf("<body>") - "<body>".Length);

        //result.HtmlFileExtension = "mht";
        string path = string.Empty;
        string[] pathSegments = Server.MapPath(".").Split('\\');
        for (int i = 0; i < pathSegments.Length - 1; i++)
        {
            path += pathSegments[i] + '\\';
        }

        if (body.IndexOf(clalitLogo) > 0)
        {
            body = body.Replace(clalitLogo, clalitLogo_email);
            linkedResources.Add("clalitLogoImageId", clalitLogoImage_FullPath);
        }
        if (body.IndexOf(clalitAndMushlamLogo) > 0)
        {
            body = body.Replace(clalitAndMushlamLogo, clalitAndMushlamLogo_email);
            linkedResources.Add("clalitAndMushlamLogoImageId", clalitAndMushlamLogoImage_FullPath);
        }


        body = GetSimplifiedHTML(body);

        try
        {
            EmailHandler.SendEmailFromDefaultAddress(subject, body, toAddress, string.Empty, string.Empty, string.Empty, Encoding.GetEncoding(ConstsLangage.HEBREW_ENCODING_HTML), linkedResources);
        }
        catch (Exception ex)
        {
            ExceptionHandlingManager mgr = new ExceptionHandlingManager();

            mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInSendingEmail),
              new WebPageExtraInfoGenerator());
        }

        txtSendEmailTo.Text = string.Empty;
    }

    #endregion

    #region simplify HTML
    private string GetSimplifiedHTML(string inputHTML)
    {
        string retString = string.Empty;
        Dictionary<string, string> dicStyles = new Dictionary<string, string>();
        string strStyles = string.Empty;
        string strBody = string.Empty;

        inputHTML.Trim();

        strStyles = inputHTML.Substring(inputHTML.IndexOf("<head>") + "<head>".Length, inputHTML.IndexOf("</head>") - inputHTML.IndexOf("<head>"));
        strStyles = strStyles.Substring(strStyles.IndexOf("<style"), strStyles.IndexOf("</style>") - strStyles.IndexOf("<style"));
        strStyles = strStyles.Substring(strStyles.IndexOf(">") + 1, strStyles.Length - strStyles.IndexOf(">") - 1);
        strStyles = strStyles.Replace("\r\n", " ").Replace("\t", " ").Replace("   ", " ").Replace("   ", " ").Replace("  ", " ").Replace(": ", ":");

        strBody = inputHTML.Substring(inputHTML.IndexOf("<body>") + "<body>".Length, inputHTML.IndexOf("</body>") - inputHTML.IndexOf("<body>") - "<body>".Length);

        strBody = strBody.Replace("<span style='color:Red'>Not mapped correctly!!!</span>", string.Empty);

        //return strBody;

        string[] arrStrStyles = strStyles.Split('}');
        foreach (string str in arrStrStyles)
        {
            string[] strKeyValue = str.Split('{');
            if (strKeyValue[0].Trim() != string.Empty && strKeyValue[1].Trim() != string.Empty)
            {
                dicStyles.Add(strKeyValue[0].Replace('.', ' ').Trim(), strKeyValue[1].Trim());
            }
        }

        string[] arrStrBody = strBody.Split('>');
        int classStartIndex;
        int classEndIndex;
        string strSepar;

        for (int n = 0; n < arrStrBody.Length; n++)
        {

            if (arrStrBody[n].IndexOf("class") >= 0)
            {
                string[] strTMP = Regex.Split(arrStrBody[n], "class");
                string[] strClass = strTMP[1].Replace('=', ' ').Trim().Split(' ');
                strClass[0] = strClass[0].Substring(1, strClass[0].Length - 2);

                if (dicStyles.ContainsKey(strClass[0]))
                {
                    if (arrStrBody[n].IndexOf("style") >= 0)
                    {
                        string[] strDivByStyle = Regex.Split(arrStrBody[n], "style");
                        strDivByStyle[1] = strDivByStyle[1].Replace("  ", " ").Replace(" =", "=").Replace("= ", "=");
                        strDivByStyle[1] = strDivByStyle[1].Insert(strDivByStyle[1].IndexOf('=') + 2, dicStyles[strClass[0]]);
                        arrStrBody[n] = strDivByStyle[0] + "style" + strDivByStyle[1];
                    }
                    else
                    {
                        arrStrBody[n] = arrStrBody[n] + " style='" + dicStyles[strClass[0]] + "'";
                    }
                }

                // remove "class" attribute
                classStartIndex = arrStrBody[n].IndexOf("class=");
                strSepar = arrStrBody[n].Substring(classStartIndex + "class=".Length, 1);
                classEndIndex = arrStrBody[n].IndexOf(strSepar, classStartIndex + "class=".Length + 1);

                if (classEndIndex > 0)
                    arrStrBody[n] = arrStrBody[n].Remove(classStartIndex - 1, classEndIndex - classStartIndex + 2);

            }

            if (arrStrBody[n].IndexOf('<') >= 0)
                arrStrBody[n] = arrStrBody[n] + '>';
        }

        int i = 0;
        string strTagName = string.Empty;
        string strNextTagName = string.Empty;
        int sameTagNameCount = 0;

        while (i < arrStrBody.Length)
        {

            // remove tags and their content where exists "display:none"
            if (arrStrBody[i].IndexOf("display:none") >= 0)
            {
                string[] arrSubStrBody = arrStrBody[i].Split('<');

                strTagName = arrSubStrBody[1].Substring(0, arrSubStrBody[1].IndexOf(' '));
                sameTagNameCount = 0;

                while (strTagName != string.Empty)
                {
                    i = i + 1;

                    string[] arrInnerSubStrBody = arrStrBody[i].Split('<');
                    strNextTagName = arrInnerSubStrBody[1].Substring(0, arrSubStrBody[1].IndexOf(' '));

                    if (strTagName == strNextTagName) // there's a tag of the same type inside the tag
                        sameTagNameCount = sameTagNameCount + 1;

                    if (arrStrBody[i].IndexOf("</" + strTagName) >= 0)
                    {
                        if (sameTagNameCount > 0)
                            sameTagNameCount = sameTagNameCount - 1;
                        else
                            strTagName = string.Empty;                
                    }
                }

                i = i + 1;
            }

            //replace tag with symbol "telephone" with text "טלפון במרפאה"
            else if (arrStrBody[i].IndexOf("Wingdings") >= 0)
            {
                string[] arrSubStrBody = arrStrBody[i].Split('<');

                strTagName = arrSubStrBody[1].Substring(0, arrSubStrBody[1].IndexOf(' '));

                while (strTagName != string.Empty)
                {
                    i = i + 1;
                    if (arrStrBody[i].IndexOf("</" + strTagName) >= 0)
                    {
                        strTagName = string.Empty;
                    }
                }

                i = i + 1;
                retString = retString + "<span>" + " טלפון במרפאה " + "</span>";
            }
            else
            {
                if (arrStrBody[i].IndexOf("<!--") < 0)
                    retString = retString + arrStrBody[i];
                i++;
            }
        }

        //clining
        retString = retString.Replace("display:Block;", string.Empty);
        retString = retString.Replace(" >", ">");
        retString = retString.Replace("border:none;", string.Empty);

        if (dicStyles.ContainsKey("body"))
        {
            retString = "<div style='" + dicStyles["body"] + "'>" + retString + "</div>";
        }

        retString = retString.Replace("; ", ";").Replace(";;", ";");

        return retString;
    }

    #endregion

    protected string Path
    {
        get { return (string)ViewState["Path"]; }
    }

    //protected string Subject
    //{
    //    get
    //    {
    //        if (Request.QueryString["action"] != null && Request.QueryString["action"].ToUpper() == "PRINT")
    //            return (string)ViewState["FileName"] + Request.QueryString[eAppliesEnum.ApplyId.ToString()];

    //        return string.Format("{0} לבקשה מספר {1}", (string)ViewState["FileName"], Request.QueryString[eAppliesEnum.ApplyId.ToString()]);
    //    }
    //}

}


