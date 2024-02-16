using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using Clalit.SeferNet.GeneratedEnums;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;
using SeferNet.BusinessLayer.WorkFlow;
using System.Web.UI.HtmlControls;
using System.Configuration;

public partial class Public_DeptSubClinics : System.Web.UI.Page
{
    DataSet m_dsClinic; 
    Facade applicFacade = Facade.getFacadeObject();
    int m_DeptCode;
    SessionParams sessionParams;
    
    protected void Page_Load(object sender, EventArgs e)
    {
        sessionParams = SessionParamsHandler.GetSessionParams();
        m_DeptCode = Int32.Parse(Request.QueryString["deptCode"]);
        m_dsClinic = applicFacade.getDeptSubClinics(m_DeptCode);
        setImageForDeptAttribution();
        setDeptName();
        BindSubClinics();
    }

    public bool BindSubClinics()
    {
        gvSubClinics.DataSource = m_dsClinic.Tables["subClinics"];
        gvSubClinics.DataBind();

        return true;
    }

    protected void gvSubClinics_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowIndex != -1)
        {
            int rowInd = e.Row.DataItemIndex;
            DataRow currentRow = m_dsClinic.Tables["subClinics"].Rows[rowInd];


            string mapURL = string.Empty;
            Image imgRecComm = e.Row.FindControl("imgRecepAndComment") as Image;
            Image imgServiceLevel = e.Row.FindControl("imgServiceLevel") as Image;
            Image imgMap = e.Row.FindControl("imgMap") as Image;

            if (ConfigurationManager.AppSettings["mapServerIP"] != null)
            {
                mapURL = "http://" + ConfigurationManager.AppSettings["mapServerIP"].ToString() + "/clinics/mapPage.asp";
                imgMap.Attributes.Add("onClick", "OpenMapWindow('" + mapURL + "'," + currentRow["deptCode"].ToString() + ")");
                imgMap.Attributes.Add("alt", "הקש להצגת חלון מפה");
                imgMap.ImageUrl = "~/Images/Applic/searchResultGrid_btnMap.gif";
            }

            if (Convert.ToInt32(currentRow["deptLevel"]) == 3)
            {
                imgServiceLevel.ImageUrl = "~/Images/vSign.gif";
                //imgServiceLevel.Style.Add("display", "none");
                imgServiceLevel.Visible = false;
            }
            if (Convert.ToInt32(currentRow["deptLevel"]) == 2)
            {
                imgServiceLevel.ImageUrl = "~/Images/Applic/M.gif";
                imgServiceLevel.Attributes.Add("alt", "שירות ברמה מחוזית");
            }
            if (Convert.ToInt32(currentRow["deptLevel"]) == 1)
            {
                imgServiceLevel.ImageUrl = "~/Images/Applic/A.gif";
                imgServiceLevel.Attributes.Add("alt", "שירות ברמה ארצית");
            }

            // rendering a picture: Open/Not Open PopUp with "Receiving Hours & Comments"
            //imgRecComm.Attributes.Add("onClick", "OpenReceptionWindow(" + currentRow["deptCode"].ToString() + ")");
            bool subClinicHasReceptionHours = (Convert.ToInt32(currentRow["countReception"]) > 0 ? true : false);
            bool subClinicHasRemarks = (Convert.ToInt32(currentRow["countDeptRemarks"]) > 0 ? true : false);
            UIHelper.setClockRemarkImage(imgRecComm, subClinicHasReceptionHours, subClinicHasRemarks, "Blue",
                "return OpenReceptionWindowDialog(" + currentRow["deptCode"].ToString() + ")",
                "", "", "");

            Image imgAttributed = e.Row.FindControl("imgAttributed") as Image;
            UIHelper.SetImageForDeptAttribution(ref imgAttributed, Convert.ToBoolean(currentRow["IsCommunity"]),
                                    Convert.ToBoolean(currentRow["IsMushlam"]), Convert.ToBoolean(currentRow["IsHospital"]), Convert.ToInt32(currentRow["SubUnitTypeCode"]));
        }
    }

    private void setImageForDeptAttribution()
    {
        bool isCommunity = bool.Parse(Request.QueryString["isCommunity"]);
        bool isMushlam = bool.Parse(Request.QueryString["isMushlam"]);
        bool isHospital = bool.Parse(Request.QueryString["isHospital"]);
        int subUnitTypeCode = int.Parse(Request.QueryString["subUnitTypeCode"]);
        UIHelper.SetImageForDeptAttribution(ref imgAttributed_6, isCommunity, isMushlam, isHospital, subUnitTypeCode);
    }

    private void setDeptName()
    {
        lblDeptName_SubClinics.Text = sessionParams.DeptName;
    }
}