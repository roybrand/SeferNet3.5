using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Data;
using System.Collections.Specialized;

public partial class UserControls_PhonesGridUC : System.Web.UI.UserControl
{
    private DataTable _dtData = null;  
    private int _phoneOrder = 1;
    protected bool _enableAdding = true;
    protected bool _enableDeleting = true;
    private int _indxAddedRow = -1;
    private bool _enableBlankData;
    private bool _useRemarks;

    
    #region Properties

    
    public bool EnableBlankData
    {
        get
        {
            if (ViewState[this.ClientID + "EnableBlankData"] != null)
            {
                return (bool)ViewState[this.ClientID + "EnableBlankData"];
            }
            return false;
        }
        set
        {
            ViewState[this.ClientID + "EnableBlankData"] = value;
            //if(value) 
              //  DisableValidatorsIfNeeded();
        }
    }

    public Label LabelTitle
    {
        get
        {
            return this.lblTitle;
        }
        set
        {

            this.lblTitle = value;
        }
    }

    public bool LabelTitleVisibility
    {
        //get
        //{
        //    return this.lblTitle;
        //}
        set
        {
            this.lblTitle.Visible = value;
        }
    }


    public bool UseRemarks
    {
        get 
        {
            return this._useRemarks;
        }
        set 
        {
            this._useRemarks = value;        
        }
    }

    public int IndxAddedRow
    {
        get
        {
            return this._indxAddedRow;
        }
        set
        {
            this._indxAddedRow = value;
        }
    }
    
    public bool EnableDeleting
    {
        get
        {
            object obj = ViewState[this.ClientID + "EnableDeleting"];

            if (obj != null)
            {
                return (bool)obj;
            }
            else
            {
                return true;
            }
        }
        set
        {
            ViewState[this.ClientID +"EnableDeleting"] =  value;
            this._enableDeleting = value;
        }
    }

    public bool EnableAdding
    {
        get
        {
            object obj = ViewState[this.ClientID + "EnableAdding"];

            if (obj != null)
            {
                return (bool)obj;
            } 
            else
            {
                return true;
            }
        }
        set
        {
            ViewState[this.ClientID + "EnableAdding"] =  value;
            this._enableAdding = value;
        }
    }   

    public DataTable SourcePhones
    {
        get
        {
            object dtPhonesData = (DataTable)ViewState[this.ClientID + "PhonesData"];

            if (dtPhonesData == null)
                return null;
            else
            {
                _dtData = (DataTable)dtPhonesData;
                RemoveEmptyRows(ref _dtData);
                return _dtData;
            }
        }
        set
        {
            _dtData = value;           
            ViewState[this.ClientID + "PhonesData"] =  _dtData;
        }
    }

    
    #endregion

     
    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager sm = ScriptManager.GetCurrent(Page);
        bool asyncPostBack = sm.IsInAsyncPostBack;

        if (!Page.IsPostBack && !asyncPostBack)
        {
            BindGrid();
            btnAdd.Visible = EnableAdding;
        }
        else
        {
            bool deliting = this.EnableDeleting;
            LinkButton lnkDelete = null;

            for (int i = 0; i < gvPhones.Rows.Count; i++)
            {
                lnkDelete = gvPhones.Rows[i].FindControl("lnkDelete") as LinkButton;

                if (lnkDelete != null)
                {
                    lnkDelete.Visible = deliting;
                }
            }
        }
    }


    private void GetVals(Control ctl)
    {

        if (ctl.Controls.Count == 0)
        {
            if (ctl is IValidator)
            {
                ((BaseValidator)ctl).Enabled = false;
            }
        }
        else
        {
            foreach (Control vtl1 in ctl.Controls)
            {
                GetVals(vtl1);
            }
        }
    }

    
    #region Bind

    public void DataBind()
    {
        BindGrid();
    }

    private void BuildGridRow(GridViewRow row)
    {
        DropDownList ddlPrePrefixPhone = null;
        DropDownList ddlPrefixPhone = null;
        LinkButton lnkDelete = null;
        RegularExpressionValidator REV1 = null;
        int prePrefix = -1;
        int prefixCode = -1;

        try
        {                       
            int rowIndex = row.RowIndex + 2;

            string prePrefixValue = ((System.Data.DataRowView)(row.DataItem)).Row["prePrefix"].ToString();
            if (prePrefixValue != String.Empty)
                prePrefix = Convert.ToInt32(prePrefixValue);

            string prefix = ((System.Data.DataRowView)(row.DataItem)).Row["prefixCode"].ToString();
            if (prefix != String.Empty)
                prefixCode= Convert.ToInt32(prefix);

            ddlPrePrefixPhone = row.FindControl("ddlPrePrefixPhone") as DropDownList;
            if (ddlPrePrefixPhone != null)
            {
                LoadPrePrefixes(ddlPrePrefixPhone, prePrefix);
            }

            ddlPrefixPhone = row.FindControl("ddlPrefixPhone") as DropDownList;
            REV1 = row.FindControl("REV1") as RegularExpressionValidator;
            if (ddlPrefixPhone != null)
            {
                LoadPrefixes(ddlPrefixPhone, prefixCode);

                if (REV1 != null)
                    EnableDisablePrefixPhone(ddlPrePrefixPhone, ddlPrefixPhone, REV1);
            }

            bool deliting = this.EnableDeleting;
            lnkDelete = row.FindControl("lnkDelete") as LinkButton;
            if (lnkDelete != null)
            {
                lnkDelete.Visible = deliting;
            }

            TextBox  txtExtension  = row.FindControl("txtExtension") as TextBox;
            if (txtExtension != null && this.IndxAddedRow == row.RowIndex)
            {
                txtExtension.Focus();
            }

            bool useRemarks = this.UseRemarks;
            TextBox txtRemark = row.FindControl("txtRemark") as TextBox;
            Label lblRemark = row.FindControl("lblRemark") as Label;
            txtRemark.Visible = useRemarks;
            lblRemark.Visible = useRemarks;

            if(txtRemark.Visible)
            {
                txtRemark.Text = ((System.Data.DataRowView)(row.DataItem)).Row["remark"].ToString();
            }

        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private void BindGrid()
    {
        DataTable dtData = (DataTable)ViewState[this.ClientID +"PhonesData"];
        if (dtData != null)
            BindData(dtData);
    }

    private void BindData(DataTable dtData)
    {
        gvPhones.DataSource = dtData;
        gvPhones.DataBind();
    }

    private void LoadPrefixes(DropDownList ddlPrefixPhone, int prePrefix)
    {
        ListItem item = null;
        
        if (ddlPrefixPhone != null)
        {
            ddlPrefixPhone.Items.Clear();
            UIHelper.BindDropDownToCachedTable(ddlPrefixPhone, "DIC_PhonePrefix", "prefixValue");

            item = new ListItem("", "-1");
            ddlPrefixPhone.Items.Insert( 0,item);

            ddlPrefixPhone.SelectedValue = prePrefix.ToString();
        }
    }

    private void LoadPrePrefixes(DropDownList ddlPrePrefixPhone, int prePrefix)
    {
        ListItem item = null;
       
        if (ddlPrePrefixPhone != null)
        {
            ddlPrePrefixPhone.Items.Clear();

            item = new ListItem(" ", "-1");
            ddlPrePrefixPhone.Items.Add(item);

            item = new ListItem("1", "1");
            ddlPrePrefixPhone.Items.Add(item);

            item = new ListItem("*", "2");
            ddlPrePrefixPhone.Items.Add(item);

            ddlPrePrefixPhone.SelectedValue = prePrefix.ToString();            
        }
    }


    #endregion

    public DataTable ReturnData()
    {
        int order = _phoneOrder;

        TextBox txtExtension, txtPhone, txtRemark;
        int prePrefix, prefixCode, phone, extension;
        string prefixText, remark;

        DataTable dt = (DataTable)ViewState[this.ClientID + "PhonesData"];

        if (dt == null) return null;

        DataTable returnDt = dt.Clone();
        DataRow dr;

        for (int i = 0; i < gvPhones.Rows.Count; i++)
        {
            extension = -1;
            phone = -1;

            txtPhone = gvPhones.Rows[i].FindControl("txtPhone") as TextBox;
            if (!string.IsNullOrEmpty(txtPhone.Text))
            {
                phone = Convert.ToInt32(txtPhone.Text);
            }

            if (phone != -1)
            {
                prePrefix = Convert.ToInt32(((DropDownList)gvPhones.Rows[i].FindControl("ddlPrePrefixPhone")).SelectedValue);
                prefixCode = Convert.ToInt32(((DropDownList)gvPhones.Rows[i].FindControl("ddlPrefixPhone")).SelectedValue);
                prefixText = ((DropDownList)gvPhones.Rows[i].FindControl("ddlPrefixPhone")).SelectedItem.Text;

                txtExtension = gvPhones.Rows[i].FindControl("txtExtension") as TextBox;
                if (!string.IsNullOrEmpty(txtExtension.Text))
                {
                    extension = Convert.ToInt32(txtExtension.Text);
                }

                dr = returnDt.NewRow();

                dr["phoneOrder"] = i + 1;
                dr["prePrefix"] = (prePrefix != -1) ? prePrefix : dr["prePrefix"];
                dr["prefixCode"] = (prefixCode != -1) ? prefixCode : dr["prefixCode"];
                dr["prefixText"] = prefixText;
                dr["phone"] = phone;
                dr["extension"] = (extension != -1) ? extension : dr["extension"];

                if (_useRemarks)
                {
                    txtRemark = gvPhones.Rows[i].FindControl("txtRemark") as TextBox;
                    dr["remark"] = txtRemark.Text;
                }

                returnDt.Rows.Add(dr);
            }
        }

        return returnDt;

        //dtChangedData = (DataTable)ViewState[this.ClientID + "PhonesData"];

        //if (dtChangedData != null && dtChangedData.Rows.Count > 0)
        //{
        //    RemoveEmptyRows(ref dtChangedData);
        //    foreach (DataRow row in dtChangedData.Rows)
        //    {
        //        if (row["phoneOrder"] != null)
        //        {
        //            row["phoneOrder"] = _phoneOrder;
        //            _phoneOrder++;
        //        }
        //    }
        //}

        //return dtChangedData;
    }

    protected void gvPhones_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            BuildGridRow(e.Row);
        }
    }

    private void EnableDisablePrefixPhone(DropDownList ddlPrePrefixPhone, DropDownList ddlPrefixPhone, RegularExpressionValidator REV1)
    {
        if (ddlPrePrefixPhone.SelectedValue == "2")
        {
            ddlPrefixPhone.SelectedIndex = -1;
            ddlPrefixPhone.Enabled = false;
            REV1.ValidationExpression = @"^\d{4}$|^\d{6}$";
            REV1.Validate();
        }
        else
        {
            ddlPrefixPhone.Enabled = true;
            REV1.ValidationExpression = @"\d{6,7}";
            REV1.Validate();
        }
    }

    #region Buttons_click

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        DataTable dtData = ReturnData();
       // DataTable dtData = (DataTable)ViewState[this.ClientID + "PhonesData"];
        if (dtData != null)
        {
            DataRow newRow = dtData.NewRow();
            dtData.Rows.InsertAt(newRow, dtData.Rows.Count);
            this.IndxAddedRow = dtData.Rows.Count - 1;
            ViewState[this.ClientID + "PhonesData"] = dtData;
            gvPhones.DataSource = null;
            BindGrid();
        }
    }


    protected void btnDelete_Click(object sender, ImageClickEventArgs e)
    {
        ImageButton btnDelete = sender as ImageButton;
        if (btnDelete != null)
        {
            GridViewRow row = btnDelete.Parent.Parent as GridViewRow;
            if (row != null)
            {
                DeleteRow(row);
            }
        }
    }

    protected void lnkDelete_Click(object sender, EventArgs e)
    {
        LinkButton btnDelete = sender as LinkButton;
        if (btnDelete != null)
        {
            GridViewRow row = btnDelete.Parent.Parent as GridViewRow;
            if (row != null)
            {
                DeleteRow(row);
            }
        }
    }

    private void DeleteRow(GridViewRow row)
    {
        int indx = row.RowIndex;
        DataTable dtData = (DataTable)ViewState[this.ClientID + "PhonesData"];
        if (dtData != null)
        {
            dtData.Rows.RemoveAt(indx);
            if (dtData.Rows.Count == 0)
            {
                DataRow newRow = dtData.NewRow();
                dtData.Rows.Add(newRow);
            }
            dtData.AcceptChanges();

            ViewState[this.ClientID + "PhonesData"] = dtData;
            gvPhones.DataSource = null;
            BindGrid();
        }
    }


    #endregion

    public void ddlPrePrefixPhone_SelectedIndexChanged(object sender, EventArgs e)
    {
        ddl_SelectedIndexChanged(sender);
    }

    private void ddl_SelectedIndexChanged(object sender)
    {
        GridViewRow row = null;

        DropDownList ddl = sender as DropDownList;
        if (ddl != null)
        {
            TableCell cell = ddl.Parent as TableCell;
            if (cell != null)
            {
                row = cell.Parent as GridViewRow;
            }
            else
            {
                row = ddl.Parent.NamingContainer as GridViewRow;
            }
            if (row != null)
            {
                UpdateData(row);
            }
        }
    }

    private void UpdateData(GridViewRow row)
    {
        DropDownList ddlPrefixPhone = row.FindControl("ddlPrefixPhone") as DropDownList;
        DropDownList ddlPrePrefixPhone = row.FindControl("ddlPrePrefixPhone") as DropDownList;

        RegularExpressionValidator REV1 = row.FindControl("REV1") as RegularExpressionValidator;
        if (REV1 != null)
            EnableDisablePrefixPhone(ddlPrePrefixPhone, ddlPrefixPhone, REV1);

        return;

        string phone = String.Empty;
        string extension = String.Empty;
        int prefixPhone = -1;
        int prePrefixPhone = -1;
        int rowIndx = -1;

        TextBox txtPhone = row.FindControl("txtPhone") as TextBox;
        if (txtPhone != null && !String.IsNullOrEmpty(txtPhone.Text))
        {
            phone = txtPhone.Text;
        }
        TextBox txtExtension = row.FindControl("txtExtension") as TextBox;
        if (txtExtension != null && !String.IsNullOrEmpty(txtExtension.Text))
        {
            extension = txtExtension.Text;
        }


        if (ddlPrePrefixPhone != null && !String.IsNullOrEmpty(ddlPrePrefixPhone.SelectedValue))
        {
            prePrefixPhone = Convert.ToInt32(ddlPrePrefixPhone.SelectedValue.ToString());
        }



        if (ddlPrefixPhone != null)
        {
            prefixPhone = Convert.ToInt32(ddlPrefixPhone.SelectedValue.ToString());
        }


        if (REV1 != null)
            EnableDisablePrefixPhone(ddlPrePrefixPhone, ddlPrefixPhone, REV1);
        if (IsPhoneNumberIsValid(phone))
        {
            rowIndx = row.RowIndex;
            if (rowIndx > -1)
            {
                gvPhones.DataSource = null;

                DataTable dtData = (DataTable)ViewState[this.ClientID + "PhonesData"];
                if (dtData != null)
                {
                    DataRow dr = dtData.Rows[rowIndx];
                    if (dr != null)
                    {
                        if (prePrefixPhone != -1)
                            dr["prePrefix"] = prePrefixPhone;
                        else
                            dr["prePrefix"] = DBNull.Value;

                        if (prefixPhone != -1)
                            dr["prefix"] = prefixPhone;
                        else
                            dr["prefix"] = DBNull.Value;

                        if (extension != "")
                            dr["extension"] = Convert.ToInt32(extension);
                        else
                            dr["extension"] = DBNull.Value;

                        int result = -1;
                        if (int.TryParse(phone, out result))
                            dr["phone"] = phone;
                        else
                        {
                            REV1.Enabled = false;
                            //REV1.Validate();
                            return;
                        }

                        dr["phoneOrder"] = rowIndx;
                        dtData.AcceptChanges();

                        RemoveEmptyRows(ref dtData);
                        ViewState[this.ClientID + "PhonesData"] = dtData;
                    }
                }
            }

            BindGrid();
        }
    }

    private void RemoveEmptyRows(ref DataTable dtData)
    {
        try
        {
			
            ArrayList arr = new ArrayList(); 

            for (int i = 0; i < dtData.Rows.Count; i++)
            {
                string prePrefix = dtData.Rows[i]["PrePreFix"].ToString();
                string prefix = dtData.Rows[i]["preFix"].ToString();
                string phone = dtData.Rows[i]["phone"].ToString();
                if ((String.IsNullOrEmpty(prePrefix) && String.IsNullOrEmpty(prePrefix) && phone == "-1") || (String.IsNullOrEmpty(prePrefix) && String.IsNullOrEmpty(prePrefix) && String.IsNullOrEmpty(phone)))
                {
                    arr.Add(i); 
                }
            }

            if (arr.Count > 0)
            {
                for (int i = 0; i < arr.Count; i++)
                {
                    dtData.Rows.RemoveAt(int.Parse(arr[i].ToString())); 
                }
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
    }

    private bool IsPhoneNumberIsValid(string phone)
    {
        if (EnableBlankData)
        {
            return true;
        }
        else
        {
            if (!String.IsNullOrEmpty(phone))
                return true;
            else
                return false;
        }
    }

    public string ReturnPhoneNumber(DataRow row)
    {
        string prefix = String.Empty;
        string prePrefix = String.Empty;
        string phoneNumber = String.Empty;

        try
        {
            if (row["prePrefix"] != DBNull.Value)
            {
                prePrefix = row["prePrefix"].ToString();
                if (prePrefix == "1")
                {
                    phoneNumber += "1-";
                }
                else
                {
                    if (prePrefix == "2")
                    {
                        phoneNumber += "*";
                    }
                }
            }

            if (row["prefixText"] != DBNull.Value)
            {
                prefix = row["prefixText"].ToString();
                
                if (!string.IsNullOrEmpty(prefix))
                    phoneNumber += prefix + "-";
            }

            if (row["phone"] != null)
            {
                phoneNumber += row["phone"];
            }          
        }

        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }

        return phoneNumber;
    }
}