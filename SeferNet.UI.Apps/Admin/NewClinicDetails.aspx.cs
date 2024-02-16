using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.FacadeLayer;

public partial class NewClinicDetails : AdminPopupBasePage
{

    private DataTable _receptionDt;
    private int _deptCode = -1;
    Facade applicFacade;

    protected void Page_Load(object sender, EventArgs e)
    {
        BindData();
    }


    private void BindData()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["DeptCode"]))
        {
            _deptCode = Convert.ToInt32(Request.QueryString["DeptCode"]);
            applicFacade = Facade.getFacadeObject();
            dvClinicDetailes.DataSource = applicFacade.GetNewClinic(_deptCode);
            dvClinicDetailes.DataBind();
        }
    }

}
