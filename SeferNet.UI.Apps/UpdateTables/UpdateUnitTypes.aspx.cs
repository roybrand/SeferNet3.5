using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;

public partial class UpdateTables_UpdateUnitTypes : System.Web.UI.Page
{
    private string _item = String.Empty;


    public string panelID = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        Panel pItems = MultiDDlSelect_SubUnitTypes.FindControl("pnlItems") as Panel;
        panelID = pItems.ClientID;
        
        this.pnlGrid.Attributes["onscroll"] = "javascript:GetScrollPosition('" + this.pnlGrid.ClientID + "','" + this.txtScrollTop.ClientID + "');";
        if (!Page.IsPostBack)
        {
            grUnitList.Item = "unitTypes";
            
            MultiDDlSelect_SubUnitTypes.Items.CssClass = "multiDropDown";
            
            SetDefaultSubUnitType();
            SetSubUnitTypesMultiDDl();

        }
        
        ScriptManager sm = ScriptManager.GetCurrent(Page);
        if (sm != null && UpdatePanel1 != null)
        {
            ScriptManager.RegisterStartupScript(UpdatePanel1, typeof(UpdatePanel), "ScrollDivToSelected", "javascript:ScrollDivToSelected('" + this.pnlGrid.ClientID + "','" + this.txtScrollTop.ClientID + "');", true);
        }
    }

    private void SetSubUnitTypesMultiDDl()
    {
        ManageItemsBO mngItems = new ManageItemsBO();
        DataTable dtSubUnits = null;
        dtSubUnits = mngItems.GetSubUnitTypes(-999);
        MultiDDlSelect_SubUnitTypes.BindData(dtSubUnits, "subUnitTypeCode", "subUnitTypeName");
        hfListOfTextsAndValues.Value = MultiDDlSelect_SubUnitTypes.listOfTextsAndValues;
    }

    private void SetDefaultSubUnitType()
    {
        UIHelper.BindDropDownToCachedTable(ddlDefaultSubUnitType, "DIC_SubUnitTypes", string.Empty);
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

    private void updateUnit()
    {
        ManageItemsBO mngItems = new ManageItemsBO();
        
        
        try
        {
            string code = hfCode.Value;
            string name = hfDescription.Value;
            string category = hfCategory.Value;
            bool allowQueueOrder = (hfAllowQueueOrder.Value == "1" ? true : false);
            bool showInInternet = (hfInternetDisplay.Value == "1" ? true : false);
            int defaultSubUnitType = Convert.ToInt32(hfDefaultSubUnitType.Value);
            string userName = getUserName();
            bool isActive = (hfIsActive.Value == "true" ? true : false);
            string subUnitTypeCodes = hfRelatedValues.Value;
            if (code != string.Empty && name != string.Empty)
            {
                mngItems.UpdateUnitTypes(Convert.ToInt32(code), name, userName, showInInternet, allowQueueOrder, isActive, defaultSubUnitType, Convert.ToInt32(category));
                
                /* Insert subUnitsTypes */
                mngItems.insertSubUnitTypes(subUnitTypeCodes, Convert.ToInt32(code), userName);
                
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    public string getUserName()
    {
        string usernameWithPrefix = new UserManager().GetLoggedinUserNameWithPrefix();

        return usernameWithPrefix;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {

        try
        {
            /* Update or Insert new */
            if (hfUpdateFlag.Value == "true")
            {
                updateUnit();
                grUnitList.BindUnits();
            }
            else
            {
                string code = hfCode.Value;
                string name = hfDescription.Value;
                string category = hfCategory.Value;


                if (code != string.Empty && name != string.Empty)
                {
                    grUnitList.NewCode = int.Parse(code);
                    grUnitList.NewDescription = name;
                    grUnitList.Category = Convert.ToInt32(category);

                    if (hfAllowQueueOrder.Value == "1")
                        grUnitList.AllowQueueOrder = true;

                    if (hfInternetDisplay.Value == "1")
                        grUnitList.ShowInInternet = true;


                    grUnitList.DefaultSubUnitCode = Convert.ToInt32(hfDefaultSubUnitType.Value);

                    grUnitList.NewSubUnitTypes = hfRelatedValues.Value;

                    bool result = grUnitList.AddNewItem();
                    if (!result)
                    {
                        string message = GetLocalResourceObject("addingError").ToString();
                        ThrowAlert(message);
                    }


                }
            }
            
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }
}