using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Collections;

[ValidationProperty("ValidateText")]
public partial class UserControls_MultiDDlSelect : System.Web.UI.UserControl
{
    public string listOfTextsAndValues = "";
    
    #region Properties
    
    public CheckBoxList Items
    {
        get { return this.chkLst; }
        set { this.chkLst = value; }
    }

    public string CssClass
    {
        get
        {
            return this.Items.CssClass;
        }

        set
        {
            this.Items.CssClass = value;
        }
    }

    public string DataTextField
    {
        get { return this.chkLst.DataTextField; }
        set { this.chkLst.DataTextField = value; }
    }

    public string DataValueField
    {
        get { return this.chkLst.DataValueField; }
        set { this.chkLst.DataValueField = value; }
    }

    public string DataSourceID
    {
        get { return this.chkLst.DataSourceID; }
        set { this.chkLst.DataSourceID = value; }
    }

    public TextBox TextBox
    {
        get { return this.txtItems; }
    }

    public string ValidateText
    {
        get
        {
            if (this.txtItems.Text != string.Empty)
                return this.txtItems.Text;
            else
                return string.Empty;

        }
    }

    public new string Width
    {
        get { return this.tblMain.Width; }
        set
        {
            this.tblMain.Width = value;

            int pixelsWidth = 200;
            if (value.IndexOf("px") > -1)
            {
                pixelsWidth = Convert.ToInt32(value.Substring(0, value.IndexOf("px")));
            }
            txtItems.Width = pnlItems.Width = Unit.Pixel(pixelsWidth);
        }
    }
    public string Height
    {
        get { return this.tblMain.Height; }
        set { this.tblMain.Height = value; }
    }

    public Panel Panel
    {
        get { return this.pnlItems; }
    }

    public Image Button
    {
        get { return this.btnOpenClose; }
    }

    public SortedList SelectedItems
    {
        get
        {
            return GetSelectedItems();
        }
    }

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        /*
        string controlName = this.Request.Params.Get("__EVENTTARGET");
        

        //http://www.telerik.com/support/kb/aspnet-ajax/general/using-dynamic-unique-names-for-javascript-functions.aspx
        //this link explains why I need this

        //first time - go to server , second time - no 
        string dd = " function d_" + this.ClientID + "(){";
        dd += "if (returnHiddenValue_" + this.ClientID + "() == 1) {";
        dd += " setHiddenValue_" + this.ClientID + "(0);";
        dd += "var txt = document.getElementById('" + txtItems.ClientID + "');";
        dd += "txt.focus();";
        dd += "}";
        dd += " else if (returnHiddenValue_" + this.ClientID + "() == 0) {";
        dd += " setHiddenValue_" + this.ClientID + "(1);";
        dd += " }";
        dd += "}";

        dd += "function setHiddenValue_" + this.ClientID + "(x) {";
        dd += "  var hdnFlg = document.getElementById('" + hdnFlg.ClientID + "');";
        dd += "  if (hdnFlg != null) {";
        //dd += "alert('set' + hdnFlg.value);";
        dd += "hdnFlg.value = x;";
        //dd += "alert('set' + hdnFlg.value);";
        dd += "}";
        dd += "}";

        dd += "function returnHiddenValue_" + this.ClientID + "() {";
        dd += " var hdnFlg = document.getElementById('" + hdnFlg.ClientID + "');";
        dd += " if (hdnFlg != null) { ";
        dd += " return hdnFlg.value;";
        dd += "                     }";
        dd += " }; ";
        dd += "d_" + this.ClientID + "(); if (returnHiddenValue_" + this.ClientID + "() == 0){ return false;}";

        btnOpenClose.Attributes.Add("onclick", dd + ";return false; ");
        */

        btnOpenClose.Attributes.Add("onclick", "onOpenCloseClick()");

        btnPermit.Attributes.Add("onclick", "getCheckedItems(this);");

    }

    
    
    public void BindData(DataTable _dtData, string columnID, string columnName)
    {
        
        chkLst.Items.Clear();

        foreach (DataRow row in _dtData.Rows)
        {
            ListItem item = new ListItem();
            item.Value = row[columnID].ToString();
            item.Text = row[columnName].ToString();
            if (listOfTextsAndValues == "")
            {
                listOfTextsAndValues = item.Text + "~" + item.Value;
            }
            else
            {
                listOfTextsAndValues += "!#!" + item.Text + "~" + item.Value;
            }
            chkLst.Items.Add(item);
        }
        
        
    }

    

    public string getSelectItemsCodes()
    {
        string select = String.Empty;
        foreach (ListItem item in chkLst.Items)
        {
            if (item.Selected)
            {
                select += item.Value + ",";
            }
        }
        if (select != string.Empty && select.Length > 0)
            select = select.Remove(select.Length - 1, 1);
        return select;
    }

    public void ClearSelection()
    {
        this.txtItems.Text = "";
        foreach (ListItem item in chkLst.Items)
        {
            item.Selected = false;
        }
    }





    public void SelectItems(string delimitedValues)
    {
        delimitedValues = delimitedValues.Trim();

        if (delimitedValues.Length > 0 && delimitedValues[delimitedValues.Length - 1] == ',')
        {
            delimitedValues = delimitedValues.Substring(0, delimitedValues.Length - 1);
        }

        if (!string.IsNullOrEmpty(delimitedValues))
        {
            string[] arr = delimitedValues.Split(',');
            string selectedText = string.Empty;

            if (arr.Length > 0)
            {
                for (int i = 0; i < arr.Length; i++)
                {
                    chkLst.Items.FindByValue(arr[i]).Selected = true;
                    selectedText += chkLst.Items.FindByValue(arr[i]).Text + ",";
                }

                txtItems.Text = selectedText.Remove(selectedText.Length - 1, 1);
            }
        }
    }

    

    

    private SortedList GetSelectedItems()
    {
        string select = String.Empty;
        SortedList myList = new SortedList();
        foreach (ListItem item in chkLst.Items)
        {
            if (item.Selected)
            {
                myList.Add(item.Value.ToString(), item.Text);
            }
        }

        return myList;
    }

    

}
