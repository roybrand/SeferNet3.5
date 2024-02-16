using System;
using System.Collections.Generic;
using System.Text;
 
using SeferNet.Globals; 

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class UserPermission
    {
        public UserPermission()
        {}

        public UserPermission(Enums.UserPermissionType permission, int deptCode)
        {
            PermissionType = permission;
            DeptCode = DeptCode;
        }
        

        public Enums.UserPermissionType PermissionType { get; set; }        

        public int DeptCode { get; set; }           
	
    }
}
