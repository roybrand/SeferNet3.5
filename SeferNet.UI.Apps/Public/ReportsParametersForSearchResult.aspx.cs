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

public partial class Reports_ReportsParametersForSearchResult : AdminBasePage
{
    string _pageName = string.Empty;

    private Dictionary<string, Control[]> paramControlsDictionary;
    private bool AttributedToPerson = false;

    #region ------------ Properties ----------------

    public Hashtable ParamsWhere
    {
        get
        {
            Hashtable paramsWhere = new Hashtable();

            DataTable SelectedCodesTable = (DataTable)Session["AllSelectedCodesList"];

            if (Convert.ToInt32(Session["reportNum"]) == 100)
            {
                string CodesListParamName = "CodesList";
                string CodesListParamValue = string.Empty;

                if (SelectedCodesTable.Rows.Count > 0)
                {
                    foreach (DataRow dr in SelectedCodesTable.Rows)
                    {
                        CodesListParamValue = CodesListParamValue + dr["ID"].ToString() + ',';
                    }
                }
                else
                {
                    CodesListParamValue = "0";
                }

                paramsWhere.Add(CodesListParamName, CodesListParamValue);
            }

            else if (Convert.ToInt32(Session["reportNum"]) == 101)
            {
                string DeptCodesListParamName = "DeptCodesList";
                string DeptCodesListParamValue = string.Empty;
                string ServiceListParamName = "ServiceList";
                string ServiceListParamValue = string.Empty;
                string DeptEmployeeListParamName = "DeptEmployeeList";
                string DeptEmployeeListParamValue = string.Empty;
                string ServiceOrEventListParamName = "ServiceOrEventList";
                string ServiceOrEventListParamValue = string.Empty;

                if (SelectedCodesTable.Rows.Count > 0)
                {
                    foreach (DataRow dr in SelectedCodesTable.Rows)
                    {
                        if (SelectedCodesTable.Columns.Count == 1)
                        {
                            DeptCodesListParamValue = DeptCodesListParamValue + "," + Convert.ToString(dr[0]);
                        }
                        else
                        {
                            AttributedToPerson = true;
                            ServiceListParamValue = ServiceListParamValue + "," + Convert.ToString(dr[0]);
                            DeptEmployeeListParamValue = DeptEmployeeListParamValue + "," + Convert.ToString(dr[1]);
                            ServiceOrEventListParamValue = ServiceOrEventListParamValue + "," + Convert.ToString(dr[2]);
                        }
                    }
                }

                //else
                //{
                //    DeptCodesListParamValue = "0";
                //    ServiceListParamValue = "0";
                //    DeptEmployeeListParamValue = "0";
                //    ServiceOrEventListParamValue = "0";               
                //}

                paramsWhere.Add(DeptCodesListParamName, DeptCodesListParamValue);
                paramsWhere.Add(ServiceListParamName, ServiceListParamValue);
                paramsWhere.Add(DeptEmployeeListParamName, DeptEmployeeListParamValue);
                paramsWhere.Add(ServiceOrEventListParamName, ServiceOrEventListParamValue);
            }

            return paramsWhere;
        }
    }

     public string[] GetSelectedFields
    {
        get
        {
            return this.SelectedFields.ToArray();
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
                DataTable dt = this.GetReportFieldsDefinition(Convert.ToInt32(Session["reportNum"]));
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
                DataTable dt = this.GetWhereParametersDefinition((int)Session["reportNum"]);
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

            if (!Page.IsPostBack)
            {
                this.divRepFields.Style["height"] = "440px";
   
                if (Request.QueryString["reportNum"] != null)
                {
                    Session["reportName"] = Request.QueryString["reportName"].ToString();
                    Session["reportNum"] = Request.QueryString["reportNum"].ToString();
                }

                this.SaveParamSelectedValues();

                this.BuildReportFieldListBox(false);
                this.SetDblClickAttributeOnListBoxes();
            }

            else if (this.IsCrossPagePostBack)
            {
                this.SaveSelectedFields();
            }
            else
            {
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
        if (this.SelectedFields.Count > 0)
        {
            this.SelectedFields.RemoveRange(0, this.SelectedFields.Count - 1);
        }

        this.RestoreParamSelectedValues(false);

        this.RestoreParamSelectedValues(true);

        // initalize fields
        this.BuildReportFieldListBox(true);
        this.SetDblClickAttributeOnListBoxes();
    }

    protected void btnExcel_Click(object sender, EventArgs e)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "CreateExcel", "CreateExcel();", true);

        this.SaveParamSelectedValues();
        this.SaveSelectedFields();
        //Session["ParamsWhere"] = ParamsWhere;
    }

    #endregion Page and Controls Events

    #region --------------Utils ------------

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


    private void SaveParamSelectedValues()
    {
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
    }


    #endregion Utils

    #region  --------------- Controls Binding ---------------

    private void BuildReportFieldListBox(bool deselectAllItems)
    {
        ListItem li = null;
        int i = -1;
        string selected = string.Empty;

        this.lstReportFields.Items.Clear();
        this.lstSelectedFields.Items.Clear();

        DataTable DT = this.CurrentRepFieldsDefinition;
        if (DT == null) return;

        DataView dv = new DataView(DT);

        if (Convert.ToInt32(Session["reportNum"]) == 101 && AttributedToPerson == false)
        {
            dv.RowFilter = "AttributedToPerson is null"; // query example = "id = 10"
        }

        DataTable dt = dv.ToTable();

        for (i = 0; i < dt.Rows.Count; i++)
        {
            //if ( 1 == 1)
            //{ 
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
            //}

        }
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

    #endregion Controls Binding

    #region -------------- Get from DataBase -----------

    /// initialize Report Field list -- this.CurrentReportFields from DataBase; 
    private DataTable GetReportFieldsDefinition(int ReportType)
    {
        //DataTable dt = null;
        DataSet dsReportFields = new DataSet();

        Facade applicFacade = Facade.getFacadeObject();

        applicFacade.GetReportFields(ref dsReportFields, ReportType);
        if (dsReportFields != null && dsReportFields.Tables.Count > 0 && dsReportFields.Tables[0].Rows.Count > 0)
        {
            return dsReportFields.Tables[0];
        }
        return null;
    }

    /// initialize Report Where Parameters list -- this.CurrentReportParams from DataBase
    private DataTable GetWhereParametersDefinition(int ReportType)
    {
        //DataTable dt = null;
        DataSet dsReportParam = new DataSet();

        Facade applicFacade = Facade.getFacadeObject();

        applicFacade.GetReportParameters(ref dsReportParam, ReportType);
        if (dsReportParam != null && dsReportParam.Tables.Count > 0 && dsReportParam.Tables[0].Rows.Count > 0)
        {
            return dsReportParam.Tables[0];
        }
        return null;
    }

    #endregion Get from DataBase
}

