using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SeferNet.UI.Apps.UserControls
{
    public partial class ServicesControl : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            txtProfessionListCodes.Style.Add("display", "none");
        }
    }
}