using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.Globals;

public partial class SortableColumnHeader : System.Web.UI.UserControl
{
    private const string IMG_DESC = "~/Images/Applic/icon_sort_descending.gif";
    private const string IMG_ASC = "~/Images/Applic/icon_sort_ascending.gif";
    private const string IMG_NO_SORT = "~/Images/Applic/icon_sort.gif";
    
    public event EventHandler SortClick;

    #region Properties

    public SortDirection? CurrentSortDirection
    {
        get
        {
            return (SortDirection?)ViewState[this.ClientID + "_currentSort"];
        }
                   
        private set
        {
            ViewState[this.ClientID + "_currentSort"] = value;
        }
    }

    public string Text
    {
        get
        {
            return lnkHeaderText.Text;
        }
        set
        {
            lnkHeaderText.Text = value;
        }
    }

    public Unit Width
    {
        get
        {
            return lnkHeaderText.Width;
        }
        set
        {
            lnkHeaderText.Width = value;
        }
    }

    public Enums.SortableData ColumnIdentifier { get; set; }

    #endregion


    protected void Page_Load(object sender, EventArgs e)
    {
    }


    public void ResetSort()
    {
        imgSortOrder.ImageUrl = IMG_NO_SORT;
        CurrentSortDirection = null;
    }

    /// <summary>
    /// returns string represantation of current sort. "ASC" if ascending, and "DESC" if descending. 
    /// if no sorting is currently set - return empty string
    /// </summary>
    /// <returns></returns>
    public string GetStringValueOfCurrentSort()
    {
        if (CurrentSortDirection != null)
        {
            if ((SortDirection)CurrentSortDirection == SortDirection.Ascending)
                return "asc";
            else
                return "desc";
        }
        else
        {
            return string.Empty;
        }
    }

    public void SetSortDirection(SortDirection direction)
    {
        CurrentSortDirection = direction;
        HandleSort();
    }

    protected void SortOrder_Click(object sender, EventArgs e)
    {
        ToggleCurrentDirection();
        HandleSort();

        if (SortClick != null)
        {
            SortClick(this, null);
        }
    }

    private void ToggleCurrentDirection()
    {
        switch (CurrentSortDirection)
        {
            case SortDirection.Ascending:
                CurrentSortDirection = SortDirection.Descending;
                break;
            
            default:
                CurrentSortDirection = SortDirection.Ascending;
                break;
        }
    }

    private void HandleSort()
    {
        switch (CurrentSortDirection)
        {
            case SortDirection.Ascending:
            default:
                CurrentSortDirection = SortDirection.Ascending;
                imgSortOrder.ImageUrl = IMG_ASC;
                break;

            case SortDirection.Descending:
                CurrentSortDirection = SortDirection.Descending;
                imgSortOrder.ImageUrl = IMG_DESC;
                break;


        }
    }
}
