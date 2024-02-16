using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.FacadeLayer;
using System.Collections;

public partial class UpdateTables_UpdateServices : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindSearchControls();

            // restore the last search
            if (Cache["searchParams"] != null && !string.IsNullOrEmpty(Request.QueryString["research"]))
            {
                object[] arr = (object[])Cache["searchParams"];
                SearchAndBindByParams((int?)arr[0], Convert.ToString(arr[1]), (int?) arr[2], (int?) arr[3],  (int?) arr[4], 
                                                                (bool?) arr[5], (bool?) arr[6], (bool?) arr[7], Convert.ToString(arr[8]));
            }
        }

        Page.Form.DefaultButton = btnSearch.UniqueID;
    }


    protected void btnSearch_click(object sender, EventArgs e)
    {
        int? serviceCategoryCode = null;
        int? serviceCode = null;
        int? selectedSector;
        int? selectedRequireQueueOrder;
        bool? isCommunity = null, isMushlam = null, isHospitals = null;

        isCommunity = (chkCommunity.Checked) ? true : isCommunity;
        isMushlam =   (chkMushlam.Checked) ? true : isMushlam;
        isHospitals = (chkHospitals.Checked) ? true : isHospitals;
        
        selectedSector = Convert.ToInt32(ddlSector.SelectedValue);        
        if (selectedSector == -1)
            selectedSector = null;

        selectedRequireQueueOrder = Convert.ToInt32(ddlRequireQueueOrder.SelectedValue);        
        if (selectedRequireQueueOrder == -1)
            selectedRequireQueueOrder = null;        

        if (!string.IsNullOrEmpty(txtServiceCode.Text))
        {
            serviceCode = Convert.ToInt32(txtServiceCode.Text);
        }
        else
        {
            if (!string.IsNullOrEmpty(hdnSelectedServiceCode.Value) && !string.IsNullOrEmpty(txtService.Text))
            {
                serviceCode = Convert.ToInt32(hdnSelectedServiceCode.Value);
            }
        }

        if (!string.IsNullOrEmpty(hdnSelectedServiceCategory.Value) && !string.IsNullOrEmpty(txtServiceCategory.Text))
        {
            serviceCategoryCode = Convert.ToInt32(hdnSelectedServiceCategory.Value);
        }

        string serviceName = (txtService.Text == string.Empty) ? null : txtService.Text;

        SearchAndBindByParams(serviceCode, serviceName, serviceCategoryCode, selectedSector, selectedRequireQueueOrder, isCommunity,
                                                                    isMushlam, isHospitals, txtServiceCategory.Text);
    }

    protected void gvResults_rowDataBound(object sender, GridViewRowEventArgs e)
    {
        DataRowView row = e.Row.DataItem as DataRowView;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ((Label)e.Row.FindControl("lblIsProfession")).Text = Convert.ToBoolean(row["isProfession"]) == true ? "מקצוע" : "שירות";
            //((Label)e.Row.FindControl("lblIsService")).Text = Convert.ToBoolean(row["isService"]) == true ? "כן" : "לא";
            ((Image)e.Row.FindControl("imgIsCommunity")).Visible = Convert.ToBoolean(row["IsInCommunity"]) == true ? true : false;
            ((Image)e.Row.FindControl("imgIsMushlam")).Visible = Convert.ToBoolean(row["IsInMushlam"]) == true ? true : false;
            ((Image)e.Row.FindControl("imgIsHospital")).Visible = Convert.ToBoolean(row["IsInHospitals"]) == true ? true : false;
            //((Label)e.Row.FindControl("lblIsHospital")).Text = Convert.ToBoolean(row["IsInHospitals"]) == true ? "כן" : "לא";            
            //((Label)e.Row.FindControl("lblDisplayInInternet")).Text = Convert.ToInt16(row["displayInInternet"]) == 1 ? "כן" : "לא"; 
            ((Image)e.Row.FindControl("imgDisplayInInternet")).Visible = Convert.ToBoolean(row["displayInInternet"]) == true ? false : true;            
            ((Label)e.Row.FindControl("lblRequiresQueueOrder")).Text = Convert.ToInt16(row["RequiresQueueOrder"]) == 1 ? "כן" : "לא";

            // javascript function to call on row-dblclick event
            e.Row.Attributes.Add("ondblclick", "javascript:void RedirectToUpdatePage(" + row["ServiceCode"].ToString() + ");");
            e.Row.Attributes.Add("style", "cursor: pointer");
        }
    }

    protected void linkEdit_click(object sender, EventArgs e)
    {
        LinkButton lnk = sender as LinkButton;

        Response.Redirect("~/UpdateTables/UpdateSpecificService.aspx?ServiceCode=" + lnk.CommandArgument);        
    }

    protected void Sort_click(object sender, EventArgs e)
    {
        SortableColumnHeader currCol = sender as SortableColumnHeader;

        ResetColumns(currCol);

        if (ViewState["source"] != null)
        {
            DataTable dt = (DataTable)ViewState["source"];

            dt.DefaultView.Sort = currCol.ColumnIdentifier.ToString() + " " + currCol.GetStringValueOfCurrentSort();

            gvResults.DataSource = dt.DefaultView;
            gvResults.DataBind();
        }
    }

    protected void btnAdd_click(object sender, EventArgs e)
    {
        Response.Redirect("~/UpdateTables/UpdateSpecificService.aspx?Add=true");        
    }

    protected void btnClear_click(object sender, EventArgs e)
    {
        ddlSector.SelectedIndex = -1;
        ddlRequireQueueOrder.SelectedIndex = -1;
        txtService.Text = txtServiceCategory.Text = txtServiceCode.Text = string.Empty;
        chkCommunity.Checked = true;
        chkHospitals.Checked = chkMushlam.Checked = false;
        gvResults.Visible = false;
    }


    private void ResetColumns(SortableColumnHeader currCol)
    {
        foreach (Control ctrl in tdColumnsContainer.Controls)
        {
            if (ctrl is SortableColumnHeader && ctrl != currCol)
            {
                (ctrl as SortableColumnHeader).ResetSort();
            }
        }
    }

    private void BindSearchControls()
    {
        UIHelper.BindDropDownToCachedTable(ddlSector, "EmployeeSector", "RelevantForProfession = 1", "EmployeeSectorDescription");
        ddlSector.Items.Insert(0, new ListItem("הכל", "-1"));

        ddlRequireQueueOrder.Items.Insert(0, new ListItem("הכל", "-1"));
        ddlRequireQueueOrder.Items.Insert(1, new ListItem("לא", "0"));
        ddlRequireQueueOrder.Items.Insert(2, new ListItem("כן", "1"));
    }

    private void SearchAndBindByParams(int? serviceCode, string serviceName, int? serviceCategoryCode, int? selectedSector, int? selectedRequireQueueOrder, bool? isCommunity,
                                                                bool? isMushlam, bool? isHospitals, string selectedServiceCategoryName)
    {
        DataSet ds = Facade.getFacadeObject().GetServicesForUpdate(serviceCode, serviceName, serviceCategoryCode,  selectedSector, selectedRequireQueueOrder,
                                                                    isCommunity, isMushlam, isHospitals);


        // save the last requested params in cache so we can get the exact results when coming back
        object[] arr = new object[] { serviceCode, serviceName, serviceCategoryCode, selectedSector, selectedRequireQueueOrder, isCommunity, 
                                            isMushlam, isHospitals, selectedServiceCategoryName };
        Cache.Remove("searchParams");
        Cache.Add("searchParams", arr, null, System.Web.Caching.Cache.NoAbsoluteExpiration,
                                    TimeSpan.FromMinutes(1), System.Web.Caching.CacheItemPriority.Low, null);

        ViewState["source"] = ds.Tables[0];


        txtServiceCode.Text = serviceCode != null ? serviceCode.ToString() : string.Empty;
        txtService.Text = serviceName;
        txtServiceCategory.Text = selectedServiceCategoryName;


        gvResults.DataSource = ds.Tables[0];
        gvResults.DataBind();
        gvResults.Visible = true;

        ResetColumns(null);
    }
    protected void imgCreateExcelReport_Click(object sender, ImageClickEventArgs e)
    {
        Hashtable WhereParameters = ParamsWhere();
        Session["ParamsWhere"] = WhereParameters;

        Session["CurrentReportName"] = "rprt_ServicesExcel";
        Session["CurrentReportTitle"] = "עדכון תחומי שירות";

        ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "CreateExcelReport", "CreateExcelReport();", true);
    }

    public Hashtable ParamsWhere()
    {
        Hashtable paramsWhere = new Hashtable();
        int? serviceCategoryCode = -1;
        int? serviceCode = -1;
        int? selectedSector = -1;
        string serviceName;
        int? selectedRequireQueueOrder = -1;
        bool? isCommunity = false, isMushlam = false, isHospitals = false;

        isCommunity = (chkCommunity.Checked) ? true : isCommunity;
        isMushlam = (chkMushlam.Checked) ? true : isMushlam;
        isHospitals = (chkHospitals.Checked) ? true : isHospitals;

        if (!string.IsNullOrEmpty(txtServiceCode.Text))
        {
            serviceCode = Convert.ToInt32(txtServiceCode.Text);
        }
        else
        {
            if (!string.IsNullOrEmpty(hdnSelectedServiceCode.Value) && !string.IsNullOrEmpty(txtService.Text))
            {
                serviceCode = Convert.ToInt32(hdnSelectedServiceCode.Value);
            }
        }

        if (!string.IsNullOrEmpty(hdnSelectedServiceCategory.Value) && !string.IsNullOrEmpty(txtServiceCategory.Text))
        {
            serviceCategoryCode = Convert.ToInt32(hdnSelectedServiceCategory.Value);
        }

        serviceName = (txtService.Text == string.Empty) ? "-1" : txtService.Text;

        selectedSector = Convert.ToInt32(ddlSector.SelectedValue);

        selectedRequireQueueOrder = Convert.ToInt32(ddlRequireQueueOrder.SelectedValue);

        paramsWhere.Add("serviceCode", serviceCode);
        paramsWhere.Add("serviceName", serviceName);
        paramsWhere.Add("serviceCategory", serviceCategoryCode);
        paramsWhere.Add("sectorCode", selectedSector);
        paramsWhere.Add("requireQueueOrder", selectedRequireQueueOrder);
        if (isCommunity == true)
        {
            paramsWhere.Add("isCommunity", 1);
        }
        else
        { 
             paramsWhere.Add("isCommunity", 0);       
        }

        if (isMushlam == true)
        {
            paramsWhere.Add("isMushlam", 1);
        }
        else
        { 
            paramsWhere.Add("isMushlam", 0);       
        }

        if (isHospitals == true)
        {
            paramsWhere.Add("isHospital", 1);
        }
        else
        { 
            paramsWhere.Add("isHospital", 0);        
        }

        return paramsWhere;
    }
}