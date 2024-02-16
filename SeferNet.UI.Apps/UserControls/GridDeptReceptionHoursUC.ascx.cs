using System;
using System.Collections;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.FacadeLayer;
using System.Globalization;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using System.Web.UI.HtmlControls;

public partial class UserControls_GridDeptReceptionHoursUC : System.Web.UI.UserControl
{
    private int _selectedDept = -1;

    private DataTable _dtData = null;
    private DataTable _dtOriginalData = null;

    //public delegate void SelectDeptEventHandler(object sender, EventArgs e);
    //public event SelectDeptEventHandler selectDept;
    private bool _isNewRowAdded = false;
    private int EditingIndex = -1;
    private int _lastAddedIndex = 0;

    #region Properies

    public int LastAddedIndex
    {
        get
        {
            object obj = GetObjectFromViewState("LastAddedIndex");

            if (obj != null)
                return (int)obj;
            else
                return -1;
        }
        set
        {
            this._lastAddedIndex = value;
            SetObjectToViewState("LastAddedIndex", _lastAddedIndex);
        }
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

    #region WidthColumns
    public Unit WidthDaysColumn
    {
        set
        {
            this.dgReceptionHours.Columns[1].ItemStyle.Width = value;
        }
    }
    public Unit WidthFromHourColumn
    {
        set
        {
            this.dgReceptionHours.Columns[2].ItemStyle.Width = value;
        }
    }
    public Unit WidthToHourColumn
    {
        set
        {
            this.dgReceptionHours.Columns[3].ItemStyle.Width = value;
        }
    }
    public Unit WidthRemarksColumn
    {
        set
        {
            this.dgReceptionHours.Columns[4].ItemStyle.Width = value;
        }
    }
    public Unit WiidthValidFromColumn
    {
        set
        {
            this.dgReceptionHours.Columns[5].ItemStyle.Width = value;
        }
    }
    public Unit WidthValidToColumn
    {
        set
        {
            this.dgReceptionHours.Columns[6].ItemStyle.Width = value;
        }
    }
    public Unit WidthButtonsColumn
    {
        set
        {
            this.dgReceptionHours.Columns[7].ItemStyle.Width = value;
        }
    }

    #endregion

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

    private Hashtable GetViewStateHashTable()
    {
        string key = this.Page.ClientID + this.ClientID;
        Hashtable hTbl = null;

        if (ViewState[key] == null)
        {
            hTbl = new Hashtable();
            ViewState[key] = hTbl;
        }
        else
        {
            hTbl = (Hashtable)ViewState[key];
        }
        return hTbl;
    }

    public DataTable dtOriginalData
    {
        get
        {
            object obj = GetObjectFromViewState("OriginalData");

            if (obj != null)
                return (DataTable)obj;
            else
                return null;
        }
        set
        {
            int counter = 0;
            this._dtOriginalData = value;

            if (!_dtOriginalData.Columns.Contains("ID_Original"))
                _dtOriginalData.Columns.Add("ID_Original");

            foreach (DataRow row in _dtOriginalData.Rows)
            {
                row["ID_Original"] = counter;
                counter++;
            }

            if (!_dtOriginalData.Columns.Contains("Add_ID"))
            {
                _dtOriginalData.Columns.Add("Add_ID");
            }

            SetObjectToViewState("OriginalData", _dtOriginalData);
        }
    }

    public bool NewRowAdded
    {
        get
        {
            object obj = GetObjectFromViewState("NewRowAdded");

            if (obj != null)
                return Convert.ToBoolean(obj);
            else
                return false;
        }
        set
        {
            this._isNewRowAdded = value;
            SetObjectToViewState("NewRowAdded", _isNewRowAdded);
        }
    }

    private void AddEmptyRow(ref DataTable dtOriginalData)
    {
        DataRow newRow = dtOriginalData.NewRow();
        //newRow.RowState = DataRowState.Added;       
        dtOriginalData.Rows.Add(newRow);
        this.NewRowAdded = true;
    }

    public Unit Width
    {
        get
        {
            return this.dgReceptionHours.Width;
        }
        set
        {
            this.dgReceptionHours.Width = value;
        }
    }

    #region Properties RemarksHiddens
    // I need this properties for save on client added new remark and to see this on server 
    // I need this properties for save on client added new remark and to see this on server 
    public string HdnRemarkText
    {
        get
        {
            GridViewRow header = dgReceptionHours.HeaderRow;
            if (header != null)
            {
                HiddenField hdnRemarkText = header.FindControl("hdnRemarkText") as HiddenField;
                return hdnRemarkText.ClientID;
            }
            else
                return String.Empty;
        }
    }
    public string HdnRemarkMask
    {
        get
        {
            GridViewRow header = dgReceptionHours.HeaderRow;
            if (header != null)
            {
                HiddenField hdnRemarkMask = header.FindControl("hdnRemarkMask") as HiddenField;
                return hdnRemarkMask.ClientID;
            }
            else
                return String.Empty;
        }
    }
    public string HdnRemarkID
    {
        get
        {
            GridViewRow header = dgReceptionHours.HeaderRow;
            if (header != null)
            {
                HiddenField hdnRemarkID = header.FindControl("hdnRemarkID") as HiddenField;
                return hdnRemarkID.ClientID;
            }
            else
                return String.Empty;
        }
    }
    public string HdnRemarkHtml
    {
        get
        {
            GridViewRow header = dgReceptionHours.HeaderRow;
            if (header != null)
            {
                HiddenField hdnRemarkHtml = header.FindControl("hdnRemarkHtml") as HiddenField;
                return hdnRemarkHtml.ClientID;
            }
            else
                return String.Empty;
        }
    }

    //**************** EditHiddenRemarks 
    public string HdnRemarkText_E
    {
        get
        {
            //if (EditingIndex > -1)
            //{
            //GridViewRow row = dgReceptionHours.Rows[EditingIndex];
            //HiddenField hdnRemarkText = row.FindControl("hdnRemarkText_E") as HiddenField;
            return this.hdnRemarkText_E.ClientID;
            //}
            //else
            //    return String.Empty;
        }
    }
    public string HdnRemarkMask_E
    {
        get
        {
            // if (EditingIndex > -1)
            //{
            //GridViewRow row = dgReceptionHours.Rows[EditingIndex];
            //HiddenField hdnRemarkMask = row.FindControl("hdnRemarkMask_E") as HiddenField;
            return hdnRemarkMask_E.ClientID;
            //     }
            //else
            //    return String.Empty;
        }
    }
    public string HdnRemarkID_E
    {
        get
        {
            // if (EditingIndex > -1)
            //{
            //GridViewRow row = dgReceptionHours.Rows[EditingIndex];
            //HiddenField hdnRemarkID = row.FindControl("hdnRemarkID_E") as HiddenField;
            return hdnRemarkID_E.ClientID;
            //     }
            //else
            //    return String.Empty;
        }
    }
    public string HdnRemarkHtml_E
    {
        get
        {
            //     if (EditingIndex > -1)
            //    {
            //GridViewRow row = dgReceptionHours.Rows[EditingIndex];
            //HiddenField hdnRemarkHtml = row.FindControl("hdnRemarkHtml_E") as HiddenField;
            return hdnRemarkHtml_E.ClientID;
            //}
            // else
            //     return String.Empty;
        }
    }

    #endregion

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager sm = ScriptManager.GetCurrent(Page);
        bool ff = sm.IsInAsyncPostBack;

        if (!Page.IsPostBack && ff == false)
        {
            CultureInfo myCIintl = new CultureInfo("he-IL", false);
            //BindData(_dtData);         
        }


    }

    #region Days
    private string ReturnDays(string dayNumber)
    {
        string day = String.Empty;

        if (!string.IsNullOrEmpty(dayNumber))
        {
            DataTable tblReceptionDays = GetReceptionDaysTable();

            DataRow[] rows = tblReceptionDays.Select("ReceptionDayCode = " + dayNumber);
            if (rows != null)
            {
                day = rows[0][1].ToString();
            }
        }

        return day;
    }

    /// <summary>
    /// function that translates days from dayCodes
    /// </summary>
    /// <returns></returns>
    protected DataTable GetReceptionDaysTable()
    {
        DataTable tbl = null;
        try
        {
            ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
            tbl = cacheHandler.getCachedDataTable(eCachedTables.DIC_ReceptionDays.ToString());
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
        return tbl;
    }

    #endregion   

    private bool isThisRowHeader(GridViewRow row)
    {
        int indx = row.RowIndex;
        if (indx > -1)
            return true;
        else
            return false;
    }

    #region Grid events
    private void GetNewReceptionValues(ref string selectedDays, ref string fromHour, ref string toHour,
        ref Hashtable hTblNewRemark, ref string fromDate,
         ref string toDate, GridViewRow row, bool isEditMode)
    {
        #region declaration

        UserControls_MultiDDlSelectUC MultiDDlSelect_Days = null;
        TextBox txtToDate = null;
        TextBox txtFromDate = null;
        TextBox txtFromHour = null;
        TextBox txtToHour = null;
        HiddenField hdnRemarkText = null;
        HiddenField hdnRemarkMask = null;
        HiddenField hdnRemarkID = null;
        HiddenField hdnRemarkHtml = null;
        #endregion

        if (!isEditMode)
        {
            MultiDDlSelect_Days = row.FindControl("MultiDDlSelect_Days") as UserControls_MultiDDlSelectUC;
            txtToDate = row.FindControl("txtToDate") as TextBox;
            txtFromDate = row.FindControl("txtFromDate") as TextBox;
            txtFromHour = row.FindControl("txtFromHour") as TextBox;
            txtToHour = row.FindControl("txtToHour") as TextBox;
            hdnRemarkText = row.FindControl("hdnRemarkText") as HiddenField;
            hdnRemarkMask = row.FindControl("hdnRemarkMask") as HiddenField;
            hdnRemarkID = row.FindControl("hdnRemarkID") as HiddenField;
            hdnRemarkHtml = row.FindControl("hdnRemarkHtml") as HiddenField;
        }
        else // mode edit
        {
            MultiDDlSelect_Days = row.FindControl("mltDdlDayE") as UserControls_MultiDDlSelectUC;
            txtToDate = row.FindControl("txtToDate") as TextBox;
            txtFromDate = row.FindControl("txtFromDate") as TextBox;
            txtFromHour = row.FindControl("txtFromHour") as TextBox;
            txtToHour = row.FindControl("txtToHour") as TextBox;
            hdnRemarkText = hdnRemarkText_E;
            hdnRemarkMask = hdnRemarkMask_E;
            hdnRemarkID = hdnRemarkID_E;
            hdnRemarkHtml = hdnRemarkHtml_E;
        }

        if (MultiDDlSelect_Days != null)
        {
            GetDays(ref selectedDays, MultiDDlSelect_Days);
        }

        if (txtToDate != null)
        {
            toDate = GetToDate(txtToDate);
        }
        if (txtFromDate != null)
        {
            //fromDate = GetToDate(txtFromDate);
             fromDate = GetToDate(txtFromDate);
            if (fromDate.ToString().Trim() == String.Empty)
            {
                fromDate = DateTime.Today.ToShortDateString();
            }
        }

        if (txtFromHour != null)
        {
            fromHour = GetToDateNew(txtFromHour);
        }

        if (txtToHour != null)
        {
            toHour = GetToDate(txtToHour);
        }

        if (hdnRemarkText != null)
        {
            GetRemark(ref hTblNewRemark, "remarkText", hdnRemarkText.Value);
            hdnRemarkText.Value = String.Empty;
        }
        if (hdnRemarkMask != null)
        {
            GetRemark(ref hTblNewRemark, "remarkMask", hdnRemarkMask.Value);
            hdnRemarkMask.Value = String.Empty;
        }
        if (hdnRemarkID != null)
        {
            GetRemark(ref hTblNewRemark, "remarkID", hdnRemarkID.Value);
            hdnRemarkID.Value = String.Empty;
        }
        if (hdnRemarkHtml != null)
        {
            GetRemark(ref hTblNewRemark, "remarkHtml", hdnRemarkHtml.Value);
            hdnRemarkHtml.Value = String.Empty;
        }
    }

    private void GetRemark(ref Hashtable hTblNewRemark, string key, string hValue)
    {
        hTblNewRemark.Add(key, this.Page.Server.UrlDecode(hValue));
    }

    #region Get new added values
    private string GetToDate(TextBox txtToDate)
    {
        string toDate = this.Request.Params[txtToDate.UniqueID].ToString();
        return toDate;
    }

    private string GetToDateNew(TextBox txtToDate)
    {
        string temp = txtToDate.UniqueID;

        string toDate = this.Request.Params[txtToDate.UniqueID].ToString();
        return toDate;
    }

    private void GetDays(ref string selectedDays, UserControls_MultiDDlSelectUC MultiDDlSelect_Days)
    {
        SortedList tbl = MultiDDlSelect_Days.SelectedItems;
        if (tbl != null && tbl.Count > 0)
        {
            IDictionaryEnumerator enm = tbl.GetEnumerator();
            while (enm.MoveNext())
            {
                selectedDays += enm.Key + ",";
            }
            selectedDays = selectedDays.Remove(selectedDays.Length - 1, 1);
        }
    }

    #endregion

    //private void CloseMddlItems(UserControls_MultiselectDropDownListBox mltDdl)
    //{
    //    string ctlID = mltDdl.ImageUpDownClientID;

    //    string var = "  var btn = document.getElementById('" + ctlID + "'); if(btn!= null) {  btn.click();} ";
    //    UpdatePanel UpdatePanel1 = this.Parent.Parent as UpdatePanel;
    //    ScriptManager.RegisterClientScriptBlock(UpdatePanel1, typeof(UpdatePanel), "JsVariableValidationKey_" + ctlID + "_close", var, true);

    //}

    public GridView get_dgReceptionHours
    {
        get
        {
            return dgReceptionHours;
        }
    }

    public override void DataBind()
    {
        //if(this.SourceData != null)
        if (dtOriginalData != null)
            this.BindData(dtOriginalData);
    }


    private void BindData(DataTable dtData)
    {
        try
        {
            CheckEmptyRow(ref dtData);
            dgReceptionHours.DataSource = null;
            DataView dv = dtData.DefaultView;
            if (dv != null)
                dv.Sort = "ReceptionDay ,openingHour";
            dgReceptionHours.DataSource = dv;
            dgReceptionHours.DataBind();
            hfUpdateFlag.Value = "";
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void CheckEmptyRow(ref DataTable dtData)
    {
        int count = 0;
        DataRow emptyRow = null;

        if (dtData.Rows.Count == 0)
        {
            AddEmptyRow(ref dtData);
        }
        else
        {
            if (this.NewRowAdded && dtData.Rows.Count > 1)
            {
                foreach (DataRow curRow in dtData.Rows)
                {
                    if (curRow.RowState == DataRowState.Added)
                    {
                        foreach (DataColumn curColumn in curRow.Table.Columns)
                        {
                            if (curRow.IsNull(curColumn))
                            {
                                count++;
                                if ((count + 2) == dtData.Columns.Count)//because ID = 0 and count = dtData.Columns.Count - 1;
                                {
                                    emptyRow = curRow;
                                    break;
                                }
                            }
                        }
                    }
                }
                if (emptyRow != null)
                {
                    dtData.Rows.Remove(emptyRow);
                    this.NewRowAdded = false;
                }
            }

            //if (dtData.Rows.Count > 0)
            //{
            //    if (dtData.Rows[0]["ID"].ToString() == "2")
            //    {
            //        dtData.Rows[0]["ID"] = "1";
            //    }
            //}
        }
    }

    private void BuildGridRow(GridViewRowEventArgs e)
    {
        try
        {
            Label lblDays = e.Row.FindControl("lblDays") as Label;
            Label lblDays2 = e.Row.FindControl("lblDays2") as Label;
            Label lblRemark = e.Row.FindControl("lblRemark") as Label;
            Label lblValidFrom = e.Row.FindControl("lblValidFrom") as Label;
            Label lblValidTo = e.Row.FindControl("lblValidTo") as Label;


            object[] data = ((System.Data.DataRowView)(e.Row.DataItem)).Row.ItemArray;

            if (lblRemark != null)
            {
                lblRemark.Text = lblRemark.Text.Replace("#", "");
            }

            string day = String.Empty;
            if (data != null)
            {
                if (lblDays != null)
                {
                    day = ReturnDays(((System.Data.DataRowView)(e.Row.DataItem))["ReceptionDay"].ToString());
                    if (day != string.Empty)
                    {
                        lblDays2.Text = lblDays.Text = day;
                    }
                    else
                    {
                        e.Row.Visible = false;
                        return;
                    }
                }

                #region Dates
                if (lblValidFrom != null)
                {
                    string from = String.Format("{0:dd/MM/yyyy}", ((System.Data.DataRowView)(e.Row.DataItem))["ValidFrom"].ToString());
                    if (from != string.Empty)
                    {
                        DateTime dateFrom = Convert.ToDateTime(from);
                        lblValidFrom.Text = dateFrom.ToShortDateString();
                    }
                }

                if (lblValidTo != null)
                {
                    string to = String.Format("{0:dd/MM/yyyy}", ((System.Data.DataRowView)(e.Row.DataItem))["ValidTo"].ToString());
                    if (to != String.Empty)
                    {
                        DateTime dateTo = Convert.ToDateTime(to);
                        lblValidTo.Text = dateTo.ToShortDateString();
                    }
                }
                #endregion
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }
    private void BuildGridHeader(GridViewRowEventArgs e, DataTable dtDeptEmployeeData)
    {
        #region Header

        TextBox txtFromDate = e.Row.FindControl("txtFromDate") as TextBox;
        if (txtFromDate != null)
        {
            txtFromDate.Text = DateTime.Today.ToString();
            txtFromDate.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtFromDate.ClientID + "')";
        }

        if (dgReceptionHours.EditIndex == -1)
            SetFromToClientsIdsToHiddenFields(e.Row);

        #endregion
    }

    //function for custom validation of hours 
    private void SetFromToClientsIdsToHiddenFields(GridViewRow row)
    {
        TextBox txtFromHour = row.FindControl("txtFromHour") as TextBox;
        TextBox txtToHour = row.FindControl("txtToHour") as TextBox;

        if (txtFromHour != null)
        {
            hdnHeaderFromHourClientID.Value = txtFromHour.ClientID;
        }

        if (txtToHour != null)
        {
            hdnHeaderToHourClientID.Value = txtToHour.ClientID;
        }

        TextBox txtFromDate = row.FindControl("txtFromDate") as TextBox;
        if (txtFromDate != null)
        {
            hdnHeaderValidFromClientID.Value = txtFromDate.ClientID;
        }

        TextBox txtToDate = row.FindControl("txtToDate") as TextBox;
        if (txtToDate != null)
        {
            hdnHeaderValidToClientID.Value = txtToDate.ClientID;
        }
    }

    protected void dgReceptionHours_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            BuildGridHeader(e, this.dtOriginalData);
        }
        else if (e.Row.RowType == DataControlRowType.DataRow)
        {
            BuildGridRow(e);
        }
    }
    protected void dgReceptionHours_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        dgReceptionHours.EditIndex = -1;
        dgReceptionHours.DataSource = this.dtOriginalData;   //set the data table to data source of GridView again here
        DataBind();
    }

    #endregion

    #region Buttons clicks

    protected void imgSave_Click(object sender, EventArgs e)
    {
        try
        {
            GridViewRow row = ((System.Web.UI.WebControls.Button)(sender)).Parent.Parent as GridViewRow;
            if (row != null)
            {
                if (!openHoursVsCloseHoursOK(row))
                    return;
                SaveRow(row);
                hfUpdateFlag.Value = "1";
                hdnEnableOverMidnightHours.Value = String.Empty;
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private bool openHoursVsCloseHoursOK(GridViewRow row)
    {
        TextBox txtFromHour = row.FindControl("txtFromHour") as TextBox;
        TextBox txtToHour = row.FindControl("txtToHour") as TextBox;
        if (txtFromHour.Text != string.Empty && txtToHour.Text != string.Empty)
        {
            //If txtToHour < "04:00" then it considered to be "over midnight hours"
            if (Convert.ToDateTime(txtFromHour.Text) < Convert.ToDateTime(txtToHour.Text)
                    || Convert.ToDateTime(txtToHour.Text) <= Convert.ToDateTime("04:00"))

                return true;
            //else if (hdnEnableOverMidnightHours.Value != null && hdnEnableOverMidnightHours.Value != string.Empty)
            //{
            //    if (Convert.ToBoolean(hdnEnableOverMidnightHours.Value) == true)
            //        return true;
            //    else
            //        return false;
            //}
            else if (txtSelectedEnableOverMidnightHours_FromDialog.Text != null && txtSelectedEnableOverMidnightHours_FromDialog.Text != string.Empty)
            {
                if (Convert.ToBoolean(txtSelectedEnableOverMidnightHours_FromDialog.Text) == true)
                    return true;
                else
                    return false;
            }


            else
                return false;
        }
        else
            return false;
    }

    protected void imgDelete_Click(object sender, ImageClickEventArgs e)
    {
        try
        {
            GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
            if (row != null)
            {
                DeleteRow(row);
                DataBind();
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void imgAdd_Click(object sender, EventArgs e)
    {
        try
        {
            GridViewRow header = dgReceptionHours.HeaderRow;
            if (header != null)
            {
                if (Page.IsValid == false) return;

                if (!openHoursVsCloseHoursOK(header))
                    return;

                bool isAdded = AddNewRow(header, false, String.Empty);
                if (isAdded)
                {
                    //clear indicator for case when to hour less than from hour 
                    hdnEnableOverMidnightHours.Value = String.Empty;

                    dgReceptionHours.EditIndex = -1;
                    dgReceptionHours.DataSource = null;
                    BindData(this.dtOriginalData);
                    hfUpdateFlag.Value = "1";
                }
                else
                {
                    string message = "'" + GetLocalResourceObject("message").ToString() + "'";
                    ThrowAlert(message);
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }

    }

    private void ThrowAlert(string message)
    {
        String scriptString = "javascript:alert(" + message + ");";
        UpdatePanel UpdPanelHours = this.FindControl("UpdPanel1") as UpdatePanel;

        ScriptManager sm = ScriptManager.GetCurrent(Page);
        if (sm != null && UpdPanelHours != null)
        {
            ScriptManager.RegisterClientScriptBlock(UpdPanelHours, typeof(UpdatePanel), "JsAlert_", scriptString, true);
        }
    }

    protected void imgCancel_Click(object sender, EventArgs e)
    {
        try
        {
            CancelEditedRow();

            //clear indicator for case when to hour less than from hour 
            hdnEnableOverMidnightHours.Value = String.Empty;
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void imgUpdate_Click(object sender, EventArgs e)
    {
        try
        {
            GridViewRow row = ((System.Web.UI.WebControls.Button)(sender)).Parent.Parent as GridViewRow;
            if (row != null)
                UpdateRow(row);
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void CancelEditedRow()
    {
        dgReceptionHours.EditIndex = -1;
        dgReceptionHours.DataSource = this.dtOriginalData;   //set the data table to data source of GridView again here        
        DataBind();
    }

    private void UpdateRow(GridViewRow row)
    {
        EditingIndex = row.RowIndex;
        dgReceptionHours.EditIndex = row.RowIndex;
        dgReceptionHours.DataSource = this.dtOriginalData;   //set the data table to data source of GridView again here

        DataBind();


        try
        {
            int index = dgReceptionHours.EditIndex;
            Label lblDays = dgReceptionHours.Rows[index].FindControl("lblDays2") as Label;

            TextBox txtFromDate = dgReceptionHours.Rows[index].FindControl("txtFromDate") as TextBox;
            if (txtFromDate != null)
            {
                txtFromDate.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtFromDate.ClientID + "')";
            }

            Label lblRemarkText = dgReceptionHours.Rows[index].FindControl("lblRemarkText") as Label;
            if (lblRemarkText != null)
            {
                hdnRemarkMask_E.Value = lblRemarkText.Text;
                hdnRemarkText_E.Value = lblRemarkText.Text.Replace("#", "");
            }

            HtmlInputText lblRemarkText_E = dgReceptionHours.Rows[index].FindControl("lblRemarkText_E") as HtmlInputText;
            if (lblRemarkText_E != null)
            {
                lblRemarkText_E.Value = lblRemarkText_E.Value.Replace("#", "");
            }

            Label lblRemarkID = dgReceptionHours.Rows[index].FindControl("lblRemarkID") as Label;
            if (lblRemarkID != null)
                hdnRemarkID_E.Value = lblRemarkID.Text;

            //for validation
            SetFromToClientsIdsToHiddenFields(dgReceptionHours.Rows[index]);

            Label lblEnableOverMidnightHours = dgReceptionHours.Rows[index].FindControl("lblEnableOverMidnightHours") as Label;
            if (lblEnableOverMidnightHours != null)
            {
                hdnEnableOverMidnightHours.Value = lblEnableOverMidnightHours.Text;
            }

            if (this.dtOriginalData != null)
            {
                UserControls_MultiDDlSelectUC mltDdlDayE = dgReceptionHours.Rows[index].FindControl("mltDdlDayE") as UserControls_MultiDDlSelectUC;

                if (mltDdlDayE != null)
                {
                    string days = ReturnDays(lblDays.Text);
                    mltDdlDayE.TextBox.Text = days;
                    string[] daysArr = SPLIT_COMMA(days);

                    foreach (string day in daysArr)
                    {
                        mltDdlDayE.SelectSpesificDate(day);
                    }
                    //OpenMddlItems(mltDdlDayE);   
                }
            }
        }

        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void DeleteRow(GridViewRow row)
    {
        string filter = String.Empty;
        string newId = String.Empty;
        Label lblReceptionID = null;
        Label lblAdd_ID = null;
        try
        {
            //1.delete from  this.SourceData

            lblReceptionID = dgReceptionHours.Rows[row.RowIndex].FindControl("lblReceptionId") as Label;
            lblAdd_ID = dgReceptionHours.Rows[row.RowIndex].FindControl("lblAdd_ID") as Label;
            if (lblReceptionID != null && lblAdd_ID != null)
            {
                if (lblAdd_ID.Text != String.Empty)
                    filter = "ADD_ID = '" + lblAdd_ID.Text + "'";
                else
                {
                    newId = lblReceptionID.Text;
                    filter = "ReceptionID = '" + newId + "'";
                }

                //if (filter != String.Empty)
                //{
                //    RemoveRowFromSourceData(filter);
                //}

                if (lblReceptionID != null)
                {
                    string id = lblReceptionID.Text;
                    if (id != string.Empty)
                    {
                        string[] receptionSID = SPLIT_COMMA(id);
                        if (receptionSID != null && receptionSID.Length > 0)
                        {
                            foreach (string receptionID in receptionSID)
                            {
                                filter = "receptionID = " + receptionID;
                                RemoveRowFromOriginalData(filter);
                            }
                        }
                    }
                    else
                    {
                        if (lblAdd_ID != null && lblAdd_ID.Text.Trim() != String.Empty)
                        {
                            filter = "Add_ID = '" + lblAdd_ID.Text + "'";
                            RemoveRowFromOriginalData(filter);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void imgClear_Click(object sender, EventArgs e)
    {
        try
        {
            GridViewRow header = dgReceptionHours.HeaderRow;
            if (header != null)
            {
                DropDownList ddlDept = header.FindControl("ddlDept") as DropDownList;
                if (ddlDept != null)
                    ddlDept.SelectedIndex = 0;

                UserControls_MultiDDlSelectUC MultiDDlSelect_Days = header.FindControl("MultiDDlSelect_Days") as UserControls_MultiDDlSelectUC;
                if (MultiDDlSelect_Days != null)
                {
                    MultiDDlSelect_Days.ClearFields();
                }
                TextBox txtFromHour = header.FindControl("txtFromHour") as TextBox;
                if (txtFromHour != null)
                    txtFromHour.Text = "";

                TextBox txtToHour = header.FindControl("txtToHour") as TextBox;
                if (txtToHour != null)
                    txtToHour.Text = "";

                TextBox txtFromDate = header.FindControl("txtFromDate") as TextBox;
                if (txtFromDate != null)
                    txtFromDate.Text = DateTime.Today.ToString();

                TextBox txtToDate = header.FindControl("txtToDate") as TextBox;
                if (txtToDate != null)
                    txtToDate.Text = "";
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void RemoveRowFromOriginalData(string filter)
    {
        RemoveRowFromData(this.dtOriginalData, filter);
    }

    private DataRow[] GetSpesificRowFromOriginalData(string openingHour, string closingHour, string validFrom, string validTo, string remarkID, string remarkText, string day)
    {
        string filter = string.Empty;
        int dayIndx = ConvertDay(day);

        filter = "  receptionDay = " + dayIndx;

        if (openingHour != string.Empty)
            filter += " and openingHour = '" + openingHour + "'";

        if (closingHour != string.Empty)
            filter += " and closingHour = '" + closingHour + "'";

        if (validFrom != string.Empty)
            filter += " and validFrom = '" + validFrom + "'";

        if (validTo != string.Empty)
            filter += " and validTo = '" + validTo + "'";

        if (remarkID != string.Empty)
            filter += filter += " and RemarkID = " + remarkID;

        if (remarkText != string.Empty)
            filter += " and RemarkText = '" + remarkText + "'";

        DataRow[] rows = this.dtOriginalData.Select(filter);
        return rows;
    }

    //private void RemoveRowFromSourceData(string filter)
    //{
    //    RemoveRowFromData(this.dtOriginalData, filter);
    //}

    private void RemoveRowFromData(DataTable dt, string filter)
    {
        DataRow[] rows = dt.Select(filter);
        if (rows != null && rows.Length > 0)
        {
            for (int x = 0; x < rows.Length; x++)
            {
                dt.Rows.Remove(rows[x]);
                //dt.AcceptChanges();
            }
        }
    }

    private int ConvertDay(string DayIndex)
    {
        int DayDesc = -1;

        switch (DayIndex)
        {
            case "א":
                {
                    DayDesc = 1;
                }
                break;
            case "ב":
                {
                    DayDesc = 2;
                }
                break;
            case "ג":
                {
                    DayDesc = 3;
                }
                break;
            case "ד":
                {
                    DayDesc = 4;
                }
                break;
            case "ה":
                {
                    DayDesc = 5;
                }
                break;
            case "ו":
                {
                    DayDesc = 6;
                }
                break;
            case "ש":
                {
                    DayDesc = 7;
                }
                break;
            case "חו``מ":
                {
                    DayDesc = 8;
                }
                break;
            case "ערב חג":
                {
                    DayDesc = 9;
                }
                break;
            case "חג":
                {
                    DayDesc = 10;
                }
                break;
            case "יום בחירות":
                {
                    DayDesc = 11;
                }
                break;
        }

        return DayDesc;
    }

    private void SaveRow(GridViewRow row)
    {
        //1 for save updated row must to delete updated row and after this to add new row 
        //this process will be in DB too - first DELETE , and after INSERT
        try
        {
            //int index = dgReceptionHours.EditIndex;
            //DeleteRow(row);

            //Label lblReceptionIds = dgReceptionHours.Rows[index].FindControl("lblReceptionIds") as Label;
            //AddNewRow(row, true, lblReceptionIds.Text);
            //dgReceptionHours.EditIndex = -1;
            //this.DataBind();  


            int index = dgReceptionHours.EditIndex;
            //DataTable dtCopySourceData = this.SourceData.Copy();
            DataTable dtCopyOriginalData = this.dtOriginalData.Copy();

            DeleteRow(row);

            Label lblReceptionID = dgReceptionHours.Rows[index].FindControl("lblReceptionID") as Label;
            int[] id_Originals = null;
            bool isAdded = AddNewRow(row, true, lblReceptionID.Text);

            if (isAdded)
            {
                dgReceptionHours.EditIndex = -1;
                dgReceptionHours.DataSource = null;
                BindData(this.dtOriginalData);
            }
            else
            {
                // if new row for any reason didn't  added - do rollback 
                //this.SourceData = dtCopySourceData.Copy();
                this.dtOriginalData = dtCopyOriginalData.Copy();

                if (id_Originals == null)
                {
                    string message = "'" + GetLocalResourceObject("message").ToString() + "'";
                    ThrowAlert(message);
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    #endregion

    #region Utils

    #region SPLIT
    private static string[] SPLIT(string itemCodes, char p)
    {
        string[] selectedItems = itemCodes.Split(p);
        //Array.Sort(selectedItems);
        return selectedItems;
    }
    private static string[] SPLIT_COMMA(string itemCodes)
    {
        char p = ',';
        string[] selectedItems = itemCodes.Split(p);
        //Array.Sort(selectedItems);
        return selectedItems;
    }
    private static string[] SPLIT_UNDERSCORE(string itemCodes)
    {
        char p = '_';
        string[] selectedItems = itemCodes.Split(p);
        //Array.Sort(selectedItems);
        return selectedItems;
    }
    #endregion

    #endregion

    private bool AddNewRow(GridViewRow row, bool isEditMode, string receptionIds)
    {

        string selectedDays = String.Empty;
        string fromHour = String.Empty;
        string toHour = String.Empty;
        string fromDate = String.Empty;
        string toDate = String.Empty;
        Hashtable hTblDepartItems = new Hashtable();
        Hashtable hTblDepartItemsTypes = new Hashtable();
        Hashtable hTblNewRemark = new Hashtable();
        bool resultOriginalData = false;
        bool resultSourceData = false;

        DataTable dtCopyOriginal = null;
        DataTable dtOriginalAfterAdding = null;
        int lastAdedIndx = -1;


        //1.get values from header 
        //1a. get values of city code and city name 
        //2. add to grid  
        //3. close Mddl

        //1
        GetNewReceptionValues(ref selectedDays, ref fromHour, ref toHour, ref hTblNewRemark, ref fromDate, ref toDate, row, isEditMode);

        if (selectedDays != String.Empty && fromHour != String.Empty && toHour != String.Empty)
        {
            //1a. get values of city code and city name 

            DataTable dtOriginal = this.dtOriginalData;
            int id = dtOriginal.Rows.Count + 1;
            dtCopyOriginal = dtOriginal.Copy();

            lastAdedIndx = LastAddedIndex;
            lastAdedIndx++;

            resultOriginalData = AddNewRowToOriginalData(ref dtOriginal, "", id,
                                                    receptionIds, selectedDays, fromHour, toHour,
                                                    fromDate, toDate, hTblNewRemark["remarkID"].ToString(),
                                                    hTblNewRemark["remarkMask"].ToString(), lastAdedIndx);

            if (resultOriginalData)
            {
                dtOriginalAfterAdding = dtOriginal.Copy();

                //if (!flag)
                //{
                //cheking duplicity in transformed data 
                //resultSourceData = AddNewRowToSourceData(row.RowIndex, receptionIds, selectedDays, fromHour, toHour, fromDate, toDate,
                //                      hTblNewRemark, lastAdedIndx);

                LastAddedIndex = lastAdedIndx;

                if (resultOriginalData)
                {
                    SetObjectToViewState("newAddedDept", null);
                    this.dtOriginalData = dtOriginalAfterAdding.Copy();
                    return true;
                }
            }
        }
        return false;
    }


    private bool AddNewRowToOriginalData(ref DataTable dtOriginalData, string receptionID, int ID_original,
      string receptionIds, string receptionDays, string openingHour, string closingHour, string validFrom, string validTo,
      string remarkID, string remarkText, int lastIndx)
    {
        if (receptionIds != string.Empty)// - for Update
        {
            string[] receptionId = SPLIT_COMMA(receptionIds);
            if (receptionId.Length > 0)
            {
                foreach (string curId in receptionId)
                {
                    return AddNewRowToOriginalData(ref dtOriginalData, receptionDays,
                          openingHour, closingHour, validFrom, validTo, remarkID, remarkText, curId, ID_original, lastIndx);
                }
            }
            else
                return false;
        }
        else //this is new row 
        {
            return AddNewRowToOriginalData(ref dtOriginalData, receptionDays,
                openingHour, closingHour, validFrom, validTo, remarkID, remarkText, string.Empty, ID_original, lastIndx);
        }
        return false;
    }

    private bool AddNewRowToOriginalData(ref DataTable dtOriginalData, string receptionDays,
                            string openingHour, string closingHour, string validFrom, string validTo,
                            string remarkID, string remarkText, string receptionID, int id, int lastAdedIndx)
    {
        bool flag = true;
        if (receptionDays != String.Empty)
        {
            string[] days = SPLIT_COMMA(receptionDays);
            if (days != null && days.Length > 0)
            {
                for (int daysCount = 0; daysCount < days.Length; daysCount++)
                {
                    string day = days[daysCount].ToString().Replace("_", "");

                    bool checkDuplicity = CheckDuplicity(dtOriginalData, openingHour, closingHour, validFrom, validTo, day);
                    if (!checkDuplicity)
                    {
                        DataRow newRow = dtOriginalData.NewRow();

                        newRow["Add_ID"] = lastAdedIndx;

                        if (receptionID != string.Empty)
                            newRow["receptionID"] = receptionID;

                        newRow["receptionDay"] = day;

                        if (openingHour != String.Empty)
                            newRow["openingHour"] = openingHour.ToString();

                        if (closingHour != String.Empty)
                            newRow["closingHour"] = closingHour;

                        if (validFrom != String.Empty)
                            newRow["validFrom"] = Convert.ToDateTime(validFrom);
                        else
                            newRow["validFrom"] = DBNull.Value;

                        if (validTo != String.Empty)
                            newRow["validTo"] = Convert.ToDateTime(validTo);
                        else
                            newRow["validTo"] = DBNull.Value;

                        if (remarkID != String.Empty)
                            newRow["RemarkID"] = remarkID;
                        else
                            newRow["RemarkID"] = -1;

                        newRow["RemarkText"] = remarkText;
                        newRow["ID_Original"] = (id + daysCount).ToString();

                        dtOriginalData.Rows.Add(newRow);
                    }
                    else
                    {
                        flag = false;
                        return flag;
                    }

                }
            }
        }
        return flag;
    }

    //this function checks duplicity of reception hours 
    private bool CheckDuplicity(DataTable dtOriginalData, string openingHour, string closingHour,
                                                                            string newValidFrom, string newValidTo, string day)
    {
        bool flag = false;
        string filter =
            " receptionDay = '" + day + "'";

        if (openingHour != String.Empty)
            filter += " and openingHour ='" + openingHour + "'";

        if (closingHour != String.Empty)
            filter += " and closingHour ='" + closingHour + "'";

        if (newValidFrom != String.Empty)
            filter += " and validFrom ='" + newValidFrom + "'";

        if (newValidTo != String.Empty)
            filter += " and validTo='" + newValidTo + "'";

        DataRow[] rows = dtOriginalData.Select(filter);

        if (rows != null && rows.Length > 0)
            flag = true;

        return flag;
    }

    protected void dgReceptionHours_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {

    }

    /// <summary>
    /// return data when occures event 'Save'
    /// </summary>
    /// <returns></returns>
    public DataTable ReturnData()
    {
        DataTable dtOriginalData = null;
        bool emptyRow = true;

        try
        {
            dtOriginalData = this.dtOriginalData;

            // check if table has one empty row. if so - remove it
            if (dtOriginalData.Rows.Count == 1)
            {
                for (int i = 0; i < dtOriginalData.Columns.Count; i++)
                {
                    if (dtOriginalData.Rows[0][i] != DBNull.Value)
                    {
                        emptyRow = false;
                        break;
                    }
                }

                if (emptyRow)
                {
                    dtOriginalData.Rows.RemoveAt(0);
                }
            }

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }

        return dtOriginalData;
    }
    //http://209.85.129.132/search?q=cache:FHrL7KO-gdkJ:forums.asp.net/p/1046148/1467966.aspx+PopupControlExtender+C%23+UserControl&cd=3&hl=iw&ct=clnk&gl=il
}
