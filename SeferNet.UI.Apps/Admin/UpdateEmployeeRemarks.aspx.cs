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


public partial class UpdateEmployeeRemarks : AdminBasePage
{

    UserInfo currentUser;

    DataTable tblCurrent;
    DataTable tblFuture;
    DataTable tblHistoric;

    int currentEmployeeDept;
    int IsMedicalTeam;

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

        Master.Page.Title = Page.Title + " " + EmpName + " " + ddlEmployeeDepts.Text; 
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
            if (Session["currentEmployeeDept"] != null)
            {
                currentEmployeeDept = Convert.ToInt32(Session["currentEmployeeDept"]);
                //ViewState["currentEmployeeDept"] = Session["currentEmployeeDept"];
            }
            else
                currentEmployeeDept = -1;

            SetFormTitles();
            FillDeptsDdl();
            if (IsMedicalTeam == 1) {        
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

    private void FillDeptsDdl()
    {
        DataSet ds = new DataSet();

        Facade applicFacade = Facade.getFacadeObject();

        applicFacade.GetEmployeeDepts(ref ds, EmployeeID);

        if ((ds != null) && (ds.Tables.Count > 0))
        {
            ddlEmployeeDepts.DataSource = ds.Tables[0];
            ddlEmployeeDepts.DataTextField = "DeptName";
            ddlEmployeeDepts.DataValueField = "DeptCode";
            ddlEmployeeDepts.DataBind();
            //currentEmployeeDept
            if (IsMedicalTeam == 0)
            {
                ddlEmployeeDepts.Items.Insert(0, new ListItem("כל היחידות בקהילה", string.Empty));
            }
            else 
            {
                ddlEmployeeDepts.SelectedValue = currentEmployeeDept.ToString();
                ddlEmployeeDepts.Enabled = false;
                btnFilterByArea.Enabled = false;
            }
        }


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

            if(ViewState["tblCurrentBefore"] == null)
                ViewState["tblCurrentBefore"] = tblCurrent;

            if(ViewState["tblFutureBefore"] == null)
                ViewState["tblFutureBefore"] = tblFuture;

            if(ViewState["tblHistoricBefore"] == null)
                ViewState["tblHistoricBefore"] = tblHistoric;
        }
    }

    private DataSet GetRemarks()
    {
        DataSet dsRemarks = new DataSet();
        Facade applicFacade = Facade.getFacadeObject();        


        applicFacade.GetEmployeeRemarks(ref dsRemarks, EmployeeID);

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
    protected void gvFutureRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        RemarksRowDataBound(sender, e);
    }
    protected void gvCurrentRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
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

            TextBox txtCurrValidFrom = e.Row.FindControl("txtCurrValidFrom") as TextBox;
            TextBox txtFtrValidFrom = e.Row.FindControl("txtFtrValidFrom") as TextBox;
            TextBox txtHistoricValidFrom = e.Row.FindControl("txtHistoricValidFrom") as TextBox;

            TextBox txtValidTo = e.Row.FindControl("txtValidTo") as TextBox;
            TextBox txtFtrValidTo = e.Row.FindControl("txtFtrValidTo") as TextBox;
            TextBox txtHistoricValidTo = e.Row.FindControl("txtHistoricValidTo") as TextBox;

            ImageButton btnRunCalendar_Date = e.Row.FindControl("btnRunCalendar_Date") as ImageButton;
            ImageButton btnRunCalendar_Date2 = e.Row.FindControl("btnRunCalendar_Date2") as ImageButton;

            TextBox txtEmployeeDepts = e.Row.FindControl("txtEmployeeDepts") as TextBox;
            ImageButton btnRoles = e.Row.FindControl("btnRoles") as ImageButton;
            CheckBox chkInternetDisplay = e.Row.FindControl("chkInternetDisplay") as CheckBox;
            
            DisableDeleteButton(e);
            
            pRemark.Visible = false;
            lblRemarkTextToShow.Visible = true;
            
            //if(lblRemarkText != null)
                //lblRemarkTextToShow.Text = remarkManager.getFormatedRemark(drView["RemarkText"].ToString());
            btnRunCalendar_Date.Enabled = false;
            btnRunCalendar_Date2.Enabled = false;
            btnRoles.Enabled = false;
            chkInternetDisplay.Enabled = false;
            txtEmployeeDepts.Enabled = false;

            if (txtCurrValidFrom != null)
                txtCurrValidFrom.Enabled = false;
            if (txtFtrValidFrom != null)
                txtFtrValidFrom.Enabled = false;
            if (txtHistoricValidFrom != null)
                txtHistoricValidFrom.Enabled = false;

            if (txtValidTo != null)
                txtValidTo.Enabled = false;
            if (txtFtrValidTo != null)
                txtFtrValidTo.Enabled = false;
            if (txtHistoricValidTo != null)
                txtHistoricValidTo.Enabled = false;
        }
    }

    private bool IsShowRemark(string DeptCodes)
    {
        bool Show = false;

        //return true; 
        string DeptCode = string.Empty;

        DeptCode = ddlEmployeeDepts.SelectedValue.ToString();

        if ((DeptCodes == string.Empty) || (DeptCodes.Contains(DeptCode)))
        {
            Show = true;
        }

        return Show;
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

            // auto complete
            AjaxControlToolkit.AutoCompleteExtender ac = e.Row.FindControl("acDepts") as AjaxControlToolkit.AutoCompleteExtender;
            if(ac != null)
                ac.ContextKey = EmployeeID.ToString();

            // bind related depts for remark
            TextBox txtDepts = e.Row.FindControl("txtEmployeeDepts") as TextBox;
            HiddenField hdnValues = e.Row.FindControl("hdnValues") as HiddenField;

            if (Convert.ToBoolean(dvRowView["attributedToAllClinics"]))
            {
                hdnValues.Value = "-1";
                txtDepts.Text = "כל היחידות בקהילה";
            }
            else
            {
                txtDepts.Text = dvRowView["AreasNames"].ToString();
                hdnValues.Value = dvRowView["DeptsCodes"].ToString();
            }

            TextBox txtActiveFrom = e.Row.FindControl("txtActiveFrom") as TextBox;

            TextBox txtValidFrom = e.Row.FindControl("txtValidFrom") as TextBox;
            TextBox txtValidTo = e.Row.FindControl("txtValidTo") as TextBox;

            if (txtValidFrom != null)
            {
                txtValidFrom.Attributes["onfocusout"] = "onfocusoutFromDate('" + txtValidFrom.ClientID + "')";
                txtValidFrom.Attributes["onChange"] = "SetActiveFrom('" + txtValidFrom.ClientID + "','" + txtActiveFrom.ClientID + "','" + dvRowView["ShowForPreviousDays"].ToString() + "');" 
                    + "CheckDatesConsistency('" + txtValidFrom.ClientID + "','" + txtValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";

                txtValidTo.Attributes["onChange"] = "CheckDatesConsistency('" + txtValidFrom.ClientID + "','" + txtValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";


                if (txtValidFrom.Text == String.Empty)
                {
                    txtValidFrom.Text = DateTime.Today.ToShortDateString();
                }

                txtActiveFrom.Attributes["onChange"] = "CheckDatesConsistency('" + txtValidFrom.ClientID + "','" + txtValidTo.ClientID + "','" + txtActiveFrom.ClientID + "')";

            }

            if ((Convert.ToByte(dvRowView["Deleted"]) == 0) && (IsShowRemark(dvRowView["DeptsCodes"].ToString())))
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

        //for (int i=0; i < tblHistoric.Rows.Count; i++)
        //{
        //    if (tblHistoric.Rows[i]["InternetDisplay"].ToString() == "True")
        //        tblHistoric.Rows[i]["InternetDisplay"] = "1";
        //    if (tblHistoric.Rows[i]["InternetDisplay"].ToString() == "False")
        //        tblHistoric.Rows[i]["InternetDisplay"] = "0";
        //}

        UserManager mng = new UserManager();

        CollectUserData();
        Facade applicFacade = Facade.getFacadeObject();

        bool updateResult = applicFacade.UpdateEmployeeRemarks(ref tblCurrent, ref tblFuture, ref tblHistoric);
        if (updateResult == true)
        {
            DataTable tblCurrentBefore = (DataTable)ViewState["tblCurrentBefore"];
            DataTable tblFutureBefore = (DataTable)ViewState["tblFutureBefore"];
            DataTable tblHistoricBefore = (DataTable)ViewState["tblHistoricBefore"];

            InsertLogChange(ref tblCurrent, ref tblCurrentBefore, mng.GetUserIDFromSession());
            InsertLogChange(ref tblFuture, ref tblFutureBefore, mng.GetUserIDFromSession());
            //InsertLogChange(ref tblHistoric, ref tblHistoricBefore, username);

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
                    else if ( tblBefore.Rows[i]["DeptsCodes"].ToString() != tblAfter.Rows[ii]["DeptsCodes"].ToString() ||
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
                            tblData.Rows[i]["ActiveFrom"] = ((TextBox)row.FindControl(arrField[2])).Text;

                            HiddenField hdnValues = row.FindControl("hdnValues") as HiddenField;

                            // if 'all clinics' has been chosen - ignore all other selections
                            if (hdnValues.Value.IndexOf("-1") > -1)
                            {
                                hdnValues.Value = "-1";
                            }

                            tblData.Rows[i]["AttributedToAllClinics"] = (hdnValues.Value.Trim() == "-1");
                            tblData.Rows[i]["AreasNames"] = ((HiddenField)row.FindControl("hdnValues")).Value;

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
