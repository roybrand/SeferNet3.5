<%@ WebHandler Language="C#" Class="Handlers.KeepSessionAlive" %>

using System;
using System.Web;
namespace Handlers
{
    public class KeepSessionAlive : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.ContentType = "text/plain";
            context.Response.Write("Done!");
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

    }
}