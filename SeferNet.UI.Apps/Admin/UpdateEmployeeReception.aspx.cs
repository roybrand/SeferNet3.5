using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;
using System.Configuration;

public partial class Admin_UpdateEmployeeReception : System.Web.UI.Page
{
    private bool IsDoctor;
    private bool HasServicesSubjectToReceiveGuest;
    DataTable receptionHoursBeforeUpdate;
    public long EmployeeID
    {
        get
        {
            if (ViewState["employeeID"] != null)
            {
                return Convert.ToInt64(ViewState["employeeID"]);
            }
            else
                return 0;
        }
        set
        {
            ViewState["employeeID"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request.UrlReferrer != null)
            {
                ViewState["lastPage"] = Request.UrlReferrer;
            }

            GetEmployeeDetails();
            SetHasServicesToReceiveGuest();
            BindEmployeeReceptionHours();
        }

    }

    private void GetEmployeeDetails()
    {
        EmployeeBO bo = new EmployeeBO();
        EmployeeID = SessionParamsHandler.GetEmployeeIdFromSession();

        if (EmployeeID == 0) // check if we lost the session
        {
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL);
            Response.End();
        }

        DataSet ds = bo.GetEmployee(EmployeeID);

        if (ds != null && ds.Tables[0] != null)
        {
            DataRowView row = ds.Tables[0].DefaultView[0];
            lblDegree.Text = row["degreeName"].ToString();
            lblSector.Text = row["EmployeeSectorDescription"].ToString();
            lblName.Text = row["firstName"].ToString() + " " + row["lastName"].ToString();
            lblSpeciality.Text = row["expert"].ToString();

            if (Convert.ToInt32(row["IsDoctor"]) != 1)
            {
                IsDoctor = false;
            }
            else
            {
                IsDoctor = true;
            }
        }
    }

    private void BindEmployeeReceptionHours()
    {
        DataSet receptionDs = new DataSet();
        ReceptionHoursManager receptionManager = new ReceptionHoursManager();

        Facade.getFacadeObject().GetEmployeeReceptions(ref receptionDs, EmployeeID);
        DataTable inputDt = receptionDs.Tables[0];
        DataTable groupingDt = receptionDs.Tables[1];
        DataTable viewTbl = receptionManager.GenerateGridTable(ref inputDt, ref groupingDt);

        ViewState["receptionHoursBeforeUpdate"] = inputDt;

        gvReceptionHours.Width = Unit.Parse("980");
        gvReceptionHours.EmployeeID = EmployeeID;
        gvReceptionHours.dtOriginalData = receptionDs.Tables[0];
        gvReceptionHours.ReceptionHoursOfDoctor = IsDoctor;
        gvReceptionHours.HasServicesSubjectToReceiveGuest = HasServicesSubjectToReceiveGuest;
        gvReceptionHours.Dept = -1;
        gvReceptionHours.DataBind();
    }

    private void SetHasServicesToReceiveGuest()
    {
        DataSet ds = new DataSet();
        EmployeeProfessionBO profBo = new EmployeeProfessionBO();
        ds = profBo.GetEmployeeProfessions(EmployeeID);

        HasServicesSubjectToReceiveGuest = false;

        if (ds != null && ds.Tables[0].Rows.Count > 0)
        {
            string ServicesToReceiveGuests = ConfigurationManager.AppSettings["ServicesRelevantForReceivingGuests"].ToString();

            var relevantServices = ServicesToReceiveGuests.Split(',');

            for (int i = 0; i < relevantServices.Length; i++)
            {
                for (int ii = 0; ii < ds.Tables[0].Rows.Count; ii++)
                {
                    if (relevantServices[i] == ds.Tables[0].Rows[ii]["professionCode"].ToString())
                    {
                        HasServicesSubjectToReceiveGuest = true;
                    }
                }
            }
        }
    }

    protected void btnCancel_click(object sender, EventArgs e)
    {
        GoBackToLastPage();
    }

    private void GoBackToLastPage()
    {
        if (ViewState["lastPage"] != null)
        {
            Response.Redirect(ViewState["lastPage"].ToString());
        }
        else
        {
            Response.Redirect("~/Public/ZoomDoctor.aspx");
        }
    }

    protected void btnSave_click(object sender, EventArgs e)
    {
        bool result = true;
        DataTable hoursDt = gvReceptionHours.ReturnData(true);
        DoctorHoursBO bo = new DoctorHoursBO();
        UserInfo currentUser = Session["currentUser"] as UserInfo;

        result = Facade.getFacadeObject().UpdateEmployeeReceptions(EmployeeID, hoursDt, currentUser.UserNameWithPrefix);

        Facade.getFacadeObject().UpdateEmployeeInClinicPreselected(EmployeeID, null, null);

        if (ViewState["receptionHoursBeforeUpdate"] != null)
            receptionHoursBeforeUpdate = (DataTable)ViewState["receptionHoursBeforeUpdate"];

        Report_hours_change(ref receptionHoursBeforeUpdate, ref hoursDt);

        if (result == true)
            GoBackToLastPage();

    }

    private bool Report_hours_change(ref DataTable tblBefore, ref DataTable tblAfter)
    {
        bool hasChanged = false;
        bool ReceptionID_WasFoundInNewTable = false;
        string remarkBefore, remarkAfter;
        string deptsWhereReceptionsHasBeenChanged = string.Empty;

        UserInfo currentUser = Session["currentUser"] as UserInfo;

        if (tblBefore == null && tblAfter == null)
        {
            return false;
        }

        for (int i = 0; i < tblBefore.Rows.Count; i++)
        {
            hasChanged = true;
            ReceptionID_WasFoundInNewTable = false;

            if (tblBefore.Rows[i]["receptionID"] == DBNull.Value)
                continue;

            for (int ii = 0; ii < tblAfter.Rows.Count; ii++)
            {
                if (tblAfter.Rows[ii]["receptionID"] == DBNull.Value)
                    continue;

                if (tblBefore.Rows[i]["RemarkText"] == DBNull.Value)
                    remarkBefore = string.Empty;
                else
                    remarkBefore = tblBefore.Rows[i]["RemarkText"].ToString();

                if (tblAfter.Rows[ii]["RemarkText"] == DBNull.Value)
                    remarkAfter = string.Empty;
                else
                    remarkAfter = tblAfter.Rows[ii]["RemarkText"].ToString();

                if(Convert.ToInt32(tblBefore.Rows[i]["receptionID"]) == Convert.ToInt32(tblAfter.Rows[ii]["receptionID"]))
                { 
                    if ((Convert.ToInt32(tblBefore.Rows[i]["ItemID"]) != Convert.ToInt32(tblAfter.Rows[ii]["ItemID"]) ||
                        Convert.ToInt16(tblBefore.Rows[i]["receptionDay"]) != Convert.ToInt16(tblAfter.Rows[ii]["receptionDay"]) ||

                        tblBefore.Rows[i]["openingHour"].ToString() != tblAfter.Rows[ii]["openingHour"].ToString() ||
                        tblBefore.Rows[i]["closingHour"].ToString() != tblAfter.Rows[ii]["closingHour"].ToString() ||
                        tblBefore.Rows[i]["ReceptionRoom"].ToString() != tblAfter.Rows[ii]["ReceptionRoom"].ToString() ||
                        tblBefore.Rows[i]["ReceiveGuests"].ToString() != tblAfter.Rows[ii]["ReceiveGuests"].ToString() ||

                        remarkBefore != remarkAfter))
                    {
                        if(deptsWhereReceptionsHasBeenChanged.IndexOf(tblBefore.Rows[i]["DeptCode"].ToString()) == -1)
                            deptsWhereReceptionsHasBeenChanged += tblBefore.Rows[i]["DeptCode"].ToString() + ",";
                    }

                    ReceptionID_WasFoundInNewTable = true;
                }

            }

            if (!ReceptionID_WasFoundInNewTable)
            {
                if (deptsWhereReceptionsHasBeenChanged.IndexOf(tblBefore.Rows[i]["DeptCode"].ToString()) == -1)
                    deptsWhereReceptionsHasBeenChanged += tblBefore.Rows[i]["DeptCode"].ToString() + ",";
            }
        }

        for (int ii = 0; ii < tblAfter.Rows.Count; ii++)
        {
            if (tblAfter.Rows[ii]["Add_ID"] != DBNull.Value && tblAfter.Rows[ii]["openingHour"].ToString() != string.Empty)
            {
                if (tblBefore.Rows.Count >= (ii + 1))
                {
                    if (deptsWhereReceptionsHasBeenChanged.IndexOf(tblBefore.Rows[ii]["DeptCode"].ToString()) == -1)
                        deptsWhereReceptionsHasBeenChanged += tblBefore.Rows[ii]["DeptCode"].ToString() + ",";
                }
                else
                { 
                    deptsWhereReceptionsHasBeenChanged += tblAfter.Rows[ii]["DeptCode"].ToString() + ",";
                }
            }
        }

        // Log changes if needed
        if (deptsWhereReceptionsHasBeenChanged.Length > 0)
        {
            deptsWhereReceptionsHasBeenChanged = deptsWhereReceptionsHasBeenChanged.Substring(0, deptsWhereReceptionsHasBeenChanged.Length - 1);
            string[] deptsList = deptsWhereReceptionsHasBeenChanged.Split(',');

            for (int i = 0; i < deptsList.Length; i++)
            {
                Facade.getFacadeObject().Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicHoursAndRemark_Update, currentUser.UserID, Convert.ToInt32(deptsList[i]), EmployeeID, -1, null, null, null, null);
            }
        }

        return hasChanged;

    }

}
