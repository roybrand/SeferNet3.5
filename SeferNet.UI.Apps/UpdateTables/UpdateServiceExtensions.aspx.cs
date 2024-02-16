using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Clalit.SeferNet.GeneratedEnums;
using System.Data;
using SeferNet.FacadeLayer;

    public partial class UpdateServiceExtensions : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            //this.userManager = new UserManager();
            //this.applicFacade = Facade.getFacadeObject();


            if (!this.IsPostBack)
            {
                this.BindDdlServiceStatus();
                this.BindDdlExtensionExists();
                //this.CurrentRemarksSort = "remark";// default sort field
                //this.SetParametersFromSession();

                //this.BindGvRemarks();
                //this.SetGVRemarksParametersFromSession();

            }
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "SetDivScrollPosition", "SetDivScrollPosition();", true);
            }
        }


        private void BindDdlServiceStatus()
        {
            this.ddlServiceStatus.DataValueField = "status";
            this.ddlServiceStatus.DataTextField = "statusDescription";
            this.ddlServiceStatus.Items.Clear();

            UIHelper.BindDropDownToCachedTable(this.ddlServiceStatus, eCachedTables.View_ActivityStatus_Binary.ToString(), "statusDescription");

            //-- add default item
            ListItem defItem = new ListItem("הכל", "-1");
            this.ddlServiceStatus.Items.Insert(0, defItem);

            //-- select default item
            this.ddlServiceStatus.SelectedIndex = 0;
        }

        private void BindDdlExtensionExists()
        {
            //this.ddlServiceStatus.DataValueField = "status";
            //this.ddlServiceStatus.DataTextField = "statusDescription";
            this.ddlExtensionExists.Items.Clear();

            //UIHelper.BindDropDownToCachedTable(this.ddlServiceStatus, eCachedTables.View_ActivityStatus_Binary.ToString(), "statusDescription");

            //-- add items
            ListItem defItem = new ListItem("הכל", "-1");
            this.ddlExtensionExists.Items.Insert(0, defItem);
            ListItem notExistsItem = new ListItem("לא קיים", "0");
            this.ddlExtensionExists.Items.Insert(1, notExistsItem);
            ListItem existsItem = new ListItem("קיים", "1");
            this.ddlExtensionExists.Items.Insert(2, existsItem);

            //-- select default item
            this.ddlExtensionExists.SelectedValue = "1";
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            //ServiceCode.SetSortDirection(SortDirection.Ascending);
            DataTable dt = GetDataFromDB();

            //gvServiceResults.EditIndex = -1;
            BindGrid();
        }

        private void BindGrid()
        {
            DataTable dt;
            if (ViewState["serviceDT"] != null)
            {
                dt = ViewState["serviceDT"] as DataTable;
            }
            else
            {
                dt = GetDataFromDB();
            }

            if (dt != null)
            {
                DataView dv = dt.DefaultView;
                if (ViewState["sortExpresion"] != null)
                {
                    dv.Sort = ViewState["sortExpresion"].ToString();
                }

                gvServiceResults.DataSource = dv;
                gvServiceResults.DataBind();
                divResults.Visible = true;
            }
        }

        private DataTable GetDataFromDB()
        {
            int serviceCode = -1;

            if (!string.IsNullOrEmpty(txtServiceCode.Text))
            {
                serviceCode = Convert.ToInt32(txtServiceCode.Text);
            }

            string ServiceDescription = (txtServiceName.Text == string.Empty) ? null : txtServiceName.Text;
            int ServiceStatus = Convert.ToInt32(ddlServiceStatus.SelectedValue);
            int ExtensionExists = Convert.ToInt32(ddlExtensionExists.SelectedValue);

            DataSet ds = Facade.getFacadeObject().GetSalServicesForUpdate(serviceCode, ServiceDescription, ServiceStatus, ExtensionExists);

            if (ds != null)
            {
                if (ViewState["serviceDT"] != null)
                {
                    ViewState.Remove("serviceDT");
                }
                ViewState.Add("serviceDT", ds.Tables[0]);
                return ds.Tables[0];
            }

            return null;
        }

        protected void btnSort_Click(object sender, EventArgs e)
        {
            SortableColumnHeader columnToSortBy = sender as SortableColumnHeader;
            string CurrentSort = columnToSortBy.ColumnIdentifier.ToString();
            DataView dvCurrentResults = null;
            SortDirection newSortDirection = (SortDirection)columnToSortBy.CurrentSortDirection;
            string direction = "asc";


            if (newSortDirection.ToString() == "Descending")
            {
                direction = "desc";
            }

            string sort = String.Empty;
            sort = CurrentSort + " " + direction;
            foreach (Control ctrl in divHeaders.Controls)
            {
                if (ctrl is SortableColumnHeader && ctrl != columnToSortBy)
                {
                    ((SortableColumnHeader)ctrl).ResetSort();
                }
            }

            ViewState["sortExpresion"] = sort;
            dvCurrentResults = ((DataTable)ViewState["serviceDT"]).DefaultView;
            dvCurrentResults.Sort = sort;

            gvServiceResults.DataSource = dvCurrentResults;
            gvServiceResults.DataBind();

            gvServiceResults.EditIndex = -1;
        }

        protected void imgCancel_Click(object sender, ImageClickEventArgs e)
        {
            gvServiceResults.EditIndex = -1;
            BindGrid();
        }
        protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
        {
            GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
            if (row != null)
            {
                gvServiceResults.EditIndex = row.RowIndex;
                BindGrid();

            }
        }
        protected void gvServiceResults_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {

            int rowInd = e.RowIndex;
            int serviceCode = Convert.ToInt32(e.NewValues[0].ToString());

            CheckBox cb = gvServiceResults.Rows[rowInd].FindControl("cbServiceReturnExist") as CheckBox;
            int isChecked;
            if (cb.Checked)
                isChecked = 1;
            else
                isChecked = 0;

            Facade.getFacadeObject().UpdateServiceReturnExist(serviceCode, isChecked);
            gvServiceResults.EditIndex = -1;
            GetDataFromDB();
            BindGrid();
        }
    }
