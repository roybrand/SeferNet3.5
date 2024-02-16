<%@ WebHandler Language="C#" Class="ElRte.Options" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using ClalitCommon.BusinessLogic.OLBL;
using ClalitCommon.BusinessObject.OnlineAdminBO;


namespace ElRte
{

    public class Options : IHttpHandler
    {
        private HttpContext _context;
        
        public void ProcessRequest(HttpContext context)
        {
            _context = context;
            context.Response.ContentType = "text/javascript";
            var script = BuildScript();
            context.Response.Write(script);
        }

        public bool IsReusable
        {
            get
            {
                return true;
            }
        }

        protected static string ToJson(IEnumerable<OLWebTranceConstants> eventList)
        {

            if (eventList == null) return "{}";

            var serializer = new JavaScriptSerializer();
            var items = eventList
                            .GroupBy(item => item.ConstantEvent)
                            .ToDictionary(m => m.Key, m => m.Select(item => item.ConstantName).ToArray());

            return serializer.Serialize(items);
        }
        
        protected static string ToJson(IEnumerable<OLConstants> constants)
        {

            if (constants == null) return "{}";

            var serializer = new JavaScriptSerializer();
            var items = constants.GroupBy( m => m.Name ).ToDictionary(m => m.Key, m => m.Key );

            return serializer.Serialize(items);
        }


        public static string ToJson(IDictionary<string, string> eventList)
        {

            if (eventList == null) return "{}";

            var serializer = new JavaScriptSerializer();

            return serializer.Serialize(eventList);
        }

        protected static IDictionary<string, string> GetCssClasses()
        {
            return new Dictionary<string, string>()
                       {
                           {"", "Select Class"},
                           {"BlueText", "BlueText"},
                           {"BottomDottedLine", "BottomDottedLine"},
                           {"GreenTitle", "GreenTitle"},
                           {"OrangeTitle", "OrangeTitle"}
                       };
        }
        
        
        protected string BuildScript()
        {
            var webTrensds = OLWebTranceConstantsManager.GetAllConstants(null, null);
            var constants = OLConstantsManager.GetAllConstants(null, null);
            var cssClasses = GetCssClasses();
            var builder = new StringBuilder();

            builder
                .AppendLine("(function($) {")
                .AppendLine("elRTE.prototype.options.buttons.constant = 'Online Constants';")
                .AppendLine("elRTE.prototype.options.buttons.webtrends = 'Online webtrends';")
                .AppendLine("elRTE.prototype.options.buttons.cssClass = 'Online Css Classes';")
                .AppendLine("elRTE.prototype.options.panels.online = ['constant', 'link', 'webtrends'];")
                .AppendLine("elRTE.prototype.options.toolbars.online = ['online', 'undoredo', 'copypaste', 'direction', 'lists', 'style', 'alignment', 'pasteText' ];")
                .AppendLine("elRTE.prototype.options.toolbar = 'online';")
                .AppendLine("elRTE.prototype.options.width = 850;")
                .AppendLine("elRTE.prototype.options.height = 250;")
                .AppendLine("elRTE.prototype.options.absoluteURLs = false;")
                .AppendFormat("elRTE.prototype.options.cssfiles = ['{0}'];", VirtualPathUtility.ToAbsolute("~/ElRte/css/elrte-inner.css"))
                .AppendFormat("elRTE.prototype.options.webtrends = {0};", ToJson(webTrensds)).AppendLine()
                .AppendFormat("elRTE.prototype.options.constants = {0};", ToJson(constants)).AppendLine()
                .AppendFormat("elRTE.prototype.options.cssClasses = {0};", ToJson(cssClasses)).AppendLine()
                .AppendLine("})(jQuery);");


            return builder.ToString();
        }
    }
}
