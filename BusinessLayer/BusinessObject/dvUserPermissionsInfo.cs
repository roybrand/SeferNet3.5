using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class dvUserPermissionsInfo
    {
        private string deptCode;

        public string DeptCode
        {
            get { return deptCode; }
            set { deptCode = value; }
        }

       

        private string permissionType;

        public string PermissionType
        {
            get { return permissionType; }
            set { permissionType = value; }
        }

    }
}
