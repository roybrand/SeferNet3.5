using Clalit.Exceptions.ExceptionData;
using Clalit.SeferNet.GeneratedEnums;
using Matrix.ExceptionHandling;
using SeferNet.FacadeLayer;
using SeferNet.UI.Apps.RSWS;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ReportsSearchResult_CreateExcel : System.Web.UI.Page
{
    readonly string webUserName = ConfigurationSettings.AppSettings["WebUserName"];
    readonly string webUserPassword = ConfigurationSettings.AppSettings["WebUserPwd"];
    readonly string webUserDomain = ConfigurationSettings.AppSettings["WebUserDomain"];
    readonly string url_ReportExecutionService = ConfigurationSettings.AppSettings["ReportExecution2005"];
    readonly string reportServerFolder = ConfigurationManager.AppSettings["ReportServerFolder"];
    readonly string reportExcelNameExtantion = "Excel";
    readonly string param_IsExcelVersion_name = "IsExcelVersion";
    string CurrentReportName = String.Empty;
    string CurrentReportTitle = String.Empty;
    int CurrentReport = 0;

    string[] SelectedFields;

    Hashtable ParamsWhere;

    MemoryStream ms;

    #region Properties

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        BuildExcelReport();
    }

    protected void btnExcel_Click(object sender, EventArgs e)
    {
        BuildExcelReport();
    }

    private void BuildExcelReport()
    {
        try
        {
            CurrentReport = Convert.ToInt32(Session["reportNum"]);

            if (CurrentReport == 100)
            {
                CurrentReportName = Session["reportName"].ToString();
                CurrentReportTitle = HttpUtility.UrlEncode("הדפסת_תוצאות_חיפוש", Encoding.UTF8);
            }
            else if (CurrentReport == 101)
            {
                CurrentReportName = Session["reportName"].ToString();
                CurrentReportTitle = HttpUtility.UrlEncode("הדפסת_תוצאות_חיפוש", Encoding.UTF8);
            }

            //Session["reportNum"]

            ParamsWhere = (Hashtable)Session["ParamsWhere"];
            SelectedFields = (string[])Session["SelectedFields"];

            ExecutionInfo execInfo = new ExecutionInfo();

            ICredentials webCredentials = new NetworkCredential(this.webUserName, this.webUserPassword, this.webUserDomain);

            ReportExecutionService executService = new ReportExecutionService();
            executService.Credentials = webCredentials;// System.Net.CredentialCache.DefaultCredentials;

            ExecutionHeader execHeader = new ExecutionHeader();
            executService.ExecutionHeaderValue = execHeader;

            executService.Url = this.url_ReportExecutionService;
            executService.Timeout = System.Threading.Timeout.Infinite;

            // Render arguments
            byte[] result = null;
            string reportPath = "/" + reportServerFolder + "/" + this.CurrentReportName + this.reportExcelNameExtantion;
            //string reportPath = "/" + reportServerFolder + "/" + this.CurrentReportTitle + this.reportExcelNameExtantion;

            string format = "Excel";
            string historyID = null;
            string devInfo = @"<DeviceInfo><Toolbar>False</Toolbar></DeviceInfo>";

            // Prepare report parameter.
            ParameterValue[] parameters = this.BuilExcelReportParameters();

            //DataSourceCredentials[] credentials = null;
            //string showHideToggle = null;
            string encoding;
            string mimeType;
            string extension;
            Warning[] warnings = null;
            string[] streamIDs = null;

            ms = new MemoryStream();

            execInfo = executService.LoadReport(reportPath, historyID);
            execInfo = executService.SetExecutionParameters(parameters, "en-us");

            result = executService.Render(format, devInfo, out extension, out encoding, out mimeType, out warnings, out streamIDs);
            execInfo = executService.GetExecutionInfo();

            ms.Write(result, 0, result.Length);

            string reportTime = DateTime.Now.ToString().Substring(11, 2) + '-' + DateTime.Now.ToString().Substring(14, 2) + '_' + DateTime.Now.ToString().Substring(0, 10);

            reportTime = reportTime.Replace("/", "-").Replace(" ", "_");
            string filename = this.CurrentReportTitle + "_" + reportTime;

            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", string.Format("attachment; filename = {0}.xls;", filename));

            Response.OutputStream.Write(ms.GetBuffer(), 0, Convert.ToInt32(ms.Length));
            Response.Flush();

            HttpContext.Current.Response.SuppressContent = true;  // Gets or sets a value indicating whether to send HTTP content to the client.
            HttpContext.Current.ApplicationInstance.CompleteRequest(); // Causes ASP.NET to bypass all events and filtering in the HTTP pipeline chain of execution and directly execute the EndRequest event.

            //HttpApplication httpApplication = new HttpApplication();
            //httpApplication.CompleteRequest();
            //Response.Close();
            //Response.End(); 
        }
        catch (Exception exception)
        {
            ExceptionHandlingManager mgr = new ExceptionHandlingManager();
            mgr.Publish(exception, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMainMenuData),
            new WebPageExtraInfoGenerator());

            sendErrorToEmail("ReportsSearchResult_CreateExcel.BuildExcelReport", exception.ToString());
        }
        finally
        {
            ms.Close();
        }
    }

    private ParameterValue[] BuilExcelReportParameters()
    {
        Dictionary<string, string> paramsDic = null;
        ParameterValue[] rpParams = null;

        paramsDic = this.BuildReportParamsDic(ParamsWhere, SelectedFields, true);

        if (paramsDic != null && paramsDic.Count > 0)
        {
            rpParams = new ParameterValue[paramsDic.Count];//[paramsDic.Count + 1]
            int i = 0;
            foreach (KeyValuePair<string, string> param in paramsDic)
            {
                rpParams[i] = new ParameterValue();//
                rpParams[i].Name = param.Key;
                rpParams[i].Value = param.Value;
                i++;
            }
        }
        //ParameterValue param_IsExcelVersion = new ParameterValue();
        //param_IsExcelVersion.Name = this.param_IsExcelVersion_name;
        //param_IsExcelVersion.Value = "1";
        //rpParams.[rpParams.Length - 1] = param_IsExcelVersion;

        return rpParams;
    }

    private Dictionary<string, string> BuildReportParamsDic(Hashtable prmWhere, string[] prmSelectedFields, bool isExcelVersion)
    {
        IDictionaryEnumerator enm = prmWhere.GetEnumerator();
        Dictionary<string, string> rsParams = new Dictionary<string, string>();

        // ----- WhereParameters
        if (enm != null)
        {
            while (enm.MoveNext())
            {
                string key = enm.Key.ToString();
                string value = enm.Value.ToString();

                if (String.IsNullOrEmpty(value))
                    value = "-1";

                if (!rsParams.ContainsKey(key))
                    rsParams.Add(key, value);
            }
        }

        //------- SelectedFields 
        if (prmSelectedFields != null && prmSelectedFields.Length > 0)
        {
            foreach (string column in prmSelectedFields)
            {
                if (!rsParams.ContainsKey(column))
                    rsParams.Add(column, "1");
            }
        }


        //string isExcelVersionParamValue = "0";
        //if (isExcelVersion)
        //{
        //    isExcelVersionParamValue = "1";
        //}
        //rsParams.Add(this.param_IsExcelVersion_name, isExcelVersionParamValue);

        return rsParams;
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

    private bool isEmailValid(string email)
    {
        Regex regex = new Regex(@"^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$");
        Match match = regex.Match(email);
        if (match.Success) return true;
        else return false;
    }
}
