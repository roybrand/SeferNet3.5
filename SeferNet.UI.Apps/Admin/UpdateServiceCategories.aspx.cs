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

public partial class UpdateServiceCategories : System.Web.UI.Page
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
    UserInfo currentUserInfo;
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
        UserManager userManager = new UserManager();
        currentUserInfo = userManager.GetUserInfoFromSession();

        applicFacade = Facade.getFacadeObject();

        if (!IsPostBack)
        {

            if (Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS] != null)
            {
                serviceCategoriesSearchParameters = new ServiceCategoriesSearchParameters();
                serviceCategoriesSearchParameters = (ServiceCategoriesSearchParameters)Session[ConstsSession.SERVICE_CATEGORIES_SEARCH_PARAMETERS];

                if (serviceCategoriesSearchParameters.SelectedServiceCategoryID != -1)
                {
                    applicFacade = Facade.getFacadeObject();
                    DataSet ds = applicFacade.GetServiceCategory((int)serviceCategoriesSearchParameters.SelectedServiceCategoryID);

                    if (ds.Tables[0].Rows[0] != null)
                    {
                        txtServiceCategoryCode.Text = ds.Tables[0].Rows[0]["ServiceCategoryID"].ToString();
                        txtServiceCategoryDescription.Text = ds.Tables[0].Rows[0]["ServiceCategoryDescription"].ToString();
                        txtMF_Specialities051Codes.Text = ds.Tables[0].Rows[0]["MF_Specialities051Code"].ToString();
                        txtMF_Specialities051Description.Text = ds.Tables[0].Rows[0]["MF_Specialities051Description"].ToString();

                    }

                    if (ds.Tables[1].Rows.Count > 0)   //attributed services
                    {
                        string attributedServicesCodes = string.Empty;
                        string attributedServices = string.Empty;

                        foreach (DataRow dr in ds.Tables[1].Rows)
                        {
                            attributedServicesCodes += dr["ServiceCode"].ToString() + ',';
                            attributedServices += dr["ServiceDescription"].ToString() + ", ";
                        }

                        if (attributedServicesCodes.Length > 0)
                        {
                            attributedServicesCodes = attributedServicesCodes.Substring(0, attributedServicesCodes.Length - 1);
                            attributedServices = attributedServices.Substring(0, attributedServices.Length - 2);
                        }

                        txtAttributedServicesCodes.Text = attributedServicesCodes;
                        txtAttributedServices.Text = attributedServices;
                    }

                }
                //serviceCategoriesSearchParameters.SelectedServiceCategoryID = -1;
                // if (hdnScrollPosition.Value != string.Empty)
                //     serviceCategoriesSearchParameters.ScrollPosition_ServiceCategories_UpdateServiceCategories = Convert.ToInt32(hdnScrollPosition.Value);

                //GetParametersAndBindGvServiceCategories();
            }

            //handleBinding();
            
        }
        else
        {
            //gvUsers.Visible = true;
        }

    }

     protected void Page_PreRender(object sender, EventArgs e)
    {
 
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("ServiceCategories.aspx");
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();
        string serviceCategoryDescription = txtServiceCategoryDescription.Text;
        int? subcategoryFromTableMF51;
        if (txtMF_Specialities051Codes.Text.Trim() != string.Empty)
        {
            string[] subcategoryFromTableMF51_lst = txtMF_Specialities051Codes.Text.Trim().Split(',');
            //subcategoryFromTableMF51 = Convert.ToInt32(txtMF_Specialities051Codes.Text.Trim());
            subcategoryFromTableMF51 = Convert.ToInt32(subcategoryFromTableMF51_lst[0]);
        }
        else
            subcategoryFromTableMF51 = null;
        string attributedServices = txtAttributedServicesCodes.Text;

        if (txtServiceCategoryCode.Text == string.Empty) //new Service Category
        {
            int newServiceCategoryID = applicFacade.InsertServiceCategory(serviceCategoryDescription, subcategoryFromTableMF51, attributedServices);

            if (newServiceCategoryID != 0)
            {
                serviceCategoriesSearchParameters = new ServiceCategoriesSearchParameters();
                serviceCategoriesSearchParameters.ServiceCategoryID = newServiceCategoryID;
                serviceCategoriesSearchParameters.ServiceCategoryDescription = serviceCategoryDescription;
                serviceCategoriesSearchParameters.ScrollPosition_ServiceCategories_UpdateServiceCategories = 0;
                serviceCategoriesSearchParameters.SelectedServiceCategoryID = newServiceCategoryID;

                Response.Redirect("ServiceCategories.aspx");
            }
            else
            {
                //error message
            }
        }
        else
        {
            applicFacade.UpdateServiceCategory(Convert.ToInt32(txtServiceCategoryCode.Text), serviceCategoryDescription, attributedServices, subcategoryFromTableMF51);
            Response.Redirect("ServiceCategories.aspx");
        }
    }
}
