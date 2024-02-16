using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using SeferNet.BusinessLayer.BusinessObject;      
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.FacadeLayer;
using System.Data.SqlClient;
using SeferNet.DataLayer;
using AjaxControlToolkit;
using SeferNet.Globals;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using System.Collections.Generic;

public partial class ServiceCategories : AdminBasePage
{
    private Facade applicFacade;
    bool m_InsertPermissionErrorFlag = false;
    bool m_UpdateUserErrorFlag = false;
    bool m_InsertUserErrorFlag = false;
    bool m_RestoreData = false;
    bool m_addNewUser = false;
    DataSet dsServiceCategories;
    DataSet dsUser;
    dvUserPermissionsInfo dvData;
    DvUserInfo dvUserData;
    
    int m_selectedPermissionType;
    int m_selectedDistrict;
    string expandedUserPermissions_ViewState = "expandedUserPermissionsViewState";
    string expandedUserPermissions_Session = "expandedUserPermissions_Session";
    Hashtable expandedUserPermissions_Hashtable;

    ServiceCategoriesSearchParameters serviceCategoriesSearchParameters;

    private string CurrentSort
    {
        get
        {
            if (ViewState["currentSort"] != null)
                return ViewState["currentSort"].ToString();
            //return "ActiveForSort";
            return "ServiceCategoryID";
        }
        set
        {
            ViewState["currentSort"] = value;
        }
    }

    private DataTable DtServiceCategories
    {
        get 
        {
            return (DataTable)ViewState["dtServiceCategories"];
        }
        set 
        {
            ViewState["dtServiceCategories"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        
        applicFacade = Facade.getFacadeObject();

        if (!IsPostBack)
        {
            if (Request.QueryString["ClearParameters"] != null)
                Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] = null;

            SetSearchParameters();

        }
        else
        {
            //gvUsers.Visible = true;
        }

    }

    private void SetSearchParameters()
    {
        if (Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] != null)
        {
            serviceCategoriesSearchParameters = new ServiceCategoriesSearchParameters();
            serviceCategoriesSearchParameters = (ServiceCategoriesSearchParameters)Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS];

            if (serviceCategoriesSearchParameters.ServiceCategoryID != null)
                txtServiceCategoryID.Text = serviceCategoriesSearchParameters.ServiceCategoryID.ToString();

            if (serviceCategoriesSearchParameters.ServiceCategoryDescription != null)
                txtServiceCategoryDescription.Text = serviceCategoriesSearchParameters.ServiceCategoryDescription;

            if (serviceCategoriesSearchParameters.ScrollPosition_ServiceCategories_UpdateServiceCategories != null)
                hdnScrollPosition.Value = serviceCategoriesSearchParameters.ScrollPosition_ServiceCategories_UpdateServiceCategories.ToString();

            if (serviceCategoriesSearchParameters.ColumnIdentifier != null && serviceCategoriesSearchParameters.SortDirection != null)
            {
                string sort = "";
                if (serviceCategoriesSearchParameters.SortDirection == SortDirection.Ascending)
                    sort = "asc";
                else
                    sort = "desc";

                CurrentSort = serviceCategoriesSearchParameters.ColumnIdentifier + ' ' + sort;

                foreach (Control ctrl in tdSortingButtons.Controls)
                {
                    if (ctrl is SortableColumnHeader && ((SortableColumnHeader)ctrl).ColumnIdentifier.ToString().Contains(serviceCategoriesSearchParameters.ColumnIdentifier))
                    {
                        ((SortableColumnHeader)ctrl).SetSortDirection(serviceCategoriesSearchParameters.SortDirection);
                    }
                }
            }

            GetParametersAndBindGvServiceCategories();

            if(serviceCategoriesSearchParameters.CurrentRowIndex != null)
                gvServiceCategories.SelectedIndex = (int)serviceCategoriesSearchParameters.CurrentRowIndex;

            ClientScript.RegisterStartupScript(typeof(string), "SetScrollPosition", "SetScrollPosition();", true);
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        GetParametersAndBindGvServiceCategories();
    }

    private void GetParametersAndBindGvServiceCategories()
    {
        hdnDeptCode.Value = hdnMinheletValue.Value = string.Empty;

        string strServiceCategoryID = txtServiceCategoryID.Text.Trim();
        int? serviceCategoryID = null;
        if (strServiceCategoryID != string.Empty)
            serviceCategoryID = Convert.ToInt32(strServiceCategoryID);

        string serviceCategoryDescription = txtServiceCategoryDescription.Text.Trim();
        if (serviceCategoryDescription == string.Empty)
            serviceCategoryDescription = null;

        int? subCategoryFromTableMF51 = null;

        dsServiceCategories = applicFacade.GetServiceCategories(serviceCategoryID, serviceCategoryDescription, subCategoryFromTableMF51);
        DtServiceCategories = dsServiceCategories.Tables[0];
        DataView dvServiceCategories = new DataView(DtServiceCategories,
            "", CurrentSort, DataViewRowState.CurrentRows);

        gvServiceCategories.DataSource = dvServiceCategories;
        gvServiceCategories.DataBind();
    }

    protected void btnDeleteServiceCategory_Click(object sender, EventArgs e)
    {
        ImageButton btnDeleteServiceCategory = sender as ImageButton;
        int serviceCategoryID = Convert.ToInt32(btnDeleteServiceCategory.Attributes["ServiceCategoryID"]);

        applicFacade.DeleteServiceCategory(serviceCategoryID);

        if (Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] != null)
            serviceCategoriesSearchParameters = (ServiceCategoriesSearchParameters)Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS];
        else
            serviceCategoriesSearchParameters = new ServiceCategoriesSearchParameters();

        serviceCategoriesSearchParameters.CurrentRowIndex = -1;

        Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] = serviceCategoriesSearchParameters;

        GetParametersAndBindGvServiceCategories();
    }

    protected void btnUpdateServiceCategory_Click(object sender, EventArgs e)
    {
        ImageButton btnUpdateServiceCategory = sender as ImageButton;
        int serviceCategoryID = Convert.ToInt32(btnUpdateServiceCategory.Attributes["ServiceCategoryID"]);
        int currentRowIndex = Convert.ToInt32(btnUpdateServiceCategory.Attributes["CurrentRowIndex"]);

        if (Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] != null)
            serviceCategoriesSearchParameters = (ServiceCategoriesSearchParameters)Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS];
        else
            serviceCategoriesSearchParameters = new ServiceCategoriesSearchParameters();

        if(txtServiceCategoryID.Text.Trim() != string.Empty)
            serviceCategoriesSearchParameters.ServiceCategoryID = Convert.ToInt32(txtServiceCategoryID.Text);
        serviceCategoriesSearchParameters.ServiceCategoryDescription = txtServiceCategoryDescription.Text;
        serviceCategoriesSearchParameters.SelectedServiceCategoryID = serviceCategoryID;
        serviceCategoriesSearchParameters.CurrentRowIndex = currentRowIndex;

        if(hdnScrollPosition.Value != string.Empty)
            serviceCategoriesSearchParameters.ScrollPosition_ServiceCategories_UpdateServiceCategories = Convert.ToInt32(hdnScrollPosition.Value);

        Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] = serviceCategoriesSearchParameters;

        Response.Redirect("UpdateServiceCategories.aspx");

    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (ViewState["SelectedrowClientID"] != null)
        {
            string rowind = ViewState["SelectedrowIndex"].ToString() ;
            string SelectedrowClientID = ViewState["SelectedrowClientID"].ToString();
            ClientScript.RegisterStartupScript(typeof(string), "startPrefix", "selectRowOnLoad('" + SelectedrowClientID + "',"+rowind+");", true);
        }

        if (Session["InsertUserError"] != null)
        {
            //dvUserDetails.Visible = true;
            Session["InsertUserError"] = null;
        }

        //if(IsPostBack)
        //    GetParametersAndBindGvUsers();

    }

    protected void btnSort_click(object sender, EventArgs e)
    {
        SortableColumnHeader columnToSortBy = sender as SortableColumnHeader;

        if (DtServiceCategories == null)
        {
            columnToSortBy.ResetSort();
            return;
        }

        foreach (Control ctrl in tdSortingButtons.Controls)
        {
            if (ctrl is SortableColumnHeader && ctrl != columnToSortBy)
            {
                ((SortableColumnHeader)ctrl).ResetSort();
            }
        }

        CurrentSort = columnToSortBy.ColumnIdentifier + " " + columnToSortBy.GetStringValueOfCurrentSort();

        DataView dvServiceCategories = new DataView(DtServiceCategories, "", CurrentSort, DataViewRowState.CurrentRows);

        if (Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] != null)
        {
            serviceCategoriesSearchParameters = (ServiceCategoriesSearchParameters)Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS];
            serviceCategoriesSearchParameters.SortDirection = (SortDirection)columnToSortBy.CurrentSortDirection;
            serviceCategoriesSearchParameters.ColumnIdentifier = columnToSortBy.ColumnIdentifier.ToString();
            serviceCategoriesSearchParameters.SelectedServiceCategoryID = null;
            Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] = serviceCategoriesSearchParameters;
        }

        gvServiceCategories.DataSource = dvServiceCategories;
        gvServiceCategories.DataBind();

        gvServiceCategories.SelectedIndex = -1;
    }

    protected void btnAddServiceCategory_Click(object sender, EventArgs e)
    {
        serviceCategoriesSearchParameters = new ServiceCategoriesSearchParameters();

        if(txtServiceCategoryID.Text.Trim() != string.Empty)
            serviceCategoriesSearchParameters.ServiceCategoryID = Convert.ToInt32(txtServiceCategoryID.Text);
        serviceCategoriesSearchParameters.ServiceCategoryDescription = txtServiceCategoryDescription.Text;
        serviceCategoriesSearchParameters.SelectedServiceCategoryID = -1;
        if(hdnScrollPosition.Value != string.Empty)
            serviceCategoriesSearchParameters.ScrollPosition_ServiceCategories_UpdateServiceCategories = Convert.ToInt32(hdnScrollPosition.Value);

        Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] = serviceCategoriesSearchParameters;

        Response.Redirect("UpdateServiceCategories.aspx");
    }

    protected void gvServiceCategories_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if(e.Row.RowType == DataControlRowType.DataRow)
        {
            string text1 = ",שים לב " + "##" + ".יש תחומים המקושרים לתחום ראשי" + "##" + "?האם ברצונך להמשיך";
            string text0 = "?האם הנך בטוח שברצוך למחוק את התחום ראשי";

            DataRowView row = e.Row.DataItem as DataRowView;

            ImageButton btnUpdateServiceCategory = e.Row.FindControl("btnUpdateServiceCategory") as ImageButton;
            btnUpdateServiceCategory.Attributes.Add("CurrentRowIndex", e.Row.RowIndex.ToString());

            string ServiceCategoryID = Convert.ToInt32(row["ServiceCategoryID"]).ToString();

            ImageButton btnDeleteServiceCategory = e.Row.FindControl("btnDeleteServiceCategory") as ImageButton;
            Label lblHasAttributedServices = e.Row.FindControl("lblHasAttributedServices") as Label;
            if (lblHasAttributedServices.Text == "1")
                btnDeleteServiceCategory.Attributes.Add("onclick", "SetServiceCategoryIDtoBeDeleted('" + ServiceCategoryID + "'); return AreYourSure('" + text1 + "')");
            else
                btnDeleteServiceCategory.Attributes.Add("onclick", "SetServiceCategoryIDtoBeDeleted('" + ServiceCategoryID + "'); return AreYourSure('" + text0 + "')");
        }
    }

    protected void btnDeleteServiceCategoryAfterConfirm_Click(object sender, EventArgs e)
    {
        int serviceCategoryID = Convert.ToInt32(txtServiceCategoryIDtoBeDeleted.Text);

        applicFacade.DeleteServiceCategory(serviceCategoryID);

        if (Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] != null)
            serviceCategoriesSearchParameters = (ServiceCategoriesSearchParameters)Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS];
        else
            serviceCategoriesSearchParameters = new ServiceCategoriesSearchParameters();

        serviceCategoriesSearchParameters.CurrentRowIndex = -1;

        Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] = serviceCategoriesSearchParameters;

        GetParametersAndBindGvServiceCategories();
    }
}
