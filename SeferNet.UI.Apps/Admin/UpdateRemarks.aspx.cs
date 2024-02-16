using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Data;

using System.Text.RegularExpressions;

using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;
using SeferNet.UI;


public partial class UpdateRemarks : AdminBasePage
{

    UserInfo currentUser;
    int currentDeptCode;
    DataTable tblSweeping;
    DataTable tblCurrent;
    DataTable tblFuture;
    DataTable tblHistoric;



    protected string UpDirection
    {
        get
        {
            return Enums.MoveDirection.Up.ToString();
        }
    }

    protected string DownDirection
    {
        get
        {
            return Enums.MoveDirection.Down.ToString();
        }

    }

    private enum RemarkTypes
    {
        Sweeping = 1,
        Current = 2,
        Future = 3,
        Historic = 4
    }

    private enum GridRemarkCols
    {
        // 0 and 1 are up and down arrows

        RecType = 2,
        ID = 3,
        InVisibleText = 4,
        Template = 5,
        Markup = 6,
        ValidFrom = 7,
        ValidTo = 8,
        InternetDisplay = 9,
        Deleted = 10
    }

    private void SetFormParams()
    {

        currentUser = Session["currentUser"] as UserInfo;

        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();

        this.currentDeptCode = sessionParams.DeptCode;

        if (currentDeptCode == 0)    // is session expired?
        {
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);
        }

        Master.Page.Title = Page.Title + " " + SessionParamsHandler.GetDeptNameFromSession();
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
            if (Session["tblCurrent"] == null)
            {
                SetRemarksTables();
            }
            else
            {
                tblSweeping = (DataTable)Session["tblSweeping"];
                tblFuture = (DataTable)Session["tblFuture"];
                tblCurrent = (DataTable)Session["tblCurrent"];
                tblHistoric = (DataTable)Session["tblHistoric"];
            }

            ShowData();

            if (gvCurrentRemarks.Rows.Count == 0 && gvFutureRemarks.Rows.Count == 0)
            {
                btnSaveChangesUp.Enabled = false;
                btnSaveChanges.Enabled = false;
            }

        }
    }

    private void SetRemarksTables()
    {
        DataSet dsRemarks;


        dsRemarks = GetRemarks(this.currentDeptCode);
        if ((dsRemarks != null) && (dsRemarks.Tables.Count > 0))
        {
            tblSweeping = dsRemarks.Tables[0];
            tblCurrent = dsRemarks.Tables[1];
            tblFuture = dsRemarks.Tables[2];
            tblHistoric = dsRemarks.Tables[3];

            Session["tblSweeping"] = tblSweeping;
            Session["tblFuture"] = tblFuture;
            Session["tblCurrent"] = tblCurrent;
            Session["tblHistoric"] = tblHistoric;
        }

    }

    private DataSet GetRemarks(int UnitID)
    {


        DataSet dsRemarks = new DataSet();



        Facade applicFacade = Facade.getFacadeObject();

        string exlog = string.Empty;



        applicFacade.GetUnitRemarks(ref dsRemarks, UnitID);


        return dsRemarks;
    }

    private void ShowData()
    {
        //gvSweepingRemarks.DataSource = tblSweeping;
        gvFutureRemarks.DataSource = tblFuture;
        gvCurrentRemarks.DataSource = tblCurrent;
        gvHistoricRemarks.DataSource = tblHistoric;

        //gvSweepingRemarks.DataBind();
        gvCurrentRemarks.DataBind();
        gvFutureRemarks.DataBind();
        gvHistoricRemarks.DataBind();

        HandleRemarksPriorityButtons(gvCurrentRemarks);

    }

    private void ParseRemark(GridViewRowEventArgs e)
    {
        Panel pRemark = null;

        string objID = string.Empty;

        string srecType = string.Empty;

        object[] data = ((System.Data.DataRowView)(e.Row.DataItem)).Row.ItemArray;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            string remarkText = data[((byte)GridRemarkCols.InVisibleText)].ToString();

            objID = ((Label)e.Row.FindControl("lblRemarkID")).Text;


            pRemark = (Panel)e.Row.FindControl("remarkPanel");

            remarkManager.setRemarkWithInputs(remarkText, objID, ref pRemark, ref objectIndex, rowClientID, ref ListOfInputID);

        }
    }

    protected void gvHistoricRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        int RemarksID = 0;
        string ColHeaderText = string.Empty;
        GridView gv;
        gv = (GridView)sender;

        CheckBox chk = (CheckBox)e.Row.FindControl("chkInternetDisplay"); ;

        TextBox txtHistoricValidFrom = e.Row.FindControl("txtHistoricValidFrom") as TextBox;
        TextBox txtHistoricValidTo = e.Row.FindControl("txtHistoricValidTo") as TextBox;
        ImageButton btnRunCalendar_Date = e.Row.FindControl("btnRunCalendar_Date") as ImageButton;
        ImageButton btnRunCalendar_Date2 = e.Row.FindControl("btnRunCalendar_Date2") as ImageButton;

        Label lblRemarkTextToShow = e.Row.FindControl("lblRemarkTextToShow") as Label;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            //string remarkText = dvRowView["RemarkText"].ToString();
            if (Convert.ToByte(dvRowView["Deleted"]) == 0)
            {
                //RemarksID = Convert.ToInt32(dvRowView["RemarkID"].ToString());
                //rowClientID = e.Row.ClientID;

                //Panel pRemark;
                //pRemark = (Panel)e.Row.FindControl("remarkPanel");

                //remarkManager.setRemarkWithInputs(remarkText, RemarksID.ToString(), ref pRemark, ref objectIndex, rowClientID, ref ListOfInputID);
                if (chk != null)
                {
                    if (Convert.ToInt32(dvRowView["Internetdisplay"]) == 1)
                    {
                        chk.Checked = true;
                    }

                }
            }
            else
            {
                e.Row.Visible = false;
            }
        }
    }

    protected void gvCurrentRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        CheckBox chk = (CheckBox)e.Row.FindControl("chkInternetDisplay");
        int RemarksID = 0;
        TextBox txtCurrValidFrom = e.Row.FindControl("txtCurrValidFrom") as TextBox;
        TextBox txtCurrentValidTo = e.Row.FindControl("txtCurrentValidTo") as TextBox;
        TextBox txtActiveFrom = e.Row.FindControl("txtActiveFrom") as TextBox;

        ImageButton btnRunCalendar_Date = e.Row.FindControl("btnRunCalendar_Date") as ImageButton;
        ImageButton btnRunCalendar_Date2 = e.Row.FindControl("btnRunCalendar_Date2") as ImageButton;

        Label lblRemarkTextToShow = e.Row.FindControl("lblRemarkTextToShow") as Label; //-- gvSweeping not containse

        TextBox txtFtrValidFrom = e.Row.FindControl("txtFtrValidFrom") as TextBox; //- future
        TextBox txtFtrValidTo = e.Row.FindControl("txtFtrValidTo") as TextBox;//-

        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            string remarkText = dvRowView["RemarkText"].ToString();

            if (Convert.ToByte(dvRowView["RecordType"]) == (byte)RemarkTypes.Sweeping)
            {
                chk.Enabled = false;
                (e.Row.FindControl("txtSwepValidFrom") as TextBox).Enabled = false;
                (e.Row.FindControl("txtSwepValidTo") as TextBox).Enabled = false;
                btnRunCalendar_Date.Enabled = false;
                btnRunCalendar_Date2.Enabled = false;

            }
            if (txtCurrValidFrom != null)
            {
                txtCurrValidFrom.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtCurrValidFrom.ClientID + "')";
                txtCurrValidFrom.Attributes["onChange"] = "SetActiveFrom('" + txtCurrValidFrom.ClientID + "','" + txtActiveFrom.ClientID + "','" + dvRowView["ShowForPreviousDays"].ToString() + "');" + "CheckDatesConsistency('" + txtCurrValidFrom.ClientID + "','" + txtCurrentValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";

                txtCurrentValidTo.Attributes["onChange"] = "CheckDatesConsistency('" + txtCurrValidFrom.ClientID + "','" + txtCurrentValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";

                if (txtCurrValidFrom.Text == String.Empty)
                {
                    txtCurrValidFrom.Text = DateTime.Today.ToShortDateString();
                }

                txtActiveFrom.Attributes["onChange"] = "CheckDatesConsistency('" + txtCurrValidFrom.ClientID + "','" + txtCurrentValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";
            }

            if (txtFtrValidFrom != null)
            {
                txtFtrValidFrom.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtFtrValidFrom.ClientID + "')";
                txtFtrValidFrom.Attributes["onChange"] = "SetActiveFrom('" + txtFtrValidFrom.ClientID + "','" + txtActiveFrom.ClientID + "','" + dvRowView["ShowForPreviousDays"].ToString() + "')";
            }

            if (Convert.ToByte(dvRowView["Deleted"]) == 0)
            {
                RemarksID = Convert.ToInt32(dvRowView["RemarkID"].ToString());
                rowClientID = e.Row.ClientID;

                Panel pRemark;
                pRemark = (Panel)e.Row.FindControl("remarkPanel");

                remarkManager.setRemarkWithInputsVariableLength(remarkText, RemarksID.ToString(), ref pRemark, ref objectIndex, rowClientID, ref ListOfInputID);

                if (chk != null)
                {
                    if (Convert.ToInt32(dvRowView["Internetdisplay"]) == 1)
                    {
                        chk.Checked = true;
                    }

                }
            }
            else
            {
                e.Row.Visible = false;
            }

            if (Convert.ToBoolean(dvRowView["RelevantForSystemManager"]) == true && currentUser.IsAdministrator != true)
            {
                chk.Enabled = false;
                if (txtCurrValidFrom != null)
                    txtCurrValidFrom.Enabled = false;
                if (txtCurrentValidTo != null)
                    txtCurrentValidTo.Enabled = false;

                if (txtFtrValidFrom != null)
                    txtFtrValidFrom.Enabled = false;
                if (txtFtrValidTo != null)
                    txtFtrValidTo.Enabled = false;

                btnRunCalendar_Date.Enabled = false;
                btnRunCalendar_Date2.Enabled = false;

                Panel pRemark = (Panel)e.Row.FindControl("remarkPanel");
                pRemark.Visible = false;

                lblRemarkTextToShow.Text = remarkManager.getFormatedRemark(remarkText);

                lblRemarkTextToShow.Visible = true;

                DisableDeleteButton(e);

            }

        }
    }

    protected void gvFutureRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        CheckBox chk = (CheckBox)e.Row.FindControl("chkInternetDisplay");
        int RemarksID = 0;
        TextBox txtFtrValidFrom = e.Row.FindControl("txtFtrValidFrom") as TextBox;
        TextBox txtFtrValidTo = e.Row.FindControl("txtFtrValidTo") as TextBox;
        TextBox txtActiveFrom = e.Row.FindControl("txtActiveFrom") as TextBox;

        ImageButton btnRunCalendar_Date = e.Row.FindControl("btnRunCalendar_Date") as ImageButton;
        ImageButton btnRunCalendar_Date2 = e.Row.FindControl("btnRunCalendar_Date2") as ImageButton;

        Label lblRemarkTextToShow = e.Row.FindControl("lblRemarkTextToShow") as Label; //-- gvSweeping not containse

        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            string remarkText = dvRowView["RemarkText"].ToString();

            if (Convert.ToByte(dvRowView["RecordType"]) == (byte)RemarkTypes.Sweeping)
            {
                chk.Enabled = false;
                (e.Row.FindControl("txtSwepValidFrom") as TextBox).Enabled = false;
                (e.Row.FindControl("txtSwepValidTo") as TextBox).Enabled = false;
                btnRunCalendar_Date.Enabled = false;
                btnRunCalendar_Date2.Enabled = false;

            }
            if (txtFtrValidFrom != null)
            {
                txtFtrValidFrom.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtFtrValidFrom.ClientID + "')";
                txtFtrValidFrom.Attributes["onChange"] = "SetActiveFrom('" + txtFtrValidFrom.ClientID + "','" + txtActiveFrom.ClientID + "','" + dvRowView["ShowForPreviousDays"].ToString() + "');" 
                    + "CheckDatesConsistency('" + txtFtrValidFrom.ClientID + "','" + txtFtrValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";

                txtFtrValidTo.Attributes["onChange"] = "CheckDatesConsistency('" + txtFtrValidTo.ClientID + "','" + txtFtrValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";

                if (txtFtrValidTo.Text == String.Empty)
                {
                    txtFtrValidTo.Text = DateTime.Today.ToShortDateString();
                }

                txtActiveFrom.Attributes["onChange"] = "CheckDatesConsistency('" + txtFtrValidTo.ClientID + "','" + txtFtrValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";
            }

            if (Convert.ToByte(dvRowView["Deleted"]) == 0)
            {
                RemarksID = Convert.ToInt32(dvRowView["RemarkID"].ToString());
                rowClientID = e.Row.ClientID;

                Panel pRemark;
                pRemark = (Panel)e.Row.FindControl("remarkPanel");

                remarkManager.setRemarkWithInputsVariableLength(remarkText, RemarksID.ToString(), ref pRemark, ref objectIndex, rowClientID, ref ListOfInputID);

                if (chk != null)
                {
                    if (Convert.ToInt32(dvRowView["Internetdisplay"]) == 1)
                    {
                        chk.Checked = true;
                    }

                }
            }
            else
            {
                e.Row.Visible = false;
            }

            if (Convert.ToBoolean(dvRowView["RelevantForSystemManager"]) == true && currentUser.IsAdministrator != true)
            {
                chk.Enabled = false;
                if (txtFtrValidTo != null)
                    txtFtrValidTo.Enabled = false;
                if (txtFtrValidTo != null)
                    txtFtrValidTo.Enabled = false;

                if (txtFtrValidFrom != null)
                    txtFtrValidFrom.Enabled = false;
                if (txtFtrValidTo != null)
                    txtFtrValidTo.Enabled = false;

                btnRunCalendar_Date.Enabled = false;
                btnRunCalendar_Date2.Enabled = false;

                Panel pRemark = (Panel)e.Row.FindControl("remarkPanel");
                pRemark.Visible = false;

                lblRemarkTextToShow.Text = remarkManager.getFormatedRemark(remarkText);

                lblRemarkTextToShow.Visible = true;

                DisableDeleteButton(e);

            }

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

    private void HandleRemarksPriorityButtons(GridView gv)
    {
        if (gv.Rows.Count == 0)
            return;

        ImageButton btnUp = gv.Rows[0].FindControl("btnUp") as ImageButton;
        if (btnUp != null)
        {
            btnUp.ImageUrl = "~/Images/Applic/btnUp_disabled.gif";
            btnUp.Enabled = false;
        }

        ImageButton btnDown = gv.Rows[gv.Rows.Count - 1].FindControl("btnDown") as ImageButton;
        if (btnDown != null)
        {
            btnDown.ImageUrl = "~/Images/Applic/btnDown_disabled.gif";
            btnDown.Enabled = false;
        }
    }



    protected void UpdateRows(object sender, EventArgs e)
    {
        DataTable tblData = null;
        int RemarkID = 0;
        CheckBox chk;
        Label LRemarkID = null;

        GridViewRow row;
        GridView gvData = null;
        Control x;

        string RemarkText = string.Empty;
        string[] arrTbl = new string[4] { "tblCurrent", "tblFuture", "tblHistoric", "tblSweeping" };
        string[] arrField = new string[2] { "", "" }; ;

        string exlog = string.Empty;


        int tbl_i;

        tblFuture = (DataTable)Session["tblFuture"];
        tblCurrent = (DataTable)Session["tblCurrent"];
        tblHistoric = (DataTable)Session["tblHistoric"];

        //if (!Page.IsValid)
        //{
        //    return;
        //}


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

        Facade applicFacade = Facade.getFacadeObject();
        applicFacade.Insert_LogChange((int)Enums.ChangeType.ClinicRemarks_Update, currentUser.UserID, this.currentDeptCode, null, null, null, null, null, null);

        //---------for each remark table from "tblCurrent", "tblFuture", "tblHistoric", "tblSweeping" -----------------------------

        List<string> remarksToBeReported = new List<string>();

        for (tbl_i = 0; tbl_i < arrTbl.Length; tbl_i++)
        { // arrTbl.Length
            switch (tbl_i)
            { //switch 
                case 0:
                    {
                        gvData = this.gvCurrentRemarks;
                        arrField = new string[2] { "txtCurrValidFrom", "txtCurrentValidTo" };
                    }
                    break;
                case 1:
                    {
                        gvData = this.gvFutureRemarks;
                        arrField = new string[2] { "txtFtrValidFrom", "txtFtrValidTo" };
                    }
                    break;
                case 2:
                    {
                        gvData = this.gvHistoricRemarks;
                        arrField = new string[2] { "txtHistoricValidFrom", "txtHistoricValidTo" };
                    }
                    break;
                case 3:
                    {
                        gvData = this.gvSweepingRemarks;
                        //arrField = new string[2] { "txtValidFrom", "txtHistoricValidTo" };
                    }
                    break;

                default:
                    break;
            } //switch 
            tblData = (DataTable)Session[arrTbl[tbl_i]];
            System.Web.UI.HtmlControls.HtmlInputHidden output;

            //---------- gvData ---------------------
            for (int row_i = 0; row_i < gvData.Rows.Count; row_i++)
            {
                row = gvData.Rows[row_i];
                if (row.RowType != DataControlRowType.DataRow)
                    continue;

                x = row.FindControl("lblRemarkID");

                LRemarkID = (Label)x;

                RemarkID = Convert.ToInt32(LRemarkID.Text);

                DataRow dataRow;
                DataRow[] dataRows = tblData.Select("RemarkID = " + RemarkID, "", DataViewRowState.CurrentRows);
                if (dataRows == null || dataRows.Length == 0)
                    continue;

                dataRow = dataRows[0];

                // if Remark is not Sweeping
                if ((int)dataRow["RecordType"] != 1)
                {
                    output = (System.Web.UI.HtmlControls.HtmlInputHidden)row.FindControl("HiddenRemarkMarkup");
                    RemarkText = output.Value;

                    // check if remark changes to be reported
                    if (dataRow["RemarkText"].ToString() != RemarkText 
                        && (RemarkText.IndexOf("~10#") > 0 || RemarkText.IndexOf("~11#") > 0 || RemarkText.IndexOf("~12#") > 0))
                    {
                        remarksToBeReported.Add(RemarkText);
                    }
                    dataRow["RemarkText"] = RemarkText;
                    dataRow["ValidFrom"] = ((TextBox)row.FindControl(arrField[0])).Text;
                    dataRow["ValidTo"] = ((TextBox)row.FindControl(arrField[1])).Text;
                    dataRow["ActiveFrom"] = ((TextBox)row.FindControl("txtActiveFrom")).Text;
                    chk = (CheckBox)row.FindControl("chkInternetDisplay");
                    if (chk.Checked == true)
                    {
                        dataRow["InternetDisplay"] = 1;
                    }
                    else
                    {
                        dataRow["InternetDisplay"] = 0;
                    }
                }


            }
            //----------- end gvData ----------------
            //-- if table is tblSweeping 
            if (sender.GetType().ToString() != "System.Web.UI.WebControls.ImageButton")
            {
                if (tbl_i == 3)
                {
                    applicFacade.InsertSweepingRemarkExclutions(tblData, this.currentDeptCode);
                }
                else
                {
                    applicFacade.UpdateDeptRemarks(ref tblData, this.currentDeptCode, currentUser.UserNameWithPrefix);

                }
            }
            else // PostBack was caused by btnChangeOrder
            {
                Session[arrTbl[tbl_i]] = tblData;
            }

        }

        //send "free remark changed" report if it really changed
        SendReportAboutFreeClinicRemarkChanged(remarksToBeReported);

        applicFacade.UpdateEmployeeInClinicPreselected(null, this.currentDeptCode, null);

        //----------------------------------
        if (sender.GetType().ToString() != "System.Web.UI.WebControls.ImageButton")
        {
            this.ReturnToCaller();
        }
    }

    protected void SendReportAboutFreeClinicRemarkChanged(List<string> remarksTextNotFormatted)
    {
        UserInfo currentUser = Session["currentUser"] as UserInfo;

        string UserName = currentUser.FirstName + " " + currentUser.LastName;
        string userEmail = currentUser.Mail;
        //string remarkTextNotFormatted;
        foreach (string remarkTextNotFormatted in remarksTextNotFormatted)
        { 
            Facade.getFacadeObject().SendReportAboutFreeClinicRemark(this.currentDeptCode, GetAbsoluteUrl(this.currentDeptCode), remarkTextNotFormatted, UserName, userEmail);        
        }
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

    private void ReturnToCaller()
    {

        string returnURL = string.Empty;
        string query = "";
        string[] splitURL = null;

        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();

        returnURL = sessionParams.CallerUrl;

        Session["tblSweeping"] = null;
        Session["tblFuture"] = null;
        Session["tblCurrent"] = null;
        Session["tblHistoric"] = null;

        if (returnURL != string.Empty)
        {
            splitURL = returnURL.Split('?');
            if (splitURL.Length > 1)
            {
                query = splitURL[1];
                query = "?" + RequestHelper.removeFromQueryString(query, "seltab");
            }
            Response.Redirect(splitURL[0] + query);
        }
        else
        {
            Response.Redirect("UpdateClinicDetails.aspx");
        }
    }

    protected void CancelUpdate(object sender, EventArgs e)
    {
        ReturnToCaller();
    }

    protected void btnChangeOrder_Click(object sender, ImageClickEventArgs e)
    {
        ImageButton btnClicked = sender as ImageButton;

        tblCurrent = (DataTable)Session["tblCurrent"];

        GridViewRow gridRow = btnClicked.Parent.Parent as GridViewRow;
        int index = gridRow.RowIndex;

        DataRow row = tblCurrent.NewRow();
        row.ItemArray = tblCurrent.Rows[index].ItemArray;

        Enums.MoveDirection direction = (Enums.MoveDirection)Enum.Parse(typeof(Enums.MoveDirection), btnClicked.CommandName);
        switch (direction)
        {
            case Enums.MoveDirection.Up:
                tblCurrent.Rows.RemoveAt(index);
                tblCurrent.Rows.InsertAt(row, index - 1);
                break;

            case Enums.MoveDirection.Down:
                tblCurrent.Rows.RemoveAt(index);
                tblCurrent.Rows.InsertAt(row, index + 1);
                break;

            default:
                break;
        }

        Session["tblCurrent"] = tblCurrent;
        Response.Redirect("UpdateRemarks.aspx");
    }
}
