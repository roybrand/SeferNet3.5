using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UpdateTables_UpdateProfessionsNew : System.Web.UI.Page
{
    private int _editedRowID = -1;
    public UserControls_GridTreeView _gridTreeView = null;

    public int EditedRowID
    {
        get
        {
            return _editedRowID;
        }
        set
        {
            _editedRowID = value;
        }
    }

    public UserControls_GridTreeView GridTreeView
    {
        get
        {
            return _gridTreeView;
        }
        set
        {
            _gridTreeView = value;
        }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.Request["flag"] != null)
        {
            if (Page.Request["flag"].ToString() == "true")
                TreeViewItem1.Item = "services";
            else
                TreeViewItem1.Item = "professions";               
        }

         _gridTreeView = TreeViewItem1;
    }


    protected void Page_PreInit(object sender, EventArgs e)
    {
        try
        {
            //Page.Title = GetLocalResourceObject("Title").ToString();

            if (Page.Request["flag"] != null)
            {
                if (Page.Request["flag"].ToString() == "true")
                    Page.Title = GetLocalResourceObject("UpdateTableServices").ToString();
                else
                    Page.Title = GetLocalResourceObject("UpdateTableProfession").ToString();

            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);

        }
    }
    
}
