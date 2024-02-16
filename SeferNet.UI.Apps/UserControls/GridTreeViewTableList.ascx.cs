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

public partial class UserControls_GridTreeViewTableList : System.Web.UI.UserControl
{
    private DataTable _dt = null;
    private int _editedRowID = -1;
    private int _newCode = -1;
    private string _newIndication = String.Empty;
    private string _newSector = String.Empty;

    private string _newDescription = String.Empty;
    

    private string _item = String.Empty;
    private bool _allowQueueOrder = false;
    private bool _showInInternet = false;
    

    
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

    

    public string NewDescription
    {
        get { return _newDescription; }
        set { _newDescription = value; }
    }

    
    #endregion

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ManageItemsBO mngItems = new ManageItemsBO();

        if (!Page.IsPostBack)
        {
            Session["currentGvDataView"] = null;

            DataBind();

        }
        
    }

    public void DataBind()
    {
        ManageItemsBO mngItems = new ManageItemsBO();

        switch (_item)
        {
            case "positions":
                this.Data = mngItems.GetTreeViewPositions();
                GridView1.Columns[0].Visible = false;
                GridView1.Columns[8].Visible = true;
                GridView1.Columns[8].HeaderText = "האם להציג";
                GridView1.Columns[9].Visible = false;
                GridView1.Columns[11].Visible = true;
                break;
            case "languages":
                this.Data = mngItems.GetTreeViewLanguages();
                GridView1.Columns[0].Visible = false;
                GridView1.Columns[1].Visible = false;
                GridView1.Columns[2].Visible = false;
                GridView1.Columns[3].Visible = false;
                GridView1.Columns[4].Visible = false;
                GridView1.Columns[5].Visible = true;
                GridView1.Columns[6].Visible = false;
                GridView1.Columns[8].Visible = true;
                GridView1.Columns[7].HeaderText = "תאור";
                GridView1.Columns[8].HeaderText = "האם להציג";
                GridView1.Columns[9].Visible = false;
                GridView1.Columns[10].Visible = false;
                break;
            case "handicappedFacilities":
                this.Data = mngItems.GetTreeViewhandicappedFacilities();
                GridView1.Columns[0].Visible = false;//אב
                GridView1.Columns[7].Visible = false;
                GridView1.Columns[8].HeaderText = "פעיל";
                //GridView1.Columns[8].Visible = false;here it will be Active
                GridView1.Columns[9].Visible = false;
                GridView1.Columns[10].Visible = false;
                break;
            
        }

        if (this.Data != null)
        {
            ViewState["dtItems"] = this.Data;
            Session["currentGvDataView"] = this.Data.DefaultView;
            BindData(this.Data);
        }
    }



    #region Save changed item

    private void SaveRow(GridViewRow row)
    {
        try
        {
            Session["currentGvDataView"] = null;
            ManageItemsBO mngItems = new ManageItemsBO();

            switch (this.Item)
            {
                case "positions":
                    SavePosition(row);
                    this.Data = mngItems.GetTreeViewPositions();
                    break;
                case "handicappedFacilities":
                    SaveHandicappedFacilities(row);
                    this.Data = mngItems.GetTreeViewhandicappedFacilities();
                    break;
                
                case "languages":
                    SaveLanguages(row);
                    this.Data = mngItems.GetTreeViewLanguages();
                    break;
                //case "Events":
                  //  SaveEvents(row);
                    //this.Data = mngItems.GetTreeViewEvents();
                    //break;
            }

            ViewState["dtItems"] = this.Data;
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    //private void SaveEvents(GridViewRow row)
    //{
    //    string eventText = ((TextBox)row.FindControl("txtName")).Text;
    //    bool isActive = ((CheckBox)row.FindControl("chkBxShowInInternet")).Checked;
    //    int eventCode = Convert.ToInt32(((Label)row.FindControl("lblCode")).Text);

    //    ManageConversationsBO bo = new ManageConversationsBO();
    //    bo.UpdateEvent(eventCode, eventText, isActive, getUserName());
    //}

    private void SaveLanguages(GridViewRow row)
    {
        try
        {
            int code = -1;
            int showInInternet = 0;
            string desc = String.Empty;
            string userName = getUserName();
            ManageItemsBO mng = new ManageItemsBO();

            Label lblCode = row.FindControl("lblCode") as Label;
            if (lblCode != null && lblCode.Text != string.Empty)
                code = int.Parse(lblCode.Text);

            CheckBox chkBxShowInInternet = row.FindControl("chkBxShowInInternet") as CheckBox;
            if (chkBxShowInInternet != null)
            {
                if (chkBxShowInInternet.Checked)
                {
                    showInInternet = 1;
                }
            }
            if (code != -1)
            {
                mng.UpdateLanguages(code, showInInternet, userName);
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    

    private void SaveHandicappedFacilities(GridViewRow row)
    {
        try
        {
            int code = -1;
            string desc = String.Empty;
            bool active = false;         

            Label lblCode = row.FindControl("lblCode") as Label;
            if (lblCode != null && lblCode.Text != string.Empty)
                code = int.Parse(lblCode.Text);

            TextBox txtName = row.FindControl("txtName") as TextBox;
            if (txtName != null && txtName.Text != string.Empty)
                desc = txtName.Text;

            CheckBox chkBxShowInInternet = row.FindControl("chkBxShowInInternet") as CheckBox;
            if (chkBxShowInInternet != null)
            {
                active = chkBxShowInInternet.Checked;
            }

            if (code != -1 && desc != string.Empty)
            {
                ManageItemsBO bo = new ManageItemsBO();
                bo.UpdateHandicappedFacility(code, desc, active);
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void SaveSortingAfterUpdate(DataTable dt)
    {
        string sorting = String.Empty;
        this.Data = dt;
        DataView dvUpdated = dt.DefaultView;
        DataView dvPrevious = (DataView)Session["currentGvDataView"];
        if (dvPrevious != null)
            sorting = dvPrevious.Sort;
        if (sorting != string.Empty)
        {
            dvUpdated.Sort = sorting;
        }
        Session["currentGvDataView"] = dvUpdated;
    }

    private void SavePosition(GridViewRow row)
    {
        try
        {
            int code = -1;
            string desc = String.Empty;
            int gender = -1;
            int sector = -1;
            bool showInSearches = false;
            bool isActive = true;


            Label lblCode = row.FindControl("lblCode") as Label;
            if (lblCode != null && lblCode.Text != string.Empty)
                code = int.Parse(lblCode.Text);

            Label lblSex = row.FindControl("lblSex") as Label;
            if (lblSex != null && lblSex.Text != string.Empty)
                gender = int.Parse(lblSex.Text);

            TextBox txtName = row.FindControl("txtName") as TextBox;
            if (txtName != null && txtName.Text != string.Empty)
                desc = txtName.Text;

            DropDownList ddlSector = row.FindControl("ddlSector") as DropDownList;
            if (ddlSector != null && ddlSector.SelectedValue != string.Empty)
                sector = int.Parse(ddlSector.SelectedValue);

            CheckBox chkBxShowInInternet = row.FindControl("chkBxShowInInternet") as CheckBox;
            if (chkBxShowInInternet != null)
            {
                showInSearches = chkBxShowInInternet.Checked;
            }

            CheckBox chkIsActive = row.FindControl("chkIsActive") as CheckBox;
            if (chkIsActive != null)
            {
                isActive = chkIsActive.Checked;
            }

            if (code != -1 && desc != string.Empty && gender > -1)
            {
                ManageItemsBO bo = new ManageItemsBO();
                bo.UpdatePosition(code, desc, gender, getUserName(), sector, showInSearches, isActive);
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }


    #endregion

    #region Grid events

    protected void GridView1_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
        }

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
            ImageButton MinButton = (ImageButton)e.Row.Cells[0].FindControl("btnMinus");
            MinButton.CommandArgument = e.Row.RowIndex.ToString();
            ImageButton addButton = (ImageButton)e.Row.Cells[0].FindControl("btnPlus");
            addButton.CommandArgument = e.Row.RowIndex.ToString();

            if (e.Row.DataItem != null)
            {
                object[] data = ((System.Data.DataRowView)(e.Row.DataItem)).Row.ItemArray;
                if (data != null && data[5].ToString().Trim() == string.Empty && data.Length > 8 && data[7].ToString().Trim() != string.Empty)
                {
                    CheckBox chkBxAllowQueueOrder = e.Row.FindControl("chkBxAllowQueueOrder") as CheckBox;
                    if (chkBxAllowQueueOrder != null)
                    {
                        chkBxAllowQueueOrder.Visible = false;
                    }

                    CheckBox chkBxShowInInternet = e.Row.FindControl("chkBxShowInInternet") as CheckBox;
                    if (chkBxShowInInternet != null)
                    {
                        chkBxShowInInternet.Visible = false;
                    }
                }
            }
        }
    }

    protected void GridView1_Editing(object sender, GridViewEditEventArgs e)
    {
        
    }
    protected void GridView1_Updating(object sender, GridViewUpdateEventArgs e)
    {

    }

    private void CancelEditedRow()
    {
        GridView1.EditIndex = -1;
        BindData(this.Data);
    }

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            object[] data = ((System.Data.DataRowView)(e.Row.DataItem)).Row.ItemArray;
            // if i have  Row.Cells[1].Text != String.Empty 
            // so I have parentID 
            // if e.Row.Cells[1].Text.Length == 0
            // this is child - do buttons invisible - false
            string ShowHide = e.Row.Cells[1].Text;
            ShowHide = ShowHide.Replace("&nbsp;", "");

            if ((data[2] != null && data[2].ToString() == "1") || (data[5] == null || data[5].ToString() == String.Empty))
            {
                ImageButton Bt_Min = (ImageButton)e.Row.Cells[0].FindControl("btnMinus");
                if (Bt_Min != null)
                {
                    Bt_Min.Visible = false;
                }

                ImageButton Bt_plus = (ImageButton)e.Row.Cells[0].FindControl("btnPlus");
                if (Bt_plus != null)
                {
                    Bt_plus.Visible = false;
                }
            }

            else
            {
                ImageButton Bt_Min = (ImageButton)e.Row.Cells[0].FindControl("btnMinus");
                if (Bt_Min != null)
                {
                    Bt_Min.Visible = true;
                }
            }

            if (data[5].ToString() == String.Empty && data[3] != null)
            {
                e.Row.Font.Bold = true;
            }

            e.Row.Attributes.Add("onmouseover", "this.style.backgroundColor = '#FEFBB8';");
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor = '#EFF7FF';");

            // data[5] - group by parent 
            //data[12] - isSingle
            //font bold for alongs is false 
            if (data[5].ToString() == String.Empty && data.Length > 12 && data[12].ToString() == "1")
            {
                Label lblName = e.Row.FindControl("lblName") as Label;
                if (lblName != null)
                {
                    lblName.Style.Add("font-weight", " normal !important");
                }
            }

            ImageButton imgDelete = (ImageButton)e.Row.Cells[0].FindControl("imgDelete");
            

            if (this.Item == "handicappedFacilities" || this.Item == "languages" ||  this.Item == "positions")
            {
                if (this.Item == "handicappedFacilities" || this.Item == "languages")
                {
                    if (imgDelete != null)
                    {
                        imgDelete.Visible = false;
                    }
                }

                #region ShowInInternet
                CheckBox chkBxShowInInternet = e.Row.FindControl("chkBxShowInInternet") as CheckBox;
                if (chkBxShowInInternet != null)
                {
                    if (this.Item == "positions")
                    {
                        chkBxShowInInternet.Visible = true;
                        if (data[8] != null && data[8].ToString().Trim() != string.Empty)
                        {
                            if (data[8].ToString() == "1" || data[8].ToString().ToUpper() == "TRUE")
                                chkBxShowInInternet.Checked = true;
                        }
                        else
                            chkBxShowInInternet.Checked = false;

                        
                    }
                    else //this.Item == "handicappedFacilities" || this.Item == "languages"
                    {
                        //if (this.Item == "Events")
                        //{
                        //    if (imgDelete != null)
                        //    {
                        //        imgDelete.Visible = false;
                        //    }

                        //    if (data[2] != null && data[2].ToString().Trim() != string.Empty)
                        //    {
                        //        chkBxShowInInternet.Checked = Convert.ToBoolean(data[2].ToString());
                        //    }
                        //}
                        //else
                        //{
                            if (data[8] != null && data[8].ToString().Trim() != string.Empty)
                                chkBxShowInInternet.Checked = Convert.ToBoolean(int.Parse(data[8].ToString()));
                            else
                                chkBxShowInInternet.Checked = false;
                        //}
                    }
                }
                #endregion

                #region IsActive
                if (this.Item == "positions")
                {
                    int numOfColumn = 9;

                    

                    CheckBox chkActive = e.Row.FindControl("chkIsActive") as CheckBox;
                    chkActive.Visible = true;
                    if (data[numOfColumn] != null && Convert.ToBoolean(data[numOfColumn]))
                    {
                        chkActive.Checked = true;
                    }
                    else
                    {
                        chkActive.Checked = false;
                    }
                }
                #endregion

                #region AllowQueueOrder
                CheckBox chkBxAllowQueueOrder = e.Row.FindControl("chkBxAllowQueueOrder") as CheckBox;
                if (chkBxAllowQueueOrder != null)
                {
                    if (data[9] != null && data[9].ToString().Trim() != string.Empty)
                    {
                        if (Convert.ToBoolean(data[9]))
                        {
                            chkBxAllowQueueOrder.Checked = true;
                        }
                    }
                    else
                        chkBxAllowQueueOrder.Checked = false;
                }
                #endregion
            }
            else if (imgDelete != null)
            {
                imgDelete.Visible = false;
            }

            

        }
    }

    

    

    protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "_Show")
        {
            int index = Convert.ToInt32(e.CommandArgument);

            GridViewRow row = GridView1.Rows[index];

            int G_Count = GetRelatedRecords(index, row);

            for (int i = index + 1; i < G_Count; i++)
            {
                if (GridView1.Rows[i].Cells[1].Text == "")
                {
                    GridView1.Rows[i].Visible = true;
                }
                else
                {
                    ImageButton Bt_Min = (ImageButton)row.Cells[0].FindControl("btnMinus");
                    Bt_Min.Visible = true;
                    ImageButton Bt_plus = (ImageButton)row.Cells[0].FindControl("btnPlus");
                    Bt_plus.Visible = false;
                    break;
                }
                ImageButton Bt_Min1 = (ImageButton)row.Cells[0].FindControl("btnMinus");
                Bt_Min1.Visible = true;
                ImageButton Bt_plus1 = (ImageButton)row.Cells[0].FindControl("btnPlus");
                Bt_plus1.Visible = false;
            }
        }

        if (e.CommandName == "_Hide")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            //int index = GridView1.SelectedIndex;
            GridViewRow row = GridView1.Rows[index];

            int G_Count = GetRelatedRecords(index, row);

            for (int i = index + 1; i < G_Count; i++)
            {
                if (GridView1.Rows[i].Cells[1].Text == "")
                {
                    GridView1.Rows[i].Visible = false;
                }
                else
                {
                    ImageButton Bt_Min = (ImageButton)row.Cells[0].FindControl("btnMinus");
                    Bt_Min.Visible = false;
                    ImageButton Bt_plus = (ImageButton)row.Cells[0].FindControl("btnPlus");
                    Bt_plus.Visible = true;
                    break;
                }
                ImageButton Bt_Min1 = (ImageButton)row.Cells[0].FindControl("btnMinus");
                Bt_Min1.Visible = false;
                ImageButton Bt_plus1 = (ImageButton)row.Cells[0].FindControl("btnPlus");
                Bt_plus1.Visible = true;
            }
        }
    }

    protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
    {
        try
        {
            dvSort = (DataView)Session["currentGvDataView"];

            if (e.SortExpression != hdnSortOrder.Value)
            {
                ViewState["sortDirection"] = null;
                hdnSortOrder.Value = e.SortExpression;
            }

            if (ViewState["sortDirection"] == null)
                ViewState["sortDirection"] = SortDirection.Descending;
            SortDirection oldSortDirection = (SortDirection)ViewState["sortDirection"];
            SortDirection newSortDirection = SortDirection.Descending;

            if (dvSort == null)
                dvSort = Session["currentGvDataView"] as DataView;

            string direction = string.Empty;
            switch (oldSortDirection)
            {
                case SortDirection.Ascending:
                    direction = " DESC";
                    newSortDirection = SortDirection.Descending;
                    break;
                case SortDirection.Descending:
                    direction = " ASC";
                    newSortDirection = SortDirection.Ascending;
                    break;
            }
            ViewState["sortDirection"] = newSortDirection;

            string sort = String.Empty;

            if (e.SortExpression == "Root")
            {
                if (direction == " ASC")
                    sort = "isSingle ,GroupByParent asc, ParentCode desc ,Code asc";
                else
                    sort = "isSingle ,GroupByParent desc, ParentCode desc ,Code desc";
            }

            else if (e.SortExpression == "Code")
            {
                if (direction == " ASC")
                    sort = "GroupByParent asc, ParentCode desc ,Code asc";
                else
                    sort = "GroupByParent desc, ParentCode desc ,Code desc";
            }
            else if (e.SortExpression == "ShowInInternet")
            {
                if (direction == " ASC")
                    sort = "ShowInInternet asc";
                else
                    sort = "ShowInInternet desc";
            }
            else if (e.SortExpression == "AllowQueueOrder")
            {
                if (direction == " ASC")
                    sort = "AllowQueueOrder asc";
                else
                    sort = "AllowQueueOrder desc";
            }
            else if (e.SortExpression == "Gender")
            {
                if (direction == " ASC")
                    sort = "Gender asc";
                else
                    sort = "Gender desc";
            }
            else if (e.SortExpression == "sectorDescription")
            {
                if (direction == " ASC")
                    sort = "sectorDescription asc";
                else
                    sort = "sectorDescription desc";
            }
            else
                if (e.SortExpression == "Name")
                {
                    #region Name
                    if (direction == " ASC")
                    {
                        if (this.Data.Columns.Contains("ParentCodeName"))
                        {
                            sort = "ParentCodeName asc, ParentCode desc ,Name asc";
                        }
                        else
                        {
                            sort = " Name asc";
                        }
                    }
                    else
                    {
                        if (this.Data.Columns.Contains("ParentCodeName"))
                        {
                            sort = "ParentCodeName desc, ParentCode desc ,Name desc";
                        }
                        else
                        {
                            sort = " Name desc";
                        }
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

    private int GetRelatedRecords(int index, GridViewRow row)
    {
        string code = String.Empty; //row.Cells[1].Text;


        Label lblCode = row.FindControl("lblCode") as Label;
        if (lblCode != null && lblCode.Text != string.Empty)
            code = lblCode.Text;

        if (ViewState["dtItems"] != null)
        {
            _dt = (DataTable)ViewState["dtItems"];
        }

        DataRow[] rows = _dt.Select("GroupByParent = " + code);
        int G_Count = index + rows.Length;
        return G_Count;
    }

    #endregion

    protected void lnkEdit_Click(object sender, EventArgs e)
    {
        try
        {
            LinkButton lnkEdit = sender as LinkButton;
            if (lnkEdit != null)
            {
                Control cell = lnkEdit.Parent;
                GridViewRow row = cell.Parent as GridViewRow;
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    #region image events
    protected void imgCancel_Click(object sender, ImageClickEventArgs e)
    {
        try
        {
            CancelEditedRow();
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        if (row != null)
        {
            GridView1.EditIndex = row.RowIndex;
            DataView dv = (DataView)Session["currentGvDataView"];
            BindData(dv);
            UpdateRow(row);
        }
    }

    
    

    protected void imgSave_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;

        ClickOnSave(row);
    }

    private void ClickOnSave(GridViewRow row)
    {
        if (row != null)
        {
            SaveRow(row);
            SaveSortingAfterUpdate(this.Data);

            GridView1.EditIndex = -1;
            GridView1.DataSource = null;
            DataView dv = this.Data.DefaultView;
            BindData(dv);
        }
    }

    #endregion

    private void UpdateRow(GridViewRow row)
    {
        string sector = String.Empty;
        int indx = row.RowIndex;
        if (this.Item == "positions")
        {
            Label lblSectorID = row.FindControl("lblSectorID") as Label;
            if (lblSectorID != null)
            {
                ViewState["selectedSector"] = lblSectorID.Text;
            }
        }



        if (this.Item == "languages")
        {
            Label lblSectorID = row.FindControl("lblSectorID") as Label;
            if (lblSectorID != null)
            {
                ViewState["selectedSector"] = lblSectorID.Text;
            }
        }

        
    }

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

    protected void ddlSector_PreRender(object sender, EventArgs e)
    {
        if (ViewState["selectedSector"] != null)
        {
            DropDownList ddlSector = sender as DropDownList;
            if (ddlSector != null)
            {
                ddlSector.SelectedValue = ViewState["selectedSector"].ToString();
            }
        }
    }


    #region Add new item

    public bool AddNewItem()
    {
        bool result = false;
        try
        {
            ManageItemsBO mngItems = new ManageItemsBO();

            switch (this.Item)
            {
                case "positions":
                    if (CheckInserNewItem("positions"))
                    {
                        AddPosition();
                        this.Data = mngItems.GetTreeViewPositions();
                        result = true;
                    }
                    else
                        result = false;
                    break;
                
                case "handicappedFacilities":
                    if (CheckInserNewItem("handicappedFacilities"))
                    {
                        AddHandicappedFacility();
                        this.Data = mngItems.GetTreeViewhandicappedFacilities();
                        result = true;
                    }
                    else
                        result = false;
                    break;
            }

            if (result)
            {
                GridView1.DataSource = null;
                Session["currentGvDataView"] = this.Data.DefaultView;
                BindData(this.Data.DefaultView);
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
        return result;
    }

    

    private bool CheckInserNewItem(string newItem)
    {
        bool result = false;
        int existed = -1;
        try
        {

            switch (newItem)
            {
                case "positions":
                    // test that new code doesn't appear in DB  
                    var matchesPositions = from position in this.Data.AsEnumerable()
                                           where position.Field<int>("Code").Equals(this.NewCode) && position.Field<string>("Gender").Equals(this.NewIndication)
                                           select position;

                    existed = matchesPositions.Count();

                    if (existed <= 0) // if new code doesn't appear in DB  
                    {
                        //check new inserted name - may by it exists in DB 
                        matchesPositions = from position in this.Data.AsEnumerable()
                                           where position.Field<string>("Name").Equals(this.NewDescription)
                                           select position;
                        existed = matchesPositions.Count();
                        if (existed > 0)
                            return false;
                        else
                            result = true;
                    }
                    else
                        result = false;
                    break;
                case "handicappedFacilities":
                    // test that new code doesn't appear in DB  
                    var matchesHandicappedFacilities = from handicappedFacility in this.Data.AsEnumerable()
                                                       where handicappedFacility.Field<int>("Code").Equals(this.NewCode)
                                                       select handicappedFacility;

                    existed = matchesHandicappedFacilities.Count();

                    if (existed <= 0) // if new code doesn't appear in DB  
                    {
                        //check new inserted name - may by it exists in DB 
                        matchesHandicappedFacilities = from handicappedFacility in this.Data.AsEnumerable()
                                                       where handicappedFacility.Field<string>("Name").Equals(this.NewDescription)
                                                       select handicappedFacility;
                        existed = matchesHandicappedFacilities.Count();
                        if (existed > 0)
                            return false;
                        else
                            result = true;
                    }
                    else
                        result = false;
                    break;
                

            }

            return result;
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void AddPosition()
    {

        int gender = -1;

        if (this.NewCode > -1 && this.NewDescription != string.Empty && this.NewIndication != string.Empty && this.NewSector != string.Empty)
        {
            if (this.NewIndication == "זכר")
                gender = 1;
            else
                gender = 2;

            ManageItemsBO bo = new ManageItemsBO();
            bo.AddPosition(this.NewCode, gender, this.NewDescription, getUserName(), int.Parse(this.NewSector));
        }

    }

    private void AddHandicappedFacility()
    {
        try
        {
            int active = -1;

            if (this.NewCode > -1 && this.NewDescription != string.Empty)
            {
                if (this.NewIndication == "פעיל")
                    active = 1;
                else
                    active = 0;

                ManageItemsBO bo = new ManageItemsBO();
                bo.AddHandicappedFacility(this.NewCode, this.NewDescription, active);
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    #endregion
}
