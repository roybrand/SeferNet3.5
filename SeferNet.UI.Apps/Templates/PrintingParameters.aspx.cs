using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;

public partial class PrintingParameters : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
        if (sessionParams != null)
            hdnCurrentDeptCode.Value = sessionParams.DeptCode.ToString();

        string physicalApplicationPath = Request.ApplicationPath;
        hdnTemplatePath.Value = physicalApplicationPath + @"/Templates/";
    }
}