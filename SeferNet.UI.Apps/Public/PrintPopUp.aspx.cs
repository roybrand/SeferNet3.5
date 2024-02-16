using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.FacadeLayer;
using System.Data;
using System.Configuration;

public partial class PrintPopUp : System.Web.UI.Page
{
    public SortingAndPagingParameters sortingAndPagingParameters { get; set; }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string WhatToPrint = Request.QueryString["WhatToPrint"].ToString();

        lblPrintDate.Text = DateTime.Now.ToString("MM/dd/yyyy");

        switch (WhatToPrint)
        {
            case "SearchDoctors":
                PrintDoctors();
                break;
            //default:
            //    PrintDoctors();
            //    break;
        }

    }

    private void PrintDoctors()
    {
        trDoctorsList.Style.Add("display", "inline");
        DoctorSearchParameters doctorSearchParameters = new DoctorSearchParameters();

        int PageSizeForSearchPages = Convert.ToInt32(ConfigurationSettings.AppSettings["PageSizeForSearchPages"]);
        if (Session["doctorSearchParameters"] != null)
        {
            if (HttpContext.Current.Session["SortingAndPagingParameters"] != null)
            {
                sortingAndPagingParameters = HttpContext.Current.Session["SortingAndPagingParameters"] as SortingAndPagingParameters;
            }
            else
            {
                sortingAndPagingParameters = new SortingAndPagingParameters();
            }

            doctorSearchParameters = Session["doctorSearchParameters"] as DoctorSearchParameters;

            Facade applicFacade = Facade.getFacadeObject();

            DataSet dsDoctors = applicFacade.getDoctorList_PagedSorted(doctorSearchParameters, new SearchPagingAndSortingDBParams(PageSizeForSearchPages, sortingAndPagingParameters.CurrentPage,
                     sortingAndPagingParameters.SortingOrder, sortingAndPagingParameters.OrderBy));

            gvDoctorsList.DataSource = dsDoctors.Tables[0];
            gvDoctorsList.DataBind();

            //GridView gridView = new GridView();
            //gridView.AutoGenerateColumns = false;

            //BoundField deptName = new BoundField();
            //deptName.HeaderText = "שם יחידה";
            //deptName.DataField = "deptName";
            //deptName.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
            //gridView.Columns.Add(deptName);

            //BoundField EmployeeName = new BoundField();
            //EmployeeName.HeaderText = "שם רופא";
            //EmployeeName.DataField = "EmployeeName";
            //deptName.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
            //gridView.Columns.Add(deptName);

            //gridView.DataSource = dsDoctors.Tables[0];
            //gridView.DataBind();
            //tdDoctorsList.Controls.Add(gridView);
        }

    }
}
