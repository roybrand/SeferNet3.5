using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;

 
namespace SeferNet.UI
{
    public class GridColumnSortingInfo
    {
        private string buttonID;
        private ImageButton button;
        private string[] buttonImages;
        private string tableColumnName;
        private SortingOrder sortingOrder;

        public GridColumnSortingInfo(ImageButton button,
               string imageDownArrow, string imageUpArrow, string imageTwoArrow, string tableColumnName)
        {
            this.buttonID = button.ID;
            this.button = button;
            this.buttonImages = new string[3] { imageDownArrow, imageUpArrow, imageTwoArrow };
            this.tableColumnName = tableColumnName;
            this.sortingOrder = SortingOrder.Undefined;
        }

        public string ButtonID 
        {
            get { return this.buttonID; }
        }

        public ImageButton Button
        {
            get { return this.button; }
            set
            {
                this.button = value;
            }
        }

        //public string[] ButtonImages { get; set; }


        public string TableColumnName 
        {
            get
            {
                return this.tableColumnName;
            }
            set
            {
                this.tableColumnName = value;
            }
        }

        public SortingOrder SortingOrder
        {
            set
            {
                this.sortingOrder = value;
            }
            get
            {
                return this.sortingOrder;
            }
        }

        public void InvertSortingOrder()
        {
            if (this.sortingOrder == SortingOrder.Ascending)
            {
                this.sortingOrder = SortingOrder.Descending;
            }
            else
            {
                this.sortingOrder = SortingOrder.Ascending;
            }

            this.button.ImageUrl = this.buttonImages[(int)this.sortingOrder];
        }

        public void SetDefaultSortingOrder()
        {
            this.sortingOrder = SortingOrder.Undefined;
            this.button.ImageUrl = this.buttonImages[(int)this.sortingOrder];
        }


        public void RefreshButtomImageBySortingOrder()
        {
            this.button.ImageUrl = this.buttonImages[(int)this.sortingOrder];
        }

        
    }

    public class RequestHelper
    {
        public static string removeFromQueryString(string queryString, string qVal)
        {
            string res = "";
            string[] splitQuery = queryString.Split('&');

            foreach (var item in splitQuery)
            {
                if (item.Split('=')[0] != qVal)
                {
                    if (res == "")
                        res = item;
                    else
                        res = res + "&" + item;
                }
            }

            return res;
        }
    }
}
