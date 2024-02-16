using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SeferNet.UI.Apps.Templates
{
    public partial class PrintingParameters_ZoomSalService : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string physicalApplicationPath = Request.ApplicationPath;
            hdnTemplatePath.Value = physicalApplicationPath + @"/Templates/";
        }
    }
}