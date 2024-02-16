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


public partial class Admin_ListMFCodes :  AdminBasePage
{/*
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
    private string _noOldCode = String.Empty; 



    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (Page.Request["noOldCode"] != null)
            {
                _noOldCode = Page.Request["noOldCode"].ToString();
                if (_noOldCode == "true")
                    ViewState["_noOldCode"] = "true";
            }

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
   
    #endregion

    #region BindData

    private void BindData()
    {
        try
        {                     
            GetOldCode();   
            GetTableCode();                          
            GetTableCodeDesc();
           
             if (_tableCode != string.Empty)
            {
                BindTableCodeData();
                if (_tableDesc != String.Empty)
                {
                    hdnKind.Value += "_tableDesc";
                    txtSearchOldDesc.Text = _tableDesc;
                    ButtonClick(imgOldDesc, null);
                }
            }           
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }


   

    private void BindTableCodeData()
    {
        try
        {
            string query = String.Empty;
            DataTable dt = null;
            //if (!string.IsNullOrEmpty(_oldCode))
            //{
                if (_tableCode == "3")
                {
                    //table601
                    dt = mng.getTable601RelevantCode();

                    lblCaption.Text = GetLocalResourceObject("Table601").ToString();
                    //btnGetSelected.Text = String.Format(btnGetSelected.Text, GetLocalResourceObject("Table601").ToString());
                }
                else if (_tableCode == "4")
                {
                    dt = mng.getTable606RelevantCode();
                    lblCaption.Text = GetLocalResourceObject("Table606").ToString();
                    //btnGetSelected.Text = String.Format(btnGetSelected.Text, GetLocalResourceObject("Table606").ToString());
                }
                else if (_tableCode == "5")
                {
                    ////table606 and table 601
                    dt = mng.getTable601_606RelevantCode();
                    lblCaption.Text = GetLocalResourceObject("Table601_606").ToString();
                    //btnGetSelected.Text = String.Format(btnGetSelected.Text, "");
                }
                Session["item"] = "tableCode";                               
            //}

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

            if (_noOldCode == "true")
                dgItems.Columns[0].Visible = false; 
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

            if (_noOldCode == "true" || ViewState["_noOldCode"] != null)
            {
                if (RelevantsNoOldCodeCheckedIndex == e.Row.RowIndex)
                    output.Text += @" checked='checked' ";
            }


            if (_noOldCode != "true" && ViewState["_noOldCode"] == null )
                output.Text += @" disabled='disabled' ";

            // Add the closing tag
            output.Text += " />";


            output = (Literal)e.Row.FindControl("RadioButtonCheck");
            if (output != null)
            {
                output.Text = string.Format(@"<input type='radio'  name='RelationshipGroup' " + @"id='RowSelector{0}' value='{0}' ", e.Row.RowIndex);
                if (RelevantsCheckedIndex == e.Row.RowIndex)
                    output.Text += @" checked='checked' ";

                // Add the closing tag
                output.Text += " />";

            }
            

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
    private Hashtable GetSelectedTableCode()
    {
        Hashtable hTbl = new Hashtable();
        Literal rdb = null;
        try
        {
            foreach (GridViewRow item in dgItems.Rows)
            {
                if(_noOldCode != "true")
                    rdb = item.FindControl("RadioButtonCheck") as Literal;
                else
                    rdb = item.FindControl("RadioButtonMarkup") as Literal;

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
                        if (lblCode != null)
                        {
                            int code = int.Parse(lblCode.Text);
                            hTbl["itemCode"] = code;
                        }

                        Label lblTableName = item.FindControl("lblTableName") as Label;
                        if (lblTableName != null && lblTableName.Text != String.Empty)
                        {
                            hTbl["table"] = lblTableName.Text;
                        }

                        Label lblCategory = item.FindControl("lblCategory") as Label;
                        if (lblCategory != null && lblCategory.Text != String.Empty)
                        {
                            hTbl["category"] = lblCategory.Text;
                        }


                        Label lblParent = item.FindControl("lblParent") as Label;
                        if (lblParent != null && lblParent.Text != String.Empty)
                        {
                            hTbl["parentName"] = lblParent.Text;
                        }

                        Label lblParentCode = item.FindControl("lblParentCode") as Label;
                        if (lblParentCode != null && lblParentCode.Text != String.Empty)
                        {
                            hTbl["parentCode"] = lblParentCode.Text;
                        }

                        if (hTbl.Count > 0)
                            return hTbl;
                    }
                    else return null;
                }
            }

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
        return hTbl;
    }

    //private string GetTableCategory(int code)
    //{
    //    string category = String.Empty;
    //    try
    //    {
    //        if (ViewState["OldCodes"] != null)
    //        {
    //            DataTable dtTableCodes = (DataTable)ViewState["OldCodes"];
    //            if (dtTableCodes != null && dtTableCodes.Rows.Count > 0)
    //            {
    //                DataRow[] rows = dtTableCodes.Select("Code = " + code.ToString());
    //                if (rows != null && rows.Length > 0)
    //                {
    //                    category = rows[0]["Category"].ToString();
    //                }
    //            }
    //        }

    //    }
    //    catch (Exception ex)
    //    {
    //        throw new Exception(ex.Message);
    //    }
    //    return category;
    //}


    
    //private int RelevantsSelectedIndex
    //{
    //    get
    //    {
    //        if (string.IsNullOrEmpty(Request.Form["RelevantsGroup"]))
    //            return -1;
    //        else
    //            return Convert.ToInt32(Request.Form["RelevantsGroup"]);
    //    }
    //}

    private int RelevantsCheckedIndex
    {
        get
        {
            if (string.IsNullOrEmpty(Request.Form["RelationshipGroup"]))
                return -1;
            else
                return Convert.ToInt32(Request.Form["RelationshipGroup"]);
        }
    }

    private int RelevantsNoOldCodeCheckedIndex
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
            SetSortingControls("lblSortCategory", "");

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void lnkCategory_Click(object sender, EventArgs e)
    {
        try
        {
            SortGridViewByColumn("Category");
            if (GridViewSortDirection == SortDirection.Ascending)
                SetSortingControls("lblSortCategory", "6");
            else
                SetSortingControls("lblSortCategory", "5");

            SetSortingControls("lblName", "");
            SetSortingControls("lblSortCode", "");
            SetSortingControls("lblSortParent", "");

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }



    protected void lnkParent_Click(object sender, EventArgs e)
    {
        try
        {
            SortGridViewByColumn("ParentCodeName");
            if (GridViewSortDirection == SortDirection.Ascending)
                SetSortingControls("lblSortParent", "6");
            else
                SetSortingControls("lblSortParent", "5");

            SetSortingControls("lblName", "");
            SetSortingControls("lblSortCode", "");
            SetSortingControls("lblSortCategory", "");

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
            SetSortingControls("lblSortCategory", "");
            SetSortingControls("lblSortParent", "");

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
            hTbl = GetSelectedTableCode();

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


