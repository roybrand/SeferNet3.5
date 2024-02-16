using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Web;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class PhoneDB : Base.SqlDal
    {
        public PhoneDB(string p_conString)
            : base(p_conString)
        {
        }

    #region DeptEventPhones

        public void DeleteDeptEventPhones(int deptEventID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { deptEventID };


            string spName = "rpc_deleteDeptEventPhones";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }       

        public void InsertDeptEventPhone(int deptEventID, int prePrefix, int prefix, int phone, int extension, string updateUser)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { deptEventID, prePrefix, prefix, phone, extension, updateUser };

            string spName = "rpc_insertDeptEventPhone";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }


    #endregion

    #region DeptEmployeePhones

        public DataSet GetDeptEmployeePhones(int deptEmployeeID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { deptEmployeeID };
            DataSet ds;

            string spName = "rpc_getDeptEmployeePhones";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void DeleteAllDeptEmployeePhones(int deptEmployeeID)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptEmployeeID };


            string spName = "rpc_DeleteAllDeptEmployeePhones";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }
        
        public int Update_x_Dept_Employee_PhonesInClinic( int deptCode )
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptCode };

            ExecuteNonQuery( "rpc_Update_x_Dept_Employee_PhonesInClinic", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
            return ErrorCode;
         }

        public void InsertDeptEmployeePhone(int deptEmployeeID, int phoneType, int prePrefix,
                                            int prefix, int phone, int extension, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptEmployeeID, phoneType, prePrefix, prefix, phone, extension, updateUser };

            string spName = "rpc_insertDeptEmployeePhone";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
        }

        public void UpdateEmplyeePhonesCascadeFromDept(int deptCode, int employeeID, int cascadeUpdateDeptEmployeePhonesFromClinic, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptCode, employeeID, cascadeUpdateDeptEmployeePhonesFromClinic, updateUser };

            string spName = "rpc_updateEmplyeePhonesCascadeFromDept";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);

        }

    #endregion

    #region EmployeePhones

        public void DeleteEmployeePhones(long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID };

            string spName = "rpc_deleteEmployeePhones";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public int InsertEmployeePhone(long employeeID, int phoneType, int phoneOrder, int prePrefix, int prefix, int phone, int extension, int isUnlisted, string updateUser)
        {
            int count = 0;

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { 
            employeeID,
	        phoneType,
            phoneOrder,
            prePrefix,
            prefix,
	        phone,
            extension,
            isUnlisted,
            updateUser};

            string spName = "rpc_insertEmployeePhone";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            count = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return count;
        }

    #endregion
    #region EmployeeServicePhones

        public DataSet GetEmployeeServicePhones(int? x_Dept_Employee_ServiceID, int? phoneType, bool? simulateCascadeUpdate)
        {
            object[] outputParams = new object[] {  };
            object[] inputParams = new object[] { x_Dept_Employee_ServiceID, phoneType, simulateCascadeUpdate };
            DataSet ds;

            string spName = "rpc_GetEmployeeServicePhones";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public int InsertEmployeeServicePhones(int x_Dept_Employee_ServiceID, int phoneType, int phoneOrder, int prePrefix, int prefix, int phone, int extension, string updateUser)
        {
            int count = 0;

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { 
	        x_Dept_Employee_ServiceID, 
	        phoneType,
	        phoneOrder,
	        prePrefix,
	        prefix,
	        phone,
	        extension,
	        updateUser};

            if (prePrefix == -1)
                inputParams[3] = null;
            if (extension == -1)
                inputParams[6] = null;

            string spName = "rpc_InsertEmployeeServicePhones";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            count = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return count;
        }

        public void DeleteEmployeeServicePhones(int? x_Dept_Employee_ServiceID, int? phoneType)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { x_Dept_Employee_ServiceID, phoneType };


            string spName = "rpc_DeleteEmployeeServicePhones";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void Update_x_Dept_Employee_Service_CascadeUpdatePhones(int x_Dept_Employee_ServiceID, bool CascadeUpdatePhones)
        {

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { x_Dept_Employee_ServiceID, CascadeUpdatePhones };

            string spName = "rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones";           
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
         }

    #endregion
        #region DeptServicePhone

        

    

    #endregion

    #region DeptPhone

    public DataSet GetDeptPhones(int deptCode, int phoneType)
    {
        object[] outputParams = new object[1] { new object() };
        object[] inputParams = new object[] { deptCode, phoneType };
        DataSet ds;

        string spName = "rpc_getDeptPhones";
        DBActionNotification.RaiseOnDBSelect(spName, inputParams);
        ds = FillDataSet(spName, ref outputParams, inputParams);

        return ds;
    }

    public DataSet GetDeptMainPhones(int deptCode, int phoneType)
    {
        object[] outputParams = new object[1] { new object() };
        object[] inputParams = new object[] { deptCode, phoneType };
        DataSet ds;

        string spName = "rpc_GetDeptMainPhones";
        DBActionNotification.RaiseOnDBSelect(spName, inputParams);
        ds = FillDataSet(spName, ref outputParams, inputParams);

        return ds;
    }

    public DataSet GetDeptFirstPhone(int deptCode)
    {
        object[] outputParams = new object[1] { new object() };
        object[] inputParams = new object[] { deptCode };
        DataSet ds;

        string spName = "rpc_getDeptFirstPhone";
        DBActionNotification.RaiseOnDBSelect(spName, inputParams);
        ds = FillDataSet(spName, ref outputParams, inputParams);

        return ds;
    }

    public DataSet GetDeptPhoneForUpdate(int deptPhoneID)
    {
        object[] outputParams = new object[1] { new object() };
        object[] inputParams = new object[] { deptPhoneID };
        DataSet ds;

        string spName = "rpc_getDeptPhoneByID";
        DBActionNotification.RaiseOnDBSelect(spName, inputParams);
        ds = FillDataSet(spName, ref outputParams, inputParams);

        return ds;
    }

    public int InsertDeptPhone(IDbTransaction trans, int deptCode, int phoneType, int phoneOrder,
        int prePrefix, int prefix, int phone, int extension, string remark, string updateUser)
    {
        int ErrorCode = 0;
        int count = 0;

        object[] outputParams = new object[1] { ErrorCode };
        object[] inputParams = new object[] { 
                deptCode,	
                phoneType,
	            phoneOrder,
                prePrefix,
		        prefix,
		        phone,
                extension,
                remark,
                updateUser};


        count = ExecuteNonQuery(trans, "rpc_insertDeptPhone", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        ErrorCode = Convert.ToInt32(outputParams[0]);

        return count;
    }

    public int InsertDeptPhonesForNewDept(int deptCode, string updateUser)
    {
        int ErrorCode = 0;

        object[] outputParams = new object[1] { ErrorCode };
        object[] inputParams = new object[] { deptCode, updateUser };

        ExecuteNonQuery("rpc_insertDeptPhonesForNewDept", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        ErrorCode = Convert.ToInt32(outputParams[0]);

        return ErrorCode;

    }

    public int InsertDeptPhone(int deptCode, int phoneType, int phoneOrder,
        int prePrefix, int prefix, int phone, int extension, string remark, string updateUser)
    {
        int ErrorCode = 0;
        int count = 0;

        object[] outputParams = new object[1] { ErrorCode };
        object[] inputParams = new object[] { 
                deptCode,	
                phoneType,
	            phoneOrder,
                prePrefix,
		        prefix,
		        phone,
                extension,
                remark,
                updateUser};

        string spName = "rpc_insertDeptPhone";
        DBActionNotification.RaiseOnDBInsert(spName, inputParams);
        count = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        ErrorCode = Convert.ToInt32(outputParams[0]);

        return count;
    }

    public int InsertDeptPhoneForSubClinics(int deptCode, int phoneType, int phoneOrder,
        int prePrefix, int prefix, int phone, int extension, string updateUser)
    {
        int ErrorCode = 0;
        int count = 0;

        object[] outputParams = new object[1] { ErrorCode };
        object[] inputParams = new object[] { 
                deptCode,	
                phoneType,
	            phoneOrder,
                prePrefix,
		        prefix,
		        phone,
                extension,
                updateUser};

        count = ExecuteNonQuery("rpc_insertDeptPhoneForSubClinics", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        ErrorCode = Convert.ToInt32(outputParams[0]);

        return count;
    }

    public int DeleteDeptPhones(int deptCode)
    {
        int ErrorCode = 0;
        object[] outputParams = new object[1] { ErrorCode };
        object[] inputParams = new object[] { deptCode };

        ExecuteNonQuery("rpc_deleteDeptPhones", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        return Convert.ToInt32(outputParams[0]);
    }

    public int DeleteDeptPhonesForSubClinics(int deptCode)
    {
        int ErrorCode = 0;
        object[] outputParams = new object[1] { ErrorCode };
        object[] inputParams = new object[] { deptCode };

        ExecuteNonQuery("rpc_deleteDeptPhonesForSubClinics", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        return Convert.ToInt32(outputParams[0]);
    }

    #endregion

    #region DIC_PhonePrefix

        public DataSet getPhonePrefixListAll()
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[0] {};

            string spName = "rpc_getPhonePrefixListAll";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public int DeletePhonePrefix(int p_prefixCode)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[1] { ErrorCode };
            object[] inputParams = new object[] { p_prefixCode };

            string spName = "rpc_deleteDIC_PhonePrefix";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return Convert.ToInt32(outputParams[0]);
        }

        public int InsertPhonePrefix(ref int ErrorCode, string p_prefixValue, int p_phoneType)
        {
            int PrefixCodeInserted = 0;
            object[] outputParams = new object[] { ErrorCode, PrefixCodeInserted };
            object[] inputParams = new object[] { p_prefixValue, p_phoneType };
            string spName = "rpc_insertDIC_PhonePrefix";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return Convert.ToInt32(outputParams[1]);
        }

        public void UpdatePhonePrefix(int p_prefixCode, string p_prefixValue, int p_phoneType)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { p_prefixCode, p_prefixValue, p_phoneType };
            string spName = "rpc_updateDIC_PhonePrefix";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

    #endregion

    }
}
