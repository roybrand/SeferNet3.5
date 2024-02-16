using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using System.Data;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.Globals;

public partial class Admin_UpdateAdminComments : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        this.checkPermissionToViewPage();

        if (!this.IsPostBack)
        {
            this.BindDefaultView();
            this.BindGrid();
        }

    }

    protected void btnAddAdminComment_Click(object sender, EventArgs e)
    {
        this.UpdateAdminComment();
    }

    private void checkPermissionToViewPage()
    {
        UserManager userManager = new UserManager();
        UserInfo currentUserInfo = userManager.GetUserInfoFromSession();

        if (currentUserInfo != null && this.User.Identity.IsAuthenticated)
        {
            if (!currentUserInfo.IsAdministrator && !currentUserInfo.CanManageTarifonViews )
            {
                this.Response.Redirect("../SearchClinics.aspx");
            }
        }
        else
        {
            this.Response.Redirect("../SearchClinics.aspx");
        }
    }

    private void BindDefaultView()
    {
        
    }

    protected void UpdateAdminComment()
    {
        int ID = 0;
        if (!string.IsNullOrEmpty(this.hfAdminComment_ID.Value))
            ID = int.Parse(this.hfAdminComment_ID.Value);

        string title = this.hfAdminComment_Title.Value;
        string comment = this.hfAdminComment_Comment.Value;

        DateTime? startDate = null;
        if (!string.IsNullOrEmpty(this.hfAdminComment_StartDate.Value))
            startDate = DateTime.Parse(this.hfAdminComment_StartDate.Value);

        DateTime? expiredDate = null;
        if (!string.IsNullOrEmpty(this.hfAdminComment_ExpiredDate.Value))
            expiredDate = DateTime.Parse(this.hfAdminComment_ExpiredDate.Value);

        byte active = 0;
        if (!string.IsNullOrEmpty(this.hfAdminComment_Active.Value))
        {
            bool _active = false;
            bool.TryParse(this.hfAdminComment_Active.Value, out _active);
            if (_active)
                active = 1;
        }

        UserManager userManager = new UserManager();
        UserInfo currentUserInfo = userManager.GetUserInfoFromSession();

        if (ID == 0)
            Facade.getFacadeObject().AddSalServicesAdminComment(title, comment, startDate, expiredDate, active, currentUserInfo.UserAD);
        else if (ID > 0)
            Facade.getFacadeObject().UpdateSalServicesAdminComment(ID, title, comment, startDate, expiredDate, active, currentUserInfo.UserAD);

        this.hfAdminComment_ID.Value = "";
        this.hfAdminComment_Title.Value = "";
        this.hfAdminComment_Comment.Value = "";
        this.hfAdminComment_StartDate.Value = "";
        this.hfAdminComment_ExpiredDate.Value = "";
        this.hfAdminComment_Active.Value = "";

        this.btnSearch_Click(null, null);
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        this.gvAdminCommentsResults.EditIndex = -1;
        this.GetDataFromDB();
        this.BindGrid();
    }

    private DataTable GetDataFromDB()
    {
        string title = null;
        if (!string.IsNullOrEmpty(this.tbSearchPanel_Title.Text))
            title = this.tbSearchPanel_Title.Text;

        string comment = null;
        if (!string.IsNullOrEmpty(this.tbSearchPanel_Comment.Text))
            comment = this.tbSearchPanel_Comment.Text;

        DateTime? startDate = new DateTime?();
        if (!string.IsNullOrEmpty(this.tbSearchPanel_StartDate.Text))
            startDate = DateTime.Parse(this.tbSearchPanel_StartDate.Text);

        DateTime? expiredDate = new DateTime?();
        if (!string.IsNullOrEmpty(this.tbSearchPanel_ExpiredDate.Text))
            expiredDate = DateTime.Parse(this.tbSearchPanel_ExpiredDate.Text);

        byte? active = new byte?();
        if (!string.IsNullOrEmpty(this.ddlSearchPanel_Active.SelectedValue))
            active = byte.Parse(this.ddlSearchPanel_Active.SelectedValue);

        DataSet ds = Facade.getFacadeObject().GetAdminCommentsForSalServices(title, comment, startDate, expiredDate, active);

        if (ds != null)
        {
            if (this.ViewState["AdminCommentsDT"] != null)
            {
                this.ViewState.Remove("AdminCommentsDT");
            }

            this.ViewState.Add("AdminCommentsDT", ds.Tables[0]);
            return ds.Tables[0];
        }

        return null;
    }

    private void BindGrid()
    {
        DataTable dt;
        if (this.ViewState["AdminCommentsDT"] != null)
        {
            dt = this.ViewState["AdminCommentsDT"] as DataTable;
        }
        else
        {
            dt = this.GetDataFromDB();
        }

        if (dt != null)
        {
            DataView dv = dt.DefaultView;
            if (this.ViewState["sortExpresion"] != null)
            {
                dv.Sort = this.ViewState["sortExpresion"].ToString();
            }

            this.gvAdminCommentsResults.DataSource = dv;
            this.gvAdminCommentsResults.DataBind();
            this.divResults.Visible = true;
        }
    }

    protected void gvAdminCommentsResults_OnRowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int adminCommentID = Convert.ToInt32(e.Values[0]);

        Facade.getFacadeObject().DeleteSalServiceAdminComment(adminCommentID);

        // rebind grid
        this.GetDataFromDB();
        this.BindGrid();
    }

    protected void gvAdminCommentsResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        GridViewRow row = e.Row;

        if (row.RowType == DataControlRowType.DataRow )
        {
            CheckBox cbActive = (CheckBox)row.FindControl("cbActive");

            if (((DataRowView)e.Row.DataItem)["active"] != null && ((DataRowView)e.Row.DataItem)["active"] != DBNull.Value)
            {
                cbActive.Checked = (((byte)((DataRowView)e.Row.DataItem)["active"]) == 1);
            }
        }

    }
}