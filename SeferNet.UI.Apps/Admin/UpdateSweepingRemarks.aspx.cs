using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls; 
using System.Data;

using System.Text.RegularExpressions; 

using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;
using System.Collections;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager; 

public partial class UpdateSweepingRemarks : AdminBasePage
{
    Facade applicFacade;

    SweepingRemarksParameters  sweepingRemarksParameters;
    SessionParams sessionParams;

    UserInfo currentUser;

    DataSet dsSweepingRemark;
    private RemarkManager remarkManager = new RemarkManager();

    #region Properties

    public DataTable AllRemarks
    {
        get
        {
            if (ViewState["AllRemarks"] != null)
            {
                return (DataTable)ViewState["AllRemarks"];
            }
            else
            {
                return null;
            }
        }
        set
        {
            ViewState["AllRemarks"] = value;
        }
    }

    public DataTable SelectedRemarks
    {
        get
        {
            if (ViewState["SelectedRemarks"] != null)
            {
                return (DataTable)ViewState["SelectedRemarks"];
            }
            else
            {
                return null;
            }
        }
        set
        {
            ViewState["SelectedRemarks"] = value;
        }
    }

    public string CurrRemarkFormatText
    {
        get
        {
            if (ViewState["currRemarkText"] != null)
            {
                return ViewState["currRemarkText"].ToString();
            }
            else
            {
                return null;
            }
        }
        set
        {
            ViewState["currRemarkText"] = value;
        }
    }

    public int CurrRemarkID
    {
        get
        {
            if (ViewState["currRemarkID"] != null)
            {
                return (int)ViewState["currRemarkID"];
            }
            else
            {
                return -1;
            }
        }
        set
        {
            ViewState["currRemarkID"] = value;
        }
    }

    #endregion

    string districtCodes = string.Empty;
    string districtNames = string.Empty;
    string administrationCodes = string.Empty;
    string administrationNames = string.Empty;
    string unitTypeCodes = string.Empty;
    string unitTypeNames = string.Empty;
    string populationSector = string.Empty;
    int userPermittedDistrict = 0;
    private string cityCodes;
    private string servicesParameter;

    protected override void CreateChildControls()
    {
        base.CreateChildControls();

        if (IsPostBack)
        {
            SetEditPlaceHolder();
        }
    }

    private void SetEditPlaceHolder()
    {
        if (ViewState["currRemarkText"] != null)
        {
            SetEditControlsForText(ref plhEditRemark, remarkManager.SplitRemarkTextByFormat(ViewState["currRemarkText"].ToString()));
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        currentUser = Session["currentUser"] as UserInfo;

        sessionParams = SessionParamsHandler.GetSessionParams();

        sweepingRemarksParameters = SessionParamsHandler.GetSweepingRemarksParameters();

        if (!IsPostBack)
        {
            if (sweepingRemarksParameters != null)
            {
                SetParametersToControls();
            }

            if (districtCodes == string.Empty)
                districtCodes = "-1";
            if (administrationCodes == string.Empty)
                administrationCodes = "-1";
            if (unitTypeCodes == string.Empty)
                unitTypeCodes = "-1";
            if (populationSector == string.Empty)
                populationSector = "-1";
        }
        else
        {
            HandleSubUnitType(null);            
            SetParametersToControlsPostBack();
        }

        autoCompleteAdmins.ContextKey = txtDistrictCodes.Text;
        autoCompleteCities.ContextKey = txtDistrictCodes.Text;

        SetPermittedDistrict();
    }

    private void HandleSubUnitType(int? selectedSubUnitTypeCode)
    {

        if (!string.IsNullOrEmpty(txtUnitTypeListCodes.Text))
        {
            string[] codesArr = txtUnitTypeListCodes.Text.Split(',');

            if (codesArr.Length == 1 && ddlSubUnitType.Visible == false)
            {
                ddlSubUnitType.Items.Clear();

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

                DataView dvSubUnitType = new DataView(tblSubUnitType, "UnitTypeCode = " + codesArr[0], "subUnitTypeName", DataViewRowState.OriginalRows);

                if (dvSubUnitType.Count > 0)
                {
                    lblSubUnitType.Visible = true;
                    ddlSubUnitType.Visible = true;

                    ddlSubUnitType.DataSource = dvSubUnitType;
                    ddlSubUnitType.DataBind();

                    ListItem lItem = new ListItem("הכל", "-1");
                    ddlSubUnitType.Items.Insert(0, lItem);

                    if (selectedSubUnitTypeCode != null)
                    {
                        ddlSubUnitType.SelectedValue = selectedSubUnitTypeCode.ToString();
                    }
                }
                else
                {
                    lblSubUnitType.Visible = ddlSubUnitType.Visible = false;
                }
            }
            else
            {
                lblSubUnitType.Visible = ddlSubUnitType.Visible = false;
            }
        }
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
        //sweepingRemarksParameters.RelatedRemarkID = RelatedRemarkID;

        SessionParamsHandler.SetSweepingRemarksParameters(sweepingRemarksParameters);
    }

    void SetPermittedDistrict()
    {
        if (!currentUser.IsAdministrator)
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
        }
        //if (!currentUser.IsAdministrator)
        //{
        //    ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
        //    DataTable tblDist = cacheHandler.getCachedDataTable(eCachedTables.View_AllDistricts.ToString());

        //    foreach (DataRow dr in tblDist.Rows)
        //    {
        //        if (Convert.ToInt32(dr["districtCode"]) == currentUser.DistrictCode)
        //        {
        //            btnDistrictsPopUp.Style.Add("display", "none");
        //            txtDistrictCodes.Text = userPermittedDistrict.ToString();
        //            txtDistrictList.Text = dr["districtName"].ToString();
        //            txtDistrictList.ReadOnly = true;
        //        }
        //    }
        //}
    }

    void SetParametersToControls()
    {
        applicFacade = Facade.getFacadeObject();
        this.SetRemarkAreasByRelatedRemarkID(sweepingRemarksParameters.RelatedRemarkID);

        dsSweepingRemark = applicFacade.GetSweepingRemarkByID(sweepingRemarksParameters.RelatedRemarkID);

        if (dsSweepingRemark.Tables[0].Rows.Count == 1)
        {
            DataRow dr = dsSweepingRemark.Tables[0].Rows[0];
            UIHelper.BindDropDownToCachedTable(ddlPopulationSectors, "PopulationSectors", "PopulationSectorDescription");

            txtValidFrom.Text = dr["ValidFrom"].ToString();
            txtValidTo.Text = dr["ValidTo"].ToString();
            txtRemarkActiveFrom.Text = dr["ActiveFrom"].ToString();
            txtDicRemarkID.Text = dr["DicRemarkID"].ToString();
            cbInternetDisplay.Checked = Convert.ToBoolean(dr["Internetdisplay"]);
            txtOpenNow.Text = Convert.ToInt16(dr["OpenNow"]).ToString();
            txtShowForPreviousDaysForSelectedRemark.Text = Convert.ToInt16(dr["ShowForPreviousDays"]).ToString();
            if (cbInternetDisplay.Checked && txtOpenNow.Text == "1")
            {
                lblAlert.Style.Add("display", "block");
            }
            else
            { 
                lblAlert.Style.Add("display", "none");            
            }

            ViewState["RelevantForSystemManager"] = (bool)dr["RelevantForSystemManager"];
            if ((bool)ViewState["RelevantForSystemManager"] == false)
            { 
                string[] strSplitted = dr["RemarkText"].ToString().Split('#');
                ArrayList lblValues = new ArrayList();
                ArrayList txtValues = new ArrayList();

                for (int i = 0; i < strSplitted.Length; i++)
                {
                    if((i/2)*2 == i)
                    {
                        lblValues.Add(strSplitted[i]);
                    }
                    else
                    {
                        if (strSplitted[i].IndexOf('~') > 0)
                        {
                            txtValues.Add(strSplitted[i].Substring(0, strSplitted[i].IndexOf('~')));
                        }
                        else
                        { 
                            txtValues.Add(strSplitted[i]);                        
                        }

                    }
                }

                string[] strSplitted1 = new string[lblValues.Count];
                string[] strSplitted2 = new string[txtValues.Count];
                for (int i = 0; i < lblValues.Count; i++)
                {
                    strSplitted1[i] = lblValues[i].ToString();
                }
                for (int i = 0; i < txtValues.Count; i++)
                {
                    strSplitted2[i] = txtValues[i].ToString();
                }   

                SetEditControlsForText(ref plhEditRemark, strSplitted1, strSplitted2);
                txtRemarkFormatedText.Text = dr["RemarkText"].ToString();                
            }
            else
            {
                plhEditRemark.Visible = false;
                txtRemarkText.Visible = true;

                txtRemarkText.Text = dr["RemarkText"].ToString();
                txtRemarkFormatedText.Text = dr["RemarkText"].ToString();

                //btnSave.Attributes.Remove("OnClientClick");
                //btnSave.Attributes.Add("OnClientClick", "SaveRTFRemarkInHidden(); ShowProgressBar();");

            }
        }
    }

    void SetRemarkAreasByRelatedRemarkID(int relatedRemarkID)
    {
        DataSet ds = applicFacade.GetSweepingRemarkAreasByRelatedRemarkID(relatedRemarkID);

        txtDistrictCodes.Text = string.Empty;
        txtDistrictList.Text = string.Empty;
        for (int i = 0; i < ds.Tables["Districts"].Rows.Count; i++)
        {
            if (txtDistrictCodes.Text != string.Empty)
                txtDistrictCodes.Text = txtDistrictCodes.Text + ",";
            txtDistrictCodes.Text = txtDistrictCodes.Text + ds.Tables["Districts"].Rows[i]["districtCode"].ToString();
            if (txtDistrictList.Text != string.Empty)
                txtDistrictList.Text = txtDistrictList.Text + ",";
            txtDistrictList.Text = txtDistrictList.Text + ds.Tables["Districts"].Rows[i]["districtName"].ToString();
        }

        txtAdminCodes.Text = string.Empty;
        txtAdminList.Text = string.Empty;
        for (int i = 0; i < ds.Tables["Administrations"].Rows.Count; i++)
        {
            if (ds.Tables["Administrations"].Rows[i]["administrationCode"].ToString() != "-1")
            {
                if (txtAdminCodes.Text != string.Empty)
                    txtAdminCodes.Text = txtAdminCodes.Text + ",";
                txtAdminCodes.Text = txtAdminCodes.Text + ds.Tables["Administrations"].Rows[i]["administrationCode"].ToString();
                if (txtAdminList.Text != string.Empty)
                    txtAdminList.Text = txtAdminList.Text + ",";
                txtAdminList.Text = txtAdminList.Text + ds.Tables["Administrations"].Rows[i]["AdministrationName"].ToString();
            }
        }

        txtUnitTypeListCodes.Text = string.Empty;
        txtUnitTypeList.Text = string.Empty;
        for (int i = 0; i < ds.Tables["UnitTypes"].Rows.Count; i++)
        {
            if (ds.Tables["UnitTypes"].Rows[i]["UnitTypeCode"].ToString() != "-1")
            {
                if (txtUnitTypeListCodes.Text != string.Empty)
                    txtUnitTypeListCodes.Text = txtUnitTypeListCodes.Text + ",";
                txtUnitTypeListCodes.Text = txtUnitTypeListCodes.Text + ds.Tables["UnitTypes"].Rows[i]["UnitTypeCode"].ToString();
                if (txtUnitTypeList.Text != string.Empty)
                    txtUnitTypeList.Text = txtUnitTypeList.Text + ",";
                txtUnitTypeList.Text = txtUnitTypeList.Text + ds.Tables["UnitTypes"].Rows[i]["UnitTypeName"].ToString();
            }
        }

        if (ds.Tables["UnitTypes"].Rows.Count > 0
            && ds.Tables["UnitTypes"].Rows[0]["SubUnitTypeCode"] != DBNull.Value &&  ds.Tables["UnitTypes"].Rows.Count == 1)
        {
            int? subUnitType = Convert.ToInt32(ds.Tables["UnitTypes"].Rows[0]["SubUnitTypeCode"]);

            HandleSubUnitType(subUnitType);
        }

        ddlPopulationSectors.SelectedValue = "-1";
        if (ds.Tables["PopulationSectors"].Rows.Count > 0
            && ds.Tables["PopulationSectors"].Rows[0]["populationSector"].ToString() != "-1")
        {
            ddlPopulationSectors.SelectedValue = ds.Tables["PopulationSectors"].Rows[0]["populationSector"].ToString();
        }

		txtExcludedDeptCodes.Text = string.Empty;
		txtExcludedDeptList.Text = string.Empty;
		for (int i = 0; i < ds.Tables["ExcludedDepts"].Rows.Count; i++)
		{
			if (txtExcludedDeptCodes.Text != string.Empty)
				txtExcludedDeptCodes.Text = txtExcludedDeptCodes.Text + ",";
			txtExcludedDeptCodes.Text = txtExcludedDeptCodes.Text + ds.Tables["ExcludedDepts"].Rows[i]["ExcludedDeptCode"].ToString();
			if (txtExcludedDeptList.Text != string.Empty)
				txtExcludedDeptList.Text = txtExcludedDeptList.Text + ",";
			txtExcludedDeptList.Text = txtExcludedDeptList.Text + ds.Tables["ExcludedDepts"].Rows[i]["ExcludedDeptName"].ToString();
		}

        txtCityCode.Text = string.Empty;
        txtCityName.Text = string.Empty;
        for (int i = 0; i < ds.Tables["Cities"].Rows.Count; i++)
        {
            if (txtCityCode.Text != string.Empty)
                txtCityCode.Text = txtCityCode.Text + ",";
            txtCityCode.Text = txtCityCode.Text + ds.Tables["Cities"].Rows[i]["CityCode"].ToString();
            if (txtCityName.Text != string.Empty)
                txtCityName.Text = txtCityName.Text + ",";
            txtCityName.Text = txtCityName.Text + ds.Tables["Cities"].Rows[i]["CityName"].ToString();
        }

        txtProfessionListCodes.Text = string.Empty;
        txtProfessionList.Text = string.Empty;
        for (int i = 0; i < ds.Tables["Services"].Rows.Count; i++)
        {
            if (txtProfessionListCodes.Text != string.Empty)
                txtProfessionListCodes.Text = txtProfessionListCodes.Text + ",";
            txtProfessionListCodes.Text = txtProfessionListCodes.Text + ds.Tables["Services"].Rows[i]["ServiceCode"].ToString();
            if (txtProfessionList.Text != string.Empty)
                txtProfessionList.Text = txtProfessionList.Text + ",";
            txtProfessionList.Text = txtProfessionList.Text + ds.Tables["Services"].Rows[i]["ServiceDescription"].ToString();
        }

        txtDistrictListClone.Text = txtDistrictList.Text;
    }

    void SetParametersToControlsPostBack()
    {
        if (ViewState["RelevantForSystemManager"] == null || (bool)ViewState["RelevantForSystemManager"] == false)
        {

            string[] strSplitted = txtRemarkFormatedText.Text.Split('#');
            ArrayList lblValues = new ArrayList();
            ArrayList txtValues = new ArrayList();

            for (int i = 0; i < strSplitted.Length; i++)
            {
                if ((i / 2) * 2 == i)
                {
                    lblValues.Add(strSplitted[i]);
                }
                else
                {
                    txtValues.Add(strSplitted[i]);
                }
            }

            string[] strSplitted1 = new string[lblValues.Count];
            string[] strSplitted2 = new string[txtValues.Count];
            for (int i = 0; i < lblValues.Count; i++)
            {
                strSplitted1[i] = lblValues[i].ToString();
            }
            for (int i = 0; i < txtValues.Count; i++)
            {
                strSplitted2[i] = txtValues[i].ToString();
            }

            SetEditControlsForText(ref plhEditRemark, strSplitted1, strSplitted2);
        }
        else 
        {
            txtRemarkFormatedText.Text = txtRemarkText.Text;
        }
    }

    private PlaceHolder SetEditControlsForText(ref PlaceHolder plh, string[] arrLabels)
    {
        plh.Controls.Clear();   // clear the place holder controls,to prevent double controls id's

        int id = 1;

        if (arrLabels.Length > 0)
        {
            for (int i = 0; i < arrLabels.Length; i++)
            {
                Label label = new Label();
                label.Text = arrLabels[i];
                label.ID = "label" + id.ToString();
                plh.Controls.Add(label);

                if (i < arrLabels.Length - 1)
                {
                    TextBox text = new TextBox();
                    text.Width = Unit.Pixel(50);
                    text.ID = "text" + id.ToString();
                    plh.Controls.Add(text);
                }

                id++;
            }
        }

        return plh;
    }

    private PlaceHolder SetEditControlsForText(ref PlaceHolder plh, string[] arrLabels, string[] arrTextBoxes)
    {
        plh.Controls.Clear();   // clear the place holder controls,to prevent double controls id's

        int id = 1;
        int maxwidth = 800;

        if (arrLabels.Length > 0)
        {
            for (int i = 0; i < arrLabels.Length; i++)
            {
                Label label = new Label();
                label.Text = arrLabels[i];
                label.ID = "label" + id.ToString();
                plh.Controls.Add(label);

                if (i < arrTextBoxes.Length)
                {
                    TextBox text = new TextBox();
                    if (arrTextBoxes.Length == 1)
                    {
                        text.Width = Unit.Pixel((arrTextBoxes[i].Length) * 7);
                        if (((arrTextBoxes[i].Length) * 7) > maxwidth)
                        {
                            text.Width = Unit.Pixel(maxwidth);
                            text.TextMode = TextBoxMode.MultiLine;
                            text.Rows = 3;
                        }
                    }
                    else 
                    {
                        int width = (int)(arrTextBoxes[i].Length * 6);
                        if (width > maxwidth)
                            width = maxwidth;
                        text.Width = Unit.Pixel(width);
                    }

                    text.ID = "text" + id.ToString();
                    text.Text = arrTextBoxes[i];
                    plh.Controls.Add(text);
                }

                id++;
            }
        }

        return plh;
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        sweepingRemarksParameters = SessionParamsHandler.GetSweepingRemarksParameters();
        sweepingRemarksParameters.RemarkID = 0;
        SessionParamsHandler.SetSweepingRemarksParameters(sweepingRemarksParameters);

        Response.Redirect("HandleSweepingRemarks.aspx");
    }

    private void UpdateSweepingDeptRemark()
    {
        List<string> values = new List<string>();
        DateTime? dateFrom = null; //DateTime dateFrom = DateTime.MinValue;
        DateTime? dateTo = null; //DateTime dateTo = DateTime.MinValue;
        DateTime? dateShowFrom = null; //DateTime dateTo = DateTime.MinValue;
        bool result = true;

        this.Page.Validate();
        if (Page.IsValid)
        {
            if (!string.IsNullOrEmpty(txtValidFrom.Text))
            {
                dateFrom = Convert.ToDateTime(txtValidFrom.Text);
            }

            if (!string.IsNullOrEmpty(txtValidTo.Text))
            {
                dateTo = Convert.ToDateTime(txtValidTo.Text);
            }

            if (!string.IsNullOrEmpty(txtRemarkActiveFrom.Text))
            {
                dateShowFrom = Convert.ToDateTime(txtRemarkActiveFrom.Text);
            }

            if (txtCityCode.Text == string.Empty)
            {
                cityCodes = string.Empty;
            }
            else
            {
                cityCodes = txtCityCode.Text;
            }


            Facade applicFacade = Facade.getFacadeObject();

            result = applicFacade.UpdateSweepingDeptRemark(
                            this.sweepingRemarksParameters.RelatedRemarkID,
                            Convert.ToInt32(this.txtDicRemarkID.Text),
                            this.txtRemarkFormatedText.Text,
                            this.txtDistrictCodes.Text,
                            this.txtAdminCodes.Text,
                            this.txtUnitTypeListCodes.Text,
                            this.ddlSubUnitType.SelectedValue,
                            this.ddlPopulationSectors.SelectedValue,
							this.txtExcludedDeptCodes.Text,
                            cityCodes,
							this.txtProfessionListCodes.Text,
                            dateFrom,
                            dateTo,
                            dateShowFrom,
                            this.cbInternetDisplay.Checked);
        }
        if (result)
        {
            //SaveParametersFromControls();
            Response.Redirect("HandleSweepingRemarks.aspx");
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        this.UpdateSweepingDeptRemark();
    }

    //// to delete - old version
    //protected void btnSave_Click(object sender, EventArgs e)
    //{
    //    List<string> values = new List<string>();
    //    DateTime dateFrom = DateTime.MinValue, dateTo = DateTime.MinValue;
    //    bool result = true;

    //    Page.Validate();
    //    if (Page.IsValid)
    //    {
    //        if (!string.IsNullOrEmpty(txtValidFrom.Text))
    //        {
    //            dateFrom = Convert.ToDateTime(txtValidFrom.Text);
    //        }

    //        if (!string.IsNullOrEmpty(txtValidTo.Text))
    //        {
    //            dateTo = Convert.ToDateTime(txtValidTo.Text);
    //        }

    //        bool displayOnInternet = cbInternetDisplay.Checked;

    //        string remarkText = txtRemarkFormatedText.Text;
    //        dicRemarkID = Convert.ToInt32(txtDicRemarkID.Text);
    //        CurrRemarkID = sweepingRemarksParameters.RelatedRemarkID;

    //        string[] arr;

    //        if (txtDistrictCodes.Text != string.Empty)
    //        {
    //            arr = txtDistrictCodes.Text.Split(',');
    //            districtsArr = new int[arr.Length];
    //            for (int i = 0; i < arr.Length; i++)
    //            {
    //                districtsArr[i] = Convert.ToInt32(arr[i]);
    //            }
    //        }

    //        if (txtAdminCodes.Text != string.Empty)
    //        {
    //            arr = txtAdminCodes.Text.Split(',');
    //            administrationCodesArr = new int[arr.Length];
    //            for (int i = 0; i < arr.Length; i++)
    //            {
    //                administrationCodesArr[i] = Convert.ToInt32(arr[i]);
    //            }
    //        }

    //        if (txtUnitTypeListCodes.Text != string.Empty)
    //        {
    //            arr = txtUnitTypeListCodes.Text.Split(',');
    //            unitTypesArr = new int[arr.Length];
    //            for (int i = 0; i < arr.Length; i++)
    //            {
    //                unitTypesArr[i] = Convert.ToInt32(arr[i]);
    //            }
    //        }

    //        if (Convert.ToInt32(ddlPopulationSectors.SelectedValue) > 0)
    //        {
    //            populationSectorsArr = new int[1];
    //            populationSectorsArr[0] = Convert.ToInt32(ddlPopulationSectors.SelectedValue);
    //        }

    //        UserInfo user = Session["currentUser"] as UserInfo;
    //        Remarks rem = new Remarks();


    //        int subUnitTypeCode = -1;
    //        if (!string.IsNullOrEmpty(ddlSubUnitType.SelectedValue))
    //        {
    //            subUnitTypeCode = Convert.ToInt32(ddlSubUnitType.SelectedValue);
    //        }

    //        result = rem.InsertSweepingRemarksViaUpdate_Transaction(CurrRemarkID, dicRemarkID, remarkText,
    //                        districtsArr, unitTypesArr, subUnitTypeCode, populationSectorsArr, administrationCodesArr, dateFrom, dateTo, 
    //                        displayOnInternet);
    //    }
    //    if (result == true)
    //    {
    //        //SaveParametersFromControls();
    //        Response.Redirect("HandleSweepingRemarks.aspx");
    //    }
    //}

   
}
