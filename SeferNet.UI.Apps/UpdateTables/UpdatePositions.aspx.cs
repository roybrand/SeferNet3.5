using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UpdateTables_UpdatePositions : System.Web.UI.Page
{

    private string _item = String.Empty; 
    public string Item
    {
        get
        {
            object items = ViewState["Items"];
            if (items == null)
                return String.Empty;
            else
            {
                _item = items.ToString();
                return _item;
            }
        }
        set
        {
            _item = value;
            ViewState["Items"] = _item;
        }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        this.Item = Page.Request["flag"].ToString();

        this.pnlGrid.Attributes["onscroll"] = "javascript:GetScrollPosition('" + this.pnlGrid.ClientID + "','" + this.txtScrollTop.ClientID + "');";
        if ( ! Page.IsPostBack)
        {
            if (Page.Request["flag"] != null)
            {
                switch (Page.Request["flag"].ToString())
                {   
                    case "positions":
                        TreeViewItem1.Item = "positions";
                        tblAdding.Visible = true;
                        break;
                    case "languages":
                        TreeViewItem1.Item = "languages";
                        tblAdding.Visible = false;
                        break;
                    case "handicappedFacilities":
                        TreeViewItem1.Item = "handicappedFacilities";
                        tblAdding.Visible = true;
                        lblGender.Text = "פעיל/לא פעיל";
                        SetDdlGender();
                        ddlSector.Visible = false;
                        lblSector.Visible = false;
                        break;
                    
                } 
            }

        }

        ScriptManager sm = ScriptManager.GetCurrent(Page);
        if (sm != null && UpdatePanel1 != null)
        {
            ScriptManager.RegisterStartupScript(UpdatePanel1, typeof(UpdatePanel), "ScrollDivToSelected", "javascript:ScrollDivToSelected('" + this.pnlGrid.ClientID + "','" + this.txtScrollTop.ClientID + "');" , true );
        }  
    }


    private void SetDdlAllowQueueOrder()
    {
        ListItem item = null;
        ddlAllowQueueOrder.Items.Clear();
        item = new ListItem();
        item.Value = "1";
        item.Text = "כן";
        ddlAllowQueueOrder.Items.Add(item);
        item = new ListItem();
        item.Value = "2";
        item.Text = "לא";
        ddlAllowQueueOrder.Items.Add(item);
    }


   
    private void SetDdlGender()
    {
        ListItem item = null;
        ddlGender.Items.Clear();
        item = new ListItem();
        item.Value = "1";
        item.Text = "פעיל";
        ddlGender.Items.Add(item);
        item = new ListItem();
        item.Value = "2";
        item.Text = "לא פעיל";
        ddlGender.Items.Add(item);
    }


    protected void Page_PreInit(object sender, EventArgs e)
    {
        try
        {           
            if (Page.Request["flag"] != null)
            {
                if (Page.Request["flag"].ToString() == "positions")
                {
                    Page.Title = GetLocalResourceObject("positions").ToString();                   
                }
                else if (Page.Request["flag"].ToString() == "languages")
                {
                    Page.Title = GetLocalResourceObject("languages").ToString();                   
                }
                else if (Page.Request["flag"].ToString() == "handicappedFacilities")
                {
                    Page.Title = GetLocalResourceObject("handicappedFacilities").ToString();                   
                }
                
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);

        }
    }
    protected void btnAddNew_Click(object sender, ImageClickEventArgs e)
    {
        try
        {
            string  code = txtCode.Text;
            string name = txtDescription.Text;
            string gender = ddlGender.SelectedItem.Text;
            string sector = ddlSector.SelectedValue;

            if(code != string.Empty && name != string.Empty ) 
            {
                TreeViewItem1.NewCode = int.Parse(code);
                TreeViewItem1.NewDescription = name;
                TreeViewItem1.NewIndication = gender;
                TreeViewItem1.NewSector = sector;

                

                bool result =TreeViewItem1.AddNewItem();
                if (!result)
                {
                    string message = GetLocalResourceObject("addingError").ToString();
                    ThrowAlert(message);
                }

                txtCode.Text = string.Empty;
                txtDescription.Text = string.Empty;              
            }            
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    


    private void ThrowAlert(string message)
    {
        String scriptString = "javascript:alert('" + message + "');";        

        ScriptManager sm = ScriptManager.GetCurrent(Page);
        if (sm != null && UpdatePanel1 != null)
        {
            ScriptManager.RegisterClientScriptBlock(UpdatePanel1, typeof(UpdatePanel), "JsAlert_", scriptString, true);
        }
    }
}
