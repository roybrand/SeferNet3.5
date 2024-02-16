using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.ObjectDataSource;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SeferNet.UI.Apps.Admin
{
    public partial class UpdateEmployeeExpertProfession : System.Web.UI.Page
    {
        private DataTable dtGrViewSource = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["EmployeeID_ToUpdateExpertProfessions"] != null && Session["EmployeExperteProfessions_SelectedValuesToUpdate"] != null)
                {
                    FirstBindGridView();
                }

                btnCancel.Attributes.Add("onclick", "SelectJQueryClose();");	// using Jquery dialog

            }
        }

        private void BindGridView()
        {
            dtGrViewSource = (DataTable)ViewState["SelectedExpertprofessions"];

            gvEmployeeProfessionExpert.DataSource = dtGrViewSource;
            gvEmployeeProfessionExpert.DataBind();
        }

        private void FirstBindGridView()
        {
            EmployeeProfessionBO professionsBo = new EmployeeProfessionBO();
            DataSet dsSelectedExpertprofessions = professionsBo.GetEmployeeExpertiseToUpdate(Convert.ToInt64(Session["EmployeeID_ToUpdateExpertProfessions"]),
                                                        Session["EmployeExperteProfessions_SelectedValuesToUpdate"].ToString());

            dtGrViewSource = dsSelectedExpertprofessions.Tables[0];
            ViewState["SelectedExpertprofessions"] = dtGrViewSource;

            gvEmployeeProfessionExpert.DataSource = dtGrViewSource;
            gvEmployeeProfessionExpert.DataBind();
        }

        protected void imgCancel_Click(object sender, ImageClickEventArgs e)
        {
            try
            {
                CancelEditedRow();
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }
        private void CancelEditedRow()
        {
            gvEmployeeProfessionExpert.EditIndex = -1;
      
            BindGridView();
        }

        protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
        {
            try
            {
                GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
                if (row != null)
                    UpdateRow(row);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        private void UpdateRow(GridViewRow row)
        {
            gvEmployeeProfessionExpert.EditIndex = row.RowIndex;
            BindGridView();
        }

        protected void imgSave_Click(object sender, ImageClickEventArgs e)
        {
            try
            {
                GridViewRow gvRow = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;

                TextBox txtExpertDiplomaNumber = gvRow.FindControl("txtExpertDiplomaNumber") as TextBox;

                dtGrViewSource = (DataTable)ViewState["SelectedExpertprofessions"];

                if (int.TryParse(txtExpertDiplomaNumber.Text, out int value))
                { 
                    dtGrViewSource.Rows[gvRow.RowIndex]["expertDiplomaNumber"] = txtExpertDiplomaNumber.Text;                
                }

                dtGrViewSource.AcceptChanges();

                gvEmployeeProfessionExpert.EditIndex = -1;

                gvEmployeeProfessionExpert.DataSource = dtGrViewSource;
                gvEmployeeProfessionExpert.DataBind();

                ViewState["SelectedExpertprofessions"] = dtGrViewSource;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        protected void btnSave_click(object sender, EventArgs e)
        {
            EmployeeProfessionBO professionsBo = new EmployeeProfessionBO();
            UserInfo user = HttpContext.Current.Session["currentUser"] as UserInfo;
            string userName = user.UserNameWithPrefix;
            string professionCodes = "";
            string expertDiplomaNumbers = "";
            Int64 employeeID = Convert.ToInt64(Session["EmployeeID_ToUpdateExpertProfessions"]);

            foreach (GridViewRow row in gvEmployeeProfessionExpert.Rows)
            {
                Label lblEmployeeID = (Label)row.FindControl("lblEmployeeID");
                Label lblserviceCode = (Label)row.FindControl("lblserviceCode");
                TextBox txtExpertDiplomaNumber = (TextBox)row.FindControl("txtExpertDiplomaNumber");

                professionCodes += lblserviceCode.Text + ',';
                expertDiplomaNumbers += txtExpertDiplomaNumber.Text + ',';
            }

            professionsBo.UpdateEmployeeExpertise(employeeID, professionCodes, expertDiplomaNumbers, userName);

            //string str = "self.close();";
            //ClientScript.RegisterStartupScript(this.GetType(), "close", str, true);
            
            //Page.ClientScript.RegisterStartupScript(this.GetType(), "close", "Close();", true);
            Page.ClientScript.RegisterStartupScript(this.GetType(), "close", "SelectJQueryClose();", true);
        }

        protected void btnCancel_click(object sender, EventArgs e)
        {
            CloseWindow(false);
        }
        private void CloseWindow(bool saveHasBeenMade)
        {
            string str = "self.close();";

            ClientScript.RegisterStartupScript(this.GetType(), "close", str, true);
        }
    }
}