using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using System.Data;
using SeferNet.Globals;

public partial class MedicalAspects : System.Web.UI.Page
{
    SessionParams sessionParams;
    UserInfo currentUser;
    bool m_isDeptPermittedForUser;
    Facade applicFacade = Facade.getFacadeObject();

    protected void Page_Load(object sender, EventArgs e)
    {
        sessionParams = SessionParamsHandler.GetSessionParams();
        currentUser = Session["currentUser"] as UserInfo;
        m_isDeptPermittedForUser = applicFacade.IsDeptPermitted(sessionParams.DeptCode);

        if (txtMedicalAspectsToAdd.Text != string.Empty)
        {
            bool insertedOK = applicFacade.InsertClinicMedicalAspects(sessionParams.DeptCode, txtMedicalAspectsToAdd.Text, currentUser.NameForLog);
            if (insertedOK)
            {
                txtMedicalAspectsToAdd.Text = string.Empty;
                BindGridView();
                Session[ConstsSession.CLINIC_HAS_MEDICAL_ASPECTS] = true;
            }
        }

        if (!IsPostBack)
        {
            setImageForDeptAttribution();
            setDeptName();
            BindGridView();
            setUpdateButtons();
            btnAddMedicalAspects.Attributes.Add("onclick", "OpenPopup("+ (int)PopupType.MedicalAspects + "," + sessionParams.DeptCode + ", 'textControl'); return false;");
        }
    }

    private void setUpdateButtons()
    {
        if (currentUser != null)
        {
            if (m_isDeptPermittedForUser || currentUser.IsAdministrator)
            {
                divUpdateMedicalaspects.Style.Remove("display");
                divUpdateMedicalaspects.Style.Add("display", "inline");
            }
            else
            {
                divUpdateMedicalaspects.Style.Remove("display");
                divUpdateMedicalaspects.Style.Add("display", "none");
            }
        }
        else
        {
            divUpdateMedicalaspects.Style.Remove("display");
            divUpdateMedicalaspects.Style.Add("display", "none");
        }
    }

    private void setDeptName()
    {
        lblDeptName.Text = Request.QueryString["deptName"];
    }

    private void setImageForDeptAttribution()
    {
        bool isCommunity = bool.Parse(Request.QueryString["isCommunity"]);
        bool isMushlam = bool.Parse(Request.QueryString["isMushlam"]);
        bool isHospital = bool.Parse(Request.QueryString["isHospital"]);
        int subUnitTypeCode = int.Parse(Request.QueryString["subUnitTypeCode"]);
        UIHelper.SetImageForDeptAttribution(ref imgAttributed_4, isCommunity, isMushlam, isHospital, subUnitTypeCode);
    }

    protected void btnAddMedicalAspects_Click(object sender, EventArgs e)
    {
        ClientScript.RegisterStartupScript(typeof(string), "RefreshParent", "RefreshParent();", true);
    }

    protected void BindGridView()
    { 
        DataSet ds = Facade.getFacadeObject().GetClinicMedicalAspects(sessionParams.DeptCode);

        gvMedicalAspects.DataSource = ds.Tables[0];
        gvMedicalAspects.DataBind();
    }

    protected void btnDeleteMedicalAspect_Click(object sender, EventArgs e)
    {
        ImageButton btnDeleteMedicalAspect = sender as ImageButton;
        int deptCode = Convert.ToInt32(btnDeleteMedicalAspect.Attributes["DeptCode"]);
        int medicalAspectCode = Convert.ToInt32(btnDeleteMedicalAspect.Attributes["MedicalAspectCode"]);

        bool thereMedicalAspectsLeft = applicFacade.DeleteClinicMedicalAspect(deptCode, medicalAspectCode);
        if (thereMedicalAspectsLeft)
            Session[ConstsSession.CLINIC_HAS_MEDICAL_ASPECTS] = true;
        else
            Session[ConstsSession.CLINIC_HAS_MEDICAL_ASPECTS] = false;

        ClientScript.RegisterStartupScript(typeof(string), "RefreshParent", "RefreshParentAfterDelete();", true);
    }

    protected void gvMedicalAspects_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ImageButton btn = e.Row.FindControl("btnDeleteMedicalAspect") as ImageButton;
            if (currentUser != null)
                btn.Visible = true;
            else
                btn.Visible = false;
        }
    }
}