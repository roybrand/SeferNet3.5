using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;

public partial class UpdateTables_UpdateBrochuresAndForms : System.Web.UI.Page
{
    public string formsAndBrochuresPath = System.Configuration.ConfigurationManager.AppSettings["formsAndBrochuresPath"].ToString();
    DataSet dsForms;
    DataSet dsBrochures;
    Facade applicFacade = Facade.getFacadeObject();

    bool IsCommunity
    {
        get
        {
            return (ddlType.SelectedValue == "1" ? true : false);
        }
    }

    bool IsMushlam
    {
        get
        {
            return (ddlType.SelectedValue == "2" ? true : false);
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            bindBrochures();
            bindForms();
            setLanguages();
        }
        else
        {
            string manageTable = hfManageTable.Value;
            switch (manageTable)
            { 
                case "forms":
                    manageForm();
                    break;
                case "brochures":
                    manageBrochure();
                    break;
            }
            
        }
    }

    private void setLanguages()
    {
        DataTable dt = applicFacade.GetLanguages();
        ddlLanguages.DataSource = dt;
        ddlLanguages.DataTextField = "languageDescription";
        ddlLanguages.DataValueField = "languageCode";
        ddlLanguages.DataBind();
    }

    private void bindBrochures()
    {
        dsBrochures = applicFacade.GetBrochures(IsCommunity, IsMushlam);
        
        gvBrochures.DataSource = dsBrochures.Tables[0];
        gvBrochures.DataBind();

        
    }

    private void bindForms()
    {
        dsForms = applicFacade.GetForms(IsCommunity, IsMushlam);
        gvForms.DataSource = dsForms;
        gvForms.DataBind();
    }
    
    protected void manageForm()
    {
        try
        {

            string newFileName = "";
            string manageType = hfAction.Value;
            int selectedID;
            

            switch (manageType)
            { 
                case "insert":
                    newFileName = getFormatedFileName(txtNewFileName.Text);
                    fuNewFormFile.SaveAs(formsAndBrochuresPath + "\\" + newFileName);
                    applicFacade.InsertForm(newFileName, txtFormName.Text, IsCommunity, IsMushlam);
                    break;
                case "update":
                    newFileName = getFormatedFileName(txtNewFileName.Text);
                    fuNewFormFile.SaveAs(formsAndBrochuresPath + "\\" + newFileName);
                    selectedID = Int32.Parse(hfSelectedID.Value);
                    applicFacade.UpdateForm(selectedID, newFileName, txtFormName.Text);
                    break;
                case "delete":
                    selectedID = Int32.Parse(hfSelectedID.Value);
                    applicFacade.DeleteForm(selectedID);
                    break;
            }

            hfAction.Value = "";
            hfSelectedID.Value = "";
            bindForms();
        }
        catch (Exception ex) { } 
        
    }

    private string getFormatedFileName(string fName)
    {
        
        if (fName.Split('.').Length == 1)
        {
            return fName + ".pdf";
        }
        else
            return fName;
        
    }

    protected void manageBrochure()
    {
        try
        {
            string newFileName = "";
            string action = hfAction.Value;
            int selectedID;
            int langCode;

            switch (action)
            {
                case "insert":
                    newFileName = getFormatedFileName(txtNewBrochureFileName.Text);
                    fuNewBrochureFile.SaveAs(formsAndBrochuresPath + "\\" + newFileName);
                    langCode = Int32.Parse(ddlLanguages.SelectedValue);
                    applicFacade.InsertBrochure(txtBrochureName.Text, newFileName, langCode, IsCommunity, IsMushlam);
                    break;
                case "update":
                    newFileName = getFormatedFileName(txtNewBrochureFileName.Text);
                    fuNewBrochureFile.SaveAs(formsAndBrochuresPath + "\\" + newFileName);
                    langCode = Int32.Parse(ddlLanguages.SelectedValue);
                    selectedID = Int32.Parse(hfSelectedID.Value);
                    applicFacade.UpdateBrochure(selectedID, txtBrochureName.Text, newFileName, langCode);
                    break;
                case "delete":
                    selectedID = Int32.Parse(hfSelectedID.Value);
                    applicFacade.DeleteBrochure(selectedID);
                    break;
            }

            hfAction.Value = "";
            hfSelectedID.Value = "";
            bindBrochures();
        }
        catch (Exception ex) { }

    }

    protected void btnDelete_Click(object sender, ImageClickEventArgs e)
    {
        int selectedID = Int32.Parse((sender as ImageButton).CommandArgument);

        applicFacade.DeleteForm(selectedID);
        bindForms();
    }
    
    
    protected void gvForms_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int rowIndex = e.Row.RowIndex;
            ImageButton ib = e.Row.FindControl("btnDelete") as ImageButton;
            ib.Attributes.Add("onclick", "deleteItem('" + dsForms.Tables[0].Rows[rowIndex][0].ToString() + "','forms')");
        }
    }


    protected void gvBrochures_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int rowIndex = e.Row.RowIndex;
            ImageButton ib = e.Row.FindControl("btnDelete") as ImageButton;
            ib.Attributes.Add("onclick", "deleteItem('" + dsBrochures.Tables[0].Rows[rowIndex][0].ToString() + "','brochures')");
        }
    }
    protected void ddlType_SelectedIndexChanged(object sender, EventArgs e)
    {
        bindBrochures();
        bindForms();
    }
}