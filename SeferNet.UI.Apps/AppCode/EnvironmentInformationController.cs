using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Matrix.ExceptionHandling;
using SeferNet.BusinessLayer.BusinessObject;

/// <summary>
/// Contains  information about the application that uses the exception handling tool
/// </summary>
/// </summary>
public class EnvironmentInformationController : EnvironmentInformationControllerBase
{
    public EnvironmentInformationController()
    {
        //
        // TODO: Add constructor logic here
        //
    }
   
    public override string GetPublisherUniqueIdentifer()
    {
        string valToReturn = string.Empty;
        UserInfo userInfo = null;
        if (HttpContext.Current.Session != null)
        {
            userInfo = HttpContext.Current.Session["currentUser"] as UserInfo;
        }

        if (userInfo != null)
        {
            valToReturn = userInfo.UserNameWithPrefix;
        }
        else
        {
            valToReturn = "not logged in";
        }

        return valToReturn;
    }
}
