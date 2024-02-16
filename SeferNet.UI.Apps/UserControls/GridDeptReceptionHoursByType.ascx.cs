using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Collections;
public partial class UserControls_GridDeptReceptionHoursByType : System.Web.UI.UserControl
{
    private DataTable dtReseptionHours = null;
    private Dictionary<int,int> dicDays = new Dictionary<int,int>();
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }

    public DataTable ClinicReseptionHours
    {
        set {
            dtReseptionHours = value;
        }
    }

    public string ReceptionHoursTitle
    {
        set {
            lblOfficeReceptionCaption.Text = value;
        }
    }
    public void bindData()
    {

        gvDeptReception.DataSource = dtReseptionHours;
        gvDeptReception.DataBind();
    
    }

    public bool displayOpenCloseButton
    {
        set {
            if (value == false)
            {
                divBtnPlusMinus.Style.Remove("display");
                divBtnPlusMinus.Style.Add("display", "none");
            }
        }
    }

    public bool showReceptionHours
    {
        set {
            if (value == true)
            {
                divReceptionTitle.Style.Add("border-left", "1px solid #dddddd");
                divBtnPlusMinus.Attributes.Remove("class");
                divBtnPlusMinus.Attributes.Add("class", "btnMinus");
                divReceptionHoursType.Style.Remove("display");
                divReceptionHoursType.Style.Add("display","block");
            }
            else
            {
                divReceptionTitle.Style.Add("border-left", "none;");
                divBtnPlusMinus.Attributes.Remove("class");
                divBtnPlusMinus.Attributes.Add("class", "btnPlus");
                divReceptionHoursType.Style.Remove("display");
                divReceptionHoursType.Style.Add("display", "none");
            }
        }
    }

    public void setMainDivClass(string divClass)
    {
        divReceptionHoursType.Attributes.Remove("class");
        divReceptionHoursType.Attributes.Add("class", divClass);
        divBtnPlusMinus.Attributes.Remove("onclick");
        divBtnPlusMinus.Attributes.Add("onclick", "setReceptionDisplay(this,'" + divClass + "')");
    }

    protected void gvDeptReception_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            
            DataRow dr = ((DataRowView)e.Row.DataItem).Row;
            int receptionDay = Convert.ToInt32(dr["receptionDay"]);
            if (!dicDays.ContainsValue(receptionDay))
            {
                GridView gvClinicHours = e.Row.FindControl("gvClinicHours") as GridView;

                DataView deptReception_ForOneDay = new DataView(dtReseptionHours,
                    "receptionDay = " + receptionDay, "openingHour", DataViewRowState.CurrentRows);
                gvClinicHours.DataSource = deptReception_ForOneDay;
                gvClinicHours.DataBind();
                int rowCount = 0;
                foreach (GridViewRow row in gvClinicHours.Rows)
                {
                    if (rowCount > 0) { 
                        row.Attributes["style"] = "border-top:dotted 1px #aaaaaa";
                    }
                    rowCount++;
                }

                dicDays.Add(receptionDay, receptionDay);
            }
            else
            {
                e.Row.Visible = false;
            }
        }
    }

    

    
    
    
}