using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using SeferNet.BusinessLayer.ObjectDataSource;

public partial class UserControls_GridTreeView : System.Web.UI.UserControl
{
    private DataTable _dt = null;
    private int _editedRowID = -1;
    private GridViewRow _editedRow = null;
    private string _item = String.Empty;
    private string _editUrl = String.Empty;


    /// <summary>
    /// indicatot that this item hasn't parent or child 
    /// </summary>
    private const string _no_relation_indicator = "999999999";
    private DataView dvSort = null ;

 
    public string Item
    {       
        get
        {          
          object items = ViewState["Items"];
          if (items == null)
             return String.Empty ;   
          else
          {
                _item = items.ToString();
             return _item;
          }
        }
        set {
            _item = value;
            ViewState["Items"] = _item;
        }   
    }

    public string EditUrl
    {
        set { _editUrl = value; }
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

    public GridViewRow EditedRow
    {
        get
        {
            return _editedRow;
        }
        set
        {
            _editedRow = value;
        }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            Session["currentGvDataView"] = null;
           ManageItemsBO mngItems = new ManageItemsBO();
            switch (_item)
            {
                case "professions":                    
                    
                    _dt = mngItems.GetTreeViewProfessions();
                   
                    break;
                case "services":
                    _dt = mngItems.GetTreeViewServices();
                    dgMain.Columns[6].Visible = false;
                    dgMain.Columns[7].Visible = false;
                    break;
            }
            ViewState["dtItems"] = _dt;
            Session["currentGvDataView"] = _dt.DefaultView;
            dgMain.DataSource = _dt;
            dgMain.DataBind();
        }       
    }    




    protected void dgMain_RowCreated(object sender, GridViewRowEventArgs e)
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
            // e.Row.Cells[3].Visible = false;

            LinkButton lnkEdit = e.Row.Cells[8].FindControl("lnkEdit") as LinkButton;
            if (lnkEdit != null)
            {
                lnkEdit.PostBackUrl = _editUrl;
            }
        }
    }
    protected void dgMain_RowDataBound(object sender, GridViewRowEventArgs e)
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
            if (ShowHide.Trim().Length == 0 || e.Row.Cells[9].Text == "1")
            {
                ImageButton Bt_Min = (ImageButton)e.Row.Cells[0].FindControl("btnMinus");
                Bt_Min.Visible = false;
                ImageButton Bt_plus = (ImageButton)e.Row.Cells[0].FindControl("btnPlus");
                Bt_plus.Visible = false;
            }

            if (data[5].ToString() == String.Empty && data[3] != null)
            {
                e.Row.Font.Bold = true;
            }

            //e.Row.Attributes.Add("onmouseover", "this.className ='selectedRow'");
            e.Row.Attributes.Add("onmouseover", "this.style.backgroundColor = '#FEFBB8';");            
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor = '#EFF7FF';");

        }
    }
    protected void dgMain_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "_Show")
        {
            int index = Convert.ToInt32(e.CommandArgument);
           
            GridViewRow row = dgMain.Rows[index];

            int G_Count = GetRelatedRecords(index, row); 

            for (int i = index + 1; i < G_Count; i++)
            {
                if (dgMain.Rows[i].Cells[1].Text == "&nbsp;")
                {
                    dgMain.Rows[i].Visible = true;
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
            //int index = dgMain.SelectedIndex;
            GridViewRow row = dgMain.Rows[index];

            int G_Count = GetRelatedRecords(index, row);           

            for (int i = index + 1; i < G_Count; i++)
            {
                if (dgMain.Rows[i].Cells[1].Text == "&nbsp;")
                {
                    dgMain.Rows[i].Visible = false;
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

    private int GetRelatedRecords(int index, GridViewRow row)
    {
        string code = row.Cells[4].Text;

        if (ViewState["dtItems"] != null)
        {
            _dt = (DataTable)ViewState["dtItems"];
        }

        DataRow[] rows = _dt.Select("GroupByParent = " + code);
        int G_Count = index + rows.Length;
        return G_Count;
    }

    protected void lnkEdit_Click(object sender, EventArgs e)
    {
        try
        {
            LinkButton lnkEdit = sender as LinkButton;
            if (lnkEdit != null)
            {
                Control cell = lnkEdit.Parent;
                GridViewRow row = cell.Parent as GridViewRow;
                int indx = row.RowIndex;
                if (indx > -1)
                {
                    _editedRowID = indx;
                }
                //if I select old service - this GridViewRow hasn't key 
                // so can't  to find this row by key 
                if (row != null)
                    _editedRow = row;                
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }
    protected void dgMain_Sorting(object sender, GridViewSortEventArgs e)
    {
        try
        {
            if (e.SortExpression != hdnSortOrder.Value)
            {
                ViewState["sortDirection"] = null;
                hdnSortOrder.Value = e.SortExpression;
            }

            if (ViewState["sortDirection"] == null)
                ViewState["sortDirection"] = SortDirection.Descending ;
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
            else
                if (e.SortExpression == "Name")
                {
                    if (direction == " ASC")
                        sort = "ParentCodeName asc, ParentCode desc ,Name asc";
                    else
                        sort = "ParentCodeName desc, ParentCode desc ,Name desc";


                }
                    //sort = "isSingle ,ParentCodeName" + direction + ", ParentCode asc," + e.SortExpression + direction;

            dvSort.Sort = sort;

            dgMain.DataSource = dvSort;
            dgMain.PageIndex = 0;
            dgMain.DataBind();
        

        }
        catch (Exception ex )
        {            
            throw new Exception(ex.Message ) ;
        }
    }
}
