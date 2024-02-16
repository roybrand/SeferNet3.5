using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Web;
using System.Data.SqlClient;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class QueueOrderMethodDB : Base.SqlDal
    {


        public QueueOrderMethodDB(string p_conString)
            : base(p_conString)
        {
        }

        public DataSet GetDicQueueOrderMethods()
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };
            DataSet ds;

            string spName = "rpc_getDicQueueOrderMethods";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetDicQueueOrderMethodsAndOptionsCombined(string selectedValues)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { selectedValues };
            DataSet ds;

            string spName = "rpc_getDicQueueOrderMethodsAndOptionsCombined";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }
        public DataSet GetDicQueueOrderMethodsAndOptionsCombinedByName(string searchStr)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { searchStr };
            DataSet ds;

            string spName = "rpc_getDicQueueOrderMethodsAndOptionsCombinedByName";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        #region Service Queue Order



        public void DeleteServiceQueueOrderMethod(int serviceCode, int deptCode)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptCode, serviceCode };

            string spName = "rpc_deleteServiceQueueOrderMethods";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);

            if (ErrorCode != 0)
            {
                switch (ErrorCode)
                {
                    case 2627: //duplicate key
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "IsAlreadyExists") as string;

                        break;

                    default:
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalInsertError") as string;

                        break;
                }

            }

        }
        
        public int InsertServiceQueueOrderHours(int queueOrderMethodID,int receptionDay,string fromHour,string toHour,
                                                                                                            string updateUserName)
        {
            int ErrorCode = 0;
            int count = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { 
                queueOrderMethodID,
		        receptionDay,
		        fromHour,
		        toHour,
                updateUserName};

            string spName = "rpc_insertServiceQueueOrderHours";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            count = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            ErrorCode = Convert.ToInt32(outputParams[0]);
            if (ErrorCode != 0)
            {
                switch (ErrorCode)
                {
                    case 2627: //duplicate key
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "IsAlreadyExists") as string;
                        break;

                    case 547: //Data constraint violation
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "ConstraintViolation") as string;
                        break;

                    default:
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalInsertError") as string;
                        break;
                }
            }
            return count;
        }

        #endregion

        #region Employee Queue Order

        public DataSet GetEmployeeInDeptQueueOrderMethods(int deptEmployeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEmployeeID };
            DataSet ds;

            string spName = "rpc_getEmployeeQueueOrderMethods";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeQueueOrderDescription(int deptCode, long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode };
            DataSet ds;

            string spName = "rpc_GetEmployeeQueueOrderDescription";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        /// <summary>
        /// insert new queue order method
        /// </summary>
        /// <param name="deptCode"></param>
        /// <param name="employeeID"></param>
        /// <param name="updateUser"></param>
        /// <param name="queueOrderMethod"></param>
        /// <returns>the new queue order method id</returns>
        public int InsertEmployeeQueueOrderMethod(int deptEmployeeID, int queueOrderMethod, string updateUser)
        {
            int ErrorCode = 0;
            int newID = 0;
            object[] outputParams = new object[] { ErrorCode, newID };
            object[] inputParams = new object[] { deptEmployeeID, queueOrderMethod, updateUser };


            string spName = "rpc_insertEmployeeQueueOrderMethod";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            newID = Convert.ToInt32(outputParams[1]);

            return newID;
        }

        public void InsertEmployeeQueueOrderHours(int queueOrderMethodID, int receptionDay, string fromHour, 
                                                                                                        string toHour, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { 
                queueOrderMethodID,
                receptionDay,
                fromHour,
                toHour,
                updateUser};

            ExecuteNonQuery("rpc_insertEmployeeQueueOrderHours", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            ErrorCode = Convert.ToInt32(outputParams[0]);
        }

        public void InsertDeptEmployeeQueueOrderPhone(int queueOrderMethodID, int prePrefix, int prefix, int phone, int extension, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { queueOrderMethodID, prePrefix, prefix, phone, extension, updateUser };

            ExecuteNonQuery("rpc_insertDeptEmployeeQueueOrderPhone", 
                                                Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }
        
        #endregion

        #region EmployeeServiceQueueOrder

        public DataSet GetEmployeeServiceQueueOrderDescription(int x_Dept_Employee_ServiceID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { x_Dept_Employee_ServiceID };
            DataSet ds;

            string spName = "rpc_GetEmployeeServiceQueueOrderDescription";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

       public DataSet GetEmployeeServiceQueueOrderMethods(int x_Dept_Employee_ServiceID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { x_Dept_Employee_ServiceID };
            DataSet ds;

            string spName = "rpc_getEmployeeServiceQueueOrderMethods";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void DeleteEmployeeServiceQueueOrderMethods(int x_Dept_Employee_ServiceID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { x_Dept_Employee_ServiceID };

            string spName = "rpc_DeleteEmployeeServiceQueueOrderMethods";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void UpdateEmployeeServiceQueueOrder(int x_Dept_Employee_ServiceID, int? queueOrder)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { x_Dept_Employee_ServiceID, queueOrder };

            ExecuteNonQuery("rpc_UpdateEmployeeServiceQueueOrder", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public int InsertEmployeeServiceQueueOrderMethod(int x_Dept_Employee_ServiceID, int queueOrderMethod, string updateUser)
        {
            int ErrorCode = 0;
            int newID = 0;
            object[] outputParams = new object[] { ErrorCode, newID };
            object[] inputParams = new object[] { x_Dept_Employee_ServiceID, queueOrderMethod, updateUser };


            string spName = "rpc_InsertEmployeeServiceQueueOrderMethod";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            newID = Convert.ToInt32(outputParams[1]);

            return newID;
        }

        public void InsertEmployeeServiceQueueOrderPhone(int employeeServiceQueueOrderMethodID, int prePrefix, int prefix, int phone, int extension, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { employeeServiceQueueOrderMethodID, prePrefix, prefix, phone, extension, updateUser };

            ExecuteNonQuery("rpc_InsertEmployeeServiceQueueOrderPhone",
                                                Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }


        public void InsertEmployeeServiceQueueOrderHours(int employeeServiceQueueOrderMethodID, int receptionDay, string fromHour,
                                                                                                        string toHour, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { 
                employeeServiceQueueOrderMethodID,
                receptionDay,
                fromHour,
                toHour,
                updateUser};

            ExecuteNonQuery("rpc_InsertEmployeeServiceQueueOrderHours", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            ErrorCode = Convert.ToInt32(outputParams[0]);
        }

        #endregion

        public void UpdateDeptEmployeeQueueOrder(int deptEmployeeID, int? queueOrder)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEmployeeID, queueOrder };

            ExecuteNonQuery("rpc_UpdateDeptEmployeeQueueOrder", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteDeptEmployeeQueueOrderMethods(int deptEmployeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEmployeeID };

            string spName = "rpc_DeleteDeptEmployeeQueueOrderMethods";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetDeptQueueOrderMethods(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };
            DataSet ds;

            string spName = "rpc_getDeptQueueOrderMethods";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public bool CheckIfQueueOrderEnabled(long employeeID, int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode };
            int ret = 0;


            string spName = "rpc_checkIfDeptEmployeeQueueOrderEnabled";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            DataSet ds = FillDataSet(spName, ref outputParams, inputParams);
            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                ret = (int)ds.Tables[0].Rows[0][0];
            }

            if (ret == 1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public void UpdateDeptQueueOrder(int deptCode, int selectedQueueOrderMethod)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, selectedQueueOrderMethod };


            string spName = "rpc_UpdateDeptQueueOrder";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void InsertDeptQueueOrderPhone(int queueOrderMethodID, int prePrefix, int prefix, int phone, int extension, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { queueOrderMethodID, prePrefix, prefix, phone, extension, updateUser };

            string spName = "rpc_insertDeptQueueOrderPhone";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            ErrorCode = Convert.ToInt32(outputParams[0]);
            if (ErrorCode != 0)
            {
                switch (ErrorCode)
                {
                    case 2627: //duplicate key
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "IsAlreadyExists") as string;
                        break;

                    case 547: //Data constraint violation
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "ConstraintViolation") as string;
                        break;

                    default:
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalInsertError") as string;
                        break;
                }
            }
        }

        public int InsertDeptQueueOrderHours(int queueOrderMethodID, int receptionDay, string fromHour, string toHour, string userName)
        {
            int ErrorCode = 0;
            int count = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { queueOrderMethodID, receptionDay, fromHour, toHour, userName};

            string spName = "rpc_insertDeptQueueOrderHours";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            count = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            ErrorCode = Convert.ToInt32(outputParams[0]);

            return count;
        }


        public int InsertDeptQueueOrderMethod(int deptCode, int queueOrderMethod, string updateUser)
        {
            int ErrorCode = 0;
            int QueueOrderMethodID = 0;
            object[] outputParams = new object[] { ErrorCode, QueueOrderMethodID };
            object[] inputParams = new object[] { deptCode, queueOrderMethod, updateUser };

            string spName = "rpc_insertDeptQueueOrderMethod";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            ErrorCode = Convert.ToInt32(outputParams[0]);
            QueueOrderMethodID = Convert.ToInt32(outputParams[1]);

            if (ErrorCode != 0)
            {
                switch (ErrorCode)
                {
                    case 2627: //duplicate key
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "RemarkLinkAlreadyExists") as string;
                        break;

                    default:
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalInsertError") as string;
                        break;
                }

            }

            return QueueOrderMethodID;
        }


        public int DeleteDeptQueueOrderMethods(int deptCode)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptCode };

            string spName = "rpc_deleteDeptQueueOrderMethods";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);

            if (ErrorCode != 0)
            {
                switch (ErrorCode)
                {
                    case 2627: //duplicate key
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "IsAlreadyExists") as string;
                        break;

                    default:
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalInsertError") as string;
                        break;
                }

            }

            return ErrorCode;
        }

        

        public int InsertServiceQueueOrderMethod(int serviceID, int deptCode, int selectedQueueOrder, string userName)
        {
            int ErrorCode = 0;
            int QueueOrderMethodID = 0;
            object[] outputParams = new object[] { ErrorCode, QueueOrderMethodID };
            object[] inputParams = new object[] { deptCode, serviceID, selectedQueueOrder, userName};

            string spName = "rpc_insertServiceQueueOrderMethod";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            ErrorCode = Convert.ToInt32(outputParams[0]);
            QueueOrderMethodID = Convert.ToInt32(outputParams[1]);

            return QueueOrderMethodID;            
        }

        public void InsertsServiceQueueOrderPhone(int queueOrderMethodID, int prePrefix, int prefix, int phone, int extension, string updateUser)
        {
            InsertsServiceQueueOrderPhone(null, queueOrderMethodID, prePrefix, prefix, phone, extension, updateUser);
        }

        public void InsertsServiceQueueOrderPhone(IDbTransaction trans, int queueOrderMethodID, int prePrefix, int prefix, int phone, int extension, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { queueOrderMethodID, prePrefix, prefix, phone, extension, updateUser };

            if (trans != null)
            {
                ExecuteNonQuery(trans, "rpc_insertServiceQueueOrderPhone", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            }
            else
            {
                string spName = "rpc_insertServiceQueueOrderPhone";
                DBActionNotification.RaiseOnDBInsert(spName, inputParams);
                ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            }

            ErrorCode = Convert.ToInt32(outputParams[0]);
            if (ErrorCode != 0)
            {
                switch (ErrorCode)
                {
                    case 2627: //duplicate key
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "IsAlreadyExists") as string;
                        break;

                    case 547: //Data constraint violation
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "ConstraintViolation") as string;
                        break;

                    default:
                        //HttpContext.Current.Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalInsertError") as string;
                        break;
                }
            }
        }
    }
}
