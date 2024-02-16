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

public partial class EmployeeReceptionExpirationPopUp : System.Web.UI.Page
{
    DataSet m_dsEmployee;
    Facade applicFacade;
    int currentDayCode = 0;

    int employeeID;
    DateTime expirationDate;

    protected void Page_Load(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();

        employeeID = Convert.ToInt32(Request.QueryString["EmployeeID"]);
        expirationDate = Convert.ToDateTime(Request.QueryString["expirationDate"]);

        m_dsEmployee = applicFacade.GetEmployeeReceptionAfterExpiration(employeeID, expirationDate);

        if (m_dsEmployee.Tables["doctorDetails"] == null)
            return;

        BindEmployeeHeader();
        BindDoctorHours();
    }

    public bool BindDoctorHours()
    {
        DataTable tblDoctorReception = m_dsEmployee.Tables["doctorReceptionHours"];

        DataRow[] dr = tblDoctorReception.Select();
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

        if (tblDaysForReception_DISTINCT.Rows.Count > 0)
        {
            gvEmployeeReceptionDays_All.DataSource = tblDaysForReception_DISTINCT;
            gvEmployeeReceptionDays_All.DataBind();
        }

        return true;
    }

    protected void gvEmployeeReceptionDays_All_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            GridView gvReceptionHours_All = (GridView)e.Row.FindControl("gvReceptionHours_All");
            DataTable tblDoctorReception = m_dsEmployee.Tables["doctorReceptionHours"];

            DataView dvReceptionHours;
            string strConditions = " receptionDay = " + dvRowView["receptionDay"].ToString();

            dvReceptionHours = new DataView(tblDoctorReception, strConditions, "openingHour", DataViewRowState.CurrentRows);

            if (dvReceptionHours.Count > 0)
            {
                gvReceptionHours_All.DataSource = dvReceptionHours;
                gvReceptionHours_All.DataBind();
            }
        }
    }

    protected void gvReceptionHours_All_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            HtmlTable gvReceptionHours_All = (HtmlTable)e.Row.FindControl("tblReceptionHours_Inner");
            DataTable tblDoctorReception = m_dsEmployee.Tables["doctorReceptionHours"];
            if (currentDayCode != 0 && currentDayCode == Convert.ToInt32(dvRowView["receptionDay"]))
                gvReceptionHours_All.Style.Add("border-top", "1px solid #DDDDDD");

            currentDayCode = Convert.ToInt32(dvRowView["receptionDay"]);
        }
    }

    public bool BindEmployeeHeader()
    {
        //// get employee's phones AS STRING for PopUp Reception Title
        //string employeePhonesInClinic = string.Empty;
        //DataRow[] drDeptEmployeePhones = m_dsEmployee.Tables["DeptEmployeePhones"].Select("phoneType <> 2 ", "phoneType, phoneOrder");
        //foreach (DataRow dataR in drDeptEmployeePhones)
        //{
        //    if (employeePhonesInClinic != string.Empty)
        //        employeePhonesInClinic += ", ";
        //    employeePhonesInClinic += dataR["phone"].ToString();
        //}
        //lblPhone_EmployeeReception.Text = employeePhonesInClinic;

        //// get employee's phones AS STRING for PopUp Reception Title
        //employeePhonesInClinic = string.Empty;
        //DataRow[] drDeptEmployeeFaxes = m_dsEmployee.Tables["DeptEmployeePhones"].Select("phoneType = 2 ", "phoneType, phoneOrder");
        //foreach (DataRow dataR in drDeptEmployeeFaxes)
        //{
        //    if (employeePhonesInClinic != string.Empty)
        //        employeePhonesInClinic += ", ";
        //    employeePhonesInClinic += dataR["phone"].ToString();
        //}
        //lblFax_EmployeeReception.Text = employeePhonesInClinic;

        //lblEmployeeProfessions_EmployeeReception.Text = m_dsEmployee.Tables["doctorDetails"].Rows[0]["professions"].ToString();
        //lblEmployeeName_EmployeeReception.Text = m_dsEmployee.Tables["doctorDetails"].Rows[0]["employeeName"].ToString();

        lblName.Text = m_dsEmployee.Tables["doctorDetails"].Rows[0]["EmployeeName"].ToString();
        if(m_dsEmployee.Tables["doctorDetails"].Rows[0]["expert"].ToString().Length > 1)
            lblExpert.Text = "&nbsp;|&nbsp;" + m_dsEmployee.Tables["doctorDetails"].Rows[0]["expert"].ToString();

        lblExpirationDate.Text = string.Format(ConstsSystem.RECEPTION_STARTING_FROM, expirationDate.ToString("dd/MM/yyyy"));
        return true;
    }
        
    private DataTable SplitStringAndConvertToOneColumnDataTable(string stringToBeSplitted, string columnName)
    {
        DataRow NewRow;
        DataColumn colItem;

        string[] strArray = stringToBeSplitted.Split(',');
        DataTable tbl = new DataTable();
        colItem = new DataColumn(columnName, Type.GetType("System.String"));
        tbl.Columns.Add(colItem);

        for (int i = 0; i < strArray.Length; i++)
        {
            NewRow = tbl.NewRow();
            NewRow[columnName] = strArray[i];
            tbl.Rows.Add(NewRow);
        }

        return tbl;
    }

}
