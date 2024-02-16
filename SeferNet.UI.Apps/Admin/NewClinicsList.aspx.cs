using System;
using System.Linq;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Globalization;

using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.BusinessObject;
using System.Data.SqlClient;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.DataLayer;
using SeferNet.FacadeLayer;
using MapsManager;
using SeferNet.Globals;

public partial class NewClinicListSearchParameters
{
    public string DeptName;
    public int? DeptCode;
    public DateTime? OpenDateSimul;
    public int? ExistsInSefer;
}

public partial class NewClinicsList : AdminBasePage
{
    Facade applicFacade;
    UserInfo currentUser;
    DataSet dsNewClinicsList;
    SessionParams sessionParams;
    string permittedDistricts;
    string errorMessage;
    NewClinicListSearchParameters newClinicListSearchParameters;



    protected void Page_Load(object sender, EventArgs e)
    {
        currentUser = Session["currentUser"] as UserInfo;

        if (currentUser != null)
        {
            SetSearchParameters();

            sessionParams = SessionParamsHandler.GetSessionParams();
            sessionParams.CallerUrl = null;
            SessionParamsHandler.SetSessionParams(sessionParams);

            applicFacade = Facade.getFacadeObject();

            if (newClinicListSearchParameters.DeptCode > 1)
            {
                applicFacade.InsertSimulExceptions(Convert.ToInt32(newClinicListSearchParameters.DeptCode), 1, currentUser.UserNameWithPrefix);
            }

            applicFacade.InsertNewClinicsList();
            dsNewClinicsList = applicFacade.getNewClinicsList(newClinicListSearchParameters.DeptCode, newClinicListSearchParameters.DeptName, newClinicListSearchParameters.OpenDateSimul, newClinicListSearchParameters.ExistsInSefer);

            DataView dvNewClinicsList;

            if (currentUser.IsAdministrator)
            {
                dvNewClinicsList = new DataView(dsNewClinicsList.Tables[0]);
                gvNewClinicsList.DataSource = dsNewClinicsList.Tables[0];
            }
            else
            {
                permittedDistricts = GetPermittedDistricts();
                if (permittedDistricts == string.Empty)
                    permittedDistricts = "0";

                dvNewClinicsList = new DataView(dsNewClinicsList.Tables[0],
                                    " DistrictCode IN (" + permittedDistricts + ") OR ManageId IN (" + permittedDistricts + ")", 
                                    "deptCode", DataViewRowState.OriginalRows);

                gvNewClinicsList.DataSource = dvNewClinicsList;
            }

            gvNewClinicsList.DataBind();

            if(dvNewClinicsList.Count > 0)
                lblInterfaceDate.Text = Convert.ToDateTime( dsNewClinicsList.Tables[0].Rows[0]["updateDate"]).ToString("dd/MM/yyyy");

        }

    }

    private void SetSearchParameters()
    {
        newClinicListSearchParameters = new NewClinicListSearchParameters();

        if (!IsPostBack)
        {
            if (Session["NewClinicListSearchParameters"] != null)
            {
                newClinicListSearchParameters = (NewClinicListSearchParameters)Session["NewClinicListSearchParameters"];

                txtSimulOpenDate.Text = newClinicListSearchParameters.OpenDateSimul.ToString();
                txtNewClinicCode.Text = newClinicListSearchParameters.DeptCode.ToString();
                txtClinicName.Text = newClinicListSearchParameters.DeptName;
                ddlExistsInDept.SelectedValue = newClinicListSearchParameters.ExistsInSefer.ToString();
            }
            else
            {
                txtSimulOpenDate.Text = DateTime.Now.AddYears(-1).ToString("dd/MM/yyyy");
                ddlExistsInDept.SelectedValue = "0";
                txtClinicName.Text = string.Empty;
                txtNewClinicCode.Text = string.Empty;

                newClinicListSearchParameters.OpenDateSimul = Convert.ToDateTime(txtSimulOpenDate.Text);
                if (txtNewClinicCode.Text.All(char.IsDigit) && txtNewClinicCode.Text != string.Empty)
                {
                    newClinicListSearchParameters.DeptCode = Convert.ToInt32(txtNewClinicCode.Text);
                }
                else
                {
                    newClinicListSearchParameters.DeptCode = null;
                }

                newClinicListSearchParameters.DeptName = txtClinicName.Text.Trim();
                newClinicListSearchParameters.ExistsInSefer = Convert.ToInt32(ddlExistsInDept.SelectedValue);

                Session["NewClinicListSearchParameters"] = newClinicListSearchParameters;
            }

        }
        else
        {
            if (txtSimulOpenDate.Text == string.Empty)
            {
                newClinicListSearchParameters.OpenDateSimul = null;
            }
            else
            {
                newClinicListSearchParameters.OpenDateSimul = Convert.ToDateTime(txtSimulOpenDate.Text);
            }

            if (txtNewClinicCode.Text.All(char.IsDigit) && txtNewClinicCode.Text != string.Empty)
            {
                newClinicListSearchParameters.DeptCode = Convert.ToInt32(txtNewClinicCode.Text);
            }
            else
            {
                newClinicListSearchParameters.DeptCode = null;
            }

            newClinicListSearchParameters.DeptName = txtClinicName.Text.Trim();
            newClinicListSearchParameters.ExistsInSefer = Convert.ToInt32(ddlExistsInDept.SelectedValue);

            Session["NewClinicListSearchParameters"] = newClinicListSearchParameters;

        }

    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        ScriptManager.RegisterClientScriptBlock(this, typeof(UpdatePanel), "hideProgressBarGeneral", "hideProgressBarGeneral()", true);
    }
    private string GetPermittedDistricts()
    {
        string permittedDistricts = string.Empty;
        if(currentUser != null)
        { 
            foreach (UserPermission UP in currentUser.UserPermissions)
            {
                if (UP.PermissionType == Enums.UserPermissionType.District)
                {
                    if (permittedDistricts != string.Empty)
                        permittedDistricts = permittedDistricts + ',';
                    permittedDistricts = permittedDistricts + UP.DeptCode.ToString();
                }
            }
        }
        return permittedDistricts;
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        UserManager mng = new UserManager();


    }

    protected void btnBackToOpener_Click(object sender, EventArgs e)
    {
        sessionParams.ServiceCode = null;
        SessionParamsHandler.SetSessionParams(sessionParams);

        Response.Redirect(@"~/Public/ZoomClinic.aspx");
    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        //int Err = updateService(ref errorMessage);
        int Err = 0;

        if (Err == 0)
        {
            ClientScript.RegisterStartupScript(typeof(string), "okMessageAndBackToZoomClinic", "OkMessageAndBackToZoomClinic();", true);
        }
        else 
        {
            lblGeneralError.Text = errorMessage;
        }

    }

    protected void gvNewClinicsList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            Button btnAddClinicAndUpdate = e.Row.FindControl("btnAddClinicAndUpdate") as Button;

            Label lblInserted = e.Row.FindControl("lblInserted") as Label;
            HtmlTable tblButtons = e.Row.FindControl("tblButtons") as HtmlTable;

            Image imgDetailes = e.Row.FindControl("imgDetailes") as Image;
            imgDetailes.Attributes.Add("onClick", "return OpenClinicDetailesPopUp(" + dvRowView["deptCode"].ToString() + ")");

            if (Convert.ToInt32(dvRowView["ExistsInDept"]) == 1)
            {
                btnAddClinicAndUpdate.Enabled = false;

                tblButtons.Style.Add("display", "none");
                lblInserted.Style.Add("display", "inline");

                for (int i = 0; i < e.Row.Controls.Count; i++)
                {
                    SetLabelsInControls(e.Row.Controls[i]);
                }

                lblInserted.Style.Add("color", "#0069CC");
            }
            else
            {
                lblInserted.Style.Add("display", "none");
            }

        }
    }

    protected void SetLabelsInControls(Control control)
    {
        try
        {
            Label lbl = control as Label;
            if (lbl != null)
                lbl.Style.Add("color", "#999999");
        }
        finally
        {
            for (int i = 0; i < control.Controls.Count; i++)
            {
                SetLabelsInControls(control.Controls[i]);
            }
        }

    }


    protected void btnAddClinicAndUpdate_Click(object sender, EventArgs e)
    {
        Button btnAddClinicAndUpdate = sender as Button;
        string errorMessage = string.Empty;
        int errorCode = 0;
        int deptCode = Convert.ToInt32(btnAddClinicAndUpdate.Attributes["DeptCode"]);

        if (DeptExistsAsMushlamOnly(deptCode))
            errorCode = UpdateDeptToCommunity(deptCode, ref errorMessage);
        else
            errorCode = InsertNewDept(deptCode, ref errorMessage);

        if (errorCode == 0)
        {
            SessionParamsHandler.SetDeptCodeInSession(deptCode);
            sessionParams.CallerUrl = "../Admin/NewClinicsList.aspx";
            SessionParamsHandler.SetSessionParams(sessionParams);
            Response.Redirect(@"../Public/ZoomClinic.aspx?DeptCode=" + deptCode, true);
        }
        else
        {
            lblGeneralError.Text = errorMessage;
        }

    }

    private bool DeptExistsAsMushlamOnly(int deptCode)
    {
        Dept dept = applicFacade.GetDeptGeneralBelongings(deptCode);

        if (dept == null)
            return false;
        else
        {
            if (dept.IsMushlam && !dept.IsCommunity)
                return true;
        }

        return false;
    }

    private string GetAbsoluteUrl(int deptCode)
    {
        string serverName = Request.ServerVariables["SERVER_NAME"].ToString();
        string[] segmentsURL = Request.Url.Segments;
        string url = string.Empty;
        url = "http://" + serverName + segmentsURL[0] + segmentsURL[1] + "Public/ZoomClinic.aspx?DeptCode=" + deptCode.ToString();
        return url;
    }

    private int InsertNewDept(int deptCode, ref string errorMessage)
    {
        int errorCode = 0;
        double coordinateX = 0;
        double coordinateY = 0;
        double XLongitude = 0;
        double YLatitude = 0;
        string SPSlocationLink = null;
        string Url = GetAbsoluteUrl(deptCode);

        DataSet ds = applicFacade.GetNewClinic(deptCode);
        if (ds != null && ds.Tables[0].Rows.Count > 0)
        {
            DataRow dr = ds.Tables[0].Rows[0];
            int number = 0;
            int.TryParse(dr["house"].ToString(), out number);

            MapCoordinatesClient cli = new MapCoordinatesClient(MapHelper.GetMapApplicationEnvironmentController());
            CoordInfo coordInfo = cli.GetXY(dr["cityName"].ToString(), dr["street"].ToString(), number, string.Empty, string.Empty);
            if (coordInfo != null && coordInfo.X > 0)
            {
                coordinateX = coordInfo.X;
                coordinateY = coordInfo.Y;
                XLongitude = coordInfo.XLongitude;
                YLatitude = coordInfo.YLatitude;
            }
        }
        else
        {
            errorCode = 1;
            return errorCode;
        }

        errorCode = applicFacade.InsertNewDeptTransaction(deptCode, currentUser.UserNameWithPrefix, coordinateX, coordinateY, XLongitude, YLatitude, SPSlocationLink, ref errorMessage);

        if (errorCode != 1)
        {
            //applicFacade.SendNewClinicMailReport(deptCode, GetAbsoluteUrl(deptCode));
            applicFacade.LoadUserInfo(currentUser.UserID);
        }

        return errorCode;
    }

    private int UpdateDeptToCommunity(int deptCode, ref string errorMessage)
    {
        int errorCode = 0;
        errorCode = applicFacade.UpdateDeptToCommunity(deptCode, currentUser.UserNameWithPrefix, ref errorMessage);
        return errorCode;
    }

    protected void btnDeleteNewClinic_Click(object sender, EventArgs e)
    {
        ImageButton btnDeleteNewClinic = sender as ImageButton;
        int deptCode = Convert.ToInt32(btnDeleteNewClinic.Attributes["DeptCode"]);
        applicFacade.DeleteSimulNewDepts(deptCode);

        for (int i = 0; i < gvNewClinicsList.Rows.Count; i++)
        {
            if (gvNewClinicsList.Rows[i].RowType == DataControlRowType.DataRow)
            {
                GridViewRow Row = gvNewClinicsList.Rows[i];
                Label lblDeptCode = Row.FindControl("lblDeptCode") as Label;
                if (lblDeptCode.Text == btnDeleteNewClinic.Attributes["DeptCode"])
                {
                    Image imgDetailes = Row.FindControl("imgDetailes") as Image;
                    imgDetailes.Attributes.Remove("onClick");

                    HtmlTable tblButtons = Row.FindControl("tblButtons") as HtmlTable;
                    tblButtons.Style.Add("display", "none");

                    Label lblInserted = Row.FindControl("lblInserted") as Label;
                    lblInserted.Text = "נמחק";
                    lblInserted.Style.Remove("display");
                    lblInserted.Style.Add("display", "inline");

                    ImageButton imgDeleteNewClinic = Row.FindControl("btnDeleteNewClinic") as ImageButton;
                    imgDeleteNewClinic.Style.Add("display", "none");
                }
            }
        }

        //dsNewClinicsList = applicFacade.getNewClinicsList(newClinicListSearchParameters.DeptCode, newClinicListSearchParameters.DeptName, newClinicListSearchParameters.OpenDateSimul, newClinicListSearchParameters.ExistsInSefer);
        //gvNewClinicsList.DataSource = dsNewClinicsList.Tables[0];
        //gvNewClinicsList.DataBind();
    }

}
