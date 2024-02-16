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
using SeferNet.FacadeLayer;
using SeferNet.UI;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Text;
using System.Globalization;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using MapsManager;
using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using System.Collections.Generic;
using SeferNet.Globals;

public partial class UpdateSalServiceDetails : AdminBasePage
{
    Facade applicFacade = Facade.getFacadeObject();

    UserInfo currentUser;

    public SessionParams_SalServices SessionParams
    {
        get
        {
            if (this.Session["SessionParams_SalServices"] == null)
                this.Session["SessionParams_SalServices"] = new SessionParams_SalServices();

            return (SessionParams_SalServices)this.Session["SessionParams_SalServices"];
        }
    }

    protected int CurrentServiceCode = 0;

    protected void Page_Load(object sender, EventArgs e)   
    {
        Form.DefaultButton = btnUpdate_Bottom.UniqueID;

        currentUser = this.Session["currentUser"] as UserInfo;

        if (!SessionParams.ServiceCode.HasValue)
            this.Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);
        else
            CurrentServiceCode = SessionParams.ServiceCode.Value;

        if (CurrentServiceCode == 0 || currentUser == null)    // is session expired?
        {
            this.Response.Redirect(PagesConsts.SEARCH_CLINICS_URL, true);
        }

        if (!this.IsPostBack)
        {
            
        }
        else 
        {

        }
    }

    private void BindDetaultView()
    {
        // Bind dropdown that are needed for the page.

    }

    public void BindSalServiceDetails()
    {
        
    }

    public void BindDeptDeptQueueOrderHeadLine()
    {
        
    }

    private void SetQueueOrderVisibility()
    {
        
    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        string errorMessage = string.Empty;

        if (this.Page.IsValid)
        {
            // Implament update here.
        }
    }

    private bool ValidateForm()
    {
        bool validated = true;
        string validationMesage = string.Empty;

        return validated;
    }

    private bool updateSalServiceInDb()
    {
        return true;
    }

}   


