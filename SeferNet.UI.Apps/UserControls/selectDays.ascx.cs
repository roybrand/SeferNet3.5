using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Clalit.Infrastructure.ServiceInterfaces;
using SeferNet.FacadeLayer;
using Clalit.Infrastructure.ServicesManager;
using Clalit.SeferNet.GeneratedEnums;
using System.Web.UI.HtmlControls;

public partial class UserControls_selectDays : System.Web.UI.UserControl
{

    protected void Page_Load(object sender, EventArgs e)
    {
        
        BindControl();
        
        
    }

    protected void BindControl()
    {
        DataTable tbl = GetReceptionDaysTable();
        createTable(tbl);
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

    private void createTable(DataTable dt)
    {
        
        int countRows = 1;
        HtmlTableCell tc;
        CheckBox cb;
        

        HtmlTableRow tr = new HtmlTableRow();
        foreach (DataRow dr in dt.Rows)
        {

            tc = new HtmlTableCell();
            cb = new CheckBox();
            cb.Text = dr["ReceptionDayName"].ToString();
            if (cb.Text.Length > 2 && countRows % 4 != 0)
            {
                tc.Attributes.Add("colspan", "2");
            }
            
            cb.Attributes.Add("value", dr["ReceptionDayName"].ToString());
            cb.Attributes.Add("onclick", "onDayClick(this);");
            tc.Controls.Add(cb);
            tr.Controls.Add(tc);
            
            

            if (countRows % 4 == 0)
            {
                tblDays.Controls.Add(tr);
                tr = new HtmlTableRow();
            }
            countRows++;
        }
        tblDays.Controls.Add(tr);

        tr = new HtmlTableRow();
        tc = new HtmlTableCell();
        tc.Attributes.Add("colspan", "4");
        tc.Style.Add("text-align", "center");

        String strButton = "<div style=\"margin:auto;width:47px;\"><div class=\"button_RightCorner\"></div><div class=\"button_CenterBackground\">";
        strButton += "<input type=\"button\" class=\"RegularUpdateButton\" value=\"אישור\" onclick=\"closeTableDays();\"/>";
        strButton += "</div><div class=\"button_LeftCorner\"></div><div>";


        tc.Controls.Add(new LiteralControl(strButton));
        tr.Controls.Add(tc);
        tblDays.Controls.Add(tr);

        
        
    }
}