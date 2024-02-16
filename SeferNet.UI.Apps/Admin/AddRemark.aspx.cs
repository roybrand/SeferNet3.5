using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.Globals;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;
using System.Web.UI.HtmlControls;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.FacadeLayer;
using System.Collections;
using SeferNet.UI;

public partial class Admin_AddRemark : System.Web.UI.Page
{
    private int _deptCode = -1;
    private int _employeeID = -1;
    private int _serviceCode = -1;
    private int _remarkID = -1;
    private int _deptEmployeeID = -1;

    private Enums.remarkType remarkType;
    private RemarkManager remarkManager = new RemarkManager();
    private UserManager userManager = new UserManager();
    private string districts;
    private string administrationCodes;
    private string unitTypes;
    private string subUnitTypes;
    private string populationSectors;
    private string RemarkText;
    private string cityCodes;
    private string servicesParameter;

    int currentEmployeeDept;
    int IsMedicalTeam;

    #region Properties

    public DataTable AllRemarksDt
    {
        get
        {
            if (Cache["AllRemarks"] != null)
            {
                return (DataTable)Cache["AllRemarks"];
            }
            else
            {
                return null;
            }
        }
        set
        {
            Cache.Remove("AllRemarks");
            Cache.Add("AllRemarks", value, null, System.Web.Caching.Cache.NoAbsoluteExpiration,
                                    TimeSpan.FromMinutes(1), System.Web.Caching.CacheItemPriority.Low, null);

        }
    }

    public int EmployeeID
    {
        get
        {
            return _employeeID;
        }
        set
        {
            _employeeID = value;
        }
    }

    public int DeptCode
    {
        get
        {
            return _deptCode;
        }
        set
        {
            _deptCode = value;
        }
    }

    public int ServiceCode
    {
        get
        {
            return _serviceCode;
        }
        set
        {
            _serviceCode = value;
        }
    }

    public int DeptEmployeeID
    {
        get
        {
            return _deptEmployeeID;
        }
        set
        {
            _deptEmployeeID = value;
        }
    }

    public int RemarkID
    {
        get
        {
            return _remarkID;
        }
        set
        {
            _remarkID = value;
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

    public int CurrGeneralRemarkID
    {
        get
        {
            if (ViewState["CurrGeneralRemarkID"] != null)
            {
                return (int)ViewState["CurrGeneralRemarkID"];
            }
            else
            {
                return -1;
            }
        }
        set
        {
            ViewState["CurrGeneralRemarkID"] = value;
        }
    }


    private string RemarksFilter
    {
        get
        {
            int selCategory = -1;
            int.TryParse(this.ddlRemarkCategory.SelectedValue, out selCategory);

            string filter = "remark like '%" + this.txtFilterRemarks.Text + "%'";
            if (selCategory != -1)
            {
                filter += " and RemarkCategoryID=" + selCategory.ToString();
            }
            return filter;
        }
    }

    #endregion

    protected override void CreateChildControls()
    {
        base.CreateChildControls();


    }

    public string lastPage = "";
    public string isModalWindow = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        this.GetParametersFromQueryString();

        if (!IsPostBack)
        {
            InitPageByRemarkType();
            SavePrevPage();
            BindAllRemarks();
            BindDdlRemarkCategories();
            ddlMDDepts.Items.CssClass = "multiDropDown";
            SetFromDateTodate();
        }
        //else
        //{
        //    if (txtCleanRemarkTextRTF.Text != string.Empty)
        //    {
        //        txtRemarkText.Text = string.Empty;
        //        txtCleanRemarkTextRTF.Text = string.Empty;
        //    }
        //}

        //this.modal.Show();
    }

    private void SavePrevPage()
    {
        if (Request.UrlReferrer != null)
        {
            ViewState["lastPage"] = Request.UrlReferrer.AbsoluteUri;
        }
        else
        {
            if (remarkType == Enums.remarkType.Doctor)
                ViewState["lastPage"] = "~/Public/ZoomDoctor.aspx";
            else
                ViewState["lastPage"] = "~/Public/ZoomClinic.aspx";
        }

        if (this.remarkType != Enums.remarkType.ReceptionHours)
        {
            lastPage = ViewState["lastPage"].ToString();
            if (lastPage.IndexOf("?") > 0)
            {
                string[] tmpSplit = lastPage.Split('?');
                lastPage = tmpSplit[0] + "?" + RequestHelper.removeFromQueryString(tmpSplit[1], "seltab");
            }
        }
        else
        {
            isModalWindow = "1";
            btnSave.Visible = false;
            btnSaveClientSide.Style.Remove("display");
            btnSaveClientSide.Style.Add("display", "inline");

            Session["isModalWindow"] = "1";
        }

    }

    private void GetParametersFromQueryString()
    {
        if (Request.QueryString["EmployeeID"] != null)
        {
            this.EmployeeID = Convert.ToInt32(Request.QueryString["EmployeeID"]);

            //-- remarkType.DoctorServiceInClinic
            if (Request.QueryString["ServiceCode"] != null && Request.QueryString["deptCode"] != null)
            {
                this.ServiceCode = Convert.ToInt32(Request.QueryString["ServiceCode"]);
                this.DeptCode = Convert.ToInt32(Request.QueryString["deptCode"]);
                this.DeptEmployeeID = Convert.ToInt32(Request.QueryString["DeptEmployeeID"]);
                this.remarkType = Enums.remarkType.DoctorServiceInClinic;
            }
            //-- remarkType.Doctor
            else
            {
                this.remarkType = Enums.remarkType.Doctor;

                if (Request.QueryString["deptCode"] != null)
                {
                    this.DeptCode = Convert.ToInt32(Request.QueryString["deptCode"]);
                }
            }
        }
        else //(Request.QueryString["EmployeeID"] == null)
        {
            //-- remarkType.ServiceInClinic
            if (Request.QueryString["ServiceCode"] != null)
            {
                this.ServiceCode = Convert.ToInt32(Request.QueryString["ServiceCode"]);
                this.remarkType = Enums.remarkType.ServiceInClinic;

                if (Request.QueryString["deptCode"] != null)
                    this.DeptCode = Convert.ToInt32(Request.QueryString["deptCode"]);
            }
            else
            {
                //-- remarkType.Clinic
                if (Request.QueryString["deptCode"] != null)
                {
                    this.DeptCode = Convert.ToInt32(Request.QueryString["deptCode"]);
                    this.remarkType = Enums.remarkType.Clinic;
                }
                //-- nums.remarkType.Sweeping
                else
                {
                    this.districts = Request.QueryString["DistrictCode"];
                    this.administrationCodes = Request.QueryString["AdministrationCode"];
                    this.unitTypes = Request.QueryString["UnitTypeCode"];
                    this.subUnitTypes = Request.QueryString["subUnitType"];
                    this.populationSectors = Request.QueryString["PopulationSector"];
                    this.cityCodes = Request.QueryString["cityCode"];
                    //if (cityCode == 0)
                    //{
                    //    cityCode = -1;
                    //}
                    this.servicesParameter = Request.QueryString["servicesParameter"];

                    if (this.districts != null
                        || this.administrationCodes != null
                        || this.unitTypes != null
                        || this.subUnitTypes != null
                        || this.populationSectors != null)
                    {
                        this.remarkType = Enums.remarkType.Sweeping;
                    }
                }
            }
        }

        if (Request.QueryString["RemarkType"] != null)
        {
            string remarkTypeStr = Request.QueryString["RemarkType"];
            this.remarkType = (Enums.remarkType)Enum.Parse(typeof(Enums.remarkType), remarkTypeStr);
        }

        if (Request.QueryString["RemarkText"] != null)
        {
            this.RemarkText = Request.QueryString["RemarkText"];
            this.RemarkText = Server.UrlDecode(RemarkText);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["RemarkID"]))
        {
            this.RemarkID = Convert.ToInt32(Request.QueryString["RemarkID"]);
        }

        if (Request.QueryString["mode"] != null)
        {
            txtHeaderOrEditMode.Value = Request.QueryString["mode"].ToString();
        }
    }

    private void InitPageByRemarkType()
    {
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
        switch (remarkType)
        {
            case Enums.remarkType.Clinic:
                Page.Title = "הוספת הערות ליחידה";
                lblInfo.Text = "בחירת הערה תוסיף אותה לרשימת ההערות המשויכת למרפאה";
                lblPopupHeader.Text = "הוספת הערות ליחידה " + sessionParams.DeptName;
                break;
            case Enums.remarkType.Doctor:
                Page.Title = "הוספת הערות לנותן שירות";
                lblInfo.Text = "בחירת הערה תוסיף אותה לרשימת ההערות המשויכת לנותן שירות";
                lblPopupHeader.Text = "הוספת הערות לנותן שירות " + sessionParams.EmployeeName;
                pnlDeptsForEmployee.Visible = true;

                CheckMedicalTeam();

                ddlMDDepts.Panel.ScrollBars = ScrollBars.Vertical;
                BindDeptsList();

                break;
            case Enums.remarkType.ServiceInClinic:
                if (RemarkID != -1) // update mode
                {
                    Page.Title = "עדכון הערות לשירות ";
                    lblInfo.Text = "ניתן לבחור הערה אחת בלבד";
                    lblPopupHeader.Text = "עדכון הערות לשירות";
                }
                else
                {
                    Page.Title = "הוספת הערות לשירות";
                    lblInfo.Text = "בחירת הערה תוסיף אותה לרשימת ההערות המשויכת לשירות";
                    lblPopupHeader.Text = "הוספת הערות לשירות";
                }
                break;

            case Enums.remarkType.DoctorServiceInClinic:
                Page.Title = "עדכון הערות לשירות";
                lblInfo.Text = "ניתן לבחור הערה אחת בלבד";
                lblPopupHeader.Text = "עדכון הערות לשירות";
                pnlDeptsForEmployee.Visible = false;
                break;
            case Enums.remarkType.Sweeping:
                {
                    Page.Title = "הוספת הערות גורפות";
                    lblInfo.Text = "ניתן לבחור הערה אחת בלבד";
                    lblPopupHeader.Text = "הוספת הערות גורפות";
                    break;
                }
            case Enums.remarkType.ReceptionHours:
                {
                    if (RemarkID != -1) // update mode
                    {
                        Page.Title = "עדכון הערות לשעות קבלה";
                        lblInfo.Text = "ניתן לבחור הערה אחת בלבד";
                        lblPopupHeader.Text = "עדכון הערות לשעות קבלה";
                    }
                    else
                    {
                        Page.Title = "הוספת הערות לשעות קבלה";
                        lblInfo.Text = "ניתן לבחור הערה אחת בלבד";
                        lblPopupHeader.Text = "הוספת הערות לשעות קבלה";
                    }

                    this.chkDisplayOnInternet.Style.Add("display", "none");
                    this.txtRemarkValidFrom.Style.Add("display", "none");
                    this.txtRemarkValidTo.Style.Add("display", "none");
                    this.txtRemarkActiveFrom.Style.Add("display", "none");
                    this.btnCalendarFrom.Style.Add("display", "none");
                    this.btnCalendarTo.Style.Add("display", "none");
                    this.btnCalendarActiveFrom.Style.Add("display", "none");
                    this.lblFromDate.Style.Add("display", "none");
                    this.lblTodate.Style.Add("display", "none");
                    this.lblShowInInternet.Style.Add("display", "none");
                    this.lblActiveFrom.Style.Add("display", "none");
                    break;
                }
            default:
                break;
        }
    }

    private void BindDeptsList()
    {
        DataSet dsDepts = new DataSet();

        Facade applicFacade = Facade.getFacadeObject();
        applicFacade.GetEmployeeDepts(ref dsDepts, EmployeeID);

        if ((dsDepts != null) && (dsDepts.Tables.Count > 0))
        {
            foreach (DataRow row in dsDepts.Tables[0].Rows)
            {
                if (IsMedicalTeam == 0)
                    ddlMDDepts.Items.Items.Add(new ListItem(row["DeptName"].ToString(), row["DeptCode"].ToString()));
                else
                {
                    if (Convert.ToInt32(row["DeptCode"]) == DeptCode)
                        ddlMDDepts.Items.Items.Add(new ListItem(row["DeptName"].ToString(), row["DeptCode"].ToString()));
                }
            }
        }

        if (IsMedicalTeam == 0)
            ddlMDDepts.Items.Items.Insert(0, new ListItem("כל היחידות", "0"));
    }

    private void CheckMedicalTeam()
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        string EmpName = string.Empty;

        if (EmployeeID != -1)
        {
            applicFacade.GetEmployeeGeneralData(ref ds, EmployeeID);
            if ((ds != null) && (ds.Tables.Count > 0) && (ds.Tables[0].Rows.Count > 0))
            {
                EmpName = ds.Tables[0].Rows[0]["EmployeeName"].ToString();
                IsMedicalTeam = Convert.ToInt16(ds.Tables[0].Rows[0]["IsMedicalTeam"]);
            }
        }
        else
        {
            IsMedicalTeam = 0;
        }

        if (DeptCode != 0)
        {
            currentEmployeeDept = DeptCode;
        }
        else
        {
            currentEmployeeDept = -1;
        }
    }

    private void BindAllRemarks()
    {


        //--- update mode
        if (this.RemarkID != -1)
        {
            DataSet dsRemarks = null;
            DataRow currRow = null;

            switch (this.remarkType)
            {
                case Enums.remarkType.ServiceInClinic:
                    {
                        ServiceRemarksBO remarksBo = new ServiceRemarksBO();
                        dsRemarks = remarksBo.getServiceRemarks(DeptCode, ServiceCode);
                        break;
                    }
                case Enums.remarkType.DoctorServiceInClinic:
                    {
                        if (this.EmployeeID != -1)
                        {
                            EmployeeServiceInDeptBO empServices = new EmployeeServiceInDeptBO();
                            dsRemarks = empServices.GetDeptEmployeeServiceRemark(RemarkID);
                            ViewState["EmployeeInClinicServiceRemarkOld"] = dsRemarks.Tables[0];
                        }
                        break;
                    }
                case Enums.remarkType.ReceptionHours:
                    {
                        DataTable rhTable = new DataTable();
                        rhTable.Columns.Add("remarkText", typeof(string));
                        rhTable.Columns.Add("remarkID", typeof(int));

                        currRow = rhTable.NewRow();
                        currRow["remarkText"] = this.RemarkText;
                        currRow["remarkID"] = this.RemarkID;
                        break;
                    }
                default:
                    break;
            }

            if (dsRemarks != null
                && dsRemarks.Tables.Count > 0
                && dsRemarks.Tables[0].Rows.Count > 0)
            {
                currRow = dsRemarks.Tables[0].Rows[0];
            }

            //this.btnSave.Enabled = true;
            if (currRow != null)
            {
                CurrGeneralRemarkID = Convert.ToInt32(currRow["remarkID"]);
                //SetEditControlsForUpdate(ref plhEditRemark, currRow);
                //SetRemarkTextIntoEditControls(currRow["remarkText"].ToString());
                hfCurrRemarkFormatText.Value = currRow["remarkText"].ToString();
            }
        }
        // --- end update mode

        dgRemarks.DataSource = GetAllRemarks();
        dgRemarks.DataBind();

    }

    private void BindDdlRemarkCategories()
    {
        // get lookup table from DataBase and bind Ddl
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = applicFacade.GetGeneralRemarkCategoriesByLinkedTo((int)remarkType, userManager.UserIsAdministrator());

        this.ddlRemarkCategory.DataValueField = "RemarkCategoryID";
        this.ddlRemarkCategory.DataTextField = "RemarkCategoryName";
        this.ddlRemarkCategory.Items.Clear();

        if (ds != null && ds.Tables[0] != null)
        {
            this.ddlRemarkCategory.DataSource = ds.Tables[0];
            this.ddlRemarkCategory.DataBind();
        }

        //-- add default item
        ListItem defItem = new ListItem("הכל", "-1");
        this.ddlRemarkCategory.Items.Insert(0, defItem);

        //-- select default item
        this.ddlRemarkCategory.SelectedIndex = 0;
    }

    //private void SetEditControlsForUpdate(ref PlaceHolder plhEditRemark, DataRow row)
    //{
    //    string[] arr = remarkManager.SplitRemarkTextWithValuesInserted(row["remarkText"].ToString());

    //    this.SetEditControlsForRemarkText(ref plhEditRemark, arr);

    //    if (this.remarkType == Enums.remarkType.ReceptionHours)
    //    {
    //    }
    //    else // remarkType != Enums.remarkType.ReceptionHours
    //    {
    //        if (row.Table.Columns.Contains("displayInInternet")
    //            && row["displayInInternet"] != DBNull.Value
    //            && Convert.ToBoolean(row["displayInInternet"]) == true)
    //        {
    //            this.chkDisplayOnInternet.Checked = true;
    //        }

    //        if (row.Table.Columns.Contains("validFrom")
    //            && row["validFrom"] != DBNull.Value)
    //        {
    //            this.txtRemarkValidFrom.Text = Convert.ToDateTime(row["validFrom"]).ToShortDateString();
    //            this.SetFromDateTodate();
    //        }

    //        if (row.Table.Columns.Contains("validTo")
    //            && row["validTo"] != DBNull.Value)
    //        {
    //            this.txtRemarkValidTo.Text = row["validTo"].ToString();
    //        }
    //    }
    //}

    private void SetFromDateTodate()
    {
        if (txtRemarkValidFrom.Text == String.Empty)
            txtRemarkValidFrom.Text = DateTime.Today.ToShortDateString();
        txtRemarkValidFrom.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtRemarkValidFrom.ClientID + "')";
    }




    /* Set the remark with the text box */
    private PlaceHolder SetEditControlsForRemarkText(ref PlaceHolder plh, string[] arrLabels)
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
                label.Style.Add(HtmlTextWriterStyle.VerticalAlign, "middle");// don't work

                if (i < arrLabels.Length - 1)
                {
                    TextBox text = new TextBox();
                    text.Width = Unit.Pixel(50);
                    text.ID = "text" + id.ToString();
                    text.Style.Add(HtmlTextWriterStyle.VerticalAlign, "middle");// don't work
                    plh.Controls.Add(text);
                }

                id++;
            }
        }

        return plh;
    }

    private void MoveToParentPage()
    {
        if (ViewState["lastPage"] != null)
        {

            Response.Redirect(ViewState["lastPage"].ToString());
        }
    }

    private void MoveToUpdateSweepingRemarks()
    {
        if (ViewState["lastPage"] != null)
        {

            Response.Redirect(ViewState["lastPage"].ToString());
        }
    }

    private void ClearEditArea()
    {
        txtRemarkValidFrom.Text = DateTime.Today.ToShortDateString();
        txtRemarkValidTo.Text = string.Empty;
        //plhEditRemark.Controls.Clear();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        List<string> values = new List<string>();
        DateTime dateFrom = DateTime.MinValue;
        DateTime? dateTo = null;
        DateTime? activeFrom = null;
        Facade applicFacade = Facade.getFacadeObject();
        bool result = true;

        Page.Validate();
        if (Page.IsValid)
        {
            string messageText = "ישנה תקלה בהוספה/עדכון הערה, נא לצאת ממסך זה ולנסות שנית";

            if (this.districts == null
                && this.administrationCodes == null
                && this.unitTypes == null
                && this.subUnitTypes == null
                && this.populationSectors == null
                && remarkType == Enums.remarkType.Sweeping)
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);
                return;
            }

            if (remarkType == Enums.remarkType.Clinic && DeptCode <= 0 )
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);
                return;
            }

            if (!string.IsNullOrEmpty(txtRemarkValidFrom.Text))
            {
                dateFrom = Convert.ToDateTime(txtRemarkValidFrom.Text);
            }

            if (!string.IsNullOrEmpty(txtRemarkValidTo.Text))
            {
                dateTo = Convert.ToDateTime(txtRemarkValidTo.Text);
            }

            if (!string.IsNullOrEmpty(txtRemarkActiveFrom.Text))
            {
                activeFrom = Convert.ToDateTime(txtRemarkActiveFrom.Text);
            }

            bool displayOnInternet = chkDisplayOnInternet.Checked;
            //string remarkText = remarkManager.SetRemarkTextToDB(CurrRemarkFormatText, values);
            int SelectedGeneralRemarkID = int.Parse(hfCurrGeneralRemarkID.Value);
            string remarkText = txtFormatedRemark.Value;

            switch (remarkType)
            {
                case Enums.remarkType.Clinic:
                    {
                        result = applicFacade.InsertDeptRemark(SelectedGeneralRemarkID, remarkText, DeptCode, dateFrom, dateTo, activeFrom, displayOnInternet, userManager.GetUserIDFromSession());

                        if (result)
                        {
                            applicFacade.UpdateEmployeeInClinicPreselected(null, DeptCode, null);
                            if (remarkText.IndexOf("~10#") > 0 || remarkText.IndexOf("~11#") > 0 || remarkText.IndexOf("~12#") > 0)
                            {
                                SendReportAboutFreeClinicRemarkChanged(remarkText);
                                result = true;
                            }
                        }

                        break;
                    }

                case Enums.remarkType.Sweeping:
                    {
                        result = applicFacade.InsertSweepingDeptRemark(
                                        SelectedGeneralRemarkID,
                                        remarkText,
                                        this.districts,
                                        this.administrationCodes,
                                        this.unitTypes,
                                        this.subUnitTypes,
                                        this.populationSectors,
                                        dateFrom,
                                        dateTo,
                                        activeFrom,
                                        displayOnInternet,
                                        this.cityCodes,
                                        this.servicesParameter
                                       );
                        break;
                    }

                case Enums.remarkType.Doctor:

                    string delimitedVals = GlobalMethods.GetStringFromList(ddlMDDepts.SelectedItems);

                    // default dept is current dept code
                    if (string.IsNullOrEmpty(delimitedVals) && DeptCode != -1)
                    {
                        delimitedVals = DeptCode.ToString();
                    }

                    result = applicFacade.InsertEmployeeRemarks(EmployeeID, remarkText, SelectedGeneralRemarkID, delimitedVals, displayOnInternet, dateFrom, dateTo, activeFrom, userManager.GetUserNameForLog());

                    if (result)
                    {
                        if (string.IsNullOrEmpty(delimitedVals))
                        {
                            applicFacade.Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicRemark_Add, userManager.GetUserIDFromSession(), -1, EmployeeID, -1, null, SelectedGeneralRemarkID, null, remarkText);
                        }
                        else
                        {
                            string[] deptCodes = delimitedVals.Split(',');
                            for (int i = 0; i < deptCodes.Count(); i++)
                            {
                                applicFacade.Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicRemark_Add, userManager.GetUserIDFromSession(), Convert.ToInt32(deptCodes[i]), EmployeeID, -1, null, SelectedGeneralRemarkID, null, remarkText);
                            }
                        }

                        applicFacade.UpdateEmployeeInClinicPreselected(EmployeeID, null, null);
                    }

                    break;

                case Enums.remarkType.DoctorServiceInClinic:
                    EmployeeServiceInDeptBO EmpServicesBo = new EmployeeServiceInDeptBO();
                    result = EmpServicesBo.InsertDeptEmployeeServiceRemark(DeptEmployeeID, ServiceCode, SelectedGeneralRemarkID, remarkText,
                                                    dateFrom, dateTo, activeFrom, displayOnInternet, userManager.GetUserNameForLog());
                    if (result == true)
                    {
                        if (ViewState["EmployeeInClinicServiceRemarkOld"] != null)
                        {
                            DataTable dtUpdatedReremark = (DataTable)ViewState["EmployeeInClinicServiceRemarkOld"];
                            string remText = dtUpdatedReremark.Rows[0]["RemarkText"].ToString();
                            int remID = Convert.ToInt32(dtUpdatedReremark.Rows[0]["RemarkID"]);

                            Facade.getFacadeObject().Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicServiceRemark_Update, userManager.GetUserIDFromSession(), DeptCode, null, DeptEmployeeID, -1, remID, ServiceCode, remText);
                        }
                        else
                        {
                            Facade.getFacadeObject().Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicServiceRemark_Add, userManager.GetUserIDFromSession(), DeptCode, null, DeptEmployeeID, -1, SelectedGeneralRemarkID, ServiceCode, remarkText);
                        }
                    }

                    break;
                case Enums.remarkType.ReceptionHours:
                    string script = "CloseItselfAsModalWindow(" + SelectedGeneralRemarkID + ", '" + remarkText + "')";
                    ScriptManager.RegisterClientScriptBlock(this, typeof(UpdatePanel), "SeveAndCloseItselfAsModalWindow", script, true);
                    return;
                default:
                    break;
            }

            // redirect to original page
            MoveToParentPage();
        }
    }

    protected void SendReportAboutFreeClinicRemarkChanged(string remarkTextNotFormatted)
    {
        UserInfo currentUser = Session["currentUser"] as UserInfo;

        string UserName = currentUser.FirstName + " " + currentUser.LastName;
        string userEmail = currentUser.Mail;

        Facade.getFacadeObject().SendReportAboutFreeClinicRemark(DeptCode, GetAbsoluteUrl(DeptCode), remarkTextNotFormatted, UserName, userEmail);
    }

    private string GetAbsoluteUrl(int deptCode)
    {
        string HTTPprefix = "http://";
        if (System.Configuration.ConfigurationManager.AppSettings["Is_HTTPS_enabled"].ToString() == "1")
        {
            HTTPprefix = "https://";
        }

        string serverName = Request.ServerVariables["SERVER_NAME"].ToString();
        string[] segmentsURL = Request.Url.Segments;
        string url = string.Empty;
        url = HTTPprefix + serverName + segmentsURL[0] + segmentsURL[1] + "Public/ZoomClinic.aspx?DeptCode=" + deptCode.ToString();
        return url;
    }

    // btnSaveAndGoEdit_Click - NO need in this now till further notice
    protected void btnSaveAndGoEdit_Click(object sender, EventArgs e)
    {
        List<string> values = new List<string>();
        DateTime dateFrom = DateTime.MinValue;
        DateTime? dateTo = null;
        DateTime? activeShowFrom = null;
        Facade applicFacade = Facade.getFacadeObject();
        bool result = true;

        Page.Validate();
        if (Page.IsValid)
        {
            string messageText = "ישנה תקלה בהוספה/עדכון הערה, נא לצאת ממסך זה ולנסות שנית";

            if (this.districts == null
                && this.administrationCodes == null
                && this.unitTypes == null
                && this.subUnitTypes == null
                && this.populationSectors == null
                && remarkType == Enums.remarkType.Sweeping)
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);
                return;
            }

            if (remarkType == Enums.remarkType.Clinic && DeptCode <= 0)
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);
                return;
            }

            if (!string.IsNullOrEmpty(txtRemarkValidFrom.Text))
            {
                dateFrom = Convert.ToDateTime(txtRemarkValidFrom.Text);
            }

            if (!string.IsNullOrEmpty(txtRemarkValidTo.Text))
            {
                dateTo = Convert.ToDateTime(txtRemarkValidTo.Text);
            }

            if (!string.IsNullOrEmpty(txtRemarkActiveFrom.Text))
            {
                activeShowFrom = Convert.ToDateTime(txtRemarkActiveFrom.Text);
            }

            bool displayOnInternet = chkDisplayOnInternet.Checked;
            //string remarkText = remarkManager.SetRemarkTextToDB(CurrRemarkFormatText, values);
            int SelectedGeneralRemarkID = int.Parse(hfCurrGeneralRemarkID.Value);
            string remarkText = txtFormatedRemark.Value;

            result = applicFacade.InsertSweepingDeptRemark(
                            SelectedGeneralRemarkID,
                            remarkText,
                            this.districts,
                            this.administrationCodes,
                            this.unitTypes,
                            this.subUnitTypes,
                            this.populationSectors,
                            dateFrom,
                            dateTo,
                            activeShowFrom,
                            displayOnInternet,
                            this.cityCodes,
                            this.servicesParameter
                            );

            // redirect to original page
            //MoveToParentPage();
            Response.Redirect(ViewState["lastPage"].ToString());
            //  "~/Admin/UpdateSweepingRemarks.aspx"
        }
    }

    private int myCount = 0;

    protected void dgRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {


        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            RadioButton rbRemark = e.Row.FindControl("radioRemark") as RadioButton;
            HiddenField hdnValue = e.Row.FindControl("hdnRemarkFormatText") as HiddenField;
            HiddenField hdnRemarkID = e.Row.FindControl("hdnRemarkID") as HiddenField;
            Label lblCategory = e.Row.FindControl("lblCategory") as Label;
            Label lblShowForPreviousDays = e.Row.FindControl("lblShowForPreviousDays") as Label;
            Label lblOpenNow = e.Row.FindControl("lblOpenNow") as Label;
            DataRowView row = e.Row.DataItem as DataRowView;

            rbRemark.Text = remarkManager.GetRemarkTextForView(row["remark"].ToString());
            hdnValue.Value = row["remark"].ToString();
            hdnRemarkID.Value = row["remarkID"].ToString();
            lblCategory.Text = row["RemarkCategoryName"].ToString();
            lblShowForPreviousDays.Text = row["ShowForPreviousDays"].ToString();
            if ((bool)row["OpenNow"])
            { 
                lblOpenNow.Text = "כן";            
            }

            if (CurrGeneralRemarkID == Convert.ToInt32(hdnRemarkID.Value))
            {
                rbRemark.Checked = true;
                this.CurrRemarkFormatText = hdnValue.Value;
                //string script = "CheckSelect('" + rbRemark.ClientID + "','" + hdnRemarkID.Value + "','" + hdnValue.Value.Replace("'", "&#39;") + "');";
                string script = "CheckSelect('" + rbRemark.ClientID + "','" + hdnRemarkID.Value + "','" + hfCurrRemarkFormatText.Value.Replace("'", "&#39;") + "','" + row["ShowForPreviousDays"].ToString() + "','" + Convert.ToInt16(row["OpenNow"]).ToString() + "');";

                script += "scrolldiv(" + e.Row.RowIndex * 20 + ");";
                ScriptManager.RegisterStartupScript(this, typeof(UpdatePanel), "setRemarkToUpdate", script, true);
            }

            rbRemark.Attributes.Add("onclick", "CheckSelect('" + rbRemark.ClientID + "','" + hdnRemarkID.Value + "','" + hdnValue.Value.Replace("'", "&#39;").Replace("\r\n", "") + "','" + row["ShowForPreviousDays"].ToString() + "','" + Convert.ToInt16(row["OpenNow"]).ToString() + "');");
        }
        myCount++;
    }

    protected void btnSearch_click(object sender, EventArgs e)
    {
        ClearEditArea();


        DataView dv = new DataView(GetAllRemarks(), this.RemarksFilter, "remark", DataViewRowState.CurrentRows);
        dgRemarks.DataSource = dv;
        dgRemarks.DataBind();
    }


    private DataTable GetAllRemarks()
    {
        if (!IsPostBack)
        {
            Facade applicFacade = Facade.getFacadeObject();
            DataSet ds = applicFacade.GetGeneralRemarks((int)this.remarkType, userManager.UserIsAdministrator(), -1);
            if (ds != null && ds.Tables[0] != null)
            {
                AllRemarksDt = ds.Tables[0];
            }
        }
        else
        {
            if (AllRemarksDt == null)
            {
                // if not exist - get remarks from db
                Facade applicFacade = Facade.getFacadeObject();
                DataSet ds = applicFacade.GetGeneralRemarks((int)this.remarkType, userManager.UserIsAdministrator(), -1);
                if (ds != null && ds.Tables[0] != null)
                {
                    AllRemarksDt = ds.Tables[0];
                }
            }
        }
        return AllRemarksDt;

    }

    protected void btnShowAll_click(object sender, EventArgs e)
    {
        ClearEditArea();
        txtFilterRemarks.Text = string.Empty;
        dgRemarks.DataSource = GetAllRemarks();
        dgRemarks.DataBind();
    }

    protected void btnSort_Click(object sender, EventArgs e)
    {
        SortableColumnHeader currentHeader = sender as SortableColumnHeader;

        this.ResetGridViewSortableHeaders(this.dgRemarks, currentHeader);

        string sort = currentHeader.ColumnIdentifier.ToString() + " " + currentHeader.GetStringValueOfCurrentSort();
        DataView dvRemarks = new DataView(GetAllRemarks(), this.RemarksFilter, sort, DataViewRowState.OriginalRows);

        this.dgRemarks.DataSource = dvRemarks;
        this.dgRemarks.DataBind();
    }

    /// <summary>
    /// Resets all GridView SortableHeaders to default state except the currentHeader.
    /// </summary>
    /// <param name="gridView"></param>
    /// <param name="currentHeader"></param>
    private void ResetGridViewSortableHeaders(GridView gridView, SortableColumnHeader currentHeader)
    {
        foreach (Control contr in this.GridViewHeaders.Controls)
        {
            foreach (Control header in contr.Controls)
            {
                //SortableColumnHeader header = ctrl.FindControl("sortHeader") as SortableColumnHeader;
                if (header is SortableColumnHeader && header != currentHeader)
                {
                    ((SortableColumnHeader)header).ResetSort();
                }
            }
        }


    }
}
