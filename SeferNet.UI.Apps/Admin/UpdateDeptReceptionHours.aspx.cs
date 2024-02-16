using System;
using SeferNet.BusinessLayer.WorkFlow;
using System.Data;
using SeferNet.BusinessLayer.BusinessObject; 
using SeferNet.FacadeLayer;
using SeferNet.Globals;
using System.Collections.Specialized;
using SeferNet.UI;
using System.Web.UI;

public partial class Admin_UpdateDeptReceptionHours : System.Web.UI.Page
{
    private int _deptCode = -1;
    private string  _deptName = String.Empty;
    Facade applicFacade = null;
    UserInfo currentUser;

    
    
    protected void Page_Load(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();

        _deptCode = SessionParamsHandler.GetDeptCodeFromSession();

        _deptName = SessionParamsHandler.GetDeptNameFromSession();


        if (!IsPostBack)
        {
            string query = Request.UrlReferrer.Query.ToString();
            query = query.Remove(0, 1);
            Master.PreviousPage = Request.UrlReferrer.AbsolutePath.ToString() + "?" + RequestHelper.removeFromQueryString(query, "seltab");

            if (_deptName != String.Empty)
            {
                lblDeptName.Text = _deptName;
                lblDeptName_2.Text = _deptName;
            }


            if (_deptCode != -1)
            {
                Dept dept = applicFacade.GetDeptGeneralBelongings(_deptCode);
                DataSet ds = applicFacade.GetReceptionTypesByGeneralBelongings(dept.IsCommunity, dept.IsMushlam, dept.IsHospital);

                //UIHelper.BindDropDownToCachedTable(ddlReceptionHoursTypes, "DIC_ReceptionHoursTypes", "ReceptionHoursTypeID");
                ddlReceptionHoursTypes.DataSource = ds.Tables[0];
                ddlReceptionHoursTypes.DataBind();

                ddlReceptionHoursTypes.Items.FindByValue(SessionParamsHandler.GetSessionParams().DefaultReceptionHoursTypeIDForClinic.ToString()).Selected = true;
               

                BindReceptionHoursGridView(_deptCode);

            }

            ddlReceptionHoursTypes.Attributes.Add("onchange", "changeReceptionHoursTypes();");
            hfSelectedHourTypeIDForUpdate.Value = ddlReceptionHoursTypes.SelectedValue;
        }
        else
        {
            if (hfOnSelectedChangeEventFlag.Value == "1")
            {
                if (hfUpdateFlag.Value == "1")
                {
                    bool result = updateReceptionHours(int.Parse(hfSelectedHourTypeIDForUpdate.Value));
                    
                }
                gvReceptionHours.get_dgReceptionHours.EditIndex = -1;
                _deptCode = SessionParamsHandler.GetDeptCodeFromSession();
                BindReceptionHoursGridView(_deptCode);
            }
            hfSelectedHourTypeIDForUpdate.Value = ddlReceptionHoursTypes.SelectedValue;
            hfUpdateFlag.Value = "";
            hfOnSelectedChangeEventFlag.Value = "";
        }

        // Show or not Button "סגירה זמנית"
        if (hfSelectedHourTypeIDForUpdate.Value == "1")
        {
            tblTemporarilyClose.Attributes.Add("style", "display:block");
        }
        else {
            tblTemporarilyClose.Attributes.Add("style", "display:none");
        }
        //tblTemporarilyClose
    }

    protected void Page_Prerender(object sender, EventArgs e)
    {
        if (hfCreateTemporarilyClosedFlag.Value == "1")
        {
            gvReceptionHours.get_dgReceptionHours.EditIndex = -1;
            _deptCode = SessionParamsHandler.GetDeptCodeFromSession();
            BindReceptionHoursGridView(_deptCode);

            hfCreateTemporarilyClosedFlag.Value = "";
        }
    }

    protected void btnCopyClinicHours_Click(object sender, EventArgs e)
    {
        DataSet receptionDs = new DataSet();
        ReceptionHoursManager receptionManager = new ReceptionHoursManager();
        if (gvReceptionHours.dtOriginalData.Rows.Count > 0 && gvReceptionHours.dtOriginalData.Rows[0]["receptionDay"] != DBNull.Value)
        {
            // return false
            string messageText = "העתקה השעות אינה אפשרית מכיוון שלסוג שעות הנבחר קיימות שעות מוזנות.";
            ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "AlertMessage", "alert('" + messageText + "');", true);
        }
        else
        {
            DataSet receptionHoursDs = new DataSet();
            _deptCode = SessionParamsHandler.GetDeptCodeFromSession();

            int receptionHoursType = 1; // שעות קבלה
            Facade.getFacadeObject().GetDeptReceptions(ref receptionDs, _deptCode, receptionHoursType);

            gvReceptionHours.dtOriginalData = receptionDs.Tables[0];
            gvReceptionHours.DataBind();
        }

    }

    private void BindReceptionHoursGridView(int deptCode)
    {
        DataSet receptionDs = new DataSet();
        ReceptionHoursManager receptionManager = new ReceptionHoursManager();

        Facade.getFacadeObject().GetDeptReceptions(ref receptionDs, deptCode, int.Parse(ddlReceptionHoursTypes.SelectedValue));
        DataTable inputDt = receptionDs.Tables[0];
        DataTable groupingDt = receptionDs.Tables[1];
         
        //DataTable viewTbl = receptionManager.GenerateGridTable(ref inputDt, ref groupingDt);
        gvReceptionHours.dtOriginalData = receptionDs.Tables[0];
        gvReceptionHours.DataBind();
    }

    protected void btnUpdateBottom_Click(object sender, EventArgs e)
    {
        bool result = updateReceptionHours(int.Parse(ddlReceptionHoursTypes.SelectedValue));

        if (result == true)
        {
            RedirectToLastPage();
        }
    }

    protected void btnCreateTemporarilyClosed_Click(object sender, EventArgs e)
    {
        string selectedDays = "";

        for (int i = 0; i < checkboxlistDays.Items.Count; i++)
        {
            if (checkboxlistDays.Items[i].Selected == true)// getting selected value from CheckBox List  
            {
                selectedDays += (i + 1).ToString() + "," ; // add selected Item text to the String .  
                //selectedDays += checkboxlistDays.Items[i].Value + "," ; // add selected Item text to the String .  
            }
        }
        DateTime dateFrom = Convert.ToDateTime(txtClosedFrom.Text);
        DateTime dateTo = Convert.ToDateTime(txtClosedTo.Text);
        int deptCode = _deptCode;
        currentUser = Session["currentUser"] as UserInfo;

        // Check WeekDaysNotInDateRange !!!!!!!!!!!!!!!!!

        DataSet ds = applicFacade.WeekDaysNotInDateRange(selectedDays, dateFrom, dateTo);

        string daysNotInDateRange = "";

        foreach (DataRow dr in ds.Tables[0].Rows)
        {
            if (Convert.ToInt32(dr["IsBetweenDates"]) == 0)
            {
                daysNotInDateRange += dr["ReceptionDayName"].ToString() + ",";
            }
        }

        if (daysNotInDateRange.Length > 0)
        {
            daysNotInDateRange = daysNotInDateRange.Remove(daysNotInDateRange.Length - 1, 1);

            lblWeekDaysNotInDateRange.Text = " נבחרו ימים אשר אינם בטווח התאריכים " + "( ימי " + daysNotInDateRange + " )";

            hfCreateTemporarilyClosedFlag.Value = string.Empty;

            ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "ShowTemporarilyClose", "ShowTemporarilyClose();", true);

            return;
        }

        bool result = applicFacade.UpdateDeptReception_TemporarilyClosed(_deptCode, selectedDays, dateFrom, dateTo, currentUser.UserNameWithPrefix);

        // Clear controls
        for (int i = 0; i < checkboxlistDays.Items.Count; i++)
        {
            checkboxlistDays.Items[i].Selected = false;// getting selected value from CheckBox List  
        }


        hfCreateTemporarilyClosedFlag.Value = "1";

        // Clear controls
        txtClosedFrom.Text = string.Empty;
        txtClosedTo.Text = string.Empty;

        //for (int i = 0; i < checkboxlistDays.Items.Count; i++)
        //{
        //    checkboxlistDays.Items[i].Selected = false;// getting selected value from CheckBox List  
        //}
    }

    private void RedirectToLastPage()
    {
        SessionParamsHandler.GetSessionParams().MarkServiceInClinicSelected = true; // we want to reach the exact tab we came from        
        
        Response.Redirect(Master.PreviousPage, true);
    }

    

    private bool updateReceptionHours(int receptionHoursTypeID)
    {
        DataTable dtReceptionHours = gvReceptionHours.ReturnData();

        currentUser = Session["currentUser"] as UserInfo;

        return applicFacade.UpdateDeptReceptionsTransaction(_deptCode, receptionHoursTypeID, dtReceptionHours, currentUser.UserNameWithPrefix);
    }     

    protected void btnBackToOpenerBottom_Click(object sender, EventArgs e)
    {
        RedirectToLastPage();
    }


    protected void ShowReceptionPreview(object sender, EventArgs e)
    {
        Session["ReceptionHours"] = gvReceptionHours.ReturnData();
        ScriptManager.RegisterStartupScript(this,this.GetType(), "preview", "OpenReceptionHoursPreview();", true);
    }

}
