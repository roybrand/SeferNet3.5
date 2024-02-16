using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.BusinessObject;
using System.Linq.Expressions;
using System.Linq;
using System.Web.Services;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.Globals;
using System.Collections;

public partial class UserControls_GridUnitTypes : System.Web.UI.UserControl
{
    private DataTable _dt = null;
    private int _editedRowID = -1;
    private int _newCode = -1;
    private string _newIndication = String.Empty;
    private string _newSector = String.Empty;

    private string _newDescription = String.Empty;
    private string _newSubUnitTypes = String.Empty;

    private string _item = String.Empty;
    private bool _allowQueueOrder = false;
    private bool _showInInternet = false;
    private int _defaultSubUnitTypeCode = -1;
    private int _category = 1;

    public event ImageClickEventHandler ImgButtonClicked;
    public delegate void ImageButtonClickEventHandler(object sender, ImageClickEventArgs e);


    #region Properties

    /// <summary>
    /// indicatot that this item hasn't parent or child 
    /// </summary>
    private const string _no_relation_indicator = "999999999";
    private DataView dvSort = null;


    public string Item
    {
        get
        {
            object items = ViewState["Items"];
            if (items == null)
                return String.Empty;
            else
            {
                _item = items.ToString();
                return _item;
            }
        }
        set
        {
            _item = value;
            ViewState["Items"] = _item;
        }
    }

    public DataTable Data
    {
        get
        {
            DataTable dt = (DataTable)ViewState["Data"];
            return dt;
        }
        set
        {
            _dt = value;
            ViewState["Data"] = _dt;
        }
    }

    public int EditedRowID
    {
        get
        {
            return _editedRowID;
        }
        set
        {
            _editedRowID = value;
        }
    }

    #region Add newItem

    public string NewIndication
    {
        get { return _newIndication; }
        set { _newIndication = value; }
    }
    public string NewSector
    {
        get { return _newSector; }
        set { _newSector = value; }
    }

    public int NewCode
    {
        get { return _newCode; }
        set { _newCode = value; }
    }

    public bool AllowQueueOrder
    {
        get { return _allowQueueOrder; }
        set { _allowQueueOrder = value; }
    }

    public bool ShowInInternet
    {
        get { return _showInInternet; }
        set { _showInInternet = value; }
    }

    public int Category
    {
        get
        {
            return _category;
        }
        set
        {
            _category = value;
        }
    }

    public int DefaultSubUnitCode
    {
        get
        {
            return _defaultSubUnitTypeCode;
        }
        set
        {
            _defaultSubUnitTypeCode = value;
        }
    }

    public string NewDescription
    {
        get { return _newDescription; }
        set { _newDescription = value; }
    }

    public string NewSubUnitTypes
    {
        get { return _newSubUnitTypes; }
        set { _newSubUnitTypes = value; }
    }
    #endregion

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ManageItemsBO mngItems = new ManageItemsBO();

        if (!Page.IsPostBack)
        {
            Session["currentGvDataView"] = null;

            BindUnits();

        }

    }

    public void BindUnits()
    {
        ManageItemsBO mngItems = new ManageItemsBO();

        //this.Data = mngItems.GetTreeViewUnitTypes();
        this.Data = mngItems.GetUnitTypes();


        if (this.Data != null)
        {

            Session["dtItems"] = this.Data;
            Session["currentGvDataView"] = this.Data.DefaultView;
            BindData(this.Data);
        }
    }





    #region Save changed item

    


    private void SaveUnitTypes(GridViewRow row)
    {
        int code = -1;
        bool showInInternet = false;
        bool allowQueueOrder = false;
        bool isActive = true;

        string desc = String.Empty;
        string userName = getUserName();

        Label lblCode = row.FindControl("lblCode") as Label;
        if (lblCode != null && lblCode.Text != string.Empty)
            code = int.Parse(lblCode.Text);




        TextBox txtName = row.FindControl("txtName") as TextBox;
        if (txtName != null && txtName.Text != string.Empty)
            desc = txtName.Text;

        CheckBox chkBxShowInInternet = row.FindControl("chkBxShowInInternet") as CheckBox;
        if (chkBxShowInInternet != null)
        {
            showInInternet = chkBxShowInInternet.Checked;
        }

        CheckBox chkBxAllowQueueOrder = row.FindControl("chkBxAllowQueueOrder") as CheckBox;
        if (chkBxAllowQueueOrder != null)
        {
            allowQueueOrder = chkBxAllowQueueOrder.Checked;
        }

        CheckBox chkIsActive = row.FindControl("chkIsActive") as CheckBox;
        if (chkIsActive != null)
        {
            isActive = chkIsActive.Checked;
        }


    }




    #endregion

    #region Grid events



    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            GridViewRow row = e.Row;
            object[] data = ((System.Data.DataRowView)(e.Row.DataItem)).Row.ItemArray;

            CheckBox cb;

            cb = row.FindControl("chkIsActive") as CheckBox;
            if (data[4].ToString() == "True")
            {
                cb.Checked = true;
            }

            cb = row.FindControl("chkBxShowInInternet") as CheckBox;
            if (data[2].ToString() == "True")
            {
                cb.Checked = true;
            }
            cb = row.FindControl("chkBxAllowQueueOrder") as CheckBox;
            if (data[3].ToString() == "True")
            {
                cb.Checked = true;
            }

            string pCode = data[0].ToString();
            string pDescription = data[1].ToString();
            string pInternetDisplay = data[2].ToString();
            string pAllowQueueOrder = data[3].ToString();
            string pActive = data[4].ToString();
            string pDefualtSubUnit = data[5].ToString();
            string pCategory = data[6].ToString();
            string pRelated = data[7].ToString();

            ImageButton ib = row.FindControl("imgUpdate") as ImageButton;
            ib.Attributes.Add("onclick", "setPopupParams('" + pCode + "','" + pDescription + "','" + pInternetDisplay + "','" + pAllowQueueOrder + "','" + pActive + "','" + pDefualtSubUnit + "','" + pCategory + "','" + pRelated + "')");
        }
    }



    #endregion


    private void BindData(Object dt)
    {
        GridView1.DataSource = dt;
        GridView1.DataBind();
    }

    public string getUserName()
    {
        string usernameWithPrefix = new UserManager().GetLoggedinUserNameWithPrefix();

        if (string.IsNullOrEmpty(usernameWithPrefix) == true)
        {
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL);
            Response.End();
        }

        return usernameWithPrefix;
    }




    #region Add new item

    public bool AddNewItem()
    {
        bool result = false;
        try
        {
            ManageItemsBO mngItems = new ManageItemsBO();

            if (CheckInserNewItem())
            {
                AddUnitType();
                this.Data = mngItems.GetTreeViewUnitTypes();
                result = true;
            }
            else
                result = false;

            if (result)
            {
                GridView1.DataSource = null;
                Session["currentGvDataView"] = this.Data.DefaultView;
                //BindData(this.Data.DefaultView);
                BindUnits();
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
        return result;
    }

    private void AddUnitType()
    {
        string userName = getUserName();
        ManageItemsBO bo = new ManageItemsBO();

        if (this.NewCode > -1 && this.NewDescription != string.Empty)
        {
            bo.AddUnitType(this.NewCode, this.NewDescription, this.AllowQueueOrder, this.ShowInInternet, this.DefaultSubUnitCode, userName, this.Category);

            if (this.NewSubUnitTypes != string.Empty)
            {
                string[] arrSubUnitTypes = NewSubUnitTypes.Split(',');
                if (arrSubUnitTypes != null && arrSubUnitTypes.Length > 0)
                {
                    for (int i = 0; i < arrSubUnitTypes.Length; i++)
                    {
                        if (!String.IsNullOrEmpty(arrSubUnitTypes[i].ToString()))
                        {
                            int subUnitTypeCode = int.Parse(arrSubUnitTypes[i].ToString());
                            bo.AddSubUnitTypeCodeToUnitTypeCode(subUnitTypeCode, this.NewCode, userName);
                        }
                    }
                }
            }
        }
    }

    private bool CheckInserNewItem()
    {
        bool result = false;
        int existed = -1;
        try
        {

            var matchesUnitType = from unitType in this.Data.AsEnumerable()
                                  where unitType.Field<int>("UnitTypeCode").Equals(this.NewCode)
                                  select unitType;

            existed = matchesUnitType.Count();

            if (existed <= 0) // if new code doesn't appear in DB  
            {
                //check new inserted name - may by it exists in DB 
                var matchesPositions = from unitType in this.Data.AsEnumerable()
                                       where unitType.Field<string>("UnitTypeName").Equals(this.NewDescription)
                                       select unitType;
                existed = matchesPositions.Count();
                if (existed > 0)
                    return false;
                else
                    result = true;
            }
            else
                result = false;

            return result;
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }


    protected void btnSort_click(object sender, EventArgs e)
    {
        try
        {
            SortableColumnHeader columnToSortBy = sender as SortableColumnHeader;
            string CurrentSort = columnToSortBy.ColumnIdentifier.ToString();

            dvSort = (DataView)Session["currentGvDataView"];

            if (CurrentSort != hdnSortOrder.Value)
            {
                hdnSortOrder.Value = CurrentSort;
            }



            SortDirection newSortDirection = (SortDirection)columnToSortBy.CurrentSortDirection;
            string direction = "Descending";

            if (newSortDirection.ToString() == "Ascending")
            {
                direction = "ASC";
            }
            if (dvSort == null)
                dvSort = Session["currentGvDataView"] as DataView;


            string sort = String.Empty;

            if (CurrentSort == "PositionCode")
            {
                if (direction == "ASC")
                    sort = "UnitTypeCode asc";
                else
                    sort = "UnitTypeCode desc";
            }
            else if (CurrentSort == "ShowInInternet")
            {
                if (direction == "ASC")
                    sort = "ShowInInternet asc";
                else
                    sort = "ShowInInternet desc";
            }
            else if (CurrentSort == "QueueOrder")
            {
                if (direction == "ASC")
                    sort = "AllowQueueOrder asc";
                else
                    sort = "AllowQueueOrder desc";
            }
            else
                if (CurrentSort == "Name")
                {
                    #region Name
                    if (direction == "ASC")
                    {
                        sort = "UnitTypeName asc";
                    }
                    else
                    {
                        sort = "UnitTypeName desc";
                    }
                    #endregion
                }

            dvSort.Sort = sort;
            Session["currentGvDataView"] = dvSort;
            BindData(dvSort);
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    #endregion

    public string Filter
    {
        get
        {
            string resFilter = "";

            if (txtSearchCode.Text != "")
            {
                resFilter = "UnitTypeCode = " + txtSearchCode.Text;
            }
            else
            {
                if (txtDescription.Text != "")
                {
                    resFilter = "UnitTypeName like '%" + txtDescription.Text + "%'";
                }
                if (txtBelong.Text != "")
                {
                    if (resFilter != "")
                    {
                        resFilter += " And Related like '%" + txtBelong.Text + "%'";
                    }
                    else
                    {
                        resFilter = "Related like '%" + txtBelong.Text + "%'";
                    }
                }
                if (txtCategory.Text != "")
                {
                    if (resFilter != "")
                    {
                        resFilter += " And CategoryName like '%" + txtCategory.Text + "%'";
                    }
                    else
                    {
                        resFilter = "CategoryName like '%" + txtCategory.Text + "%'";
                    }
                }
                
                
            }
            
            return resFilter;
        }
    }
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        DataTable currentTable = null;
        DataView currentView = null;
        
        if (Session["currentGvDataView"] != null)
        {
            currentView = Session["currentGvDataView"] as DataView;
            currentTable = Session["dtItems"] as DataTable;
            DataView dv = new DataView(currentTable, this.Filter,
                            currentView.Sort, DataViewRowState.CurrentRows);
            BindData(dv);           
        }
    }

    protected void imgCreateExcelReport_Click(object sender, ImageClickEventArgs e)
    {
        Hashtable WhereParameters = ParamsWhere();
        Session["ParamsWhere"] = WhereParameters;

        Session["CurrentReportName"] = "rprt_UnitTypesExcel";
        Session["CurrentReportTitle"] = "ניהול סוגי יחידות";

        ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "CreateExcelReport", "CreateExcelReport();", true);
        //ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "alert", "alert('after post back');", true);
    }

    public Hashtable ParamsWhere()
    {
        Hashtable paramsWhere = new Hashtable();
        string description, searchCode, belong, category;

        if (txtDescription.Text.Trim() == String.Empty)
        {
            description = "-1";
        }
        else
        {
            description = txtDescription.Text.Trim();
        }

        if (txtSearchCode.Text.Trim() == String.Empty)
        {
            searchCode = "-1";
        }
        else
        {
            searchCode = txtSearchCode.Text.Trim();
        }

        if (txtBelong.Text.Trim() == String.Empty)
        {
            belong = "-1";
        }
        else
        {
            belong = txtBelong.Text.Trim();
        }

        if (txtCategory.Text.Trim() == String.Empty)
        {
            category = "-1";
        }
        else
        {
            category = txtCategory.Text.Trim();
        }

        paramsWhere.Add("Description", description);
        paramsWhere.Add("SearchCode", searchCode);
        paramsWhere.Add("Belong", belong);
        paramsWhere.Add("Category", category);

        return paramsWhere;
    }

}