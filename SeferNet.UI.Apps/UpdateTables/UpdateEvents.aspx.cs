using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using System.Data;
using SeferNet.FacadeLayer;
using SeferNet.Globals;

public partial class UpdateTables_UpdateEvents : System.Web.UI.Page
{

    GeneralDictionariesBO bo = new GeneralDictionariesBO();

    public DataTable m_dtEvents
    {
        get
        {
            return (DataTable)ViewState["Events"];
        }
        set
        {
            ViewState["Events"] = value;
        }
    }

    public DataTable m_dtEventFiles
    {
        get
        {
            return (DataTable)ViewState["EventFiles"];
        }
        set
        {
            ViewState["EventFiles"] = value;
        }
    }   
    


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            GetNextEventNumber();
            BindEventsGrid();
        }

        if (ScriptManager.GetCurrent(this).IsInAsyncPostBack)
            ScriptManager.RegisterStartupScript(this, this.GetType(), "scroll", "SetScroll('" + scrollPosition.Value +"');", true);
    }

    private void GetNextEventNumber()
    {
        
        int eventCode = bo.GetNextEventCode();
        
        lblCodeNumber.Text = eventCode.ToString();
    }

    private void BindEventsGrid()
    {

        DataSet ds = bo.GetTreeViewEvents();
        
        m_dtEvents = ds.Tables[0];
        m_dtEventFiles = ds.Tables[1];

        gvEvents.DataSource = m_dtEvents;
        gvEvents.DataBind();        
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        string desc = txtAddDecription.Text;
        bool isActive = chkIsActive.Checked;
        int eventCode = Convert.ToInt32(lblCodeNumber.Text);

        UserInfo currentUser = new UserManager().GetUserInfoFromSession();

        if (currentUser == null)
        {
            Response.Redirect(PagesConsts.SEARCH_CLINICS_URL);
            Response.End();
        }

        bo.AddEvent(eventCode, desc, isActive, currentUser.UserNameWithPrefix);

        ResetPage();
    }


    private void ResetPage()
    {
        txtAddDecription.Text = string.Empty;
        chkIsActive.Checked = false;
        
        int eventCode = Convert.ToInt32(lblCodeNumber.Text);
        eventCode++;
        lblCodeNumber.Text = eventCode.ToString();
        
        BindEventsGrid();
    }


    protected void gvEvents_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            CheckBox chkIsActive = e.Row.FindControl("chkIsActive") as CheckBox;
            chkIsActive.Enabled = (e.Row.RowIndex == gvEvents.EditIndex);


            DataRowView row = e.Row.DataItem as DataRowView;
            DataView eventFiles = new DataView(m_dtEventFiles, "EventCode=" + row["EventCode"].ToString(), 
                                                    "fileDescription", DataViewRowState.OriginalRows);
            if (eventFiles.Count > 0)
            {
                GridView gvFiles = e.Row.FindControl("gvAttachedFiles") as GridView;
                if (gvFiles == null)
                {
                    gvFiles = e.Row.FindControl("gvEditAttachedFiles") as GridView;
                }

                gvFiles.DataSource = eventFiles;
                gvFiles.DataBind();
            }
        }
    }

    protected void gvEvents_RowEditing(object sender, GridViewEditEventArgs e)
    {
        gvEvents.EditIndex = e.NewEditIndex;
        gvEvents.DataSource = m_dtEvents;
        gvEvents.DataBind();
    }

    protected void gvEvents_cancelEdit(object sender, GridViewCancelEditEventArgs e)
    {
        gvEvents.EditIndex = -1;
        gvEvents.DataSource = m_dtEvents;
        gvEvents.DataBind();
    }

    protected void btnSaveRow_click(object sender, EventArgs e)
    {
        int rowIndex = gvEvents.EditIndex;

        Label lblCode = gvEvents.Rows[rowIndex].FindControl("lblEventCode") as Label;
        int eventCode = Convert.ToInt32(lblCode.Text);
        TextBox txtChosenFile = gvEvents.Rows[rowIndex].FindControl("txtChosenFile") as TextBox;
        string eventName = ((TextBox)gvEvents.Rows[rowIndex].FindControl("txtEventName")).Text;
        bool isActive = ((CheckBox)gvEvents.Rows[rowIndex].FindControl("chkIsActive")).Checked;

        Facade.getFacadeObject().UpdateEvent(eventCode, eventName, isActive, txtChosenFile.Text);
        

        gvEvents.EditIndex = -1;
        BindEventsGrid();
    }

    protected void btnDeleteFile_click(object sender, EventArgs e)
    {
        ImageButton btnDelete = sender as ImageButton;
        int eventFileID = Convert.ToInt32(btnDelete.CommandArgument);

        Facade.getFacadeObject().DeleteEventFile(eventFileID);

        BindEventsGrid();
    }

    protected void btnCancel_click(object sender, EventArgs e)
    {
        gvEvents.EditIndex = -1;
    }
}
