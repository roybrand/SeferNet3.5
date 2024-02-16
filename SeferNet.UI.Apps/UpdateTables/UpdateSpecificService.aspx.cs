using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using System.Data;

public partial class UpdateTables_UpdateSpecificService : System.Web.UI.Page
{
    protected int m_serviceCode
    {
        get
        {
            if (ViewState["serviceCode"] != null)
                return (int)ViewState["serviceCode"];
            else
                return 0;

        }
        set
        {
            ViewState["serviceCode"] = value;
        }
    }

    private bool InsertMode
    {
        get
        {
            if (ViewState["insertMode"] != null)
            {
                return (bool)ViewState["insertMode"];
            }
            return false;
        }
        set
        {
            ViewState["insertMode"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DeterminePageMode();
            BindData();
        }

        if (!string.IsNullOrEmpty(hdnServiceCode.Value))
        {
            m_serviceCode = Convert.ToInt32(hdnServiceCode.Value);
            txtServiceCodeOld.Text = hdnServiceCode.Value;
            txtServiceDescOld.Text = hdnServiceDesc.Value;
        }
    }

    private void DeterminePageMode()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["ServiceCode"]))
        {
            InsertMode = false;
        }
        else
        {
            InsertMode = true;
        }
    }

    protected void btnSave_click(object sender, EventArgs e)
    {
        bool isCommunity, isMushlam, isHospitals, enableExpert, 
                isService = false, isProfession = false, displayInInternet, RequiresQueueOrder = true;
        
        string sectors = ddlSectors.getSelectItemsCodes();
        string categories = hdnCategoriesListCodes.Value;
        string showExpert = null;
        int? SectorToShowWith = Convert.ToInt32(ddlSectorToShow.SelectedValue);
        if (SectorToShowWith == -1)
            SectorToShowWith = null;

        if (Page.IsValid)
        {
            if (ddlServiceType.Items.FindByValue("service").Selected)
            {
                isService = true;
            }
            else
            {
                isProfession = true;
            }

            isCommunity = chkIsCommunity.Checked;
            isMushlam = chkIsMushlam.Checked;
            isHospitals = chkIsHospital.Checked;
            enableExpert = chkExpert.Checked;
            displayInInternet = cbDisplayInInternet.Checked;
            RequiresQueueOrder = cbRequiresQueueOrder.Checked;

            if (enableExpert)
                showExpert = txtExpertDesc.Text;

            if (InsertMode)
            {
                m_serviceCode = Convert.ToInt32(txtServiceCodeOld.Text);
                Facade.getFacadeObject().InsertService(m_serviceCode, txtDesc.Text, isService, isProfession,
                                    sectors, isCommunity, isMushlam, isHospitals, categories,
                                    enableExpert, showExpert, SectorToShowWith, displayInInternet, RequiresQueueOrder);
            }
            else
            {
                Facade.getFacadeObject().UpdateService(m_serviceCode, txtDesc.Text, isService, isProfession,
                                                    sectors, isCommunity, isMushlam, isHospitals, categories,
                                                    enableExpert, showExpert, SectorToShowWith, displayInInternet, RequiresQueueOrder);
            }


            Response.Redirect("UpdateServices.aspx?research=true");
        }

    }

    protected void btnCancel_click(object sender, EventArgs e)
    {
        Response.Redirect("UpdateServices.aspx?research=true");
    }

    protected void CheckSelectedSector(object sender, ServerValidateEventArgs e)
    {
        if (ddlServiceType.SelectedValue.ToLower() == "profession")
        {
            if (ddlSectors.SelectedItems.Count == 0)
            {
                e.IsValid = false;
                return;
            }
        }

        e.IsValid = true;
        
    }

    protected void CheckInsertedCode(object sender, ServerValidateEventArgs e)
    {
        e.IsValid = (hdnServiceCode.Value != string.Empty);
    }

    private void BindData()
    {
        DataSet ds;

        // sectors
        ds = Facade.getFacadeObject().GetEmployeeSectors(-1);
        if (ds != null && ds.Tables[0].Rows.Count > 0)
        {
            ddlSectors.BindData(ds.Tables[0], "EmployeeSectorCode", "EmployeeSectorDescription");

            ddlSectorToShow.DataSource = ds.Tables[0];
            ddlSectorToShow.DataTextField = "EmployeeSectorDescription";
            ddlSectorToShow.DataValueField = "EmployeeSectorCode";
            ddlSectorToShow.DataBind();
        }

        // update mode
        if (!InsertMode)
        {
            int serviceCode;
            Int32.TryParse(Request.QueryString["ServiceCode"], out serviceCode);
            m_serviceCode = serviceCode;

            ds = Facade.getFacadeObject().GetServiceByCode(m_serviceCode);

            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                DataRow dr = ds.Tables[0].Rows[0];
                txtDesc.Text = dr["ServiceDescription"].ToString();


                bool isService = Convert.ToBoolean(dr["IsService"]);
                if (isService)
                {
                    ddlServiceType.Items.FindByValue("service").Selected = true;
                }
                else
                {
                    ddlServiceType.Items.FindByValue("profession").Selected = true;
                }

                // select sectors
                ddlSectors.SelectItems(dr["Sectors"].ToString());

                // attribution
                chkIsCommunity.Checked = Convert.ToBoolean(dr["IsInCommunity"]);
                chkIsMushlam.Checked = Convert.ToBoolean(dr["IsInMushlam"]);
                chkIsHospital.Checked = Convert.ToBoolean(dr["IsInHospitals"]);

                chkExpert.Checked = Convert.ToBoolean(dr["enableExpert"]);
                txtExpertDesc.Text = dr["ShowExpert"].ToString();
                if (!chkExpert.Checked)
                    pnlExpert.Attributes.Add("disabled", "true");

                txtParentCategories.Text = dr["Categories"].ToString();
                hdnCategoriesListCodes.Value = dr["categoriesCodes"].ToString();

                ddlSectorToShow.SelectedValue = dr["SectorToShowWith"].ToString();
                //if (ddlSectorToShow.SelectedIndex == 0)
                //    ddlSectorToShow.Enabled = false;
                cbDisplayInInternet.Checked = Convert.ToBoolean(dr["displayInInternet"]);

                cbRequiresQueueOrder.Checked = Convert.ToBoolean(dr["RequiresQueueOrder"]);
            }
        }
        else
        {
            pnlAdd.Visible = true;
            chkIsCommunity.Checked = true;
            chkExpert.Checked = false;
            pnlExpert.Attributes.Add("disabled", "true");
            cbDisplayInInternet.Checked = true;
            cbRequiresQueueOrder.Checked = true;
        }
    }
}