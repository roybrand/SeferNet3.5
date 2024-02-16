using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using System.Configuration;

namespace SeferNet.DataLayer
{
    public class ConnectionHandler
    {

        public static string ResolveConnStrByLang()
        {
            string lang;
            if (HttpContext.Current.Session != null)
            {
                if (HttpContext.Current.Session["Culture"] == null)
                    lang = "he-il";
                else
                    lang = HttpContext.Current.Session["Culture"].ToString();
            }
            else
                lang = "he-il";

            return ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"].ConnectionString;

        }
    }
}
