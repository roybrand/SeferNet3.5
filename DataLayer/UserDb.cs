using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Web;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class UserDb : Base.SqlDal
    {

        public UserDb(string p_conString)
            : base(p_conString)
        {
        }

        public void getUserInfo(ref DataSet p_ds, Int64 p_userID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_userID };

            string spName = "rpc_getUserInfo";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet getUserList(int districtCode, int permissionType, string userName, string firstName, string lastName, Int64? userID, string domain, bool? definedInAD, bool? errorReport, bool? trackingNewClinic, bool? ReportRemarksChange)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { districtCode, permissionType, userName, firstName, lastName, userID, domain, definedInAD, errorReport, trackingNewClinic, ReportRemarksChange };

            string spName = "rpc_getUserList";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }
        public DataSet getUserListForExcell(int districtCode, int permissionType, string userName, string firstName, string lastName, Int64? userID, string domain, bool? definedInAD, bool? errorReport, bool? trackingNewClinic, bool? trackingRemarkChanges)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { districtCode, permissionType, userName, firstName, lastName, userID, domain, definedInAD, errorReport, trackingNewClinic, trackingRemarkChanges };

            string spName = "rpc_getUserListForExcell";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetUsersToCheck(string domain, bool getNonCheckedOnly)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { domain, getNonCheckedOnly };

            string spName = "rpc_getUsersToCheck";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public void UpdateUserIDToCheck(string userAD, Int64 userIDfromAD, bool userIsInAD)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { userAD, userIDfromAD, userIsInAD };

            string spName = "rpc_updateUserIDToCheck";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet getUserPermissions(Int64 UserID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { UserID };

            string spName = "rpc_getUserPermissions";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        //public DataSet getUserPermission(string UserName, int permissionType, int DeptCode)
        //{
        //    object[] outputParams = new object[1] { new object() };
        //    object[] inputParams = new object[3] { UserName, permissionType, DeptCode };

        //    string spName = "rpc_getUserPermission";
        //    DBActionNotification.RaiseOnDBSelect(spName, inputParams);
        //    return FillDataSet(spName, ref outputParams, inputParams);
        //}

        public DataSet getUserPermittedDistricts(Int64 UserID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { UserID };

            string spName = "rpc_getUserPermittedDistricts";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet getUserPermittedDistrictsForReports(Int64 UserID, string unitTypeCodes)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { UserID, unitTypeCodes };

            string spName = "rpc_getUserPermittedDistrictsForReports";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }
        public DataSet getUserMailesToSendReportAboutClinicRemark(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };

            string spName = "rpc_getUserMailesToSendReportAboutClinicRemark";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet getUserDetails(string UserName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { UserName };

            string spName = "rpc_getUserDetails";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public void DeleteUser(Int64 userID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { userID };

            string spName = "rpc_DeleteUser";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }
        //public void DeleteUserPermission(string UserName, int permissionType, int DeptCode)
        //{
        //    object[] outputParams = new object[1] { new object() };
        //    object[] inputParams = new object[3] { UserName, permissionType, DeptCode };

        //    string spName = "rpc_DeleteUserPermission";
        //    DBActionNotification.RaiseOnDBDelete(spName, inputParams);
        //    ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        //}

        public void DeleteUserPermissions(Int64 userID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { userID };
            string spName = "rpc_DeleteUserPermissions";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void InsertUser(Int64 userID, string userName, string domain, string userDescription, string phoneNumber,
                                string firstName, string lastName, string email, bool definedInAD, string currentUserName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { userID, userName, domain, userDescription, phoneNumber, firstName, lastName, email, definedInAD, currentUserName };
            string spName = "rpc_InsertUser";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void InsertUserPermission(string UserName, int permissionType, int DeptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[3] { UserName, permissionType, DeptCode };

            string spName = "rpc_insertUserPermission";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void InsertUserPermission(Int64 userID, int permissionType, int deptCode, bool errorReport, bool trackingNewClinic, bool TrackingRemarkChanges, string updateUserName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { userID, permissionType, deptCode, errorReport, trackingNewClinic, TrackingRemarkChanges, updateUserName };
            string spName = "rpc_insertUserPermission";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void UpdateUser(Int64 UserID, string UserName, string Domain, string UserDescription, string PhoneNumber,
                                string FirstName, string LastName, string Mail, string updateUserName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { UserID, UserName, Domain, UserDescription, PhoneNumber, FirstName, LastName, Mail, updateUserName };

            string spName = "rpc_updateUser";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet AuthenticateUserAgainstDB(Int64 userID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { userID };
            string spName = "rpc_GetUserAuthenticatedAgainstDB";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);

            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public void UpdateUserIDviaUserAD_special(string UserName, Int64 UserID, string FirstName, string LastName, string Email, string PhoneNumber)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { UserName, UserID, FirstName, LastName, Email, PhoneNumber };
            string spName = "rpc_updateUserViaAD";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void Insert_LogChange(int changeTypeID, Int64 updateUser, int deptCode, Int64? employeeID, int? deptEmployeeID, int? deptEmployeeServiceID, int? remarkID, int? serviceCode, string value)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { changeTypeID, updateUser, deptCode, employeeID, deptEmployeeID, deptEmployeeServiceID, remarkID, serviceCode, value };
            string spName = "rpc_Insert_LogChange";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public DataSet GetChangeTypes(string changeTypeSelected)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { changeTypeSelected };
            string spName = "rpc_GetChangeTypes";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetUpdateUser(string updateUserSelected)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { updateUserSelected };
            string spName = "rpc_GetUpdateUser";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            return FillDataSet(spName, ref outputParams, inputParams);
        }

    }

}
