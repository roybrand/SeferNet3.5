using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class ServiceCategoriesSearchParameters
    {
        int? m_selectedServiceCategoryID;
        int? m_serviceCategoryID;
        string m_serviceCategoryDescription;
        int? m_scrollPosition_ServiceCategories_UpdateServiceCategories;
        int? m_currentRowIndex;
        string m_columnIdentifier;
        SortDirection m_sortDirection;

        public int? SelectedServiceCategoryID
        {
            get { return m_selectedServiceCategoryID; }
            set { m_selectedServiceCategoryID = value; }
        }

        public int? ServiceCategoryID
        {
            get { return m_serviceCategoryID; }
            set { m_serviceCategoryID = value; }
        }

        public string ServiceCategoryDescription
        {
            get { return m_serviceCategoryDescription; }
            set { m_serviceCategoryDescription = value; }
        }

        public int? ScrollPosition_ServiceCategories_UpdateServiceCategories
        {
            get { return m_scrollPosition_ServiceCategories_UpdateServiceCategories; }
            set { m_scrollPosition_ServiceCategories_UpdateServiceCategories = value; }
        }

        public int? CurrentRowIndex
        {
            get { return m_currentRowIndex; }
            set { m_currentRowIndex = value; }
        }

        public string ColumnIdentifier
        {
            get { return m_columnIdentifier; }
            set { m_columnIdentifier = value; }
        }

        public SortDirection SortDirection
        {
            get { return m_sortDirection; }
            set { m_sortDirection = value; }
        }
    }
}
