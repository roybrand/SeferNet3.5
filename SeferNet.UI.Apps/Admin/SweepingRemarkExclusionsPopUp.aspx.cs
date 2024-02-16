using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Text.RegularExpressions;
using System.Text;
using System.Web.Services;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.FacadeLayer;

public partial class SweepingRemarkExclusionsPopUp : AdminPopupBasePage
{
    private int RemarkID;
    private string RemarkText = String.Empty;

	protected void Page_Load(object sender, EventArgs e)
	{
		GetRequestParameters();
		if (!Page.IsPostBack)
		{
			this.BindPage();
		}
	}
    
    #region GerRequestData

	private void GetRequestParameters()
    {
        if (Request["RemarkID"] != null && Request["RemarkID"].ToString() != String.Empty)
        {
            int.TryParse(this.Request["RemarkID"].ToString(), out this.RemarkID);
        }
    
		//if (Request["RemarkText"] != null && Request["RemarkText"].ToString() != String.Empty)
		//{            
		//    this.RemarkText = Server.UrlDecode(Request["RemarkText"].ToString());
		//}  
    }
 
    #endregion

    #region BindData

    private void BindPage()
    {
		
		Facade facade = Facade.getFacadeObject();
		DataSet ds = facade.GetSweepingRemarkExclusions(this.RemarkID);
		this.gvDepts.DataSource = ds.Tables[0];
		this.gvDepts.DataBind();

		this.lblCaption.Text = ds.Tables[1].Rows[0]["RemarkText"] as string;
    }

    #endregion
}
