using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using System.Data;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.Globals;

public partial class Admin_UpdateServiceSynonym : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // session expired
        UserInfo user = new UserManager().GetUserInfoFromSession();
        if (user == null)
        {
            //Response.Redirect(PagesConsts.SEARCH_CLINICS_URL);
        }

        if (IsPostBack && (hdNewServiceCode.Value != "" || hdnSelectedNewServiceCategory.Value != ""))
        {
            AddSynonymToService();
        }
    }

    protected void AddSynonymToService()
    {
        string servicesCodes = "";
        if (!String.IsNullOrEmpty(hdNewServiceCode.Value))
            servicesCodes = hdNewServiceCode.Value;
        else
            servicesCodes = hdnSelectedNewServiceCategory.Value;
        string synonym = hdNewSynonym.Value;

        Facade.getFacadeObject().AddSynonymToService(servicesCodes, synonym);
        
        txtNewSynonym.Text = txtNewServiceCode.Text = txtNewServiceName.Text = string.Empty;
        hdnSelectedNewServiceCategory.Value = hdNewSynonym.Value = hdNewServiceCode.Value = "";
        btnSearch_Click(null, null);

    }

    
    

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        ServiceCode.SetSortDirection(SortDirection.Ascending);
        DataTable dt = GetDataFromDB();

        gvServiceResults.EditIndex = -1;
        BindGrid();
    }

    

    private DataTable  GetDataFromDB()
    {
        int? serviceCode = null;

        if (!string.IsNullOrEmpty(txtServiceCode.Text))
        {
            serviceCode = Convert.ToInt32(txtServiceCode.Text);
        }

        string synonymWord = (txtSynonymWord.Text == string.Empty) ? null : txtSynonymWord.Text; 
        string serviceName = (txtServiceName.Text == string.Empty) ? null : txtServiceName.Text;
        int? sCategorie = null;
        if (!string.IsNullOrEmpty(hdnSelectedServiceCategory.Value) && !string.IsNullOrEmpty(txtServiceCategory.Text))
            sCategorie = Convert.ToInt32(hdnSelectedServiceCategory.Value);

        DataSet ds = Facade.getFacadeObject().GetSynonymsByService(serviceCode, serviceName, synonymWord, sCategorie);
        
        if (ds != null)
        {
            if (ViewState["synonymsDT"] != null)
            {
                ViewState.Remove("synonymsDT");
            }
            ViewState.Add("synonymsDT", ds.Tables[0]);
            return ds.Tables[0];
        }

        return null;
    }

    private void BindGrid()
    {
        DataTable dt;
        if (ViewState["synonymsDT"] != null)
        {
            dt = ViewState["synonymsDT"] as DataTable;
        }
        else
        {
            dt = GetDataFromDB();
        }
        
        if (dt != null)
        {
            DataView dv = dt.DefaultView;
            if (ViewState["sortExpresion"] != null)
            {
                dv.Sort = ViewState["sortExpresion"].ToString();
            }
            
            gvServiceResults.DataSource = dv;
            gvServiceResults.DataBind();
            divResults.Visible = true;
        }
    }

    protected void gvServiceResults_OnRowDeleting(object sender, GridViewDeleteEventArgs e)
    {

        int synonymID = Convert.ToInt32(e.Values[0]);
        Facade.getFacadeObject().DeleteServiceSynonym(synonymID);

        // rebind grid
        //btnSearch_Click(null, null);
        GetDataFromDB();
        BindGrid();
    }

    

    protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        if (row != null)
        {
            gvServiceResults.EditIndex = row.RowIndex;
            BindGrid();

        }
    }
    
    
    protected void imgCancel_Click(object sender, ImageClickEventArgs e)
    {
        gvServiceResults.EditIndex = -1;
        BindGrid();
    }


    protected void gvServiceResults_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        
        int rowInd = e.RowIndex;
        int synonymID = Convert.ToInt32(e.NewValues[0].ToString());
        
        TextBox tb = gvServiceResults.Rows[rowInd].FindControl("txtServiceSynonym") as TextBox;
        string synonym = (tb == null ? "" : tb.Text);

        Facade.getFacadeObject().UpdateServiceSynonym(synonymID, synonym);
        gvServiceResults.EditIndex = -1;
        GetDataFromDB();
        BindGrid();
    }

    protected void btnSort_Click(object sender, EventArgs e)
    {
        SortableColumnHeader columnToSortBy = sender as SortableColumnHeader;
        string CurrentSort = columnToSortBy.ColumnIdentifier.ToString();
        DataView dvCurrentResults = null;
        SortDirection newSortDirection = (SortDirection)columnToSortBy.CurrentSortDirection;
        string direction = "asc";

        
        if (newSortDirection.ToString() == "Descending")
        {
            direction = "desc";
        }

        string sort = String.Empty;
        sort = CurrentSort + " " + direction;
        foreach (Control ctrl in divHeaders.Controls)
        {
            if (ctrl is SortableColumnHeader && ctrl != columnToSortBy)
            {
                ((SortableColumnHeader)ctrl).ResetSort();
            }
        }

        ViewState["sortExpresion"] = sort;
        dvCurrentResults = ((DataTable)ViewState["synonymsDT"]).DefaultView;
        dvCurrentResults.Sort = sort;


        gvServiceResults.DataSource = dvCurrentResults;
        gvServiceResults.DataBind();
        

        

    }

    
}