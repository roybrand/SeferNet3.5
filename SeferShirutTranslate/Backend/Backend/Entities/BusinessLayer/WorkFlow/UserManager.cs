using Backend.Entities.BusinessLayer.BusinessObject;

namespace Backend.Entities.BusinessLayer.WorkFlow
{
    public class UserManager
    {
        public UserInfo GetUserFromAD(string domain, string userName)
        {
            System.DirectoryServices.DirectoryEntry objEntry = null;
            System.DirectoryServices.DirectorySearcher objSearcher = null;
            System.DirectoryServices.SearchResult objSearchResult = null;

            UserInfo userInfo = new UserInfo();

            string sUserWithDomain = "";
            string sDomainName = "";

            string sActiveDirectoryPath = BuildActiveDirectoryPath(domain);
            string sUserWithoutDomain = "";

            sUserWithDomain = domain + @"\" + userName;
            sDomainName = Path.GetDirectoryName(sUserWithDomain);

            sUserWithoutDomain = Path.GetFileNameWithoutExtension(sUserWithDomain);

            objEntry = new System.DirectoryServices.DirectoryEntry(sActiveDirectoryPath);
            objSearcher = new System.DirectoryServices.DirectorySearcher(objEntry);
            objSearcher.Filter = "(SAMAccountName=" + sUserWithoutDomain + ")";
            objSearcher.PropertiesToLoad.Add("cn");

            objSearchResult = objSearcher.FindOne();
            if (objSearchResult == null)
            {
                return new UserInfo(1);
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
                {
                    userInfo.Title = directoryEntry.Properties["title"].Value.ToString();
                }
                else
                {
                    userInfo.Title = string.Empty;
                }

                userInfo.FirstName = directoryEntry.Properties["givenName"].Value.ToString();
                userInfo.LastName = directoryEntry.Properties["sn"].Value.ToString();
                userInfo.Name = directoryEntry.Properties["name"].Value.ToString();

                if (directoryEntry.Properties["telephoneNumber"].Value != null)
                {
                    userInfo.Phone = directoryEntry.Properties["telephoneNumber"].Value.ToString();
                }
                else
                {
                    userInfo.Phone = string.Empty;
                }

                if (directoryEntry.Properties["mobile"].Value != null)
                {
                    userInfo.PhoneMobile = directoryEntry.Properties["mobile"].Value.ToString();
                }
                else
                {
                    userInfo.PhoneMobile = string.Empty;
                }

                if (directoryEntry.Properties["facsimileTelephoneNumber"].Value != null)
                {
                    userInfo.Fax = directoryEntry.Properties["facsimileTelephoneNumber"].Value.ToString();
                }
                else
                {
                    userInfo.Fax = string.Empty;
                }

                if (directoryEntry.Properties["mail"].Value != null)
                {
                    userInfo.Mail = directoryEntry.Properties["mail"].Value.ToString();
                }
                else
                {
                    userInfo.Mail = string.Empty;
                }

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
    }
}
