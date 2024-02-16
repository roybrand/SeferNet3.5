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
using SeferNet.FacadeLayer;
using System.Data.SqlClient;

public partial class UpdateDIC_HandicappedFacilities : AdminBasePage
{
    DataSet ds;
    DataSet dsPrefix;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        { 
            UIHelper.BindDropDownToCachedTable(ddlPhoneTypeNew, "DIC_PhoneTypes", "phoneTypeName");
            string referringUrl = Request.UrlReferrer.AbsolutePath;
            ViewState["referringUrl"] = referringUrl;
            GetDataForGrid();
            BindGridView();
        }
    }

    private void GetDataForGrid()
    {
        Facade applicFacade = Facade.getFacadeObject();
        dsPrefix = applicFacade.getPhonePrefixListAll();
        ViewState["dsPrefix"] = dsPrefix;
    }
    private void BindGridView()
    {
        DataSet dsPrefix = ViewState["dsPrefix"] as DataSet;
        gvPhonePrefix.DataSource = dsPrefix;
        gvPhonePrefix.DataBind();
    }
   
    protected void btnInsert_Click(object sender, EventArgs e)
    {
        string prefixValue;
        int phoneType;
        int newPrefixCode;
        prefixValue = txtPrefixValue.Text;
        phoneType = Convert.ToInt32(ddlPhoneTypeNew.SelectedValue);
        Facade applicFacade = Facade.getFacadeObject();

        try
        {
            newPrefixCode = applicFacade.InsertPhonePrefix(prefixValue, phoneType);
            if (newPrefixCode > 0)
            {
                gvPhonePrefix.EditIndex = -1;
                GetDataForGrid();
                BindGridView();
                txtprefixCode.Text = string.Empty;
                txtPrefixValue.Text = string.Empty;
            }
            else
            {
                Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "UnableToAddRow") as string;
            }
        }
        catch (Exception exp)
        {
            ConstraintException ex = exp as ConstraintException;
            if (ex != null)
            {
                Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "UnableToAddRow") as string;

            }
            else
            {
                Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalUpdateError") as string;
            }
            return;
        }
    }

    protected void imgDelete_Click(object sender, ImageClickEventArgs e)
    {
        try
        {
            GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
            if (row != null)
            {
                Label lblPrefixCode = row.FindControl("lblPrefixCode") as Label;
                int prefixCode = Convert.ToInt32(lblPrefixCode.Text);
                Facade applicFacade = Facade.getFacadeObject();

                int errorCode = applicFacade.DeletePhonePrefix(prefixCode);

                if (errorCode == 0)
                {
                    GetDataForGrid();
                    BindGridView();
                }
                else
                {
                    Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "UnableToDeleteRow") as string;
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
    {
        try
        {
            GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
            if (row != null)
            {
                gvPhonePrefix.EditIndex = row.RowIndex;

                GetDataForGrid();
                BindGridView();
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void imgCancel_Click(object sender, ImageClickEventArgs e)
    {
        try
        {
            gvPhonePrefix.EditIndex = -1;

            GetDataForGrid();
            BindGridView();
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    protected void imgSave_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;

        Label lblPrefixCode = row.FindControl("lblPrefixCode") as Label;
        int prefixCode = Convert.ToInt32(lblPrefixCode.Text);
        
        DropDownList ddlPhoneType = row.FindControl("ddlPhoneType") as DropDownList;
        int phoneType = Convert.ToInt32(ddlPhoneType.SelectedValue);

        TextBox txtPrefixValue = row.FindControl("txtPrefixValue") as TextBox;
        string prefixValue = txtPrefixValue.Text.Trim();
        
        Facade applicFacade = Facade.getFacadeObject();
        bool result;
        result = applicFacade.UpdatePhonePrefix(prefixCode, prefixValue, phoneType);

        if (result == true)
        {
            gvPhonePrefix.EditIndex = -1;
            GetDataForGrid();
            BindGridView();
        }
    }

    protected void gvPhonePrefix_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        GridView gv = (GridView)sender;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (gv.EditIndex == e.Row.RowIndex)
            {
                DropDownList ddlPhoneType = e.Row.FindControl("ddlPhoneType") as DropDownList;
                UIHelper.BindDropDownToCachedTable(ddlPhoneType, "DIC_PhoneTypes", "phoneTypeName");
                ddlPhoneType.SelectedValue = dsPrefix.Tables[0].Rows[e.Row.RowIndex]["phoneType"].ToString();
            }
        }
    }
}
