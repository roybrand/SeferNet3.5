using System;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using System.Data;
using SeferNet.BusinessLayer.ObjectDataSource;

public partial class Admin_UpdateMushlamProfessionsMapping : System.Web.UI.Page
{

    private DataTable _dataSource 
    {
        get
        {
            if (ViewState["DataSource"] != null)
            {
                return (DataTable)ViewState["DataSource"];
            }
            return null;
        }
        set
        {
            ViewState["DataSource"] = value;
        }
    }

    private string _currentSort 
    { 
        get
        {
            if (ViewState["currentSort"] != null)
                return ViewState["currentSort"].ToString();
            else
                return string.Empty;                   
        }
        set
        {
            ViewState["currentSort"] = value;
        }
    }



    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            bindTablesName();
            bindTreatmentTypes();
        }
        else
        {
            if (hdnMappingType.Value != "")
            {
                mapMushlamToSefer();
            }
                

            if (!string.IsNullOrEmpty(hdnScroll.Value))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "scroll",
                                            "document.getElementById('divServices').scrollTop = " + hdnScroll.Value + ";", true);
            }
        }
    }

    
        

    private void mapMushlamToSefer()
    {
        int tableCode = Convert.ToInt32(hdnTableCode.Value);
        int? mushlamServiceCode = null;
        int seferServiceCode;
        int? parentCode = null;
        int? groupCode = null;
        int? subGroupCode = null;
        

        seferServiceCode = Convert.ToInt32(hdnServiceCode.Value);
        
        if(!string.IsNullOrEmpty(hdnMushlamServiceCode.Value))
            mushlamServiceCode = Convert.ToInt32(hdnMushlamServiceCode.Value);

        if (!string.IsNullOrEmpty(hdnNewMushlamParentCode.Value))
            parentCode = Convert.ToInt32(hdnNewMushlamParentCode.Value);

        if (!string.IsNullOrEmpty(hdnNewGroupCode.Value))
            groupCode = Convert.ToInt32(hdnNewGroupCode.Value);

        if (!string.IsNullOrEmpty(hdnNewSubGroupCode.Value))
            subGroupCode = Convert.ToInt32(hdnNewSubGroupCode.Value);

        if (hdnMappingType.Value == "add")
            Facade.getFacadeObject().InsertMushlamToSeferMapping(tableCode, mushlamServiceCode, seferServiceCode,
                parentCode, groupCode, subGroupCode);
        else
        {
            int mappingID = Convert.ToInt32(hdnID.Value);
            Facade.getFacadeObject().UpdateMushlamToSeferMapping(tableCode, mappingID, mushlamServiceCode, seferServiceCode,
                parentCode, groupCode, subGroupCode);
        }

        if(_dataSource != null)
            BindGridView();
        
    }

    

    private void BindGridView()
    {
        string seferServiceName = txtSeferServiceName.Text == "" ? null:txtSeferServiceName.Text;
        string mushlamServiceName = txtMushlamServiceName.Text == "" ? null : txtMushlamServiceName.Text;
        int? tableCode = null;
        if (ddlSearchTableNumber.SelectedValue != "-1")
            tableCode = Convert.ToInt32(ddlSearchTableNumber.SelectedValue);

        _dataSource = Facade.getFacadeObject().GetMushlamConnectionTables(tableCode, seferServiceName, mushlamServiceName).Tables[0];

        _dataSource.DefaultView.Sort = _currentSort;

        gvProfessions.DataSource = _dataSource.DefaultView;
        gvProfessions.DataBind();

        tblRes.Style["display"] = "inline";

        
    }

    private void bindTablesName()
    {

        DataTable retTable = Facade.getFacadeObject().GetTablesName();

        foreach (DataRow dr in retTable.Rows)
        {
            ddlSearchTableNumber.Items.Add(new ListItem(dr["tableCode"] + " - " + dr["tableName"], dr["tableCode"].ToString()));
            ddlNewTable.Items.Add(new ListItem(dr["tableCode"] + " - " + dr["tableName"], dr["tableCode"].ToString()));
        }

        ddlSearchTableNumber.Items.Add(new ListItem("הכל", "-1"));
        ddlSearchTableNumber.Items.FindByValue("-1").Selected = true;

        ddlNewTable.Items.Add(new ListItem("בחר", "-1"));
        ddlNewTable.Items.FindByValue("-1").Selected = true;

    }

    private void bindTreatmentTypes()
    {
        DataTable dt = Facade.getFacadeObject().getGeneralDataTable("MushlamTreatmentTypes").Tables[0];

        ddlTreatmentTypes.DataSource = dt;
        ddlTreatmentTypes.DataTextField = "TreatmentName";
        ddlTreatmentTypes.DataValueField = "TreatmentCode";
        ddlTreatmentTypes.DataBind();
    }

    protected void columnSort_clicked(object sender, EventArgs e)
    {
        SortableColumnHeader currColumn = sender as SortableColumnHeader;

        foreach (Control ctrl in divHeaders.Controls)
        {
            if (ctrl is SortableColumnHeader && ctrl != currColumn)
                ((SortableColumnHeader)ctrl).ResetSort();
        }

        _dataSource.DefaultView.Sort = currColumn.ColumnIdentifier + " " + currColumn.GetStringValueOfCurrentSort();
        _currentSort = _dataSource.DefaultView.Sort;

        gvProfessions.DataSource = _dataSource.DefaultView;
        gvProfessions.DataBind();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        hdnMappingType.Value = "";
        BindGridView();
    }

    protected void gvProfessions_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lblMushlamServiceCode = e.Row.FindControl("lblMushlamServiceCode") as Label;
            if (lblMushlamServiceCode.Text == DBNull.Value.ToString())
                lblMushlamServiceCode.Text = "";
            
            Label lblsubCode = e.Row.FindControl("lblsubCode") as Label;
            if (lblsubCode.Text == DBNull.Value.ToString())
                lblsubCode.Text = "";

            Label lblParentCode = e.Row.FindControl("lblParentCode") as Label;
            if (lblParentCode.Text == DBNull.Value.ToString())
                lblParentCode.Text = "";

            Label lblSeferServiceCode = e.Row.FindControl("lblSeferServiceCode") as Label;
            Label lblID = e.Row.FindControl("lblID") as Label;
            lblID.Visible = false;
            string seferServiceDescription = e.Row.Cells[9].Text;
            /*
             tableID, mushlamServiceCode, subGroupCode, parentCode,
             SeferServiceCode
             */
            
            StringBuilder sb = new StringBuilder();
            sb.Append("'" + e.Row.Cells[0].Text + "'");
            sb.Append(",'" + lblID.Text + "'");
            sb.Append(",'" + lblMushlamServiceCode.Text + "'");
            sb.Append(",'" + lblsubCode.Text + "'");
            sb.Append(",'" + lblParentCode.Text + "'");
            sb.Append(",'" + lblSeferServiceCode.Text + "'");
            


            ImageButton button = e.Row.FindControl("ibEdit") as ImageButton;

            button.Attributes.Add("onclick", "setNewWindowParams(" + sb.ToString() + ");return false;");

            if (hdnMappingType.Value == "edit")
            {
                if (hdnID.Value == lblID.Text)
                    e.Row.Style.Add("background-color", "#dbdbda");
            }
         }
        
        
        
    }

    protected void btnDelete_SubSpeciality_Click(object sender, ImageClickEventArgs e)
    {
        
        ImageButton ib = sender as ImageButton;
        string[] args = ib.CommandArgument.Split('_');
        int id = Convert.ToInt32(args[0]);
        int mushlamTableCode = Convert.ToInt32(args[1]);

        Facade.getFacadeObject().DeleteMushlamToSeferMapping(id, mushlamTableCode);

        BindGridView();

    }
}