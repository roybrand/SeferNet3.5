using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using System.Web.UI.HtmlControls;

public partial class Public_MushlamServices : System.Web.UI.Page
{
    public int DeptCode { get; set; }
    public int CurrentMushlamServiceCode { get; set; }
    public int salServiceCode { get; set; }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            SetUiContorls();
            BindMushlamData();
        }
    }

    private void SetUiContorls()
    {
        bool isCommunity = Convert.ToBoolean(Request.QueryString["isCommunity"]);
        bool isMushlam = Convert.ToBoolean(Request.QueryString["isMushlam"]);
        bool isHospital = Convert.ToBoolean(Request.QueryString["isHospital"]);
        int subUnitTypeCode = Convert.ToInt32(Request.QueryString["subUnitTypeCode"]);       

        UIHelper.SetImageForDeptAttribution(ref imgAttribution, isCommunity, isMushlam, isHospital, subUnitTypeCode);
        lblDeptName.Text = Request.QueryString["deptName"]; ;

     }

    private void BindMushlamData()
    {
        DataTable dtMushlam = new DataTable();

        if (Request.QueryString["deptCode"] != null)
        {
            DeptCode = Convert.ToInt32(Request.QueryString["deptCode"]);

            DataSet ds = Facade.getFacadeObject().getClinicDetails(DeptCode, string.Empty, string.Empty);

            dtMushlam = ds.Tables["mushlamServices"];

        }
        else if (Request.QueryString["salServiceCode"] != null)
        {
            salServiceCode = Convert.ToInt32(Request.QueryString["salServiceCode"]);

            lblServiceName.Text = Request.QueryString["ServiceName"].ToString();
            imgAttribution.Attributes.CssStyle.Add("display", "none");

            DataSet ds = Facade.getFacadeObject().GetMushlamServicesForSalService(salServiceCode);
            dtMushlam = ds.Tables[0];

            if (dtMushlam.Rows.Count == 0)
            {
                tblResult.Attributes.CssStyle.Add("display", "none");
                tblNoRrecordsFound.Attributes.CssStyle.Add("display", "inline");
                return;
            }

        }
        rptSearchResults.DataSource = dtMushlam;
        rptSearchResults.DataBind();

        CurrentMushlamServiceCode = Convert.ToInt32(dtMushlam.Rows[0]["ServiceCode"]);
        int groupCode = Convert.ToInt32(dtMushlam.Rows[0]["GroupCode"]);
        int subGroupCode = Convert.ToInt32(dtMushlam.Rows[0]["SubGroupCode"]);

        DisplayMushlamServiceData(CurrentMushlamServiceCode, groupCode, subGroupCode);

        ((HtmlControl)rptSearchResults.Items[0].FindControl("divServiceRow")).Attributes.Add("class", "mushlamServiceResultsRowSelected");
    }

    private void DisplayMushlamServiceData(int serviceCode, int groupCode, int subGroupCode)
    {
        MushlamService service = Facade.getFacadeObject().GetMushlamServiceByCode(serviceCode, groupCode, subGroupCode);

        lblGeneralRemark.Text = service.GeneralRemark;
        lblRepRemark.Text = service.RepresentativeRemark;

        if (!string.IsNullOrEmpty(service.SelfParticipation))
            lblAgreementDetails.Text = "<b>" + service.SelfParticipation + "</b></br></br>";
        lblAgreementDetails.Text += service.AgreementRemark;

        if (!string.IsNullOrEmpty(service.ClalitRefund))
            lblRefund.Text = "<b>" + service.ClalitRefund + "</b></br></br>";
        lblRefund.Text += service.PrivateRemark;
        if (lblRefund.Text != "")
            lblRefund.Text += "</br>";
        lblRefund.Text += service.RequiredDocuments;

        rptLinkedServices.Visible = false;
        if (!string.IsNullOrEmpty(service.LinkedBasketServices))
        {
            MushlamManager manager = new MushlamManager();
            List<LinkedService> servicesList = manager.GetLinkedServicesForMushlamService(service);

            rptLinkedServices.Visible = true;
            rptLinkedServices.DataSource = servicesList;
            rptLinkedServices.DataBind();
        }

        // service models
        rptModels.Visible = false;
        List<MushlamModel> list = Facade.getFacadeObject().GetMushlamModelsForService(CurrentMushlamServiceCode);
        if (list.Count > 0)
        {
            rptModels.Visible = true;
            rptModels.DataSource = list;
            rptModels.DataBind();
        }
    }


    protected void lnkMushlamService_clicked(object sender, EventArgs e)
    {
        LinkButton link = sender as LinkButton;
        HtmlControl row;
        if (link != null)
        {
            CurrentMushlamServiceCode = Convert.ToInt32(link.CommandArgument.Split('_')[0]);
            int groupCode = Convert.ToInt32(link.CommandArgument.Split('_')[1]);
            int subGroupCode = Convert.ToInt32(link.CommandArgument.Split('_')[2]);
            DisplayMushlamServiceData(CurrentMushlamServiceCode, groupCode, subGroupCode);

            // mark the selected row
            foreach (RepeaterItem ctrl in rptSearchResults.Items)
            {
                row = (HtmlControl)ctrl.FindControl("divServiceRow");
                row.Attributes.Add("class", "mushlamServiceResultsRow");
            }

            ((HtmlControl)link.Parent).Attributes.Add("class", "mushlamServiceResultsRowSelected");
        }
    }
}