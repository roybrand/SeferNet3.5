using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class UserInfo
    {
        string m_userNameWithPrefix;        
        int m_districtCode;
        List<UserPermission> m_UserPermissions;


        #region Properties

        public Int64 UserID {get; set; }

        public string Domain {get; set;}

        public string UserAD { get; set; }

        public string UserNameWithPrefix { get; set; }
        
        public string FirstName { get; set; }

        public string LastName { get; set; }

        public string Name { get; set; }

        public string Title { get; set; }

        public string Phone { get; set; }

        public string PhoneMobile { get; set; }

        public string Fax { get; set; }

        public string Mail { get; set; }

        public int DistrictCode { get; set; }

        public bool DefinedInAD { get; set; }

        public string Description { get; set; }

        public bool IsAdministrator { get; internal set; }

        public string NameForLog { get; internal set; }

        public List<int> UserDepts { get; set; }

        public List<UserPermission> UserPermissions
        {
            get { return m_UserPermissions; }
            set { m_UserPermissions = value; }
        }

        //public Enums.UserPermissionType MaxPermissionType
        //{
        //    get { return m_MaxPermissionType; }
        //    set { m_MaxPermissionType = value; }
        //}

        public string UserNameNoPrefix
        {
            get
            {
                string retVal = string.Empty;
                if (string.IsNullOrEmpty(m_userNameWithPrefix) == false)
                {
                    if (m_userNameWithPrefix.Contains("\\") == true)
                    {
                        string[] arr = m_userNameWithPrefix.Split(new string[] { "\\" }, StringSplitOptions.RemoveEmptyEntries);
                        retVal = arr[arr.Length - 1];
                    }
                    else
                    {
                        retVal = m_userNameWithPrefix;
                    }
                }
                return retVal;
            }
        }

        public bool HasDistrictPermission 
        {
            get
            {
                return UserPermissions.Exists(delegate(UserPermission up)
                                                        {
                                                            return (up.PermissionType == Enums.UserPermissionType.District);
                                                        });
            }            
        }

        public bool CanManageTarifonViews
        {
            get
            {
                return UserPermissions.Exists(delegate(UserPermission up)
                {
                    return (up.PermissionType == Enums.UserPermissionType.ManageTarifonViews);
                });
            }
        }

        public bool HasAdminClinicPermission
        {
            get
            {
                return UserPermissions.Exists(delegate(UserPermission up)
                {
                    return (up.PermissionType == Enums.UserPermissionType.AdminClinic);
                });
            }
        }


        #endregion


        public bool CheckIfUserPermitted(Enums.UserPermissionType permissionType, int districtCode)
        {
            if (IsAdministrator)
            {
                return true;
            }

            bool hasPermission = UserPermissions.Exists(
                                                            delegate(UserPermission up)
                                                            {
                                                                return (up.PermissionType == permissionType) &&
                                                                                (up.DeptCode == districtCode || districtCode == -1 || up.DeptCode == -1);
                                                            }
                                                        );

            return hasPermission;
        }

        public bool CheckIfHiddenDetailsAllowed(int districtCode)
        {
            if (IsAdministrator)
            {
                return true;
            }

            bool hasPermission = UserPermissions.Exists(
                                                delegate(UserPermission up)
                                                {
                                                    return (up.PermissionType == Enums.UserPermissionType.ViewHiddenDetails ||
                                                                       up.PermissionType == Enums.UserPermissionType.District)
                                                            && (up.DeptCode == districtCode || up.DeptCode == -1);
                                                }
                                                        );

            return hasPermission;
        }

        public bool IsDeptPermitted(int deptCode)
        {
            if (IsAdministrator)
                return true;

            bool hasPermission = UserDepts.Exists(delegate(int listDeptCode)
                                                        { 
                                                            return (listDeptCode == deptCode); 
                                                        });

            return hasPermission;
        }

        public bool IsDistrictPermitted(int districtCode)
        {
            if (IsAdministrator)            
                return true;

            bool hasPermission = UserPermissions.Exists(delegate(UserPermission up)
                                                        {
                                                            return (up.PermissionType == Enums.UserPermissionType.District) &&
                                                                   (up.DeptCode == districtCode);
                                                        });
            
            return hasPermission;
        }
    }

    public class UserLoginInformation
    {
        int ?m_FailedAttemptsCount;
        DateTime ?m_LastLoginAttemptedLoginDate;
        string m_UserNameReal;
        string m_UserName;
        string m_MachineName;
        string m_SessionID;
        string m_UserIP;
        bool m_LoginFromOtherIpExists;

        public int ?FailedAttemptsCount
        {
            get { return m_FailedAttemptsCount; }
            set { m_FailedAttemptsCount = value; }
        }

        public DateTime ?LastLoginAttemptedLoginDate
        {
            get { return m_LastLoginAttemptedLoginDate; }
            set { m_LastLoginAttemptedLoginDate = value; }
        }

        public string UserName
        {
            get { return m_UserName; }
            set { m_UserName = value; }
        }

        public string UserNameReal
        {
            get { return m_UserNameReal; }
            set { m_UserNameReal = value; }
        }

        public string MachineName
        {
            get { return m_MachineName; }
            set { m_MachineName = value; }
        }

        public string UserIP
        {
            get { return m_UserIP; }
            set { m_UserIP = value; }
        }

        public string SessionID
        {
            get { return m_SessionID; }
            set { m_SessionID = value; }
        }
        public bool LoginFromOtherIpExists
        {
            get { return m_LoginFromOtherIpExists; }
            set { m_LoginFromOtherIpExists = value; }
        }

        public UserLoginInformation()
        {
            m_FailedAttemptsCount = 0;
        }
    }
}
