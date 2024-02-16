using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.BusinessObject;
using System.Configuration;
using SeferNet.UI;

/// <summary>
/// Summary description for PagingControlsController
/// </summary>
public class SortingAndPagingInfoController
{
    #region Props 

    #region Paging

    public int totalPages
    {
        get
        {
            int retVal = 0;

            if (pageSize > 0)
            {
                retVal = totalRecords / pageSize;
                if ((retVal * pageSize) < totalRecords)
                    retVal += 1;
            }

            return retVal;
        }
    }

    public int totalRecords { get; set; }
    public int pageSize { get; set; }
    public int currentPage { get; set; }

    public LinkButton BtnFirstPage { get; set; }
    public LinkButton BtnPreviousPage { get; set; }
    public LinkButton BtnNextPage { get; set; }
    public LinkButton BtnLastPage { get; set; }

    public Label LblTotalRecords { get; set; }
    public Label LblPageFromPages { get; set; }

    public DropDownList DdlCarrentPage { get; set; }

    #endregion

    #endregion

    public SortingAndPagingParameters sortingAndPagingParameters { get; set; }

    public ISearchPageController SearchPageController { get; set; }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="searchPageController">the page that has the paging in it</param>
    /// <param name="btnFirstPage">button the move to first page</param>
    /// <param name="btnPreviousPage">button the move to previous page</param>
    /// <param name="btnNextPage">button the move to next page</param>
    /// <param name="btnLastPage">button the move to last page</param>
    /// <param name="lblTotalRecords">label that indicates the total number of records that were retrieved</param>
    /// <param name="lblPageFromPages"></param>
    /// <param name="ddlCarrentPage">current page selected</param>
    public SortingAndPagingInfoController(ISearchPageController searchPageController,
                                  LinkButton btnFirstPage,
                                  LinkButton btnPreviousPage, LinkButton btnNextPage,
                                  LinkButton btnLastPage,
                                  Label lblTotalRecords,
                                  Label lblPageFromPages,
                                  DropDownList ddlCarrentPage)
    {
        SearchPageController = searchPageController;
        BtnFirstPage = btnFirstPage;
        BtnPreviousPage = btnPreviousPage;
        BtnNextPage = btnNextPage;
        BtnLastPage = btnLastPage;
        LblTotalRecords = lblTotalRecords;
        LblPageFromPages = lblPageFromPages;
        DdlCarrentPage = ddlCarrentPage;

        //init from config or default for page size
        if (ConfigurationManager.AppSettings["PageSizeForSearchPages"] != null)
            pageSize = int.Parse(ConfigurationManager.AppSettings["PageSizeForSearchPages"].ToString());
        else
        {
            pageSize = 50;
        }

        //get the previous SortingAndPagingParameters from session if exist
        //we'll determine the sorting and paging based on the previous search
        if (HttpContext.Current.Session["SortingAndPagingParameters"] != null)
        {
            sortingAndPagingParameters = HttpContext.Current.Session["SortingAndPagingParameters"] as SortingAndPagingParameters;
        }
        else
        {
            sortingAndPagingParameters = new SortingAndPagingParameters();
        }
    }

    public void ResetSortingAndPagingParameters()
    {
        sortingAndPagingParameters = new SortingAndPagingParameters();
        sortingAndPagingParameters.TotalPages = totalPages;
        sortingAndPagingParameters.OrderBy = string.Empty;
        sortingAndPagingParameters.CurrentPage = currentPage;
        sortingAndPagingParameters.SortingOrder = Convert.ToInt32(sortingOrder.Ascending);
        HttpContext.Current.Session["SortingAndPagingParameters"] = sortingAndPagingParameters;
    }

    public void SetPagingControls(int? numberOfRecords)
    {
        if (numberOfRecords != null)
        {
            totalRecords = (int)numberOfRecords;
        }
        

        if (currentPage == 1)
        {
            BtnFirstPage.Enabled = false;
            BtnPreviousPage.Enabled = false;
        }
        else
        {
            BtnFirstPage.Enabled = true;
            BtnPreviousPage.Enabled = true;
        }

        if (currentPage == totalPages)
        {
            BtnNextPage.Enabled = false;
            BtnLastPage.Enabled = false;
        }
        else
        {
            BtnNextPage.Enabled = true;
            BtnLastPage.Enabled = true;
        }

        if (totalRecords < 1)
        {
            BtnNextPage.Enabled = false;
            BtnLastPage.Enabled = false;
        }

        LblTotalRecords.Text = "נמצאו" + "&nbsp;" + totalRecords + "&nbsp;" + "רשומות";
        LblPageFromPages.Text = "(" + "&nbsp;" + "עמוד" + "&nbsp;" + currentPage + "&nbsp;" + "מתוך" + "&nbsp;" + totalPages + "&nbsp;" + ")";

        if (totalRecords < 1)
            LblPageFromPages.Text = string.Empty;

        DdlCarrentPage.Items.Clear();
        if (totalPages > 1)
        {
            for (int i = 1; i <= totalPages; i++)
            {
                DdlCarrentPage.Items.Add(i.ToString());
                if (i == currentPage)
                    DdlCarrentPage.Items[i - 1].Selected = true;
            }
            DdlCarrentPage.Enabled = true;
        }
        else
        {
            DdlCarrentPage.Enabled = false;
        }

        if (HttpContext.Current.Session["SortingAndPagingParameters"] != null)
        {
            sortingAndPagingParameters = (SortingAndPagingParameters)HttpContext.Current.Session["SortingAndPagingParameters"];
            sortingAndPagingParameters.TotalPages = totalPages;
            HttpContext.Current.Session["SortingAndPagingParameters"] = sortingAndPagingParameters;
        }

    }     

    public void btnNextPage_Click(object sender, EventArgs e)
    {
        sortingAndPagingParameters = new SortingAndPagingParameters();

        if (HttpContext.Current.Session["SortingAndPagingParameters"] != null)
        {
            sortingAndPagingParameters = (SortingAndPagingParameters)HttpContext.Current.Session["SortingAndPagingParameters"];
            currentPage = sortingAndPagingParameters.CurrentPage + 1;
            sortingAndPagingParameters.CurrentPage = currentPage;           
        }

        HttpContext.Current.Session["SortingAndPagingParameters"] = sortingAndPagingParameters;

        //call the interface who calls the searchPage
        SearchPageController.LoadDataAndPopulate();

        SetPagingControls(SearchPageController.TotalNumberOfRecords);
    }

    public void btnFirstPage_Click(object sender, EventArgs e)
    {
        sortingAndPagingParameters = new SortingAndPagingParameters();

        if (HttpContext.Current.Session["SortingAndPagingParameters"] != null)
        {
            sortingAndPagingParameters = (SortingAndPagingParameters)HttpContext.Current.Session["SortingAndPagingParameters"];
            currentPage = 1;
            sortingAndPagingParameters.CurrentPage = currentPage;           
        }

        HttpContext.Current.Session["SortingAndPagingParameters"] = sortingAndPagingParameters;

        SearchPageController.LoadDataAndPopulate();        
        SetPagingControls(SearchPageController.TotalNumberOfRecords);
    }

    public void btnLastPage_Click(object sender, EventArgs e)
    {
        currentPage = sortingAndPagingParameters.TotalPages;
        sortingAndPagingParameters.CurrentPage = currentPage;           
       
        HttpContext.Current.Session["SortingAndPagingParameters"] = sortingAndPagingParameters;

        SearchPageController.LoadDataAndPopulate();

        SetPagingControls(SearchPageController.TotalNumberOfRecords);
    }

    public void btnPreviousPage_Click(object sender, EventArgs e)
    {
       currentPage = sortingAndPagingParameters.CurrentPage - 1;
       sortingAndPagingParameters.CurrentPage = currentPage;          

        HttpContext.Current.Session["SortingAndPagingParameters"] = sortingAndPagingParameters;

        SearchPageController.LoadDataAndPopulate();

        SetPagingControls(SearchPageController.TotalNumberOfRecords);
    }    

    public void ddlCarrentPage_SelectedIndexChanged(object sender, EventArgs e)
    {
        currentPage = Convert.ToInt32(DdlCarrentPage.SelectedValue);
        sortingAndPagingParameters.CurrentPage = currentPage;

        HttpContext.Current.Session["SortingAndPagingParameters"] = sortingAndPagingParameters;

        SearchPageController.LoadDataAndPopulate();

        SetPagingControls(SearchPageController.TotalNumberOfRecords);
    }

    public void RepeatLastSearch()
    {
        currentPage = sortingAndPagingParameters.CurrentPage;

        HttpContext.Current.Session["SortingAndPagingParameters"] = sortingAndPagingParameters;

        SearchPageController.LoadDataAndPopulate(true);
        SetPagingControls(SearchPageController.TotalNumberOfRecords);
    }

    public void BindDataAndPaging()
    {
        SearchPageController.LoadDataAndPopulate();

        SetPagingControls(SearchPageController.TotalNumberOfRecords);
    }

    /// <summary>
    /// Reorders the search  
    /// </summary>
    /// <param name="sortedByTemp"></param>
    /// <param name="ascImage"></param>
    /// <param name="descImage"></param>
    /// <param name="btnClicked"></param>
    public void ReOrderSearch(string sortBy, SortDirection sortDir)
    {
        sortingAndPagingParameters.CurrentPage = 1;

        sortingAndPagingParameters.SortingOrder = Convert.ToInt32(sortDir);
        sortingAndPagingParameters.OrderBy = sortBy;

        HttpContext.Current.Session["SortingAndPagingParameters"] = sortingAndPagingParameters;
    }
}
