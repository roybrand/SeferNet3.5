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
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;

public partial class DeptEventPopUp : System.Web.UI.Page
{
    DataSet m_dsEvent;
    Facade applicFacade;

    protected void Page_Load(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();
        int deptEventID = Convert.ToInt32(Request.QueryString["EventCode"]);
        m_dsEvent = applicFacade.GetDeptEventForPopUp(deptEventID);

        m_dsEvent.Tables[0].TableName = "deptEvent";
        m_dsEvent.Tables[1].TableName = "deptEventMeetings";
        m_dsEvent.Tables[2].TableName = "deptEventPhones";
        m_dsEvent.Tables[3].TableName = "deptPhones";
        m_dsEvent.Tables[4].TableName = "DeptEventHandicappedFacilities";
        m_dsEvent.Tables[5].TableName = "DeptEventFiles";

        SetEventDetails();
        SetEventParticulars();
        SetEventFiles();

        btnClose.Attributes.Add("OnClientClick", "return false;");
    }

    private void SetEventFiles()
    {
        if (m_dsEvent.Tables["DeptEventFiles"].Rows.Count > 0)
        {
            gvAttachedFiles.DataSource = m_dsEvent.Tables["DeptEventFiles"];
            gvAttachedFiles.DataBind();
        }
        else
        {
            lblEventFiles.Visible = false;
        }       
    }

    public bool SetEventDetails()
    {
        if (m_dsEvent.Tables["deptEvent"] == null || m_dsEvent.Tables["deptEvent"].Rows.Count < 1)
            return false;

        DataRow dr = m_dsEvent.Tables["deptEvent"].Rows[0];

        lblDeptName_EventDetails.Text = dr["deptName"].ToString();
        lblDeptAddress_EventDetails.Text = dr["address"].ToString();

        string deptPhones = string.Empty, eventPhones = string.Empty;

        if (m_dsEvent.Tables["deptPhones"] != null && m_dsEvent.Tables["deptPhones"].Rows.Count > 0)
        {
            for (int i = 0; i < m_dsEvent.Tables["deptPhones"].Rows.Count; i++)
            {
                if (deptPhones != string.Empty)
                    deptPhones += " | ";
                deptPhones += m_dsEvent.Tables["deptPhones"].Rows[i]["phone"].ToString();
            }
        }

        lblDeptPhones_EventDetails.Text = deptPhones;



        if (dr["ShowPhonesFromDept"] != DBNull.Value && Convert.ToBoolean(dr["ShowPhonesFromDept"]))
        {
            lblEventPhones_EventDetails.Text = deptPhones;
        }
        else
        {
            if (m_dsEvent.Tables["deptEventPhones"] != null && m_dsEvent.Tables["deptEventPhones"].Rows.Count > 0)
            {
                for (int i = 0; i < m_dsEvent.Tables["deptEventPhones"].Rows.Count; i++)
                {
                    if (eventPhones != string.Empty)
                        eventPhones += " | ";
                    eventPhones += m_dsEvent.Tables["deptEventPhones"].Rows[i]["phone"].ToString();
                }
            }
            lblEventPhones_EventDetails.Text = eventPhones;
        }

        lblEventName_EventDetails.Text = dr["EventName"].ToString();
        lblEventDescription_EventDetails.Text = dr["EventDescription"].ToString();
        lblRegistrationStatus_EventDetails.Text = dr["RegistrationStatus"].ToString();
        lblPayOrderDescription_EventDetails.Text = dr["PayOrderDescription"].ToString();

        if (string.IsNullOrEmpty(dr["MemberPrice"].ToString()))
        {
            pnlMemberPrice.Visible = false;
        }
        else
        {
            lblMemberPrice_EventDetails.Text = dr["MemberPrice"].ToString();
        }

        if (string.IsNullOrEmpty(dr["FullMemberPrice"].ToString()))
        {
            pnlFullMember.Visible = false;
        }
        else
        {
            lblFullMemberPrice_EventDetails.Text = dr["FullMemberPrice"].ToString();
        }

        if (string.IsNullOrEmpty(dr["CommonPrice"].ToString()))
        {
            pnlCommonMember.Visible = false;
        }
        else
        {
            lblCommonPrice_EventDetails.Text = dr["CommonPrice"].ToString();
        }

        if (dr["TargetPopulation"].ToString() != string.Empty)
            lblTargetPopulation_EventDetails.Text = dr["TargetPopulation"].ToString();
        else
            lblTargetPopulation_EventDetails.Text = "לא מוגדר";


        lblEventRemark_EventDetails.Text = dr["Remark"].ToString();


        return true;
    }

    public bool SetEventParticulars()
    {
        if (m_dsEvent.Tables["deptEventMeetings"] == null || m_dsEvent.Tables["deptEventMeetings"].Rows.Count < 1)
            return false;

        gvEventParticulars.DataSource = m_dsEvent.Tables["deptEventMeetings"];
        gvEventParticulars.DataBind();

        return true;
    }

    protected void gvAttachedFiles_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView row = e.Row.DataItem as DataRowView;
            string fileDescription = row["FileDescription"].ToString();
            string fileName = row["FileName"].ToString();

            fileDescription = fileDescription.Substring(0, fileDescription.LastIndexOf('.'));

            string fileSelf = ConfigHelper.GetEventFilesStoragePath() + fileName;
            
            HyperLink hlOpenFile = e.Row.FindControl("hlOpenFile") as HyperLink;
            hlOpenFile.Text = fileDescription;

            string Url = "";

             Url = @"file:" + fileSelf;
            hlOpenFile.NavigateUrl = Url;

        }
    }

    protected void lnkToFile_click(object sender, EventArgs e)
    {
        LinkButton lnk = sender as LinkButton;        

        string fileName = ConfigHelper.GetEventFilesStoragePath() + lnk.CommandArgument;

        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition", "inline;filename=" + lnk.CommandArgument);
        Response.ContentType = "application/ms-word";
        Response.WriteFile(fileName);
        Response.End();

     }
}
