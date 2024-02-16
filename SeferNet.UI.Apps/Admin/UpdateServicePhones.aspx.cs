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
using SeferNet.BusinessLayer.ObjectDataSource;

public partial class UpdateServicePhones : AdminPopupBasePage
{
    Facade applicFacade = Facade.getFacadeObject();
    DataSet m_dsDeptEmployeeServisePhones;
    DataTable m_dtDeptEmployeeServisePhones;
    DataTable phoneDt;
    string dsDeptEmployeeServisePhones_session = "dsDeptEmployeeServisePhones_session";
    int x_Dept_Employee_ServiceID;

    public int X_Dept_Employee_ServiceID
    {
        get
        {
            return x_Dept_Employee_ServiceID;
        }
        set
        {
            x_Dept_Employee_ServiceID = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        x_Dept_Employee_ServiceID = Convert.ToInt32(Request.QueryString["x_Dept_Employee_ServiceID"]);

        if (!IsPostBack)
        {
            m_dsDeptEmployeeServisePhones = applicFacade.GetEmployeeServicePhones(x_Dept_Employee_ServiceID, null, null);
            m_dtDeptEmployeeServisePhones = m_dsDeptEmployeeServisePhones.Tables[0];
            Session[dsDeptEmployeeServisePhones_session] = m_dsDeptEmployeeServisePhones;

            SetPhoneControlsData();

            bool cascadeUpdateEmployeeServicePhones = Convert.ToBoolean(m_dsDeptEmployeeServisePhones.Tables[1].Rows[0]["CascadeUpdateEmployeeServicePhones"]);
            chkShowPhonesFromDept.Checked = cascadeUpdateEmployeeServicePhones;
            pnlPhones.Enabled = !chkShowPhonesFromDept.Checked;

            SetQueueOrderDetails();
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        //if (m_dtDeptEmployeeServisePhones.Columns.Contains("GetCascade") && m_dtDeptEmployeeServisePhones.Rows.Count > 0)
        //{
        //    chkShowPhonesFromDept.Checked = Convert.ToBoolean(m_dtDeptEmployeeServisePhones.Rows[0]["GetCascade"]);
        //}

        //pnlPhones.Enabled = !chkShowPhonesFromDept.Checked;
    }

    protected void TogglePhonesPanel(object sender, EventArgs e)
    {
        bool cascadeUpdate = chkShowPhonesFromDept.Checked;
        phoneDt = ServicePhonesUC.ReturnData();
        UserInfo currentUser = new UserManager().GetUserInfoFromSession();

        //applicFacade.UpdateEmployeeServicePhones(x_Dept_Employee_ServiceID, phoneDt, cascadeUpdate, currentUser.UserNameWithPrefix);

        if (cascadeUpdate)
        {
            m_dsDeptEmployeeServisePhones = applicFacade.GetEmployeeServicePhones(x_Dept_Employee_ServiceID, null, cascadeUpdate);
            m_dtDeptEmployeeServisePhones = m_dsDeptEmployeeServisePhones.Tables[0];

            SetPhoneControlsData();
            bool cascadeUpdateEmployeeServicePhones = Convert.ToBoolean(m_dsDeptEmployeeServisePhones.Tables[1].Rows[0]["CascadeUpdateEmployeeServicePhones"]);
            chkShowPhonesFromDept.Checked = cascadeUpdateEmployeeServicePhones;
        }
        pnlPhones.Enabled = !chkShowPhonesFromDept.Checked;
    }

    protected void chkQueueOrderFromDept_checked(object sender, EventArgs e)
    {
        string s;
    }

    private void SetQueueOrderDetails()
    {
        QueueOrderMethodBO queueBo = new QueueOrderMethodBO();

        lblQueuePhones.Text = string.Empty;

        // get queue order details
        DataSet ds = queueBo.GetEmployeeServiceQueueOrderDescription(x_Dept_Employee_ServiceID);

        if (ds != null)
        {
            DataTable dt = ds.Tables[0];
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                lblQueuePhones.Text += dt.Rows[i]["QueueOrderDescription"].ToString() + " , ";
            }
            if (lblQueuePhones.Text.Length > 1)
            {
                lblQueuePhones.Text = lblQueuePhones.Text.Substring(0, lblQueuePhones.Text.Length - 2);
            }
        }

        if (lblQueuePhones.Text == String.Empty)
        {
            chkQueueOrderFromDept.Enabled = false;
        }
        else
        {
            chkQueueOrderFromDept.Enabled = true;
        }
    }

    private void SetPhoneControlsData()
    {
        DataTable dtPh = new DataTable();

        Phone.CreateTableStructure(ref dtPh);

        for (int i = 0; i < m_dtDeptEmployeeServisePhones.Rows.Count; i++)
        {
            DataRow dr = dtPh.NewRow();
            dr["prePrefix"] = m_dtDeptEmployeeServisePhones.Rows[i]["prePrefix"];//"1";
            dr["prefixCode"] = m_dtDeptEmployeeServisePhones.Rows[i]["prefixCode"];
            dr["prefixText"] = m_dtDeptEmployeeServisePhones.Rows[i]["prefixText"];
            dr["phone"] = m_dtDeptEmployeeServisePhones.Rows[i]["phone"];
            dr["phoneID"] = DBNull.Value;
            dr["phoneOrder"] = m_dtDeptEmployeeServisePhones.Rows[i]["phoneOrder"];
            dr["extension"] = m_dtDeptEmployeeServisePhones.Rows[i]["extension"];

            dtPh.Rows.Add(dr);
        }

        if (dtPh.Rows.Count == 0)
        { 
            DataRow dr = dtPh.NewRow();
            dtPh.Rows.Add(dr);
        }

        ServicePhonesUC.LabelTitle.Text = ":טלפונים";
        ServicePhonesUC.SourcePhones = dtPh;
        ServicePhonesUC.EnableBlankData = true;
        ServicePhonesUC.DataBind();
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if(txtQueueOrderHasChanged.Text != string.Empty)
            CloseWindow(true);
        else
            CloseWindow(false);
    }

    private void CloseWindow(bool saveHasBeenMade)
    {
        string str = "";
        if (saveHasBeenMade)
        { 
            str += "parent.RebindPhones();";        
        }

        str += "SelectJQueryClose();";

        ClientScript.RegisterStartupScript(this.GetType(), "close", str, true);
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        UserInfo currentUser = new UserManager().GetUserInfoFromSession();

        bool cascadeUpdate = chkShowPhonesFromDept.Checked;
        phoneDt = ServicePhonesUC.ReturnData();

        for (int i = 0; i < phoneDt.Rows.Count; i++)
        {
            phoneDt.Rows[i]["PhoneType"] = "1";
        }

        if (chkQueueOrderFromDept.Checked)
            applicFacade.CascadeEmployeeServiceQueueOrderFromDept(x_Dept_Employee_ServiceID);


        if(applicFacade.UpdateEmployeeServicePhones(x_Dept_Employee_ServiceID, phoneDt, cascadeUpdate, currentUser.UserNameWithPrefix))
            CloseWindow(true);
        else
            CloseWindow(false);

    }


}