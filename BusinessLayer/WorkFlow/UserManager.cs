using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.DataLayer;
using System.Configuration;
using System.Data;
using System.Web;
using System.Xml;
using System.Xml.XPath;
using SeferNet.BusinessLayer.ADClalit;
using System.IO;
using System.Web.Security;
using System.Linq;

using SeferNet.Globals;
using Microsoft.ApplicationBlocks.ExceptionManagement;
using System.Collections;
using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using Clalit.SeferNet.GeneratedEnums;
namespace SeferNet.BusinessLayer.WorkFlow
{
    public class UserManager
    {
        UserInfo currentUser;
        string m_ConnStr;

        //constructor
        public UserManager()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang();
        }

        public UserManager(string userNameWithPrefix)
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang();
            currentUser = new UserInfo();
            currentUser.UserNameWithPrefix = userNameWithPrefix;
        }

        public void ClearSessionFromUserInfo()
        {
            if (HttpContext.Current != null)
            {
                HttpContext.Current.Session["currentUser"] = null;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public UserInfo GetUserInfoFromSession()
        {
            if (HttpContext.Current != null && HttpContext.Current.Session["currentUser"] != null)
            {
                return HttpContext.Current.Session["currentUser"] as UserInfo;
            }

            return null;
        }

        public string GetLoggedinUserNameWithPrefix()
        {
            UserInfo currentUser = GetUserInfoFromSession();

            if (currentUser != null)
                return currentUser.UserNameWithPrefix;
            else
                return string.Empty;
        }

        public string GetUserNameForLog()
        {
            UserInfo currentUser = GetUserInfoFromSession();

            if (currentUser != null)
                return currentUser.NameForLog;
            else
                return string.Empty;
        }

        public string GetLoggedinUserNameNoPrefix()
        {
            UserInfo currentUser = GetUserInfoFromSession();

            if (currentUser != null)
                return currentUser.UserNameNoPrefix;
            else
                return string.Empty;
        }

        public Int64 GetUserIDFromSession()
        {
            UserInfo currentUser = GetUserInfoFromSession();

            if (currentUser != null)
                return currentUser.UserID;
            else
                return 0;
        }

        public bool UserIsAdministrator()
        {
            UserInfo currentUser = GetUserInfoFromSession();

            if (currentUser != null)
                return currentUser.IsAdministrator;
            else
                return false;
        }

        public bool UserHasDistrictPermission()
        {
            UserInfo user = GetUserInfoFromSession();

            if (user == null)
                return false;
            else
            {
                return user.HasDistrictPermission;
            }
        }

        public bool DeptPermittedForUser(int deptCode)
        {
            currentUser = GetUserInfoFromSession();

            if (currentUser == null)
                return false;

            return currentUser.IsDeptPermitted(deptCode);
        }

        public int GetUserDistrict()
        {
            currentUser = GetUserInfoFromSession();

            if (currentUser != null)
            {
                return currentUser.DistrictCode;
            }
            else
                return 0;
        }

        /// <summary>
        /// Load the user information from the database and fills the session user key 
        /// for later use
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public UserInfo GetUserInfoFromDB(Int64 userID)
        {
            UserInfo userInfo = new UserInfo();
            UserDb userdb = new UserDb(m_ConnStr);
            DataSet dsUser = new DataSet();
            userdb.getUserInfo(ref dsUser, userID);
            if (dsUser != null && dsUser.Tables.Count != 0 && dsUser.Tables[0].Rows.Count != 0)
            {
                DataRow drUser = dsUser.Tables[0].Rows[0];

                userInfo.UserID = Convert.ToInt64(drUser["UserID"]);
                string[] userAD = drUser["UserName"].ToString().Split('\\');

                if (userAD.Length == 1)
                    userInfo.UserAD = userAD[0];
                else
                    userInfo.UserAD = userAD[1];

                userInfo.Description = drUser["UserDescription"].ToString();
                userInfo.FirstName = drUser["FirstName"].ToString();
                userInfo.LastName = drUser["LastName"].ToString();
                userInfo.NameForLog = userInfo.UserID + " " + userInfo.FirstName + " " + userInfo.LastName;
                userInfo.UserNameWithPrefix = userInfo.NameForLog; // we have to get rid of it
                userInfo.Domain = drUser["Domain"].ToString();
                userInfo.Mail = drUser["Email"].ToString();
                userInfo.DefinedInAD = Convert.ToBoolean(drUser["DefinedInAD"]);
            }

            return userInfo;
        }

        public void LoadUserInfo(long userID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            UserDb userdb = new UserDb(m_ConnStr);
            DataSet dsUser = new DataSet();
            userdb.getUserInfo(ref dsUser, userID);

            //if user is defined in db and has at least one permission
            if (dsUser != null && dsUser.Tables.Count != 0 && dsUser.Tables[0].Rows.Count != 0)
            {
                dsUser.Tables[0].TableName = "UserDetails";
                dsUser.Tables[1].TableName = "UserPermissions";
                dsUser.Tables[2].TableName = "UserDepts";

                DataRow drUser = dsUser.Tables["UserDetails"].Rows[0];

                currentUser = new UserInfo();
                currentUser.UserID = Convert.ToInt64(drUser["UserID"]);
                currentUser.UserAD = drUser["UserName"].ToString();
                currentUser.Description = drUser["UserDescription"].ToString();
                currentUser.FirstName = drUser["FirstName"].ToString();
                currentUser.LastName = drUser["LastName"].ToString();
                currentUser.NameForLog = currentUser.UserID + " " + currentUser.FirstName + " " + currentUser.LastName;
                currentUser.UserNameWithPrefix = currentUser.NameForLog; // we have to get rid of it
                currentUser.Domain = drUser["Domain"].ToString();
                currentUser.Mail = drUser["Email"].ToString();
                currentUser.DefinedInAD = Convert.ToBoolean(drUser["DefinedInAD"]);

                //permissions from UserPermissions Table
                currentUser.UserPermissions = new List<UserPermission>();
                DataTable dtPermissions = dsUser.Tables["UserPermissions"];

                for (int i = 0; i < dtPermissions.Rows.Count; i++)
                {
                    UserPermission permission = new UserPermission();

                    //permission.iPermissionType = Convert.ToInt32(dsUser.Tables["UserPermissions"].Rows[i]["permissionType"]);
                    Enums.UserPermissionType permissionType = (Enums.UserPermissionType)dsUser.Tables["UserPermissions"].Rows[i]["permissionType"];

                    if (permissionType == Enums.UserPermissionType.Administrator)
                        currentUser.IsAdministrator = true;

                    permission.DeptCode = Convert.ToInt32(dsUser.Tables["UserPermissions"].Rows[i]["deptCode"]);
                    permission.PermissionType = permissionType;

                    currentUser.UserPermissions.Add(permission);
                }

                //setHighestPermissions(currentUser);

                if (dsUser.Tables[3] != null)
                    currentUser.DistrictCode = Convert.ToInt32(dsUser.Tables[3].Rows[0]["districtCode"]);

                //Permitted dept codes
                if (!currentUser.IsAdministrator)
                {
                    IEnumerable<DataRow> list = dsUser.Tables["UserDepts"].AsEnumerable();
                    var deptCodes = from depts in list
                                    select depts.Field<int>("DeptCode");

                    currentUser.UserDepts = deptCodes.ToList<int>();
                }

            }
            else
            {
                currentUser = null;
            }

            HttpContext.Current.Session["currentUser"] = currentUser;
        }

        public bool authenticateUserAgainstAD(string domain, string userName, string p_userPassword)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<ClalitService><Input><MessageInfo>");
            sb.Append("<ApplicationName>ConfirmSystem</ApplicationName>");
            sb.Append("<ServiceName>UserLoginStatus</ServiceName>");
            sb.Append("<UserDomain>" + domain + "</UserDomain>");
            sb.Append("<UserName>" + userName + "</UserName>");
            sb.Append("</MessageInfo>");
            sb.Append("<parameters>");

            sb.Append("<AccountName>" + userName + "</AccountName>");
            sb.Append("<AccountPassword>" + p_userPassword + "</AccountPassword>");

            sb.Append("<Domain>" + domain + "</Domain> ");
            ////

            string[] properties = SeferNet.Globals.ConstsSystem.All_PROPERTIES_FROM_AD_USER.Split('|');
            string[] propertyValue = new string[properties.Length];

            //sb.Append("<Properties>");
            //foreach (string property in properties)
            //{
            //    sb.Append("<PropertyName>" + property + "</PropertyName>");
            //}
            //sb.Append("</Properties>");

            /////
            sb.Append("</parameters></Input></ClalitService>");
            ADClalit.Service1 serv = new Service1();
            string answerXml = serv.ADservice(sb.ToString());

            string status = string.Empty;

            XmlDocument doc = new XmlDocument();
            doc.LoadXml(answerXml);
            XmlElement root = doc.DocumentElement;

            XmlNodeList statusList = root.GetElementsByTagName("UserLoginStatus");
            foreach (XmlNode singleValue in statusList)
            {
                status = singleValue.InnerXml;
            }
            if (status != "yes")
                return false;

            return true;
        }

        public Hashtable GetAllRelevantPropertiesOfUser(string userName, string userDomain)
        {
            //get
            string[] request = SeferNet.Globals.ConstsSystem.All_PROPERTIES_FROM_AD_USER.Split('|');
            string[] result = getPropertiesOfUser(request, userName, userDomain);

            if (result[0] == null)
                return null;
            //build HT
            Hashtable ht = new Hashtable(result.Length);

            //fill data 2 table
            for (int i = 0; i < request.Length; i++)
                ht.Add(request[i], result[i]);

            //return table
            return ht;
        }

        public void UpdateUserInDB(ref UserInfo userInfo, string updateUserName)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            string userName;
            if (userInfo.Domain != string.Empty)
                userName = userInfo.Domain + @"\" + userInfo.UserAD;
            else
                userName = userInfo.UserAD;

            userdb.UpdateUser(userInfo.UserID, userName, userInfo.Domain, userInfo.Description,
                userInfo.Phone, userInfo.FirstName, userInfo.LastName, userInfo.Mail, updateUserName);
        }

        private bool GetUserDetails(XmlNodeList propValueList)
        {
            Hashtable hashtable = new Hashtable(propValueList.Count);

            foreach (XmlNode singleValue in propValueList)
            {
                hashtable.Add(singleValue.Name, singleValue.InnerText);
            }
            //for (int i = 0; i < propValueList.Count; i++)
            //{ 
            //    //hashtable.Add(request[i], result[i]);
            //    hashtable.Add(request[i], result[i]);
            //}

            return true;
        }

        public DataSet GetUserList(int districtCode, int permissionType, string userName, string firstName, string lastName, Int64? userID, string domain, bool? definedInAD, bool? errorReport, bool? trackingNewClinic, bool? ReportRemarksChange)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            return userdb.getUserList(districtCode, permissionType, userName, firstName, lastName, userID, domain, definedInAD, errorReport, trackingNewClinic, ReportRemarksChange);
        }
        public DataSet GetUserListForExcell(int districtCode, int permissionType, string userName, string firstName, string lastName, Int64? userID, string domain, bool? definedInAD, bool? errorReport, bool? trackingNewClinic, bool? trackingRemarkChanges)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            return userdb.getUserListForExcell(districtCode, permissionType, userName, firstName, lastName, userID, domain, definedInAD, errorReport, trackingNewClinic, trackingRemarkChanges);
        }

        public DataSet GetUsersToCheck(string domain, bool getNonCheckedOnly)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            return userdb.GetUsersToCheck(domain, getNonCheckedOnly);
        }

        public void UpdateUserIDToCheck(string userAD, Int64 userIDfromAD, bool userIsInAD)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            userdb.UpdateUserIDToCheck(userAD, userIDfromAD, userIsInAD);
        }

        public void InsertUser(ref UserInfo userInfo, string updateUserName)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            string userName;
            if (userInfo.Domain != string.Empty)
                userName = userInfo.Domain + @"\" + userInfo.UserAD;
            else
                userName = userInfo.UserAD;

            userdb.InsertUser(userInfo.UserID, userName, userInfo.Domain, userInfo.Description, userInfo.Phone, userInfo.FirstName, userInfo.LastName, userInfo.Mail, userInfo.DefinedInAD, updateUserName);
        }

        public void DeleteUser(Int64 userID)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            userdb.DeleteUser(userID);
        }

        public void DeleteUserPermissions(Int64 userID)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            userdb.DeleteUserPermissions(userID);
        }

        public void InsertUserPermissions(DataTable userPermissions, string updateUserName)
        {
            UserDb userdb = new UserDb(m_ConnStr);

            foreach (DataRow dr in userPermissions.Rows)
            {
                userdb.InsertUserPermission(Convert.ToInt64(dr["UserID"]),
                                            Convert.ToInt32(dr["PermissionType"]),
                                            Convert.ToInt32(dr["deptCode"]),
                                            Convert.ToBoolean(dr["ErrorReport"]),
                                            Convert.ToBoolean(dr["TrackingNewClinic"]),
                                            Convert.ToBoolean(dr["TrackingRemarkChanges"]),
                                            updateUserName
                                            );
            }
        }

        public bool IsUserExist(string userName)
        {
            string AskedDomain = "Clalit";
            string Domain = "Clalit";
            string AskedUserName = userName.Split('\\')[1];

            string isExist = string.Empty;

            StringBuilder sb = new StringBuilder(1000);

            //build xml
            sb.Append("<ClalitService><Input><MessageInfo>");
            sb.Append("<ApplicationName>ConfirmSystem</ApplicationName>");
            sb.Append("<ServiceName>UserExistStatus</ServiceName>");
            sb.Append("<UserDomain>" + AskedDomain + "</UserDomain>");
            sb.Append("<UserName>" + AskedUserName + "</UserName>");
            sb.Append("</MessageInfo>");
            sb.Append("<parameters>");

            sb.Append("<AccountName>" + AskedUserName + "</AccountName>");
            sb.Append("<AccountPassword></AccountPassword>");
            sb.Append("<Domain>" + Domain + "</Domain> ");

            sb.Append("</parameters></Input></ClalitService>");

            ADClalit.Service1 GetPropertyService = new ADClalit.Service1();
            string XmlFromWs = GetPropertyService.ADservice(sb.ToString());

            XmlDocument doc = new XmlDocument();
            try
            {
                doc.LoadXml(XmlFromWs);
            }
            catch
            {
                return false;
            }

            // Get and display all the book titles.
            XmlElement root = doc.DocumentElement;
            XmlNodeList elemList = root.GetElementsByTagName("UserExistStatus");
            isExist = elemList[0].InnerXml.ToUpper();

            if (isExist == "YES")
            {
                return true;
            }

            return false;
        }

        public UserInfo GetUserPropertiesFromAD(string domain, string userName)
        {
            System.DirectoryServices.DirectoryEntry objEntry = null;
            System.DirectoryServices.DirectorySearcher objSearcher = null;
            System.DirectoryServices.SearchResult objSearchResult = null;

            UserInfo userInfo = new UserInfo();
            try
            {
                string sUserWithDomain = "";
                string sDomainName = "";

                string sActiveDirectoryPath = BuildActiveDirectoryPath(domain);
                string sUserWithoutDomain = "";

                sUserWithDomain = domain + @"\" + userName;
                sDomainName = System.IO.Path.GetDirectoryName(sUserWithDomain);

                sUserWithoutDomain = System.IO.Path.GetFileNameWithoutExtension(sUserWithDomain);

                objEntry = new System.DirectoryServices.DirectoryEntry(sActiveDirectoryPath);
                objSearcher = new System.DirectoryServices.DirectorySearcher(objEntry);
                objSearcher.Filter = "(SAMAccountName=" + sUserWithoutDomain + ")";
                objSearcher.PropertiesToLoad.Add("cn");

                objSearchResult = objSearcher.FindOne();
                if (objSearchResult == null)
                {
                    throw new Exception("לא ניתן לאמת את פרטי המשתמש");
                }
                else
                {
                    System.DirectoryServices.DirectoryEntry directoryEntry = objSearchResult.GetDirectoryEntry();

                    if (directoryEntry.Properties["extensionAttribute15"].Value != null && directoryEntry.Properties["extensionAttribute15"].ToString() != string.Empty
                            && (directoryEntry.Properties["employeeID"].Value == null || directoryEntry.Properties["employeeID"].Value.ToString() == string.Empty))
                        userInfo.UserID = Convert.ToInt64(directoryEntry.Properties["extensionAttribute15"].Value.ToString() + directoryEntry.Properties["extensionAttribute14"].Value.ToString());
                    else
                    {
                        if (directoryEntry.Properties["employeeID"].Value != null && directoryEntry.Properties["employeeID"].ToString() != string.Empty)
                        {
                            userInfo.UserID = Convert.ToInt64(directoryEntry.Properties["employeeID"].Value.ToString());
                        }
                        else
                        {
                            userInfo.UserID = 0;
                        }
                    }

                    userInfo.UserAD = userName;
                    userInfo.Domain = domain;
                    if (directoryEntry.Properties["title"].Value != null)
                        userInfo.Title = directoryEntry.Properties["title"].Value.ToString();
                    else
                        userInfo.Title = string.Empty;
                    userInfo.FirstName = directoryEntry.Properties["givenName"].Value.ToString();
                    userInfo.LastName = directoryEntry.Properties["sn"].Value.ToString();
                    userInfo.Name = directoryEntry.Properties["name"].Value.ToString();

                    if (directoryEntry.Properties["telephoneNumber"].Value != null)
                        userInfo.Phone = directoryEntry.Properties["telephoneNumber"].Value.ToString();
                    else
                        userInfo.Phone = string.Empty;

                    if (directoryEntry.Properties["mobile"].Value != null)
                        userInfo.PhoneMobile = directoryEntry.Properties["mobile"].Value.ToString();
                    else
                        userInfo.PhoneMobile = string.Empty;

                    if (directoryEntry.Properties["facsimileTelephoneNumber"].Value != null)
                        userInfo.Fax = directoryEntry.Properties["facsimileTelephoneNumber"].Value.ToString();
                    else
                        userInfo.Fax = string.Empty;

                    if (directoryEntry.Properties["mail"].Value != null)
                        userInfo.Mail = directoryEntry.Properties["mail"].Value.ToString();
                    else
                        userInfo.Mail = string.Empty;
                    return userInfo;
                }

            }
            catch (Exception Ex)
            {
                if (Ex.Message.IndexOf("unknown user name or bad password") > -1)
                    return userInfo;
                return userInfo;
            }
        }

        public string BuildActiveDirectoryPath(string domain)
        {
            string activeDirectoryPath = string.Empty;
            string sUserWithDomain = string.Empty;

            switch (domain.ToUpper())
            {
                case "CLALIT":
                    activeDirectoryPath = "LDAP://DC=clalit,DC=org,DC=il";
                    break;
                case "MOR":
                    activeDirectoryPath = "LDAP://DC=machon-mor,DC=co,DC=il";
                    break;
                default:
                    activeDirectoryPath = "LDAP://DC=" + domain.Trim() + ",DC=clalit,DC=org,DC=il";
                    break;
            }

            return activeDirectoryPath;
        }

        private string[] getPropertiesOfUser(string[] properties, string domain, string userName)
        {
            string AskedDomain = domain;
            string[] userNameExtended = userName.Split('\\');
            string AskedUserName = userName;
            if (userNameExtended.Length > 1)
                AskedUserName = userNameExtended[1];
            else
                AskedUserName = userNameExtended[0];


            string[] propertyValue = new string[properties.Length];

            StringBuilder sb = new StringBuilder(1000);

            //<PropertyName>mail</PropertyName><PropertyName>givenName</PropertyName></Properties></parameters></Input></ClalitService>

            //build xml
            sb.Append("<ClalitService><Input><MessageInfo>");
            sb.Append("<ApplicationName>ConfirmSystem</ApplicationName>");
            sb.Append("<ServiceName>GetUserProperties</ServiceName>");
            sb.Append("<UserDomain>" + AskedDomain + "</UserDomain>");
            sb.Append("<UserName>" + AskedUserName + "</UserName>");
            sb.Append("</MessageInfo>");
            sb.Append("<parameters>");

            sb.Append("<AccountName>" + AskedUserName + "</AccountName>");
            sb.Append("<AccountPassword></AccountPassword>");
            sb.Append("<Domain>" + domain + "</Domain> ");

            sb.Append("<Properties>");
            foreach (string property in properties)
            {
                sb.Append("<PropertyName>" + property + "</PropertyName>");
            }

            sb.Append("</Properties>");

            sb.Append("</parameters></Input></ClalitService>");

            ADClalit.Service1 GetPropertyService = new ADClalit.Service1();
            string XmlFromWs = GetPropertyService.ADservice(sb.ToString());

            XmlDocument doc = new XmlDocument();
            try
            {
                doc.LoadXml(XmlFromWs);
            }
            catch (Exception ex)
            {
                //ExceptionManager.
                //ExceptionManagementHelper.PublishException(ex, ((int)Enums.ErrorNumbers.LoadXMLdocumentFailed).ToString(), ConstErrorDescription.LOAD_XML_FAILED);
            }

            // Get and display all the book titles.
            XmlElement root = doc.DocumentElement;

            XmlNodeList propValueList = root.GetElementsByTagName("UserPropertyValue");

            int i = 0;
            foreach (XmlNode singleValue in propValueList)
            {
                propertyValue[i] = singleValue.InnerXml;
                i++;
            }

            return propertyValue;
        }

        public string[] getPropertiesOfUser_special(string[] properties, string domain, string userName)
        {
            string AskedDomain = domain;
            string AskedUserName;
            //string AskedUserName = userName;
            if (userName.IndexOf('\\') > 0)
                AskedUserName = userName.Split('\\')[1].Trim();
            else
                AskedUserName = userName;

            string[] propertyValue = new string[properties.Length];

            StringBuilder sb = new StringBuilder(1000);

            //<PropertyName>mail</PropertyName><PropertyName>givenName</PropertyName></Properties></parameters></Input></ClalitService>

            //build xml
            sb.Append("<ClalitService><Input><MessageInfo>");
            sb.Append("<ApplicationName>ConfirmSystem</ApplicationName>");
            sb.Append("<ServiceName>GetUserProperties</ServiceName>");
            sb.Append("<UserDomain>" + AskedDomain + "</UserDomain>");
            sb.Append("<UserName>" + AskedUserName + "</UserName>");
            sb.Append("</MessageInfo>");
            sb.Append("<parameters>");

            sb.Append("<AccountName>" + AskedUserName + "</AccountName>");
            sb.Append("<AccountPassword></AccountPassword>");
            sb.Append("<Domain>" + domain + "</Domain> ");

            sb.Append("<Properties>");
            foreach (string property in properties)
            {
                sb.Append("<PropertyName>" + property + "</PropertyName>");
            }

            sb.Append("</Properties>");

            sb.Append("</parameters></Input></ClalitService>");

            ADClalit.Service1 GetPropertyService = new ADClalit.Service1();
            string XmlFromWs = GetPropertyService.ADservice(sb.ToString());

            XmlDocument doc = new XmlDocument();

            doc.LoadXml(XmlFromWs);

            // Get and display all the book titles.
            XmlElement root = doc.DocumentElement;

            XmlNodeList propValueList = root.GetElementsByTagName("UserPropertyValue");

            int i = 0;
            foreach (XmlNode singleValue in propValueList)
            {
                propertyValue[i] = singleValue.InnerXml;
                i++;
            }

            return propertyValue;
        }

        public DataSet getUserPermittedDistricts(Int64 UserID)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            return userdb.getUserPermittedDistricts(UserID);
        }

        public DataSet getUserPermittedDistrictsForReports(Int64 UserID, string unitTypeCodes)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            return userdb.getUserPermittedDistrictsForReports(UserID, unitTypeCodes);
        }

        public DataSet getUserMailesToSendReportAboutClinicRemark(int deptCode)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            return userdb.getUserMailesToSendReportAboutClinicRemark(deptCode);
        }

        public DataSet GetUserPermissions(Int64 userID)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            return userdb.getUserPermissions(userID);
        }

        public void UpdateUserIDviaUserAD_special(string UserName, Int64 UserID, string FirstName, string LastName, string Email, string PhoneNumber)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            userdb.UpdateUserIDviaUserAD_special(UserName, UserID, FirstName, LastName, Email, PhoneNumber);
        }

        public List<Enums.UserPermissionType> GetUserPermissionsForMenuViewing(UserInfo currentUser)
        {
            List<Enums.UserPermissionType> list = new List<Enums.UserPermissionType>();

            if (currentUser.IsAdministrator)
                list.Add(Enums.UserPermissionType.Administrator);

            if (currentUser.HasDistrictPermission)
                list.Add(Enums.UserPermissionType.District);

            if (currentUser.CanManageTarifonViews)
                list.Add(Enums.UserPermissionType.ManageTarifonViews);

            if (currentUser.HasAdminClinicPermission)
                list.Add(Enums.UserPermissionType.AdminClinic);
            else
            {
                if (currentUser.UserDepts != null && currentUser.UserDepts.Count > 0 && !currentUser.HasDistrictPermission)
                    list.Add(Enums.UserPermissionType.Clinic);
            }

            if (currentUser.UserPermissions.Count > 0)
            {
                foreach (UserPermission up in currentUser.UserPermissions)
                {
                    if (up.PermissionType == Enums.UserPermissionType.ViewHiddenAndReports &&
                                                                !list.Contains(Enums.UserPermissionType.ViewHiddenAndReports))
                        list.Add(Enums.UserPermissionType.ViewHiddenAndReports);

                    if (up.PermissionType == Enums.UserPermissionType.ViewHiddenDetails &&
                                                                !list.Contains(Enums.UserPermissionType.ViewHiddenDetails))
                        list.Add(Enums.UserPermissionType.ViewHiddenDetails);

                    if (up.PermissionType == Enums.UserPermissionType.ManageInternetSalServices)
                        list.Add(Enums.UserPermissionType.ManageInternetSalServices);
                }
            }

            // add lowest permission if none
            if (list.Count == 0)
            {
                list.Add(Enums.UserPermissionType.AvailableToAll);
            }

            return list;
        }

        public void Insert_LogChange(int changeTypeID, Int64 updateUser, int deptCode, Int64? employeeID, int? deptEmployeeID, int? deptEmployeeServicesID, int? remarkID, int? serviceCode, string value)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            userdb.Insert_LogChange(changeTypeID, updateUser, deptCode, employeeID, deptEmployeeID, deptEmployeeServicesID, remarkID, serviceCode, value);
        }

        public DataSet GetChangeTypes(string changeTypeSelected)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            DataSet ds = userdb.GetChangeTypes(changeTypeSelected);

            return ds;
        }

        public DataSet GetUpdateUser(string updateUserSelected)
        {
            UserDb userdb = new UserDb(m_ConnStr);
            DataSet ds = userdb.GetUpdateUser(updateUserSelected);

            return ds;
        }

    }
}
