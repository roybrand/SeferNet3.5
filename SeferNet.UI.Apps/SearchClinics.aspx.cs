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
using SeferNet.UI;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using System.Text;
using Clalit.SeferNet.GeneratedEnums;
using MapsManager;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;
using SeferNet.Globals;
using Clalit.SeferNet.Services;
using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using System.Collections.Generic;
using System.Linq;


public partial class Public_SearchClinics : System.Web.UI.Page, ISearchPageController
{
    private DataSet dsClinics;
    private string currentDept = string.Empty;
    SessionParams sessionParams;    
    ClinicSearchParameters clinicSearchParameters;
    bool isMushlamSelected;
    bool isHospitalSelected;
    ClinicSearchParametersForMushlamServices clinicSearchParametersForMushlamServices = new ClinicSearchParametersForMushlamServices();
    

    public int CurrentMushlamServiceCode 
    {
        get
        {
            if (ViewState["currentMushlamServiceCode"] != null)
            {
                return (int)ViewState["currentMushlamServiceCode"];
            }
            return 0;
        }
        set
        {
            ViewState["currentMushlamServiceCode"] = value;
        }
    }

    public string[] LastSearchMushlamServices
    {
        get
        {
            if (ViewState["LastSearchMushlamServices"] != null)
                return (string[])ViewState["LastSearchMushlamServices"];
            return null;
        }
        set
        {
            ViewState["LastSearchMushlamServices"] = value;
        }
    }

    protected enum Tabs
    {
        General,
        Agreement,
        Refund,
        SalServices,
        Models
    }


    #region Page Events


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        RegisterMasterControlsEvents();

        //transfterring control from  master page to the current page - by removing it from the master and adding it to 
        // a place holder
        //this code MUST BE CALLED every time the page loads
        phButtonsShowHideMap.Controls.Add(Master.GetDivButtonShowHide());

        if (IsPostBack == false)
        {
            //flag to hide map
            Master.IsAllowShowMap_PageCondition = false;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        Master.PagingControlsController = new SortingAndPagingInfoController(this, btnFirstPage, btnPreviousPage, btnNextPage, btnLastPage,
                                                                                        lblTotalRecords, lblPageFromPages, ddlCarrentPage);
        if (!IsPostBack)
        {
            handleBinding();
            ddlStatus.SelectedValue = (Convert.ToInt32(clinicStatus.Active)).ToString();

            this.InitializeViewFromGlobalResources();//julia
            HandleSubUnitTypes();
        }

        if (cbHandleSubUnitTypes.Checked)
        {
            HandleSubUnitTypes();
            cbHandleSubUnitTypes.Checked = false;
            btnUnitTypeListPopUp.Focus();
        }

        // clear selected TAB at "ZoomClinic.aspx"       
        sessionParams = SessionParamsHandler.GetSessionParams();
        sessionParams.CurrentTab_ZoomClinic = null;
        SessionParamsHandler.SetSessionParams(sessionParams);

        if (!IsPostBack)
        {
            if (Request.QueryString["RepeatSearch"] != null)
            {
                RepeatLastSearch();             
            }
            else
            {
                ViewState["clinicSearchParameters"] = null;
            }
        }

        /* Set the context key with the Shiuch - Community is the default */
        AutoCompleteClinicName.ContextKey = Master.TxtDistrictCodes.Text + "~" + new UserManager().GetLoggedinUserNameWithPrefix() + "~Community";
        AutoClalitServiceDesc.ContextKey = Master.TxtDistrictCodes.Text + "~" + new UserManager().GetLoggedinUserNameWithPrefix() + "~Community";
        
        txtURLforResolutionSetUp.Text = GetURLforResolutionRemark();

        ////this occurs when we click on a grid row map image
        //// it suppose to focus on the address  in the map of the clicked address
        //SearchPageHelper.HandleRowMapImageClick_IfRequired(gvClinicsList, Master );

        Master.SetTabIndexes(new WebControl[] { txtClinicName, Master.TxtDistrictList, Master.TxtCity, txtProfessionList,
                                            txtUnitTypeList, txtHandicappedFacilitiesList, ddlPopulationSectors, 
                                            txtClinicCode, ddlStatus, Master.TxtFromHour, Master.TxtToHour, Master.TxtAtHour}, null);


        SetExtendedSearchMode();

        if (!IsPostBack)
        {
            SearchViaOutsideURL();
        }

    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        SessionParamsHandler.SetLastSearchPageURL("SearchClinics.aspx");

        foreach (RepeaterItem myItem in rptSearchResults.Items)
        {
            if (myItem.ItemType == ListItemType.AlternatingItem
                || myItem.ItemType == ListItemType.Item)
            {
                ImageButton btnShowProviders = myItem.FindControl("btnShowProviders") as ImageButton;
                Label lblNumOfSuppliers = myItem.FindControl("lblNumOfSuppliers") as Label;
                Label lblEmptyLabel = myItem.FindControl("lblEmptyLabel") as Label;

                if (Convert.ToInt32(lblNumOfSuppliers.Text) == 0)
                    btnShowProviders.Visible = false;
                else
                    lblEmptyLabel.Visible = false;

            }
        }

        if (txtProfessionList.Text == string.Empty)
            divReceiveGuests.Disabled = true;
        else
        {
            divReceiveGuests.Disabled = true;

            string ServicesToReceiveGuests = txtProfessionsRelevantForReceivigGuests.Text;
            var relevantServices = ServicesToReceiveGuests.Split(',');
            var selectedServices = txtProfessionListCodes.Text.Split(',');

            for (int i = 0; i < relevantServices.Length; i++)
            {
                for (int ii = 0; ii < selectedServices.Length; ii++)
                {
                    if (relevantServices[i] == selectedServices[ii])
                    {
                        divReceiveGuests.Disabled = false;
                    }
                }
            }
        }

    }

    protected void btnShowProviders_Click(object sender, ImageClickEventArgs e)
    {
        Master.ResetSortingAndPaging(tdSortingButtons, null);

        ImageButton btnShowProviders = sender as ImageButton;
        string[] sParams = btnShowProviders.CommandArgument.Split('_');

        clinicSearchParametersForMushlamServices.ServiceCodeForMuslam = sParams[0].ToString();
        clinicSearchParametersForMushlamServices.GroupCode = Convert.ToInt32(sParams[1].ToString());
        clinicSearchParametersForMushlamServices.SubGroupCode = Convert.ToInt32(sParams[2].ToString());
        clinicSearchParametersForMushlamServices.ServiceDescriptionForMuslam = sParams[3].ToString();

        Session["ClinicSearchParametersForMushlamServices"] = clinicSearchParametersForMushlamServices;
        Session["divMushlamServices_ScrollTopPosition"] = txtScrollTop.Text.ToString();

        LoadDataAndPopulate();

        ToggleTabs(false);
    }

    private void SearchViaOutsideURL()
    {
        bool execute = false;

        if (!string.IsNullOrEmpty(this.Request.QueryString["ClinicType"]))
        {
            this.txtUnitTypeListCodes.Text = this.Request.QueryString["ClinicType"].ToString();
            int unitTypeCode = 0;
            bool result = Int32.TryParse(Request.QueryString["ClinicType"].ToString(), out unitTypeCode);
            if (result == false)
                return;

            Facade applicFacade = Facade.getFacadeObject();
            DataSet ds = applicFacade.GetUnitTypeWithAttributes(unitTypeCode);
            if (ds.Tables[0].Rows.Count > 0)
                txtUnitTypeList.Text = ds.Tables[0].Rows[0]["UnitTypeName"].ToString();

            execute = true;
        }

        if (execute == false)
            return;

        if (ValidateForm())
        {
            Session["ClinicSearchParametersForMushlamServices"] = null;

            LastSearchMushlamServices = null;
            Master.uniqueSearchParamater = Guid.NewGuid().ToString();
            Master.ResetSortingAndPaging(tdSortingButtons, null);
            Master.ResetLastSelectedRowIndex();

            ShowGridAndRelatedControls();

            // reset data recieved indicators
            hdnDeptsDataRecieved.Value = hdnMushlamDataRecieved.Value = string.Empty;


            // if only mushlam selected - load mushlam tab
            if (isMushlamSelected && Master.GetSelectedSearchMode().Count == 1)
            {
                SearchMushlam();
            }
            else
            {
                // populate depts data
                LoadDataAndPopulate();

                SetMushlamTabVisibilityOnSearch();
            }

        }
    }
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (ValidateForm())
        {
            Session["ClinicSearchParametersForMushlamServices"] = null;
            Session["RenewSearch"] = true;

            LastSearchMushlamServices = null;
            Master.uniqueSearchParamater = Guid.NewGuid().ToString();
            Master.ResetSortingAndPaging(tdSortingButtons, null);
            Master.ResetLastSelectedRowIndex();

            ShowGridAndRelatedControls();

            // reset data recieved indicators
            hdnDeptsDataRecieved.Value = hdnMushlamDataRecieved.Value = string.Empty;


            // if only mushlam selected - load mushlam tab
            if (isMushlamSelected && Master.GetSelectedSearchMode().Count == 1)
            {       
                SearchMushlam();
            }
            else
            {
                Facade applicFacade = Facade.getFacadeObject();
                //DataSet DeptRandomOrder = applicFacade.GetDeptRandomOrder();

                //Session["DeptRandomOrderTable"] = DeptRandomOrder.Tables[0];

                // populate depts data
                LoadDataAndPopulate();

                SetMushlamTabVisibilityOnSearch();
            }

        }
    }

    protected void btnSort_Click(object sender, EventArgs e)
    {
        //Session["DeptRandomOrderTable"] = null;
        Session["RenewSearch"] = true;

        SortableColumnHeader columnToSortBy = sender as SortableColumnHeader;
        DataView dvCurrentResults = null;
        if (Master.IsClosestPointsSearchMode == true)
        {
            dvCurrentResults = ((DataTable)ViewState["currentGvDataView"]).DefaultView;
        }

        clinicSearchParameters = (ClinicSearchParameters)Session["clinicSearchParameters"];

        Master.ReSortResults(tdSortingButtons, columnToSortBy, dvCurrentResults, repClinicsList);

    }

    protected void repClinicsList_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        DataRowView currentRow = e.Item.DataItem as DataRowView;

        if (Master.IsClosestPointsSearchMode)
        {
            if (dsClinics == null && ViewState["dsClinics"] != null)
            {
                dsClinics = (DataSet)ViewState["dsClinics"];
            }

        }

            //if (currentDept != currentRow["deptCode"].ToString())
            //{
            //    currentDept = currentRow["deptCode"].ToString();
            //    isNewDept = true;
            //}
            //else
            //{
            //    isNewDept = false;
            //}
        long currEmployeeID;

        if (!long.TryParse(currentRow["EmployeeID"].ToString(), out currEmployeeID))
        {
            currEmployeeID = -1;
            //todo error
        }


        int showServicePictureFlag = 0;
        Image imgRecComm = e.Item.FindControl("imgRecepAndComment") as Image;
        Image imgServiceLevel = e.Item.FindControl("imgServiceLevel") as Image;
        Image imgReceiveGuests = e.Item.FindControl("imgReceiveGuests") as Image;
        HyperLink lnkDeptCode = e.Item.FindControl("lnkToDept") as HyperLink;
        HyperLink lnkToDoctor = e.Item.FindControl("lnkToDoctor") as HyperLink;
        Image imgSerRecComm = e.Item.FindControl("imgServiceRecepAndComment") as Image;
        HyperLink lnkToService = e.Item.FindControl("lnkToService") as HyperLink;
        Image imgAttributed = e.Item.FindControl("imgAttributed") as Image;
        Image imgMap = e.Item.FindControl("imgMap") as Image;
        Label lblPhone = e.Item.FindControl("lblPhone") as Label;
        Label lblCityName = e.Item.FindControl("lblcityName") as Label;
        Label lblAddress = e.Item.FindControl("lblAddress") as Label;
        Label lblTemporarilyInactive = e.Item.FindControl("lblTemporarilyInactive") as Label;
        Image imgPhoneRemark = e.Item.FindControl("imgPhoneRemark") as Image;
        Image imgAgreementType = e.Item.FindControl("imgAgreementType") as Image;

        int rowStatus = getRowStatus(currentRow["status"].ToString(), currentRow["employeeStatus"].ToString(), currentRow["serviceStatus"].ToString());

        if (rowStatus != 1)
        {
            setLablesColor(rowStatus, lnkDeptCode, lnkToDoctor,
                lnkToService, lblPhone, lblCityName, lblAddress);
        }

        if (rowStatus != 2)
        {
            lblTemporarilyInactive.Style.Add("display", "none");
        }

        //if (isNewDept)
        //{
        lnkDeptCode.NavigateUrl = "Public/ZoomClinic.aspx?DeptCode=" + currentRow["deptCode"].ToString() + "&Index=" + e.Item.ItemIndex
                                                                                            + "&SearchId=" + Master.uniqueSearchParamater;
        //}
        //else
        //{

        //    imgMap.Visible = false;
        //    imgAttributed.Visible = false;
        //    imgServiceLevel.Visible = false;
        //    imgRecComm.Visible = false;
        //    lnkDeptCode.Visible = false;
        //    lblPhone.Visible = false;
        //    lblCityName.Visible = false;
        //    lblAddress.Visible = false;
        //}


        // handle scroll inside results div
        if (e.Item.ItemIndex == sessionParams.LastRowIndexOnSearchPage &&
                                            Request.QueryString["RepeatSearch"] != null)
        {
            Master.SetScrollToLastSearch(e.Item.FindControl("pnlLink"), lnkDeptCode);
            ((HtmlTableRow)e.Item.FindControl("trClinic")).Attributes.Remove("class");
            ((HtmlTableRow)e.Item.FindControl("trClinic")).Attributes.Add("class", "trPlain_marked");
        }

        int currDeptCode = Convert.ToInt32(currentRow["deptCode"]);

        addressHandler ad = new addressHandler();
        phoneHandler ph = new phoneHandler();

        #region OrderNumber



        //we only want numbers when we are in Closest Points Search Mode
        Label lbl = e.Item.FindControl("MapOrderNumber") as Label;
        if (Master.IsClosestPointsSearchMode == true)
        {
            lbl.Text = (e.Item.ItemIndex + 1).ToString();
            HtmlTableCell tc = e.Item.FindControl("tdMapOrder") as HtmlTableCell;
            tc.Style.Add("display", "block");
            tc = e.Item.FindControl("tdAddressData") as HtmlTableCell;
            tc.Style.Remove("width");
            tc.Style.Add("width", "165px");
            tdEmptyData.Style.Add("width", "37px");
            tdAddressHeader.Style.Add("width", "161px");
        }
        else
        {
            lbl.Visible = false;

            HtmlTableCell tc = e.Item.FindControl("tdMapOrder") as HtmlTableCell;
            tc.Style.Add("display", "none");
            tc = e.Item.FindControl("tdAddressData") as HtmlTableCell;
            tc.Style.Remove("width");
            tc.Style.Add("width", "175px");
            tdEmptyData.Style.Add("width", "25px");
            tdAddressHeader.Style.Add("width", "173px");
        }

        #endregion

        #region Map


        SearchPageHelper.PrepareGridRowMapData(currentRow, e.Item.ItemIndex, imgMap, clinicSearchParameters.MapInfo.CoordinatX,
                                                                   clinicSearchParameters.MapInfo.CoordinatY, repClinicsList.ClientID, Master.IsClosestPointsSearchMode);


        #endregion

        lnkToService.ToolTip = currentRow["ServicePhones"].ToString();

        if (Convert.ToBoolean(currentRow["IsMedicalTeam"]) == false)
        {
            lnkToDoctor.NavigateUrl = "Public/ZoomDoctor.aspx?EmployeeID=" + currentRow["employeeID"] + "&Index=" + e.Item.ItemIndex +
                                                                                                "&Id=" + Master.uniqueSearchParamater;
        }


        if (Convert.ToInt32(currentRow["deptLevel"]) == 3)
        {
            if (currentRow["ShowUnitInInternet"] == DBNull.Value || Convert.ToInt32(currentRow["ShowUnitInInternet"]) == 0)
            {
                imgServiceLevel.ImageUrl = "~/Images/Applic/pic_NotShowInInternet.gif";
                imgServiceLevel.ToolTip = "יחידה פנימית בלבד";
            }
            else
            {
                imgServiceLevel.ImageUrl = "~/Images/vSign.gif";
                //imgServiceLevel.Style.Add("display", "none");
                imgServiceLevel.Visible = false;
            }
        }
        if (Convert.ToInt32(currentRow["deptLevel"]) == 2)
        {
            imgServiceLevel.ImageUrl = "~/Images/Applic/M.gif";
            imgServiceLevel.Attributes.Add("alt", "שירות ברמה מחוזית");
        }
        if (Convert.ToInt32(currentRow["deptLevel"]) == 1)
        {
            imgServiceLevel.ImageUrl = "~/Images/Applic/A.gif";
            imgServiceLevel.Attributes.Add("alt", "שירות ברמה ארצית");
        }

        if (currentRow["ServiceID"].ToString() != string.Empty && Utils.IsServiceRelevantForReceivingGuests(Convert.ToInt32(currentRow["ServiceID"])))
        {
            if (Convert.ToInt32(currentRow["ReceiveGuests"]) == 1)
            {
                imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuests.png";
                imgReceiveGuests.ToolTip = "הרופא מקבל אורחים";
            }
            else if (Convert.ToInt32(currentRow["ReceiveGuests"]) == 0)
            {
                imgReceiveGuests.ImageUrl = "~/Images/Applic/NOTreceiveGuests.png";
                imgReceiveGuests.ToolTip = "הרופא אינו מקבל אורחים";
            }
            else if (Convert.ToInt32(currentRow["ReceiveGuests"]) == 2)
            {
                imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuestsPartTime.png";
                imgReceiveGuests.ToolTip = "הרופא מקבל אורחים לפעמים";
            }
        }
        else
        {
            imgReceiveGuests.Visible = false;
        }

        if (Convert.ToInt32(currentRow["ShowHoursPicture"]) > 0)
        {
            showServicePictureFlag += 1;
        }

        if (Convert.ToInt32(currentRow["ShowRemarkPicture"]) > 0)
        {
            showServicePictureFlag += 10;
        }

        if (currentRow["remark"] != DBNull.Value && currentRow["remark"].ToString() != string.Empty)
        {
            imgPhoneRemark.ImageUrl = "~/Images/Applic/phone_remark.png";
            imgPhoneRemark.ToolTip = currentRow["remark"].ToString();
        }
        else 
        {
            imgPhoneRemark.Visible = false;
        }

        string deptCode = currentRow["deptCode"].ToString();
        string employeeID = currentRow["employeeID"].ToString();
        string serviceOrEventID = currentRow["ServiceID"].ToString();
        string agreementType = currentRow["agreementType"].ToString();
        bool serviceHasReceptionHours = (Convert.ToInt32(currentRow["ShowHoursPicture"]) > 0 ? true : false);
        bool serviceHasRemarks = (Convert.ToInt32(currentRow["ShowRemarkPicture"]) > 0 ? true : false);
        int serviceOrEvent = Convert.ToInt32(currentRow["ServiceOrEvent"]);

        if (serviceOrEvent == 1)
        {
            UIHelper.setClockRemarkImage(imgSerRecComm, serviceHasReceptionHours, serviceHasRemarks, "Green",
                "OpenServiceWindow(" + deptCode + "," + employeeID + "," + serviceOrEventID + "," + agreementType + ")",
                "הקש להצגת שעות קבלה", "הקש להצגת הערות", "הקש להצגת שעות קבלה והערות");
        }
        else
        {
            UIHelper.setClockRemarkImage(imgSerRecComm, serviceHasReceptionHours, serviceHasRemarks, "Green",
                "OpenEventsWindow('" + serviceOrEventID + "')",
                "הקש להצגת שעות קבלה", "הקש להצגת הערות", "הקש להצגת שעות קבלה והערות");
        }
        //OpenEventsWindow
         
        bool clinicHasReceptionHours = (Convert.ToInt32(currentRow["countReception"]) > 0 ? true : false);
        bool clinicHasRemarks = (Convert.ToInt32(currentRow["countDeptRemarks"]) > 0 ? true : false);
        if (Convert.ToInt32(currentRow["ShowRemarkPicture"]) > 0 && Convert.ToInt32(currentRow["ShowRemarkPicture"]) < 4)
        {
            clinicHasRemarks = true;
        }

        string ServiceCodes = "0";
        if (clinicSearchParameters.ServiceCodes != null && clinicSearchParameters.ServiceCodes != string.Empty)
        {
            ServiceCodes = clinicSearchParameters.ServiceCodes;
        }

        UIHelper.setClockRemarkImage(imgRecComm, clinicHasReceptionHours, clinicHasRemarks, "Blue",
            "return OpenReceptionWindowDialog(" + currentRow["deptCode"].ToString() + ",'" + ServiceCodes + "')",
            "הקש להצגת שעות קבלה", "הקש להצגת הערות", "הקש להצגת שעות קבלה והערות");



        bool isCommunity = (bool)currentRow["IsCommunity"];
        bool isMushlam = (bool)currentRow["IsMushlam"];
        bool isHospital = (bool)currentRow["isHospital"];

        int subUnitTypeCode = (int)currentRow["subUnitTypeCode"];

        UIHelper.SetImageForDeptAttribution(ref imgAttributed, isCommunity, isMushlam, isHospital, subUnitTypeCode);

        #region Queue Order

        List<int> queueOrders;

        if (employeeID != string.Empty)
        {
            queueOrders = (from queueOrder in dsClinics.Tables["QueueOrderMethods"].AsEnumerable()
                           where queueOrder.Field<long>("employeeID") == currEmployeeID
                           && queueOrder.Field<int>("deptCode") == currDeptCode
                           && queueOrder.Field<int>("ServiceID") == Convert.ToInt32(serviceOrEventID)
                           select queueOrder.Field<int>("QueueOrderMethod")).ToList();
        }
        else
        {
            queueOrders = (from queueOrder in dsClinics.Tables["QueueOrderMethods"].AsEnumerable()
                           where queueOrder.Field<int>("deptCode") == currDeptCode
                           select queueOrder.Field<int>("QueueOrderMethod")).ToList();
        }

        if (queueOrders.Count > 0)
        {
            Literal litQueueOrder = e.Item.FindControl("litQueueOrder") as Literal;
            Label lblDeptEmployeeQueueOrderPhones = e.Item.FindControl("lblDeptEmployeeQueueOrderPhones") as Label;

            litQueueOrder.Text = UIHelper.GetInnerHTMLForQueueOrder(queueOrders, "tblQueueOrderPhonesAndHours" + currentRow["RowNumber"], null, null);

            DataRow[] phonesArr;
            if (employeeID != string.Empty)
            {
                phonesArr = dsClinics.Tables["DeptPhones"].Select("DeptCode=" + currDeptCode + " AND EmployeeID=" + currEmployeeID + " AND ServiceID=" + serviceOrEventID);
            }
            else
            {
                phonesArr = dsClinics.Tables["DeptPhones"].Select("DeptCode=" + currDeptCode);
            }

            if (phonesArr.Length > 0)
            {
                for (int i = 0; i < phonesArr.Length; i++)
                {
                    if (!string.IsNullOrEmpty(lblDeptEmployeeQueueOrderPhones.Text))
                    {
                        lblDeptEmployeeQueueOrderPhones.Text += ", ";
                    }

                    lblDeptEmployeeQueueOrderPhones.Text += phonesArr[i]["phone"].ToString();
                }

                GridView gvQueueOrderHours = e.Item.FindControl("gvDeptEmployeeQueueOrderHours") as GridView;

                if (employeeID != string.Empty)
                {
                    gvQueueOrderHours.DataSource = new DataView(dsClinics.Tables["QueueOrderMethods"], "DeptCode=" + currDeptCode +
                                " AND EmployeeID=" + currEmployeeID + " AND ServiceID=" + serviceOrEventID + " AND FromHour IS NOT NULL", string.Empty, DataViewRowState.OriginalRows);
                }
                else
                {
                    gvQueueOrderHours.DataSource = new DataView(dsClinics.Tables["QueueOrderMethods"], "DeptCode=" + currDeptCode +
                                 " AND FromHour IS NOT NULL", string.Empty, DataViewRowState.OriginalRows);
                }

                gvQueueOrderHours.DataBind();
            }
        }
        else
        {
            if (currentRow["QueueOrderDescription"] != DBNull.Value)
            {
                Label lblQueueOrder = e.Item.FindControl("lblQueueOrder") as Label;
                lblQueueOrder.Visible = true;
                lblQueueOrder.Text = currentRow["QueueOrderDescription"].ToString();
            }            
        }

        #endregion

        if (currentRow["ServiceID"].ToString() != "0")
        {
            if (currentRow["AgreementType"] != DBNull.Value)
            {
                eDIC_AgreementTypes agreement = (eDIC_AgreementTypes)Enum.Parse(typeof(eDIC_AgreementTypes),
                                                                            currentRow["AgreementType"].ToString());

                UIHelper.SetImageForAgreementType(agreement, imgAgreementType);
            }
        }
        else
        {
            imgAgreementType.Visible = false;
        }
    }

    protected void lnkMushlamService_clicked(object sender, EventArgs e)
    {
        LinkButton link = sender as LinkButton;
        HtmlControl row;
        if (link != null)
        {
            CurrentMushlamServiceCode = Convert.ToInt32(link.CommandArgument.Split('_')[0]);
            int groupCode = Convert.ToInt32(link.CommandArgument.Split('_')[1]);
            int subGroupCode = Convert.ToInt32(link.CommandArgument.Split('_')[2]);
            DisplayMushlamServiceData(CurrentMushlamServiceCode, groupCode, subGroupCode);

            // mark the selected row
            foreach (RepeaterItem ctrl in rptSearchResults.Items)
            {
                row = (HtmlControl)ctrl.FindControl("divServiceRow");
                row.Attributes.Add("class", "mushlamServiceResultsRow");
            }

            ((HtmlControl)link.Parent).Attributes.Add("class", "mushlamServiceResultsRowSelected");
        }
    }

    protected void btnShowMushlamServices_click(object sender, EventArgs e)
    {

        divMushlamServicesSuppliersOnly.Visible = false;

        SearchMushlam();

        if (Session["ClinicSearchParametersForMushlamServices"] != null)
        {
            clinicSearchParametersForMushlamServices = (ClinicSearchParametersForMushlamServices)Session["ClinicSearchParametersForMushlamServices"];
            MarkMushlamServiceResultsRowSelected(clinicSearchParametersForMushlamServices.ServiceCodeForMuslam, 
                                                 clinicSearchParametersForMushlamServices.GroupCode, 
                                                 clinicSearchParametersForMushlamServices.SubGroupCode,
                                                 clinicSearchParametersForMushlamServices.ServiceDescriptionForMuslam);

            Session["ClinicSearchParametersForMushlamServices"] = null;

            if (Session["divMushlamServices_ScrollTopPosition"] != null)
            {
                txtScrollTop.Text = Session["divMushlamServices_ScrollTopPosition"].ToString();

                Session["divMushlamServices_ScrollTopPosition"] = null;
            }

        }

    }

    private void MarkMushlamServiceResultsRowSelected(string serviceCodeForMuslam, int? groupCode, int? subGroupCode, string serviceDescriptionForMuslam)
    {
        HtmlControl row;
        ImageButton btnShowProviders;

        foreach (RepeaterItem ctrl in rptSearchResults.Items)
        {
            row = (HtmlControl)ctrl.FindControl("divServiceRow");

            btnShowProviders = row.FindControl("btnShowProviders") as ImageButton;
            if (btnShowProviders.CommandArgument == (serviceCodeForMuslam + '_' + groupCode + '_' + subGroupCode + '_' + serviceDescriptionForMuslam))
                row.Attributes.Add("class", "mushlamServiceResultsRowSelected");
            else
                row.Attributes.Add("class", "mushlamServiceResultsRow");
         }
    }

    protected void btnShowDepts_Clicked(object sender, EventArgs e)
    {
        Master.ResetSortingAndPaging(tdSortingButtons, null);

        Session["ClinicSearchParametersForMushlamServices"] = null;

        LoadDataAndPopulate();
        ShowGridAndRelatedControls();
        ToggleTabs(false);
    }

    protected void btnShowServiceModels_click(object sender, EventArgs e)
    {
        //ToggleMushlamInnerTabs(false);

        List<MushlamModel> list = Facade.getFacadeObject().GetMushlamModelsForService(CurrentMushlamServiceCode);

        rptModels.DataSource = list;
        rptModels.DataBind();
    }


    #endregion

    private void RegisterMasterControlsEvents()
    {
        Master.btnSubmit_ClickEvent += btnSubmit_Click;
    }

    private string GetURLforResolutionRemark()
    {
        string serverName = Request.ServerVariables["SERVER_NAME"].ToString();
        string[] segmentsURL = Request.Url.Segments;
        string fileName = "SetResolution";
        string url = string.Empty;
        url = "http://" + serverName + segmentsURL[0] + segmentsURL[1] + "HelpFiles/ShowHelp.aspx?file=" + fileName;
        return url;
    }

    private void InitializeViewFromGlobalResources()
    {
        string notValidChar = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "NotValidChar_ErrorMess") as string;
        string notValidWords = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "PreservedWord_ErrorMess") as string;
        string notValidInteger = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "IntegerOnly_ErrorMess") as string;


        //---- ClinicName
        this.vldRegexClinicName.ErrorMessage = string.Format(notValidChar, this.lblClinicName.Text);
        this.vldRegexClinicName.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.vldPreservedWordsClinicName.ErrorMessage = string.Format(notValidWords, "בית");

        //----- ClinicKod
        this.VldTypeCheckClinicKod.ErrorMessage = string.Format(notValidInteger, this.lblClinicCode.Text);

        string multiLineLabelCss = "MultiLineLabel";

        this.lblClinicCode.CssClass = multiLineLabelCss;
        this.lblClinicName.CssClass = multiLineLabelCss;
        this.lblHandicappedFacilities.CssClass = multiLineLabelCss;
        this.lblPopulationSectors.CssClass = multiLineLabelCss;
        this.lblProfession.CssClass = multiLineLabelCss;
        this.lblUnitType.CssClass = multiLineLabelCss;
        this.lblStatus.CssClass = multiLineLabelCss;
         
        this.lblSubUnitType.CssClass = multiLineLabelCss;
        this.lblClalitService.CssClass = multiLineLabelCss;
        //this.lblMedicalAspect.CssClass = multiLineLabelCss;
    }

    private void RepeatLastSearch()
    {
        RestoreSearchParameters();

        // populate depts data
        Master.RepeatLastSearch();               

        repClinicsList.Visible = true;        
        ToggleTabs(false);
        SetMushlamTabVisibilityOnSearch();
        ShowGridAndRelatedControls();
    }

    private void HandleSubUnitTypes()
    {
        // selected unitTypes was changed and need to be cared
        cbHandleSubUnitTypes.Checked = false;

        ClinicSearchParameters clinicSearchParameters_for_SearchMode_Only = new ClinicSearchParameters();
        Master.SetSearchParametersByControls(clinicSearchParameters_for_SearchMode_Only);

        int isCommunity = Convert.ToInt32(clinicSearchParameters_for_SearchMode_Only.CurrentSearchModeInfo.IsCommunitySelected);
        int isMushlam = Convert.ToInt32(clinicSearchParameters_for_SearchMode_Only.CurrentSearchModeInfo.IsMushlamSelected);
        int isHospitals = Convert.ToInt32(clinicSearchParameters_for_SearchMode_Only.CurrentSearchModeInfo.IsHospitalsSelected);

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

            string modeInfoCondition = string.Empty;

            if (isCommunity == 1)
                modeInfoCondition = " IsCommunity = 1 ";

            if (isMushlam == 1)
            {
                if (modeInfoCondition == string.Empty)
                    modeInfoCondition += " IsMushlam = 1 ";
                else
                    modeInfoCondition += " OR IsMushlam = 1 ";
            }

            if (isHospitals == 1)
            {
                if (modeInfoCondition == string.Empty)
                    modeInfoCondition += " IsHospitals = 1 ";
                else
                    modeInfoCondition += " OR IsHospitals = 1 ";
            }

            if (modeInfoCondition != string.Empty)
                modeInfoCondition = " AND ( " + modeInfoCondition + " ) ";

            DataView dvSubUnitType = new DataView(tblSubUnitType, "UnitTypeCode = " + unitTypesSelected[0] + modeInfoCondition, "subUnitTypeName", DataViewRowState.OriginalRows);
            if (dvSubUnitType.Count > 0)
            {
                ddlSubUnitType.Items.Clear();

                ListItem lItem = new ListItem("הכל", "-1");
                ddlSubUnitType.Items.Add(lItem);

                if (dvSubUnitType.Count > 1)
                {
                    lblSubUnitType.Style.Add("display", "inline");
                    ddlSubUnitType.Style.Add("display", "inline");
                }
                else
                {
                    ddlSubUnitType.Style.Add("display", "none");
                    lblSubUnitType.Style.Add("display", "none");
                }

                ddlSubUnitType.DataSource = dvSubUnitType;
                ddlSubUnitType.DataBind();
            }
            else
            {
                ddlSubUnitType.Style.Add("display", "none");
                lblSubUnitType.Style.Add("display", "none");
            }

        }
        else
        {
            //the case when "NO ONE" or "MORE THEN ONE"  unitTypes were selected
            // just hide the ddlSubUnitType control

            ddlSubUnitType.Items.Clear();
            ListItem lItem = new ListItem("הכל", "-1");
            ddlSubUnitType.Items.Add(lItem);
            ListItem lItem2 = new ListItem("כללית", "0");
            ddlSubUnitType.Items.Add(lItem2);

            lblSubUnitType.Style.Add("display", "inline");
            ddlSubUnitType.Style.Add("display", "inline");
        }
    }

    private void handleBinding()
    {
        // bind all relevant dropdownlists to cached views
        ListItem lItem = new ListItem("הכל", "-1");
        ddlStatus.Items.Add(lItem);
        UIHelper.BindDropDownToCachedTable(ddlStatus, eCachedTables.DIC_ActivityStatus.ToString(), eDIC_ActivityStatusEnum.statusDescription.ToString());
        UIHelper.BindDropDownToCachedTable(ddlPopulationSectors, eCachedTables.PopulationSectors.ToString(), ePopulationSectorsEnum.PopulationSectorDescription.ToString());
        txtProfessionsRelevantForReceivigGuests.Text = ConfigurationManager.AppSettings["ServicesRelevantForReceivingGuests"].ToString();
    }

    private void ClearFields()
    {
        Master.ClearFields();

        txtClinicName.Text = String.Empty;
        txtClinicCode.Text = String.Empty;

        txtUnitTypeListCodes.Text = String.Empty;
        txtUnitTypeList.Text = String.Empty;
        txtUnitTypeList_ToCompare.Text = String.Empty;
        ddlSubUnitType.SelectedIndex = -1;
        txtProfessionListCodes.Text = string.Empty;
        txtProfessionList.Text = string.Empty;
        txtProfessionList_ToCompare.Text = string.Empty;

        txtHandicappedFacilitiesList.Text = string.Empty;
        txtHandicappedFacilitiesCodes.Text = string.Empty;
        txtHandicappedFacilitiesList_ToCompare.Text = string.Empty;
        ddlPopulationSectors.SelectedValue = "-1";
        ddlStatus.SelectedValue = (Convert.ToInt32(clinicStatus.Active)).ToString();
        
    }

    #region Save/Restore search perameters


    private void RestoreSearchParameters()
    {
        if (Session["clinicSearchParameters"] == null)
            return;

        clinicSearchParameters = (ClinicSearchParameters)Session["clinicSearchParameters"];
        txtClinicName.Text = clinicSearchParameters.DeptName;

        txtProfessionListCodes.Text = clinicSearchParameters.ServiceCodes;
        txtProfessionList.Text = clinicSearchParameters.ServiceDescriptions;

        txtQueueOrderCodes.Text = clinicSearchParameters.QueueOrderMethodsAndOptionsCodes;
        txtQueueOrder.Text = clinicSearchParameters.QueueOrderMethodsAndOptions;

        txtUnitTypeList.Text = clinicSearchParameters.UnitTypeNames;
        txtUnitTypeListCodes.Text = clinicSearchParameters.UnitTypeCodes;
        HandleSubUnitTypes();
        if (clinicSearchParameters.SubUnitTypeCodes != string.Empty)
            ddlSubUnitType.SelectedValue = clinicSearchParameters.SubUnitTypeCodes;

        txtHandicappedFacilitiesCodes.Text = clinicSearchParameters.HandicappedFacilitiesCodes;
        txtHandicappedFacilitiesList.Text = clinicSearchParameters.HandicappedFacilitiesDescriptions;
        ddlPopulationSectors.SelectedValue = clinicSearchParameters.PopulationSectorCode.ToString();
        txtClinicCode.Text = clinicSearchParameters.CodeSimul;
        if (clinicSearchParameters.Status == null)
            ddlStatus.SelectedIndex = 0;
        else
            ddlStatus.SelectedValue = clinicSearchParameters.Status.ToString();
        chkExtendedSearch.Checked = clinicSearchParameters.IsExtendedSearch;

        txtMedicalAspectCode.Text = clinicSearchParameters.MedicalAspectCode;
        txtMedicalAspectDescription.Text = clinicSearchParameters.MedicalAspectDescription;
        txtClalitServiceCode.Text = clinicSearchParameters.ClalitServiceCode;
        txtClalitServiceDesc.Text = clinicSearchParameters.ClalitServiceDescription;
        cbNotReceiveGuests.Checked = clinicSearchParameters.ReceiveGuests;

        Master.RefreshControlsByParameters(clinicSearchParameters);

    }

    #endregion

    protected void txtClalitServiceCode_TextChanged(object sender, EventArgs e)
    {
        //Get the clalit service code's description by the code text:
        string clalitServiceCode = this.txtClalitServiceCode.Text;

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        int iClalitServiceCode = 0;

        if (int.TryParse(clalitServiceCode, out iClalitServiceCode))
        {
            ds = applicFacade.GetClalitServiceDescription_ByClalitServiceCode(iClalitServiceCode);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                string sClalitServiceDescription = ds.Tables[0].Rows[0]["ClalitServiceDescription"].ToString();

                this.txtClalitServiceDesc.Text = sClalitServiceDescription;
            }
        }
    }

    protected void txtMedicalAspectCode_TextChanged(object sender, EventArgs e)
    {
        string medicalAspectCode = this.txtMedicalAspectCode.Text;

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetMedicalAspectDescription_ByMedicalAspectCode(medicalAspectCode);

            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                string MedicalAspectDescription = ds.Tables[0].Rows[0]["MedicalAspectDescription"].ToString();

                this.txtMedicalAspectDescription.Text = MedicalAspectDescription;
            }
    }


    private void SetExtendedSearchMode()
    {
        List<Enums.SearchMode> selectedSearchMode = Master.GetSelectedSearchMode();
        isMushlamSelected = (selectedSearchMode.Contains(Enums.SearchMode.Mushlam));
        isHospitalSelected = (selectedSearchMode.Contains(Enums.SearchMode.Hospitals));

        if (isMushlamSelected)
            divExtendedSearch.Style.Add("display", "block");
        else
            divExtendedSearch.Style.Add("display", "none");

        if (isHospitalSelected)
        {
            trMedicalAspect.Style.Add("display", "block");
            tblClalitService.Style.Add("display", "block");
        }
        else
        {
            trMedicalAspect.Style.Add("display", "none");
            tblClalitService.Style.Add("display", "none");
        }

        if (chkExtendedSearch.Checked)
        {
            btnProfessionListPopUp.Enabled = false;
            AutoCompleteProfessions.ServicePath = string.Empty;
        }
        else
        {
            btnProfessionListPopUp.Enabled = true;
            AutoCompleteProfessions.ServicePath = "AjaxWebServices/AutoComplete.asmx";
        }
    }

    private void SetDisplayedTab()
    {
        if (isMushlamSelected)
        {
            ToggleTabs(true);
        }
        else
        {
            ToggleTabs(false);
        }
    }

    private void ToggleTabs(bool isMushlamSelected)
    {
        if (isMushlamSelected)
        {
            tabDeptsSelected.Style.Add("display", "none");
            tabDeptsNotSelected.Style.Add("display", "inline");
            tabMushlamServicesNotSelected.Style.Add("display", "none");
            tabMushlamServicesSelected.Style.Add("display", "inline");

            divDeptSearchResults.Style.Add("display", "none");
            divMushlamServicesResults.Style.Add("display", "inline");

            // set default tab inside mushlam tab
            //ToggleMushlamInnerTabs(true);
        }
        else
        {
            tabDeptsSelected.Style.Add("display", "inline");
            tabDeptsNotSelected.Style.Add("display", "none");            
            
            tabMushlamServicesNotSelected.Style.Add("display", "block");
            tabMushlamServicesSelected.Style.Add("display", "none");

            divDeptSearchResults.Style.Add("display", "inline");
            divMushlamServicesResults.Style.Add("display", "none");

        }
    }

    private bool ValidateForm()
    {
        bool validated = true;

        Page.Validate("vldGrSearch");
        if (!Page.IsValid)
        {
            validated = false;
            repClinicsList.Visible = false;
        }
        return validated;
    }

    private void BindGridView_PagedSorted(bool isFromCache)
    {       
        Facade applicFacade = Facade.getFacadeObject();
        if (Session["ClinicSearchParametersForMushlamServices"] != null)
        {
            clinicSearchParametersForMushlamServices = (ClinicSearchParametersForMushlamServices)Session["ClinicSearchParametersForMushlamServices"];
        }

        clinicSearchParameters.IsFromCached = isFromCache;

        SearchPagingAndSortingDBParams searchPagingAndSortingDBParams = Master.GetPagingAndSortingDBParams();
        string SelectedCodesList_1 = "";
        string SelectedCodesList_2 = "";
        string SelectedCodesList_3 = "";

        if (Session["RenewSearch"] != null && Convert.ToBoolean(Session["RenewSearch"]) == true)
        {
            Session["AllSelectedCodesList"] = null;
            Session["RenewSearch"] = null;

            UserInfo currentUser = Session["currentUser"] as UserInfo;

            if (currentUser == null)
            {
                clinicSearchParameters.UserIsLogged = false;
            }
            else
            {
                clinicSearchParameters.UserIsLogged = true;
            }

            dsClinics = applicFacade.getClinicList_PagedSorted(clinicSearchParameters, clinicSearchParametersForMushlamServices, searchPagingAndSortingDBParams);


            Session["AllSelectedCodesList"] = dsClinics.Tables["AllSelectedCodes"];

            if (dsClinics.Tables.Count > 2)  // list of all selected deptCodes
            {
                if (dsClinics.Tables[2].Rows[0].ToString() != string.Empty)
                {
                    Session["FoundDeptCodeList"] = dsClinics.Tables[2].Rows[0][0].ToString();
                }
            }

            if (dsClinics.Tables["rowsCount"] != null)
            {
                sessionParams = SessionParamsHandler.GetSessionParams();
                sessionParams.totalRows = Convert.ToInt32(dsClinics.Tables["rowsCount"].Rows[0][0]);
                SessionParamsHandler.SetSessionParams(sessionParams);
            }
            else
            {
                sessionParams = SessionParamsHandler.GetSessionParams();
                sessionParams.totalRows = 0;
                SessionParamsHandler.SetSessionParams(sessionParams);
            }
        }
        else
        {
            if (Session["AllSelectedCodesList"] != null)
            {
                int pageSize = (int)searchPagingAndSortingDBParams.PageSize;

                int startingRow = ((int)searchPagingAndSortingDBParams.StartingPage - 1) * pageSize;

                DataTable dtSelectedCodes = (DataTable)Session["AllSelectedCodesList"];

                if (dtSelectedCodes.Rows.Count >= startingRow)
                {
                    int toRow = startingRow + pageSize - 1;

                    if (toRow > dtSelectedCodes.Rows.Count)
                        toRow = dtSelectedCodes.Rows.Count;

                    for (int i = startingRow; i < toRow; i++)
                    {
                        SelectedCodesList_1 = SelectedCodesList_1 + "," + Convert.ToString(dtSelectedCodes.Rows[i][0]);
                        if (dtSelectedCodes.Columns.Count > 2)
                        {
                            SelectedCodesList_2 = SelectedCodesList_2 + "," + Convert.ToString(dtSelectedCodes.Rows[i][1]);
                            SelectedCodesList_3 = SelectedCodesList_3 + "," + Convert.ToString(dtSelectedCodes.Rows[i][2]);
                        }
                    }
                }

                dsClinics = applicFacade.getClinicList_PagedSorted(SelectedCodesList_1, SelectedCodesList_2, SelectedCodesList_3,
                    clinicSearchParameters, clinicSearchParametersForMushlamServices, searchPagingAndSortingDBParams);
            }
        }

        if (Master.IsClosestPointsSearchMode)
        {
            ViewState["dsClinics"] = dsClinics;
        }

        DataTable dtDepts = null;
        if (dsClinics != null)
        {
            dtDepts = dsClinics.Tables["depts"];
            if (Master.IsClosestPointsSearchMode == true)
            {
                ViewState["currentGvDataView"] = dsClinics.Tables["depts"];
            }
        }

        repClinicsList.DataSource = dtDepts;
        repClinicsList.DataBind();

        if (clinicSearchParametersForMushlamServices.ServiceCodeForMuslam == null)
            divMushlamServicesSuppliersOnly.Visible = false;
        else
        {
            divMushlamServicesSuppliersOnly.Visible = true;

            lblMushlamServicesSuppliersOnly.Text = "תוצאות חיפוש עבור שירות מושלם: " + clinicSearchParametersForMushlamServices.ServiceDescriptionForMuslam.ToString();
        }
    }

    private void getParametersForQuery_Paged()
    {
        clinicSearchParameters = new ClinicSearchParameters();

        
        clinicSearchParameters.ServiceCodes = txtProfessionListCodes.Text;
        if (LastSearchMushlamServices != null)
            clinicSearchParameters.ServiceCodes = (LastSearchMushlamServices.Aggregate((i,j) => i + "," + j));
        clinicSearchParameters.ServiceDescriptions = txtProfessionList.Text;
        clinicSearchParameters.UnitTypeNames = txtUnitTypeList.Text;
        clinicSearchParameters.UnitTypeCodes = txtUnitTypeListCodes.Text;
        clinicSearchParameters.SubUnitTypeCodes = ddlSubUnitType.SelectedValue;
        clinicSearchParameters.HandicappedFacilitiesDescriptions = txtHandicappedFacilitiesList.Text;
        clinicSearchParameters.CodeSimul = txtClinicCode.Text;
        clinicSearchParameters.Status = Convert.ToInt32(ddlStatus.SelectedValue);
        clinicSearchParameters.IsExtendedSearch = chkExtendedSearch.Checked;
        clinicSearchParameters.ExtendedServiceToSearch = txtProfessionList.Text.Trim();

        clinicSearchParameters.QueueOrderMethodsAndOptions = txtQueueOrder.Text;
        clinicSearchParameters.QueueOrderMethodsAndOptionsCodes = txtQueueOrderCodes.Text;

        clinicSearchParameters.MedicalAspectCode = txtMedicalAspectCode.Text.Trim();
        clinicSearchParameters.MedicalAspectDescription = txtMedicalAspectDescription.Text.Trim();
        clinicSearchParameters.ClalitServiceCode = txtClalitServiceCode.Text.Trim();
        clinicSearchParameters.ClalitServiceDescription = txtClalitServiceDesc.Text.Trim();
        clinicSearchParameters.ReceiveGuests = cbNotReceiveGuests.Checked;

        if (clinicSearchParameters.MedicalAspectCode == string.Empty)
            clinicSearchParameters.MedicalAspectCode = null;
        if (clinicSearchParameters.MedicalAspectDescription == string.Empty)
            clinicSearchParameters.MedicalAspectDescription = null;
        if (clinicSearchParameters.ClalitServiceCode == string.Empty)
            clinicSearchParameters.ClalitServiceCode = null;
        if (clinicSearchParameters.ClalitServiceDescription == string.Empty)
            clinicSearchParameters.ClalitServiceDescription = null;

        Master.SetSearchParametersByControls(clinicSearchParameters);
        DoctorSearchParameters doctorSearchParameters = (DoctorSearchParameters)Session["doctorSearchParameters"];
        if (doctorSearchParameters != null)
            Master.SetSearchModeParameters(doctorSearchParameters);
        else
        {
            doctorSearchParameters = new DoctorSearchParameters();
            Master.SetSearchModeParameters(doctorSearchParameters);
        }
        Session["doctorSearchParameters"] = doctorSearchParameters;
        Session["clinicSearchParameters"] = clinicSearchParameters;

        ClinicManager man = new ClinicManager();
        clinicSearchParameters.UnitTypeCodes = man.GetUnitTypesGroups(txtUnitTypeListCodes.Text);


        if (ddlSubUnitType.SelectedValue == "-1" || ddlSubUnitType.SelectedIndex == -1)
            clinicSearchParameters.SubUnitTypeCodes = string.Empty;
        else
            clinicSearchParameters.SubUnitTypeCodes = ddlSubUnitType.SelectedValue;

        clinicSearchParameters.HandicappedFacilitiesCodes = txtHandicappedFacilitiesCodes.Text;
        clinicSearchParameters.DeptName = txtClinicName.Text.Trim();

        if (txtClinicCode.Text.Trim() != string.Empty)
            clinicSearchParameters.DeptCode = Convert.ToInt32(txtClinicCode.Text);
        else
            clinicSearchParameters.DeptCode = -1;

        clinicSearchParameters.Status = Convert.ToInt32(ddlStatus.SelectedValue);
        clinicSearchParameters.PopulationSectorCode = Convert.ToInt32(ddlPopulationSectors.SelectedValue);
    }

    private void HandleNoMushlamResultsFound()
    {
        trNoResults.Visible = true;
        lblFoundResults.Text = ConstsSystem.NO_RESULTS;
        lblSearchedText.Text = "\"" + txtProfessionList.Text + "\"";
        trMushlamResults.Visible = false;

    }
    private void cleanMushlamControls()
    {
        lblGeneralRemark.Text = string.Empty;
        lblEligibilityRemark.Text = string.Empty;
        lblAgreementDetails.Text = string.Empty;
        lblRepRemark.Text = string.Empty;
        lblRefund.Text = string.Empty;
    }
    
    private void DisplayMushlamServiceData(int serviceCode, int groupCode, int subGroupCode)
    {
        cleanMushlamControls();

        MushlamService service = Facade.getFacadeObject().GetMushlamServiceByCode(serviceCode, groupCode, subGroupCode);

        lblGeneralRemark.Text = service.GeneralRemark;
        if (service.EligibilityRemark != "")
            lblEligibilityRemark.Text = service.EligibilityRemark + "</br></br>";

        if(!string.IsNullOrEmpty(service.SelfParticipation))
            lblAgreementDetails.Text = "<b>" + service.SelfParticipation + "</b></br></br>";
        lblAgreementDetails.Text += service.AgreementRemark;

        lblRepRemark.Text = service.RepresentativeRemark;

        lblRefund.Text = "";

        if (!string.IsNullOrEmpty(service.ClalitRefund))
            lblRefund.Text = "<b>" + service.ClalitRefund + "</b></br></br>";
        lblRefund.Text += service.PrivateRemark;
        if(lblRefund.Text != "")
            lblRefund.Text += "</br>";
        lblRefund.Text += service.RequiredDocuments;
        pnlInnerMushlamRefund.Visible = !string.IsNullOrEmpty(lblRefund.Text);        

        rptLinkedServices.Visible = false;
        if (!string.IsNullOrEmpty(service.LinkedBasketServices))
        {
            MushlamManager manager = new MushlamManager();
            List<LinkedService> servicesList = manager.GetLinkedServicesForMushlamService(service);

            rptLinkedServices.Visible = true;
            rptLinkedServices.DataSource = servicesList;
            rptLinkedServices.DataBind();
        }

        // service models
        rptModels.Visible = false;
        List<MushlamModel> list = Facade.getFacadeObject().GetMushlamModelsForService(CurrentMushlamServiceCode);        
        if (list.Count > 0)        
        {
            rptModels.Visible = true;
            rptModels.DataSource = list;
            rptModels.DataBind();
        }

        ScriptManager.RegisterStartupScript(this,this.GetType(), "scroll", "ScrollToLastPosition();", true);
    }       

    protected void setLablesColor(int statusType, HyperLink lnkDeptCode, HyperLink lnkToDoctor,
        HyperLink lnkToService, Label lblPhone, Label lblCityName, Label lblAddress)
    {
        string strColor = (statusType == 0 ? "red" : "#858585");
        
        lnkDeptCode.Style.Add("color",strColor);
        lnkToDoctor.Style.Add("color", strColor);
        lnkToService.Style.Add("color", strColor);
        lblPhone.Style.Add("color", strColor);
        lblCityName.Style.Add("color", strColor);
        lblAddress.Style.Add("color", strColor);
    }

    protected int getRowStatus(string deptStatus, string employeeStatus, string serviceStatus)
    {
        int status = 1;

        if (serviceStatus == "0" || employeeStatus == "0" || deptStatus == "0")
            status = 0;
        else
        {
            if (employeeStatus == "2" || deptStatus == "2" || serviceStatus == "2")
                status = 2;
            
        }
        return status;
    }

    private void ShowGridAndRelatedControls()
    {
        trPagingButtons.Style.Add("display", "inline");
        trSortingButtons.Style.Add("display", "inline");
        trGvClinicList.Style.Add("display", "inline");
    }

    private void SearchMushlam()
    {
        getParametersForQuery_Paged();

        ToggleTabs(true);
        pnlTabs.Visible = true;

        if (Session["divMushlamServices_ScrollTopPosition"] != null)
            txtScrollTop.Text = Session["divMushlamServices_ScrollTopPosition"].ToString();
        else
            txtScrollTop.Text = string.Empty;
        
        // display mushlam tab and services search results
        List<MushlamServiceSearchResults> list = Facade.getFacadeObject().GetMushlamServices(txtProfessionListCodes.Text.Trim(), 
                                                            txtProfessionList.Text.Trim(), chkExtendedSearch.Checked, clinicSearchParameters);

        rptSearchResults.DataSource = list;
        rptSearchResults.DataBind();

        if (list != null && list.Count > 0)
        {

            LastSearchMushlamServices = (from item in list
                                         select item.ServiceCode.ToString()).ToArray();

            trMushlamResults.Visible = true;
            trNoResults.Visible = false;

            CurrentMushlamServiceCode = list[0].ServiceCode;

            DisplayMushlamServiceData(CurrentMushlamServiceCode, list[0].GroupCode, list[0].SubGroupCode);

            ((HtmlControl)rptSearchResults.Items[0].FindControl("divServiceRow")).Attributes.Add("class", "mushlamServiceResultsRowSelected");
        }
        else
        {
            HandleNoMushlamResultsFound();
        }
        
    }

    private void SearchDeptsData(bool isFromCache)
    {
        BindGridView_PagedSorted(isFromCache);
        
        Master.SetPagingControls(sessionParams.totalRows);
        
        repClinicsList.Visible = true;

        ToggleTabs(false);
    }

    private void SetMushlamTabVisibilityOnSearch()
    {
        List<Enums.SearchMode> selectedSearchMode = Master.GetSelectedSearchMode();

        tabMushlamServicesSelected.Style.Add("display", "none");


        if (selectedSearchMode.Contains(Enums.SearchMode.Mushlam))
        {
            tabMushlamServicesNotSelected.Style.Add("display", "block");
        }
        else
        {
            tabMushlamServicesNotSelected.Style.Add("display", "none");
        }
    }


    #region Paging events

    protected void btnNextPage_Click(object sender, EventArgs e)
    {
        Master.PagingControlsController.btnNextPage_Click(sender, e);
    }

    protected void btnFirstPage_Click(object sender, EventArgs e)
    {
        Master.PagingControlsController.btnFirstPage_Click(sender, e);
    }

    protected void btnLastPage_Click(object sender, EventArgs e)
    {
        Master.PagingControlsController.btnLastPage_Click(sender, e);
    }

    protected void btnPreviousPage_Click(object sender, EventArgs e)
    {
        Master.PagingControlsController.btnPreviousPage_Click(sender, e);
    }

    protected void ddlCarrentPage_SelectedIndexChanged(object sender, EventArgs e)
    {
        Master.PagingControlsController.ddlCarrentPage_SelectedIndexChanged(sender, e);
    }

    #endregion

    #region ISearchPageController

    public int TotalNumberOfRecords
    {
        get
        {
            sessionParams = SessionParamsHandler.GetSessionParams();

            if(sessionParams != null)
                return sessionParams.totalRows;
            //if (dsClinics != null && dsClinics.Tables["rowsCount"] != null && dsClinics.Tables["rowsCount"].Rows.Count > 0)
            //    return Convert.ToInt32(dsClinics.Tables["rowsCount"].Rows[0][0]);
            else
                return 0;
        }
    }

    public void LoadDataAndPopulate(bool isFromCache = false)
    {
        if (Master.IsClosestPointsSearchMode == true)  // search by distance if required
        {
            Master.SetSortingByDistanceAsc();
        }

        getParametersForQuery_Paged();

        // load depts data
        SearchDeptsData(isFromCache);        
        
        pnlTabs.Visible = true;

        //  Show/hide alerts when using time-bound paramrters   
        if (clinicSearchParameters.CurrentReceptionTimeInfo != null
            && ((clinicSearchParameters.CurrentReceptionTimeInfo.FromHour != null && clinicSearchParameters.CurrentReceptionTimeInfo.FromHour != string.Empty)
                || (clinicSearchParameters.CurrentReceptionTimeInfo.InHour != null && clinicSearchParameters.CurrentReceptionTimeInfo.InHour != string.Empty)
                || clinicSearchParameters.CurrentReceptionTimeInfo.OpenNow == true
                ||(clinicSearchParameters.CurrentReceptionTimeInfo.ReceptionDays != null && clinicSearchParameters.CurrentReceptionTimeInfo.ReceptionDays != string.Empty))
            )
        {
            if (clinicSearchParameters.CurrentReceptionTimeInfo.FromHour != null && clinicSearchParameters.CurrentReceptionTimeInfo.FromHour != string.Empty)
            {

                lblReceptionParameters_With_FromHour_search_alert.Visible = true;
                lblReceptionParameters_WithNO_FromHour_search_alert.Visible = false;

                if(clinicSearchParameters.CurrentReceptionTimeInfo.ToHour == null)
                    lblFromHour_ToHour_search_alert.Visible = true;
                else
                    lblFromHour_ToHour_search_alert.Visible = false;
            }
            else
            {
                lblReceptionParameters_With_FromHour_search_alert.Visible = false;
                lblReceptionParameters_WithNO_FromHour_search_alert.Visible = true;
                lblFromHour_ToHour_search_alert.Visible = false;
            }
        }
        else
        {
            lblFromHour_ToHour_search_alert.Visible = false;
            lblReceptionParameters_With_FromHour_search_alert.Visible = false;
            lblReceptionParameters_WithNO_FromHour_search_alert.Visible = false;
        }

        div_health_gov_il.Visible = false;


// will be uncommented in next version
        //if (clinicSearchParameters.UnitTypeCodes != null && clinicSearchParameters.UnitTypeCodes != string.Empty)
        //{
        //    string[] unitTypeCodes = clinicSearchParameters.UnitTypeCodes.ToString().Split(',');
        //    for (int i = 0; i < unitTypeCodes.Length; i++)
        //    {
        //        if (Convert.ToInt32(unitTypeCodes[i]) == 916)
        //            div_health_gov_il.Visible = true;
        //    }
        //}
        //else if (clinicSearchParameters.ServiceCodes != null && clinicSearchParameters.ServiceCodes != string.Empty)
        //{
        //    string[] serviceCodes = clinicSearchParameters.ServiceCodes.ToString().Split(',');
        //    for (int i = 0; i < serviceCodes.Length; i++)
        //    {
        //        if (Convert.ToInt32(serviceCodes[i]) == 308)
        //            div_health_gov_il.Visible = true;
        //    }
        //}

        //flag to show the map, the map is shown only if there is a grid visible, otherwise no point to 
        //show it
        Master.IsAllowShowMap_PageCondition = true;

        if (Master.IsClosestPointsSearchMode == true)
        {
            Master.RefreshMap(null, dsClinics.Tables[0], clinicSearchParameters.MapInfo.CoordinatX, clinicSearchParameters.MapInfo.CoordinatY, true);
        }
    }

    public SearchParametersBase PageSearchParameters
    {
        get { return clinicSearchParameters; }
    }

    public DataTable DTSearchResults
    {
        get
        {
            DataTable dtToReturn = null;
            if (dsClinics != null && dsClinics.Tables.Count > 0)
            {
                dtToReturn = dsClinics.Tables[0];
            }
            return dtToReturn;
        }
    }

    #endregion
}


