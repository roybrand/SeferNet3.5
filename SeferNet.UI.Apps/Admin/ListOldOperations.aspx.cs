using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Collections;
using System.Web.Services;
using System.Collections.Specialized;
using System.Configuration;
using SeferNet.BusinessLayer.ObjectDataSource;


public partial class Admin_ListOldOperations : AdminBasePage
{ /*
    private string _category = String.Empty;
    private string _oldCode = String.Empty;
    private string _childServiceID = String.Empty;
    private string _tableCode = String.Empty;
    private string _childServiceDesc = String.Empty;
    private string _oldCodeDesc = String.Empty;
    private string _parentDesc = String.Empty;
    private string _tableDesc = String.Empty;

    public delegate void ImageButtonClickEventHandler(object sender, ImageClickEventArgs e);
    public event ImageButtonClickEventHandler ButtonClick;

    private ManageConversationsBO mng = new ManageConversationsBO();
    _ManagingServicesProfessionsHelper helper = new _ManagingServicesProfessionsHelper();


    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!Page.IsPostBack)
            {
                ButtonClick = imgOldDesc_Click;
                BindData();
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void ListOldOperations_ButtonClick(object sender, ImageClickEventArgs e)
    {
        imgOldDesc_Click(sender, e);
    }

    [WebMethod(true, EnableSession = true)]
    public static string[] GetAutoComplite(string prefixText, int count)
    {
        try
        {
            if (count == 0)
            {
                count = 100;
            }
            List<string> items = null;


            for (int i = 0; i < count; i++)
            {
                DataTable dt = (DataTable)HttpContext.Current.Session["OldCodes"];
                if (dt != null && dt.Rows.Count > 0)
                {
                    DataRow[] rows = dt.Select(" Name like '%" + prefixText + "%'");
                    //DataRow[] rows = helper.GetSelectedData(dt, "Name", prefixText);

                    DataTable dtResults = rows.CopyToDataTable();

                    int total = -1;
                    if (count < dtResults.Rows.Count)
                        total = count;
                    if (dtResults.Rows.Count < count)
                        total = dtResults.Rows.Count;

                    int x = 0;

                    items = new List<string>(total);
                    if (dtResults != null && dtResults.Rows.Count > 0)
                    {
                        foreach (DataRow curRow in dtResults.Rows)
                        {
                            if (x > total)
                                break;

                            items.Add(curRow["Name"].ToString());
                            x++;
                        }
                    }
                }
            }

            return items.ToArray();
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }





    #region GerRequestData

    private void GetParentDesc()
    {
        if (Request["parentDesc"] != null && Request["parentDesc"].ToString() != String.Empty)
        {
            _parentDesc = Request["parentDesc"].ToString();
        }
    }

    private void GetChildDetails()
    {
        try
        {
            GetChildCode();
            GetChildDesc();
            GetChildCategory();
            GetOldCode();
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void GetChildCategory()
    {
        if (Request["category"] != null && Request["category"].ToString() != String.Empty)
        {
            _category = Request["category"].ToString();
        }
    }

    private void GetTableCodeDesc()
    {
        if (Request["tableDesc"] != null && Request["tableDesc"].ToString() != String.Empty)
        {
            _tableDesc = Request["tableDesc"].ToString();
        }
    }

    private void GetTableCode()
    {
        if (Request["tableCode"] != null && Request["tableCode"].ToString() != String.Empty)
        {
            _tableCode = Request["tableCode"].ToString();
        }
    }

    private void GetChildCode()
    {
        if (Request["childServiceID"] != null && Request["childServiceID"].ToString() != String.Empty)
        {
            _childServiceID = Request["childServiceID"].ToString();
        }
    }

    private void GetChildDesc()
    {
        if (Request["childServiceDesc"] != null && Request["childServiceDesc"].ToString() != String.Empty)
        {
            _childServiceDesc = Request["childServiceDesc"].ToString();
        }
    }

    private void GetOldCode()
    {
        if (Request["oldCode"] != null && Request["oldCode"].ToString() != String.Empty)
        {
            _oldCode = Request["oldCode"].ToString();
        }
        if (string.IsNullOrEmpty(_oldCode))
        {
            if (Session["oldCode"] != null)
                _oldCode = Session["oldCode"].ToString();
        }
    }

    private void GetOldCodeDesc()
    {
        if (Request["oldCodeDesc"] != null && Request["oldCodeDesc"].ToString() != String.Empty)
        {
            _oldCodeDesc = Request["oldCodeDesc"].ToString();
        }
    }
    #endregion

    #region BindData

    private void BindData()
    {
        try
        {
            ViewState["isSelectTableCode"] = false;
            GetChildDetails();
           
            GetOldCode();
            GetOldCodeDesc();
            GetParentDesc();
          

            // if I need parent code
            if (_childServiceID != string.Empty)
            {
                hdnKind.Value = "childServiceID";
                if (_category != String.Empty)
                {
                    BindParentCode(_childServiceID, _category, _oldCode);

                    //if i need specific parent code 
                    if (_parentDesc != String.Empty)
                    {
                        hdnKind.Value += "_parentDesc";
                        txtSearchOldDesc.Text = _parentDesc;
                        ButtonClick(imgOldDesc, null);
                    }
                }
            }
            
            else if (!String.IsNullOrEmpty(_oldCode))
            {
                //i need to remember wich kind of request was - old code , old code 
                hdnKind.Value = "oldCode";
                if (String.IsNullOrEmpty(_oldCodeDesc))
                {
                    BindOldCodeData();
                }
                else
                {
                    //if i want to see all list of professions or services

                    hdnKind.Value += "_oldCodeDesc";
                    BindOldCodeData();
                    txtSearchOldDesc.Text = _oldCodeDesc;
                    ButtonClick(imgOldDesc, null);
                }
            }

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }


    /// <summary>
    /// get  code that cann't be oldCode or any code that is child code or this code 
    /// </summary>
    /// <param name="childServiceID"></param>
    /// <param name="flag"></param>
    /// <param name="oldCode"></param>
    private void BindParentCode(string childServiceID, string flag, string oldCode)
    {
        string query = String.Empty;
        DataTable dt = null;
        try
        {
            if (oldCode == String.Empty)
                oldCode = "-1";

            if (_category == GetLocalResourceObject("Service").ToString())
            {

                dt = mng.getServiceParents(int.Parse(childServiceID), int.Parse(oldCode));

                lblCaption.Text = String.Format(GetLocalResourceObject("SelectParentCodeFor").ToString(), GetLocalResourceObject("Service").ToString(), _childServiceDesc);
                btnGetSelected.Text = String.Format(btnGetSelected.Text, GetLocalResourceObject("Service").ToString());
            }
            else if (_category == GetLocalResourceObject("Profession").ToString())
            {

                dt = mng.getProfessionsParents(int.Parse(childServiceID), int.Parse(oldCode));

                lblCaption.Text = String.Format(GetLocalResourceObject("SelectParentCodeFor").ToString(), GetLocalResourceObject("Profession").ToString(), _childServiceDesc);
                btnGetSelected.Text = String.Format(btnGetSelected.Text, GetLocalResourceObject("Profession").ToString());
            }
            Session["item"] = "parentCode";

            if (dt != null && dt.Rows.Count > 0)
            {
                BindData(dt);
            }
            else
                lblCaption.Text = GetLocalResourceObject("No data").ToString();
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    

    private void BindOldCodeData()
    {
        try
        {
            DataTable dt = null;
            string query = String.Empty;
            if (!string.IsNullOrEmpty(_oldCode))
            {
                if (_oldCode == "1")
                {
                    //services
                    dt = mng.getServiceOldCodeData();
                    lblCaption.Text = GetLocalResourceObject("ListOldServices").ToString(); ;
                    btnGetSelected.Text = String.Format(btnGetSelected.Text, GetLocalResourceObject("Service").ToString());
                }
                else if (_oldCode == "2")
                {
                    //professions
                    dt = mng.getProfessionOldCodeData();
                    lblCaption.Text = GetLocalResourceObject("ListOldProfessions").ToString(); ;
                    btnGetSelected.Text = String.Format(btnGetSelected.Text, GetLocalResourceObject("Profession").ToString());
                }
            }
            Session["item"] = "oldCode";

            if (dt != null && dt.Rows.Count > 0)
                BindData(dt);
            else
                lblCaption.Text = GetLocalResourceObject("No data").ToString();

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void BindData(DataTable dt)
    {
        try
        {
            ViewState["OldCodes"] = dt;
            Session["OldCodes"] = dt;
            dgItems.DataSource = dt;
            dgItems.DataBind();
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void dgItems_RowCreated(object sender, GridViewRowEventArgs e)
    {
        Literal output = null;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // Grab a reference to the Literal control
            output = (Literal)e.Row.FindControl("RadioButtonMarkup");

            // Output the markup except for the "checked" attribute
            output.Text = string.Format(@"<input type='radio'  name='RelevantsGroup' " + @"id='RowSelector{0}' value='{0}' ", e.Row.RowIndex);

            // See if we need to add the "checked" attribute
            if (RelevantsSelectedIndex == e.Row.RowIndex)
                output.Text += @" checked='checked'";

            if (_oldCode != String.Empty && _tableCode != string.Empty)
                output.Text += @" disabled='disabled'";

            // Add the closing tag
            output.Text += " />";           
        }
    }

    protected void dgItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        Literal output = null;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // Grab a reference to the Literal control
            output = (Literal)e.Row.FindControl("RadioButtonMarkup");

            //if item is connected
            object[] data = ((System.Data.DataRowView)(e.Row.DataItem)).Row.ItemArray;
            if (data[2].ToString() == "1")
            {
                // Output the markup except for the "checked" attribute
                output.Text = string.Format(@"<input type='radio' disabled='disabled' checked='checked'" + @"id='RowSelector{0}' value='{0}' ", e.Row.RowIndex);

                // Add the closing tag
                output.Text += " />";
            }
            if (data[3].ToString() != String.Empty)
            {

                if (data[3].ToString() == "601")
                    e.Row.Attributes.Add("class", "table601");
                else if (data[3].ToString() == "606")
                    e.Row.Attributes.Add("class", "table606");
            }

        }
    }

    #endregion

    #region Utils
    
    private Hashtable GetSelectedParentService()
    {
        Hashtable hTbl = new Hashtable();
        try
        {
            foreach (GridViewRow item in dgItems.Rows)
            {
                Literal rdb = item.FindControl("RadioButtonMarkup") as Literal;

                if (rdb != null && rdb.Text.IndexOf("checked='checked'") > 0 && rdb.Text.IndexOf("disabled='disabled'") < 0)
                {
                    Label lblName = item.FindControl("lblName") as Label;
                    if (lblName != null && !string.IsNullOrEmpty(lblName.Text))
                    {
                        hTbl["itemDesc"] = lblName.Text;
                    }
                    Label lblCode = item.FindControl("lblCode") as Label;
                    if (lblCode != null)
                    {
                        hTbl["itemCode"] = int.Parse(lblCode.Text);
                    }
                    Label lblTableName = item.FindControl("lblTableName") as Label;
                    if (lblTableName != null && lblTableName.Text != String.Empty)
                    {
                        hTbl["table"] = lblTableName.Text;
                    }

                    if (hTbl.Count > 0)
                        return hTbl;
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
        return hTbl;
    }

    private int RelevantsSelectedIndex
    {
        get
        {
            if (string.IsNullOrEmpty(Request.Form["RelevantsGroup"]))
                return -1;
            else
                return Convert.ToInt32(Request.Form["RelevantsGroup"]);
        }
    }   

    #endregion

    #region Button_Click

    protected void lnkCode_Click(object sender, EventArgs e)
    {
        try
        {
            SortGridViewByColumn("Code");
            if (GridViewSortDirection == SortDirection.Ascending)
                SetSortingControls("lblSortCode", "6");
            else
                SetSortingControls("lblSortCode", "5");

            SetSortingControls("lblName", "");

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }



    protected void lnkName_Click(object sender, EventArgs e)
    {
        try
        {
            SortGridViewByColumn("Name");
            if (GridViewSortDirection == SortDirection.Ascending)
                SetSortingControls("lblSortName", "6");
            else
                SetSortingControls("lblSortName", "5");

            SetSortingControls("lblSortCode", "");

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    public SortDirection GridViewSortDirection
    {
        get
        {
            if (Session["sortDirection"] == null)
                Session["sortDirection"] = SortDirection.Ascending;
            return (SortDirection)Session["sortDirection"];
        }
        set
        {
            Session["sortDirection"] = value;
        }
    }

    private void SortGridViewByColumn(string columnName)
    {
        if (Session["OldCodes"] != null)
        {
            DataTable dt = (DataTable)Session["OldCodes"];
            if (dt != null)
            {
                DataView view = dt.DefaultView;
                if (GridViewSortDirection == SortDirection.Ascending)
                {
                    view.Sort = columnName + " asc";
                    GridViewSortDirection = SortDirection.Descending;
                }
                else
                {
                    view.Sort = columnName + " desc";
                    GridViewSortDirection = SortDirection.Ascending;
                }
                Session["ViewSort"] = view.Sort;

                dgItems.DataSource = view;
                dgItems.DataBind();
            }
        }
    }
    private void SetSortingControls(string controlID, string orderSort)
    {
        TableCell cell = dgItems.HeaderRow.Cells[0];
        Label lblSortCode = cell.FindControl(controlID) as Label;
        if (lblSortCode != null)
            lblSortCode.Text = orderSort;
    }

    protected void imgOldDesc_Click(object sender, ImageClickEventArgs e)
    {
        DataTable dtNew = null;
        try
        {
            DataTable dt = (DataTable)ViewState["OldCodes"];
            if (dt != null && dt.Rows.Count > 0)
            {
                dtNew = helper.GetSelectedData(dt, "Name", txtSearchOldDesc.Text);
                if (dtNew != null && dtNew.Rows.Count > 0)
                {
                    ViewState["OldCodes"] = dtNew;
                    dgItems.DataSource = dtNew;
                    dgItems.DataBind();
                }
                else
                {
                    lblMessage.Text = GetLocalResourceObject("No data").ToString();
                    dgItems.DataSource = null;
                    dgItems.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void imgClearOldDesc_Click(object sender, ImageClickEventArgs e)
    {
        txtSearchOldDesc.Text = String.Empty;
    }

    protected void imgRefresh_Click(object sender, ImageClickEventArgs e)
    {
        try
        {
            lblMessage.Text = String.Empty;
            txtSearchOldDesc.Text = String.Empty;

            ClearParametersBeforeBind("oldCodeDesc");
            ClearParametersBeforeBind("parentDesc");
            ClearParametersBeforeBind("tableDesc");
            BindData();
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }


    /// <summary>
    /// this function removes from request querystrings parametr of description
    /// </summary>
    /// <param name="queryParameter"></param>
    private void ClearParametersBeforeBind(string queryParameter)
    {
        if (hdnKind.Value.IndexOf(queryParameter) > 0)
        {
            hdnKind.Value = hdnKind.Value.Replace(queryParameter, "");
            NameValueCollection objNewValueCollection = HttpUtility.ParseQueryString(Request.QueryString.ToString());
            if (objNewValueCollection != null && objNewValueCollection.Count > 0)
            {
                objNewValueCollection.Remove(queryParameter);

                string sRedirect = Request.Url.AbsolutePath;
                string sNewQueryString = "?" + objNewValueCollection.ToString();

                sRedirect = sRedirect + sNewQueryString;
                HttpContext.Current.RewritePath(sRedirect);
            }
        }
    }

    protected void btnGetSelected_Click(object sender, EventArgs e)
    {
        string tblName = String.Empty;
        string codeDescription = String.Empty;
        Hashtable hTbl = new Hashtable();

        try
        {           
            hTbl = GetSelectedParentService();            

            if (hTbl != null && hTbl.Count > 0)
            {
                Session["selectedCode"] = hTbl;
            }
            Session["OldCodes"] = null;

            if (!ClientScript.IsClientScriptBlockRegistered("clientScript"))
            {
                // Form the script that is to be registered at client side.
                String scriptString = "<script language=\"JavaScript\">window.opener.focus();window.close();window.opener.document.forms(0).submit();</script>";
                ClientScript.RegisterClientScriptBlock(this.GetType(), "clientScript", scriptString);
                //ScriptManager.RegisterClientScriptBlock(UpdatePanel1, typeof(UpdatePanel), "JsVariableValidationKey", scriptString, true);                     
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }


    #endregion
   
   */
}


