using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Data;
using System.ComponentModel;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.FacadeLayer;
using AjaxControlToolkit;
using System.Globalization;
using System.Collections.Specialized;
using System.Text;
using SeferNet.Globals;
using SeferNet.BusinessLayer.BusinessObject;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;
using System.Configuration;

public partial class UserControls_GridReceptionHoursUC : System.Web.UI.UserControl
{
    private int _selectedDept = -1;
    private DataTable _dtOriginalData = null;
    private bool _isNewRowAdded = false;
    private int EditingIndex = -1;
    private DataTable _tblReceptionDays;
    private int _lastAddedIndex = 0;
    private int _deptCodeForReceptionHoursControl_DropDownListSelected = 0;

    private const string DEFAULT_SORT = "ReceptionDay, OpeningHour";
    private const string CurrentDept_deptCode_ReceptionDay_OpeningHour_SORT = "deptCode, ReceptionDay, OpeningHour";

    #region Properies

    public Unit Width
    {
        set
        {
            this.dgReceptionHours.Width = value;
        }
    }

    public bool EnableHoursOverlapp
    {
        get
        {
            object obj = GetObjectFromViewState("EnableHoursOverlapp");

            if (obj != null)
                return (bool)obj;
            else
                return false;
        }
        set
        {
            //this._enableHoursOverlapp = ;
            SetObjectToViewState("EnableHoursOverlapp", value);
        }
    }

    public bool ReceptionHoursOfDoctor
    {
        get
        {
            object obj = GetObjectFromViewState("ReceptionHoursOfDoctor");

            if (obj != null)
                return (bool)obj;
            else
                return false;
        }
        set
        {
            SetObjectToViewState("ReceptionHoursOfDoctor", value);
        }
    }

    public bool EmployeeHasMoreThenOneClinic
    {
        get
        {
            object obj = GetObjectFromViewState("EmployeeHasMoreThenOneClinic");

            if (obj != null)
                return (bool)obj;
            else
                return false;
        }
        set
        {
            SetObjectToViewState("EmployeeHasMoreThenOneClinic", value);
        }
    }

    public bool EmployeeIsMedicalTeamOrVirtualDoctor
    {
        get
        {
            object obj = GetObjectFromViewState("EmployeeIsMedicalTeamOrVirtualDoctor");

            if (obj != null)
                return (bool)obj;
            else
                return false;
        }
        set
        {
            SetObjectToViewState("EmployeeIsMedicalTeamOrVirtualDoctor", value);
        }
    }

    public bool HasServicesSubjectToReceiveGuest
    {
        get
        {
            object obj = GetObjectFromViewState("HasServicesSubjectToReceiveGuest");

            if (obj != null)
                return (bool)obj;
            else
                return false;
        }
        set
        {
            SetObjectToViewState("HasServicesSubjectToReceiveGuest", value);
        }
    }

    public long EmployeeID
    {
        get
        {
            object obj = GetObjectFromViewState("EmployeeID");

            if (obj != null)
            {
                return (long)obj;
            }
            else
            {
                return 0;
            }
        }
        set
        {
            SetObjectToViewState("EmployeeID", value);
        }
    }

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

    public DataTable dtOriginalData
    {
        get
        {
            if (_dtOriginalData == null)
            {
                _dtOriginalData = (DataTable)Session["OriginalData"];
            }
            return _dtOriginalData;
        }
        set
        {
            int counter = 0;
            this._dtOriginalData = value;

            if (!_dtOriginalData.Columns.Contains("ID_Original"))
            {
                _dtOriginalData.Columns.Add("ID_Original");

                foreach (DataRow row in _dtOriginalData.Rows)
                {
                    row["ID_Original"] = counter;
                    counter++;
                }
            }

            if (!_dtOriginalData.Columns.Contains("Add_ID"))
            {
                _dtOriginalData.Columns.Add("Add_ID");
            }

            if (!_dtOriginalData.Columns.Contains("Newly_Added"))
            {
                _dtOriginalData.Columns.Add("Newly_Added");
            }

            this.CollectionDepts = BuildDeptCollection(this._dtOriginalData);

            Session["OriginalData"] = _dtOriginalData;
        }
    }

    protected bool IsVisualLabels
    {
        get
        {
            return Dept == -1;
        }
    }

    private object GetObjectFromViewState(string key)
    {
        return ViewState[key];

        //object obg = null;
        //Hashtable hTbl = GetViewStateHashTable();
        //if (hTbl != null)
        //{
        //    if (!hTbl.ContainsKey(key))
        //    {
        //        return null;
        //    }
        //    else
        //    {
        //        obg = hTbl[key];
        //        return obg;
        //    }
        //}
        //return null;
    }

    private bool SetObjectToViewState(string key, object obj)
    {
        ViewState[key] = obj;

        return true;

        //Hashtable hTbl = GetViewStateHashTable();
        //if (hTbl != null)
        //{
        //    if (!hTbl.ContainsKey(key))
        //    {
        //        hTbl.Add(key, obg);
        //        return true;
        //    }
        //    else
        //    {
        //        hTbl[key] = obg;
        //    }
        //}
        //return false;
    }

    public ListDictionary CollectionDepts
    {
        get
        {
            object obj = GetObjectFromViewState("collectionDepts");

            if (obj != null)
                return (ListDictionary)obj;
            else
                return null;
        }
        set
        {
            SetObjectToViewState("collectionDepts", value);
        }
    }

    private void AddEmptyRow(ref DataTable dtOriginalData)
    {
        DataRow newRow = dtOriginalData.NewRow();
        dtOriginalData.Rows.Add(newRow);
        this.NewRowAdded = true;
    }

    /// <summary>
    /// builds collection of depts that have receptions 
    /// </summary>
    /// <param name="dataTable"></param>
    /// <returns></returns>
    private ListDictionary BuildDeptCollection(DataTable dataTable)
    {
        try
        {
            ListDictionary list = new ListDictionary();

            foreach (DataRow row in dataTable.Rows)
            {
                BuildDeptCollection(row, ref list);
            }

            return list;
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void BuildDeptCollection(DataRow row, ref ListDictionary list)
    {
        int deptCode = -1;
        string deptName = String.Empty;
        int _itemID = -1;
        string _itemName = string.Empty;
        string _receptionID = string.Empty;
        receptionHoursDept dept = null;
        Item entity = null;
        int indx = -1;

        try
        {
            if (row["deptCode"] != DBNull.Value)
            {
                deptCode = int.Parse(row["deptCode"].ToString());
                deptName = row["deptName"].ToString();

                if (!list.Contains(deptCode))
                {
                    dept = new receptionHoursDept();
                    dept.deptCode = deptCode;
                    dept.deptName = deptName;

                }
                else
                {
                    dept = (receptionHoursDept)list[deptCode];
                }

                if (dept != null)
                {
                    if (row["ItemID"] != DBNull.Value)
                    {
                        _itemID = int.Parse(row["ItemID"].ToString());
                        _itemName = row["ItemDesc"].ToString();
                        #region GetEntity
                        if (dept.Entities.ContainsKey(_itemID))
                        {
                            entity = dept.Entities.GetByKey(_itemID);
                            indx = dept.Entities.IndexOf(entity);
                        }
                        else
                        {
                            entity = new Item();
                            entity.itemID = _itemID;
                            entity.itemName = _itemName;
                        }
                        #endregion

                        if (entity != null)
                        {
                            if (row["ItemType"] != DBNull.Value)
                            {
                                if (row["ItemType"].ToString() == Item.ItemType.profession.ToString())
                                {
                                    entity.itemType = Item.ItemType.profession;
                                }
                                else
                                {
                                    entity.itemType = Item.ItemType.service;
                                }
                            }

                            if (row["receptionID"] != DBNull.Value)
                            {
                                entity.isSelected = true;
                                entity.receptionID = row["receptionID"].ToString();
                            }
                        }

                        if (!dept.Entities.ContainsKey(_itemID))
                        {
                            dept.Entities.Add(entity);
                        }
                        else
                        {
                            dept.Entities[indx] = entity;
                        }
                    }
                }

                if (!list.Contains(deptCode))
                {
                    list.Add(dept.deptCode, dept);
                }
                else
                {
                    list[dept.deptCode] = dept;
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
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

    public int Dept
    {
        get
        {
            object selected = GetObjectFromViewState("selectedDept");
            if (selected != null)
            {
                return int.Parse(selected.ToString());
            }
            else
                return -1;
        }
        set
        {
            this._selectedDept = value;

            if (_selectedDept > -1)
            {
                SetObjectToViewState("selectedDept", _selectedDept);
                dgReceptionHours.EditIndex = -1;
                ViewState["conflictData"] = null;
            }
            else
            {
                SetObjectToViewState("selectedDept", null);

                // if we don't have a conflict - cancel editing because data source is different between modes
                if (ViewState["conflictData"] == null)
                {
                    dgReceptionHours.EditIndex = -1;
                }
            }
        }
    }

    //DeptCodeForReceptionHoursControl_DropDownListSelected
    public int DeptCodeForReceptionHoursControl_DropDownListSelected
    {
        get
        {
            object obj = GetObjectFromViewState("DeptCodeForReceptionHoursControl_DropDownListSelected");

            if (obj != null)
                return (int)obj;
            else
                return -1;
        }
        set
        {
            this._deptCodeForReceptionHoursControl_DropDownListSelected = value;
            SetObjectToViewState("DeptCodeForReceptionHoursControl_DropDownListSelected", _deptCodeForReceptionHoursControl_DropDownListSelected);
        }
    }

    public UserInfo CurrentUser
    {
        get
        {
            UserManager u = new UserManager();
            return u.GetUserInfoFromSession();
        }
    }

    #region Properties RemarksHiddens
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

    #endregion

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        Session["GridReceptionHoursUCErrorNumber"] = 0;
        Session["GridReceptionHoursUCErrorMessage"] = string.Empty;

        ScriptManager sm = ScriptManager.GetCurrent(Page);

        bool ff = sm.IsInAsyncPostBack;

        if (!Page.IsPostBack && ff == false)
        {
            CultureInfo myCIintl = new CultureInfo("he-IL", false);
        }

        if (Page.IsPostBack && Session["EmployeeReceiveGuestsToBeChangedTo"] != null)
        {
            bool EmployeeReceiveGuests = Convert.ToBoolean(Session["EmployeeReceiveGuestsToBeChangedTo"]);

            SetReceiveGuests(EmployeeReceiveGuests);

            Session["EmployeeReceiveGuestsToBeChangedTo"] = null;
        }

        if (Page.IsPostBack && Session["ParametersToCopyClinicHoursToEmployeeHours"] != null)
        {
            string[] ParametersToCopyClinicToEmployeeHours = Session["ParametersToCopyClinicHoursToEmployeeHours"].ToString().Split(';');
            int ServiceCode = Convert.ToInt32(ParametersToCopyClinicToEmployeeHours[0]);
            int DeptCode = Convert.ToInt32(ParametersToCopyClinicToEmployeeHours[1]);

            CopyEmployeeServiceHoursFromClinicHours(ServiceCode, DeptCode);

            Session["ParametersToCopyClinicHoursToEmployeeHours"] = null;
        }
    }

    private void CopyEmployeeServiceHoursFromClinicHours(int serviceCode, int DeptCode)
    {
        // Get clinic hours
        DataTable dtClinicHours = new DataTable();
        DataSet dsClinicHours = new DataSet();

        int CheckResult = 0;

        ReceptionHoursManager receptionHoursManager = new ReceptionHoursManager();

        ClinicManager clinicManager = new ClinicManager();
        int receptionHoursType = 1; // שעות קבלה

        clinicManager.GetDeptReceptions(ref dsClinicHours, DeptCode, receptionHoursType);
        dtClinicHours = dsClinicHours.Tables[0];
        string filter = string.Empty;

        //if (!this.EmployeeIsMedicalTeamOrVirtualDoctor)
        //{
        //    filter = "deptCode = " + DeptCode.ToString() + " and receptionDay > 0 ";
        //}
        //else 
        //{
        filter = "deptCode = " + DeptCode.ToString() + " and receptionDay > 0  and ItemID = " + serviceCode.ToString();
        //}

        if (dtClinicHours.Rows.Count > 0)
        {
            if (dtOriginalData.Select(filter).Count() == 0)
            {
                // If there is NO reception hours for the Employee (person) in this clinic OR Employee (Team) in this clinic for this service
                // Check overlapping in other clinics
                bool foundOverlapp = false;

                if (!this.EmployeeIsMedicalTeamOrVirtualDoctor && this.EmployeeIsMedicalTeamOrVirtualDoctor) // לא משנה מה
                {
                    foreach (DataRow drEmployeCurrenteReceptions in dtOriginalData.Rows)
                    {
                        foreach (DataRow drClinicHours in dtClinicHours.Rows)
                        {
                            if (drEmployeCurrenteReceptions["receptionDay"].ToString() == drClinicHours["receptionDay"].ToString())
                            {
                                if (!HoursAreValid(drEmployeCurrenteReceptions["OpeningHour"].ToString(), drEmployeCurrenteReceptions["ClosingHour"].ToString(), drClinicHours["OpeningHour"].ToString(), drClinicHours["closingHour"].ToString()))
                                {
                                    foundOverlapp = true;
                                }
                            }
                        }
                    }
                }

                if (!foundOverlapp)
                {
                    CopyClinicReceptionHoursToEmployeeServiceReceptionHours(ref dtClinicHours, DeptCode, serviceCode);
                    CheckResult = 1;
                }
                else
                {
                    CheckResult = 0;
                }
            }
            else
            {
                CheckResult = 0;
            }

        }
        else
        {
            // Nothing to copy
            CheckResult = -1;

        }
        if (CheckResult == 0)
        {
            string messageText = "העתקה השעות אינה אפשרית מכיוון שלנותן השירות הוזנו שעות ביחידה או שקיימת חפיפה עם שעות ביחידה.";
            ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);
        }
        else if (CheckResult == -1)
        {
            string messageText = "העתקה השעות אינה אפשרית מכיוון שלא מוגדרים שעות ביחידה.";
            ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);
        }

    }

    private bool CopyClinicReceptionHoursToEmployeeServiceReceptionHours(ref DataTable dtClinicHours, int DeptCode, int serviceCode)
    {
        string filterToSelect = "deptCode = " + DeptCode.ToString() + " AND ItemID = " + serviceCode.ToString();

        DataRow[] resultsRow = dtOriginalData.Select(filterToSelect);
        DataRow templateRow = resultsRow[0]; // resultsRow[0].cop
        int Add_ID = 0;

        foreach (DataRow drClinicHours in dtClinicHours.Rows)
        {
            DataRow drEmployeCurrenteReceptions = dtOriginalData.NewRow();

            drEmployeCurrenteReceptions.ItemArray = templateRow.ItemArray;

            drEmployeCurrenteReceptions["deptCode"] = DeptCode;
            drEmployeCurrenteReceptions["receptionDay"] = drClinicHours["receptionDay"];
            drEmployeCurrenteReceptions["openingHour"] = drClinicHours["openingHour"];
            drEmployeCurrenteReceptions["closingHour"] = drClinicHours["closingHour"];
            drEmployeCurrenteReceptions["validFrom"] = DateTime.Now.ToString("dd/MM/yyyy");
            drEmployeCurrenteReceptions["Newly_Added"] = 1;
            drEmployeCurrenteReceptions["Add_ID"] = Add_ID;

            dtOriginalData.Rows.Add(drEmployeCurrenteReceptions);
            Add_ID = Add_ID + 1;
        }

        dgReceptionHours.DataSource = null;

        DataBind();

        return true;
    }
    //private bool HoursAreValid(DataRow firstRow, DataRow secondRow)
    private bool HoursAreValid(string openingHour_1, string closingHour_1, string openingHour_2, string closingHour_2)
    {
        TimeSpan firstOpen = Convert.ToDateTime(openingHour_1).TimeOfDay;
        TimeSpan firstClose = Convert.ToDateTime(closingHour_1).TimeOfDay;
        TimeSpan secondOpen = Convert.ToDateTime(openingHour_2).TimeOfDay;
        TimeSpan secondClose = Convert.ToDateTime(closingHour_2).TimeOfDay;


        // if hours are overlapp - not valid, unless it's same dept and same hours
        if (firstClose > secondOpen)
        {
            if ((firstOpen >= secondOpen && firstOpen <= secondClose)
                || (firstClose >= secondOpen && firstClose <= secondClose)
                || (secondOpen >= firstOpen && secondOpen <= firstClose)
                || (secondClose >= firstOpen && secondClose <= firstClose)
                )
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        return true;
    }

    public void ddlDept_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow row = null;
        UserControls_MultiDDlSelect MultiDDlSelect_DepartItems = null;
        DropDownList ddlAgreementType = null;
        try
        {
            DropDownList ddlDept = sender as DropDownList;
            if (ddlDept != null && ddlDept.SelectedIndex != -1)
            {

                if (ddlDept.ID == "ddlDept")
                {
                    row = dgReceptionHours.HeaderRow;
                    MultiDDlSelect_DepartItems = row.FindControl("MultiDDlSelect_DepartItems") as UserControls_MultiDDlSelect;

                    ddlAgreementType = row.FindControl("ddlAgreementType") as DropDownList;
                    BindDDlAgreementType(ddlDept.SelectedValue, ddlAgreementType, this.dtOriginalData, false);

                }
                else if (ddlDept.ID == "ddlDeptE")
                {
                    row = ddlDept.Parent.Parent.Parent.Parent as GridViewRow;
                    MultiDDlSelect_DepartItems = row.FindControl("MultiDDlSelect_DepartItemsE") as UserControls_MultiDDlSelect;
                }

                if (MultiDDlSelect_DepartItems != null)
                {
                    int selectedCode = int.Parse(ddlDept.SelectedValue);
                    BindSelectedDeptItems(selectedCode, MultiDDlSelect_DepartItems, null);
                    MultiDDlSelect_DepartItems.TextBox.Text = "";
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    public new void DataBind()
    {
        BindGrid();
    }

    public void UpdateControl(DataTable dtRemainingItems)
    {
        try
        {
            //update SourceData first - because i use linq to find out codes of deleted items 
            // if i will delete first from dtOrder - i will lost codes of deleted items 
            DataTable org = this.dtOriginalData;
            //DataTable src = this.SourceData;

            DataTable dtItemsMustBeDeleted = GetItemsMustBeDeleted(this.dtOriginalData, dtRemainingItems);

            DataTable dtItemsMustBeAdded = GetItemsMustBeAdded(this.dtOriginalData, dtRemainingItems);

            //if (dtItemsMustBeDeleted != null && dtItemsMustBeDeleted.Rows.Count > 0)
            //{
            //    UpdateSourceData(dtItemsMustBeDeleted);
            //}

            SetObjectToViewState("collectionDepts", null);
            UpdateOriginalData(dtItemsMustBeDeleted, dtItemsMustBeAdded);

            org = this.dtOriginalData;
            this.CollectionDepts = BuildDeptCollection(this.dtOriginalData);

            DataBind();
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    /// <summary>
    /// return data when occures event 'Save'
    /// </summary>
    /// <returns></returns>
    public DataTable ReturnData()
    {
        DataTable dtChangedData = null;
        try
        {
            DataTable dtOriginalData = this.dtOriginalData;
            if (dtOriginalData != null && dtOriginalData.Rows.Count > 0)
            {
                dtChangedData = dtOriginalData;
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }

        return dtChangedData;
    }

    public DataTable ReturnData(bool SpreadOverlappingRemark)
    {
        DataTable dtChangedData = null;
        try
        {
            DataTable dtOriginalData = this.dtOriginalData;
            if (dtOriginalData != null && dtOriginalData.Rows.Count > 0)
            {
                SpreadOverlapingRemark(dtOriginalData);
                dtChangedData = dtOriginalData;
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }

        return dtChangedData;
    }

    #region Days

    private string ReturnDays(string days)
    {
        string day = String.Empty;

        if (_tblReceptionDays == null)
        {
            _tblReceptionDays = GetReceptionDaysTable();
        }

        string[] days_receptionID = SPLIT_COMMA(days);
        if (days_receptionID != null)
        {
            foreach (string day_receptionID in days_receptionID)
            {
                if (day_receptionID != String.Empty)
                {
                    DataRow[] rows = _tblReceptionDays.Select("ReceptionDayCode = " + day_receptionID);
                    if (rows != null)
                    {
                        day += rows[0][1].ToString() + ",";
                    }
                }
            }
        }
        if (day != String.Empty)
        {
            day = day.Remove(day.Length - 1, 1);
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

    #region DropDownList

    private void BindDDlDept(DropDownList ddlDept, bool isEdit)
    {
        ListItem item = null;
        UserInfo currentUser = Session["currentUser"] as UserInfo;

        if (ddlDept != null)
        {
            if (!currentUser.IsAdministrator)
            {
                foreach (receptionHoursDept currentDept in CollectionDepts.Values)
                {
                    foreach (var userDept in currentUser.UserDepts)
                    {
                        if (userDept == currentDept.deptCode)
                        {
                            item = new ListItem(currentDept.deptName, currentDept.deptCode.ToString());
                            ddlDept.Items.Add(item);
                        }
                    }
                }
            }
            else
            {
                foreach (receptionHoursDept currentDept in CollectionDepts.Values)
                {
                    item = new ListItem(currentDept.deptName, currentDept.deptCode.ToString());
                    ddlDept.Items.Add(item);
                }
            }



            if (!isEdit)
            {
                item = new ListItem(ConstsSystem.CHOOSE, "-1");
                ddlDept.Items.Insert(0, item);
                if (ddlDept.Items.FindByValue(this.DeptCodeForReceptionHoursControl_DropDownListSelected.ToString()) != null)
                {
                    ddlDept.Items.FindByValue(this.DeptCodeForReceptionHoursControl_DropDownListSelected.ToString()).Selected = true;
                }
                else
                {
                    ddlDept.SelectedIndex = this.DeptCodeForReceptionHoursControl_DropDownListSelected;
                    //ddlDept.SelectedIndex = 0;                
                }

            }
        }
    }

    private void BindDDlAgreementType(string deptCode, DropDownList ddlAgreementType, DataTable dataTable, bool isEdit)
    {
        ListDictionary list = new ListDictionary();
        int agreementType = -1;
        string agreementTypeDescription = string.Empty;

        foreach (DataRow row in dataTable.Rows)
        {
            if (row["deptCode"] != DBNull.Value)
            {
                if (Convert.ToInt32(row["deptCode"]) == Convert.ToInt32(deptCode))
                {
                    agreementType = Convert.ToInt32(row["agreementType"]);
                    agreementTypeDescription = row["agreementTypeDescription"].ToString();

                    if (!list.Contains(agreementType))
                    {
                        list.Add(agreementType, agreementTypeDescription);
                    }
                }
            }
        }

        if (list.Count < 1)
        {
            ddlAgreementType.Items.Clear();
            ddlAgreementType.Enabled = false;
        }
        else
        {
            ddlAgreementType.Enabled = true;
            ddlAgreementType.DataSource = list;
            ddlAgreementType.DataValueField = "Key";
            ddlAgreementType.DataTextField = "Value";
            ddlAgreementType.DataBind();
        }
    }

    private void BindSelectedDeptItems(int selectedDept, UserControls_MultiDDlSelect mltDdl, object obg)
    {
        string selectedItems = String.Empty;

        if (selectedDept > -1)
            BindDeptItems(mltDdl, selectedDept);

        //GridViewRow row = mltDdl.Parent.Parent.Parent.Parent as GridViewRow;
        GridViewRow row = mltDdl.Parent.Parent as GridViewRow;

        if (row.RowType == DataControlRowType.DataRow)
        {
            selectedItems = SelectMddlItems(mltDdl, obg);

            if (!String.IsNullOrEmpty(selectedItems))
            {
                selectedItems = selectedItems.Remove(selectedItems.Length - 1, 1);
                mltDdl.TextBox.Text = selectedItems;
            }
        }
    }

    private string SelectMddlItems(UserControls_MultiDDlSelect mltDdl, object obg)
    {
        string selectedItems = String.Empty;
        foreach (ListItem itemL in mltDdl.Items.Items)
        {
            if (isItemCodeSelected(itemL.Value, obg))
            {
                itemL.Selected = true;
                selectedItems += itemL.Text + ",";
            }
        }
        return selectedItems;
    }

    private bool isItemCodeSelected(string itemCode, object obg)
    {
        if (obg is DataTable)
        {
            DataTable dtData = obg as DataTable;
            foreach (DataRow row in dtData.Rows)
            {
                if (row["itemsCodes"] != null)
                {
                    string itemCodes = row["itemsCodes"].ToString();

                    string[] selectedItems = SPLIT_COMMA(itemCodes);
                    if (selectedItems.Contains(itemCode))
                        return true;
                }
            }
        }
        else if (obg is string)
        {
            string itemsCodes = obg as string;
            string[] selectedItems = SPLIT_COMMA(itemsCodes);
            if (selectedItems.Contains(itemCode))
                return true;

        }
        return false;
    }

    //private void OpenMddlItems(UserControls_MultiDDlSelectUC mltDdl)
    //{
    //    string ctlID = mltDdl.Button.ClientID;

    //    string var = "  var btn = document.getElementById('" + ctlID + "'); if(btn!= null) { btn.click(); } ";
    //    UpdatePanel UpdatePanel1 = this.Parent.Parent as UpdatePanel;
    //    ScriptManager.RegisterClientScriptBlock(UpdatePanel1, typeof(UpdatePanel), "JsVariableValidationKey_" + ctlID, var, true);
    //}

    private void BindDeptItems(UserControls_MultiDDlSelect mltDdl, int selectedDept)
    {

        Items items = GetSpesificDeptItemsObjects(selectedDept);
        mltDdl.Items.Items.Clear();
        //mltDdl.TextBox.Text = String.Empty;

        if (items != null)
        {
            foreach (Item curItem in items)
            {
                string itemCode = curItem.itemID.ToString();
                string itemDesc = curItem.itemName;

                ListItem item = new ListItem(itemDesc, itemCode);
                item.Attributes.Add("title", itemDesc);
                mltDdl.Items.Items.Add(item);
            }
            mltDdl.DataBind();
        }
    }

    #endregion

    #region GetItems(Services) by selected Dept

    private Items GetSpesificDeptItemsObjects(int p_selectedDept)
    {
        receptionHoursDept dept = GetDeptFromCollection(p_selectedDept);
        if (dept != null)
        {
            return dept.Entities;
        }
        else
            return null;
    }

    private receptionHoursDept GetDeptFromCollection(int p_selectedDept)
    {
        object objDept = this.CollectionDepts[p_selectedDept];
        if (objDept != null)
        {
            receptionHoursDept dept = (receptionHoursDept)objDept;
            if (dept != null)
            {
                return dept;
            }
        }

        return null;
    }

    #endregion

    /// <summary>
    /// get new values of receprion .get from header or from row - this depends on mode
    /// </summary>
    /// <param name="p_selectedDept"></param>
    /// <param name="p_selectedDeptName"></param>
    /// <param name="hTblDepartItems"></param>
    /// <param name="hTblDepartItemsTypes"></param>
    /// <param name="selectedDays"></param>
    /// <param name="fromHour"></param>
    /// <param name="toHour"></param>
    /// <param name="hTblNewRemark"></param>
    /// <param name="fromDate"></param>
    /// <param name="toDate"></param>
    /// <param name="row"></param>
    /// <param name="isEditMode"></param>
    private void GetNewReceptionValues(ref string p_selectedDept, ref string p_selectedDeptName, ref string p_selectedAgreementType, ref string p_selectedAgreementTypeDescription,
        ref ListDictionary hTblDepartItems, ref ListDictionary hTblDepartItemsTypes, ref string selectedDays,
        ref string fromHour, ref string toHour, ref ListDictionary dicNewRemark, ref string fromDate,
        ref string toDate, GridViewRow row, ref string receptionRoom, ref bool receiveGuests, bool isEditMode)
    {
        #region declaration
        DropDownList ddlDept = null;
        DropDownList ddlAgreementType = null;
        Label lblAgreementType = null;
        Label lblAgreementTypeDescription = null;
        UserControls_MultiDDlSelect mDDlDepartItems = null;
        UserControls_MultiDDlSelectUC MultiDDlSelect_Days = null;
        TextBox txtToDate = null;
        TextBox txtFromDate = null;
        TextBox txtFromHour = null;
        TextBox txtToHour = null;
        TextBox txtReceptionRoom = null;
        HiddenField hdnRemarkText = null;
        HiddenField hdnRemarkMask = null;
        HiddenField hdnRemarkID = null;
        CheckBox cbReceiveGuests = null;
        #endregion

        if (!isEditMode)
        {
            ddlDept = row.FindControl("ddlDept") as DropDownList;
            ddlAgreementType = row.FindControl("ddlAgreementType") as DropDownList;
            mDDlDepartItems = row.FindControl("MultiDDlSelect_DepartItems") as UserControls_MultiDDlSelect;
            MultiDDlSelect_Days = row.FindControl("MultiDDlSelect_Days") as UserControls_MultiDDlSelectUC;
            txtToDate = row.FindControl("txtToDate") as TextBox;
            txtFromDate = row.FindControl("txtFromDate") as TextBox;
            txtFromHour = row.FindControl("txtFromHour") as TextBox;
            txtToHour = row.FindControl("txtToHour") as TextBox;
            txtReceptionRoom = row.FindControl("txtReceptionRoom") as TextBox;
            cbReceiveGuests = row.FindControl("cbReceiveGuests") as CheckBox;
            hdnRemarkText = row.FindControl("hdnRemarkText") as HiddenField;
            hdnRemarkMask = row.FindControl("hdnRemarkMask") as HiddenField;
            hdnRemarkID = row.FindControl("hdnRemarkID") as HiddenField;
        }
        else // mode edit
        {
            ddlDept = row.FindControl("ddlDeptE") as DropDownList;
            lblAgreementType = row.FindControl("lblAgreementType") as Label;
            lblAgreementTypeDescription = row.FindControl("lblAgreementTypeDescription") as Label;
            mDDlDepartItems = row.FindControl("MultiDDlSelect_DepartItemsE") as UserControls_MultiDDlSelect;
            MultiDDlSelect_Days = row.FindControl("mltDdlDayE") as UserControls_MultiDDlSelectUC;
            txtToDate = row.FindControl("txtToDate") as TextBox;
            txtFromDate = row.FindControl("txtFromDate") as TextBox;
            txtFromHour = row.FindControl("txtFromHour") as TextBox;
            txtToHour = row.FindControl("txtToHour") as TextBox;
            txtReceptionRoom = row.FindControl("txtReceptionRoom") as TextBox;
            cbReceiveGuests = row.FindControl("cbReceiveGuests") as CheckBox;
            hdnRemarkText = hdnRemarkText_E;
            hdnRemarkMask = hdnRemarkMask_E;
            hdnRemarkID = hdnRemarkID_E;

        }

        if (!isEditMode)//mode Add new 
        {
            //if (GetObjectFromViewState("newAddedDept") != null)
            if (!string.IsNullOrEmpty(ddlDept.SelectedValue))
            {
                //p_selectedDept = GetObjectFromViewState("newAddedDept").ToString();
                p_selectedDept = ddlDept.SelectedValue;
            }
            else
            {
                if (GetObjectFromViewState("selectedDept") != null)
                {
                    p_selectedDept = GetObjectFromViewState("selectedDept").ToString();
                }
                else
                {
                    p_selectedDept = ddlDept.SelectedItem.Value;
                }
            }

            if (!string.IsNullOrEmpty(ddlAgreementType.SelectedValue))
            {
                p_selectedAgreementType = ddlAgreementType.SelectedItem.Value;
                p_selectedAgreementTypeDescription = ddlAgreementType.SelectedItem.Text;
            }
        }
        else //mode Edit
        {
            if (Dept > -1)
                p_selectedDept = Dept.ToString();
            else
                p_selectedDept = ddlDept.SelectedItem.Value;

            p_selectedAgreementType = lblAgreementType.Text;
            p_selectedAgreementTypeDescription = lblAgreementTypeDescription.Text;
        }

        if (p_selectedDept != String.Empty)
        {
            receptionHoursDept dept = GetDeptFromCollection(int.Parse(p_selectedDept));
            if (dept != null)
            {
                p_selectedDeptName = dept.deptName;
            }
        }

        if (mDDlDepartItems != null)
        {
            GetDepartItems(hTblDepartItems, hTblDepartItemsTypes, mDDlDepartItems, int.Parse(p_selectedDept));
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
            fromDate = GetToDate(txtFromDate);
            if (fromDate.ToString().Trim() == String.Empty)
            {
                fromDate = DateTime.Today.ToShortDateString();
            }
        }

        if (txtFromHour != null)
        {
            fromHour = GetToDate(txtFromHour);
        }

        if (txtToHour != null)
        {
            toHour = GetToDate(txtToHour);
        }

        if (txtReceptionRoom != null)
        {
            receptionRoom = txtReceptionRoom.Text;
        }

        if (cbReceiveGuests != null)
        {
            receiveGuests = cbReceiveGuests.Checked;
        }

        if (hdnRemarkText != null)
        {
            GetRemark(ref dicNewRemark, "remarkText", hdnRemarkText.Value);
            hdnRemarkText.Value = String.Empty;
        }
        if (hdnRemarkMask != null)
        {
            GetRemark(ref dicNewRemark, "remarkMask", hdnRemarkMask.Value);
            hdnRemarkMask.Value = String.Empty;
        }
        if (hdnRemarkID != null)
        {
            GetRemark(ref dicNewRemark, "remarkID", hdnRemarkID.Value);
            hdnRemarkID.Value = String.Empty;
        }
    }

    private void GetRemark(ref ListDictionary dicNewRemark, string key, string hValue)
    {
        dicNewRemark.Add(key, this.Page.Server.UrlDecode(hValue));
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

    private void GetDepartItems(ListDictionary dicDepartItems, ListDictionary dicDepartItemsTypes, UserControls_MultiDDlSelect mDDlDepartItems, int selectedDept)
    {
        CheckBoxList lst = mDDlDepartItems.Items;
        if (lst != null)
        {
            foreach (ListItem curItem in lst.Items)
            {
                if (curItem.Selected)
                {
                    string itemId = curItem.Value;
                    string itemDesc = curItem.Text;
                    string itemType = String.Empty;
                    if (!dicDepartItems.Contains(itemId))
                        dicDepartItems.Add(itemId, itemDesc);

                    //// bug - ListItem does'nt save attributes  - i need accept item type 
                    //string type = String.Empty;                       
                    //DataTable dtServicesProfessions = GetEmployeeSpesificDeptServicesProfessions(int.Parse( selectedDept));

                    //if (dtServicesProfessions != null && dtServicesProfessions.Rows.Count > 0)
                    //{
                    //  DataRow[] rows = dtServicesProfessions.Select(" ItemID =" + curItem.Value.ToString() + " and  ItemDesc = '" + curItem.Text + "'");
                    //  if (rows != null && rows.Length > 0)
                    //  {
                    //     type = rows[0]["ItemType"].ToString();
                    //     if (!hTblDepartItemsTypes.ContainsKey(curItem.Value))
                    //        hTblDepartItemsTypes.Add(curItem.Value, type);
                    //  }
                    //}  


                    receptionHoursDept dept = GetDeptFromCollection(selectedDept);
                    if (dept != null)
                    {
                        Item item = dept.Entities.GetByKey(int.Parse(itemId));
                        if (item != null)
                        {
                            itemType = item.itemType.ToString();
                            if (!dicDepartItemsTypes.Contains(itemId))
                                dicDepartItemsTypes.Add(itemId, itemType);

                        }
                    }
                }
            }
        }

        //CloseMddlItems(mDDlDepartItems);

    }

    #endregion

    private void InsertRemarkAfterConflict(string clientID)
    {
        string remark = GetConflictRemark();
        ListDictionary hTblRemark = GetRemarkDetailsInConflict();

        if (hTblRemark != null)
        {
            string remarkText = hTblRemark["remarkText"].ToString();
            string remarkMask = hTblRemark["remarkMask"].ToString();
            string remarkID = hTblRemark["remarkID"].ToString();

            string txtRemarkClientID = dgReceptionHours.HeaderRow.FindControl("inpTitleRemark").ClientID;
            string hdnRemarkIdClientID = dgReceptionHours.HeaderRow.FindControl("hdnRemarkID").ClientID;
            string hdnRemarkTextClientID = dgReceptionHours.HeaderRow.FindControl("hdnRemarkText").ClientID;
            string hdnRemarkMaskClientID = dgReceptionHours.HeaderRow.FindControl("hdnRemarkMask").ClientID;

            if (!String.IsNullOrEmpty(remark))
            {
                String scriptString = "javascript: function insertRemarkConflictData_" + clientID + "()" +
                    " { " +
                    //"  var inpTitleRemark = document.getElementById('" + txtRemarkClientID + "'); " +
                    //"  if (inpTitleRemark != null)" +
                    //"       inpTitleRemark.value ='" + this.Page.Server.UrlDecode(remark) + "';" +

                    //remarkID
                    "  var hdnRemarkID = document.getElementById('" + hdnRemarkIdClientID + "');" +
                    "  if (hdnRemarkID != null) " +
                    "       hdnRemarkID.value ='" + this.Page.Server.UrlDecode(remarkID) + "';" +

                    // remark text
                    "  var hdnRemarkText = document.getElementById('" + hdnRemarkTextClientID + "');" +
                    "  if (hdnRemarkText != null)" +
                    "       hdnRemarkText.value ='" + this.Page.Server.UrlDecode(remarkText) + "';" +

                    // remark mask
                    "  var hdnRemarkMask = document.getElementById('" + hdnRemarkMaskClientID + "');" +
                    "  if (hdnRemarkMask != null)" +
                    "       hdnRemarkMask.value ='" + this.Page.Server.UrlDecode(remarkMask) + "';" +

                    " } " +
                    "insertRemarkConflictData_" + clientID + "();";
                UpdatePanel UpdPanelHours = this.FindControl("UpdPanelHours") as UpdatePanel;

                ScriptManager sm = ScriptManager.GetCurrent(Page);
                if (sm != null && UpdPanelHours != null)
                {
                    ScriptManager.RegisterClientScriptBlock(UpdPanelHours, typeof(UpdatePanel), "JsRemarkConflictData_" + clientID, scriptString, true);
                }
            }
        }
    }

    private void InsertRemarkAfterConflictForExistRow(string clientID)
    {
        string remark = GetConflictRemark();
        ListDictionary hTblRemark = GetRemarkDetailsInConflict();

        if (hTblRemark != null)
        {

            string remarkText = hTblRemark["remarkText"].ToString();
            string remarkMask = hTblRemark["remarkMask"].ToString();
            string remarkID = hTblRemark["remarkID"].ToString();

            GridViewRow currRow = dgReceptionHours.Rows[dgReceptionHours.EditIndex];

            string lblRemarkTextClientID = currRow.FindControl("lblRemarkText_E").ClientID;
            string lblRemarkIDClientID = currRow.FindControl("lblRemarkID_E").ClientID;
            string lblRemarkMaskClientID = currRow.FindControl("lblRemarkMask_E_c").ClientID;

            if (!String.IsNullOrEmpty(remark))
            {
                String scriptString = "javascript: function inserRemarkConflictDataForExistRow_" + clientID + "()" +
                    " { " +
                    //remarkText
                    "  var lblRemarkText_E = document.getElementById('" + lblRemarkTextClientID + "'); " +
                    "  if (lblRemarkText_E != null) " +
                    " lblRemarkText_E.value ='" + this.Page.Server.UrlDecode(remark) + "'; " +

                     //remarkID
                     "  var lblRemarkID_E = document.getElementById('" + lblRemarkIDClientID + "');" +
                    "  if (lblRemarkID_E != null)" +
                    " lblRemarkID_E.value ='" + this.Page.Server.UrlDecode(remarkID) + "';" +

                        //remarkMask
                        "  var lblRemarkMask_E_c = document.getElementById('" + lblRemarkMaskClientID + "');" +
                        "  if (lblRemarkMask_E_c != null && lblRemarkMask_E_c[0] != null)" +
                        " lblRemarkMask_E_c[0].value ='" + this.Page.Server.UrlDecode(remarkMask) + "';" +

                    " } " +
                    "inserRemarkConflictDataForExistRow_" + clientID + "();";
                UpdatePanel UpdPanelHours = this.FindControl("UpdPanelHours") as UpdatePanel;

                ScriptManager sm = ScriptManager.GetCurrent(Page);
                if (sm != null && UpdPanelHours != null)
                {
                    ScriptManager.RegisterClientScriptBlock(UpdPanelHours, typeof(UpdatePanel), "JsRemarkConflictData_" + clientID, scriptString, true);
                }
            }
        }
    }

    private string GetConflictRemark()
    {
        string remark = String.Empty;
        ListDictionary hTblError = null;
        ListDictionary hTblNewRemark = null;

        if (ViewState["conflictData"] != null)
        {
            hTblError = (ListDictionary)ViewState["conflictData"];
            if (hTblError != null && hTblError["hTblNewRemark"] != null)
            {
                hTblNewRemark = (ListDictionary)hTblError["hTblNewRemark"];
                if (hTblNewRemark != null)
                {
                    remark = hTblNewRemark["remarkText"].ToString();
                }
            }
        }

        return remark;
    }

    private void BindGrid()
    {
        DataTable dataSourceDT;

        if (Dept == -1)
        {
            dataSourceDT = new DataView(this.dtOriginalData, "ReceptionID is not null OR Add_ID is not null", CurrentDept_deptCode_ReceptionDay_OpeningHour_SORT, DataViewRowState.CurrentRows).ToTable();
        }
        else
        {
            dataSourceDT = new DataView(this.dtOriginalData, "DeptCode=" + Dept + " AND ReceptionID is not null OR Add_ID is not null", DEFAULT_SORT, DataViewRowState.CurrentRows).ToTable();
        }

        CheckEmptyRow(dataSourceDT);

        SpreadOverlapingRemark(dataSourceDT);

        dgReceptionHours.DataSource = dataSourceDT;
        dgReceptionHours.DataBind();


        if (dgReceptionHours.EditIndex > -1)
        {
            SaveErrorEditedRowWhenTabs();
        }

    }

    private ListDictionary GetRemarkDetailsInConflict()
    {
        ListDictionary hTblNewRemark = null;

        ListDictionary hTblError = (ListDictionary)ViewState["conflictData"]; ;

        string selectedCode = String.Empty;
        string fromHour = String.Empty;
        string toHour = String.Empty;
        string fromDate = string.Empty;
        string toDate = string.Empty;
        string days = String.Empty;
        string slctDeptCode = String.Empty;

        if (hTblError != null)
        {
            GetConflictData(hTblError, ref fromHour, ref toHour, ref fromDate,
                                 ref toDate, ref days, ref hTblNewRemark, ref slctDeptCode);

            if (dgReceptionHours.EditIndex > -1)
            {
                GridViewRow editedRow = dgReceptionHours.Rows[dgReceptionHours.EditIndex];
                if (editedRow != null)
                    DoImgConflictVisible(editedRow);
            }
        }
        return hTblNewRemark;
    }

    private void SaveErrorEditedRowWhenTabs()
    {
        GridViewRow editedRow = dgReceptionHours.Rows[dgReceptionHours.EditIndex];
        if (editedRow != null)
        {
            ListDictionary hTblError = null;
            int selectedDeptCode = -1;
            string selectedCode = String.Empty;
            string fromHour = String.Empty;
            string toHour = String.Empty;
            string fromDate = string.Empty;
            string toDate = string.Empty;
            string days = String.Empty;
            string slctDeptCode = String.Empty;

            ListDictionary hTblNewRemark = null;

            if (ViewState["conflictData"] != null)
            {
                hTblError = (ListDictionary)ViewState["conflictData"];
                if (hTblError != null)// if this data not for new added reception                         
                {
                    GetConflictData(hTblError, ref fromHour, ref toHour, ref fromDate, ref toDate, ref days, ref hTblNewRemark, ref slctDeptCode);

                    DoImgConflictVisible(editedRow);
                }

                #region Days
                UserControls_MultiDDlSelectUC mltDdlDayE = editedRow.FindControl("mltDdlDayE") as UserControls_MultiDDlSelectUC;
                if (mltDdlDayE != null && !String.IsNullOrEmpty(days))
                {
                    MultiDDlSelectUCSelectDays(days, mltDdlDayE);
                }
                #endregion

                #region ErrorHours
                //for validation
                //SetFromToClientsIdsToHiddenFields(editedRow);

                TextBox txtFromHour = editedRow.FindControl("txtFromHour") as TextBox;
                if (fromHour != string.Empty && txtFromHour != null)
                {
                    txtFromHour.Text = fromHour;
                }

                TextBox txtToHour = editedRow.FindControl("txtToHour") as TextBox;
                if (toHour != string.Empty && txtToHour != null)
                {
                    txtToHour.Text = toHour;
                }

                #endregion

                #region ErrorDates

                TextBox txtFromDate = editedRow.FindControl("txtFromDate") as TextBox;
                if (txtFromDate != null && !string.IsNullOrEmpty(fromDate))
                {
                    txtFromDate.Text = fromDate;
                }

                TextBox txtToDate = editedRow.FindControl("txtToDate") as TextBox;
                if (txtToDate != null && !string.IsNullOrEmpty(toDate))
                {
                    txtToDate.Text = toDate;
                }
                #endregion

                /*#region Get selected dept code
                if (ddlDeptE != null)
                {
                    if (this.CollectionDepts != null && this.CollectionDepts.Count > 0)
                    {
                        BindDDlDept(ddlDeptE, true);

                        ddlDeptE.SelectedValue = slctDeptCode;
                        if (ddlDeptE.Items.Count > 0)
                        {
                            selectedDeptCode = int.Parse(ddlDeptE.SelectedValue);
                        }
                    }
                }
                else
                {
                    selectedDeptCode = this.Dept;
                }
                #endregion*/

                #region DeptItems - professions and services
                UserControls_MultiDDlSelect MultiDDlSelect_DepartItemsE = editedRow.FindControl("MultiDDlSelect_DepartItemsE") as UserControls_MultiDDlSelect;

                if (MultiDDlSelect_DepartItemsE != null && selectedDeptCode != -1)
                {
                    //MultiDDlSelect_DepartItemsE.TextBox.Width = Unit.Parse("95px");
                    //MultiDDlSelect_DepartItemsE.Panel.Width = Unit.Parse("95px");

                    //if i want to click on second tab - i want to save changes
                    //i bind all items to MultiDDlSelect_DepartItemsE
                    // ans selecte only items that were selected in previous tab 
                    // not items taht were selected in event binding 
                    BindSelectedDeptItems(selectedDeptCode, MultiDDlSelect_DepartItemsE, null);
                    ListDictionary hTblDepartItems = (ListDictionary)hTblError["hTblDepartItems"];
                    ListDictionary hTblDepartItemsTypes = (ListDictionary)hTblError["hTblDepartItemsTypes"];

                    #region clear fron data tah was  from binding this row
                    foreach (ListItem item in MultiDDlSelect_DepartItemsE.Items.Items)
                    {
                        item.Selected = false;
                    }
                    MultiDDlSelect_DepartItemsE.TextBox.Text = String.Empty;

                    #endregion

                    if (hTblDepartItems != null && hTblDepartItems.Count > 0)
                    {
                        BindErrorDeptItems(MultiDDlSelect_DepartItemsE, hTblDepartItems);
                    }
                }
                #endregion


                if (hTblNewRemark != null && hTblNewRemark.Count > 0)
                {
                    HtmlInputText lblRemarkText_E = editedRow.FindControl("lblRemarkText_E") as HtmlInputText;
                    if (lblRemarkText_E != null)
                    {
                        lblRemarkText_E.Value = hTblNewRemark["remarkText"].ToString();
                    }

                    hdnRemarkMask_E.Value = hTblNewRemark["remarkMask"].ToString();
                    hdnRemarkText_E.Value = hTblNewRemark["remarkText"].ToString();
                    hdnRemarkID_E.Value = hTblNewRemark["remarkID"].ToString();
                }
            }
        }
    }

    private void SpreadOverlapingRemark(DataTable dtData)
    {
        ReceptionHoursManager receptionHoursManager = new ReceptionHoursManager();

        DataRow[] rowsWithRemark = dtData.Select("RemarkID = 4"); // It is all about "פעם בשבוע" remark only

        foreach (DataRow rowWithRemark in rowsWithRemark)
        {
            for (int i = 0; i < dtData.Rows.Count; i++)
            {
                if ((dtData.Rows[i]["RemarkID"].ToString() == string.Empty || dtData.Rows[i]["RemarkID"].ToString() == "-1")
                    && Convert.ToInt32(dtData.Rows[i]["deptCode"]) == Convert.ToInt32(rowWithRemark["deptCode"])
                    && Convert.ToInt32(dtData.Rows[i]["ItemID"]) == Convert.ToInt32(rowWithRemark["ItemID"])
                    && dtData.Rows[i]["ReceptionDay"].ToString() == rowWithRemark["ReceptionDay"].ToString()
                    && DatesHaveOverlapp(dtData.Rows[i]["ValidFrom"], dtData.Rows[i]["validTo"], rowWithRemark["ValidFrom"], rowWithRemark["validTo"])
                    && (HoursAreValid(dtData.Rows[i], rowWithRemark) == false)
                    )
                {
                    dtData.Rows[i]["RemarkID"] = rowWithRemark["RemarkID"];
                    dtData.Rows[i]["RemarkText"] = rowWithRemark["RemarkText"];
                }
            }
        }
    }

    private bool HoursAreValid(DataRow firstRow, DataRow secondRow)
    {
        TimeSpan firstOpen = Convert.ToDateTime(firstRow["openingHour"]).TimeOfDay;
        TimeSpan firstClose = Convert.ToDateTime(firstRow["closingHour"]).TimeOfDay;
        TimeSpan secondOpen = Convert.ToDateTime(secondRow["openingHour"]).TimeOfDay;
        TimeSpan secondClose = Convert.ToDateTime(secondRow["closingHour"]).TimeOfDay;

        if (firstClose > secondOpen)
        {
            if (firstOpen == secondOpen && firstClose == secondClose)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        return true;
    }

    private bool DatesHaveOverlapp(object firstFrom, object firstTo, object secondFrom, object secondTo)
    {
        DateTime? firstDateFrom, firstDateTo, secondDateFrom, secondDateTo;

        firstDateFrom = ConvertToDate(firstFrom);
        firstDateTo = ConvertToDate(firstTo);
        secondDateFrom = ConvertToDate(secondFrom);
        secondDateTo = ConvertToDate(secondTo);

        if ((firstDateTo == null && secondDateTo == null) || (firstDateFrom == secondDateFrom))
        {
            return true;
        }

        if (firstDateFrom < secondDateFrom)
        {
            if (firstDateTo >= secondDateFrom || firstDateTo == null)
            {
                return true;
            }
        }
        else
        {
            if (secondDateTo >= firstDateFrom || secondDateTo == null)
            {
                return true;
            }
        }

        return false;
    }
    private DateTime? ConvertToDate(object dateObject)
    {
        DateTime? val = null;

        if (dateObject != DBNull.Value)
        {
            val = Convert.ToDateTime(dateObject);
        }

        return val;
    }

    private void CheckEmptyRow(DataTable dtData)
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
        ListDictionary hTblError = null;
        string deptCode = ((System.Data.DataRowView)(e.Row.DataItem)).Row["DeptCode"].ToString();
        Label lblValidFrom = e.Row.FindControl("lblValidFrom") as Label;
        TextBox txtFromDate = e.Row.FindControl("txtFromDate") as TextBox;
        Label lblValidTo = e.Row.FindControl("lblValidTo") as Label;
        Label lblID = e.Row.FindControl("lblID") as Label;
        object[] data = ((System.Data.DataRowView)(e.Row.DataItem)).Row.ItemArray;
        string id = String.Empty;
        Button imgUpdate = e.Row.FindControl("imgUpdate") as Button;
        ImageButton imgDelete = e.Row.FindControl("imgDelete") as ImageButton;

        if (this.EmployeeHasMoreThenOneClinic && !this.EmployeeIsMedicalTeamOrVirtualDoctor && Dept != -1)
        {
            imgUpdate.Visible = false;
            imgDelete.Visible = false;
        }
        if ((this.EmployeeIsMedicalTeamOrVirtualDoctor) && Dept == -1)
        {
            imgUpdate.Visible = false;
            imgDelete.Visible = false;
        }

        UserInfo currentUser = Session["currentUser"] as UserInfo;

        if (!currentUser.IsAdministrator && deptCode != string.Empty)
        {
            bool currentDeptIsUserPermitted = false;

            foreach (var userDept in currentUser.UserDepts)
            {
                if (userDept == Convert.ToInt32(deptCode))
                {
                    currentDeptIsUserPermitted = true;
                }
            }

            if (!currentDeptIsUserPermitted)
            {
                imgUpdate.Visible = false;
                imgDelete.Visible = false;
            }
        }

        if (ViewState["conflictData"] != null)
        {
            hTblError = (ListDictionary)ViewState["conflictData"];
            id = hTblError["Source_ID"].ToString();
        }

        //this is not new added reception ours 
        if (lblID != null && lblID.Text == id && lblID.Text != String.Empty && id != string.Empty)
        {
            DoImgConflictVisible(e.Row);
        }

        if (dgReceptionHours.EditIndex == e.Row.RowIndex)
        {
            bool singleDeptMode = Dept > -1;
            UserControls_MultiDDlSelect ddlProfessions = e.Row.FindControl("MultiDDlSelect_DepartItemsE") as UserControls_MultiDDlSelect;
            HtmlInputText txtRemark = e.Row.FindControl("lblRemarkText_E") as HtmlInputText;

            SetEditedRowControlsWidth(singleDeptMode, ddlProfessions, txtRemark);
        }

        #region Remarks

        Label lblRemark = e.Row.FindControl("lblRemark") as Label;

        if (lblRemark != null)
        {
            lblRemark.Text = lblRemark.Text.Replace("#", "");
        }
        else
        {
            HtmlInputText lblRemarkEdit = e.Row.FindControl("lblRemarkText_E") as HtmlInputText;
            if (lblRemarkEdit != null)
            {
                lblRemarkEdit.Value = lblRemarkEdit.Value.Replace("#", "");
                lblRemarkEdit.Attributes.Add("title", lblRemarkEdit.Value);
            }

        }

        #endregion

        #region Days

        Label lblDays = e.Row.FindControl("lblDays") as Label;
        Label lblDays2 = e.Row.FindControl("lblDays2") as Label;
        string day = ReturnDays(((System.Data.DataRowView)(e.Row.DataItem))["ReceptionDay"].ToString());

        if (lblDays != null)
        {
            lblDays2.Text = lblDays.Text = day;
        }

        #endregion

        #region ReceiveGuests

        Image imgReceiveGuests = e.Row.FindControl("imgReceiveGuests") as Image;
        CheckBox cbReceiveGuests = e.Row.FindControl("cbReceiveGuests") as CheckBox;

        if (cbReceiveGuests != null && ((System.Data.DataRowView)(e.Row.DataItem))["ReceiveGuests"] != System.DBNull.Value)
        {
            cbReceiveGuests.Checked = Convert.ToBoolean(((System.Data.DataRowView)(e.Row.DataItem))["ReceiveGuests"]);
        }
        if (cbReceiveGuests != null && !this.ReceptionHoursOfDoctor)
        {
            cbReceiveGuests.Style.Add("display", "none");
        }

        if (imgReceiveGuests != null && ((System.Data.DataRowView)(e.Row.DataItem))["ReceiveGuests"] != System.DBNull.Value)
        {
            if (Convert.ToBoolean(((System.Data.DataRowView)(e.Row.DataItem))["ReceiveGuests"]))
            {
                imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuestsSmall.png";
            }
            else
            {
                imgReceiveGuests.ImageUrl = "~/Images/Applic/NOTReceiveGuestsSmall.png";
            }
            //imgReceiveGuests.Visible = Convert.ToBoolean(((System.Data.DataRowView)(e.Row.DataItem))["ReceiveGuests"]);
        }

        if (imgReceiveGuests != null && (!this.ReceptionHoursOfDoctor || !this.HasServicesSubjectToReceiveGuest))
        {
            imgReceiveGuests.Visible = false;
        }

        #endregion

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

        if (txtFromDate != null)
        {
            txtFromDate.Text = DateTime.Today.ToString();
            //string from = String.Format("{0:dd/MM/yyyy}", ((System.Data.DataRowView)(e.Row.DataItem))["ValidFrom"].ToString());
            //if (from != string.Empty)
            //{
            //    DateTime dateFrom = Convert.ToDateTime(from);
            //    lblValidFrom.Text = dateFrom.ToShortDateString();
            //}
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

    private void MarkOverlappedHoursRow(GridViewRowEventArgs e)
    {
        DataRowView drv = (DataRowView)e.Row.DataItem;
        DataRow currentDR = drv.Row;
        DataTable hoursTable = drv.DataView.Table;
        if (hoursTable.Rows.Count > 1)
        {
            ReceptionHoursManager mngr = new ReceptionHoursManager();
            if (mngr.CheckIfOverlappOverThisRow(ref hoursTable, currentDR))
            {
                e.Row.Attributes["style"] = "background-color: #f2cbcf";
                Image imgShowOverlap = e.Row.FindControl("imgShowOverlap") as Image;
                if (imgShowOverlap != null)
                {
                    imgShowOverlap.Visible = true;
                }
            }
        }
    }

    private void DoImgConflictVisible(GridViewRow row)
    {
        Image imgConflict = row.FindControl("imgConflict") as Image;
        if (imgConflict != null)
        {
            imgConflict.Visible = true;
            if (row.RowType == DataControlRowType.DataRow)
            {
                row.Attributes["style"] = "background-color: #f2cbcf";
            }
        }
    }

    private void BuildGridHeader(GridViewRowEventArgs e, DataTable dtDeptEmployeeData)
    {
        ListDictionary hTblError = null;
        string selectedCode = String.Empty;
        string fromHour = String.Empty;
        string toHour = String.Empty;
        string fromDate = string.Empty;
        string toDate = string.Empty;
        string days = String.Empty;

        ListDictionary hTblNewRemark = null;
        HiddenField hdnRemarkText = e.Row.FindControl("hdnRemarkText") as HiddenField;
        HiddenField hdnRemarkMask = e.Row.FindControl("hdnRemarkMask") as HiddenField;
        HiddenField hdnRemarkID = e.Row.FindControl("hdnRemarkID") as HiddenField;

        if (ViewState["conflictData"] != null)
        {
            hTblError = (ListDictionary)ViewState["conflictData"];
            if (hTblError["AddNewMode"] == null)// if this data not for new added reception 
            {
                hTblError = null;
            }
            else
            {
                GetConflictData(hTblError, ref fromHour, ref toHour, ref fromDate,
                    ref toDate, ref days, ref hTblNewRemark, ref selectedCode);
                DoImgConflictVisible(e.Row);


                HtmlInputText txtRemark = e.Row.FindControl("inpTitleRemark") as HtmlInputText;
                ListDictionary list = hTblError["hTblNewRemark"] as ListDictionary;
                txtRemark.Value = list["remarkText"].ToString();
                hdnRemarkText.Value = list["remarkText"].ToString();
                hdnRemarkMask.Value = list["remarkMask"].ToString();
                hdnRemarkID.Value = list["remarkID"].ToString();
            }
        }

        Button imgAdd = e.Row.FindControl("imgAdd") as Button;
        ImageButton btnSpreadRoomNumber = e.Row.FindControl("btnSpreadRoomNumber") as ImageButton;

        if (this.EmployeeHasMoreThenOneClinic && !this.EmployeeIsMedicalTeamOrVirtualDoctor && Dept != -1)
        {
            imgAdd.Enabled = false;
            btnSpreadRoomNumber.Enabled = false;
        }
        if ((this.EmployeeIsMedicalTeamOrVirtualDoctor) && Dept == -1)
        {
            imgAdd.Enabled = false;
            btnSpreadRoomNumber.Enabled = false;
        }

        #region FromDate

        TextBox txtFromDate = e.Row.FindControl("txtFromDate") as TextBox;
        if (txtFromDate != null)
        {
            txtFromDate.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtFromDate.ClientID + "')";

            if (!string.IsNullOrEmpty(fromDate))
            {
                txtFromDate.Text = fromDate;
            }
            else
            {
                txtFromDate.Text = DateTime.Today.ToString();
            }
        }

        #endregion

        #region ToDate

        TextBox txtToDate = e.Row.FindControl("txtToDate") as TextBox;
        if (txtToDate != null && !string.IsNullOrEmpty(toDate))
        {
            txtToDate.Text = toDate;
        }

        #endregion

        DropDownList ddlDept = e.Row.FindControl("ddlDept") as DropDownList;
        if (ddlDept != null)
        {
            if (this.CollectionDepts != null && this.CollectionDepts.Count > 0)
            {
                BindDDlDept(ddlDept, false);

                if (ddlDept.Items.Count > 0)
                {
                    if (GetObjectFromViewState("selectedDept") != null)
                    {
                        ddlDept.SelectedValue = GetObjectFromViewState("selectedDept").ToString();
                    }
                    // if was error when adding new receprtion
                    if (!String.IsNullOrEmpty(selectedCode))
                    {
                        //selectedCode = hTblError["selectedDeptCode"].ToString(); 
                        ddlDept.SelectedValue = selectedCode;
                    }

                    DropDownList ddlAgreementType = e.Row.FindControl("ddlAgreementType") as DropDownList;
                    BindDDlAgreementType(ddlDept.SelectedValue, ddlAgreementType, this.dtOriginalData, false);

                    #region DepartItems - Services and Professions
                    UserControls_MultiDDlSelect mDDlDepartItems = e.Row.FindControl("MultiDDlSelect_DepartItems") as UserControls_MultiDDlSelect;
                    HtmlInputText txtRemark = e.Row.FindControl("inpTitleRemark") as HtmlInputText;

                    if (mDDlDepartItems != null)
                    {
                        if (Dept > -1)
                        {
                            //mDDlDepartItems.TextBox.Width = Unit.Parse("130px");
                            //mDDlDepartItems.Panel.Width = Unit.Parse("130px");
                            mDDlDepartItems.Width = "140px";
                            txtRemark.Style.Add("width", "170px");
                            //txtRemark.Width = Unit.Pixel(150);
                        }
                        else
                        {
                            //mDDlDepartItems.TextBox.Width = Unit.Parse("100px");
                            //mDDlDepartItems.Panel.Width = Unit.Parse("100px");
                            mDDlDepartItems.Width = "95px";
                            txtRemark.Style.Add("width", "95px");
                        }
                        mDDlDepartItems.Panel.ScrollBars = ScrollBars.Vertical;


                        if (GetObjectFromViewState("selectedDept") != null)
                        {
                            int hSelectedCode = int.Parse((GetObjectFromViewState("selectedDept").ToString()));
                            BindSelectedDeptItems(hSelectedCode, mDDlDepartItems, this.dtOriginalData);
                        }

                        if (GetObjectFromViewState("selectedDept") == null && GetObjectFromViewState("DeptCodeForReceptionHoursControl_DropDownListSelected") != null)
                        {
                            int hSelectedCode = int.Parse((GetObjectFromViewState("DeptCodeForReceptionHoursControl_DropDownListSelected").ToString()));
                            BindSelectedDeptItems(hSelectedCode, mDDlDepartItems, this.dtOriginalData);
                        }

                        #region ErrorDepartItems
                        if (hTblError != null && hTblError.Count > 0)
                        {
                            if (hTblError["hTblDepartItems"] != null)
                            {
                                ListDictionary hTblDepartItems = (ListDictionary)hTblError["hTblDepartItems"];

                                BindDeptItems(mDDlDepartItems, Convert.ToInt32(selectedCode));

                                BindErrorDeptItems(mDDlDepartItems, hTblDepartItems);
                            }
                        }
                        #endregion
                    }
                    #endregion
                }
            }
        }


        #region ErrorDays

        UserControls_MultiDDlSelectUC multiDDlSelect_Days = e.Row.FindControl("MultiDDlSelect_Days") as UserControls_MultiDDlSelectUC;
        if (multiDDlSelect_Days != null && days != string.Empty)
        {
            MultiDDlSelectUCSelectDays(days, multiDDlSelect_Days);
            //string selectedDays = ReturnDays(days);
            //MultiDDlSelect_Days.TextBox.Text = selectedDays;
            //string[] daysArr = SPLIT_COMMA(selectedDays);            

            //foreach (string day in daysArr)
            //{
            //    MultiDDlSelect_Days.SelectSpesificDate(day);
            //}
        }

        #endregion

        #region ErrorHours

        TextBox txtFromHour = e.Row.FindControl("txtFromHour") as TextBox;
        if (fromHour != string.Empty && txtFromHour != null)
        {
            txtFromHour.Text = fromHour;
        }

        TextBox txtToHour = e.Row.FindControl("txtToHour") as TextBox;
        if (toHour != string.Empty && txtToHour != null)
        {
            txtToHour.Text = toHour;
        }

        #endregion

        #region ErrorRemarks
        if (hTblNewRemark != null)
        {
            string remarkText = hTblNewRemark["remarkText"].ToString();
            if (hdnRemarkText != null)
            {
                hdnRemarkText.Value = remarkText;
            }

            string remarkMask = hTblNewRemark["remarkMask"].ToString();
            if (hdnRemarkMask != null)
            {
                hdnRemarkMask.Value = remarkMask;
            }

            string remarkID = hTblNewRemark["remarkID"].ToString();
            if (hdnRemarkID != null)
            {
                hdnRemarkID.Value = remarkID;
            }
        }
        #endregion

        #region ReceiveGuests

        CheckBox cbReceiveGuests = e.Row.FindControl("cbReceiveGuests") as CheckBox;
        Image imgReceiveGuests = e.Row.FindControl("imgReceiveGuests") as Image;

        if (imgReceiveGuests != null && (!this.ReceptionHoursOfDoctor || !this.HasServicesSubjectToReceiveGuest))
        {
            imgReceiveGuests.Visible = false;
        }

        if (Session["EmployeeReceiveGuests"] != null)
        {
            cbReceiveGuests.Checked = Convert.ToBoolean(Session["EmployeeReceiveGuests"]);

            Session["EmployeeReceiveGuests"] = null;
        }

        if (cbReceiveGuests != null && (!this.ReceptionHoursOfDoctor || !this.HasServicesSubjectToReceiveGuest))
        {
            cbReceiveGuests.Style.Add("display", "none");
        }

        #endregion
    }

    private void BindErrorDeptItems(UserControls_MultiDDlSelect mDDlDepartItems, ListDictionary hTblDepartItems)
    {
        IDictionaryEnumerator enm = hTblDepartItems.GetEnumerator();
        string selectedCodes = string.Empty;

        while (enm.MoveNext())
        {
            selectedCodes += enm.Key.ToString() + ",";
        }

        mDDlDepartItems.SelectItems(selectedCodes);
    }

    private void GetConflictData(ListDictionary hTblError, ref string fromHour, ref string toHour, ref string fromDate, ref string toDate, ref string days, ref ListDictionary hTblNewRemark, ref string selectedDeptCode)
    {
        fromHour = hTblError["fromHour"].ToString();
        toHour = hTblError["toHour"].ToString();
        days = hTblError["selectedDays"].ToString();

        if (hTblError["hTblNewRemark"] != null)
        {
            hTblNewRemark = (ListDictionary)hTblError["hTblNewRemark"];
        }
        if (hTblError["fromDate"] != null)
        {
            fromDate = hTblError["fromDate"].ToString();
        }
        if (hTblError["toDate"] != null)
        {
            toDate = hTblError["toDate"].ToString();
        }
        if (hTblError["selectedDeptCode"] != null)
        {
            selectedDeptCode = hTblError["selectedDeptCode"].ToString();
        }
    }

    //function for custom validation of hours 
    private void SetFromToClientsIdsToHiddenFields(GridViewRow row)
    {
        TextBox txtFromHour = row.FindControl("txtFromHour") as TextBox;
        TextBox txtToHour = row.FindControl("txtToHour") as TextBox;

        if (txtFromHour != null)
        {
            //hdnHeaderFromHourClientID.Value = txtFromHour.ClientID;
        }

        if (txtToHour != null)
        {
            //hdnHeaderToHourClientID.Value = txtToHour.ClientID;
        }

        TextBox txtFromDate = row.FindControl("txtFromDate") as TextBox;
        if (txtFromDate != null)
        {
            //hdnHeaderValidFromClientID.Value = txtFromDate.ClientID;
        }

        TextBox txtToDate = row.FindControl("txtToDate") as TextBox;
        if (txtToDate != null)
        {
            //hdnHeaderValidToClientID.Value = txtToDate.ClientID;
        }
    }

    #region ImageButtonClicks

    protected void imgSave_Click(object sender, EventArgs e)
    {
        try
        {
            GridViewRow row = ((System.Web.UI.WebControls.Button)(sender)).Parent.Parent as GridViewRow;

            if (row != null)
            {
                SaveRow(row);

                //clear indicator for case when to hour less than from hour 
                hdnEnableOverMidnightHours.Value = String.Empty;
            }
        }
        catch (Exception exception)
        {
            sendErrorToEmail("GridReceptionHoursUC.imgSave_Click", exception.ToString());

            redirect(500, exception.Message.ToString());
        }
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
        catch (Exception exception)
        {
            sendErrorToEmail("GridReceptionHoursUC.imgDelete_Click", exception.ToString());

            throw new Exception(exception.Message);
        }
    }

    protected void imgPostBack_Click(object sender, ImageClickEventArgs e)
    {
        try
        {
            if (hdnAgreedToChangeOverlappedHoursExpiration.Value == "1") //confirm
            {
                dtOriginalData = (DataTable)Session["dtWithSaggestedChangesInCaseOfOverlappingInSameClinic"];
            }
            else
            {
                dtOriginalData = (DataTable)Session["backUpCopyBeforeAddOrUpdateRow"]; // decline
            }

            Session["dtWithSaggestedChangesInCaseOfOverlappingInSameClinic"] = null;
            Session["backUpCopyBeforeAddOrUpdateRow"] = null;
            hdnAgreedToChangeOverlappedHoursExpiration.Value = String.Empty;

            dgReceptionHours.EditIndex = -1;
            dgReceptionHours.DataSource = null;

            DataBind();
        }
        catch (Exception exception)
        {
            sendErrorToEmail("GridReceptionHoursUC.imgPostBack_Click", exception.ToString());

            redirect(500, exception.Message.ToString());
        }

    }

    protected void imgAdd_Click(object sender, EventArgs e)
    {
        try
        {
            ViewState["conflictData"] = null;
            DisableImgConflict();

            // Save data source for greedView to restore late in case "user will not agree to change expiration date for overlapping hours"
            DataTable dtOriginalDataCopyBeforeAddOrUpdateRow = this.dtOriginalData.Copy();
            Session["backUpCopyBeforeAddOrUpdateRow"] = dtOriginalDataCopyBeforeAddOrUpdateRow;

            GridViewRow header = dgReceptionHours.HeaderRow;

            if (header != null)
            {
                int[] id_Originals = null;
                int isAdded = AddNewRow(header, false, String.Empty, ref id_Originals);
                if (isAdded == 1) // Row is added OK
                {
                    DisableImgConflict();

                    //clear indicator for case when to hour less than from hour 
                    hdnEnableOverMidnightHours.Value = String.Empty;

                    dgReceptionHours.EditIndex = -1;
                    dgReceptionHours.DataSource = null;
                    DataBind();
                }

                else if (isAdded == 0)// Row is NOT added
                {
                    //this is to save remark of problematic new added row
                    Button btn = sender as Button;
                    InsertRemarkAfterConflict(btn.ClientID);

                    if (id_Originals == null)
                    {
                        string message = "'" + GetLocalResourceObject("message").ToString() + "'";
                        ThrowAlert(message);
                    }
                    else
                    {
                        WarningConflict(id_Originals, true);
                    }
                }
                else
                //isAdded == 2 - it was a conflict over same clinic's hours: add row and then ask. If "Ok" leave it. If not 
                // On client user will be asked : agreed or cancel. If agreed - leave it. If cancel - go to server and restore data to previous state.
                {
                    //ScriptManager.RegisterClientScriptBlock(this, typeof(UpdatePanel), "ConfirmExpirationDate", "ConfirmExpirationDate()", true);
                    ScriptManager.RegisterClientScriptBlock(UpdPanelHours, typeof(UpdatePanel), "ConfirmExpirationDate", "ConfirmExpirationDate()", true);

                    dgReceptionHours.EditIndex = -1;
                    dgReceptionHours.DataSource = null;
                    DataBind();
                }
            }
        }
        catch (Exception exception)
        {
            sendErrorToEmail("GridReceptionHoursUC.imgAdd_Click", exception.ToString());

            redirect(500, exception.Message.ToString());
        }
    }

    private void SetReceiveGuests(bool employeeReceiveGuests)
    {
        GridViewRow header = dgReceptionHours.HeaderRow;
        if (header != null)
        {
            //This is a check:
            // if controls have no values but "txtReceptionRoom" TextBox -
            // this is not "add" action!!
            // THIS action will update ALL txtReceptionRoom TextBoxes with its' value - all will be the same

            DropDownList ddlDept = header.FindControl("ddlDept") as DropDownList;

            if (!string.IsNullOrEmpty(ddlDept.SelectedValue) && ddlDept.SelectedValue != "-1")
            {

                // spread the value
                for (int i = 0; i < dtOriginalData.Rows.Count; i++)
                {
                    if (dtOriginalData.Rows[i]["DeptCode"].ToString() == ddlDept.SelectedValue.ToString())
                    {
                        dtOriginalData.Rows[i]["ReceiveGuests"] = employeeReceiveGuests;
                    }
                }
                //this.dtOriginalData

                dgReceptionHours.EditIndex = -1;
                dgReceptionHours.DataSource = null;

                DataBind();

            }

        }

    }

    protected void btnSpreadRoomNumber_Click(object sender, ImageClickEventArgs e)
    {
        if (Page.IsValid)
        {
            ViewState["conflictData"] = null;
            DisableImgConflict();

            GridViewRow header = dgReceptionHours.HeaderRow;
            if (header != null)
            {
                //This is a check:
                // if controls have no values but "txtReceptionRoom" TextBox -
                // this is not "add" action!!
                // THIS action will update ALL txtReceptionRoom TextBoxes with its' value - all will be the same

                DropDownList ddlDept = header.FindControl("ddlDept") as DropDownList;

                if (!string.IsNullOrEmpty(ddlDept.SelectedValue) && ddlDept.SelectedValue != "-1")
                {
                    DropDownList ddlAgreementType = header.FindControl("ddlAgreementType") as DropDownList;
                    UserControls_MultiDDlSelect mDDlDepartItems = header.FindControl("MultiDDlSelect_DepartItems") as UserControls_MultiDDlSelect;
                    UserControls_MultiDDlSelectUC MultiDDlSelect_Days = header.FindControl("MultiDDlSelect_Days") as UserControls_MultiDDlSelectUC;
                    TextBox txtToDate = header.FindControl("txtToDate") as TextBox;
                    TextBox txtFromDate = header.FindControl("txtFromDate") as TextBox;
                    TextBox txtFromHour = header.FindControl("txtFromHour") as TextBox;
                    TextBox txtToHour = header.FindControl("txtToHour") as TextBox;
                    TextBox txtReceptionRoom = header.FindControl("txtReceptionRoom") as TextBox;
                    if (txtReceptionRoom.Text != string.Empty
                        && (txtToDate.Text == string.Empty &&
                            txtFromHour.Text == string.Empty &&
                            txtToHour.Text == string.Empty &&
                            MultiDDlSelect_Days.SelectedItems.Count < 1)
                        )
                    {
                        // spread the value
                        for (int i = 0; i < dtOriginalData.Rows.Count; i++)
                        {
                            if (dtOriginalData.Rows[i]["DeptCode"].ToString() == ddlDept.SelectedValue.ToString())
                            {
                                dtOriginalData.Rows[i]["ReceptionRoom"] = txtReceptionRoom.Text;
                            }
                        }
                        //this.dtOriginalData

                        dgReceptionHours.EditIndex = -1;
                        dgReceptionHours.DataSource = null;

                        DataBind();
                    }
                }
            }
        }
    }

    protected void imgUpdate_Click(object sender, EventArgs e)
    {
        Button btnUpdate = ((System.Web.UI.WebControls.Button)(sender));

        DataTable dtOriginalDataCopyBeforeAddOrUpdateRow = this.dtOriginalData.Copy();
        Session["backUpCopyBeforeAddOrUpdateRow"] = dtOriginalDataCopyBeforeAddOrUpdateRow;

        if (btnUpdate != null)
        {
            GridViewRow row = btnUpdate.Parent.Parent as GridViewRow;
            if (row != null)
            {
                UpdateRow(row);
            }
        }
    }

    protected void imgClear_Click(object sender, EventArgs e)
    {
        DisableImgConflict();
        ViewState["conflictData"] = null;
        GridViewRow header = dgReceptionHours.HeaderRow;
        if (header != null)
        {
            DropDownList ddlDept = header.FindControl("ddlDept") as DropDownList;
            if (ddlDept != null)
                ddlDept.SelectedIndex = 0;

            UserControls_MultiDDlSelect MultiDDlSelect_DepartItems = header.FindControl("MultiDDlSelect_DepartItems") as UserControls_MultiDDlSelect;
            if (MultiDDlSelect_DepartItems != null)
            {
                MultiDDlSelect_DepartItems.ClearSelection();
            }
            UserControls_MultiDDlSelectUC MultiDDlSelect_Days = header.FindControl("MultiDDlSelect_Days") as UserControls_MultiDDlSelectUC;
            if (MultiDDlSelect_Days != null)
            {
                MultiDDlSelect_Days.ClearFields();
                MultiDDlSelect_Days.TextBox.Text = String.Empty;
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

            HtmlInputText txtRemark = header.FindControl("inpTitleRemark") as HtmlInputText;
            if (txtRemark != null)
                txtRemark.Value = string.Empty;
        }

    }

    #endregion

    private void DisableImgConflict()
    {
        foreach (GridViewRow row in dgReceptionHours.Rows)
        {
            Image imgConflict = row.FindControl("imgConflict") as Image;
            if (imgConflict != null)
            {
                imgConflict.Visible = false;
            }

            if (row.RowState == DataControlRowState.Alternate)
            {
                //row.BackColor = dgReceptionHours.AlternatingRowStyle.BackColor;
                row.Attributes["style"] = "background-color: #FEFEFE";
            }
            else
            {
                //row.BackColor = dgReceptionHours.RowStyle.BackColor;
                row.Attributes["style"] = "background-color: #F3F3F3";
            }
        }

        GridViewRow header = dgReceptionHours.HeaderRow;
        Image imgConflictHeader = header.FindControl("imgConflict") as Image;
        if (imgConflictHeader != null)
        {
            imgConflictHeader.Visible = false;
        }
    }

    private void WarningConflict(int[] id_Originals, bool isAddingNewReception)
    {

        DataTable dtOriginal = this.dtOriginalData;

        //if user tryed to add new reception hours and this is conflict with existed hourc 
        if (isAddingNewReception)
        {
            GridViewRow header = dgReceptionHours.HeaderRow;
            DoImgConflictVisible(header);
        }

        foreach (int x in id_Originals)
        {
            if (dtOriginal != null && dtOriginalData.Rows.Count > 0)
            {
                DataRow[] rows = dtOriginal.Select("ID_Original = '" + x.ToString() + "'");
                if (rows != null && rows.Length > 0)
                {

                    if (ViewState["conflictData"] != null)
                    {
                        ListDictionary hTblError = (ListDictionary)ViewState["conflictData"];
                        if (hTblError != null)
                        {
                            hTblError["Source_ID"] = rows[0]["id_original"].ToString();
                        }
                    }

                    foreach (GridViewRow row in dgReceptionHours.Rows)
                    {
                        SelectRowConflictVisible(row, rows[0]["id_original"].ToString());
                    }


                    #region remark
                    /*
                        DataRow[] rows = dtOriginal.Select("ID_Original = '" + x.ToString() + "'");
                        if (rows != null && rows.Length > 0)
                        {
                            foreach (DataRow dataRowOriginal in rows)
                            {
                                string openHour = dataRowOriginal["openingHour"].ToString();
                                string closingHour = dataRowOriginal["closingHour"].ToString();
                                string validFrom = dataRowOriginal["validFrom"].ToString();
                                string validTo = dataRowOriginal["validTo"].ToString();
                                string itemType = dataRowOriginal["itemType"].ToString();
                                string itemID = dataRowOriginal["itemID"].ToString();

                                if (dtSource != null && dtSource.Rows.Count > 0)
                                {
                                    string filter =
                                        " openingHour = '" + openHour +
                                        "' and closingHour='" + closingHour + "'";

                                    if (validFrom.ToString() != string.Empty)
                                    {
                                        filter += " and ValidFrom ='" + validFrom + "'";

                                        if (validTo.ToString() != string.Empty)
                                        {
                                            filter += " and ValidTo='" + validTo + "'";
                                        }
                                    }

                                    DataRow[] rowsSource = dtSource.Select(filter);
                                    if (rowsSource != null && rowsSource.Length > 0)
                                    {
                                        foreach (DataRow rowSource in rowsSource)
                                        {
                                            string itemsCodes = rowSource["ItemsCodes"].ToString();
                                            string[] codes_Items = SPLIT_COMMA(itemsCodes);


                                            string itemsTypes = rowSource["ItemsTypes"].ToString();
                                            string[] types_Items = SPLIT_COMMA(itemsTypes);

                                            if (codes_Items.Contains(itemID) && types_Items.Contains(itemType))
                                            {
                                                string id = rowSource["ID"].ToString();
                                                if (id != string.Empty)
                                                {
                                                    if (ViewState["conflictData"] != null)
                                                    {
                                                        ListDictionary hTblError = (ListDictionary)ViewState["conflictData"];
                                                        if (hTblError != null)
                                                        {
                                                            hTblError["Source_ID"] = id;
                                                        }
                                                    }

                                                    foreach (GridViewRow row in dgReceptionHours.Rows)
                                                    {
                                                        SelectRowConflictVisible(isAddingNewReception, row, id);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                       
                         */
                    #endregion
                } // if (rows != null && rows.Length > 0)
                else
                {
                    int editedIndx = dgReceptionHours.EditIndex;

                    if (editedIndx > -1)
                    {
                        Label lblID = dgReceptionHours.Rows[editedIndx].FindControl("lblID") as Label;
                        SelectRowConflictVisible(dgReceptionHours.Rows[editedIndx], lblID.Text);
                    }
                }
            }//if (dtOriginal != null
        }//foreach
    }

    private void SelectRowConflictVisible(GridViewRow row, string id)
    {
        Label lblID = row.FindControl("lblID") as Label;

        //this is not new added reception ours 
        if (lblID != null && lblID.Text == id)
        {
            DoImgConflictVisible(row);
        }
    }

    private void ThrowAlert(string message)
    {
        String scriptString = "javascript:alert(" + message + ");";
        UpdatePanel UpdPanelHours = this.FindControl("UpdPanelHours") as UpdatePanel;

        ScriptManager sm = ScriptManager.GetCurrent(Page);
        if (sm != null && UpdPanelHours != null)
        {
            ScriptManager.RegisterClientScriptBlock(UpdPanelHours, typeof(UpdatePanel), "JsAlert_", scriptString, true);
        }
    }

    private void UpdateRow(GridViewRow row)
    {
        int selectedDeptCode = -1;
        string itemsCodes = String.Empty;

        EditingIndex = row.RowIndex;
        dgReceptionHours.EditIndex = row.RowIndex;

        DataBind();


        GridViewRow editingRow = dgReceptionHours.Rows[dgReceptionHours.EditIndex];

        int index = dgReceptionHours.EditIndex;
        DropDownList ddlDeptE = editingRow.FindControl("ddlDeptE") as DropDownList;
        Label lblItemsCodes = editingRow.FindControl("lblItemsCodes") as Label;
        Label lblDays = editingRow.FindControl("lblDays2") as Label;

        TextBox txtFromDate = dgReceptionHours.Rows[index].FindControl("txtFromDate") as TextBox;
        if (txtFromDate != null)
        {
            txtFromDate.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtFromDate.ClientID + "')";
        }

        ImageButton imgDelete = editingRow.FindControl("imgDelete") as ImageButton;
        if (imgDelete != null)
            imgDelete.Visible = false;

        Label lblRemarkText = editingRow.FindControl("lblRemarkText") as Label;
        if (lblRemarkText != null)
        {
            hdnRemarkMask_E.Value = lblRemarkText.Text;
            hdnRemarkText_E.Value = lblRemarkText.Text.Replace("#", ""); ;
        }

        Label lblRemarkID = editingRow.FindControl("lblRemarkID") as Label;
        if (lblRemarkID != null)
            hdnRemarkID_E.Value = lblRemarkID.Text;


        if (lblItemsCodes != null && lblItemsCodes.Text != String.Empty)
        {
            itemsCodes = lblItemsCodes.Text;
        }

        //for validation
        //SetFromToClientsIdsToHiddenFields(editingRow);

        Label lblEnableOverMidnightHours = editingRow.FindControl("lblEnableOverMidnightHours") as Label;
        if (lblEnableOverMidnightHours != null)
        {
            hdnEnableOverMidnightHours.Value = lblEnableOverMidnightHours.Text;
        }


        if (itemsCodes != String.Empty)
        {
            UserControls_MultiDDlSelect ddlProfessions = editingRow.FindControl("MultiDDlSelect_DepartItemsE") as UserControls_MultiDDlSelect;
            HtmlInputText txtRemark = editingRow.FindControl("lblRemarkText_E") as HtmlInputText;
            bool singleDeptMode = (Dept > -1);

            SetEditedRowControlsWidth(singleDeptMode, ddlProfessions, txtRemark);


            #region Get selected dept code
            if (ddlDeptE != null)
            {
                if (CollectionDepts != null && CollectionDepts.Count > 0)
                {
                    BindDDlDept(ddlDeptE, true);
                    Label lblDeptCode = editingRow.FindControl("lblDeptCode") as Label;
                    if (lblDeptCode != null && lblDeptCode.Text != String.Empty)
                    {
                        ddlDeptE.SelectedValue = lblDeptCode.Text;
                    }
                    if (ddlDeptE.Items.Count > 0)
                    {
                        selectedDeptCode = int.Parse(ddlDeptE.SelectedValue);
                    }
                }
            }
            else
            {
                selectedDeptCode = this.Dept;
            }
            #endregion

            if (ddlProfessions != null)
            {
                if (selectedDeptCode > -1)
                {
                    BindDeptItems(ddlProfessions, selectedDeptCode);
                }

                ddlProfessions.SelectItems(itemsCodes);

                //BindSelectedDeptItems(selectedDeptCode, MultiDDlSelect_DepartItemsE, itemsCodes);
            }

            UserControls_MultiDDlSelectUC mltDdlDayE = editingRow.FindControl("mltDdlDayE") as UserControls_MultiDDlSelectUC;
            if (mltDdlDayE != null && !String.IsNullOrEmpty(lblDays.Text))
            {
                MultiDDlSelectUCSelectDays(lblDays.Text, mltDdlDayE);
            }
        }
    }

    private void SetEditedRowControlsWidth(bool singleDeptMode, UserControls_MultiDDlSelect ddlProfessions, HtmlInputText txtRemark)
    {
        if (singleDeptMode)
        {
            ddlProfessions.Width = "140px";
            txtRemark.Style.Add("width", "160px");

        }
        else
        {
            ddlProfessions.Width = "95px";
            txtRemark.Style.Add("width", "92px");
        }
    }

    private void MultiDDlSelectUCSelectDays(string p_days, UserControls_MultiDDlSelectUC mltDdlDay)
    {
        string days = ReturnDays(p_days);
        mltDdlDay.TextBox.Text = days;
        string[] daysArr = SPLIT_COMMA(days);

        foreach (string day in daysArr)
        {
            mltDdlDay.SelectSpesificDate(day);
        }
    }

    private void DeleteRow(GridViewRow row)
    {
        string filter = String.Empty;
        string newId = String.Empty;
        Label lblID = null;

        string deptCode = string.Empty;
        string openingHoure = string.Empty;
        string closingHoure = string.Empty;
        string validFrom = string.Empty;
        string validTo = string.Empty;
        string remarkID = string.Empty;
        string remarkText = string.Empty;
        string day = string.Empty;
        Label lblAdd_ID = null;

        try
        {
            //1.delete from  this.SourceData
            lblID = dgReceptionHours.Rows[row.RowIndex].FindControl("lblID") as Label;
            lblAdd_ID = dgReceptionHours.Rows[row.RowIndex].FindControl("lblAdd_ID") as Label;
            if (lblID != null && lblAdd_ID != null)
            {

                //2. remove from dtOridinalData
                Label lblReceptionIds = dgReceptionHours.Rows[row.RowIndex].FindControl("lblReceptionIds") as Label;
                if (lblReceptionIds != null)
                {
                    //if this is new added row - i haven't reception number 
                    if (lblAdd_ID != null && lblAdd_ID.Text.Trim() != String.Empty)
                    {
                        filter = "Add_ID = '" + lblAdd_ID.Text + "'";
                        RemoveRowFromOriginalData(filter);
                    }
                    else
                    {
                        //if this is existed receptions row - I have number of receptions
                        string id = lblReceptionIds.Text;
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
                    }

                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private DataTable GetItemsMustBeAdded(DataTable originalData, DataTable dtRemainingItems)
    {
        DataTable dtItemsMustBeAdded = null;

        #region Get items that must be added

        var remain = from c in dtRemainingItems.AsEnumerable()
                     select new
                     {
                         ItemID = c.Field<int?>("ItemCode"),
                         ItemType = c.Field<string>("ItemType"),
                         ItemName = c.Field<string>("ItemDesc"),
                         DeptCode = c.Field<string>("DeptCode"),
                         DeptName = c.Field<string>("DeptName"),
                         AgreementType = c.Field<string>("AgreementType")
                     };
        int countRemain = remain.Count();

        var all = from a in originalData.AsEnumerable()
                  where a.Field<int>("deptCode") == this.Dept
                  select new
                  {
                      ItemID = a.Field<int?>("ItemID"),
                      ItemType = a.Field<string>("ItemType"),
                      ItemName = a.Field<string>("ItemDesc"),
                      DeptCode = a.Field<int>("DeptCode").ToString(),
                      //DeptCode = a.Field<string>("DeptCode"),
                      DeptName = a.Field<string>("DeptName"),
                      //AgreementType = a.Field<string>("AgreementType")
                      AgreementType = a.Field<byte>("AgreementType").ToString()
                  };
        int countAll = all.Count();

        var addedItems = remain.Except(all);
        #endregion

        dtItemsMustBeAdded = new DataTable();
        dtItemsMustBeAdded.Columns.Add("ItemCode", Type.GetType("System.Int32"));
        dtItemsMustBeAdded.Columns.Add("ItemDesc");
        dtItemsMustBeAdded.Columns.Add("ItemType");
        dtItemsMustBeAdded.Columns.Add("DeptCode");
        dtItemsMustBeAdded.Columns.Add("DeptName");
        dtItemsMustBeAdded.Columns.Add("AgreementType");

        DataRow drNew = null;
        foreach (var g in addedItems)
        {
            drNew = dtItemsMustBeAdded.NewRow();
            drNew["ItemCode"] = g.ItemID;
            drNew["ItemDesc"] = g.ItemName;
            drNew["ItemType"] = g.ItemType;
            drNew["DeptCode"] = g.DeptCode;
            drNew["DeptName"] = g.DeptName;
            drNew["AgreementType"] = g.AgreementType;
            dtItemsMustBeAdded.Rows.Add(drNew);
        }

        return dtItemsMustBeAdded;

    }

    private DataTable GetItemsMustBeDeleted(DataTable originalData, DataTable dtRemainingItems)
    {
        DataTable dtItemsMustBeDeleted = null;
        try
        {
            #region Get items that must be deleted

            var remain = from c in dtRemainingItems.AsEnumerable()
                         select new
                         {
                             ItemID = c.Field<int?>("ItemCode"),
                             ItemType = c.Field<string>("ItemType"),
                             ItemName = c.Field<string>("ItemDesc")
                         };

            var all = from a in originalData.AsEnumerable()
                      where a.Field<int>("deptCode") == this.Dept
                          && a.Field<int?>("ItemID") != null
                      select new
                      {
                          ItemID = a.Field<int?>("ItemID"),
                          ItemType = a.Field<string>("ItemType"),
                          ItemName = a.Field<string>("ItemDesc")
                      };
            #endregion

            if (all.Count() > 0)
            {
                var deletedItems = all.Except(remain);

                if (deletedItems.Count() > 0)
                {
                    dtItemsMustBeDeleted = new DataTable();
                    dtItemsMustBeDeleted.Columns.Add("ItemCode", Type.GetType("System.Int32"));
                    dtItemsMustBeDeleted.Columns.Add("ItemDesc");
                    dtItemsMustBeDeleted.Columns.Add("ItemType");

                    DataRow drNew = null;
                    foreach (var g in deletedItems)
                    {
                        drNew = dtItemsMustBeDeleted.NewRow();
                        drNew["ItemCode"] = g.ItemID;
                        drNew["ItemDesc"] = g.ItemName;
                        drNew["ItemType"] = g.ItemType;
                        dtItemsMustBeDeleted.Rows.Add(drNew);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
        return dtItemsMustBeDeleted;
    }

    private void UpdateOriginalData(DataTable dtItemsMustBeDeleted, DataTable dtItemsMustBeAdded)
    {
        try
        {
            if (dtItemsMustBeAdded != null && dtItemsMustBeAdded.Rows.Count > 0)
            {
                AddItemsMustBeAddedToOriginalData(this.dtOriginalData, dtItemsMustBeAdded);
            }
            if (dtItemsMustBeDeleted != null && dtItemsMustBeDeleted.Rows.Count > 0)
            {
                RemoveDeletedItemsFromOriginalData(this.dtOriginalData, dtItemsMustBeDeleted);
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void RemoveDeletedItemsFromOriginalData(DataTable originalData, DataTable dtItemsMustBeDeleted)
    {
        foreach (DataRow row in dtItemsMustBeDeleted.Rows)
        {
            string code = row["ItemCode"].ToString();
            string name = row["ItemDesc"].ToString();
            string type = row["ItemType"].ToString();

            DataRow[] originalRows = originalData.Select("ItemID = " + code + " and ItemType = '" + type + "'" + " and deptCode =" + this.Dept.ToString());
            if (originalRows != null && originalRows.Length > 0)
            {
                for (int i = 0; i < originalRows.Length; i++)
                {
                    originalData.Rows.Remove(originalRows[i]);
                }
                this.dtOriginalData = originalData;
            }
        }
    }

    private void AddItemsMustBeAddedToOriginalData(DataTable oridinalData, DataTable dtItemsMustBeAdded)
    {
        try
        {
            DataRow newRow = null;
            foreach (DataRow row in dtItemsMustBeAdded.Rows)
            {
                newRow = oridinalData.NewRow();
                newRow["ItemID"] = row["ItemCode"].ToString();
                newRow["ItemType"] = row["ItemType"].ToString();
                newRow["ItemDesc"] = row["ItemDesc"].ToString();
                newRow["EmployeeID"] = EmployeeID.ToString();
                newRow["deptCode"] = row["deptCode"].ToString();
                newRow["deptName"] = row["deptName"].ToString();
                newRow["AgreementType"] = row["AgreementType"].ToString();

                oridinalData.Rows.Add(newRow);
                oridinalData.AcceptChanges();
            }
            this.dtOriginalData = oridinalData;
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

    private void SaveRow(GridViewRow row)
    {
        //1 for save updated row must to delete updated row and after this to add new row 
        //this process will be in DB too - first DELETE , and after this INSERT
        try
        {
            DisableImgConflict();

            int index = dgReceptionHours.EditIndex;
            DataTable dtCopyOriginalData = this.dtOriginalData.Copy();
            Session["backUpCopyBeforeAddOrUpdateRow"] = dtCopyOriginalData;

            DeleteRow(row);

            Label lblReceptionIds = dgReceptionHours.Rows[index].FindControl("lblReceptionIds") as Label;
            int[] id_Originals = null;
            int isAdded = AddNewRow(row, true, lblReceptionIds.Text, ref id_Originals);

            if (isAdded == 1) // Row is added OK
            {
                dgReceptionHours.EditIndex = -1;
                dgReceptionHours.DataSource = null;
                DataBind();
                DisableImgConflict();
                ViewState["conflictData"] = null;
            }
            else if (isAdded == 0) // Row is NOT added 
            {
                // if new row for any reason didn't  added - do rollback 
                //SetObjectToViewState("GridReceptionHoursData", dtCopySourceData.Copy());
                //this.dtOriginalData = dtCopyOriginalData.Copy();
                //this.SourceData = dtCopySourceData.Copy();
                this.dtOriginalData = dtCopyOriginalData;


                ImageButton btn = row.FindControl("imgSave") as ImageButton;
                InsertRemarkAfterConflictForExistRow(btn.ClientID);

                if (id_Originals == null)
                {
                    string message = "'" + GetLocalResourceObject("message").ToString() + "'";
                    ThrowAlert(message);

                }
                else
                {
                    WarningConflict(id_Originals, false);
                }
            }
            else //isAdded == 2 - it was a conflict over same clinic's hours
            {
                ScriptManager.RegisterClientScriptBlock(this, typeof(UpdatePanel), "ConfirmExpirationDate", "ConfirmExpirationDate()", true);

                dgReceptionHours.EditIndex = -1;
                dgReceptionHours.DataSource = null;
                DataBind();
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }


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

    #region DataTableSelectDistinct
    private static DataTable SelectDistinct(DataTable SourceTable, params string[] FieldNames)
    {
        object[] lastValues;
        DataTable newTable;
        DataRow[] orderedRows;

        if (FieldNames == null || FieldNames.Length == 0)
            throw new ArgumentNullException("FieldNames");

        lastValues = new object[FieldNames.Length];
        newTable = new DataTable();

        foreach (string fieldName in FieldNames)
            newTable.Columns.Add(fieldName, SourceTable.Columns[fieldName].DataType);

        orderedRows = SourceTable.Select("", string.Join(", ", FieldNames));

        foreach (DataRow row in orderedRows)
        {
            if (!fieldValuesAreEqual(lastValues, row, FieldNames))
            {
                newTable.Rows.Add(createRowClone(row, newTable.NewRow(), FieldNames));
                setLastValues(lastValues, row, FieldNames);
            }
        }

        return newTable;
    }

    private static bool fieldValuesAreEqual(object[] lastValues, DataRow currentRow, string[] fieldNames)
    {
        bool areEqual = true;

        for (int i = 0; i < fieldNames.Length; i++)
        {
            if (lastValues[i] == null || !lastValues[i].Equals(currentRow[fieldNames[i]]))
            {
                areEqual = false;
                break;
            }
        }

        return areEqual;
    }

    private static DataRow createRowClone(DataRow sourceRow, DataRow newRow, string[] fieldNames)
    {
        foreach (string field in fieldNames)
            newRow[field] = sourceRow[field];

        return newRow;
    }

    private static void setLastValues(object[] lastValues, DataRow sourceRow, string[] fieldNames)
    {
        for (int i = 0; i < fieldNames.Length; i++)
            lastValues[i] = sourceRow[fieldNames[i]];
    }

    #endregion

    #endregion

    private int AddNewRow(GridViewRow row, bool isEditMode, string receptionIds, ref int[] id_Originals)
    {
        string selectedDeptCode = String.Empty;
        string selectedDeptName = String.Empty;
        string selectedAgreementType = String.Empty;
        string selectedAgreementTypeDescription = String.Empty;
        string deptCityCode = String.Empty;
        string deptCityName = String.Empty;
        string departItems = String.Empty;
        string departItemsCodes = String.Empty;
        string selectedDays = String.Empty;
        string fromHour = String.Empty;
        string toHour = String.Empty;
        string fromDate = String.Empty;
        string toDate = String.Empty;
        ListDictionary dicDepartItems = new ListDictionary();
        ListDictionary dicDepartItemsTypes = new ListDictionary();
        ListDictionary dicNewRemark = new ListDictionary();
        bool resultOriginalData = false;
        ReceptionHoursManager mngr = null;
        DataTable dtCopyOriginal = null;
        DataTable dtToMakeChangesIfOverlappInSameClinic; //CheckIfOverlappInSameClinicAndMakeChanges
        string receptionRoom = String.Empty;
        bool receiveGuests = false;

        //1.get values from header 
        //1a. get values of city code and city name 
        //2. add to grid  
        //3. close Mddl

        //1
        GetNewReceptionValues(ref selectedDeptCode, ref selectedDeptName, ref selectedAgreementType, ref selectedAgreementTypeDescription, ref dicDepartItems, ref dicDepartItemsTypes,
                                ref selectedDays, ref fromHour, ref toHour, ref dicNewRemark, ref fromDate, ref toDate,
                                row, ref receptionRoom, ref receiveGuests, isEditMode);

        if (selectedDeptCode != String.Empty && dicDepartItems != null && dicDepartItemsTypes != null &&
            selectedDays != String.Empty && fromHour != String.Empty && toHour != String.Empty)
        {
            //1a. get values of city code and city name 
            GetCityDetails(selectedDeptCode, ref deptCityCode, ref deptCityName);

            string itemsCodes = String.Empty;
            string itemsNames = String.Empty;
            string itemsTypes = String.Empty;
            GetItems(dicDepartItems, dicDepartItemsTypes, out itemsCodes, out itemsNames, out itemsTypes);

            DataTable dtOriginal = this.dtOriginalData;
            int id = dtOriginal.Rows.Count + 1;
            dtCopyOriginal = dtOriginal.Copy();

            resultOriginalData = AddNewRowToOriginalData(ref dtOriginal, id, this.EmployeeID.ToString(),
                                                    selectedDeptCode, selectedDeptName, selectedAgreementType, selectedAgreementTypeDescription, itemsCodes, itemsNames, itemsTypes,
                                                    deptCityCode, deptCityName, receptionIds, selectedDays, fromHour, toHour,
                                                    fromDate, toDate, receptionRoom, receiveGuests, dicNewRemark["remarkID"].ToString(),
                                                    dicNewRemark["remarkMask"].ToString());

            if (resultOriginalData)
            {
                dtToMakeChangesIfOverlappInSameClinic = dtOriginal.Copy();

                mngr = new ReceptionHoursManager();
                int overlappingFlag = 0;

                if (!this.EnableHoursOverlapp)
                {
                    // Check overlapping in different clinics

                    overlappingFlag = mngr.CheckIfOverlapp(ref dtOriginal, out id_Originals, CurrentUser);
                }

                // flag == 0 - no overlapping 
                if (overlappingFlag == 0)
                {
                    return 1;
                }

                if (overlappingFlag == 2) // overlapping in the same clinic
                {
                    // "CheckIfOverlappInSameClinicAndMakeChanges" removed (commented).  It may be uncommented in future

                    if (!EmployeeIsMedicalTeamOrVirtualDoctor)
                    {
                        if (mngr.CheckIfOverlappInSameClinicAndMakeChanges(ref dtToMakeChangesIfOverlappInSameClinic, out id_Originals, CurrentUser) == 2)
                        {
                            Session["dtWithSaggestedChangesInCaseOfOverlappingInSameClinic"] = dtToMakeChangesIfOverlappInSameClinic.Copy();

                            // case: flag == 2 overlape in same clinic
                            return 2;
                        }

                        return 1; // Row is added withuot problems
                    }
                    else
                    {
                        return 1; // Row is added withuot problems                    
                    }

                    //return 1;
                }
                else if (overlappingFlag == 1) // overlapping against another clinic
                {
                    this.dtOriginalData = dtCopyOriginal.Copy();

                    ListDictionary hTblError = new ListDictionary();
                    hTblError["selectedDeptCode"] = selectedDeptCode;
                    hTblError["selectedDeptName"] = selectedDeptName;
                    hTblError["deptCityCode"] = deptCityCode;
                    hTblError["deptCityName"] = deptCityName;
                    hTblError["selectedDays"] = selectedDays;
                    hTblError["fromHour"] = fromHour;
                    hTblError["toHour"] = toHour;
                    hTblError["fromDate"] = fromDate;
                    hTblError["toDate"] = toDate;
                    hTblError["hTblDepartItems"] = dicDepartItems;
                    hTblError["hTblDepartItemsTypes"] = dicDepartItemsTypes;
                    hTblError["hTblNewRemark"] = dicNewRemark;

                    if (!isEditMode) // if this is new reception - show sign  of warning
                        hTblError["AddNewMode"] = true;

                    ViewState["conflictData"] = hTblError;

                    return 0; // Row NOT added
                }

            }

        }
        return 0; // NOT added
    }

    private DataRow[] CheckNewRowOverlapping(string selectedDeptCode, string selectedDeptName, string deptCityCode,
        string deptCityName, string selectedDays, string fromHour, string toHour, string fromDate, string toDate,
        ListDictionary dicNewRemark, string itemsCodes, string itemsNames, string itemsTypes, DataTable dtData)
    {
        string filter = string.Empty;

        if (itemsCodes != string.Empty)
        {
            filter = "itemsCodes='" + itemsCodes + "'";
        }
        //if (itemsNames != string.Empty)
        //{
        //    if (filter != string.Empty)
        //    {
        //        filter += " and itemsNames='" + itemsNames + "'";
        //    }
        //    else
        //    {
        //        filter += " itemsNames='" + itemsNames + "'";
        //    }
        //}
        if (itemsTypes != string.Empty)
        {
            if (filter != string.Empty)
            {
                filter += " and itemsTypes='" + itemsTypes + "'";
            }
            else
            {
                filter += " itemsTypes='" + itemsNames + "'";
            }
        }
        if (selectedDeptCode != string.Empty)
        {
            if (filter != string.Empty)
            {
                filter += " and DepartCode='" + selectedDeptCode + "'";
            }
            else
            {
                filter += " DepartCode='" + selectedDeptCode + "'";
            }
        }
        //if (selectedDeptName != string.Empty)
        //{
        //    if (filter != string.Empty)
        //    {
        //        filter += " and DepartName='" + selectedDeptName + "'";
        //    }
        //    else
        //    {
        //        filter += "  DepartName='" + selectedDeptName + "'";
        //    }
        //}
        if (selectedDays != string.Empty)
        {
            if (filter != string.Empty)
            {
                filter += " and Days='" + selectedDays + "'";
            }
            else
            {
                filter += " Days='" + selectedDays + "'";
            }
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
        //if (hTblNewRemark["remarkMask"].ToString() != string.Empty)
        //{
        //    if (filter != string.Empty)
        //    {
        //        filter += " and Remark='" + hTblNewRemark["remarkMask"].ToString() + "'";
        //    }
        //    else
        //    {
        //        filter += " and Remark='" + hTblNewRemark["remarkMask"].ToString() + "'";
        //    }
        //}
        //if (hTblNewRemark["remarkID"].ToString()!= string.Empty)
        //{
        //    if (filter != string.Empty)
        //    {
        //        filter += " and RemarkID=" + hTblNewRemark["remarkID"].ToString();
        //    }
        //    else
        //    {
        //        filter += " RemarkID=" + hTblNewRemark["remarkID"].ToString();
        //    }
        //}
        if (fromDate != string.Empty)
        {
            if (filter != string.Empty)
            {
                filter += " and ValidFrom ='" + fromDate + "'";
            }

        }
        if (toDate != string.Empty)
        {
            if (filter != string.Empty)
            {
                filter += " and ValidTo='" + toDate + "'";
            }
        }
        if (deptCityCode != string.Empty)
        {
            if (filter != string.Empty)
            {
                filter += " and DepartCityCode =" + deptCityCode;
            }
        }
        //if (deptCityName != string.Empty)
        //{
        //    if (filter != string.Empty)
        //    {
        //        filter += " and DepartCity='" + deptCityName + "'";
        //    }
        //}

        DataRow[] rows = dtData.Select(filter);
        return rows;
    }

    private void GetItems(ListDictionary dicDepartItems, ListDictionary dicDepartItemsTypes, out string itemsCodes,
                                                                                        out string itemsNames, out string itemsTypes)
    {
        itemsCodes = string.Empty;
        itemsNames = string.Empty;
        itemsTypes = string.Empty;

        IDictionaryEnumerator enumerator = dicDepartItems.GetEnumerator();

        while (enumerator.MoveNext())
        {
            itemsCodes += enumerator.Key.ToString() + ",";
            itemsNames += enumerator.Value.ToString() + ",";
        }
        if (itemsCodes.Length > 0)
            itemsCodes = itemsCodes.Remove(itemsCodes.Length - 1, 1);

        if (itemsNames.Length > 0)
            itemsNames = itemsNames.Remove(itemsNames.Length - 1, 1);

        enumerator = dicDepartItemsTypes.GetEnumerator();
        while (enumerator.MoveNext())
        {
            itemsTypes += enumerator.Value.ToString() + ",";
        }
        if (itemsTypes.Length > 0)
            itemsTypes = itemsTypes.Remove(itemsTypes.Length - 1, 1);
    }

    private void GetCityDetails(string selectedDeptCode, ref string deptCityCode, ref string deptCityName)
    {
        DataRow[] rows = this.dtOriginalData.Select("DeptCode = " + selectedDeptCode);
        if (rows != null && rows.Length > 0)
        {
            deptCityCode = rows[0]["cityCode"].ToString();
            deptCityName = rows[0]["cityName"].ToString();
        }
    }


    private bool AddNewRowToOriginalData(ref DataTable dtOriginalData, int ID_original, string emploeeID,
      string deptCode, string deptName, string agreementType, string agreementTypeDescription, string itemIDs, string itemsNames, string itemsKinds, string cityCode, string cityName,
      string receptionIds, string receptionDays, string openingHour, string closingHour, string validFrom, string validTo, string receptionRoom,
      bool? receiveGuests, string remarkID, string remarkText)
    {

        // Cleen previous "Newly_Added" mark(if existed).
        // New row will be marked as "Newly_Added"

        foreach (DataRow dr in dtOriginalData.Rows)
        {
            dr["Newly_Added"] = 0;
        }

        if (receptionIds != string.Empty)// - for Update
        {
            string[] receptionId = SPLIT_COMMA(receptionIds);
            if (receptionId.Length > 0)
            {
                foreach (string curId in receptionId)
                {
                    if (itemIDs != string.Empty)
                    {
                        return AddNewRowToOriginalData(ref dtOriginalData, deptCode, deptName, agreementType, agreementTypeDescription,
                            itemIDs, itemsNames, itemsKinds, cityCode, cityName, receptionDays,
                            openingHour, closingHour, validFrom, validTo, receptionRoom, receiveGuests, remarkID, remarkText, curId, ID_original);
                    }
                    else
                        return false;
                }
            }
            else
                return false;
        }
        else //this is new row 
        {
            if (itemIDs != string.Empty)
            {
                return AddNewRowToOriginalData(ref dtOriginalData, deptCode, deptName, agreementType, agreementTypeDescription,
                    itemIDs, itemsNames, itemsKinds, cityCode, cityName, receptionDays,
                    openingHour, closingHour, validFrom, validTo, receptionRoom, receiveGuests, remarkID, remarkText, string.Empty, ID_original);
            }
            else
                return false;
        }
        return false;
    }

    private bool AddNewRowToOriginalData(ref DataTable dtOriginalData, string deptCode, string deptName,
                            string agreementType, string agreementTypeDescription,
                            string itemIDs, string itemsNames, string itemsKinds,
                            string cityCode, string cityName, string receptionDays,
                            string openingHour, string closingHour, string validFrom, string validTo,
                            string receptionRoom, bool? receiveGuests,
                            string remarkID, string remarkText, string receptionID, int id)
    {
        string[] itemNums = SPLIT_COMMA(itemIDs);
        string[] itemsTypes = SPLIT_COMMA(itemsKinds);
        string[] itemsNouns = SPLIT_COMMA(itemsNames);

        bool flag = true;

        if (itemNums != null && itemNums.Length > 0)
        {
            for (int itemIDsCount = 0; itemIDsCount < itemNums.Length; itemIDsCount++)
            {
                if (receptionDays != String.Empty)
                {
                    string[] days = SPLIT_COMMA(receptionDays);
                    if (days != null && days.Length > 0)
                    {
                        for (int daysCount = 0; daysCount < days.Length; daysCount++)
                        {
                            string day = days[daysCount].ToString().Replace("_", "");
                            string type = itemsTypes[itemIDsCount].ToString();

                            StringBuilder filter = new StringBuilder();
                            filter.Append(" EmployeeID = '" + this.EmployeeID + "'" +
                                " and receptionDay = '" + day + "'" +
                                " and itemID ='" + itemNums[itemIDsCount].ToString() + "'" +
                                " and ItemType = '" + type + "'");

                            if (!string.IsNullOrEmpty(deptCode))
                            {
                                filter.Append(" and DeptCode='" + deptCode + "'");
                            }

                            if (openingHour != String.Empty)
                                filter.Append(" and openingHour ='" + openingHour + "'");

                            if (closingHour != String.Empty)
                                filter.Append(" and closingHour ='" + closingHour + "'");

                            if (validFrom != String.Empty)
                                filter.Append(" and validFrom ='" + validFrom + "'");

                            if (validTo != String.Empty)
                                filter.Append(" and validTo='" + validTo + "'");

                            DataRow[] rows = dtOriginalData.Select(filter.ToString());
                            if (rows.Length == 0)
                            {
                                DataRow newRow = dtOriginalData.NewRow();

                                newRow["Add_ID"] = LastAddedIndex + 1;
                                LastAddedIndex++;

                                newRow["EmployeeID"] = this.EmployeeID;

                                if (receptionID != string.Empty)
                                    newRow["receptionID"] = receptionID;

                                newRow["deptCode"] = deptCode;
                                newRow["deptName"] = deptName;

                                newRow["AgreementType"] = agreementType;
                                newRow["AgreementTypeDescription"] = agreementTypeDescription;

                                if (cityCode != String.Empty)
                                {
                                    newRow["cityCode"] = cityCode;
                                }
                                newRow["cityName"] = cityName;
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

                                if (receptionRoom != String.Empty)
                                    newRow["receptionRoom"] = receptionRoom;
                                else
                                    newRow["receptionRoom"] = DBNull.Value;

                                if (receiveGuests != null)
                                    newRow["receiveGuests"] = receiveGuests;
                                else
                                    newRow["receiveGuests"] = DBNull.Value;

                                newRow["itemType"] = type;
                                newRow["itemID"] = itemNums[itemIDsCount].ToString();
                                newRow["itemDesc"] = itemsNouns[itemIDsCount].ToString();

                                if (remarkID != String.Empty)
                                    newRow["RemarkID"] = remarkID;
                                else
                                    newRow["RemarkID"] = -1;

                                newRow["RemarkText"] = remarkText;
                                newRow["ID_Original"] = (id + daysCount).ToString();

                                // "newRow["Newly_Added"] = 1" means: in case of conflict between hours the new one will dominate
                                newRow["Newly_Added"] = 1;

                                dtOriginalData.Rows.Add(newRow);
                                // ****** Next lines are commented as to CANCEL PropagateTheRemarkOnAllRowsInConflict 26/06/2021
                                //dtOriginalData.AcceptChanges();

                                //ReceptionHoursManager mngr = new ReceptionHoursManager();
                                //mngr.PropagateTheRemarkOnAllRowsInConflict(ref dtOriginalData, newRow, CurrentUser);

                            }
                            else
                            {
                                flag = false;
                            }
                        }
                    }
                }
            }
        }
        return flag;
    }

    #region Grid events

    protected void dgReceptionHours_RowDeleted(object sender, GridViewDeletedEventArgs e)
    {

    }

    protected void dgReceptionHours_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {

    }

    protected void dgReceptionHours_RowEdit(object sender, GridViewEditEventArgs e)
    {
    }

    protected void CheckAddParams(object sender, ServerValidateEventArgs e)
    {
        GridViewRow row = ((CustomValidator)sender).Parent.Parent as GridViewRow;

        string messageText = string.Empty;

        // chosen dept
        /*if (row.FindControl("ddlDept") != null)
        {
            DropDownList dllDept = row.FindControl("ddlDept") as DropDownList;

            if (ddlDept.SelectedIndex == 0)
            {
                e.IsValid = false;
                messageText = "חובה לבחור יחידה";
                ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);

                return;
            }
        }*/

        // professions
        UserControls_MultiDDlSelect ddlProfessions = row.FindControl("MultiDDlSelect_DepartItems") as UserControls_MultiDDlSelect;
        if (ddlProfessions.SelectedItems == null || ddlProfessions.SelectedItems.Count == 0)
        {
            e.IsValid = false;
            messageText = "חובה לבחור תחום שירות";
            ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);
            return;
        }

        // days
        UserControls_MultiDDlSelectUC ddlDays = row.FindControl("MultiDDlSelect_Days") as UserControls_MultiDDlSelectUC;
        if (ddlDays.SelectedItems == null || ddlDays.SelectedItems.Count == 0)
        {
            e.IsValid = false;

            messageText = "חובה לבחור ימים";
            ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);

            return;
        }

        e.IsValid = true;
    }

    protected void dgReceptionHours_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.Cells.Count > 1)
        {
            e.Row.Cells[1].Visible = IsVisualLabels;
        }

        if (e.Row.RowType == DataControlRowType.Header)
        {
            BuildGridHeader(e, this.dtOriginalData);

            ImageButton btn = e.Row.FindControl("imgSave") as ImageButton;
            if (btn != null) btn.Enabled = false;
        }

        else if (e.Row.RowType == DataControlRowType.DataRow)
        {
            BuildGridRow(e);
            MarkOverlappedHoursRow(e);
        }

        //ImageButton btn = row.FindControl("imgSave") as ImageButton;

    }

    protected void dgReceptionHours_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        dgReceptionHours.EditIndex = -1;

        DataBind();

        DisableImgConflict();
        ViewState["conflictData"] = null;

        //clear indicator for case when to hour less than from hour 
        hdnEnableOverMidnightHours.Value = String.Empty;
    }

    #endregion

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

    bool isEmailValid(string email)
    {
        Regex regex = new Regex(@"^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$");
        Match match = regex.Match(email);
        if (match.Success) return true;
        else return false;
    }

    private void redirect(int errorNumber, string errorMessage)
    {
        string url = Request.Url.AbsoluteUri;

        Session["GridReceptionHoursUCErrorNumber"] = errorNumber.ToString();
        Session["GridReceptionHoursUCErrorMessage"] = errorMessage;

        Response.Redirect(url);
    }
}
