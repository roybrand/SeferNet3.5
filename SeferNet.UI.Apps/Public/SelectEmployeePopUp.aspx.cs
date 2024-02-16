using SeferNet.FacadeLayer;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SeferNet.UI.Apps.Public
{
    public partial class SelectEmployeePopUp : System.Web.UI.Page
    {
        Facade applicFacade;
        int employeeID;
        int licenseNumber;
        string firstName;
        string lastName;
        DataSet m_dsEmployeeList;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (txtSelectedEmployeeID.Text != string.Empty)
            {
                applicFacade = Facade.getFacadeObject();
                m_dsEmployeeList = applicFacade.GetEmployeeList(string.Empty, string.Empty, -1, Convert.ToInt64(txtSelectedEmployeeID.Text));

                txtSelectedEmployeeName.Text = m_dsEmployeeList.Tables[0].Rows[0]["firstName"].ToString() + ' ' + m_dsEmployeeList.Tables[0].Rows[0]["lastName"].ToString();

                ClientScript.RegisterStartupScript(typeof(string), "SelectEmployee", "SelectEmployee();", true);            
            }

        }
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (gvEmployeeList.Rows.Count > 1)
                lblSelectIfMoreThenOne.Style.Add("display", "inline");
            else
                lblSelectIfMoreThenOne.Style.Add("display", "none");

            InitializeAutoCompleteControls();
        }

        private void InitializeAutoCompleteControls()
        {
            this.txtLastName.Attributes.Add("onFocus",
                "UpdateAutoCompleteName('" + txtFirstName.ClientID + "','"
                + AutoCompleteLastName.BehaviorID + "');");

            this.txtFirstName.Attributes.Add("onFocus",
                "UpdateAutoCompleteName('" + txtLastName.ClientID + "','"
                + AutoCompleteFirstName.BehaviorID + "');");
        }

        protected void btnSelect_Click(object sender, EventArgs e)
        {
            applicFacade = Facade.getFacadeObject();

            if (txtEmployeeID.Text != string.Empty)
                employeeID = Convert.ToInt32(txtEmployeeID.Text);
            else
                employeeID = -1;

            if (txtLicenseNumber.Text != string.Empty)
                licenseNumber = Convert.ToInt32(txtLicenseNumber.Text);
            else
                licenseNumber = -1;

            if (txtFirstName.Text != string.Empty)
                firstName = txtFirstName.Text.Trim();
            else
                firstName = string.Empty;

            if (txtLastName.Text != string.Empty)
                lastName = txtLastName.Text.Trim();
            else
                lastName = string.Empty;

            m_dsEmployeeList = applicFacade.GetEmployeeList(firstName, lastName, licenseNumber, employeeID);

            gvEmployeeList.DataSource = m_dsEmployeeList.Tables[0];
            gvEmployeeList.DataBind();
            gvEmployeeList.Style.Add("display", "inline");
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtEmployeeID.Text = string.Empty;
            txtFirstName.Text = string.Empty;
            txtLastName.Text = string.Empty;
            txtLicenseNumber.Text = string.Empty;

            gvEmployeeList.DataSource = null;
            gvEmployeeList.DataBind();
            gvEmployeeList.Style.Add("display", "none");
        }

    }
}