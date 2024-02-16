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

using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.Globals;

public partial class Public_DoctorReceptionPopUp : System.Web.UI.Page
{
    private DataSet dsEmployee;
    private Facade applicFacade;
    private int deptEmployeeID;
    private string serviceCode;
    private bool TodayReceptionDialogMode = true;
    private DateTime expirationDate;
    private DateTime closestReceptionsChange = DateTime.MaxValue;
    string RemarkCategoriesForAbsence = System.Configuration.ConfigurationManager.AppSettings["RemarkCategoriesForAbsence"].ToString();
    string RemarkCategoriesForClinicActivity = System.Configuration.ConfigurationManager.AppSettings["RemarkCategoriesForClinicActivity"].ToString();
    bool serviceRelevantForReceivingGuests = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();

        this.deptEmployeeID = Convert.ToInt32(Request.QueryString["deptEmployeeID"]);

        if (!string.IsNullOrEmpty(Request.QueryString["serviceCode"]))
            this.serviceCode = Request.QueryString["serviceCode"].ToString();
        else
            this.serviceCode = string.Empty;

        expirationDate = DateTime.Now;

        //---- expirationDate
        if (!string.IsNullOrEmpty(Request.QueryString["expirationDate"]) &&
            !string.IsNullOrEmpty(Request.QueryString["expirationDate"].Trim()) &&
            Request.QueryString["expirationDate"].Trim() != "null" &&
            DateTime.TryParse(Request.QueryString["expirationDate"], out expirationDate))
        {
            this.TodayReceptionDialogMode = false;
        }
        else
        {
            expirationDate = DateTime.Now;
            this.TodayReceptionDialogMode = true;
        }


        this.dsEmployee = applicFacade.getEmployeeReceptionAndRemarks(deptEmployeeID, serviceCode, expirationDate);

        if (dsEmployee.Tables["employeeName"] == null)
            return;


        this.BindWindow();
        //BindTitleLables();
        //BindHours();
        //BindRemarks();
        //BindDeptName();
    }

    private void BindLblFromExpDate(GridViewRowEventArgs e)
    {
        Label lblFromExpDate = (Label)e.Row.FindControl("lblFromExpDat");
        if (this.TodayReceptionDialogMode)
        {
            lblFromExpDate.Style["display"] = "none";
        }
        else
        {
            lblFromExpDate.Text = HttpContext.GetGlobalResourceObject("ApplicResources", "FromExperationDate") as string
                + " " + expirationDate.ToShortDateString();
            lblFromExpDate.Style["display"] = "inline";
        }
    }

    protected void gvOuterForEmployeeHours_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            closestReceptionsChange = DateTime.MaxValue;

            this.BindLblFromExpDate(e);

            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            GridView gvEmployeeReceptionDays = (GridView)e.Row.FindControl("gvEmployeeReceptionDays");
            DataTable tblDoctorReception = this.dsEmployee.Tables["doctorReception"];
            int professionOrServiceCode = Convert.ToInt32(dvRowView["professionOrServiceCode"]);

            serviceRelevantForReceivingGuests = Utils.IsServiceRelevantForReceivingGuests(professionOrServiceCode);

            DataView dvEmployeeReceptionDays;
            string strSelectConditions = "DeptEmployeeID = " + this.deptEmployeeID.ToString() + " AND professionOrServiceCode = '" + professionOrServiceCode.ToString() + "'";
            dvEmployeeReceptionDays = new DataView(tblDoctorReception,
                strSelectConditions,
                "receptionDay", DataViewRowState.CurrentRows);

            DataRow[] dr = tblDoctorReception.Select(strSelectConditions, "receptionDay");
            DataTable tblDaysForReception_DISTINCT = tblDoctorReception.Clone();
            foreach (DataRow dataR in dr)
            {
                if (tblDaysForReception_DISTINCT.Select("receptionDay = '" + dataR["receptionDay"].ToString() + "'").Length == 0)
                {
                    DataRow drNew = tblDaysForReception_DISTINCT.NewRow();
                    drNew.ItemArray = dataR.ItemArray;
                    tblDaysForReception_DISTINCT.Rows.Add(drNew);
                }
            }

            if (dvEmployeeReceptionDays.Count > 0)
            {
                gvEmployeeReceptionDays.DataSource = tblDaysForReception_DISTINCT;
                gvEmployeeReceptionDays.DataBind();
            }


            CheckIfNeedExpireWarning(professionOrServiceCode, e.Row);
        }
    }

    protected void gvEmployeeReceptionDays_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            GridView gvReceptionHours = (GridView)e.Row.FindControl("gvReceptionHours");
            DataTable tblDoctorReception = this.dsEmployee.Tables["doctorReception"];

            string strConditions = "DeptEmployeeID = " + this.deptEmployeeID.ToString() +
                                    " AND receptionDay = " + dvRowView["receptionDay"].ToString() +
                                    " AND professionOrServiceCode = '" + dvRowView["professionOrServiceCode"].ToString() + "'";

            DataView dvReceptionHours = new DataView(tblDoctorReception, strConditions, "openingHour", DataViewRowState.CurrentRows);

            if (dvReceptionHours.Count > 0)
            {
                gvReceptionHours.DataSource = dvReceptionHours;
                gvReceptionHours.DataBind();
            }
        }
    }

    protected void gvReceptionHours_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRow dr = ((DataRowView)e.Row.DataItem).Row;

            if (this.TodayReceptionDialogMode && Convert.ToInt32(dr["willExpireIn"]) < 15)
            {
                DateTime currChangeDate = Convert.ToDateTime(dr["expirationDate"]);

                if (currChangeDate < closestReceptionsChange)
                {
                    closestReceptionsChange = currChangeDate;
                    closestReceptionsChange = closestReceptionsChange.AddDays(1);
                }
            }

            Image imgReceiveGuests = e.Row.FindControl("imgReceiveGuests") as Image;

            if (serviceRelevantForReceivingGuests)
            {
                if (imgReceiveGuests != null && ((System.Data.DataRowView)(e.Row.DataItem))["ReceiveGuests"] != System.DBNull.Value)
                {
                    if (Convert.ToBoolean(dr["ReceiveGuests"]) == true)
                    {
                        imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuestsSmall.png";
                        imgReceiveGuests.ToolTip = "הרופא מקבל אורחים";
                    }
                    else if (Convert.ToBoolean(dr["ReceiveGuests"]) == false)
                    {
                        imgReceiveGuests.ImageUrl = "~/Images/Applic/NOTreceiveGuestsSmall.png";
                        imgReceiveGuests.ToolTip = "הרופא אינו מקבל אורחים";
                    }
                }
                else
                {
                    imgReceiveGuests.ImageUrl = "~/Images/Applic/NOTreceiveGuestsSmall.png";
                    imgReceiveGuests.ToolTip = "הרופא אינו מקבל אורחים";
                }

            }
            else
            {
                imgReceiveGuests.Visible = false;
            }
        }
    }

    protected void gvDoctorRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            Image imgInternet = e.Row.FindControl("imgInternet") as Image;
            if (Convert.ToBoolean(dvRowView["displayInInternet"]) == true)
            {
                //imgInternet.Style.Add("display", "none");
                imgInternet.Visible = false;
            }
            else
            {
                imgInternet.Style.Add("display", "inline");
                imgInternet.ImageUrl = "../Images/Applic/pic_NotShowInInternet.gif";
                imgInternet.ToolTip = "לא תוצג באינטרנט";
            }

            string[] RemarkCategoriesForAbsenceArr = RemarkCategoriesForAbsence.Split(',');
            for (int i = 0; i < RemarkCategoriesForAbsenceArr.Length; i++)
            {
                if (RemarkCategoriesForAbsenceArr[i] == dvRowView["RemarkCategoryID"].ToString())
                {
                    Label lblRemark = e.Row.FindControl("lblRemark") as Label;
                    lblRemark.CssClass = "LabelBoldRed_13";
                }
            }

        }
    }

    protected void gvClinicActivityRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            //Image imgInternet = e.Row.FindControl("imgInternet") as Image;
            //if (Convert.ToBoolean(dvRowView["displayInInternet"]) == true)
            //{
            //    //imgInternet.Style.Add("display", "none");
            //    imgInternet.Visible = false;
            //}
            //else
            //{
            //    imgInternet.Style.Add("display", "inline");
            //    imgInternet.ImageUrl = "../Images/Applic/pic_NotShowInInternet.gif";
            //    imgInternet.ToolTip = "לא תוצג באינטרנט";
            //}

            string[] RemarkCategoriesForClinicActivityArr = RemarkCategoriesForClinicActivity.Split(',');
            for (int i = 0; i < RemarkCategoriesForClinicActivityArr.Length; i++)
            {
                if (RemarkCategoriesForClinicActivityArr[i] == dvRowView["RemarkCategoryID"].ToString())
                {
                    Label lblRemark = e.Row.FindControl("lblRemark") as Label;
                    lblRemark.CssClass = "LabelBoldRed_13";
                }
            }

        }
    }

    protected void gvClinicRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //if (e.Row.RowType == DataControlRowType.DataRow)
        //{
        //    DataRowView dvRowView = e.Row.DataItem as DataRowView;

        //    string[] RemarkCategoriesForClinicActivityArr = RemarkCategoriesForClinicActivity.Split(',');
        //    for (int i=0; i < RemarkCategoriesForClinicActivityArr.Length; i++)
        //    {
        //        if (RemarkCategoriesForClinicActivityArr[i] == dvRowView["RemarkCategoryID"].ToString())
        //        {
        //            Label lblRemark = e.Row.FindControl("lblRemark") as Label;
        //            lblRemark.CssClass = "LabelBoldRed_13";
        //        }
        //    }
        //}
    }

    protected void BindWindow()
    {
        DataTable tblDoctorReception = this.dsEmployee.Tables["doctorReception"];

        this.lblEmployeeName_EmployeeReception.Text = this.dsEmployee.Tables["employeeName"].Rows[0]["employeeName"].ToString();
        this.lblClinicName_EmployeeReception.Text = this.dsEmployee.Tables["employeeName"].Rows[0]["deptName"].ToString();

        //------- get employee's phones AS STRING for PopUp Reception Title
        string employeePhonesInClinic = string.Empty;
        DataRow[] drDeptEmployeePhones = this.dsEmployee.Tables["DeptEmployeePhones"].Select("DeptEmployeeID = " + this.deptEmployeeID.ToString() + " AND phoneType <> 2 ", "phoneType, phoneOrder");
        foreach (DataRow dataR in drDeptEmployeePhones)
        {
            if (employeePhonesInClinic != string.Empty)
                employeePhonesInClinic += ", ";
            employeePhonesInClinic += dataR["phone"].ToString();
        }

        if (!string.IsNullOrEmpty(employeePhonesInClinic))
        {
            lblPhone_EmployeeReception.Text = employeePhonesInClinic;
        }
        else
        {
            lblPhone_EmployeeReception.Visible = lblPhoneCaption_EmployeeReception.Visible = false;
        }


        //-------- get employee's faxes AS STRING for PopUp Reception Title
        employeePhonesInClinic = string.Empty;
        DataRow[] drDeptEmployeeFaxes = this.dsEmployee.Tables["DeptEmployeePhones"].Select("DeptEmployeeID = " + this.deptEmployeeID.ToString() + " AND phoneType = 2 ", "phoneType, phoneOrder");
        foreach (DataRow dataR in drDeptEmployeeFaxes)
        {
            if (employeePhonesInClinic != string.Empty)
                employeePhonesInClinic += ", ";
            employeePhonesInClinic += dataR["phone"].ToString();
        }
        if (!string.IsNullOrEmpty(employeePhonesInClinic))
        {
            lblFax_EmployeeReception.Text = employeePhonesInClinic;
        }
        else
        {
            lblFax_EmployeeReception.Visible = lblFaxCaption_EmployeeReception.Visible = false;
        }

        //-------- Bind "gvOuterForEmployeeHours" 
        DataView dvOuterForEmployeeHours;

        ReceptionHoursManager bl = new ReceptionHoursManager();
        bl.GenerateGridTable(ref tblDoctorReception);

        DataRow[] dr = tblDoctorReception.Select("DeptEmployeeID = " + this.deptEmployeeID.ToString(), "professionOrServiceCode");
        DataTable tblProffAndServForReception_DISTINCT = tblDoctorReception.Clone();
        foreach (DataRow dataR in dr)
        {
            if (tblProffAndServForReception_DISTINCT.Select("professionOrServiceCode = '" + dataR["professionOrServiceCode"].ToString() + "'").Length == 0)
            {
                DataRow drNew = tblProffAndServForReception_DISTINCT.NewRow();
                drNew.ItemArray = dataR.ItemArray;
                tblProffAndServForReception_DISTINCT.Rows.Add(drNew);
            }
        }

        dvOuterForEmployeeHours = new DataView(tblDoctorReception,
            "DeptEmployeeID = " + this.deptEmployeeID.ToString(), "professionOrServiceCode", DataViewRowState.CurrentRows);

        if (dvOuterForEmployeeHours.Count > 0)
        {
            this.gvOuterForEmployeeHours.DataSource = tblProffAndServForReception_DISTINCT;
            this.gvOuterForEmployeeHours.DataBind();
        }


        BindFutureReceptionsIfNeeded();


        //------------ Bind "gvDoctorRemarks"
        DataTable tblEmployeeRemarks = this.dsEmployee.Tables["employeeRemark"];
        DataTable tblClinicActivityRemarks = this.dsEmployee.Tables["ClinicActivityRemarks"];
        DataView dvClinicActivityRemarks = new DataView(tblClinicActivityRemarks, "RemarkCategoryID in (" + RemarkCategoriesForClinicActivity + ")", "", DataViewRowState.CurrentRows);
        DataView dvClinicRemarks = new DataView(tblClinicActivityRemarks, "RemarkCategoryID NOT in (" + RemarkCategoriesForClinicActivity + ")", "", DataViewRowState.CurrentRows);

        if (tblEmployeeRemarks.Rows.Count > 0 || tblClinicActivityRemarks.Rows.Count > 0)
        {
            this.trRemarksCaption.Style.Add("display", "inline");

            if (tblEmployeeRemarks.Rows.Count > 0)
            {
                this.gvDoctorRemarks.DataSource = tblEmployeeRemarks;
                this.gvDoctorRemarks.DataBind();
            }

            if (dvClinicActivityRemarks.Count > 0)
            {
                this.gvClinicActivityRemarks.DataSource = dvClinicActivityRemarks;
                this.gvClinicActivityRemarks.DataBind();
            }

            if (dvClinicRemarks.Count > 0)
            {
                this.gvClinicRemarks.DataSource = dvClinicRemarks;
                this.gvClinicRemarks.DataBind();
            }
        }

        //ClinicActivityRemarks
    }

    private void BindFutureReceptionsIfNeeded()
    {
        DataTable futureReceptionsDt = dsEmployee.Tables["closestNewReception"];

        if (futureReceptionsDt.Rows.Count > 0)
        {

            DataTable newReceptionsDt = futureReceptionsDt.Clone();

            for (int i = 0; i < futureReceptionsDt.Rows.Count; i++)
            {

                if (dsEmployee.Tables["doctorReception"].Select("professionOrServiceCode=" +
                                                        futureReceptionsDt.Rows[i]["ServiceOrProfessionCode"].ToString()).Length == 0)
                {

                    newReceptionsDt.ImportRow(futureReceptionsDt.Rows[i]);
                }
            }

            if (newReceptionsDt.Rows.Count > 0)
            {
                gvFutureProfessionsReceptions.DataSource = newReceptionsDt;
                gvFutureProfessionsReceptions.DataBind();
            }
        }
    }

    private void CheckIfNeedExpireWarning(int professionCode, GridViewRow row)
    {
        if (dsEmployee.Tables["closestNewReception"].Rows.Count > 0)
        {
            DataTable dtChanges = dsEmployee.Tables["closestNewReception"];
            DataRow[] results = dtChanges.Select("ServiceOrProfessionCode=" + professionCode);

            if (results.Length > 0)
            {
                DateTime addReceptionDate = Convert.ToDateTime(results[0]["ChangeDate"]);

                if (addReceptionDate < closestReceptionsChange)
                {
                    closestReceptionsChange = addReceptionDate;
                }
            }
        }

        if (closestReceptionsChange < DateTime.MaxValue)
        {
            Label lnkExpireWarning = row.FindControl("lnkExpireWarning") as Label;
            HtmlContainerControl divExpire = row.FindControl("divExpire") as HtmlContainerControl;

            divExpire.Attributes.Add("onclick", "OpenEmployeeExpirationReceptionWindow(" + deptEmployeeID.ToString() + "," + serviceCode +
                                                        ",'" + closestReceptionsChange.ToShortDateString() + "')");

            lnkExpireWarning.Visible = true;
            lnkExpireWarning.Text = string.Format(ConstsSystem.EXPIRE_MESSAGE, closestReceptionsChange.ToShortDateString());
        }
    }

    protected void gvFutureProfessionsReceptions_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HtmlContainerControl divExpire = e.Row.FindControl("divExpire") as HtmlContainerControl;
            DateTime changeDate = Convert.ToDateTime(((DataRowView)e.Row.DataItem)["ChangeDate"]);

            divExpire.Attributes.Add("onclick", "OpenEmployeeExpirationReceptionWindow(" + deptEmployeeID.ToString() + "," + serviceCode +
                                                        ",'" + changeDate.ToShortDateString() + "')");

            Label lblWarning = e.Row.FindControl("lnkExpireWarning") as Label;

            lblWarning.Text = string.Format(ConstsSystem.EXPIRE_MESSAGE, changeDate.ToShortDateString());
        }
    }
}

