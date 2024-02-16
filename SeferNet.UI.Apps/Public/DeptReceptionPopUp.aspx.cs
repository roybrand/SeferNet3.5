using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.Globals;


public partial class Public_DeptReceptionPopUp : System.Web.UI.Page
{
    DataSet m_dsClinic;
    
    protected int DeptCode;
    private bool m_futureInfoMode = false;
    private DateTime expirationDate;
    private DateTime m_closestDeptReceptionChange = DateTime.MaxValue;
    

    protected void Page_Load(object sender, EventArgs e)
    {
        DeptCode = Convert.ToInt32(Request.QueryString["deptCode"]);

        SetWindowMode();

        BindDeptName();
    }

    private void SetWindowMode()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["expirationDate"]))
        {
            DateTime.TryParse(Request.QueryString["expirationDate"].ToString(), out expirationDate);

            m_futureInfoMode = true;
        }
    }

    

    public bool BindDeptName()
    {
        Facade applicFacade;
        applicFacade = Facade.getFacadeObject();
        m_dsClinic = applicFacade.GetDeptDetailsForPopUp(DeptCode);
        
        lblDeptName.Text = m_dsClinic.Tables[0].Rows[0]["deptName"].ToString();
        lblPhone.Text = m_dsClinic.Tables[0].Rows[0]["phone1"].ToString();
        lblDistrictName.Text = m_dsClinic.Tables[0].Rows[0]["districtName"].ToString();
        lblAddress.Text = m_dsClinic.Tables[0].Rows[0]["address"].ToString();
        lblCityName.Text = m_dsClinic.Tables[0].Rows[0]["cityName"].ToString();

        return true;
    }




    

}
