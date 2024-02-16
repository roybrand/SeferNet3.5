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

public partial class UserControls_QueueOrderHoursUC : System.Web.UI.UserControl
{
    //difference in function returnDays
    private DataTable _dtData = null;
    private DataTable _dtOriginalData = null;
    private int _lastAddedIndex = 0;


    #region Properies

    public int LastAddedIndex
    {
        get
        {
            if (ViewState["LastAddedIndex_" + this.ClientID] != null)
                return (int)ViewState["LastAddedIndex_" + this.ClientID];
            else
                return -1;
        }
        set
        {
            ViewState["LastAddedIndex_" + this.ClientID] = value;
        }
    }

   
    #region WidthColumns
    public Unit WidthDaysColumn
    {
        set
        {
            this.dgOrderHours.Columns[1].ItemStyle.Width = value;
        }
    }
    public Unit WidthFromHourColumn
    {
        set
        {
            this.dgOrderHours.Columns[2].ItemStyle.Width = value;
        }
    }
    public Unit WidthToHourColumn
    {
        set
        {
            this.dgOrderHours.Columns[3].ItemStyle.Width = value;
        }
    }

    public Unit WidthButtonsColumn
    {
        set
        {
            this.dgOrderHours.Columns[7].ItemStyle.Width = value;
        }
    }

    #endregion

    public DataTable SourceData
    {
        get
        {
            if (ViewState["QueueOrderHoursData_" + this.ClientID] != null)
            {
                return (DataTable)ViewState["QueueOrderHoursData_" + this.ClientID];
            }
            else
            {
                return null;
            }
        }
        set
        {

            if (ViewState["QueueOrderHoursData_" + this.ClientID] == null)
            {
                _dtData = value;
                int counter = 0;
                if (!_dtData.Columns.Contains("ID"))
                {
                    _dtData.Columns.Add("ID");
                }

                foreach (DataRow row in _dtData.Rows)
                {
                    row["ID"] = counter;
                    counter++;
                }

                if (!_dtData.Columns.Contains("Add_ID"))
                {
                    _dtData.Columns.Add("Add_ID");
                }
                ViewState["QueueOrderHoursData_" + this.ClientID] = _dtData;
            }
            else
            {
                ViewState["QueueOrderHoursData_" + this.ClientID] = value;
            }
        }
    }

    public DataTable dtOriginalData
    {
        get
        {
            if (ViewState["OriginalData_" + this.ClientID] != null)
                return (DataTable)ViewState["OriginalData_" + this.ClientID];
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

            ViewState["OriginalData_" + this.ClientID] = _dtOriginalData;
        }
    }

    public bool NewRowAdded
    {
        get
        {
            object obj = ViewState["NewRowAdded_" + this.ClientID];

            if (obj != null)
                return Convert.ToBoolean(obj);
            else
                return false;
        }
        set
        {
            ViewState["NewRowAdded_" + this.ClientID] = value;
        }
    }

    private void AddEmptyRow(ref DataTable dtOriginalData)
    {
        DataRow newRow = dtOriginalData.NewRow();
        dtOriginalData.Rows.Add(newRow);
        this.NewRowAdded = true;
    }

    public Unit Width
    {
        get
        {
            return this.dgOrderHours.Width;
        }
        set
        {
            this.dgOrderHours.Width = value;
        }
    }

    #region Properties RemarksHiddens


    #endregion


    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {}

    #region Days
    private string ReturnDays(string days)
    {
        string day = String.Empty;
        DataTable tblReceptionDays = GetReceptionDaysTable();

        string[] days_receptionID = SPLIT_COMMA(days);

        if (days_receptionID != null)
        {
            foreach (string day_receptionID in days_receptionID)
            {
                if (day_receptionID != String.Empty)
                {
                    DataRow[] rows = tblReceptionDays.Select("ReceptionDayCode = " + day_receptionID);
                    if (rows != null)
                    {
                        day += rows[0][1].ToString() + ",";
                    }
                }
                else
                {
                    day += day_receptionID + ",";
                }
            }
        }
        day = day.Remove(day.Length - 1, 1);
        return day;
    }

    /// <summary>
    /// function that translates days from dayCodes
    /// </summary>
    /// <returns></returns>
    protected DataTable GetReceptionDaysTable()
    {
        DataTable tbl = null;

        ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();

        tbl = cacheHandler.getCachedDataTable(eCachedTables.DIC_ReceptionDays.ToString());

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
       GridViewRow row, bool isEditMode)
    {
        #region declaration
        UserControls_MultiDDlSelectUC MultiDDlSelect_Days = null;
        TextBox txtFromHour = null;
        TextBox txtToHour = null;
        #endregion

        if (!isEditMode)
        {
            MultiDDlSelect_Days = row.FindControl("MultiDDlSelect_Days") as UserControls_MultiDDlSelectUC;
            txtFromHour = row.FindControl("txtFromHour") as TextBox;
            txtToHour = row.FindControl("txtToHour") as TextBox;
        }
        else // mode edit
        {
            MultiDDlSelect_Days = row.FindControl("mltDdlDayE") as UserControls_MultiDDlSelectUC;
            txtFromHour = row.FindControl("txtFromHourEdit") as TextBox;
            txtToHour = row.FindControl("txtToHourEdit") as TextBox;
        }

        if (MultiDDlSelect_Days != null)
        {
            GetDays(ref selectedDays, MultiDDlSelect_Days);
        }
        if (txtFromHour != null)
        {
            fromHour = GetToDate(txtFromHour);
        }
        if (txtToHour != null)
        {
            toHour = GetToDate(txtToHour);
        }
    }

    #region Get new added values
    private string GetToDate(TextBox txtToDate)
    {
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



    public override void DataBind()
    {
        this.BindData(SourceData);
    }


    private void BindData(DataTable dtData)
    {

        CheckEmptyRow(ref dtData);
        dgOrderHours.DataSource = null;
        DataView dv = dtData.DefaultView;
        if (dv != null)
            dv.Sort = "Days asc";
        dgOrderHours.DataSource = dv;
        dgOrderHours.DataBind();
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

            if (dtData.Rows.Count > 0)
            {
                if (dtData.Rows[0]["ID"].ToString() == "2")
                {
                    dtData.Rows[0]["ID"] = "1";
                }
            }
        }
    }

    private void BuildGridRow(GridViewRowEventArgs e)
    {

        Label lblDays = e.Row.FindControl("lblDays") as Label;
        Label lblDays2 = e.Row.FindControl("lblDays2") as Label;

        string day = String.Empty;

        if (lblDays != null)
        {
            object[] data = ((System.Data.DataRowView)(e.Row.DataItem)).Row.ItemArray;
            if (data != null)
            {
                day = ReturnDays(((System.Data.DataRowView)(e.Row.DataItem))["Days"].ToString());
                if (day != string.Empty)
                    lblDays2.Text = lblDays.Text = day;
                else
                    e.Row.Visible = false;
            }
        }
    }

    //private void BuildGridHeader(GridViewRowEventArgs e, DataTable dtDeptEmployeeData)
    //{
    //    #region Header

    //    if (dgOrderHours.EditIndex == -1)
    //        SetFromToClientsIdsToHiddenFields(e.Row);
    //    UserControls_MultiDDlSelectUC MultiDDlSelect_Days = e.Row.FindControl("MultiDDlSelect_Days") as UserControls_MultiDDlSelectUC;
    //    if (MultiDDlSelect_Days != null)
    //    {
    //        MultiDDlSelect_Days.TextBox.Width = Unit.Parse("25px");
    //        MultiDDlSelect_Days.Items.Width = Unit.Parse("78px");

    //        MultiDDlSelect_Days.Items.TextAlign = TextAlign.Right;
    //        MultiDDlSelect_Days.Panel.Width = Unit.Parse("78px");
    //        MultiDDlSelect_Days.Panel.Height = Unit.Parse("300px");
    //        DataTable tbl = GetReceptionDaysTable();
    //        MultiDDlSelect_Days.BindData(tbl, "ReceptionDayCode", "ReceptionDayName");
    //    }

    //    #endregion
    //}

    //function for custom validation of hours 
    //private void SetFromToClientsIdsToHiddenFields(GridViewRow row)
    //{
    //    TextBox txtFromHour = row.FindControl("txtFromHour") as TextBox;
    //    TextBox txtToHour = row.FindControl("txtToHour") as TextBox;

    //    if (txtFromHour != null)
    //    {
    //        hdnHeaderFromHourClientID.Value = txtFromHour.ClientID;
    //    }

    //    if (txtToHour != null)
    //    {
    //        hdnHeaderToHourClientID.Value = txtToHour.ClientID;
    //    }
    //}

    protected void dgOrderHours_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            //BuildGridHeader(e, this.SourceData);
        }
        else if (e.Row.RowType == DataControlRowType.DataRow)
        {
            BuildGridRow(e);
        }
    }
    protected void dgOrderHours_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        dgOrderHours.EditIndex = -1;
        //dgOrderHours.DataSource = this.SourceData;   //set the data table to data source of GridView again here
        //dgOrderHours.DataBind();
        //DataBind(this.SourceData);
        DataBind();
    }


    #endregion

    #region Buttons clicks

    protected void imgSave_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        if (row != null)
            SaveRow(row);
    }

    protected void imgDelete_Click(object sender, ImageClickEventArgs e)
    {

        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        if (row != null)
        {
            DeleteRow(row);
            BindData(this.SourceData);
        }
    }

    protected void imgAdd_Click(object sender, ImageClickEventArgs e)
    {

        GridViewRow header = dgOrderHours.HeaderRow;
        bool isAdded = AddNewRow(header, false, String.Empty);
        if (isAdded)
        {
            dgOrderHours.EditIndex = -1;
            dgOrderHours.DataSource = null;
            BindData(this.SourceData);
        }
        else
        {
            string message = "'" + GetLocalResourceObject("message").ToString() + "'";
            ThrowAlert(message);
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

    protected void imgCancel_Click(object sender, ImageClickEventArgs e)
    {
        dgOrderHours.EditIndex = -1;
        DataBind();
    }

    protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        if (row != null)
            UpdateRow(row);
    }

    private void UpdateRow(GridViewRow row)
    {
        dgOrderHours.EditIndex = row.RowIndex;
        //DataBind();



    }

    protected void dgOrderHours_RowEditing(object sender, GridViewEditEventArgs e)
    {
        dgOrderHours.EditIndex = e.NewEditIndex;
        DataBind();

        int index = dgOrderHours.EditIndex;
        Label lblDays = dgOrderHours.Rows[index].FindControl("lblDays2") as Label;

        if (this.SourceData != null)
        {
            UserControls_MultiDDlSelectUC mltDdlDayE = dgOrderHours.Rows[index].FindControl("mltDdlDayE") as UserControls_MultiDDlSelectUC;

            if (mltDdlDayE != null)
            {
                string days = ReturnDays(lblDays.Text);

                mltDdlDayE.TextBox.Text = days;
                string[] daysArr = SPLIT_COMMA(days);

                foreach (string day in daysArr)
                {
                    mltDdlDayE.SelectSpesificDate(day);
                }
            }
        }
    }

    private void DeleteRow(GridViewRow row)
    {
        string filter = String.Empty;
        string newId = String.Empty;
        Label lblID = null;
        Label lblAdd_ID = null;

        //delete from  this.SourceData

        lblID = dgOrderHours.Rows[row.RowIndex].FindControl("lblID") as Label;
        lblAdd_ID = dgOrderHours.Rows[row.RowIndex].FindControl("lblAdd_ID") as Label;
        if (lblID != null && lblAdd_ID != null)
        {
            if (lblAdd_ID.Text != String.Empty)
                filter = "ADD_ID = '" + lblAdd_ID.Text + "'";
            else
            {
                newId = lblID.Text;
                filter = "Id = '" + newId + "'";
            }

            RemoveRowFromSourceData(filter);

            Label lblReceptionIds = dgOrderHours.Rows[row.RowIndex].FindControl("lblReceptionIds") as Label;
            if (lblReceptionIds != null)
            {
                string id = lblReceptionIds.Text;
                if (id != string.Empty)
                {
                    string[] receptionSID = SPLIT_COMMA(id);
                    if (receptionSID != null && receptionSID.Length > 0)
                    {
                        foreach (string receptionID in receptionSID)
                        {
                            filter = "QueueOrderHoursID = " + receptionID;
                            RemoveRowFromOriginalData(filter);
                        }
                    }
                }
                else
                {
                    // this is new added reception 
                    if (lblAdd_ID != null && lblAdd_ID.Text.Trim() != String.Empty)
                    {
                        filter = "Add_ID = '" + lblAdd_ID.Text + "'";
                        RemoveRowFromOriginalData(filter);
                    }
                }
            }
        }
    }

    private void RemoveRowFromOriginalData(string filter)
    {
        RemoveRowFromData(this.dtOriginalData, filter);
    }

    private void RemoveRowFromSourceData(string filter)
    {
        RemoveRowFromData(this.SourceData, filter);
    }

    private void RemoveRowFromData(DataTable dt, string filter)
    {
        DataRow[] rows = dt.Select(filter);
        if (rows != null && rows.Length > 0)
        {
            for (int x = 0; x < rows.Length; x++)
            {
                dt.Rows.Remove(rows[x]);
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

        int index = dgOrderHours.EditIndex;
        DeleteRow(row);

        Label lblReceptionIds = dgOrderHours.Rows[index].FindControl("lblReceptionIds") as Label;
        AddNewRow(row, true, lblReceptionIds.Text);
        dgOrderHours.EditIndex = -1;

        DataBind();
        //BindData(this.SourceData);

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


        bool resultOriginalData = false;
        bool resultSourceData = false;

        DataTable dtCopyOriginal = null;
        DataTable dtOriginalAfterAdding = null;
        int lastAdedIndx = -1;

        if (row != null)
        {
            //1.get values from header 
            //1a. get values of city code and city name 
            //2. add to grid  
            //3. close Mddl

            //1
            GetNewReceptionValues(ref selectedDays, ref fromHour, ref toHour, row, isEditMode);

        }
       
        if (selectedDays != String.Empty && fromHour != String.Empty && toHour != String.Empty)
        {
            DataTable dtOriginal = this.dtOriginalData;
            int id = dtOriginal.Rows.Count + 1;
            dtCopyOriginal = dtOriginal.Copy();

            lastAdedIndx = LastAddedIndex;
            lastAdedIndx++;
            resultOriginalData = AddNewRowToOriginalData(ref dtOriginal, "", id, receptionIds, selectedDays, fromHour, toHour,
                                                    lastAdedIndx);
            if (resultOriginalData)
            {
                dtOriginalAfterAdding = dtOriginal.Copy();

                //if (!flag)
                //{
                //cheking duplicity in transformed data 
                resultSourceData = AddNewRowToSourceData(row.RowIndex, receptionIds, selectedDays, fromHour, toHour,
                                       lastAdedIndx);

                LastAddedIndex = lastAdedIndx;

                if (resultOriginalData && resultSourceData)
                {
                    this.dtOriginalData = dtOriginalAfterAdding.Copy();
                    return true;
                }
            }
        }
        return false;
    }


    private bool AddNewRowToOriginalData(ref DataTable dtOriginalData, string receptionID, int ID_original,
     string receptionIds, string receptionDays, string openingHour, string closingHour, int lastIndx)
    {
        if (receptionIds != string.Empty)// - for Update
        {
            string[] receptionId = SPLIT_COMMA(receptionIds);
            if (receptionId.Length > 0)
            {
                foreach (string curId in receptionId)
                {
                    return AddNewRowToOriginalData(ref dtOriginalData, receptionDays,
                          openingHour, closingHour, curId, ID_original, lastIndx);
                }
            }
            else
                return false;
        }
        else //this is new row 
        {
            return AddNewRowToOriginalData(ref dtOriginalData, receptionDays,
                openingHour, closingHour, string.Empty, ID_original, lastIndx);
        }
        return false;
    }


    private bool AddNewRowToOriginalData(ref DataTable dtOriginalData, string receptionDays,
                            string openingHour, string closingHour,
                            string receptionID, int id, int lastAdedIndx)
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

                    bool checkDuplicity = CheckDuplicity(dtOriginalData, openingHour, closingHour, day);
                    if (!checkDuplicity)
                    {
                        DataRow newRow = dtOriginalData.NewRow();

                        newRow["Add_ID"] = lastAdedIndx;

                        if (receptionID != string.Empty)
                            newRow["QueueOrderHoursID"] = receptionID;

                        newRow["receptionDay"] = day;

                        if (openingHour != String.Empty)
                            newRow["openingHour"] = openingHour.ToString();

                        if (closingHour != String.Empty)
                            newRow["closingHour"] = closingHour;

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
                                                                             string day)
    {
        bool flag = false;
        string filter =
            " receptionDay = '" + day + "'";

        if (openingHour != String.Empty)
            filter += " and openingHour ='" + openingHour + "'";

        if (closingHour != String.Empty)
            filter += " and closingHour ='" + closingHour + "'";

        DataRow[] rows = dtOriginalData.Select(filter);

        if (rows != null && rows.Length > 0)
            flag = true;

        return flag;
    }


    private bool AddNewRowToSourceData(int indx, string receptionIds, string selectedDays, string fromHour, string toHour,
                                      int lastIndx)
    {
        // i need to know row Index for insert updated( new added row in this position)
        bool result = false;

        DataTable dtData = this.SourceData;
        if (dtData != null)
        {
            DataRow dr = dtData.NewRow();
            dr["QueueOrderHoursID"] = receptionIds;

            #region Filter
            DataRow[] rows = CheckNewRowOverlapping(selectedDays, fromHour, toHour, dtData);
            #endregion

            if (rows != null && rows.Length < 1)
            {
                dr["Add_ID"] = lastIndx;
                dr["Days"] = selectedDays;
                dr["openingHour"] = fromHour;
                dr["closingHour"] = toHour;


                if (this.NewRowAdded)
                {
                    if ((dgOrderHours.Rows.Count - 1) > 0)
                        dr["ID"] = dgOrderHours.Rows.Count - 1;
                    else
                        dr["ID"] = 1;
                }
                else
                    dr["ID"] = dgOrderHours.Rows.Count + 1;
                //
                if (indx > -1)
                {
                    dtData.Rows.InsertAt(dr, indx);
                    result = true;
                    dtData.AcceptChanges();
                }
                else
                {
                    dtData.Rows.Add(dr);
                    result = true;
                    dtData.AcceptChanges();
                }
            }
        }

        this.SourceData = dtData;
        return result;
    }


    private DataRow[] CheckNewRowOverlapping(string selectedDays, string fromHour, string toHour,
         DataTable dtData)
    {
        string filter = string.Empty;

        if (selectedDays != string.Empty)
        {
            filter += " Days='" + selectedDays + "'";
        }

        if (fromHour != string.Empty)
        {
            if (filter != string.Empty)
            {
                filter += " and openingHour='" + fromHour + "'";
            }
            else
            {
                filter += " openingHour='" + fromHour + "'";
            }
        }
        if (toHour != string.Empty)
        {
            if (filter != string.Empty)
            {
                filter += " and closingHour='" + toHour + "'";
            }
            else
            {
                filter += " closingHour='" + toHour + "'";
            }
        }

        DataRow[] rows = dtData.Select(filter);
        return rows;
    }
   

    protected void dgOrderHours_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {

    }

    /// <summary>
    /// return data when occures event 'Save'
    /// </summary>
    /// <returns></returns>
    public DataTable ReturnData()
    {
        DataTable dtOriginalData = null;

        dtOriginalData = this.dtOriginalData;

        return dtOriginalData;
    }

    //http://209.85.129.132/search?q=cache:FHrL7KO-gdkJ:forums.asp.net/p/1046148/1467966.aspx+PopupControlExtender+C%23+UserControl&cd=3&hl=iw&ct=clnk&gl=il






}
