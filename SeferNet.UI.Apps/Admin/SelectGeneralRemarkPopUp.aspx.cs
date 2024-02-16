using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using SeferNet.DataLayer;

public partial class SelectGeneralRemarkPopUp : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        dsGeneralRemarks.ConnectionString = ConnectionHandler.ResolveConnStrByLang();
        tdMainHeader.InnerHtml = UIHelper.GetStrbyImg(Page.Title);
        //string str = Request.QueryString["linkedTo"].ToString();
    }

    protected void dsGeneralRemarks_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        e.Command.Parameters["@LinkedToDept"].Value = DBNull.Value;
        e.Command.Parameters["@LinkedToDoctor"].Value = DBNull.Value;
        e.Command.Parameters["@LinkedToDoctorInClinic"].Value = DBNull.Value;
        e.Command.Parameters["@LinkedToServiceInClinic"].Value = DBNull.Value;
        e.Command.Parameters["@LinkedToReceptionHours"].Value = DBNull.Value;
        e.Command.Parameters["@EnableOverlappingHours"].Value = DBNull.Value;
        if( string.Compare(Request.QueryString["LinkedTo"], "LinkedToDept", true) == 0 )
            e.Command.Parameters["@LinkedToDept"].Value = 1;
        if (string.Compare(Request.QueryString["LinkedTo"], "LinkedToDoctor", true) == 0)
            e.Command.Parameters["@LinkedToDoctor"].Value = 1;
        if (string.Compare(Request.QueryString["LinkedTo"], "LinkedToDoctorInClinic", true) == 0)
            e.Command.Parameters["@LinkedToDoctorInClinic"].Value = 1;
        if (string.Compare(Request.QueryString["LinkedTo"], "LinkedToServiceInClinic", true) == 0)
            e.Command.Parameters["@LinkedToServiceInClinic"].Value = 1;
        if (string.Compare(Request.QueryString["LinkedTo"], "LinkedToReceptionHours", true) == 0)
            e.Command.Parameters["@LinkedToReceptionHours"].Value = 1;
        if (string.Compare(Request.QueryString["LinkedTo"], "EnableOverlappingHours", true) == 0)
            e.Command.Parameters["@EnableOverlappingHours"].Value = 1;

    }
}
