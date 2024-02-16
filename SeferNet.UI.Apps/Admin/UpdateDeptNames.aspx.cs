using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Data;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow;

public partial class UpdateDeptNames : AdminPopupBasePage
{
    Facade applicFacade;
    DataSet dsDeptNamesAndCo;
    DataSet dsDeptDetails;
    UserInfo currentUser;
    int currentDeptCode;
    int clinicType;
    string independentClinicDeptName;
    string deptNameFreePart;
    int deptStatus;

    public DataTable dtDeptNames
    {
        get
        {
            if (ViewState["deptNames"] != null)
            {
                return (DataTable)ViewState["deptNames"];
            }
            return null;
        }
        set
        {
            ViewState["deptNames"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        currentUser = Session["currentUser"] as UserInfo;

        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();

        if (sessionParams != null)
            currentDeptCode = (sessionParams.DeptCode);
        else
        {
            ClientScript.RegisterStartupScript(this.GetType(), "close", "this.close();", true);
        }

        if (!IsPostBack)
        {
            GetData();
            BindData();

            InitializeViewFromGlobalResources();//julia

            if (currentUser.IsAdministrator)
            {
                vldDeptNameToAdd.Enabled = false;
                vldDeptNameToAdd_Concistency.Enabled = true;

                txtDeptNameToAdd_FromDate.Enabled = true;
                btnRunCalendar_DeptNameToAdd.Attributes.Add("style", "display:inline");
            }
            else
            {
                vldDeptNameToAdd.Enabled = true;
                vldDeptNameToAdd_Concistency.Enabled = false;

                txtDeptNameToAdd_FromDate.Enabled = false;
                btnRunCalendar_DeptNameToAdd.Attributes.Add("style", "display:none");
            }
        }

        BindDropDownLists();

        txtDeptNameToAdd_FromDate.Attributes.Add("onchange", "checkDateOnChange('" + txtDeptNameToAdd_FromDate.ClientID + "')");
    }

    protected void Page_Prerender(object sender, EventArgs e)
    {
        if (cbSaveToBeMade.Checked == true)
        {//data to be saved on UpdateClinicDetailes page 
            string str = "";
            if(Session["NewDeptName"] != null)
            {
                str += "parent.SetClinicName('" + Session["NewDeptName"].ToString() + "');"; 
            }
            str += "SelectJQueryClose();";

            ClientScript.RegisterStartupScript(this.GetType(), "close", str, true);
        }

        //if (cbSaveToBeMade.Checked == true) //data to be saved on UpdateClinicDetailes page 
        //{
        //    string str = "var obj = new Object(); obj.ClinicNameDataToBeSaved = 1; ";
        //    if (Session["NewDeptName"] != null)
        //    {
        //        str = str + "obj.NewDeptName = '" + Session["NewDeptName"].ToString() + "';";
        //    }

        //    str = str + "window.returnValue = obj; self.close();";
        //    ClientScript.RegisterStartupScript(typeof(string), "selfClose", str, true);
        //}

        if (txtErrorMessageAfterSave.Text != string.Empty)
        {
            ClientScript.RegisterStartupScript(typeof(string), "giveErrorMessage", "GiveErrorMessage('" + txtErrorMessageAfterSave.Text + "');", true);
            txtErrorMessageAfterSave.Text = string.Empty;
        }
    }

    private void BindDropDownLists()
    {
        int? index = null;

        if (ddlDeptLevel.SelectedIndex != -1)
        {
            index = ddlDeptLevel.SelectedIndex;
        }
        UIHelper.BindDropDownToCachedTable(ddlDeptLevel, "DIC_deptLevel", "deptLevelDescription");

        DataView dv = ddlDeptLevel.DataSource as DataView;

        for (int i = 0; i < ddlDeptLevel.Items.Count; i++)
        {
            ddlDeptLevel.Items[i].Attributes["EnableDisplayPriority"] = dv[i]["EnableDisplayPriority"].ToString();
        }

        if (index != null)
        {
            ddlDeptLevel.SelectedIndex = (int)index;
        }

        if (!IsPostBack)
        {
            ddlDeptLevel.SelectedValue = dsDeptNamesAndCo.Tables["DeptDetails"].Rows[0]["deptLevel"].ToString();
            ddlDisplayPriority.SelectedValue = dsDeptNamesAndCo.Tables["DeptDetails"].Rows[0]["DisplayPriority"].ToString();

            ToggleDisplayPriorityByDeptLevel();
        }
    }

    private void ToggleDisplayPriorityByDeptLevel()
    {
        bool enableDisplayPriority = Convert.ToBoolean(ddlDeptLevel.SelectedItem.Attributes["EnableDisplayPriority"]);

        pnlDisplayPriority.Visible = enableDisplayPriority;
    }

    private void GetData()
    {
        applicFacade = Facade.getFacadeObject();
        dsDeptNamesAndCo = applicFacade.GetDeptNamesForUpdate(currentDeptCode);
        foreach (DataRow dr in dsDeptNamesAndCo.Tables["DeptNames"].Rows)
        {
            dr["deptName"] = dr["deptName"].ToString().Replace("'", "`");
            dr["deptNameFreePart"] = dr["deptNameFreePart"].ToString().Replace("'", "`");
        }

        if (Session["dtDeptNames"] != null)
        {
            dtDeptNames = (DataTable)Session["dtDeptNames"];
        }
        else
        {
            dtDeptNames = dsDeptNamesAndCo.Tables["DeptNames"];
        }
        //Session["deptLevel"] = null;
        //Session["displayPriority"] = null;

        ViewState["dtDeptNamesBeforeUpdate"] = dtDeptNames;

        dsDeptDetails = applicFacade.GetDeptDetailsForPopUp(currentDeptCode);

        independentClinicDeptName = applicFacade.GetDefaultDeptNameForIndependentClinic(currentDeptCode);
    }

    private void BindData()
    {
        PopulateGrids();

        //if (Session["newClinicType"] == null)
        //{
        //    clinicType = Convert.ToInt32(dsDeptDetails.Tables[0].Rows[0]["UnitTypeCode"]);
        //    txtClinicType.Text = dsDeptDetails.Tables[0].Rows[0]["UnitTypeName"].ToString();
        //}
        //else
        //{
        //    clinicType = Convert.ToInt32(Session["newClinicType"]);
        //    txtClinicType.Text = Session["newUnitTypeName"].ToString();
        //}

        if (Request.QueryString["clinicType"] != null)
        {
            clinicType = Convert.ToInt32(Request.QueryString["clinicType"]);
        }
        else
        {
            clinicType = 0;
        }

        if (Request.QueryString["clinicTypeText"] != null)
        {
            txtClinicType.Text = Request.QueryString["clinicTypeText"].ToString();
        }
        else
        {
            txtClinicType.Text = string.Empty;
        }

        deptStatus = Convert.ToInt32(dsDeptDetails.Tables[0].Rows[0]["status"]);
        ViewState["deptStatus"] = deptStatus;

        deptNameFreePart = dsDeptDetails.Tables[0].Rows[0]["deptNameFreePart"].ToString();

        txtDeptNameToAdd_FromDate.Text = DateTime.Now.Day.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Year.ToString();


        Boolean isHospital = Convert.ToBoolean(dsDeptDetails.Tables[0].Rows[0]["IsHospital"]);

        if (isHospital)
        {
            if (Request.QueryString["districtName"] != null)
            {
                txtCityName.Text = Request.QueryString["districtName"].ToString();
            }

            //txtCityName.Text = dsDeptDetails.Tables[0].Rows[0]["districtName"].ToString();
        }
        else
        {
            if (Request.QueryString["cityName"] != null)
            {
                txtCityName.Text = Request.QueryString["cityName"].ToString().Replace("'", "`");
            }
            //txtCityName.Text = dsDeptDetails.Tables[0].Rows[0]["cityName"].ToString();
        }

        if (!currentUser.IsAdministrator)
        {
            txtCityName.ReadOnly = true;
        }

        if (clinicType == 112) //"מרפאה עצמאית"
        {
            txtClinicType.Visible = false;
            ddlClinicType.Visible = true;
        }
        else
        {
            txtClinicType.Visible = true;
            if (!currentUser.IsAdministrator)
            {
                txtClinicType.ReadOnly = true;
            }
            ddlClinicType.Visible = false;
        }

        if (clinicType == 101) //"מרפאה כפרית"
        {
            txtDeptNameToAdd.Text = string.Empty;
            vldDeptNameToAdd.Enabled = false;
        }
        else if (clinicType == 112)
        {
            txtDeptNameToAdd.Text = independentClinicDeptName;
        }
        else
        {
            if (deptNameFreePart != null && deptNameFreePart != string.Empty)
            {
                txtDeptNameToAdd.Text = deptNameFreePart;
            }
            else
            {
                txtDeptNameToAdd.Text = string.Empty;
            }
        }

    }

    protected void gvDeptNames_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView row = e.Row.DataItem as DataRowView;
            DateTime currFromDate = Convert.ToDateTime(row["fromDate"]);
            TextBox txtToDate = e.Row.FindControl("txtToDate") as TextBox;

            if (e.Row.RowIndex == 0)
                e.Row.FindControl("btnDelete").Visible = false;

            if (currFromDate.Date < Convert.ToDateTime(DateTime.Now.Day.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Year.ToString()))
            {
                e.Row.FindControl("lblFromDate").Visible = true;
            }

            if (!string.IsNullOrEmpty(txtToDate.Text))
            {
                txtToDate.Visible = true;
                e.Row.FindControl("lblToDate").Visible = false;
            }

            if (!Convert.IsDBNull(row["toDate"]))
            {
                e.Row.Style.Add("display", "none");
            }
        }
    }

    protected void gvDeptNamesHistory_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        bool nextDateIsFuture = false;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = e.Row.DataItem as DataRowView;

            if (e.Row.RowIndex < (drv.Row.Table.Rows.Count - 1))
            {
                if (Convert.ToDateTime(drv.Row.Table.Rows[e.Row.RowIndex + 1]["fromDate"]) > DateTime.Now)
                {
                    nextDateIsFuture = true;
                }
            }

            //if (Convert.ToDateTime(txt.Text) < DateTime.Now && e.Row.RowIndex < (drv.Row.Table.Rows.Count - 1))

            Label lbl = e.Row.FindControl("lblFromDate") as Label;
            if (Convert.ToDateTime(lbl.Text) > Convert.ToDateTime(DateTime.Now.Day.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Year.ToString()) || nextDateIsFuture == true || e.Row.RowIndex == (drv.Row.Table.Rows.Count - 1))
            {
                e.Row.Style.Add("display", "none");
            }
        }
    }

    protected void btnAddDeptNameLB_Click(object sender, EventArgs e)
    {
        DateTime newFromDate = Convert.ToDateTime(txtDeptNameToAdd_FromDate.Text);
        DateTime newFromDateS;

        if (newFromDate.Date == DateTime.Now.Date)
        {
            DateTime newFromDateH = newFromDate.AddHours(DateTime.Now.Hour);
            DateTime newFromDateM = newFromDateH.AddMinutes(DateTime.Now.Minute);
            newFromDateS = newFromDateM.AddSeconds(DateTime.Now.Second);
        }
        else
        {
            newFromDateS = newFromDate;
        }

        string deptName = string.Empty;
        deptName = txtDeptNameToAdd.Text;

        if (ddlClinicType.Visible == true)
        {
            if (deptName != string.Empty)
            {
                deptName = deptName + " - ";
            }

            deptName = deptName + ddlClinicType.SelectedValue;
        }
        else
        {
            if (txtClinicType.Text != string.Empty)
            {
                if (deptName != string.Empty)
                {
                    deptName = deptName + " - ";
                }

                deptName = deptName + txtClinicType.Text;
            }
        }

        if (txtCityName.Text != string.Empty)
        {
            if (deptName != string.Empty)
            {
                deptName = deptName + " - ";
            }

            deptName = deptName + txtCityName.Text;
        }

        if (dtDeptNames.Rows.Count > 0)
        {
            DateTime lastFromDate = Convert.ToDateTime(dtDeptNames.Rows[dtDeptNames.Rows.Count - 1]["FromDate"]);
            lastFromDate = Convert.ToDateTime(lastFromDate.Day.ToString() + "/" + lastFromDate.Month.ToString() + "/" + lastFromDate.Year.ToString());

            if (newFromDate == lastFromDate)
            {
                dtDeptNames.Rows[dtDeptNames.Rows.Count - 1]["deptNameFreePart"] = txtDeptNameToAdd.Text;
                dtDeptNames.Rows[dtDeptNames.Rows.Count - 1]["deptName"] = deptName;
            }
            else
            {
                dtDeptNames.Rows[dtDeptNames.Rows.Count - 1]["ToDate"] = newFromDateS.AddDays(-1);
                dtDeptNames.Rows.Add(currentDeptCode, txtDeptNameToAdd.Text, deptName, newFromDateS.ToString());
            }

        }
        else
        {
            dtDeptNames.Rows.Add(currentDeptCode, txtDeptNameToAdd.Text, deptName, newFromDateS.ToString());
        }

        dtDeptNames.AcceptChanges();

        //txtDeptNameToAdd.Text = string.Empty;
        //txtDeptNameToAdd_FromDate.Text = string.Empty;

        foreach (DataRow dr in dtDeptNames.Rows)
        {
            dr["deptName"] = dr["deptName"].ToString().Replace("'", "`");
            dr["deptNameFreePart"] = dr["deptNameFreePart"].ToString().Replace("'", "`");
        }

        gvDeptNames.DataSource = dtDeptNames;
        gvDeptNames.DataBind();

        gvDeptNamesHistory.DataSource = dtDeptNames;
        gvDeptNamesHistory.DataBind();

        //Session["NewDeptName"] = deptName.Replace("`", "'");
        Session["NewDeptName"] = deptName;
    }

    protected void btnSaveDeptName_Click(object sender, EventArgs e)
    {
        int deptLevel = Convert.ToInt32(ddlDeptLevel.SelectedValue);
        int? displayPriority = null;

        if (pnlDisplayPriority.Visible && Convert.ToInt32(ddlDisplayPriority.SelectedValue) >= 1)
        {
            displayPriority = Convert.ToInt32(ddlDisplayPriority.SelectedValue);
        }

        // put all into session to be saved on page UpdateClinicDetailes afterwards if needed
        //foreach (DataRow dr in dtDeptNames.Rows)
        //{
        //    dr["deptName"] = dr["deptName"].ToString().Replace("`", "'");
        //    dr["deptNameFreePart"] = dr["deptNameFreePart"].ToString().Replace("`", "'");
        //}
        Session["dtDeptNames"] = dtDeptNames;
        Session["deptLevel"] = deptLevel;
        Session["displayPriority"] = displayPriority;
        Session["deptNameFreePart"] = txtDeptNameToAdd.Text;

        cbSaveToBeMade.Checked = true;

        //string str = "";

        //str += "parent.SetQueueEmployeeInClinic('" + txtDeptNameToAdd.Text + "');";
        //str += "SelectJQueryClose();";


        //ClientScript.RegisterStartupScript(this.GetType(), "close", str, true);

    }

    protected void SendMailToAdministrator()
    {
        string MailTo = System.Configuration.ConfigurationManager.AppSettings["ReportClinicChangeToMail"].ToString();

        string UserName = currentUser.UserNameWithPrefix;

        applicFacade.SendReportClinicNameChange(currentDeptCode, GetAbsoluteUrl(currentDeptCode), MailTo, UserName);
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

    protected void btnDelete_click(object sender, EventArgs e)
    {
        ImageButton btn = sender as ImageButton;
        int rowIndex = (btn.NamingContainer as GridViewRow).RowIndex;

        if (rowIndex > 0 && rowIndex < dtDeptNames.Rows.Count - 1)
        {
            DateTime nextFromDate = Convert.ToDateTime(dtDeptNames.Rows[rowIndex + 1]["FromDate"]);
            dtDeptNames.Rows[rowIndex - 1]["ToDate"] = nextFromDate.AddDays(-1);
        }
        else
        {
            if (rowIndex == dtDeptNames.Rows.Count - 1)
                dtDeptNames.Rows[rowIndex - 1]["ToDate"] = DBNull.Value;
        }

        dtDeptNames.Rows[rowIndex].Delete();
        dtDeptNames.AcceptChanges();

        PopulateGrids();

        //if (Session["deptNamesRowIndexToBeDeleted"] != null)
        //{
        //    if (Convert.ToInt32(Session["deptNamesRowIndexToBeDeleted"]) == e.RowIndex)
        //    {
        //        Session["deptNamesRowIndexToBeDeleted"] = null;
        //        PopulateGrids();       
        //        return;
        //    }
        //}
        //else
        //    Session["deptNamesRowIndexToBeDeleted"] = e.RowIndex;

        //dtDeptNames.Rows[e.RowIndex].Delete();
        //PopulateGrids();       
    }

    protected void PopulateGrids()
    {
        //dtDeptNames.Rows[e.RowIndex].Delete();
        //dtDeptNames.AcceptChanges();

        gvDeptNames.DataSource = dtDeptNames;
        gvDeptNames.DataBind();

        gvDeptNamesHistory.DataSource = dtDeptNames;
        gvDeptNamesHistory.DataBind();
    }

    /// <summary>
    /// check if the last status that was updated is not "not active temporarily"
    /// </summary>
    /// <returns></returns>

    protected void gvDeptStatusHistory_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lbl = e.Row.FindControl("lblToDate") as Label;
            if (lbl.Text != string.Empty)
            {
                if (Convert.ToDateTime(lbl.Text).AddDays(1) > DateTime.Now)
                {
                    e.Row.Style.Add("display", "none");
                }
            }
            else
            {
                e.Row.Style.Add("display", "none");
            }
        }
    }

    private void InitializeViewFromGlobalResources()
    {
        string notValidChar = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "NotValidChar_ErrorMess") as string;
        string notValidWords = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "PreservedWord_ErrorMess") as string;
        string notValidInteger = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "IntegerOnly_ErrorMess") as string;

        vldRegexDeptNameToAdd.ErrorMessage = string.Format(notValidChar, "מרפאה");
        vldRegexDeptNameToAdd.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        vldPreservedWordsDeptNameToAdd.ErrorMessage = string.Format(notValidWords, "מרפאה");
    }

    protected void ddlDeptLevel_selectedIndexChanged(object sender, EventArgs e)
    {
        ddlDisplayPriority.SelectedIndex = -1;

        ToggleDisplayPriorityByDeptLevel();
    }
}

