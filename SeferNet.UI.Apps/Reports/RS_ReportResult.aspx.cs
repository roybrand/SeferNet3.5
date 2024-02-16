using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.UI.Apps.RSWS;
using System.Collections;
using SeferNet.FacadeLayer;
using System.Data;
using System.Configuration;
using System.Web.Services.Protocols;
using Microsoft.Reporting;
using System.Net;
using System.IO;
using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using Clalit.SeferNet.GeneratedEnums;

public partial class Reports_RS_ReportResult : System.Web.UI.Page
{
    //excel http://ryanfarley.com/blog/archive/2006/01/27/15689.aspx
    //http://www.mindfiresolutions.com/How-to-add-dynamic-data-in-to-the-SQL-Report-header-and-footer-383.php
    //http://www.ssw.com.au/ssw/standards/rules/rulestobetterSQlreportingservices.aspx
   
    private int _currentReport = 1;
    private Hashtable _hTblParamsWhere = null;
    private string[] _selectedReportFields = null;
    private string _urlReportServer = ConfigurationManager.AppSettings["ReportServerUrl"].ToString() + "/Pages/ReportViewer.aspx?%2f" + ConfigurationManager.AppSettings["ReportServerFolder"].ToString() + "%2f";

    readonly string webUserName = ConfigurationSettings.AppSettings["WebUserName"];
    readonly string webUserPassword = ConfigurationSettings.AppSettings["WebUserPwd"];
    readonly string webUserDomain = ConfigurationSettings.AppSettings["WebUserDomain"];
    readonly string url_ReportExecutionService = ConfigurationSettings.AppSettings["ReportExecution2005"];
    readonly string reportServerFolder = ConfigurationManager.AppSettings["ReportServerFolder"];
    readonly string param_IsExcelVersion_name = "IsExcelVersion";
    readonly string reportExcelNameExtantion = "Excel";
    private string _currentReportTitle = String.Empty;
    private string _currentReportName = String.Empty;
    private Microsoft.Reporting.WebForms.ReportParameter[]  _reportParams = null;
    
    #region Properties



    public Microsoft.Reporting.WebForms.ReportParameter[] ReportParams
    {
        get
        {
            if (ViewState["ReportParams"] != null)
            {
                _reportParams = ViewState["ReportParams"] as Microsoft.Reporting.WebForms.ReportParameter[];
            }
            return _reportParams;
        }
        set
        {
            ViewState["ReportParams"] = value;
        }
    }


    public int CurrentReport
    {
        get
        {
            if (ViewState["CurrentReport"] != null)
            {
                _currentReport = int.Parse(ViewState["CurrentReport"].ToString());
            }
            return _currentReport;
        }
        set
        {
            ViewState["CurrentReport"] = value;
        }
    }

    public string  CurrentReportName
    {
        get
        {
            if (ViewState["CurrentReportName"] != null)
            {
                _currentReportName = ViewState["CurrentReportName"].ToString();
            }
            return _currentReportName;
        }
        set
        {
            ViewState["CurrentReportName"] = value;
        }
    }

    public string  CurrentReportTitle
    {
        get
        {
            if (ViewState["CurrentReportTitle"] != null)
            {
                _currentReportTitle = ViewState["CurrentReportTitle"].ToString();
            }
            return _currentReportTitle;
        }
        set
        {
            ViewState["CurrentReportTitle"] = value;
        }
    }

    public Hashtable WhereParams
    {
        get
        {
            if (ViewState["ParamsWhere"] != null)
            {
                _hTblParamsWhere = (Hashtable)ViewState["ParamsWhere"];
            }
            return _hTblParamsWhere;
        }
        set
        {
            ViewState["ParamsWhere"] = value;
        }
    }
    
    public string[] GetSelectedFields
    {
        get
        {
            if (ViewState["SelectedReportFields"] != null)
                return (string[])ViewState["SelectedReportFields"];
            else
                return null;
        }
        set
        {
            _selectedReportFields = value;
            if (_selectedReportFields != null && _selectedReportFields.Length > 0)
            {
                ViewState["SelectedReportFields"] = _selectedReportFields;
            }
        }
    }    

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (PreviousPage != null)
            {                              
                this.CurrentReport = PreviousPage.GetSelectedReportID;
                if ( this.CurrentReport > -1)
                {
                    GetReportDetails(this.CurrentReport);
                }
                this.WhereParams = PreviousPage.ParamsWhere;
                //get fields , that were selected in previous page 
                this.GetSelectedFields = GetPreviousPageSelectedFields();               
            }

            ViewReport("/" + reportServerFolder + "/" +this.CurrentReportName);                                  
        }
        this.Title = this.CurrentReportTitle;
    }

    private void GetReportDetails(int p_CurrentReport)
    {
        try
        {
            Facade applicFacade = Facade.getFacadeObject();
            DataSet ds = null;
            applicFacade.GetReportDetails(ref ds, p_CurrentReport);

            if (ds != null && ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0)
	        {
                this.CurrentReportTitle = ds.Tables[0].Rows[0]["reportTitle"].ToString();
                this.Title = this.CurrentReportTitle;
                this.CurrentReportName = ds.Tables[0].Rows[0]["reportName"].ToString(); 
	        }
        }
        catch (Exception ex)
        {
            
            throw new Exception (ex.Message);
        }
    }

    protected void ViewReport(string reportPath)
    {
        //ICredentials webCredentials = new NetworkCredential(this.webUserName, this.webUserPassword, this.webUserDomain);
        //rpvMain.ServerReport.ReportServerCredentials = webCredentials; //(userName, password, domain);
       
        rpvMain.Visible = true;
        rpvMain.Height = Unit.Percentage(100);       
        rpvMain.ProcessingMode = Microsoft.Reporting.WebForms.ProcessingMode.Remote;
        rpvMain.ServerReport.ReportServerUrl = new Uri(ConfigurationManager.AppSettings["ReportServerUrl"]);
     
        rpvMain.ServerReport.ReportPath = reportPath;
        rpvMain.ShowToolBar = true;
        rpvMain.ShowBackButton = true;
        rpvMain.SizeToReportContent = true;
        //Microsoft.Reporting.WebForms.ReportParameterInfoCollection  prm  = rpvMain.ServerReport.GetParameters();
        Microsoft.Reporting.WebForms.ReportParameter[] repParams = this.BuilReportParams(false);
        if (repParams != null)
        {
            this.ReportParams = repParams;
        }
       
        if (repParams != null)
        {
          
            rpvMain.ServerReport.SetParameters(repParams);
            
            rpvMain.ServerReport.Refresh();
        }
    }

    protected Microsoft.Reporting.WebForms.ReportParameter[] BuilReportParams(bool isExcelVersion)
    {
        Dictionary<string, string> paramsDic = null;
        Microsoft.Reporting.WebForms.ReportParameter[] rpParams = null;

        paramsDic = this.BuildReportParamsDic(this.WhereParams, this.GetSelectedFields, isExcelVersion);

        if (paramsDic != null && paramsDic.Count > 0)
        {
            rpParams = new Microsoft.Reporting.WebForms.ReportParameter[paramsDic.Count];//[rsParams.Count+1]
            int i = 0;
            foreach (KeyValuePair<string, string> rsParam in paramsDic)
            {
                rpParams[i] = new Microsoft.Reporting.WebForms.ReportParameter(rsParam.Key, rsParam.Value, true);
                i++;
            }
        }
        //rpParams[rpParams.Length-1] = new Microsoft.Reporting.WebForms.ReportParameter(this.param_IsExcelVersion_name, "0", true);
        return rpParams;
    }

    protected ParameterValue[] BuilExcelReportParameters()
    {
        Dictionary<string, string> paramsDic = null;
        ParameterValue[] rpParams = null;


        paramsDic = this.BuildReportParamsDic(this.WhereParams, this.GetSelectedFields, true);


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
    
    protected Dictionary<string, string> BuildReportParamsDic(Hashtable prmWhere , string [] prmSelectedFields, bool isExcelVersion)
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
                
                if(String.IsNullOrEmpty(value))
                    value= "-1";
                
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


        string isExcelVersionParamValue = "0";
        if (isExcelVersion)
        {
            isExcelVersionParamValue = "1";
        }
        rsParams.Add(this.param_IsExcelVersion_name, isExcelVersionParamValue);

        return rsParams;
    }
    
    /// <summary>
    /// function returns fields , that were selected in previous page 
    /// </summary>
    private string[] GetPreviousPageSelectedFields()
    {
        string[] selectedReportFields = null;
        if (PreviousPage != null)
        {
            selectedReportFields = PreviousPage.GetSelectedFields;

            return selectedReportFields;
        }
        else
            return null;
    }
 
    protected void btnExcel_Click(object sender, EventArgs e)
    {
        //this.BuildExcelReport_urlAccess();
        this.BuildExcelReport();
    }

    private void BuildExcelReport_urlAccess()
    {
        //http://www.ssw.com.au/ssw/standards/rules/rulestobetterSQlreportingservices.aspx

        string prms = String.Empty;
        Microsoft.Reporting.WebForms.ReportParameter[] repParams = this.BuilReportParams(true);
        
        if (this.ReportParams != null)
        {
            //this.ReportParams[this.ReportParams.Length-1] = new Microsoft.Reporting.WebForms.ReportParameter(this.param_IsExcelVersion_name, "1", true);
            foreach (Microsoft.Reporting.WebForms.ReportParameter prm in this.ReportParams)
            {
                prms += "&" + prm.Name + "=" + prm.Values[0].ToString();
            }
        }

        string url = _urlReportServer + this.CurrentReportName + "Excel&rs:Command=Render&rs:Format=Excel" + prms;
        Response.Redirect( url, false);
    }

    private void BuildExcelReport()
    {
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
		
		MemoryStream ms = new MemoryStream();
		try
		{
			execInfo = executService.LoadReport(reportPath, historyID);
			execInfo = executService.SetExecutionParameters(parameters, "en-us");

			result = executService.Render(format, devInfo, out extension, out encoding, out mimeType, out warnings, out streamIDs);
			execInfo = executService.GetExecutionInfo();
			
			ms.Write(result, 0, result.Length);

			Response.ContentType = "application/vnd.ms-excel";
			Response.AddHeader("Content-Disposition",
				string.Format("attachment; filename = {0}.xls;", this.CurrentReportName + this.reportExcelNameExtantion));
			Response.OutputStream.Write(ms.GetBuffer(), 0, Convert.ToInt32(ms.Length));
			Response.Flush();
            HttpApplication httpApplication = new HttpApplication();
            httpApplication.CompleteRequest();
            //Response.Close();
            //Response.End();
		}
		catch (Exception e)
		{
			ExceptionHandlingManager mgr = new ExceptionHandlingManager();
			mgr.Publish(e, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMainMenuData),
			  new WebPageExtraInfoGenerator());
		}
		finally
		{
			ms.Close();
		}

    }
    
    protected void btnBack_Click(object sender, EventArgs e)
    {
        Session["reportNum"] = this.CurrentReport;// ?
        Response.Redirect("~/Reports/ReportsParameters.aspx");
    }
}
