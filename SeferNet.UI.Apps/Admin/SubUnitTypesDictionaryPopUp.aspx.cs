using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.BusinessObject;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;

public partial class Admin_SubUnitTypesDictionaryPopUp : System.Web.UI.Page
{
   static  string _userName = String.Empty;
   protected string _parentUnitTypeCode = String.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        _userName = getUserName();
        if (Request.QueryString["parentUnitTypeCode"] != null)
        {
            _parentUnitTypeCode = Request.QueryString["parentUnitTypeCode"].ToString();
            //this.SqlDataSource1.SelectParameters.Add("UnitTypeCode", _parentUnitTypeCode);
            
        }
    }

    [WebMethod]
    public static void InsertNewSubUnitTypeCodes(string newCodes, string parentUnitTypeCode, string userName)
    {
        try
        {
            if (!String.IsNullOrEmpty(newCodes))
            {
                string[] code = newCodes.Split(',');
                if (code != null && code.Length > 0)
                {
                    for (int i = 0; i < code.Length; i++)
                    {
                       string subUnitTypeCode = code[i].ToString();
                       if (!string.IsNullOrEmpty(subUnitTypeCode) && !string.IsNullOrEmpty(parentUnitTypeCode))
                        {
                            InsertNewSubUnitTypeCodeToUnitTypeCode(subUnitTypeCode, parentUnitTypeCode, userName); 
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }                     
    }

    private static void InsertNewSubUnitTypeCodeToUnitTypeCode(string subUnitTypeCode, string parentUnitTypeCode, string userName)
    {
        try
        {
            ManageItemsBO bo = new ManageItemsBO();
            bo.AddSubUnitTypeCodeToUnitTypeCode(int.Parse(subUnitTypeCode), int.Parse(parentUnitTypeCode), userName);
        }
        catch (Exception ex)
        {            
            throw new Exception(ex.Message ) ;
        }
    }


    public  string getUserName()
    {
        UserInfo currentUser = new UserManager().GetUserInfoFromSession();
        return currentUser.UserNameWithPrefix;
    }
    
    protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        e.Command.Parameters["@UnitTypeCode"].Value = _parentUnitTypeCode;       
    }
    protected void chkSybUnitTypes_DataBound(object sender, EventArgs e)
    {
        DataView dvSql = (DataView)SqlDataSource1.Select(DataSourceSelectArguments.Empty);
        foreach (DataRowView drvSql in dvSql)
        {
            string subUnitTypeCode  = drvSql["subUnitTypeCode"].ToString();
            string subUnitTypeName = drvSql["subUnitTypeName"].ToString();
            string selected = drvSql["selected"].ToString();

            ListItem item = chkSybUnitTypes.Items.FindByText(subUnitTypeName);
           if (item != null && selected == "0")
           {
               item.Enabled = false;
               item.Selected = true;
           }
        }        
    }

    protected void chkSybUnitTypes_PreRender(object sender, EventArgs e)
    {

    }
}
