using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer;
using SeferNet.Globals;
public partial class Public_sendBrochuresAndForms : System.Web.UI.Page
{
    public string formsAndBrochuresPath = System.Configuration.ConfigurationManager.AppSettings["formsAndBrochuresPath"].ToString();
    public string manageType = "2";
    public string from = System.Configuration.ConfigurationManager.AppSettings["MushlamFromMail"].ToString();
    public string subject = ConstsSystem.EMAIL_SUBJECT_MUSHLAM;
    public string mailServerName = System.Configuration.ConfigurationManager.AppSettings["smtpServer"].ToString();
    bool _isCommunity = false;
    bool _isMushlam = false;
    
    
    bool IsCommunity
    {
        get
        {
            return _isCommunity;
        }
        set
        {
            _isCommunity = value;
        }


    }

    bool IsMushlam
    {
        get
        {
            return _isMushlam;
        }
        set
        {
            _isMushlam = value;
        }

    }

    private void setManageType()
    {
        if (Request.QueryString["manageType"] == null)
        {
            /* The defualt is Mushlam */
            IsCommunity = false;
            IsMushlam = true;
            setTitle("2");
        }
        else
        {
            switch (Request.QueryString["manageType"])
            { 
                case "1":
                    IsCommunity = true;
                    manageType = "1";
                    break;
                case "2":
                    IsMushlam = true;
                    manageType = "2";
                    break;
            }
            setTitle(Request.QueryString["manageType"]);
        }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        setManageType();
        bindForms();
        bindBrochures();
    }

    private void setTitle(string manageType)
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataTable dt = applicFacade.GetOrganizationSector();
        DataRow dr;
        dr = dt.Select("OrganizationSectorID = " + manageType)[0];
        Page.Title += " - " + dr["HebrewDescription"].ToString();
        
    }

    private void bindForms()
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = applicFacade.GetForms(IsCommunity, IsMushlam);
        repForms.DataSource = ds;
        repForms.DataBind();
    }

    private void bindBrochures()
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = applicFacade.GetBrochures(IsCommunity, IsMushlam);
        DataView dv1 = new DataView(ds.Tables[0],
                        "tbl = 1", "", DataViewRowState.CurrentRows);

        DataView dv2 = new DataView(ds.Tables[0],
                        "tbl = 2", "", DataViewRowState.CurrentRows);

        repBrochures_1.DataSource = dv1;
        repBrochures_1.DataBind();

        repBrochures_2.DataSource = dv2;
        repBrochures_2.DataBind();
    }

    private void sendMail()
    {
        //MailHelper.;
    }
}