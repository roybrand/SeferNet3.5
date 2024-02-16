using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.FacadeLayer;

public partial class ClinicDetails : AdminPopupBasePage
{

    private DataTable _receptionDt;
    private int _deptCode = -1;
    Facade applicFacade;
    DataSet m_dsClinic;

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
            m_dsClinic = applicFacade.GetDeptDetailsForPopUp(_deptCode);

            dvClinicDetailes.DataSource = m_dsClinic.Tables[0];
            dvClinicDetailes.DataBind();
        }
    }

    protected void dvClinicDetailes_DataBinding(object sender, EventArgs e)
    {
        DataRow row = m_dsClinic.Tables[0].Rows[0];

        if (row["substituteManagerName"].ToString().Length > 0)
            row["managerName"] = row["substituteManagerName"];

    }
}
