using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using SeferNet.Globals;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Data;
using System.Web.Security;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.FacadeLayer;
using ClalitUserManagement.Proxies;
using SeferNet.UI.Apps.CentralLogRegularService;

/// <summary>
/// Summary description for LoginService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class LoginService : System.Web.Services.WebService
{

    public LoginService()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }


    [WebMethod(EnableSession = true)]
    public int GetLoginResult(string domain, string userName, string password)
    {
        int retVal = (int)Enums.LoginResult.Unknown; //default

        try
        {
            if (userName != string.Empty && password != string.Empty)
            {
                UserManager manager = new UserManager();
                UserInfo currentUser;
                CentralLogServiceClient service = new CentralLogServiceClient();

                if (authenticateUser(domain, userName, password))
                {
                    currentUser = manager.GetUserInfoFromSession();

                    LogginAttemptRecord(domain, userName, true);

                    if (currentUser != null)
                    {
                        DataSet dsUserPermissions = manager.GetUserPermissions(currentUser.UserID);
                        if (dsUserPermissions.Tables[0].Rows.Count > 0)
                        {
                            FormsAuthentication.SetAuthCookie(currentUser.UserNameWithPrefix, false);
                            retVal = (int)Enums.LoginResult.Success;

                            Session[ConstsSession.IS_POST_BACK_AFTER_LOGIN_LOGOUT] = 1;
                            Session[ConstsSession.SUCCESSFUL_LOGIN_TOOK_PLACE] = 1;
                        }
                        else
                        {
                            manager.ClearSessionFromUserInfo();
                            retVal = (int)Enums.LoginResult.NoPermissionsForUser;
                        }
                    }
                    else
                    {
                        manager.ClearSessionFromUserInfo();
                        retVal = (int)Enums.LoginResult.UserNameOrPasswordNotCorrect;
                    }
                }
                else
                {
                    LogginAttemptRecord(domain, userName, false);

                    manager.ClearSessionFromUserInfo();

                    retVal = (int)Enums.LoginResult.UserNameOrPasswordNotCorrect;
                }
            }
        }
        catch (Exception ex)
        {
            retVal = (int)Enums.LoginResult.Failed;
        }

        return retVal;
    }


    private void LogginAttemptRecord(string domain, string userName, bool loginSuccess)
    {
        CentralLogServiceClient clsClient = new CentralLogServiceClient();

        string entryUser = string.Concat(domain.ToUpper(), "\\", userName.ToUpper());

        string entryIP = GetIPAddress();

        CentralLogOutput returnedOutput = clsClient.GetPreviousAndRefreshCentralLog(new CentralLogInput()
        {
            SystemId = ApplicationEnum.SeferNet,
            UserName = entryUser,
            UserNameReal = System.Security.Principal.WindowsIdentity.GetCurrent().Name.ToString().ToUpper(),
            EventDateTime = DateTime.Now,
            IsSuccessful = loginSuccess,
            IP = entryIP,
            MachineName = System.Environment.MachineName,
            SessionID = System.Web.HttpContext.Current.Session.SessionID
        });

        if (loginSuccess)
        {
            UserLoginInformation userLoginInformation = new UserLoginInformation();
            if (returnedOutput.FailedCount == null)
            {
                returnedOutput.FailedCount = 0;
            }
            userLoginInformation.FailedAttemptsCount = returnedOutput.FailedCount;
            if (returnedOutput.EventDateTime == null)
            {
                returnedOutput.EventDateTime = DateTime.Now;
            }
            userLoginInformation.LastLoginAttemptedLoginDate = returnedOutput.EventDateTime;
            userLoginInformation.UserName = returnedOutput.UserName;
            userLoginInformation.UserNameReal = returnedOutput.UserNameReal;
            userLoginInformation.MachineName = returnedOutput.MachineName;
            userLoginInformation.SessionID = returnedOutput.SessionID;
            userLoginInformation.UserIP = returnedOutput.IP;

            if (!string.IsNullOrEmpty(returnedOutput.SessionID) && entryIP != returnedOutput.IP)
            {
                userLoginInformation.LoginFromOtherIpExists = true;
            }
            else
            {
                userLoginInformation.LoginFromOtherIpExists = false;
            }

            Session["UserLoginInformation"] = userLoginInformation;
        }


    }

    protected string GetIPAddress()
    {
        System.Web.HttpContext context = System.Web.HttpContext.Current;
        string ipAddress = context.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];

        if (!string.IsNullOrEmpty(ipAddress))
        {
            string[] addresses = ipAddress.Split(',');
            if (addresses.Length != 0)
            {
                return addresses[0];
            }
        }

        return context.Request.ServerVariables["REMOTE_ADDR"];
    }

    private bool authenticateUser(string domain, string userName, string password)
    {
        bool userIsAuthenticatedAgainstAD = false;        
        bool result = true;
        UserInfo userInfo = new UserInfo();
        UserManager manager = new UserManager();
        Facade applicFacade = Facade.getFacadeObject();



       //userIsAuthenticatedAgainstAD = manager.authenticateUserAgainstAD(domain, userName, password);
        userIsAuthenticatedAgainstAD = CheckUserPass(userName, domain, password);
        if (userIsAuthenticatedAgainstAD)
        {
            GetUserProperties(domain, userName);
            userInfo = manager.GetUserPropertiesFromAD(domain, userName);
        }
        //try
        //{
        //    AdTools AdTools = new AdTools();
        //    userIsAuthenticatedAgainstAD = AdTools.UserLoginStatus(userName, domain, password);
        //}
        //catch(Exception ex)
        //{ 
        
        //}

        if (userIsAuthenticatedAgainstAD)
        {
            result = applicFacade.UpdateUserInDB(ref userInfo, string.Empty);
            
            if (result)
                return applicFacade.LoadUserInfo(userInfo.UserID);                
            else
                return false;
        }
        else
        {
            long userID;
            Int64.TryParse(password, out userID);

            if (userID != 0)
                return applicFacade.LoadUserInfo(userID);
            else
                return false;

        }        
    }

    public bool CheckUserPass(string p_userName, string p_domain, string p_passWord)
    {
        try
        {
            string sUserWithDomain = "";
            string sDomainName = "";
            UserManager um = new UserManager();
            string sActiveDirectoryPath = um.BuildActiveDirectoryPath(p_domain);//"LDAP://DC=clalit,DC=org,DC=il";
            string sUserWithoutDomain = "";

            System.DirectoryServices.DirectoryEntry objEntry = null;
            System.DirectoryServices.DirectorySearcher objSearcher = null;
            System.DirectoryServices.SearchResult objSearchResult = null;

            sUserWithDomain = p_domain + @"\" + p_userName;
            sDomainName = System.IO.Path.GetDirectoryName(sUserWithDomain);

            //if (sDomainName.Trim().ToUpper() != "clalit".ToUpper())
            //{
            //    sActiveDirectoryPath = "LDAP://DC=" + sDomainName.Trim() + ",DC=clalit,DC=org,DC=il";
            //}

            sUserWithoutDomain = System.IO.Path.GetFileNameWithoutExtension(sUserWithDomain);

            objEntry = new System.DirectoryServices.DirectoryEntry(sActiveDirectoryPath, sUserWithDomain, p_passWord);
            objSearcher = new System.DirectoryServices.DirectorySearcher(objEntry);
            objSearcher.Filter = "(SAMAccountName=" + sUserWithoutDomain + ")";
            objSearcher.PropertiesToLoad.Add("cn");

            objSearchResult = objSearcher.FindOne();
            if (objSearchResult == null)
            {

                throw new Exception("לא ניתן לאמת את פרטי המשתמש");
            }
            else
                return true;
        }
        catch (Exception Ex)
        {
            if (Ex.Message.IndexOf("unknown user name or bad password") > -1 ) 
                return false;
            return false;
        }
    }

    public static void GetUserProperties(string p_domain, string p_userName) 
    {
        System.DirectoryServices.AccountManagement.PrincipalContext ctx = new System.DirectoryServices.AccountManagement.PrincipalContext(System.DirectoryServices.AccountManagement.ContextType.Domain, p_domain);
        System.DirectoryServices.AccountManagement.UserPrincipal u = System.DirectoryServices.AccountManagement.UserPrincipal.FindByIdentity(ctx, p_userName);

        string firstname = u.GivenName;
        string lastname = u.Surname;
        string email = u.EmailAddress;
        string telephone = u.VoiceTelephoneNumber;
    }

    [WebMethod(EnableSession = true)]
    public int GetLogoutResult()
    {
        int retVal = (int)Enums.LogoutResult.Unknown; //default

        try
        {

            FormsAuthentication.SignOut();
            UserManager manager = new UserManager();
            manager.ClearSessionFromUserInfo();
            retVal = (int)Enums.LogoutResult.Success; //

        }
        catch (Exception ex)
        {
            retVal = (int)Enums.LogoutResult.Failed; //

        }

        return retVal;
    }
}
