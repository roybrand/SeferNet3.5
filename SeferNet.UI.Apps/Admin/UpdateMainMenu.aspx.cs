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
using System.Globalization;

using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.BusinessObject;
using System.Data.SqlClient;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.DataLayer;
using SeferNet.FacadeLayer;
using System.Text;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using SeferNet.Globals;
using System.Collections.Generic;

public partial class UpdateMainMenu : AdminBasePage
{
    Facade applicFacade;
    UserInfo currentUser;
    System.Collections.Generic.List<UserPermission> PermissionList;
    string remarkText = string.Empty;
    SessionParams sessionParams;
    string errorMessage;
    string mainMenuRestrictions_ViewState = "mainMenuRestrictions_ViewState";

    string BG_ReadOnly = "#F7F7F7";
    string BG_notReadOnly = "White";

    protected void Page_Load(object sender, EventArgs e)
    {
        currentUser = Session["currentUser"] as UserInfo;

        sessionParams = SessionParamsHandler.GetSessionParams();

        applicFacade = Facade.getFacadeObject();

        PlayWithMenu();

        int nc = trvMaimMenu.Nodes.Count;

        if (!IsPostBack)
        {
            SetSiteMenuSql();
            BindDdlPermissionType();
            cbNewWindow.Attributes.Add("onclick", "SetNewWindowControls()");
            cbEmptyEntry.Attributes.Add("onclick", "SetEmptyEntry()");
        }

        txtParrent.Style.Add("background-color", BG_ReadOnly);
    }

    private void BindDdlPermissionType()
    {
        UserInfo currentUser = Session["currentUser"] as UserInfo;
        ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
        DataTable tbl = cacheHandler.getCachedDataTable(eCachedTables.PermissionTypes.ToString());

        if (currentUser.IsAdministrator)
        {
            DataView dv = new DataView(tbl, null, "permissionDescription", DataViewRowState.CurrentRows);
            lstPermissionsTypes.DataSource = dv;
            lstPermissionsTypes.DataBind();
            return;
        }
        else
        {
            DataView dv = new DataView(tbl, "PermissionCode <> " + (int)Enums.UserPermissionType.Administrator,
                                            "permissionDescription", DataViewRowState.CurrentRows);
            lstPermissionsTypes.DataSource = dv;
            lstPermissionsTypes.DataBind();
        }
    }

    protected void PlayWithMenu()
    {
        //trvMaimMenu.Attributes.Add("onClick", "ToggleSelected(this);");

        for (int i = 0; i < trvMaimMenu.Nodes.Count; i++)
        {
            if (trvMaimMenu.Nodes[i].Checked)
            {
               txtSelectedNode.Text = trvMaimMenu.Nodes[i].Value;
            }
        }

    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        vldRegTxtPageName.Text = "חובה להזין את שם הדף ללא סיומת באותיות לועזיות";

        for (int i = 0; i < trvMaimMenu.Nodes.Count; i++)
        {
            trvMaimMenu.Nodes[i].ImageUrl = "../Images/Applic/Checked_NOT.gif";
            UnsignChildrenNodes(trvMaimMenu.Nodes[i]);
        }

        if (trvMaimMenu.SelectedNode != null)
        {
            string str = trvMaimMenu.SelectedNode.Value;
            trvMaimMenu.SelectedNode.ImageUrl = "../Images/Applic/Checked.gif";

        }
        if (trvMaimMenu.SelectedNode != null)
        {
            btnAddChildItem.Enabled = true;
            btnUpdateItem.Enabled = true;
            btnDelete.Enabled = true;
            btnMooveDown.Enabled = true;
            btnMooveUp.Enabled = true;

            btnMooveUp.ImageUrl = "../Images/Applic/btnUp_enabled.gif";
            btnMooveDown.ImageUrl = "../Images/Applic/btnDown_enabled.gif";
            btnDelete.ImageUrl = "../Images/Applic/btn_X_red.gif";
        }
        else
        { 
            btnAddChildItem.Enabled = false;
            btnUpdateItem.Enabled = false;
            btnDelete.Enabled = false;
            btnMooveDown.Enabled = false;
            btnMooveUp.Enabled = false;

            btnMooveUp.ImageUrl = "../Images/Applic/btnUp_disabled.gif";
            btnMooveDown.ImageUrl = "../Images/Applic/btnDown_disabled.gif";
            btnDelete.ImageUrl = "../Images/Applic/btn_X_grey.gif";
       }

    }

    private void UnsignChildrenNodes(TreeNode parentNode)
    {
        for (int i = 0; i < parentNode.ChildNodes.Count; i++)
        {
            parentNode.ChildNodes[i].ImageUrl = "../Images/Applic/Checked_NOT.gif";
            UnsignChildrenNodes(parentNode.ChildNodes[i]);
        }
    }

    private void SetSiteMenuSql()
    {
        trvMaimMenu.Nodes.Clear();

        applicFacade = Facade.getFacadeObject();
        List<Enums.UserPermissionType> permissionsList = new List<Enums.UserPermissionType>();
        try
        {
            UserManager userManager = new UserManager(Master.getUserName());
            UserInfo currentUser = userManager.GetUserInfoFromSession();

            permissionsList = userManager.GetUserPermissionsForMenuViewing(currentUser);

        }
        catch
        {
            if (permissionsList.Count == 0)
            {
                permissionsList.Add(Enums.UserPermissionType.AvailableToAll);
            }
        }

        DataSet ds = applicFacade.GetMainMenuData(permissionsList, "");
        DataSet hDS = new DataSet();

        for (int i = 0; i < ds.Tables.Count; i++)
        {
            DataTable dtParCld = ds.Tables[i].Copy();
            dtParCld.TableName = "Layer_" + i;
            hDS.Tables.Add(dtParCld);
        }

        for (int i = 0; i < hDS.Tables.Count - 1; i++)
        {
            hDS.Relations.Add("Parent_Child_" + i, hDS.Tables["Layer_" + i].Columns["ItemID"],
                hDS.Tables["Layer_" + (i + 1)].Columns["ParentID"], true);
        }
        
        foreach (DataRow parentRow in hDS.Tables["Layer_0"].Rows)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(parentRow["Title"].ToString());

            string itemText = CreateItemText(parentRow["Title"].ToString(), Convert.ToInt32(1), Convert.ToBoolean(parentRow["HasRestrictions"]));

            TreeNode trNode = new TreeNode(itemText, parentRow["Url"].ToString());

            trvMaimMenu.Nodes.Add(trNode);

            trNode.Expanded = true;
            trNode.ImageUrl = "../Images/Applic/btn_Plus_Blue_12.gif";
            trNode.ToggleExpandState();
            //trNode.ShowCheckBox = true;
            trNode.Value = parentRow["ItemID"].ToString();

            AddChildNodes(trNode, parentRow, 0);
        }

        //SiteMenuSql.MenuItemClick += new MenuEventHandler(SiteMenuSql_MenuItemClick);
        trvMaimMenu.ExpandAll();

    }

    private string CreateItemText(string title, int roles, bool hasRestrictions)
    {
        StringBuilder sb = new StringBuilder();

        if (roles == 5)
            sb.Append("<font color='#FF8000'>(a)&nbsp;</font>");
        else if (roles == 1)
            sb.Append("<font color='#33D60D'>(d)&nbsp;</font>");
        else if (roles == 2)
            sb.Append("<font color='#787878'>(s)&nbsp;</font>");
        else if (roles == 3)
            sb.Append("<font color='#025ED4'>(c)&nbsp;</font>");
        else
            sb.Append(string.Empty);

        if(hasRestrictions)
            sb.Append("<img src='../Images/ValErrorIcon.gif' title='התפריט לא מוצג בכל דפי המערכת' style='border: solid 0px White' />  ");

        sb.Append(title);

        return sb.ToString();
    }

    private void AddChildNodes(TreeNode upperNode, DataRow parentDataRow, int Layer)
    {
        int i = 0;
        foreach (DataRow childRow in parentDataRow.GetChildRows("Parent_Child_" + Layer))
        {
            string itemText = CreateItemText(childRow["Title"].ToString(), Convert.ToInt32(1), Convert.ToBoolean(childRow["HasRestrictions"]));

            TreeNode trNode = new TreeNode(itemText, childRow["Url"].ToString());
            trNode.Value = childRow["ItemID"].ToString();

            upperNode.ChildNodes.Add(trNode);

            AddChildNodes(trNode, childRow, Layer + 1);
            i++;
        }
    }

    protected void trvMaimMenu_SelectedNodeChanged(object sender, EventArgs e)
    {
        txtSelectedNode.Text = trvMaimMenu.SelectedNode.Value;
        tblUpdateItem.Style.Add("display", "none");
        ClearValues();

    }

    protected void btnAddItem_Click(object sender, EventArgs e)
    {
        tblUpdateItem.Style.Add("display", "inline");
        ClearValues();
        txtSelectedNode.Text = string.Empty;
        txtParrentID.Text = string.Empty;
        //ddlPermissionLevel.SelectedValue = "0"; 
        cbRoot.Checked = true;
        SetSiteMenuSql();
    }

    protected void btnAddChildItem_Click(object sender, EventArgs e)
    {
        tblUpdateItem.Style.Add("display", "inline");
        txtParrentID.Text = trvMaimMenu.SelectedValue;
        string[] parrentText = trvMaimMenu.SelectedNode.Text.Split('>');
        if (parrentText.Length > 1)
            txtParrent.Text = parrentText[parrentText.Length - 1].Trim();
        else
            txtParrent.Text = trvMaimMenu.SelectedNode.Text.Trim();
        txtTitle.Text = string.Empty;
        txtUrl.Text = string.Empty;
        //ddlPermissionLevel.SelectedValue = "0"; 

        cbItIsUpdate.Checked = false;
    }

    private void SetNewWindowControlsDefaults()
    {
        cbNewWindow.Checked = false;
        cbModalDialog.Checked = false;
        txtSizeX.Text = string.Empty;

        txtSizeY.Text = string.Empty;
        cbResize.Checked = false;

        cbModalDialog.Disabled = true;
        txtSizeX.Enabled = false;
        txtSizeX.Style.Add("background-color", BG_ReadOnly);
        txtSizeY.Enabled = false;
        txtSizeY.Style.Add("background-color", BG_ReadOnly);
        cbResize.Disabled = true;
    }

    protected void btnUpdateItem_Click(object sender, EventArgs e)
    {
        tblUpdateItem.Style.Add("display", "inline");
        cbItIsUpdate.Checked = true;

        SetNewWindowControlsDefaults();

        int itemID = Convert.ToInt32(txtSelectedNode.Text);
        DataSet dsMainMenuItem = applicFacade.GetMainMenuItem(itemID);
        DataRow selectedRow = dsMainMenuItem.Tables[0].Rows[0];

        string[] UrlAndWindowParameters = selectedRow["Url"].ToString().Split('#');

        if (UrlAndWindowParameters.Length > 1)
        {
            cbNewWindow.Checked = true;

            cbModalDialog.Disabled = false;
            txtSizeX.Enabled = true;
            txtSizeX.Style.Add("background-color", BG_notReadOnly);
            txtSizeY.Enabled = true;
            txtSizeY.Style.Add("background-color", BG_notReadOnly);
            cbResize.Disabled = false;
            cbResize.Checked = true;

            string[] WindowParameters = UrlAndWindowParameters[1].Split(';');
            if (WindowParameters.Length > 1)
            {
                if (Convert.ToInt16(WindowParameters[0]) == 1)
                    cbModalDialog.Checked = true;

                if (WindowParameters[1].Length > 0)
                    txtSizeX.Text = WindowParameters[1];
                if (WindowParameters[2].Length > 0)
                    txtSizeY.Text = WindowParameters[2];

                if (WindowParameters[3].Length > 0 && Convert.ToInt16(WindowParameters[3]) == 1)
                    cbResize.Checked = true;
                else
                    cbResize.Checked = false;
            }

        }

        if (UrlAndWindowParameters[0] == ConstsSystem.EMPTY)
        {
            txtUrl.Text = string.Empty;
            txtUrl.Style.Add("background-color", BG_ReadOnly);
            txtUrl.Enabled = false;

            cbEmptyEntry.Checked = true;

            cbNewWindow.Checked = false;
            cbNewWindow.Disabled = true;

            cbModalDialog.Checked = false;
            cbModalDialog.Disabled = true;

            txtSizeX.Text = string.Empty;
            txtSizeX.Style.Add("background-color", BG_ReadOnly);            
            txtSizeX.Enabled = false;

            txtSizeY.Text = string.Empty;
            txtSizeY.Enabled = false;
            txtSizeY.Style.Add("background-color", BG_ReadOnly);

            cbResize.Checked = false;
            cbResize.Disabled = true;
        }
        else
        { 
            txtUrl.Text = UrlAndWindowParameters[0];
        }

        txtTitle.Text = selectedRow["Title"].ToString();
        txtParrent.Text = selectedRow["parentTitle"].ToString();
        txtParrentID.Text = string.Empty;
        //ddlPermissionLevel.SelectedValue = selectedRow["Roles"].ToString();

        foreach (ListItem item in lstPermissionsTypes.Items)
        {
            item.Selected = false;
        }

        if (selectedRow["Roles"] != null)
        {
            string[] arrRoles = selectedRow["Roles"].ToString().Trim().Split(',');

            for (int i = 0; i < arrRoles.Length; i++)
            {
                lstPermissionsTypes.Items.FindByValue(arrRoles[i]).Selected = true;
            }
        }


        ViewState[mainMenuRestrictions_ViewState] = dsMainMenuItem.Tables[1];
        gvRestrictions.DataSource = (DataTable)ViewState[mainMenuRestrictions_ViewState];
        gvRestrictions.DataBind();
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        tblUpdateItem.Style.Add("display", "none");
        ClearValues();
    }

    void ClearValues()
    {
        txtParrent.Text = string.Empty;
        txtTitle.Text = string.Empty;
        txtUrl.Text = string.Empty;
        //ddlPermissionLevel.SelectedValue = "0";
        cbRoot.Checked = false;
        cbItIsUpdate.Checked = false;
        ViewState[mainMenuRestrictions_ViewState] = null;
        gvRestrictions.DataSource = null;
        gvRestrictions.DataBind();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        DataTable dtMainMenuRestrictions = (DataTable)ViewState[mainMenuRestrictions_ViewState];

        int itemID = 0;
        if(txtSelectedNode.Text != string.Empty)
            itemID = Convert.ToInt32(txtSelectedNode.Text);
        string title = txtTitle.Text;
        string description = string.Empty;
        string url = txtUrl.Text;
        if (cbEmptyEntry.Checked)
            url = ConstsSystem.EMPTY;

        if (cbNewWindow.Checked)
        {
            url += '#';
            if (cbModalDialog.Checked)
                url += "1;";
            else
                url += "0;";

            if (txtSizeX.Text != string.Empty)
                url += txtSizeX.Text + ";";
            else
                url += ";";

            if(txtSizeY.Text != string.Empty)
                url += txtSizeY.Text + ";";
            else
                url += ";";

            if(cbResize.Checked)
                url += "1;";
            else
                url += ";";
        }

        string roles = string.Empty;
        int parentID;
        
        for (int i = 0; i < lstPermissionsTypes.Items.Count; i++)
        {
            if (lstPermissionsTypes.Items[i].Selected)
                roles += lstPermissionsTypes.Items[i].Value + ',';
        }
        if (string.IsNullOrEmpty(roles))
            roles = ((int)Enums.UserPermissionType.AvailableToAll).ToString();

        
        if (txtParrentID.Text != string.Empty)
            parentID = Convert.ToInt32(txtParrentID.Text);
        else
            parentID = -1;

        if(!cbItIsUpdate.Checked)
            applicFacade.InsertMainMenuItem(title, description, url, roles, parentID, dtMainMenuRestrictions);
        else
            applicFacade.UpdateMainMenuItem(itemID, title, description, url, roles, dtMainMenuRestrictions);

        tblUpdateItem.Style.Add("display", "none");
        ClearValues();

        SetSiteMenuSql();
    }

    protected void btnDelete_Click(object sender, ImageClickEventArgs e)
    {
        int temID = Convert.ToInt32(txtSelectedNode.Text);
        applicFacade.DeleteMainMenuItem(temID);

        tblUpdateItem.Style.Add("display", "none");
        ClearValues();

        SetSiteMenuSql();
    }
    protected void trvMaimMenu_TreeNodeDataBound(object sender, TreeNodeEventArgs e)
    {
        DataRowView dvRowView = e.Node.DataItem as DataRowView;
        if (Convert.ToBoolean(dvRowView["Roles"]))
            e.Node.ImageUrl = "../Images/Applic/ExclamationMarkOrange.gif";
    }

    protected void btnMooveDown_Click(object sender, ImageClickEventArgs e)
    {
        int temID = Convert.ToInt32(txtSelectedNode.Text);
        applicFacade.UpdateMainMenu_MoveItem(temID, -1);

        tblUpdateItem.Style.Add("display", "none");
        ClearValues();

        SetSiteMenuSql();
    }

    protected void btnMooveUp_Click(object sender, ImageClickEventArgs e)
    {
        int temID = Convert.ToInt32(txtSelectedNode.Text);
        applicFacade.UpdateMainMenu_MoveItem(temID, 1);

        tblUpdateItem.Style.Add("display", "none");
        ClearValues();

        SetSiteMenuSql();
    }

    protected void btnDeleteRestriction_Click(object sender, EventArgs e)
    {
        ImageButton btnDeleteRestriction = sender as ImageButton;
        //int mainMenuItemID = Convert.ToInt32(btnDeleteRestriction.Attributes["MainMenuItemID"]);
        string pageName = btnDeleteRestriction.Attributes["PageName"].ToString();

        int indexToBeRemoved = -1;

        DataTable dtMainMenuRestrictions = (DataTable)ViewState[mainMenuRestrictions_ViewState];
        for (int i = 0; i < dtMainMenuRestrictions.Rows.Count; i++)
        {
            //if (Convert.ToInt32(dtMainMenuRestrictions.Rows[i]["MainMenuItemID"]) == mainMenuItemID && dtMainMenuRestrictions.Rows[i]["PageName"].ToString() == pageName)
            if (dtMainMenuRestrictions.Rows[i]["PageName"].ToString() == pageName)
                indexToBeRemoved = i;
        }

        if (indexToBeRemoved >= 0)
        {
            dtMainMenuRestrictions.Rows.RemoveAt(indexToBeRemoved);
            dtMainMenuRestrictions.AcceptChanges();
        }

        gvRestrictions.DataSource = dtMainMenuRestrictions;
        gvRestrictions.DataBind();

        ViewState[mainMenuRestrictions_ViewState] = dtMainMenuRestrictions;
    }

    protected void btnAddPageName_Click(object sender, EventArgs e)
    {
        DataTable dtMainMenuRestrictions = (DataTable) ViewState[mainMenuRestrictions_ViewState];

        if (dtMainMenuRestrictions == null)
            dtMainMenuRestrictions = applicFacade.GetMainMenuItem(-1).Tables[1];

        foreach (DataRow dr in dtMainMenuRestrictions.Rows)
        {
            if (dr["PageName"].ToString() == txtPageName.Text)
                return;
        }

        DataRow newDataRow = dtMainMenuRestrictions.NewRow();
        newDataRow["PageName"] = txtPageName.Text;
        dtMainMenuRestrictions.Rows.Add(newDataRow);

        gvRestrictions.DataSource = dtMainMenuRestrictions;
        gvRestrictions.DataBind();

        ViewState[mainMenuRestrictions_ViewState] = dtMainMenuRestrictions;
        txtPageName.Text = string.Empty;
    }
}
