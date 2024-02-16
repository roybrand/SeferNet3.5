using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;

public partial class Admin_ReceptionHoursPreview : AdminPopupBasePage
{

    private DataTable _receptionDt;
    private int _deptCode = -1;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindData();
        }
    }


    private void BindData()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["DeptCode"]))
        {
            _deptCode = Convert.ToInt32(Request.QueryString["DeptCode"]);
        }

        if (Request.QueryString["Employee"] != null)
        {
            BindEmployeeMode();
        }
        else
        {
            // if it's service - change the header
            if (Request.QueryString["service"] != null)
            {
                lblDeptReceptionCaption.Text = "שעות קבלה לשירות";
            }

            BindServiceOrDeptMode();
        }
    }

    private void BindServiceOrDeptMode()
    {
        divDeptReception.Visible = true;
        divEmployeeReceptionPerUnit.Visible = divEmployeeReceptionForAllUnits.Visible = false;

        if (Session["ReceptionHours"] != null)
        {
            _receptionDt = (DataTable)Session["ReceptionHours"];
            
            ReceptionHoursManager recManager = new ReceptionHoursManager();
            recManager.SetDayNameToTable(_receptionDt);

            DataTable uniqueDaysDt = FilterUniqueDays(_receptionDt);

            gvDeptReception.DataSource = uniqueDaysDt;
            gvDeptReception.DataBind();
        }
    }

    /// <summary>
    /// gets a datatable and returns a data table with one cloumn named "receptionDayName" contains the reception days distinct
    /// </summary>
    /// <param name="_receptionDt"></param>
    private DataTable FilterUniqueDays(DataTable receptionDt)
    {
        DataTable newDt = new DataTable();
        newDt.Columns.Add(new DataColumn("ReceptionDay", typeof(string)));
        newDt.Columns.Add(new DataColumn("ReceptionDayName", typeof(string)));
        List<string> doneDays = new List<string>();

        for (int i = 0; i < receptionDt.Rows.Count; i++)
        {
            if (!doneDays.Contains(receptionDt.Rows[i]["ReceptionDay"].ToString()))
            {
                doneDays.Add(receptionDt.Rows[i]["ReceptionDay"].ToString());
                
                DataRow row = newDt.NewRow();
                row["ReceptionDay"] = receptionDt.Rows[i]["ReceptionDay"].ToString();
                row["ReceptionDayName"] = receptionDt.Rows[i]["ReceptionDayName"].ToString();
                
                newDt.Rows.Add(row);
            }
        }

        newDt.DefaultView.Sort = "ReceptionDayName ASC";
        return newDt;
    }    

    private void BindEmployeeMode()
    {
        ReceptionHoursManager recManager = new ReceptionHoursManager();

        if (Session["ReceptionHours"] != null)
        {
            _receptionDt = (DataTable)Session["ReceptionHours"];

            if (_deptCode != -1)   // specific dept
            {
                divEmployeeReceptionPerUnit.Visible = true;
                divDeptReception.Visible = divEmployeeReceptionForAllUnits.Visible = false;

                DataTable doctorInfoDt = (DataTable)Session["doctorDetails"];

                lblEmployeeName.Text = doctorInfoDt.Rows[0]["doctorsName"].ToString();
                lblEmployeeProfessions.Text = doctorInfoDt.Rows[0]["expert"].ToString();
                lblClinicName.Text = doctorInfoDt.Rows[0]["DeptName"].ToString();
                lblFaxs.Text = doctorInfoDt.Rows[0]["fax"].ToString();
                lblPhone.Text = doctorInfoDt.Rows[0]["phonesOnly"].ToString();

                                
                recManager.GenerateGridTableFromReturnData(ref _receptionDt);
                gvOuterForEmployeeHours.DataSource = recManager.GetUniqueProfessionsFromDataTable(ref _receptionDt);
                gvOuterForEmployeeHours.DataBind();
            }
            else  // all depts 
            {
                divEmployeeReceptionForAllUnits.Visible = true;
                divDeptReception.Visible = divEmployeeReceptionPerUnit.Visible = false;

                recManager.SetDayNameToTable(_receptionDt);

                DataTable daysDt = recManager.ReturnUniqueDaysTable(_receptionDt, "ReceptionDay");
                gvEmployeeReceptionDays_All.DataSource = daysDt;
                gvEmployeeReceptionDays_All.DataBind();
            }
        }
    }

    protected void gvOuterForEmployeeHours_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView row = e.Row.DataItem as DataRowView;
            
            GridView gvDays = e.Row.FindControl("gvReceptionDays") as GridView;

            string selectStr = "professionOrServiceCode = " + row["code"].ToString();

            if (_deptCode != -1)
            {
                selectStr += " and deptCode=" + _receptionDt.Rows[0]["deptCode"].ToString();
            }

            DataRow[] days = _receptionDt.Select(selectStr);
            DataTable daysDt = days.CopyToDataTable();    
            
            ReceptionHoursManager rec = new ReceptionHoursManager();
            DataTable sourceDt = rec.GetUniqueProfessionsPerDays(daysDt);
            sourceDt.DefaultView.Sort = "ReceptionDay";
            gvDays.DataSource = sourceDt;           
            
            gvDays.DataBind();
        }
    }

    protected void gvReceptionDays_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView rowView = e.Row.DataItem as DataRowView;
            string receptionDay = rowView["receptionDay"].ToString();
            
            string professionCode = rowView["professionOrServiceCode"].ToString();

            DataRow[] hours = _receptionDt.Select("receptionDay=" + receptionDay + " and professionOrServiceCode = " + professionCode);
            DataTable hoursDt = hours.CopyToDataTable();
            hoursDt.DefaultView.Sort = "openingHour ASC";

            GridView gvHours = e.Row.FindControl("gvReceptionHours") as GridView;
            gvHours.DataSource = hoursDt;
            gvHours.DataBind();
        }
    }

    protected void gvDeptReception_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView row = e.Row.DataItem as DataRowView;
            GridView gvHours = e.Row.FindControl("gvDeptHours") as GridView;

            string day = row["ReceptionDay"].ToString();
            DataTable hoursDt = _receptionDt.Select("ReceptionDay='" + day + "'").CopyToDataTable();

            gvHours.DataSource = hoursDt;
            gvHours.DataBind();
        }
    }

    protected void gvEmployeeReceptionDays_All_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            GridView gvReceptionHours_All = e.Row.FindControl("gvReceptionHours_All") as GridView;
            DataRowView row = e.Row.DataItem as DataRowView;
            string day = row["receptionDay"].ToString();

            DataRow[] rows = _receptionDt.Select("receptionDay = " + day);
            gvReceptionHours_All.DataSource = rows.CopyToDataTable();
            gvReceptionHours_All.DataBind();            
        }
    }

    protected void gvReceptionHours_All_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lblReceptionRemarks = e.Row.FindControl("lblReceptionRemarks") as Label;
            
            string remark = ((DataRowView)e.Row.DataItem)["remarkText"].ToString();
            
            lblReceptionRemarks.Text = remark.Replace("#","");

            if (string.IsNullOrEmpty(lblReceptionRemarks.Text))
                lblReceptionRemarks.Text = "&nbsp;";
        }
    }
}
