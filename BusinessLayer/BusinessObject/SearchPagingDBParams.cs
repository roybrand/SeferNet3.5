using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    /// <summary>
    /// this class holds the info of the paging & sorting parameters of search web pages (like clinics/doctors/events) 
    /// this class is to be initialized from top layers like UI, but its properties are only to be set from the constractor
    /// because we don't want them to be changed
    /// </summary>
    public   class SearchPagingAndSortingDBParams
    {
        public int? PageSize { get; private set; }
        public int? StartingPage { get; private set; }
        public int IsOrderDescending { get; private set; }
        public string SortedBy { get; private set; }

        public SearchPagingAndSortingDBParams(int? pageSize, int? startingPage,
         int isOrderDescending, string sortedBy)
        {
            PageSize = pageSize;
            StartingPage = startingPage;
            SortedBy = sortedBy;
            IsOrderDescending = isOrderDescending;

            PrepareParametersForDBQuery();
        }

        private  void PrepareParametersForDBQuery()
        {
            if (PageSize == -1)//pageSise
                PageSize = null;
            if (StartingPage == -1)//startingPage
                StartingPage = null;
            if (SortedBy == string.Empty)//SortedBy
                SortedBy = null;
            if (IsOrderDescending < 0)//isOrderDescending
                IsOrderDescending = 0;
        }
    }
}
