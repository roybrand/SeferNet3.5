using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;

public partial class Tests_DefaultMultDDl : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //MultiDDlSelect_Days.ImgButtonClicked += new ImageClickEventHandler(MultiDDlSelect_Days_ImgButtonClicked);
        //MultiDDlSelect_New.ImgButtonClicked += new ImageClickEventHandler(MultiDDlSelect_New_ImgButtonClicked);
        //MultiDDlSelect_Days.Button.Click    +=new ImageClickEventHandler(Button_Click);            
        ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
        DataTable tbl = cacheHandler.getCachedDataTable(eCachedTables.DIC_ReceptionDays.ToString());

       MultiDDlSelect_New.BindData(tbl, "ReceptionDayCode", "ReceptionDayName");

        if (! Page.IsPostBack)
        {
            //MultiDDlSelect_Days.Items.Items.Add("uytyu1");
            //MultiDDlSelect_Days.Items.Items.Add("uytyu2");
            //MultiDDlSelect_Days.Items.Items.Add("uytyu3");
           
            MultiDDlSelect_Days.BindData(tbl, "ReceptionDayCode", "ReceptionDayName");

        }

        //ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
        //DataTable tbl = cacheHandler.getCachedDataTable("DIC_ReceptionDays");
         //MultiDDlSelect_Days.BindData(tbl, "ReceptionDayCode", "ReceptionDayName");
        //MultiDDlSelect_Days.ButtonClick += new UserControls_MultiDDlSelect.ImageButtonClickEventHandler(MultiDDlSelect_Days_ButtonClick);
        //****//

       // MultiDDlSelect_Days.CloseClick += new UserControls_MultiDDlSelect.CloseEventHandler(MultiDDlSelect_Days_CloseClick);




        //EventControl1.ImgButtonClicked +=new ImageClickEventHandler(EventControl1_ImgButtonClicked);        
        ////Hooking the selected index changed event.
        //MultiDDlSelect_Days.CloseClick +=new UserControls_MultiDDlSelect.CloseEventHandler(MultiDDlSelect_Days_CloseClick);
        //    MultiDDlSelectNew.SourceData = tbl;
           

    }

    void MultiDDlSelect_New_ImgButtonClicked(object sender, ImageClickEventArgs e)
    {
        throw new NotImplementedException();
    }

   protected void Button_Click(object sender, ImageClickEventArgs e)
    {
        string t = "";
    }

    protected void MultiDDlSelect_Days_ImgButtonClicked(object sender, ImageClickEventArgs e)
    {
        string t = "";
    }

    protected void MultiDDlSelect_Days_CloseClick(object sender, EventArgs e)
    {
        string t = "";
    }

    protected void MultiDDlSelect_Days_ButtonClick(object sender, ImageClickEventArgs e)
    {
        string t = "";
    }

   
    protected void MultiDDlSelectNew_ButtonClick(object sender, ImageClickEventArgs e)
    {
        string t = "";
    }


    //EventControl1_ImgButtonClickedEventControl1_ImgButtonClickedEventControl1_ImgButtonClicked
  protected  void EventControl1_ImgButtonClicked(object sender, ImageClickEventArgs e)
    {
        MessageLabel.Text = "Image! " + DateTime.Now.ToLongTimeString();
    }

   

    protected void EventControl1_ButtonClicked(object sender, EventArgs e)
    {
        MessageLabel.Text = "You clicked it! " + DateTime.Now.ToLongTimeString();
    }



          


    protected void Button1_Click(object sender, EventArgs e)
    {
        MessageLabel.Text = "Image! " + DateTime.Now.ToLongTimeString();
    }




    protected void Button1_Click1(object sender, EventArgs e)
    {

    }
}
