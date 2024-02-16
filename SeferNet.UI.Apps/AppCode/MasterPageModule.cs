using System;
using System.Web;
using System.Web.UI;
using System.Threading;
using System.Globalization;

public class MasterPageModule : IHttpModule
{
    public void Init(HttpApplication context)
    {
        context.PreRequestHandlerExecute += new EventHandler(context_PreRequestHandlerExecute);
    }

    public void context_PreRequestHandlerExecute(object sender, EventArgs e)
    {
        Page page = HttpContext.Current.CurrentHandler as Page;
        if (page != null)
        {
            page.PreInit += new EventHandler(page_PreInit);
        }
    }

    public void page_PreInit(object sender, EventArgs e)
    {
        Page page = sender as Page;
        
        if (HttpContext.Current.Request.Params["ctl00$pageContent$ddlLanguage"] != null && HttpContext.Current.Request.Params["ctl00$ddlLanguage"] != string.Empty)
        {
            string lang = HttpContext.Current.Request.Params["ctl00$pageContent$ddlLanguage"];
            Thread.CurrentThread.CurrentUICulture = new CultureInfo(lang);
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(lang);
        }
        else
        {
           
            if (HttpContext.Current.Session["Culture"] == null)
            {
                HttpContext.Current.Session["Culture"] = "he-il";
            }
            
            string lang = HttpContext.Current.Session["Culture"].ToString();
            Thread.CurrentThread.CurrentUICulture = new CultureInfo(lang);
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(lang);
        

        }
        
    }

    public void Dispose()
    {
    }
} 

