using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Collections;
using SeferNet.FacadeLayer;
using SeferNet.Globals;
using SeferNet.BusinessLayer.WorkFlow;
using System.Web.UI.HtmlControls;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;


// Report parameters Names for query condition - "Where..." 
public static class ParameterWhereNames
{
    public static string District = "DistrictCodes";
    public static string AdminClinic = "AdminClinicCode";
    public static string UnitType = "UnitTypeCodes";
    public static string SubUnitType = "SubUnitTypeCodes";
    public static string Status = "StatusCodes";
    public static string SubClinicStatusCodes = "SubClinicStatusCodes";
    public static string DeptEmpStatus = "DeptEmployeeStatusCodes";
    public static string Sector = "SectorCodes";
    public static string Cities = "CitiesCodes";
    public static string Service = "ServiceCodes";
    public static string ServiceGivenBy = "ServiceGivenBy_cond";
    public static string ObjectType = "ObjectType_cond";
    public static string ValidFrom = "ValidFrom_cond";
    public static string ValidTo = "ValidTo_cond";
    public static string Profession = "ProfessionCodes";
    public static string showEmailInInternet = "showEmailInInternet_cond";
    public static string ExpertProfession = "ExpertProfessionCodes";
    public static string EmployeeSector = "EmployeeSector_cond";
    public static string EmployeeSex = "EmployeeSex_cond";
    public static string EmployeePosition = "PositionCodes";
    public static string EmployeeLanguage = "EmployeeLanguage_cond";
    public static string AgreementType = "AgreementType_cond";
    public static string DeptEvents_cond = "DeptEvents_cond";
    public static string EventStartDate_cond = "EventStartDate_cond";
    public static string EventFinishDate_cond = "EventFinishDate_cond";
    public static string SubClinicUnitType = "SubClinicUnitTypeCodes";
    public static string RemarkType = "RemarkType_cond";
    public static string Remark = "Remark_cond";
    public static string IsConstantRemark = "IsConstantRemark_cond";
    public static string IsSharedRemark = "IsSharedRemark_cond";
    public static string ShowRemarkInInternet = "ShowRemarkInInternet_cond";
    public static string IsFutureRemark = "IsFutureRemark_cond";
    public static string IsValidRemark = "IsValidRemark_cond";

    public static string IsRemarkAttributedToAllClinics = "IsRemarkAttributedToAllClinics_cond";
    public static string DeptProperty = "DeptProperty_cond";
    public static string ReceptionHoursSpan = "ReceptionHoursSpan_cond";
    public static string IncludeSubClinicEmployees = "IncludeSubClinicEmployees_cond";
    public static string Membership_cond = "Membership_cond";

    public static string FromDate = "FromDate";
    public static string ToDate = "ToDate";
    public static string DeptCode = "DeptCodes";
    public static string ChangeType = "ChangeTypes";
    public static string Employee = "EmployeeNames";
    public static string UpdateUser = "UserNames";
    public static string ShowCodes = "ShowCodes";
    //public static string Services = "Services";
    //public static string Remarks = "Remarks";
}

public static class eADM_QueriesFieldsEnum
{
    public static string FieldTitle = "FieldTitle";
    public static string FieldName = "FieldName";
    public static string Mandatory = "Mandatory";
    public static string FieldOrder = "FieldOrder";
}

public partial class Reports_ReportsParameters : AdminBasePage
{
    string _pageName = string.Empty;

    private Dictionary<string, Control[]> paramControlsDictionary;

    #region ------------ Properties ----------------

    // ok -  used in Rs_reportResult
    public Hashtable ParamsWhere
    {
        get
        {
            Hashtable paramsWhere = new Hashtable();
            foreach (KeyValuePair<string, string[]> param in this.ParamsSelectedValuesDict)
            {
                // "Employee" reports requered only AgreementType parameter, Membership_cond control is helper control.
                if (param.Key == ParameterWhereNames.Membership_cond
                    && this.ParamsSelectedValuesDict.ContainsKey(ParameterWhereNames.AgreementType))
                    continue;

                string parValue = param.Value[0];

                if (param.Key == ParameterWhereNames.AgreementType && param.Value[0] == "-1")//selected AgreementType = All
                {
                    string membership = this.ParamsSelectedValuesDict[ParameterWhereNames.Membership_cond][0];

                    string[] memberships = membership.Split(',');

                    parValue = string.Empty;

                    foreach (string ms in memberships)
                    {
                        if (ms == "-1")
                        {
                            parValue = "-1";
                            break;
                        }
                        else
                        {
                            if (ms != string.Empty)
                            {
                                parValue += GetAgreementTypesAccordingToSearchMode(Convert.ToInt32(ms));
                            }
                        }
                    }

                    paramsWhere.Add(param.Key, parValue);
                    continue;
                }

                paramsWhere.Add(param.Key, param.Value[0]);
            }
            return paramsWhere;
        }
    }

    private string GetAgreementTypesAccordingToSearchMode(int searchMode)
    {
        DataSet ds;
        string agreementTypes = string.Empty;

        if (Session["AgreementTypesAccordingToSearchMode"] != null)
        {
            ds = (DataSet)Session["AgreementTypesAccordingToSearchMode"];
        }
        else
        {
            Facade applicFacade = Facade.getFacadeObject();
            ds = applicFacade.getGeneralDataTable("DIC_AgreementTypes");
            Session["AgreementTypesAccordingToSearchMode"] = ds;
        }

        foreach (DataRow row in ds.Tables[0].Rows)
        {
            if (Convert.ToInt32(row["OrganizationSectorID"]) == searchMode)
            {
                agreementTypes += row["AgreementTypeID"].ToString() + ',';
            }

        }

        return agreementTypes;
    }

    // ok -  used in Rs_reportResult
    public string[] GetSelectedFields
    {
        get
        {
            return this.SelectedFields.ToArray();
        }
    }

    public int GetSelectedReportID
    {
        get
        {
            int selectedReportId = int.Parse(this.ddlReport.SelectedValue.ToString());
            return selectedReportId;
        }
    }

    //current report Fields Definitions fom DB
    private DataTable CurrentRepFieldsDefinition
    {
        get
        {
            string currentReportName = this.Session["reportName"] as string;
            if (currentReportName == null)
                return null;

            string key = currentReportName + "_CurrentReportFieldsDefinition";
            object obj = this.Session[key];

            if (obj != null)
                return obj as DataTable;
            //--- Get ReportFields Definition from DataBase and seve into Session
            else
            {
                DataTable dt = this.GetReportFieldsDefinition();
                if (dt != null)
                {
                    this.Session[key] = dt;
                }
                return dt;
            }
        }
    }

    //current report WhereParameters definitions from DB 
    private DataTable CurrentRepParamsDefinition
    {
        get
        {
            string currentReportName = this.Session["reportName"] as string;
            if (currentReportName == null)
                return null;

            string key = currentReportName + "_CurrentParamsDefinition";
            object obj = this.Session[key];

            if (obj != null)
                return obj as DataTable;
            //--- Get WhereParameters Definition from DataBase and seve into Session
            else
            {
                DataTable dt = this.GetWhereParametersDefinition();
                if (dt != null)
                {
                    this.Session[key] = dt;
                }
                return dt;
            }
        }
    }

    private Dictionary<string, string[]> ParamsSelectedValuesDict
    {
        get
        {
            Dictionary<string, string[]> paramSelValuesDict;

            string currentReportName = this.Session["reportName"] as string;
            if (currentReportName == null)
                return null;

            string key = currentReportName + "_ParamsSelectedValues";
            object obj = this.Session[key];

            if (obj != null && obj is Dictionary<string, string[]>)
            {
                paramSelValuesDict = obj as Dictionary<string, string[]>;
            }
            else
            {
                paramSelValuesDict = new Dictionary<string, string[]>(20);
                this.Session[key] = paramSelValuesDict;
            }
            return paramSelValuesDict;
        }
        // used to remove ParamsSelectedValuesDict from Session by seting Null value 
        //set
        //{
        //    string currentReportName = this.Session["reportName"] as string;

        //    if (value == null &&
        //        currentReportName != null)
        //    {
        //        string key = currentReportName + "_ParamsSelectedValues";
        //        this.Session.Remove(key);
        //    }
        //}
    }

    private List<string> SelectedFields
    {
        get
        {
            List<string> selectedFields;

            string currentReportName = this.Session["reportName"] as string;
            if (currentReportName == null)
                return null;

            string key = currentReportName + "_SelectedFields";
            object obj = this.Session[key];

            if (obj != null && obj is List<string>)
            {
                selectedFields = obj as List<string>;
            }
            else
            {
                selectedFields = new List<string>();
                this.Session[key] = selectedFields;
            }
            return selectedFields;
        }

    }

    #region ---------- Save items in Session -----------------

    private Hashtable GetSessionHashTable()
    {
        Hashtable hTbl = null;

        if (Session[_pageName] == null)
        {
            hTbl = new Hashtable();
            Session[_pageName] = hTbl;
        }
        else
        {
            hTbl = (Hashtable)Session[_pageName];
        }
        return hTbl;
    }

    private object GetObjectFromSession(string key)
    {
        object obg = null;
        Hashtable hTbl = GetSessionHashTable();
        if (hTbl != null)
        {
            if (!hTbl.ContainsKey(key))
            {
                return null;
            }
            else
            {
                obg = hTbl[key];
                return obg;
            }
        }
        return null;
    }

    private bool SetObjectToSession(string key, object obg)
    {
        Hashtable hTbl = GetSessionHashTable();
        if (hTbl != null)
        {
            if (!hTbl.ContainsKey(key))
            {
                hTbl.Add(key, obg);
                return true;
            }
            else
            {
                hTbl[key] = obg;
            }
        }
        return false;
    }

    #endregion

    #region ---------- Save items in ViewState ----------------

    private Hashtable GetViewStateHashTable()
    {
        Hashtable hTbl = null;

        if (ViewState[_pageName] == null)
        {
            hTbl = new Hashtable();
            ViewState[_pageName] = hTbl;
        }
        else
        {
            hTbl = (Hashtable)ViewState[_pageName];
        }
        return hTbl;
    }

    private object GetObjectFromViewState(string key)
    {
        object obg = null;
        Hashtable hTbl = GetViewStateHashTable();
        if (hTbl != null)
        {
            if (!hTbl.ContainsKey(key))
            {
                return null;
            }
            else
            {
                obg = hTbl[key];
                return obg;
            }
        }
        return null;
    }

    private bool SetObjectToViewState(string key, object obg)
    {
        Hashtable hTbl = GetViewStateHashTable();
        if (hTbl != null)
        {
            if (!hTbl.ContainsKey(key))
            {
                hTbl.Add(key, obg);
                return true;
            }
            else
            {
                hTbl[key] = obg;
            }
        }
        return false;
    }

    #endregion

    #endregion Properties

    #region ---------- Page and Controls Events ------------

    //------- Page_Load --------
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            SessionParamsHandler.RemoveDeptCodeFromSession();

            _pageName = ((System.Web.UI.TemplateControl)(this.Page)).AppRelativeVirtualPath;

            this.InitParamControlsDictionary();

            if (!Page.IsPostBack)
            {
                this.divRepFields.Style["height"] = "440px";

                this.divRepParameters.Style["height"] = "440px";

                BindDdlReport();
                if (Request.QueryString["reportNum"] != null)
                {
                    //ClearFormData();
                    ddlReport.SelectedValue = Request.QueryString["reportNum"].ToString();
                }
                else if (Session["reportNum"] != null)
                {
                    ddlReport.SelectedValue = Session["reportNum"].ToString();
                }
                else
                {
                    ddlReport.SelectedValue = "1";
                }
                Session["reportName"] = ddlReport.SelectedItem.Text;
                Session["reportNum"] = ddlReport.SelectedItem.Value;

                cbValidNow.Checked = true;

                //---- Initialize whereParameter controls
                this.VisibleRelevantWhereParamControls();
                this.SetValidationGroup();
                this.InitWhereParamControls(false);//Binds all paramControls
                this.RestoreParamSelectedValues(false);
                this.LimitDistrictDdlByUserPermission();
                this.BindDDlAdminClinics();
                this.BindDDlSubUnitTypes();
                this.EnableProfessionAndExpertProfByEmployeeSector();
                this.BindDDlEmployeePosition();
                this.BindDDlAgreementType();
                this.RestoreParamSelectedValues(true);

                // selected fields 
                this.BuildReportFieldListBox(false);
                this.RestoreSelectedFields();
                this.SetDblClickAttributeOnListBoxes();
                //txtUnitTypeListCodes.Text = string.Empty;
            }


            else if (this.IsCrossPagePostBack)
            {
                this.SaveParamSelectedValues();
                this.SaveSelectedFields();
            }
            else
            {
                //this.BindDDlAdminClinics();

                ScriptManager.RegisterClientScriptBlock(this.upReportParams, typeof(UpdatePanel),
                    "RefreshMembership",
                    "if (typeof (MarkCelectedCheckboxes) == 'function') {MarkCelectedCheckboxes();}",
                    //"RefreshMembership();",
                    true);
            }


        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected override void OnPreRenderComplete(EventArgs e)
    {
        base.OnPreRenderComplete(e);
    }

    protected void btnAddAll_Click(object sender, EventArgs e)
    {
        int i = 0;

        for (i = 0; i < lstReportFields.Items.Count; i++)
        {
            lstSelectedFields.Items.Add(lstReportFields.Items[i]);
        }

        lstSelectedFields.ClearSelection();
        lstReportFields.ClearSelection();
        lstReportFields.Items.Clear();
    }

    protected void btnAddFields_Click(object sender, EventArgs e)
    {
        this.MoveFields(this.lstReportFields, this.lstSelectedFields);

        ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "SetScrollPositionForNotSelected", "SetScrollPositionForNotSelected();", true);
    }

    private void MoveFields(ListBox source, ListBox destination)
    {
        int selIndex = source.SelectedIndex;
        int sourseIndex;
        int destLastIndex = destination.Items.Count;

        for (int i = source.GetSelectedIndices().Length - 1; i >= 0; i--)
        {
            sourseIndex = source.GetSelectedIndices()[i];
            destination.Items.Insert(destLastIndex, source.Items[sourseIndex]);
            source.Items.RemoveAt(sourseIndex);
        }

        destination.ClearSelection();
        source.ClearSelection();

        if (selIndex >= source.Items.Count)
        {
            selIndex--;
        }
        source.SelectedIndex = selIndex;

    }

    protected void btnRemoveAll_Click(object sender, EventArgs e)
    {
        this.BuildReportFieldListBox(true);
        this.SetDblClickAttributeOnListBoxes();
    }

    protected void btnRemoveFields_Click(object sender, EventArgs e)
    {
        this.MoveFields(this.lstSelectedFields, this.lstReportFields);

        ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "SetScrollPositionForSelected", "SetScrollPositionForSelected();", true);
    }

    //not in use now
    protected void btnUp_Click(object sender, EventArgs e)
    {
        try
        {
            int indx = lstSelectedFields.SelectedIndex;
            if (indx > -1)
            {
                ListItem selectedIten = lstSelectedFields.Items[indx];
                if (selectedIten != null)
                {
                    if (indx - 1 > -1)
                    {
                        lstSelectedFields.Items.RemoveAt(indx);
                    }
                    indx = indx - 1;

                    if (indx > -1)
                    {
                        lstSelectedFields.Items.Insert(indx, selectedIten);
                        lstSelectedFields.Items[indx].Selected = true;
                        lstSelectedFields.Items[indx].Attributes["selected"] = "true";
                    }
                }
                lstSelectedFields.ClearSelection();
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    //not in use now
    protected void btnDown_Click(object sender, EventArgs e)
    {
        try
        {
            int indx = lstSelectedFields.SelectedIndex;
            if (indx + 1 < lstSelectedFields.Items.Count)
            {
                ListItem selectedIten = lstSelectedFields.Items[indx];
                if (selectedIten != null)
                {
                    if (indx <= lstSelectedFields.Items.Count)
                    {
                        lstSelectedFields.Items.RemoveAt(indx);
                    }
                    indx = indx + 1;

                    if (indx <= lstSelectedFields.Items.Count)
                    {
                        lstSelectedFields.Items.Insert(indx, selectedIten);
                        lstSelectedFields.Items[indx].Selected = true;
                        lstSelectedFields.Items[indx].Attributes["selected"] = "true";
                    }
                }
                lstSelectedFields.ClearSelection();
            }

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void btnResetParams_Click(object sender, EventArgs e)
    {
        //reset ParamsSelectedValuesDict and SelectedFields
        this.ParamsSelectedValuesDict.Clear();
        if (this.SelectedFields.Count > 0)
        {
            this.SelectedFields.RemoveRange(0, this.SelectedFields.Count - 1);
        }

        //---- Initialize whereParameter controls
        this.VisibleRelevantWhereParamControls();
        this.InitWhereParamControls(false);//Binds all paramControls
        this.RestoreParamSelectedValues(false);
        this.LimitDistrictDdlByUserPermission();
        this.BindDDlAdminClinics();
        this.BindDDlSubUnitTypes();
        this.EnableProfessionAndExpertProfByEmployeeSector();
        this.BindDDlEmployeePosition();
        this.BindDDlAgreementType();
        this.RestoreParamSelectedValues(true);

        // initalize fields
        this.BuildReportFieldListBox(true);
        this.SetDblClickAttributeOnListBoxes();
    }

    protected void btnDoReport_Click(object sender, EventArgs e)
    {

    }

    protected void btnExcel_Click(object sender, EventArgs e)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "CreateExcel", "CreateExcel();", true);

        SetValidFromToByValidNow();

        this.SaveParamSelectedValues();
        this.SaveSelectedFields();
        //Session["ParamsWhere"] = ParamsWhere;

        ClearValidFromToByValidNow();
    }

    private void SetValidFromToByValidNow()
    {
        string DateNowString;

        if (cbValidNow.Checked)
        {
            //DateNowString =  String.Format("{0:yyyy-MM-dd}", DateTime.Now);
            DateNowString = String.Format("{0:dd/MM/yyyy}", DateTime.Now);

            txtValidFrom.Text = DateNowString;
            txtValidTo.Text = DateNowString;
        }
    }

    private void ClearValidFromToByValidNow()
    {
        if (cbValidNow.Checked)
        {
            txtValidFrom.Text = string.Empty;
            txtValidTo.Text = string.Empty;
        }
    }

    protected void District_TextChanged(object sender, EventArgs e)
    {
        this.BindDDlAdminClinics();

        this.txtDeptCodes.Text = string.Empty;
        this.txtDepts.Text = string.Empty; 
    }

    protected void ddlReport_SelectedIndexChanged(object sender, EventArgs e)
    {
        // ClearFormData();
        this.SaveSelectedFields();
        this.SaveParamSelectedValues();

        Session["reportName"] = ddlReport.SelectedItem.Text;
        Session["reportNum"] = ddlReport.SelectedItem.Value;

        this.VisibleRelevantWhereParamControls();
        this.SetValidationGroup();
        this.InitWhereParamControls(false);
        //Restore independent ParamControls Selected Values 
        this.RestoreParamSelectedValues(false);
        this.LimitDistrictDdlByUserPermission();
        this.BindDDlAdminClinics();
        this.BindDDlSubUnitTypes();
        this.EnableProfessionAndExpertProfByEmployeeSector();
        this.BindDDlEmployeePosition();
        this.BindDDlAgreementType();
        //Restore dependent ParamControls Selected Values 
        this.RestoreParamSelectedValues(true);

        //restore fields
        this.BuildReportFieldListBox(false);
        this.RestoreSelectedFields();
        this.SetDblClickAttributeOnListBoxes();
    }

    protected void txtUnitTypeList_TextChanged(object sender, EventArgs e)
    {
        BindDDlSubUnitTypes();
    }

    protected void ddlEmployeeSector_SelectedIndexChanged(object sender, EventArgs e)
    {
        this.EnableProfessionAndExpertProfByEmployeeSector();
        this.BindDDlEmployeePosition();
    }

    protected void Membership_SelectedIndexChanged(object sender, EventArgs e)
    {
        this.BindDDlAgreementType();
    }

    #endregion Page and Controls Events

    #region --------------Utils ------------

    private void LimitDistrictDdlByUserPermission()
    {
        //if user is not permitted to administer users
        // 1 is district administrator
        // 6 is district permittions for Reports
        // 5 is system administrator
        UserManager usMang = new UserManager();
        DataSet districts = usMang.getUserPermittedDistrictsForReports(usMang.GetUserIDFromSession(), string.Empty);//(um.GetUserInfoFromSession().UserID) ;

        if (districts.Tables[0].Rows.Count == 1)
        {
            this.txtDistrictCodes.Text = districts.Tables[0].Rows[0]["districtCode"].ToString();
            this.txtDistrictList.Text = districts.Tables[0].Rows[0]["districtName"].ToString();

            this.btnDistrict.Disabled = true;
            this.txtDistrictList.Enabled = false;
        }
        else
        {
            this.btnDistrict.Disabled = false;
            this.txtDistrictList.Enabled = true;
        }
    }

    private void EnableProfessionAndExpertProfByEmployeeSector()
    {
        if (!(ddlReport.SelectedItem.Value == "4"
             || ddlReport.SelectedItem.Value == "5"
             || ddlReport.SelectedItem.Value == "6"
             || ddlReport.SelectedItem.Value == "7"
             || ddlReport.SelectedItem.Value == "11"))
            return;

        if (this.ddlEmployeeSector.SelectedItem != null &&
            (this.ddlEmployeeSector.SelectedItem.Value == "2" ||
            this.ddlEmployeeSector.SelectedItem.Value == "7"))
        {// enable
            this.EnableTextBoxControl(ParameterWhereNames.Profession, true);
        }
        else
        { // disable
            this.InitTextBoxControl(ParameterWhereNames.Profession);
            this.EnableTextBoxControl(ParameterWhereNames.Profession, false);
        }

        if (ddlReport.SelectedItem.Value != "11"
            && this.ddlEmployeeSector.SelectedItem != null
            && this.ddlEmployeeSector.SelectedItem.Value == "7")
        {// enable
            this.EnableTextBoxControl(ParameterWhereNames.ExpertProfession, true);
        }
        else
        { // disable
            this.InitTextBoxControl(ParameterWhereNames.ExpertProfession);
            this.EnableTextBoxControl(ParameterWhereNames.ExpertProfession, false);
        }

    }

    private void SaveSelectedFields()
    {
        this.SelectedFields.Clear();
        foreach (ListItem item in this.lstSelectedFields.Items)
         {
            this.SelectedFields.Add(item.Value);
        }

        Session["SelectedFields"] = SelectedFields.ToArray();
    }

    private void RestoreSelectedFields()
    {
        foreach (string selField in this.SelectedFields)
        {
            ListItem item = this.lstReportFields.Items.FindByValue(selField);
            if (item == null)
                continue;

            this.lstSelectedFields.Items.Add(item);
            this.lstReportFields.Items.Remove(item);
        }
    }

    private void SetDblClickAttributeOnListBoxes()
    {
        this.lstSelectedFields.Attributes.Add("onDblClick", "lstSelectedFields_doubleClick();");
        this.lstReportFields.Attributes.Add("onDblClick", "lstReportFields_doubleClick();");
    }

    private void InitParamControlsDictionary()
    {
        this.paramControlsDictionary = new Dictionary<string, Control[]>(50);
        this.paramControlsDictionary.Add(ParameterWhereNames.ShowCodes, new Control[] { this.trShowCodes, this.cbShowCodes });
        this.paramControlsDictionary.Add(ParameterWhereNames.District, new Control[] { this.trDistrict, this.txtDistrictCodes, this.txtDistrictList });
        this.paramControlsDictionary.Add(ParameterWhereNames.AdminClinic, new Control[] { this.trAdminClinic, this.ddlAdminClinic });
        this.paramControlsDictionary.Add(ParameterWhereNames.Cities, new Control[] { this.trCity, this.txtCitiesListCodes, this.txtCitiesList });
        this.paramControlsDictionary.Add(ParameterWhereNames.Status, new Control[] { this.trStatus, this.ddlStatus });
        this.paramControlsDictionary.Add(ParameterWhereNames.SubClinicStatusCodes, new Control[] { this.trSubClinicStatus, this.ddlSubClinicStatus });

        this.paramControlsDictionary.Add(ParameterWhereNames.DeptEmpStatus, new Control[] { this.trDeptEmpStatus, this.ddlDeptEmpStatus });
        this.paramControlsDictionary.Add(ParameterWhereNames.UnitType, new Control[] { this.trUnitType, this.txtUnitTypeListCodes, txtUnitTypeList });
        this.paramControlsDictionary.Add(ParameterWhereNames.SubUnitType, new Control[] { this.trSubUnitType, this.ddlSubUnitType });
        this.paramControlsDictionary.Add(ParameterWhereNames.Sector, new Control[] { this.trSector, this.ddlSector });
        this.paramControlsDictionary.Add(ParameterWhereNames.Service, new Control[] { this.trServices, this.txtServicesListCodes, txtServicesList });
        this.paramControlsDictionary.Add(ParameterWhereNames.Profession, new Control[] { this.trProfession, this.txtProfessionListCodes, this.txtProfessionList, this.btnProfessionListPopUp });
        this.paramControlsDictionary.Add(ParameterWhereNames.ObjectType, new Control[] { this.trObjectType, this.txtObjectTypeCodes, this.txtObjectType });
        this.paramControlsDictionary.Add(ParameterWhereNames.ServiceGivenBy, new Control[] { this.trServiceGivenBy, this.ddlServiceGivenBy });
        this.paramControlsDictionary.Add(ParameterWhereNames.ValidFrom, new Control[] { this.trValidFrom, this.txtValidFrom });
        this.paramControlsDictionary.Add(ParameterWhereNames.ValidTo, new Control[] { this.trValidTo, this.txtValidTo });
        this.paramControlsDictionary.Add(ParameterWhereNames.EmployeeSector, new Control[] { this.trEmployeeSector, this.ddlEmployeeSector });
        this.paramControlsDictionary.Add(ParameterWhereNames.ExpertProfession, new Control[] { this.trExpertProfession, this.txtExpertProfListCodes, this.txtExpertProfList, this.btnExpertProfListPopUp });
        this.paramControlsDictionary.Add(ParameterWhereNames.EmployeeSex, new Control[] { this.trEmployeeSex, this.DdlEmployeeSex });
        this.paramControlsDictionary.Add(ParameterWhereNames.EmployeePosition, new Control[] { this.trEmployeePosition, this.DdlEmployeePosition });
        this.paramControlsDictionary.Add(ParameterWhereNames.EmployeeLanguage, new Control[] { this.trEmployeeLanguage, this.txtEmployeeLanguageCodes, this.txtEmployeeLanguage });
        this.paramControlsDictionary.Add(ParameterWhereNames.AgreementType, new Control[] { this.trAgreementType, this.ddlAgreementType });
        this.paramControlsDictionary.Add(ParameterWhereNames.DeptEvents_cond, new Control[] { this.trEvent, this.txtEventCodes, this.txtEvent });
        this.paramControlsDictionary.Add(ParameterWhereNames.EventStartDate_cond, new Control[] { this.trEventStartDate, this.TxtEventStartDate });
        this.paramControlsDictionary.Add(ParameterWhereNames.EventFinishDate_cond, new Control[] { this.trEventFinishDate, this.TxtEventFinishDate });
        this.paramControlsDictionary.Add(ParameterWhereNames.SubClinicUnitType, new Control[] { this.trSubClinicUnitType, this.txtSubClinicUnitTypeListCodes, txtSubClinicUnitTypeList });

        this.paramControlsDictionary.Add(ParameterWhereNames.RemarkType, new Control[] { this.trRemarkType, this.ddlRemarkType });
        this.paramControlsDictionary.Add(ParameterWhereNames.Remark, new Control[] { this.trRemark, this.txtRemarkCodes, this.txtRemark });
        this.paramControlsDictionary.Add(ParameterWhereNames.IsConstantRemark, new Control[] { this.trIsConstantRemark, this.DdlIsConstantRemark });
        this.paramControlsDictionary.Add(ParameterWhereNames.IsSharedRemark, new Control[] { this.trIsSharedRemark, this.DdlIsSharedRemark });
        this.paramControlsDictionary.Add(ParameterWhereNames.IsFutureRemark, new Control[] { this.trIsFutureRemark, this.DdlIsFutureRemark });
        this.paramControlsDictionary.Add(ParameterWhereNames.IsValidRemark, new Control[] { this.trIsValidRemark, this.DdlIsValidRemark });

        this.paramControlsDictionary.Add(ParameterWhereNames.IsRemarkAttributedToAllClinics, new Control[] { this.trRemarkAttributedToAllClinics, this.DdlRemarkAttributedToAllClinics });
        this.paramControlsDictionary.Add(ParameterWhereNames.ShowRemarkInInternet, new Control[] { this.trShowRemarkInInternet, this.DdlShowRemarkInInternet });
        this.paramControlsDictionary.Add(ParameterWhereNames.showEmailInInternet, new Control[] { this.trShowInInternet, this.DdlShowInInternet });
        this.paramControlsDictionary.Add(ParameterWhereNames.DeptProperty, new Control[] { this.trDeptProperty, this.DdlDeptProperty });
        this.paramControlsDictionary.Add(ParameterWhereNames.ReceptionHoursSpan, new Control[] { this.trReceptionHoursSpan, this.txtReceptionHoursSpan });
        this.paramControlsDictionary.Add(ParameterWhereNames.IncludeSubClinicEmployees, new Control[] { this.trIncludeSubClinicEmployees, this.DdlIncludeSubClinicEmployees });
        this.paramControlsDictionary.Add(ParameterWhereNames.Membership_cond, new Control[] { this.trMembership, this.lstMembership });

        this.paramControlsDictionary.Add(ParameterWhereNames.FromDate, new Control[] { this.trFromDate, this.txtFromDate });
        this.paramControlsDictionary.Add(ParameterWhereNames.ToDate, new Control[] { this.trToDate, this.txtToDate });
        this.paramControlsDictionary.Add(ParameterWhereNames.DeptCode, new Control[] { this.trDeptCode, this.txtDeptCodes, this.txtDepts });
        this.paramControlsDictionary.Add(ParameterWhereNames.ChangeType, new Control[] { this.trChangeType, this.txtChangeTypeCodes, this.txtChangeType });
        this.paramControlsDictionary.Add(ParameterWhereNames.Employee, new Control[] { this.trEmployee, this.txtEmployeeCodes, this.txtEmployee });
        this.paramControlsDictionary.Add(ParameterWhereNames.UpdateUser, new Control[] { this.trUpdateUser, this.txtUpdateUserCodes, this.txtUpdateUser });

        //this.paramControlsDictionary.Add(ParameterWhereNames.Services, new Control[] { this.trServices, this.txtServicesListCodes, txtServicesList });
        //this.paramControlsDictionary.Add(ParameterWhereNames.Remarks, new Control[] { this.trRemark, this.txtRemarkCodes, this.txtRemark });
    }

    private void SetValidationGroup()
    {
        Control[] parContr = this.paramControlsDictionary[ParameterWhereNames.ValidFrom];
        if (parContr != null
            && parContr.Length > 0
            && ((HtmlTableRow)parContr[0]).Style["display"] != "none")
        {
            this.btnGetReport.ValidationGroup = this.ValidFrom_Validator.ValidationGroup;
        }

        parContr = this.paramControlsDictionary[ParameterWhereNames.EventStartDate_cond];
        if (parContr != null
            && parContr.Length > 0
            && ((HtmlTableRow)parContr[0]).Style["display"] != "none")
        {
            this.btnGetReport.ValidationGroup = this.MaskedEditValidator_EventStartDate.ValidationGroup;
        }
    }

    private void SaveParamSelectedValues()
    {
        this.ParamsSelectedValuesDict.Clear();

        foreach (string parKey in this.paramControlsDictionary.Keys)
        {
            Control[] parContr = this.paramControlsDictionary[parKey];
            if (parContr == null || parContr.Length < 2 ||
                ((HtmlTableRow)parContr[0]).Style["display"] == "none")
                continue;

            if (parContr[1] is DropDownList)
            {
                string selValue = ((DropDownList)parContr[1]).SelectedValue;
                this.ParamsSelectedValuesDict[parKey] = new string[] { selValue };

            }

            else if (parContr[1] is TextBox)
            {
                string selCodes = ((TextBox)parContr[1]).Text;

                string selDescrips = null;
                if (parContr.Length >= 3)
                {
                    selDescrips = ((TextBox)parContr[2]).Text;
                }

                // If textBox represent DateTime value , change dateTime format 
                //DataRow[] rows = this.CurrentRepParamsDefinition.Select("ParameterID = '" + parKey + "' and AppControlType = 3");
                //DateTime date;
                DateTime dateFromConversion;
                if (selCodes.Length == 10 && DateTime.TryParse(selCodes, out dateFromConversion)) // "dd/MM/yyyy", null, null,
                {
                    //selCodes = dateFromConversion.ToString("yyyy-MM-dd");
                    selCodes = dateFromConversion.ToString("dd/MM/yyyy H:mm");
                }

                this.ParamsSelectedValuesDict[parKey] = new string[] { selCodes, selDescrips };
            }
             
            else if (parContr[1] is UserControls_SearchModeSelector)
            {
                this.ParamsSelectedValuesDict[parKey] = new string[] { ((UserControls_SearchModeSelector)parContr[1]).SelectedCodes };
            }

            if (parKey == "ShowCodes")
            {
                this.ParamsSelectedValuesDict[parKey] = new string[] {  (Convert.ToInt16 ( ((CheckBox)parContr[1]).Checked )).ToString()   };
            }
        }

        Session["ParamsWhere"] = ParamsWhere;
    }

    /// <summary>
    /// Restore Parameters Selected Values for Dependent parameters or Independent parameters 
    /// </summary>
    /// <param name="isDependentParam"></param>
    private void RestoreParamSelectedValues(bool isDependentParam)
    {
        Dictionary<string, string[]> parSelValuesDict = this.ParamsSelectedValuesDict;

        foreach (string parKey in parSelValuesDict.Keys)
        {
            Control[] parContr = this.paramControlsDictionary[parKey];
            DataRow[] parDefin = this.CurrentRepParamsDefinition.Select("ParameterID = '" + parKey + "'");

            if (parContr == null || parContr.Length < 2 || ((HtmlTableRow)parContr[0]).Visible == false)
                return;


            string dependsOnParam = parDefin[0]["DependsOnParam"] as string;

            if (string.IsNullOrEmpty(dependsOnParam) == !isDependentParam)
            {
                string[] selValues = parSelValuesDict[parKey];
                if (selValues == null || selValues.Length < 1)
                    return;

                if (parContr[1] is DropDownList &&
                    ((DropDownList)parContr[1]).Items.FindByValue(selValues[0]) != null)
                {
                    ((DropDownList)parContr[1]).SelectedValue = selValues[0];
                }

                else if (parContr[1] is TextBox)
                {
                    ((TextBox)parContr[1]).Text = selValues[0];// selected codes
                }

                if (parContr.Length >= 3 && parContr[2] is TextBox)
                {
                    ((TextBox)parContr[2]).Text = selValues[1]; // selected values
                }

                else if (parContr[1] is UserControls_SearchModeSelector)
                {
                    ((UserControls_SearchModeSelector)parContr[1]).SelectedCodes = selValues[0];// selected codes
                }

            }
        }
    }

    private void ClearFormData()
    {
        Session[_pageName] = null;
        Session["reportName"] = null;
        Session["reportNum"] = null;
        ViewState[_pageName] = null;
        ClearForm();
    }

    private void ClearForm()
    {
        lstReportFields.Items.Clear();
        lstSelectedFields.Items.Clear();

        //-------- Clear textBoxes
        txtProfessionListCodes.Text = string.Empty;
        txtProfessionList.Text = string.Empty;

        txtCitiesListCodes.Text = string.Empty;
        txtCitiesList.Text = string.Empty;

        txtUnitTypeListCodes.Text = string.Empty;
        txtUnitTypeList.Text = string.Empty;

        txtServicesListCodes.Text = string.Empty;
        txtServicesList.Text = string.Empty;

        //--------- Clear Ddls
        //ddl District.SelectedIndex = -1;
        //ddlDistrict.SelectedValue = null;

        ddlAdminClinic.SelectedIndex = -1;
        ddlAdminClinic.SelectedValue = null;

        ddlStatus.SelectedIndex = -1;
        ddlStatus.SelectedValue = null;

        ddlSubUnitType.SelectedIndex = -1;
        ddlSubUnitType.SelectedValue = null;

        ddlSector.SelectedIndex = -1;
        ddlSector.SelectedValue = null;
    }

    #endregion Utils

    #region  --------------- Controls Binding ---------------

    private void BindDdlReport()
    {
        UIHelper.BindDropDownToCachedTable(ddlReport, "DIC_Reports", "ID");
    }

    private void BuildReportFieldListBox(bool deselectAllItems)
    {
        ListItem li = null;
        int i = -1;
        string selected = string.Empty;

        this.lstReportFields.Items.Clear();
        this.lstSelectedFields.Items.Clear();

        DataTable dt = this.CurrentRepFieldsDefinition;
        if (dt == null) return;


        for (i = 0; i < dt.Rows.Count; i++)
        {
            li = new ListItem();
            li.Text = dt.Rows[i][eADM_QueriesFieldsEnum.FieldTitle.ToString()].ToString();
            li.Value = dt.Rows[i][eADM_QueriesFieldsEnum.FieldName.ToString()].ToString();
            li.Attributes.Add("ListPosition", i.ToString());   //("ListPosition", dt.Rows[i]["Ord"].ToString());
            selected = dt.Rows[i][eADM_QueriesFieldsEnum.Mandatory.ToString()].ToString();
            li.Attributes.Add("Mandatory", selected);

            if (deselectAllItems)
            {
                lstReportFields.Items.Add(li);
            }
            else
            {
                if (selected == "1")
                {
                    lstSelectedFields.Items.Add(li);
                }
                else
                {
                    lstReportFields.Items.Add(li);
                }
            }
        }
    }

    private void BindDDlSubUnitTypes()
    {
        DataRow[] rows = this.CurrentRepParamsDefinition.Select("ParameterID = '" + ParameterWhereNames.SubUnitType + "'");
        if (rows.Length == 0)
            return;

        string[] unitTypesSelected = txtUnitTypeListCodes.Text.Split(',');
        if (unitTypesSelected.Length == 1 && unitTypesSelected[0] != string.Empty)
        {
            string filter = "UnitTypeCode = " + unitTypesSelected[0];
            this.BindDropDownToCachedTable(rows[0], filter, false);
        }
        //--- the case when "NO ONE" or "MORE THEN ONE"  unitTypes were selected
        else
        {
            // add default item only to items collection 
            this.BindDropDownToCachedTable(rows[0], string.Empty, true);
            //to do: add default item
        }
    }

    private void BindDDlAdminClinics()
    {
        string districtCodes = "-1";
        if (this.txtDistrictCodes.Text != string.Empty &&
            this.txtDistrictCodes.Text != "-1")
        {
            districtCodes = this.txtDistrictCodes.Text;
        }

        DataRow[] defin = this.CurrentRepParamsDefinition.Select("ParameterID = '" + ParameterWhereNames.AdminClinic + "'");
        if (defin.Length == 0) return;

        ddlAdminClinic.Items.Clear();

        UIHelper.BindDropDownToCachedTable(ddlAdminClinic,
                eCachedTables.View_AllAdministrations.ToString(),
                "districtCode in( " + districtCodes.ToString() + ")",
                defin[0]["LookupDescriptionField"] as string);

        ListItem defaultItem = new ListItem(defin[0]["AppDefaultItemDescription"] as string, "-1");
        this.ddlAdminClinic.Items.Insert(0, defaultItem);
    }

    private void BindDDlEmployeePosition()
    {
        int sectorCode = -1;
        if (ddlEmployeeSector.SelectedValue != string.Empty &&
            ddlEmployeeSector.SelectedValue != "-1")
        {
            sectorCode = Convert.ToInt32(ddlEmployeeSector.SelectedValue);
        }

        DataRow[] defin = this.CurrentRepParamsDefinition.Select("ParameterID = '" + ParameterWhereNames.EmployeePosition + "'");
        if (defin.Length == 0) return;

        this.DdlEmployeePosition.Items.Clear();

        string filter = string.Empty;
        if (sectorCode != -1)
            filter = "relevantSector = " + sectorCode.ToString();
        else
            filter = " ";

        UIHelper.BindDropDownToCachedTable(DdlEmployeePosition,
                eCachedTables.View_Positions.ToString(),
                filter,
                defin[0]["LookupDescriptionField"] as string);

        ListItem defaultItem = new ListItem(defin[0]["AppDefaultItemDescription"] as string, "-1");
        this.DdlEmployeePosition.Items.Insert(0, defaultItem);
    }

    private void BindDDlAgreementType()
    {
        List<Enums.SearchMode> membership = this.lstMembership.SelectedSearchModes;

        DataRow[] defin = this.CurrentRepParamsDefinition.Select("ParameterID = '" + ParameterWhereNames.AgreementType + "'");
        if (defin.Length == 0) return;

        string filter = string.Empty;

        //Facade applicFacade = Facade.getFacadeObject();
        //DataSet ds = applicFacade.getGeneralDataTable(DataTableName);

        foreach (Enums.SearchMode mode in membership)
        {
            switch (mode)
            {
                case Enums.SearchMode.All:
                    break;
                case Enums.SearchMode.Community:
                    //filter += "1,2,6,";
                    filter += GetAgreementTypesAccordingToSearchMode((int)Enums.SearchMode.Community);
                    break;
                case Enums.SearchMode.Mushlam:
                    //filter += "3,4,";
                    filter += GetAgreementTypesAccordingToSearchMode((int)Enums.SearchMode.Mushlam);
                    break;
                case Enums.SearchMode.Hospitals:
                    filter += GetAgreementTypesAccordingToSearchMode((int)Enums.SearchMode.Hospitals);
                    break;
                default:
                    break;
            }
        }
        if (filter.Length > 0)
        {
            filter = filter.Remove(filter.Length - 1);
            filter = "AgreementTypeID in (" + filter + ")";
        }

        this.ddlAgreementType.Items.Clear();
        UIHelper.BindDropDownToCachedTable(this.ddlAgreementType,
                eCachedTables.DIC_AgreementTypes.ToString(),
                filter,
                defin[0]["LookupDescriptionField"] as string);

        ListItem defaultItem = new ListItem(defin[0]["AppDefaultItemDescription"] as string, "-1");
        this.ddlAgreementType.Items.Insert(0, defaultItem);
    }

    // Bind DropDownList To CachedTable by DataRow with parameter Definition
    private bool BindDropDownToCachedTable(DataRow paramDefinition, string filter, bool IsIndependentParamOnly)//bool defaultItemOnly,
    {
        //paramDefinitionRow 
        string parameterID = paramDefinition["ParameterID"] as string;
        if (!this.paramControlsDictionary.ContainsKey(parameterID))
            return false;

        DropDownList ddlParam = (DropDownList)this.paramControlsDictionary[parameterID][1];
        ddlParam.Items.Clear();

        ddlParam.DataValueField = paramDefinition["LookupValueField"] as string;
        ddlParam.DataTextField = paramDefinition["LookupDescriptionField"] as string;

        string lookupTable = paramDefinition["LookupTable"] as string;
        string dependensOn = paramDefinition["DependsOnParam"] as string;

        if (//!defaultItemOnly &&
            lookupTable != null &&
            (string.IsNullOrEmpty(dependensOn) || !IsIndependentParamOnly)) // parameterControl is inDependent
        {
            UIHelper.BindDropDownToCachedTable(ddlParam, lookupTable, filter, paramDefinition["LookupDescriptionField"] as string);
        }

        //-- add default item
        string defItemText = paramDefinition["AppDefaultItemDescription"] as string;
        if (defItemText != null)
        {
            ListItem defItem = new ListItem(defItemText, "-1");
            ddlParam.Items.Insert(0, defItem);
        }

        //-- select default item
        string selectedCodesStr = paramDefinition["AppDefaultSelectedCodes"] as string;
        if (string.IsNullOrWhiteSpace(selectedCodesStr))
            return false;

        string[] selectedCodesArr = selectedCodesStr.Split(new char[] { ',', ';' });
        if (selectedCodesArr.Length == 0)
            return false;

        ListItem selectedItem = ddlParam.Items.FindByValue(selectedCodesArr[0]);
        if (selectedItem != null)
        {
            ddlParam.SelectedValue = selectedItem.Value;
        }

        return true;
    }

    private bool InitTextBoxControl(DataRow paramDefinition)
    {
        string parameterID = paramDefinition["ParameterID"] as string;
        string defSelectedCodes = paramDefinition["AppDefaultSelectedCodes"] as string;
        string defSelectedNames = paramDefinition["AppDefaultSelectedNames"] as string;
        return this.InitTextBoxControl(parameterID, defSelectedCodes, defSelectedNames);
    }

    private bool InitTextBoxControl(string parameterID)
    {
        return this.InitTextBoxControl(parameterID, null, null);
    }

    private bool InitTextBoxControl(string parameterID, string defSelectedCodes, string defSelectedNames)
    {
        //string parameterID = paramDefinition["ParameterID"] as string;
        if (!this.paramControlsDictionary.ContainsKey(parameterID))
            return false;

        // parameterCodes control
        TextBox param = this.paramControlsDictionary[parameterID][1] as TextBox;
        if (param != null)
            param.Text = defSelectedCodes;

        // parameterNames control
        if (this.paramControlsDictionary[parameterID].Length >= 3)
        {
            param = this.paramControlsDictionary[parameterID][2] as TextBox;
            if (param != null)
                param.Text = defSelectedNames;
        }



        return true;
    }

    private bool EnableTextBoxControl(string parameterID, bool enabled)
    {
        //string parameterID = paramDefinition["ParameterID"] as string;
        if (!this.paramControlsDictionary.ContainsKey(parameterID))
            return false;

        // parameterCodes control
        HtmlTableRow param = this.paramControlsDictionary[parameterID][0] as HtmlTableRow;
        if (param != null)
            param.Disabled = !enabled;

        TextBox textDiscr = this.paramControlsDictionary[parameterID][2] as TextBox;
        if (textDiscr != null)
            textDiscr.Enabled = enabled;

        HtmlInputImage button = this.paramControlsDictionary[parameterID][3] as HtmlInputImage;
        if (button != null)
            button.Disabled = !enabled;
        return true;
    }

    private bool InitCheckBoxListControl(DataRow paramDefinition)
    {
        string parameterID = paramDefinition["ParameterID"] as string;
        string defSelectedCodes = paramDefinition["AppDefaultSelectedCodes"] as string;
        string defSelectedNames = paramDefinition["AppDefaultSelectedNames"] as string;

        if (!this.paramControlsDictionary.ContainsKey(parameterID))
            return false;

        // parameterCodes control
        UserControls_SearchModeSelector param = this.paramControlsDictionary[parameterID][1] as UserControls_SearchModeSelector;
        if (param != null)
        {
            //param.SelectedIndexChanged += new EventHandler(this.Membership_SelectedIndexChanged);
            param.SelectedCodes = defSelectedCodes;
        }
        return true;
    }

    //private bool InitCheckBoxControl(string parameterID)
    private bool InitCheckBoxControl(DataRow paramDefinition)

    {
        string parameterID = paramDefinition["ParameterID"] as string;
        if (!this.paramControlsDictionary.ContainsKey(parameterID))
            return false;

        // parameterCodes control
        CheckBox param = this.paramControlsDictionary[parameterID][1] as CheckBox;
        if (param != null)
            param.Checked = false;

        //// parameterNames control
        //if (this.paramControlsDictionary[parameterID].Length >= 3)
        //{
        //    param = this.paramControlsDictionary[parameterID][2] as TextBox;
        //    if (param != null)
        //        param.Text = defSelectedNames;
        //}



        return true;
    }

    //----------- BindWhereParamControls ------
    private void VisibleRelevantWhereParamControls()
    {
        //--- un visible all parameterControls
        foreach (Control[] controls in this.paramControlsDictionary.Values)
        {
            ((HtmlTableRow)controls[0]).Style.Add("display", "none");
        }

        //--- visible current report relevant parameterControls
        //--- disabled current report relevant parameterControls  
        DataRow[] selRows = this.CurrentRepParamsDefinition.Select();
        if (selRows != null && selRows.Length > 0)
        {
            foreach (DataRow row in selRows)
            {
                string parameterID = (string)row["ParameterID"];
                if (!this.paramControlsDictionary.ContainsKey(parameterID))
                    continue;

                HtmlTableRow tableRow = (HtmlTableRow)this.paramControlsDictionary[parameterID][0];
                tableRow.Style.Add("display", "inline");

                //if ((byte?)row["AppControlEnabled"] == 1)
                //{
                //    tableRow.Disabled = false;
                //}
                //else if ((byte?)row["AppControlEnabled"] == 2)
                //{
                //    tableRow.Disabled = true;
                //}
            }
        }
    }

    private void InitWhereParamControls(bool IsIndependentParamOnly)
    {
        //bind parameters need be represented as Single selection control(dropDownList).
        DataRow[] selRows = this.CurrentRepParamsDefinition.Select("AppControlType = 1 and AppControlEnabled >= 1");
        if (selRows != null && selRows.Length > 0)
        {
            foreach (DataRow row in selRows)
            {
                this.BindDropDownToCachedTable(row, string.Empty, IsIndependentParamOnly);
            }
        }

        //set Status default
        //this.ddlStatus.SelectedValue = "1";

        //bind parameters need be represented as Multi selection control(MultiLine TextBox).
        selRows = this.CurrentRepParamsDefinition.Select("AppControlType = 2 or AppControlType = 3 and AppControlEnabled >= 1");
        if (selRows != null && selRows.Length > 0)
        {
            foreach (DataRow row in selRows)
            {
                this.InitTextBoxControl(row);
            }
        }

        //bind parameters need be represented as checkBoxList control( SearchModeSelector ).
        selRows = this.CurrentRepParamsDefinition.Select("AppControlType = 4 and AppControlEnabled >= 1");
        if (selRows != null && selRows.Length > 0)
        {
            foreach (DataRow row in selRows)
            {
                this.InitCheckBoxListControl(row);
            }
        }
        // bind checkbox
        selRows = this.CurrentRepParamsDefinition.Select("AppControlType = 5 and AppControlEnabled >= 1");
        if (selRows != null && selRows.Length > 0)
        {
            foreach (DataRow row in selRows)
            {
                this.InitCheckBoxControl(row);
            }
        }
    }

    #endregion Controls Binding

    #region -------------- Get from DataBase -----------

    /// initialize Report Field list -- this.CurrentReportFields from DataBase; 
    private DataTable GetReportFieldsDefinition()
    {
        //DataTable dt = null;
        DataSet dsReportFields = new DataSet();

        Facade applicFacade = Facade.getFacadeObject();
        int ReportType = int.Parse(ddlReport.SelectedValue);

        applicFacade.GetReportFields(ref dsReportFields, ReportType);
        if (dsReportFields != null && dsReportFields.Tables.Count > 0 && dsReportFields.Tables[0].Rows.Count > 0)
        {
            // this.CurrentReportFields = dsReportFields.Tables[0];

            //DataRow[] rows = dsReportFields.Tables[0].Select("Visible = 1");
            //if (rows != null && rows.Length > 0)
            //{
            //    dt = rows.CopyToDataTable();
            //}
            return dsReportFields.Tables[0];
        }
        return null;
    }

    /// initialize Report Where Parameters list -- this.CurrentReportParams from DataBase
    private DataTable GetWhereParametersDefinition()
    {
        //DataTable dt = null;
        DataSet dsReportParam = new DataSet();

        Facade applicFacade = Facade.getFacadeObject();
        int ReportType = int.Parse(ddlReport.SelectedValue);

        applicFacade.GetReportParameters(ref dsReportParam, ReportType);
        if (dsReportParam != null && dsReportParam.Tables.Count > 0 && dsReportParam.Tables[0].Rows.Count > 0)
        {
            return dsReportParam.Tables[0];
        }
        return null;
    }

    #endregion Get from DataBase
}

