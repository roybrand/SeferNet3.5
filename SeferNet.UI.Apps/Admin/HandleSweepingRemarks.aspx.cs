using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Globalization;

using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.BusinessObject;
using System.Data.SqlClient;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.DataLayer;
using SeferNet.FacadeLayer;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using SeferNet.Globals;

public partial class HandleSweepingRemarks : AdminBasePage
{
    Facade applicFacade;
    UserInfo currentUser;
    System.Collections.Generic.List<UserPermission> PermissionList;
    string remarkText = string.Empty;
    SessionParams sessionParams;
    SweepingRemarksParameters sweepingRemarksParameters;
    DataSet dsSweepingRemarks;

    string districtCodes = string.Empty;
    string districtNames = string.Empty;
    string administrationCodes = string.Empty;
    string administrationNames = string.Empty;
    string unitTypeCodes = string.Empty;
    string unitTypeNames = string.Empty;
    string populationSector = string.Empty;
    int subUnitType = -1;
    int RelatedRemarkID;
    int userPermittedDistrict = 0;
    string cityCodes = string.Empty;
    string cityName = string.Empty;
    string servicesParameter = string.Empty;
    string servicesNameParameter = string.Empty;
    string freeTextToSearch = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        currentUser = Session["currentUser"] as UserInfo;

        sessionParams = SessionParamsHandler.GetSessionParams();

        sweepingRemarksParameters = SessionParamsHandler.GetSweepingRemarksParameters();

        applicFacade = Facade.getFacadeObject();

        SetPermittedDistrict();

        if (!IsPostBack)
        {
            if (Request.QueryString["ClearParameters"] != null)
            {
                SessionParamsHandler.ClearSweepingRemarksParameters();
                // There is "ClearParameters" in query string when we open the page from "Main menu" to clear parameters.
                // If we call page "AddRemark.aspx" and then come back from it, "ClearParameters" still presents 
                // because page "AddRemark.aspx" doesn't make "redirect" BUT uses "Server.Transfer" 
                // and in this case we still have "ClearParameters" in query string.
                // SO we make "redirect" to get rid of "ClearParameters"
                Response.Redirect("../Admin/HandleSweepingRemarks.aspx");
            }

            if (sweepingRemarksParameters != null)
            {
                SetParametersToControls();
                SetPermittedDistrict();
            }

            if (districtCodes == string.Empty)
                districtCodes = "-1";
            if (administrationCodes == string.Empty)
                administrationCodes = "-1";
            if (unitTypeCodes == string.Empty)
                unitTypeCodes = "-1";
            if (populationSector == string.Empty)
                populationSector = "-1";

            FillLists(districtCodes, administrationCodes, populationSector, unitTypeCodes);

            if (districtCodes != "-1" || administrationCodes != "-1" || unitTypeCodes != "-1" || populationSector != "-1")
                BindRemarks(districtCodes, administrationCodes, populationSector, unitTypeCodes, subUnitType, servicesParameter, cityCodes, freeTextToSearch);

            //BindRemarks(districtCodes, administrationCodes, populationSector, unitTypeCodes, subUnitType);
        }

        if (!string.IsNullOrEmpty(hdnNewUnitCodeSelected.Value))
        {
            HandleSubUnitCodeArea();
            hdnNewUnitCodeSelected.Value = string.Empty;
        }


        autoCompleteAdmins.ContextKey = txtDistrictCodes.Text;
        autoCompleteCities.ContextKey = txtDistrictCodes.Text;
    }

    private void HandleSubUnitCodeArea()
    {
        string[] unitTypesSelected = txtUnitTypeListCodes.Text.Split(',');

        if (unitTypesSelected.Length == 1 && unitTypesSelected[0] != string.Empty)
        {
            //try to get subUnitTypes list (if exists) for the selected unitType
            ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
          
            DataTable tblSubUnitType = cacheHandler.getCachedDataTable(eCachedTables.View_SubUnitTypes.ToString());
            if (tblSubUnitType == null) // if table was not found in cache we get the data from the database
            {
                Facade applicFacade = Facade.getFacadeObject();
                DataSet ds = applicFacade.getGeneralDataTable("View_SubUnitTypes");
                tblSubUnitType = ds.Tables[0];
                if (tblSubUnitType == null)
                    return;
            }

            DataView dvSubUnitType = new DataView(tblSubUnitType, "UnitTypeCode = " + unitTypesSelected[0], "subUnitTypeName", DataViewRowState.OriginalRows);

            if (dvSubUnitType.Count > 0)
            {
                lblSubUnitType.Visible = true;
                ddlSubUnitType.Visible = true;

                ddlSubUnitType.Items.Clear();

                ddlSubUnitType.DataSource = dvSubUnitType;
                ddlSubUnitType.DataBind();
                
                ListItem lItem = new ListItem("הכל", "-1");
                ddlSubUnitType.Items.Insert(0, lItem);
            }
            else
            {
                ddlSubUnitType.Visible = false;
                lblSubUnitType.Visible = false;
            }

        }
        else
        {
            //the case when "NO ONE" or "MORE THEN ONE"  unitTypes were selected
            // just hide the ddlSubUnitType control
            ddlSubUnitType.Items.Clear();
            ddlSubUnitType.Visible = false;
            lblSubUnitType.Visible = false;

        }
    }

    void SetPermittedDistrict()
    {
        if(!currentUser.IsAdministrator)
        {
            txtDistrictsPermitted.Text = string.Empty;

            List<UserPermission> userPermissions = currentUser.UserPermissions;

            for (int i = 0; i < userPermissions.Count; i++)
            {
                if (userPermissions[i].PermissionType == SeferNet.Globals.Enums.UserPermissionType.District)
                {
                    //userPermittedDistrict = userPermissions[i].DeptCode;
                    if (txtDistrictsPermitted.Text != string.Empty)
                        txtDistrictsPermitted.Text = txtDistrictsPermitted.Text + ',';
                    txtDistrictsPermitted.Text = txtDistrictsPermitted.Text + userPermissions[i].DeptCode.ToString();
                }
            }

            ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();           
            DataTable tblDist = cacheHandler.getCachedDataTable(eCachedTables.View_AllDistricts.ToString());

            DataView vDist = new DataView(tblDist, "districtCode in (" + txtDistrictsPermitted.Text + ")", "", DataViewRowState.CurrentRows);

            if (vDist.Count == 1)
            { 
                foreach (DataRowView drv in vDist)
                {
                    if (txtDistrictList.Text != string.Empty)
                        txtDistrictList.Text = txtDistrictList.Text + ',';
                    txtDistrictList.Text = txtDistrictList.Text + drv["districtName"];
                }
           
                btnDistrictsPopUp.Style.Add("display", "none");
                txtDistrictCodes.Text = txtDistrictsPermitted.Text;
                txtDistrictList.ReadOnly = true;
            }

            //foreach (DataRow dr in tblDist.Rows)
            //{
            //    if (Convert.ToInt32(dr["districtCode"]) == currentUser.DistrictCode)
            //    {
            //        btnDistrictsPopUp.Style.Add("display", "none");
            //        //txtDistrictCodes.Text = userPermittedDistrict.ToString();
            //        txtDistrictCodes.Text = dr["districtCode"].ToString();
            //        txtDistrictList.Text = dr["districtName"].ToString();
            //        txtDistrictList.ReadOnly = true;
            //    }
            //}

        }

    }

    

    private void FillLists(string districtCode, string administrationCode, string populationSector, string UnitTypeCode)
    {
        UIHelper.BindDropDownToCachedTable(ddlPopulationSectors, "PopulationSectors", "PopulationSectorDescription");
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        HandleButtons();
        if (dsSweepingRemarks != null && (dsSweepingRemarks.Tables["currentRemarks"].Rows.Count > 0 || dsSweepingRemarks.Tables["futureRemarks"].Rows.Count > 0 || dsSweepingRemarks.Tables["historyRemarks"].Rows.Count > 0))
        {
            trHeaderRemarks.Style.Add("display", "inline");
        }
        else
        { 
            trHeaderRemarks.Style.Add("display", "none");
        }

        if (dsSweepingRemarks != null && dsSweepingRemarks.Tables["currentRemarks"] != null && dsSweepingRemarks.Tables["currentRemarks"].Rows.Count > 0)
        {
            trCurrentRemarks.Style.Add("display", "inline");
            trRemarksHeader_Current.Style.Add("display", "inline");
        }
        else
        {
            trCurrentRemarks.Style.Add("display", "none");
            trRemarksHeader_Current.Style.Add("display", "none");
        }

        if (dsSweepingRemarks != null && dsSweepingRemarks.Tables["futureRemarks"] != null && dsSweepingRemarks.Tables["futureRemarks"].Rows.Count > 0)
        {
            gvRemarks_Future.Style.Add("display", "inline");
            trRemarksHeader_Future.Style.Add("display", "inline");
        }
        else
        {
            gvRemarks_Future.Style.Add("display", "none");
            trRemarksHeader_Future.Style.Add("display", "none");
        }

        if (dsSweepingRemarks != null && dsSweepingRemarks.Tables["historyRemarks"] != null && dsSweepingRemarks.Tables["historyRemarks"].Rows.Count > 0)
        {
            gvRemarks_History.Style.Add("display", "inline");
            trRemarksHeader_History.Style.Add("display", "inline");
        }
        else
        {
            gvRemarks_History.Style.Add("display", "none");
            trRemarksHeader_History.Style.Add("display", "none");
        }

    }

    protected void HandleButtons()
    {
        if (txtDistrictCodes.Text != string.Empty)
        {
            btnAddRemark.Enabled = true;
            btnSelect.Enabled = true;
            txtCityName.Enabled = true;
            btnCitiesListPopUp.Disabled = false;
        }
        else
        {
            btnAddRemark.Enabled = false;
            btnSelect.Enabled = false;
            txtCityName.Enabled = false;
            btnCitiesListPopUp.Disabled = true;
        }
    }

    protected void btnSelect_Click(object sender, EventArgs e)
    {
        ScriptManager.RegisterClientScriptBlock(this, typeof(UpdatePanel), "hideProgressBarGeneral", "hideProgressBarGeneral()", true);

        districtCodes = txtDistrictCodes.Text;
        administrationCodes = txtAdminCodes.Text;
        unitTypeCodes = txtUnitTypeListCodes.Text;
        populationSector = ddlPopulationSectors.SelectedValue;
        servicesParameter = txtProfessionListCodes.Text;
        if (txtCityCode.Text != string.Empty && txtCityCode.Text != "0")
        {
            cityCodes = txtCityCode.Text;
        }

        freeTextToSearch = txtFreeText.Text;

        int selectedSubUnitCode = -1;

        if (districtCodes == string.Empty)
            districtCodes = "-1";
        if (administrationCodes == string.Empty)
            administrationCodes = "-1";
        if (unitTypeCodes == string.Empty)
            unitTypeCodes = "-1";
        if (ddlSubUnitType.Visible == true)
        {
            selectedSubUnitCode = Convert.ToInt32(ddlSubUnitType.SelectedValue);
        }

        BindRemarks( districtCodes, administrationCodes, populationSector, unitTypeCodes, selectedSubUnitCode, servicesParameter, cityCodes, freeTextToSearch);

        if (dsSweepingRemarks.Tables["currentRemarks"].Rows.Count == 0 &&
            dsSweepingRemarks.Tables["futureRemarks"].Rows.Count == 0 &&
            dsSweepingRemarks.Tables["historyRemarks"].Rows.Count == 0)
            trNoDataFound.Style.Add("display", "inline");
        else
            trNoDataFound.Style.Add("display", "none");

    }

    protected void btnEditRemark_Click(object sender, EventArgs e)
    {
        Button btnEditRemark = sender as Button;
        RelatedRemarkID = Convert.ToInt32(btnEditRemark.Attributes["RelatedRemarkID"]);

        SaveParametersFromControls();

        string URL = "~/Admin/UpdateSweepingRemarks.aspx?DistrictCode=" + sweepingRemarksParameters.DistrictCodes;
        URL += "&AdminClinicCode=" + sweepingRemarksParameters.AdministrationCodes;
        URL += "&UnitType=" + sweepingRemarksParameters.UnitTypeCodes;
        URL += "&SectorCode=" + sweepingRemarksParameters.PopulationSector;

        sessionParams.CallerUrl = "../Admin/HandleSweepingRemarks.aspx";
        SessionParamsHandler.SetSessionParams(sessionParams);

        Response.Redirect(URL);
    }

    void SaveParametersFromControls()
    {
        sweepingRemarksParameters = SessionParamsHandler.GetSweepingRemarksParameters();

        sweepingRemarksParameters.DistrictCodes = txtDistrictCodes.Text;
        sweepingRemarksParameters.DistrictNames = txtDistrictList.Text;
        sweepingRemarksParameters.AdministrationCodes = txtAdminCodes.Text;
        sweepingRemarksParameters.AdministrationNames = txtAdminList.Text;
        sweepingRemarksParameters.PopulationSector = ddlPopulationSectors.SelectedValue;
        sweepingRemarksParameters.UnitTypeCodes = txtUnitTypeListCodes.Text;
        sweepingRemarksParameters.UnitTypeNames = txtUnitTypeList.Text;
        sweepingRemarksParameters.RelatedRemarkID = RelatedRemarkID;

        sweepingRemarksParameters.CityCodes = txtCityCode.Text;
        sweepingRemarksParameters.CityName = txtCityName.Text;
        sweepingRemarksParameters.FreeText = txtFreeText.Text;

        SessionParamsHandler.SetSweepingRemarksParameters(sweepingRemarksParameters);
    }

    void SetParametersToControls()
    {
        sweepingRemarksParameters = SessionParamsHandler.GetSweepingRemarksParameters();

        txtDistrictCodes.Text = sweepingRemarksParameters.DistrictCodes;
        txtDistrictList.Text = sweepingRemarksParameters.DistrictNames;
        txtAdminCodes.Text = sweepingRemarksParameters.AdministrationCodes;
        txtAdminList.Text = sweepingRemarksParameters.AdministrationNames;
        if (sweepingRemarksParameters.PopulationSector != string.Empty)
            ddlPopulationSectors.SelectedValue = sweepingRemarksParameters.PopulationSector;
        txtUnitTypeListCodes.Text = sweepingRemarksParameters.UnitTypeCodes;
        txtUnitTypeList.Text = sweepingRemarksParameters.UnitTypeNames;
        txtCityCode.Text = sweepingRemarksParameters.CityCodes.ToString();
        txtCityName.Text = sweepingRemarksParameters.CityName;
        txtFreeText.Text = sweepingRemarksParameters.FreeText;
        txtProfessionListCodes.Text = sweepingRemarksParameters.ServicesParameter;
        txtProfessionList.Text = sweepingRemarksParameters.ServicesNameParameter;

        districtCodes = sweepingRemarksParameters.DistrictCodes;
        administrationCodes = sweepingRemarksParameters.AdministrationCodes;
        populationSector = sweepingRemarksParameters.PopulationSector;
        unitTypeCodes = sweepingRemarksParameters.UnitTypeCodes;
        subUnitType = sweepingRemarksParameters.SubUnitTypeCode;
        cityCodes = sweepingRemarksParameters.CityCodes;
        servicesParameter = sweepingRemarksParameters.ServicesParameter;
        freeTextToSearch = sweepingRemarksParameters.FreeText;
    }

    protected void btnDeleteRemark_Click(object sender, EventArgs e)
    {
        ImageButton btnDeleteRemark = sender as ImageButton;
        int RelatedRemarkID = Convert.ToInt32(btnDeleteRemark.Attributes["RelatedRemarkID"]);
        
        //SeferNet.BusinessLayer.ObjectDataSource.RemarkInfoBO bo = new SeferNet.BusinessLayer.ObjectDataSource.RemarkInfoBO();
        //bo.Delete(RelatedRemarkID);
        
        //--- new Sweeping DeptRemarks concept
        Facade applicFacade = Facade.getFacadeObject();
        applicFacade.DeleteDeptRemark(RelatedRemarkID);
        
        // after remark was deleted we need to refresh data on page
        SaveParametersFromControls();

        string URL = "~/Admin/HandleSweepingRemarks.aspx?DistrictCode=" + sweepingRemarksParameters.DistrictCodes;
        URL += "&AdminClinicCode=" + sweepingRemarksParameters.AdministrationCodes;
        URL += "&UnitTypeCode=" + sweepingRemarksParameters.UnitTypeCodes;
        URL += "&SectorCode=" + sweepingRemarksParameters.PopulationSector;

        Response.Redirect(URL, true);
    }

    private void BindRemarks(string districtCode, string administrationCode, string populationSector, string UnitTypeCode, 
                                    int subUnitTypeCode, string servicesParameter, string cityCodes, string freeText)
    { 
        dsSweepingRemarks = new DataSet();
        applicFacade.GetSweepingRemarks(ref dsSweepingRemarks, districtCode, administrationCode, populationSector, 
                                                UnitTypeCode, subUnitTypeCode, userPermittedDistrict, servicesParameter, cityCodes, freeText);

        dsSweepingRemarks.Tables[0].TableName = "currentRemarks";
        dsSweepingRemarks.Tables[1].TableName = "futureRemarks";
        dsSweepingRemarks.Tables[2].TableName = "historyRemarks";
        dsSweepingRemarks.Tables[3].TableName = "RemarkAttributes";

        gvRemarks_Current.DataSource = dsSweepingRemarks.Tables["currentRemarks"];
        gvRemarks_Future.DataSource = dsSweepingRemarks.Tables["futureRemarks"];
        gvRemarks_History.DataSource = dsSweepingRemarks.Tables["historyRemarks"];
        gvRemarks_Current.DataBind();
        gvRemarks_Future.DataBind();
        gvRemarks_History.DataBind();
        //if (dsSweepingRemarks.Tables["currentRemarks"].Rows.Count == 0 &&
        //    dsSweepingRemarks.Tables["futureRemarks"].Rows.Count == 0 &&
        //    dsSweepingRemarks.Tables["historyRemarks"].Rows.Count == 0)
        //    trNoDataFound.Style.Add("display", "inline");
        //else
        //    trNoDataFound.Style.Add("display", "none");
    }


    protected void gvRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int rowInd = e.Row.DataItemIndex;
            GridView thisGridView = (GridView)sender;
            string thisGridViewID = thisGridView.ID;
            DataRow currentRow;
            switch (thisGridViewID)
            {
                case "gvRemarks_History":
                    currentRow = dsSweepingRemarks.Tables["historyRemarks"].Rows[rowInd];
                    break;
                case "gvRemarks_Current":
                    currentRow = dsSweepingRemarks.Tables["currentRemarks"].Rows[rowInd];
                    break;
                case "gvRemarks_Future":
                    currentRow = dsSweepingRemarks.Tables["futureRemarks"].Rows[rowInd];
                    break;
                default:
                    currentRow = dsSweepingRemarks.Tables["currentRemarks"].Rows[rowInd];
                    break;
            }

			//---- imgNotShowInInternet
            Image imgNotShowInInternet = e.Row.FindControl("imgNotShowInInternet") as Image;
            if (Convert.ToInt32(currentRow["Internetdisplay"]) == 1)
            {
                //imgNotShowInInternet.Style.Add("display", "none");
                imgNotShowInInternet.Visible = false;
            }

			//---- btnExclusions
			ImageButton btnExclusions = e.Row.FindControl("btnExclusions") as ImageButton;
			if (Convert.ToInt32(currentRow["ExcludedDeptsCount"]) > 0)
			{
				btnExclusions.Style.Add("display", "inline");
				btnExclusions.Attributes.Add("onClick",
					"return OpenSweepingRemarkExclusions(" + currentRow["RelatedRemarkID"].ToString() + ")");
			}
			else
			{
				btnExclusions.Style.Add("display", "none");
			}

            GridView gvDistricts = e.Row.FindControl("gvDistricts") as GridView;
            GridView gvAdministration = e.Row.FindControl("gvAdministration") as GridView;
            GridView gvUnitType = e.Row.FindControl("gvUnitType") as GridView;
            GridView vgPopulationSector = e.Row.FindControl("vgPopulationSector") as GridView;
            GridView gvCities = e.Row.FindControl("gvCities") as GridView;
            GridView gvServices = e.Row.FindControl("gvServices") as GridView;

            DataTable tblDistricts = new DataTable();
            tblDistricts.Columns.Add("districtCode", typeof(Int32));
            tblDistricts.Columns.Add("districtName", typeof(string));

            DataTable tblAdministrations = new DataTable();
            tblAdministrations.Columns.Add("administrationCode", typeof(Int32));
            tblAdministrations.Columns.Add("AdministrationName", typeof(string));

            DataTable tblUnitTypes = new DataTable();
            tblUnitTypes.Columns.Add("UnitTypeCode", typeof(Int32));
            tblUnitTypes.Columns.Add("UnitTypeName", typeof(string));

            DataTable tblPopulationSectors = new DataTable();
            tblPopulationSectors.Columns.Add("populationSector", typeof(Int32));
            tblPopulationSectors.Columns.Add("PopulationSectorDescription", typeof(string));

            DataTable tblCities = new DataTable();
            tblCities.Columns.Add("cityCode", typeof(Int32));
            tblCities.Columns.Add("cityName", typeof(string));

            DataTable tblServices = new DataTable();
            tblServices.Columns.Add("serviceCode", typeof(Int32));
            tblServices.Columns.Add("ServiceDescription", typeof(string));

            Int32 currDistrictCode = 0;
            Int32 currAdministrationCode = 0;
            Int32 currUnitTypeCode = 0;
            Int32 currPopulationSector = 0;
            Int32 currCity = 0;
            Int32 currService = 0;

            DataView dvDistricts = new DataView(dsSweepingRemarks.Tables["RemarkAttributes"],
                "RelatedRemarkID = " + currentRow["RelatedRemarkID"], "districtName", DataViewRowState.OriginalRows);
            for (int i = 0; i < dvDistricts.Count; i++)
            {
                if (currDistrictCode != Convert.ToInt32(dvDistricts[i]["districtCode"]))
                {
                    currDistrictCode = Convert.ToInt32(dvDistricts[i]["districtCode"]);
                    tblDistricts.Rows.Add(Convert.ToInt32(dvDistricts[i]["districtCode"]), dvDistricts[i]["districtName"].ToString()); 
                }
            }
            gvDistricts.DataSource = tblDistricts;
            gvDistricts.DataBind();

            DataView dvAdministration = new DataView(dsSweepingRemarks.Tables["RemarkAttributes"],
                "RelatedRemarkID = " + currentRow["RelatedRemarkID"], "AdministrationName", DataViewRowState.OriginalRows);
            for (int i = 0; i < dvAdministration.Count; i++)
            {
                if (currAdministrationCode != Convert.ToInt32(dvAdministration[i]["administrationCode"]))
                {
                    currAdministrationCode = Convert.ToInt32(dvAdministration[i]["administrationCode"]);
                    tblAdministrations.Rows.Add(Convert.ToInt32(dvAdministration[i]["administrationCode"]), dvAdministration[i]["AdministrationName"].ToString()); 
                }
            }
            gvAdministration.DataSource = tblAdministrations;
            gvAdministration.DataBind();

            DataView dvUnitType = new DataView(dsSweepingRemarks.Tables["RemarkAttributes"],
                "RelatedRemarkID = " + currentRow["RelatedRemarkID"], "UnitTypeName", DataViewRowState.OriginalRows);
            for (int i = 0; i < dvUnitType.Count; i++)
            {
                if (currUnitTypeCode != Convert.ToInt32(dvUnitType[i]["UnitTypeCode"]))
                {
                    currUnitTypeCode = Convert.ToInt32(dvUnitType[i]["UnitTypeCode"]);
                    tblUnitTypes.Rows.Add(Convert.ToInt32(dvUnitType[i]["UnitTypeCode"]), dvUnitType[i]["UnitTypeName"].ToString()); 
                }
            }
            gvUnitType.DataSource = tblUnitTypes;
            gvUnitType.DataBind();

            DataView dvPopulationSector = new DataView(dsSweepingRemarks.Tables["RemarkAttributes"],
                "RelatedRemarkID = " + currentRow["RelatedRemarkID"], "PopulationSectorDescription", DataViewRowState.OriginalRows);
            for (int i = 0; i < dvPopulationSector.Count; i++)
            {
                if (currPopulationSector != Convert.ToInt32(dvPopulationSector[i]["populationSector"]))
                {
                    currPopulationSector = Convert.ToInt32(dvPopulationSector[i]["populationSector"]);
                    tblPopulationSectors.Rows.Add(Convert.ToInt32(dvPopulationSector[i]["populationSector"]), dvPopulationSector[i]["PopulationSectorDescription"].ToString()); 
                }
            }
            vgPopulationSector.DataSource = tblPopulationSectors;
            vgPopulationSector.DataBind();

            DataView dvCity = new DataView(dsSweepingRemarks.Tables["RemarkAttributes"],
                "RelatedRemarkID = " + currentRow["RelatedRemarkID"], "cityName", DataViewRowState.OriginalRows);
            for (int i = 0; i < dvCity.Count; i++)
            {
                if (currCity != Convert.ToInt32(dvCity[i]["cityCode"]))
                {
                    currCity = Convert.ToInt32(dvCity[i]["cityCode"]);
                    tblCities.Rows.Add(Convert.ToInt32(dvCity[i]["cityCode"]), dvCity[i]["cityName"].ToString()); 
                }
            }
            gvCities.DataSource = tblCities;
            gvCities.DataBind();

            DataView dvServices = new DataView(dsSweepingRemarks.Tables["RemarkAttributes"],
                "RelatedRemarkID = " + currentRow["RelatedRemarkID"], "ServiceDescription", DataViewRowState.OriginalRows);
            for (int i = 0; i < dvServices.Count; i++)
            {
                if (currService != Convert.ToInt32(dvServices[i]["serviceCode"]))
                {
                    currService = Convert.ToInt32(dvServices[i]["serviceCode"]);
                    tblServices.Rows.Add(Convert.ToInt32(dvServices[i]["serviceCode"]), dvServices[i]["ServiceDescription"].ToString()); 
                }
            }
            gvServices.DataSource = tblServices;
            gvServices.DataBind();

            Label lblSubUnitType = e.Row.FindControl("lblSubUnitType") as Label;

            DataRow[] rowsArr = dsSweepingRemarks.Tables["RemarkAttributes"].Select("RelatedRemarkID=" + currentRow["RelatedRemarkID"]);
            if (rowsArr.Length > 0)
                lblSubUnitType.Text = rowsArr[0]["SubUnitTypeName"].ToString();
        }
    }

    protected void btnAddRemark_Click(object sender, EventArgs e)
    {
        districtCodes = txtDistrictCodes.Text;
        administrationCodes = txtAdminCodes.Text;
        administrationNames = txtAdminList.Text;
        unitTypeCodes = txtUnitTypeListCodes.Text;
        unitTypeNames = txtUnitTypeList.Text;
        populationSector = ddlPopulationSectors.SelectedValue;
        servicesParameter = txtProfessionListCodes.Text;
        servicesNameParameter = txtProfessionList.Text;

        if (txtCityCode.Text != string.Empty)
        {
            cityCodes = txtCityCode.Text;
            cityName = txtCityName.Text;
        }
        else
        {
            cityCodes = string.Empty;
            cityName = string.Empty;
        }

        
        if (ddlSubUnitType.Visible)
        {
            subUnitType = Convert.ToInt32(ddlSubUnitType.SelectedValue);
        }

        sweepingRemarksParameters = SessionParamsHandler.GetSweepingRemarksParameters();

        sweepingRemarksParameters.DistrictCodes = districtCodes;
        sweepingRemarksParameters.DistrictNames = txtDistrictList.Text;
        sweepingRemarksParameters.AdministrationCodes = administrationCodes;
        sweepingRemarksParameters.AdministrationNames = administrationNames;
        sweepingRemarksParameters.UnitTypeCodes = unitTypeCodes;
        sweepingRemarksParameters.UnitTypeNames = unitTypeNames;
        sweepingRemarksParameters.PopulationSector = populationSector;
        sweepingRemarksParameters.CityCodes = cityCodes;
        sweepingRemarksParameters.CityName = cityName;
        sweepingRemarksParameters.ServicesParameter = servicesParameter;
        sweepingRemarksParameters.ServicesNameParameter = servicesNameParameter;

        SessionParamsHandler.SetSweepingRemarksParameters(sweepingRemarksParameters);

        string URL = "~/Admin/AddRemark.aspx?districtCode=" + districtCodes;
        URL += "&administrationCode=" + administrationCodes;
        URL += "&UnitTypeCode=" + unitTypeCodes;
        URL += "&populationSector=" + populationSector;
        URL += "&subUnitType=" + subUnitType;
        URL += "&cityCode=" + cityCodes.ToString();
        URL += "&servicesParameter=" + servicesParameter;
        

        Response.Redirect(URL);
    }

}
