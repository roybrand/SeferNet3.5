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


public partial class UpdateEmployeeServiceRemarks : AdminBasePage
{

    UserInfo currentUser;

    DataTable tblCurrent;
    DataTable tblFuture;
    DataTable tblHistoric;

    int currentEmployeeDept;
    int IsMedicalTeam;
    string ServiceName = string.Empty;

    private int _deptCode = -1;
    private int _serviceCode = -1;
    private int _deptEmployeeID = -1;

    private enum RemarkTypes
    {
        Sweeping = 1,
        Current = 2,
        Future = 3,
        Historic = 4
    }

    private enum GridRemarkCols
    {
        RecType = 0,
        ID = 1,
        InVisibleText = 2,
        Template = 3,
        Markup = 4,
        ValidFrom = 5,
        ValidTo = 6,
        InternetDisplay = 7,
        Deleted = 8,
        RelatedID = 9,
        SelectArea = 10
    }


    private int EmployeeID
    {
        get
        {
            if (ViewState["EmployeeID"] != null)
            {
                return (int)ViewState["EmployeeID"];
            }
            else
                return 0;
        }
        set { ViewState["EmployeeID"] = value; }
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





    private void SetFormParams()
    {
        currentUser = null;

        if (Session["currentUser"] != null)
        {
            currentUser = Session["currentUser"] as UserInfo;
        }

        if (Request.QueryString["EmployeeID"] != null)
        {
            EmployeeID = Convert.ToInt32(Request.QueryString["EmployeeID"]);
        }

    }

    private void SetFormTitles()
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

        if (ServiceCode != -1)
        {
            ServiceName = Facade.getFacadeObject().GetServiceByCode(ServiceCode).Tables[0].Rows[0]["ServiceDEscription"].ToString();
        }

        Master.Page.Title = Page.Title + " - " + ServiceName + " - " + EmpName;

        Label lblPageTitle = (Label)Master.FindControl("lblPageTitle");
        lblPageTitle.Style.Add("font-size", "18px");
    }

    public String ListOfInputID = "";

    private string rowClientID = "";
    private int objectIndex = 0;


    private RemarkManager remarkManager;

    protected void Page_Load(object sender, EventArgs e)
    {
        remarkManager = new RemarkManager();
        SetFormParams();

        if (!Page.IsPostBack)
        {
            GetParametersFromQueryString();

            if (Session["currentEmployeeDept"] != null)
            {
                currentEmployeeDept = Convert.ToInt32(Session["currentEmployeeDept"]);
            }
            else
                currentEmployeeDept = -1;

            SetFormTitles();
            //FillDeptsDdl();
            if (IsMedicalTeam == 1)
            {
                CollectUserData();
            }
            SetRemarksTables();
            ShowData();
            SaveCallerPage();

            if (gvCurrentRemarks.Rows.Count == 0 && gvFutureRemarks.Rows.Count == 0)
            {
                btnSaveChangesUp.Enabled = false;
                btnSaveChanges.Enabled = false;
            }

        }
        else
        {
            tblCurrent = (DataTable)Session["tblCurrent"];
            tblFuture = (DataTable)Session["tblFuture"];
            tblHistoric = (DataTable)Session["tblHistoric"];
        }

    }

    private void GetParametersFromQueryString()
    {
        if (Request.QueryString["EmployeeID"] != null)
        {
            this.EmployeeID = Convert.ToInt32(Request.QueryString["EmployeeID"]);

            if (Request.QueryString["ServiceCode"] != null)
            {
                this.ServiceCode = Convert.ToInt32(Request.QueryString["ServiceCode"]);
            }

            if ( Request.QueryString["deptCode"] != null)
            {
                this.DeptCode = Convert.ToInt32(Request.QueryString["deptCode"]);
                this.DeptEmployeeID = Convert.ToInt32(Request.QueryString["DeptEmployeeID"]);
            }

            if ( Request.QueryString["DeptEmployeeID"] != null)
            {
                this.DeptEmployeeID = Convert.ToInt32(Request.QueryString["DeptEmployeeID"]);
            }

        }
    }

    private void SaveCallerPage()
    {
        if (Request.UrlReferrer != null)
        {
            ViewState["callerPage"] = Request.UrlReferrer.ToString();
        }
        else
        {
            ViewState["callerPage"] = "~/Public/ZoomDoctor.aspx";
        }
    }

    private void SetFromDateTodate(TextBox txtCurrValidFrom)
    {
        if (txtCurrValidFrom.Text == String.Empty)
            txtCurrValidFrom.Text = DateTime.Today.ToShortDateString();
        txtCurrValidFrom.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtCurrValidFrom.ClientID + "')";
    }

    private void SetRemarksTables()
    {
        DataSet dsRemarks = null;
        dsRemarks = GetRemarks();
        if ((dsRemarks != null) && (dsRemarks.Tables.Count > 0))
        {
            tblCurrent = dsRemarks.Tables[0];
            tblFuture = dsRemarks.Tables[1];
            tblHistoric = dsRemarks.Tables[2];

            Session["tblCurrent"] = tblCurrent;
            Session["tblFuture"] = tblFuture;
            Session["tblHistoric"] = tblHistoric;

            if (ViewState["tblCurrentBefore"] == null)
                ViewState["tblCurrentBefore"] = tblCurrent;

            if (ViewState["tblFutureBefore"] == null)
                ViewState["tblFutureBefore"] = tblFuture;

            if (ViewState["tblHistoricBefore"] == null)
                ViewState["tblHistoricBefore"] = tblHistoric;
        }
    }

    private DataSet GetRemarks()
    {
        DataSet dsRemarks = new DataSet();
        Facade applicFacade = Facade.getFacadeObject();

        applicFacade.GetEmployeeServiceRemarks(ref dsRemarks, DeptEmployeeID, ServiceCode);

        return dsRemarks;
    }

    private void ShowData()
    {
        gvCurrentRemarks.DataSource = tblCurrent;
        gvFutureRemarks.DataSource = tblFuture;
        gvHistoricRemarks.DataSource = tblHistoric;


        gvCurrentRemarks.DataBind();


        gvFutureRemarks.DataBind();


        gvHistoricRemarks.DataBind();
    }

    private string getFormatedRemark(string remarkText)
    {
        string res = "";
        string pattern = @"[#](?<text>.*?)[#]";

        string[] arrPlainText = Regex.Split(remarkText, pattern);

        foreach (string plainText in arrPlainText)
        {
            if (res == "")
            {
                res += plainText.Split('~')[0];
            }
            else
            {
                res += " " + plainText.Split('~')[0];
            }
        }

        return res;
    }

    private void ParseRemark(GridViewRowEventArgs e)
    {
        Panel pRemark = null;
        DataRowView dvRowView = e.Row.DataItem as DataRowView;
        string remarkTemplate = dvRowView["RemarkTemplate"].ToString().Trim();
        string objID = string.Empty;
        byte recType = 0;
        string srecType = string.Empty;

        object[] data = ((System.Data.DataRowView)(e.Row.DataItem)).Row.ItemArray;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            pRemark = (Panel)e.Row.FindControl("remarkPanel");
            if (pRemark == null) // gvHistoricRemarks
                return;
            string remarkText = data[((byte)GridRemarkCols.InVisibleText)].ToString();

            srecType = ((Label)e.Row.FindControl("lblRecordType")).Text;
            recType = Convert.ToByte(srecType);
            objID = ((Label)e.Row.FindControl("lblRemarkID")).Text;

            remarkManager.setRemarkWithInputsVariableLengthAndMaxWidth(remarkTemplate, remarkText, objID, ref pRemark, ref objectIndex, rowClientID, ref ListOfInputID, Convert.ToInt16(pRemark.Width.Value));
        }
    }

    public void DisableDeleteButton(GridViewRowEventArgs e)
    {
        HtmlImage image = (HtmlImage)e.Row.FindControl("imgDelete");

        if (image != null)
        {

            image.Attributes.Remove("onclick");
            image.Attributes.Add("onclick", "javascript:return false");
            image.Style.Remove("cursor");
        }
    }

    protected void gvHistoricRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        RemarksRowDataBound(sender, e);
    }

    protected void gvRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        RemarksRowDataBound(sender, e);
    }


    private void SetRowPermission(GridViewRowEventArgs e, DataRowView drView)
    {
        if (currentUser.IsAdministrator == false && Convert.ToBoolean(drView["RelevantForSystemManager"]) == true)
        {
            Label lblRemarkText = e.Row.FindControl("lblRemarkText") as Label;

            btnSaveChanges.Enabled = false;
            btnSaveChangesUp.Enabled = false;
            Label lblRemarkTextToShow = e.Row.FindControl("lblRemarkTextToShow") as Label;
            Panel pRemark = (Panel)e.Row.FindControl("remarkPanel");

            TextBox txtValidFrom = e.Row.FindControl("txtValidFrom") as TextBox;
            TextBox txtHistoricValidFrom = e.Row.FindControl("txtHistoricValidFrom") as TextBox;

            TextBox txtValidTo = e.Row.FindControl("txtValidTo") as TextBox;
            TextBox txtHistoricValidTo = e.Row.FindControl("txtHistoricValidTo") as TextBox;

            TextBox txtActiveFrom = e.Row.FindControl("txtActiveFrom") as TextBox;

            ImageButton btnRunCalendar_Date = e.Row.FindControl("btnRunCalendar_Date") as ImageButton;
            ImageButton btnRunCalendar_Date2 = e.Row.FindControl("btnRunCalendar_Date2") as ImageButton;
            ImageButton btnCalendarActiveFrom = e.Row.FindControl("btnCalendarActiveFrom") as ImageButton;

            TextBox txtEmployeeDepts = e.Row.FindControl("txtEmployeeDepts") as TextBox;
            ImageButton btnRoles = e.Row.FindControl("btnRoles") as ImageButton;
            CheckBox chkInternetDisplay = e.Row.FindControl("chkInternetDisplay") as CheckBox;

            DisableDeleteButton(e);

            pRemark.Visible = false;
            lblRemarkTextToShow.Visible = true;

            btnRunCalendar_Date.Enabled = false;
            btnRunCalendar_Date2.Enabled = false;
            btnCalendarActiveFrom.Enabled = false;

            btnRoles.Enabled = false;
            chkInternetDisplay.Enabled = false;
            txtEmployeeDepts.Enabled = false;

            if (txtValidFrom != null)
                txtValidFrom.Enabled = false;
            if (txtHistoricValidFrom != null)
                txtHistoricValidFrom.Enabled = false;

            if (txtValidTo != null)
                txtValidTo.Enabled = false;
            if (txtHistoricValidTo != null)
                txtHistoricValidTo.Enabled = false;

            txtActiveFrom.Enabled = false;
        }
    }


    private void RemarksRowDataBound(object sender, GridViewRowEventArgs e)
    {
        CheckBox chk;
        int RemarksID = 0;
        string lblAreasClientID = string.Empty;
        string DeptCode = string.Empty;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            TextBox txtValidFrom = e.Row.FindControl("txtValidFrom") as TextBox;
            TextBox txtValidTo = e.Row.FindControl("txtValidTo") as TextBox;
            TextBox txtActiveFrom = e.Row.FindControl("txtActiveFrom") as TextBox;

            if (txtValidFrom != null)
            { 
                txtValidFrom.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtValidFrom.ClientID + "')";
                txtValidFrom.Attributes["onChange"] = "SetActiveFrom('" + txtValidFrom.ClientID + "','" + txtActiveFrom.ClientID + "','" + dvRowView["ShowForPreviousDays"].ToString() + "');"
                        + "CheckDatesConsistency('" + txtValidFrom.ClientID + "','" + txtValidTo.ClientID + "','" + txtActiveFrom.ClientID + "');";

                txtValidTo.Attributes["onChange"] = "CheckDatesConsistency('" + txtValidFrom.ClientID + "','" + txtValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";

                if (txtValidFrom.Text == String.Empty)
                {
                    txtValidFrom.Text = DateTime.Today.ToShortDateString();
                }

                txtActiveFrom.Attributes["onChange"] = "CheckDatesConsistency('" + txtValidFrom.ClientID + "','" + txtValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";
            }

            if (Convert.ToByte(dvRowView["Deleted"]) == 0)
                {
                RemarksID = Convert.ToInt32(dvRowView["RemarkID"].ToString());
                rowClientID = e.Row.ClientID;
                ParseRemark(e);
                e.Row.Cells[(byte)GridRemarkCols.Markup].ID = "HiRemarkText" + RemarksID.ToString();
                chk = (CheckBox)e.Row.FindControl("chkInternetDisplay");
                if (chk != null)
                {
                    if (Convert.ToInt32(dvRowView["Internetdisplay"]) == 1)
                    {
                        chk.Checked = true;
                    }
                }

                SetRowPermission(e, dvRowView);
            }
            else
            {
                e.Row.Visible = false;
            }
        }

    }

    protected void RemarkTextchChange(object sender, EventArgs e)
    {
        Label LRemarkID = null;
        TextBox Tctl = null;

        foreach (GridViewRow row in gvCurrentRemarks.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                LRemarkID = (Label)row.FindControl("RemarkID");
                Tctl = (TextBox)row.FindControl("RemarkText");
            }
        }
    }

    protected void UpdateRows(object sender, EventArgs e)
    {

        if (hfCurrentDeletedRows.Value != "")
        {
            foreach (string rowIndex in hfCurrentDeletedRows.Value.Split(','))
            {
                int ind = int.Parse(rowIndex);
                tblCurrent.Rows[ind]["Deleted"] = 1;
            }

        }

        if (hfFutureDeletedRows.Value != "")
        {
            foreach (string rowIndex in hfFutureDeletedRows.Value.Split(','))
            {
                int ind = int.Parse(rowIndex);
                tblFuture.Rows[ind]["Deleted"] = 1;
            }

        }

        if (hfHistoricDeletedRows.Value != "")
        {
            foreach (string rowIndex in hfHistoricDeletedRows.Value.Split(','))
            {
                int ind = int.Parse(rowIndex);
                tblHistoric.Rows[ind]["Deleted"] = 1;
            }

        }

        UserManager mng = new UserManager();

        CollectUserData();
        Facade applicFacade = Facade.getFacadeObject();

        bool updateResult = applicFacade.UpdateEmployeeServiceRemarks(ref tblCurrent, ref tblFuture, ref tblHistoric);
        if (updateResult == true)
        {
            DataTable tblCurrentBefore = (DataTable)ViewState["tblCurrentBefore"];
            DataTable tblFutureBefore = (DataTable)ViewState["tblFutureBefore"];
            DataTable tblHistoricBefore = (DataTable)ViewState["tblHistoricBefore"];

            applicFacade.UpdateEmployeeInClinicPreselected(EmployeeID, null, null);

            ReturnToCaller();
        }
    }

    private void InsertLogChange(ref DataTable tblAfter, ref DataTable tblBefore, long username)
    {
        Facade applicFacade = Facade.getFacadeObject();

        for (int i = 0; i < tblBefore.Rows.Count; i++)
        {
            //toBeUpdated = false;
            //toBeDeleted = false;

            for (int ii = 0; ii < tblAfter.Rows.Count; ii++)
            {
                if (Convert.ToInt32(tblBefore.Rows[i]["RemarkID"]) == Convert.ToInt32(tblAfter.Rows[ii]["RemarkID"]))
                {
                    if (Convert.ToByte(tblAfter.Rows[ii]["Deleted"]) == 1) // LOG for deleted
                    {
                        if (Convert.ToByte(tblAfter.Rows[i]["AttributedToAllClinics"]) == 1)
                        {
                            applicFacade.Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicRemark_Delete, username, -1, EmployeeID, null, null, Convert.ToInt32(tblBefore.Rows[i]["dicRemarkID"]), null, tblBefore.Rows[i]["RemarkText"].ToString());
                        }
                        else
                        {
                            string[] deptCodes = tblBefore.Rows[i]["DeptsCodes"].ToString().Split(',');

                            foreach (string deptCode in deptCodes)
                            {
                                applicFacade.Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicRemark_Delete, username, Convert.ToInt32(deptCode), EmployeeID, null, null, Convert.ToInt32(tblBefore.Rows[i]["dicRemarkID"]), null, tblBefore.Rows[i]["RemarkText"].ToString());
                            }
                        }
                    }
                    else if (tblBefore.Rows[i]["DeptsCodes"].ToString() != tblAfter.Rows[ii]["DeptsCodes"].ToString() ||
                              tblBefore.Rows[i]["RemarkText"].ToString() != tblAfter.Rows[ii]["RemarkText"].ToString() ||
                              Convert.ToDateTime(tblBefore.Rows[i]["ValidFrom"]) != Convert.ToDateTime(tblAfter.Rows[ii]["ValidFrom"]) ||
                              Convert.ToDateTime(tblBefore.Rows[i]["ValidTo"]) != Convert.ToDateTime(tblAfter.Rows[ii]["ValidTo"])
                            )   // LOG for updated
                    {

                        if (Convert.ToByte(tblAfter.Rows[i]["AttributedToAllClinics"]) == 1)
                        {
                            applicFacade.Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicRemark_Update, username, -1, EmployeeID, null, null, Convert.ToInt32(tblBefore.Rows[i]["dicRemarkID"]), null, tblBefore.Rows[i]["RemarkText"].ToString());
                        }
                        else
                        {
                            string[] deptCodes = tblBefore.Rows[i]["DeptsCodes"].ToString().Split(',');

                            foreach (string deptCode in deptCodes)
                            {
                                applicFacade.Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicRemark_Delete, username, Convert.ToInt32(deptCode), EmployeeID, null, null, Convert.ToInt32(tblBefore.Rows[i]["dicRemarkID"]), null, tblBefore.Rows[i]["RemarkText"].ToString());
                            }
                        }
                    }
                }

            }
        }

    }
    private void CollectUserData()
    {
        DataTable tblData = null;
        int RemarkID = 0;
        CheckBox chk;
        Label LRemarkID = null;

        GridViewRow row;
        GridView gvData = null;
        Control x;
        Control y;
        string RemarkText = string.Empty;
        string[] arrTbl = new string[3] { "tblCurrent", "tblFuture", "tblHistoric" };
        string[] arrField = new string[2] { "", "" }; ;
        string username = Master.getUserName();

        int i;
        int tbl_i;
        string exlog = string.Empty;



        for (tbl_i = 0; tbl_i < arrTbl.Length; tbl_i++)
        {
            switch (tbl_i)
            {
                case 0:
                    {
                        gvData = gvCurrentRemarks;
                        arrField = new string[3] { "txtValidFrom", "txtValidTo", "txtActiveFrom" };
                    }
                    break;
                case 1:
                    {
                        gvData = gvFutureRemarks;
                        arrField = new string[3] { "txtValidFrom", "txtValidTo", "txtActiveFrom" };
                    }
                    break;
                case 2:
                    {
                        gvData = gvHistoricRemarks;
                        arrField = new string[3] { "txtHistoricValidFrom", "txtHistoricValidTo", "txtActiveFrom" };
                    }
                    break;

                default:
                    break;
            } //switch 
            tblData = (DataTable)Session[arrTbl[tbl_i]];
            System.Web.UI.HtmlControls.HtmlInputHidden output;

            for (int row_i = 0; row_i < gvData.Rows.Count; row_i++)
            {
                row = gvData.Rows[row_i];
                if (row.RowType == DataControlRowType.DataRow)
                {
                    x = row.FindControl("lblRemarkID");

                    LRemarkID = (Label)x;

                    RemarkID = Convert.ToInt32(LRemarkID.Text);
                    for (i = 0; i < tblData.Rows.Count; i++)
                    {

                        if (Convert.ToInt32(tblData.Rows[i]["RemarkID"].ToString()) == RemarkID)
                        {
                            output = (System.Web.UI.HtmlControls.HtmlInputHidden)row.FindControl("HiddenRemarkMarkup");
                            RemarkText = output.Value;
                            tblData.Rows[i]["RemarkText"] = RemarkText;
                            tblData.Rows[i]["ValidFrom"] = ((TextBox)row.FindControl(arrField[0])).Text;
                            tblData.Rows[i]["ValidTo"] = ((TextBox)row.FindControl(arrField[1])).Text;

                            chk = (CheckBox)row.FindControl("chkInternetDisplay");
                            if (chk.Checked == true)
                            {
                                tblData.Rows[i]["InternetDisplay"] = 1;
                            }
                            else
                            {
                                tblData.Rows[i]["InternetDisplay"] = 0;
                            }


                            break;

                        }
                    }

                }
            }

        }
    }


    private void ReturnToCaller()
    {

        string returnURL = string.Empty;

        Session["tblSweeping"] = null;
        Session["tblFuture"] = null;
        Session["tblCurrent"] = null;
        Session["tblHistoric"] = null;

        if (ViewState["callerPage"] != null)
        {
            returnURL = ViewState["callerPage"].ToString();
        }
        //

        if (!string.IsNullOrEmpty(returnURL))
        {
            Response.Redirect(returnURL);
        }
        else
        {
            Response.Redirect("UpdateEmployee.aspx");
        }
    }
    protected void CancelUpdate(object sender, EventArgs e)
    {
        ReturnToCaller();
    }

    protected void FilterRemarks(object sender, EventArgs e)
    {

        CollectUserData();
        SetRemarksTables();
        ShowData();
    }

}
