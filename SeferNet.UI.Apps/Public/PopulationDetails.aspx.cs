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
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using System.Text;
using SeferNet.Globals;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using SeferNet.UI;
using System.Collections.Generic;
using System.Linq;
using System.Drawing;
using System.Web.Services;

public partial class Public_PopulationDetails : System.Web.UI.Page
{
    Facade applicFacade = Facade.getFacadeObject();

    protected void Page_Load(object sender, EventArgs e)
    {
        // Bind the details of the page:
        byte populationCode = 0;
        byte.TryParse(this.Request.QueryString["pCode"], out populationCode);

        byte subPopulationCode = 0;
        byte.TryParse(this.Request.QueryString["pSubCode"], out subPopulationCode);

        DataSet dsPopulationDetails = applicFacade.GetPopulationDetails(populationCode, subPopulationCode);
        if (dsPopulationDetails != null && dsPopulationDetails.Tables.Count > 0 && dsPopulationDetails.Tables[0].Rows.Count > 0)
        {
            DataRow drPopulationDetails = dsPopulationDetails.Tables[0].Rows[0];

            string populationsDesc = drPopulationDetails["PopulationsDesc"].ToString();
            string parentPopulationDesc = drPopulationDetails["ParentPopulationDesc"].ToString();

            string title = "";
            if (!string.IsNullOrEmpty(parentPopulationDesc))
                title = parentPopulationDesc;//+ " - " + populationsDesc;
            else
                title = populationsDesc;

            this.Title = title;
            this.lblPopulationsDesc.Text = "תיאור אוכלוסיות - " + title;
            
            if (dsPopulationDetails.Tables.Count > 1 && dsPopulationDetails.Tables[1].Rows.Count > 0)
            {
                StringBuilder sbPopulationSettings = new StringBuilder();

                for (int i = 0; i < dsPopulationDetails.Tables[1].Rows.Count; i++)
                {
                    DataRow drPopulationSettings = dsPopulationDetails.Tables[1].Rows[i];

                    sbPopulationSettings.Append(drPopulationSettings["SettingsDesc"]);
                    sbPopulationSettings.Append("<br/>");
                    sbPopulationSettings.Append(Environment.NewLine);
                }

                this.lblSettingsDesc.Text = sbPopulationSettings.ToString();
            }
        }
    }
}