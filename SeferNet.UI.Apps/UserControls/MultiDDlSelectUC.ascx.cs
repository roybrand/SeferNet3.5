using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Data;
using System.Collections;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.FacadeLayer;
using System.IO;
using System.Reflection;
using System.Text;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;

public partial class UserControls_MultiDDlSelectUC : System.Web.UI.UserControl
{
    public event ImageClickEventHandler ImgButtonClicked;
    public delegate void ImageButtonClickEventHandler(object sender, ImageClickEventArgs e);
    public event ImageButtonClickEventHandler ButtonClick;    
    private DataTable _dtSource = null;


    public TextBox TextBox
    {
        get { return this.txtItems; }
    }

    public HtmlTable Items
    {
        get { return tblMultiDDL; }
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

    public string Width
    {
        get { return this.tblMain.Width; }
        set { this.tblMain.Width = value; }
    }

    public string Height
    {
        get { return this.tblMain.Height; }
        set { this.tblMain.Height = value; }
    }

    public Button ButtonOK
    {
        get { return this.btnClose; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        //if (!IsPostBack)
        //{
            //this.BuildScriptsString();
            //this.btnOpenClose.OnClientClick = this.script_BtnOpenClose_Click + " return btnOpenClose_Click" + this.ClientID + "()";
            //this.btnClose.OnClientClick = this.script_BtnClose_Click + "return btnClose_Click" + this.ClientID + "()";
            
            //UpdatePanel UpdatePanel1 = this.Parent.Parent as UpdatePanel;
            
            //ScriptManager.RegisterClientScriptBlock(this, typeof(UserControl), "clientScript_" + this.ClientID,
            //    this.script_setSelectItems + this.script_BtnOpenClose_Click + this.script_setSelectItems, true);
            BindControl();
        //}
        
        btnOpenClose.Attributes.Add("onclick", "btnOpenClose_Click('" + "pnlData_" + this.ClientID + "'); return false;");
        txtItems.Attributes.Add("onfocus","this.blur(); btnOpenClose_Click('" + "pnlData_" + this.ClientID +"');");
       
    }

    protected void BindControl()
    {
        DataTable tbl = GetReceptionDaysTable();
        this.BindData(tbl, "ReceptionDayCode", "ReceptionDayName");
    }

    protected DataTable GetReceptionDaysTable()
    {
        DataTable tbl = null;
        try
        {
            ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
            tbl = cacheHandler.getCachedDataTable(eCachedTables.DIC_ReceptionDays.ToString());
            if (tbl == null) // if table was not found in cache we get the data from the database
            {
                Facade applicFacade = Facade.getFacadeObject();
                DataSet ds = applicFacade.getGeneralDataTable("DIC_ReceptionDays");
                tbl = ds.Tables[0];
                if (tbl == null)
                    return null;
            }
        }
        catch (Exception ex)
        {
            throw new Exception(ex.Message);
        }
        return tbl;
    }
    
    private void CalculateSquare(DataTable dtSource, ref  int columns, ref int rows)
    {
        try
        {
            int countItems = dtSource.Rows.Count;
            double sqrt = 0;
            double round = 0;
            int result = 0;
            if (columns == -1)
            {
                sqrt = Math.Sqrt((double)countItems);
                round = Math.Round(sqrt, 0);
                if (round * round <= countItems)
                {
                    //x++;
                    //y = Math.DivRem(count, (int)x, out  result);
                    columns = Convert.ToInt32(round + 1);
                }
                else
                {
                    columns = Convert.ToInt32(round);
                }
                columns = Convert.ToInt32(round); 
            }

            rows = Math.DivRem(countItems, columns, out result);
            if (result > 0)
                rows++;
        }
        catch (Exception ex)
        {            
            throw new Exception(ex.Message);
        }
    }

    public SortedList SelectedItems
    {
        get
        {
            return getSelectedItemsHashTbl();
        }
    }

    public void SelectSpesificDate(string day)
    {
        int counter = 0;

        foreach (HtmlTableRow row in tblMultiDDL.Rows)
        {
            for (int j = 0; j < row.Cells.Count; j++)
            {
                CheckBox chkBx = row.FindControl("chkItem_" + counter.ToString() + "_" + j.ToString() + "_" + this.ClientID) as CheckBox;
                if (chkBx != null)
                {
                    if (chkBx.Text == day)
                    {
                        chkBx.Checked = true;
                    }
                }
            }
            counter++;
        }
    }   


    private SortedList getSelectedItemsHashTbl()
    {
        string select = String.Empty;
        SortedList myList = new SortedList();
        int counter = 0;

        foreach (HtmlTableRow row in tblMultiDDL.Rows)
        {
            for (int j = 0; j < row.Cells.Count; j++)
            {
                CheckBox chkBx = row.FindControl("chkItem_" + counter.ToString() + "_" + j.ToString() + "_" + this.ClientID) as CheckBox;
                if (chkBx != null)
                {
                    if (chkBx.Checked)
                    {                       
                        string value = chkBx.Attributes["value"].ToString();
                        myList.Add(value , chkBx.Text);
                    }
                }
            }
            counter++;
        }

        return myList;
    }

    public void ClearFields()
    {
        int counter = 0;

        foreach (HtmlTableRow row in tblMultiDDL.Rows)
        {
            for (int j = 0; j < row.Cells.Count; j++)
            {
                CheckBox chkBx = row.FindControl("chkItem_" + counter.ToString() + "_" + j.ToString() + "_" + this.ClientID) as CheckBox;
                if (chkBx != null)
                {
                    chkBx.Checked = false;
                }
            }
            counter++;
        }
    }


    public void BindData(DataTable _dtData, string colimnID, string columnName)
    {

        int columns = 4;
        int rows = -1;
        int step = 0;

        CalculateColumnsAndRows(_dtData, ref columns, ref rows);

        if (rows > 0)
        {
            for (int i = 0; i < rows; i++)
            {
                HtmlTableRow rowT = new HtmlTableRow();
                rowT.EnableViewState = true;
                if (columns > 0)
                {
                    for (int j = 0; j < columns; j++)
                    {
                        HtmlTableCell cell = new HtmlTableCell();

                        cell.Style.Add("height", "10px");

                        CheckBox chkBx = new CheckBox();

                        chkBx.ID = "chkItem_" + i.ToString() + "_" + j.ToString() + "_" + this.ClientID;


                        if (step < _dtData.Rows.Count)
                        {
                            chkBx.Text = _dtData.Rows[step][1].ToString();
                            chkBx.Attributes.Add("value", _dtData.Rows[step][0].ToString());

                            chkBx.InputAttributes["onchange"] = " return setSelectItems('" + this.tblMultiDDL.ClientID + "');";

                            chkBx.AutoPostBack = false;

                            step++;
                            cell.Controls.Add(chkBx);
                            rowT.Cells.Add(cell);
                        }
                    }
                }

                tblMultiDDL.Rows.Add(rowT);
            }
            if (tblMultiDDL.Rows.Count > 0)
            {
                CheckCountTdsForEachRow(tblMultiDDL);
            }
        }
    }

    private void CalculateColumnsAndRows(DataTable dt, ref int columns, ref int rows)
    {
        if (ViewState["DaysColumnsNum"] != null)
        {
            columns = (int)ViewState["DaysColumnsNum"];
            rows = (int)ViewState["DaysRowsNum"];
        }
        else
        {
            CalculateSquare(dt, ref  columns, ref  rows);

            //ViewState["DaysColumnsNum"] = columns;
            //ViewState["DaysRowsNum"] = rows;
        }

    }

    private void CheckCountTdsForEachRow(HtmlTable tblMultiDDL)
    {
        int cellsNumber = tblMultiDDL.Rows[0].Cells.Count;
        Dictionary<int, int> dic;

        if (ViewState["colSpanColumns"] != null)
        {
            dic = (Dictionary<int, int>)ViewState["colSpanColumns"];


            foreach (KeyValuePair<int, int> val in dic)
            {
                tblMultiDDL.Rows[val.Key].Cells[val.Value].ColSpan = 2;
            }
        }
        else
        {
            int rowIndex = -1;
            int colIndex = -1;
            dic = new Dictionary<int, int>();

            foreach (HtmlTableRow row in tblMultiDDL.Rows)
            {
                rowIndex++;
                colIndex = -1;
                if (row.Cells.Count < cellsNumber)
                {
                    foreach (HtmlTableCell cell in row.Cells)
                    {
                        colIndex++;

                        CheckBox chkBx = cell.Controls[0] as CheckBox;

                        if (chkBx.Text.Length > 2)
                        {
                            cell.ColSpan = 2;
                            //dic.Add(rowIndex, colIndex);
                        }
                    }
                }
            }

            //ViewState["colSpanColumns"] = dic;
        }
    }
    
    public string getSelectItemsCodes()
    {
        string select = String.Empty;
        
        int counter = 0;
        foreach (HtmlTableRow row in tblMultiDDL.Rows)
        {
            for (int j = 0; j < row.Cells.Count; j++)
            {
                CheckBox chkBx = row.FindControl("chkItem_" + counter.ToString() + "_" + j.ToString() + "_" + this.ClientID) as CheckBox;
                if (chkBx != null)
                {
                    if (chkBx.Checked)
                    {
                        string value = chkBx.Attributes["value"].ToString();
                        select += value + ",";
                    }
                }
            }
            counter++;
        }

        if (select != string.Empty && select.Length > 0)
            select = select.Remove(select.Length - 1, 1);
        return select;     
    }



}
