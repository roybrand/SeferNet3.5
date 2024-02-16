using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
using System.ComponentModel;
using SeferNet.DataLayer;
using System.Globalization;
using SeferNet.BusinessLayer.BusinessObject;
using System.Transactions;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class QueueOrderMethodBO
    {

        /// <summary>
        /// private field for conn property
        /// </summary>
        private SqlConnection _conn;
        /// <summary>
        /// Propery to hold our SQL connection
        /// </summary>
        private SqlConnection conn
        {
            get
            {
                if (_conn == null)
                    _conn = new SqlConnection(ConnectionHandler.ResolveConnStrByLang());

                return _conn;
            }
        }


        /// <summary>
        /// returns two dataTables: 1. queue orders  2. queue order methods
        /// </summary>
        /// <returns></returns>
        public DataSet GetDicQueueOrderMethods()
        {
            QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);
            DataSet ds = dal.GetDicQueueOrderMethods();
            ds.Tables[0].TableName = "QueueOrder";
            ds.Tables[1].TableName = "QueueOrderMethods";
            return ds;
        }

        public DataSet GetDicQueueOrderMethodsAndOptionsCombined(string selectedValues)
        {
            QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);
            DataSet ds = dal.GetDicQueueOrderMethodsAndOptionsCombined(selectedValues);
            return ds;
        }
        public DataSet GetDicQueueOrderMethodsAndOptionsCombinedByName(string searchStr)
        {
            QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);
            DataSet ds = dal.GetDicQueueOrderMethodsAndOptionsCombinedByName(searchStr);
            return ds;
        }

        #region Dept Queue Order

        public DataSet GetDeptQueueOrderMethods(int DeptCode)
        {
            QueueOrderMethodDB queueOrderMethoddb = new QueueOrderMethodDB(conn.ConnectionString);
            return queueOrderMethoddb.GetDeptQueueOrderMethods(DeptCode);
        }

        public void UpdateDeptQueueOrderMethods(int deptCode, int selectedQueueOrderMethod, DataSet methodsDs, string userName)
        {
            SqlTransaction trans = null;
            int queueOrderMethodID = 0;
            try
            {

                QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);

                conn.Open();
                trans = conn.BeginTransaction();

                dal.DeleteDeptQueueOrderMethods(deptCode);

                dal.UpdateDeptQueueOrder(deptCode, selectedQueueOrderMethod);

                DataTable methodsDt = methodsDs.Tables["methods"];

                for (int i = 0; i < methodsDt.Rows.Count; i++)
                {
                    DataRow row = methodsDt.Rows[i];

                    queueOrderMethodID = dal.InsertDeptQueueOrderMethod(deptCode, Convert.ToInt32(row["QueueOrderMethod"]), userName);

                    if (row["phone"] != DBNull.Value)
                    {
                        Phone phone = new Phone(row);
                        dal.InsertDeptQueueOrderPhone(queueOrderMethodID, phone.PrePrefix, phone.PreFix, phone.PhoneNumber, phone.Extension, userName);
                    }
                }

                DataTable hoursDt = methodsDs.Tables["hours"];
                if (hoursDt != null && hoursDt.Rows.Count > 0 && queueOrderMethodID != 0)
                {
                    for (int i = 0; i < hoursDt.Rows.Count; i++)
                    {
                        int receptionDay = Convert.ToInt32(hoursDt.Rows[i]["receptionDay"]);
                        string fromHour = hoursDt.Rows[i]["openingHour"].ToString();
                        string toHour = hoursDt.Rows[i]["closingHour"].ToString();

                        dal.InsertDeptQueueOrderHours(queueOrderMethodID, receptionDay, fromHour, toHour, userName);
                    }
                }

                trans.Commit();
            }
            catch (Exception ex)
            {
                trans.Rollback();
            }
            finally
            {
                if (conn != null)
                {
                    conn.Close();
                }
            }
        }

        #endregion

        #region ServiceQueueOrder

        

        public void UpdateServiceQueueOrderMethods(int serviceID, int deptCode, int selectedQueueOrderMethod, DataSet ds, string userName)
        {
            SqlTransaction trans = null;
            int queueOrderMethodID = 0;
            try
            {

                QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);

                conn.Open();
                trans = conn.BeginTransaction();

                dal.DeleteServiceQueueOrderMethod(serviceID, deptCode);

                

                DataTable methodsDt = ds.Tables["methods"];

                for (int i = 0; i < methodsDt.Rows.Count; i++)
                {
                    DataRow row = methodsDt.Rows[i];

                    queueOrderMethodID = dal.InsertServiceQueueOrderMethod(serviceID, deptCode, Convert.ToInt32(row["QueueOrderMethod"]), userName);

                    if (row["phone"] != DBNull.Value)
                    {
                        Phone phone = new Phone(row);
                        dal.InsertsServiceQueueOrderPhone(queueOrderMethodID, phone.PrePrefix, phone.PreFix, phone.PhoneNumber, phone.Extension, userName);
                    }
                }

                DataTable hoursDt = ds.Tables["hours"];
                if (hoursDt != null && hoursDt.Rows.Count > 0 && queueOrderMethodID != 0)
                {
                    for (int i = 0; i < hoursDt.Rows.Count; i++)
                    {
                        int receptionDay = Convert.ToInt32(hoursDt.Rows[i]["receptionDay"]);
                        string fromHour = hoursDt.Rows[i]["openingHour"].ToString();
                        string toHour = hoursDt.Rows[i]["closingHour"].ToString();

                        InsertServiceQueueOrderHours(queueOrderMethodID, receptionDay, fromHour, toHour, userName);
                    }
                }

                trans.Commit();
            }
            catch (Exception ex)
            {
                trans.Rollback();
            }
            finally
            {
                if (conn != null)
                {
                    conn.Close();
                }
            }
        }

        public void InsertServiceQueueOrderHours(int queueOrderMethodID, int receptionDay, string fromHour, string toHour,
                                                                                                            string updateUserName)
        {
            QueueOrderMethodDB queueOrderMethoddb = new QueueOrderMethodDB(conn.ConnectionString);
            queueOrderMethoddb.InsertServiceQueueOrderHours(queueOrderMethodID, receptionDay, fromHour, toHour, updateUserName);
        }

        #endregion

        #region EmployeeQueueOrder

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployeeInDeptQueueOrderMethods(int deptEmployeeID)
        {
            QueueOrderMethodDB queueOrderMethoddb = new QueueOrderMethodDB(conn.ConnectionString);
            return queueOrderMethoddb.GetEmployeeInDeptQueueOrderMethods(deptEmployeeID);
        }


        public DataSet GetEmployeeQueueOrderDescription(int deptCode, long employeeID)
        {
            QueueOrderMethodDB queueOrderMethoddb = new QueueOrderMethodDB(conn.ConnectionString);
            return queueOrderMethoddb.GetEmployeeQueueOrderDescription(deptCode, employeeID);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertEmployeeQueueOrderMethod(int deptEmployeeID, int queueOrderMethod, string updateUser)
        {
            QueueOrderMethodDB queueOrderMethoddb = new QueueOrderMethodDB(conn.ConnectionString);

            queueOrderMethoddb.InsertEmployeeQueueOrderMethod(deptEmployeeID, queueOrderMethod, updateUser);
        }


        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertEmployeeQueueOrderHours(int queueOrderMethodID, int receptionDay, string fromHour,
                                                                                                    string toHour, string updateUser)
        {
            QueueOrderMethodDB queueOrderMethodDB = new QueueOrderMethodDB(conn.ConnectionString);

            queueOrderMethodDB.InsertEmployeeQueueOrderHours(queueOrderMethodID, receptionDay, fromHour, toHour, updateUser);
        }

        public void UpdateDeptEmployeeQueueOrder(int deptEmployeeID, int? queueOrder)
        {
            QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);
            
            dal.UpdateDeptEmployeeQueueOrder(deptEmployeeID, queueOrder);
        }

        public bool UpdateEmployeeQueueOrderMethods(int deptEmployeeID, int queueOrder, DataSet methodsDs, string updateUser)
        {
            int queueOrderMethodID = 0;
            try
            {
                using (TransactionScope trans = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);

                    dal.DeleteDeptEmployeeQueueOrderMethods(deptEmployeeID);

                    dal.UpdateDeptEmployeeQueueOrder(deptEmployeeID, queueOrder);

                    DataTable methodsDt = methodsDs.Tables["methods"];

                    for (int i = 0; i < methodsDt.Rows.Count; i++)
                    {
                        DataRow row = methodsDt.Rows[i];

                        queueOrderMethodID = dal.InsertEmployeeQueueOrderMethod(deptEmployeeID, Convert.ToInt32(row["QueueOrderMethod"]),
                                                                                                                                    updateUser);

                        if (row["phone"] != DBNull.Value)
                        {
                            Phone phone = new Phone(row);
                            dal.InsertDeptEmployeeQueueOrderPhone(queueOrderMethodID, phone.PrePrefix, phone.PreFix, phone.PhoneNumber, phone.Extension, updateUser);
                        }
                    }

                    DataTable hoursDt = methodsDs.Tables["hours"];
                    if (hoursDt != null && hoursDt.Rows.Count > 0 && queueOrderMethodID != 0)
                    {
                        for (int i = 0; i < hoursDt.Rows.Count; i++)
                        {
                            int receptionDay = Convert.ToInt32(hoursDt.Rows[i]["receptionDay"]);
                            string fromHour = hoursDt.Rows[i]["openingHour"].ToString();
                            string toHour = hoursDt.Rows[i]["closingHour"].ToString();

                            InsertEmployeeQueueOrderHours(queueOrderMethodID, receptionDay, fromHour, toHour, updateUser);
                        }
                    }
                    trans.Complete();
                    trans.Dispose();
                }
            }
            catch (Exception ex)
            {
                return false;
            }
            
            return true;
        }

        public void DeleteQueueOrderMethodsForEmployee(int deptEmployeeID)
        {
            QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);
            dal.DeleteDeptEmployeeQueueOrderMethods(deptEmployeeID);
        }

        public bool CheckIfQueueOrderEnabled(long employeeID, int deptCode)
        {
            QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);
            return dal.CheckIfQueueOrderEnabled(employeeID, deptCode);
        }

        #endregion

        #region EmployeeServiceQueueOrder

        public DataSet GetEmployeeServiceQueueOrderDescription(int x_Dept_Employee_ServiceID)
        {
            QueueOrderMethodDB queueOrderMethoddb = new QueueOrderMethodDB(conn.ConnectionString);
            return queueOrderMethoddb.GetEmployeeServiceQueueOrderDescription(x_Dept_Employee_ServiceID);
        }

        public DataSet GetEmployeeServiceQueueOrderMethods(int x_Dept_Employee_ServiceID)
        {
            QueueOrderMethodDB queueOrderMethoddb = new QueueOrderMethodDB(conn.ConnectionString);
            return queueOrderMethoddb.GetEmployeeServiceQueueOrderMethods(x_Dept_Employee_ServiceID);
        }

        public void UpdateEmployeeServiceQueueOrderMethods(int x_Dept_Employee_ServiceID, int queueOrder, DataSet methodsDs, string updateUser)
        {
            int employeeServiceQueueOrderMethodID = 0;

            using (TransactionScope trans = TranscationScopeFactory.GetForInsertedRecords())
            {
                QueueOrderMethodDB dal = new QueueOrderMethodDB(conn.ConnectionString);

                dal.DeleteEmployeeServiceQueueOrderMethods(x_Dept_Employee_ServiceID);

                dal.UpdateEmployeeServiceQueueOrder(x_Dept_Employee_ServiceID, queueOrder);

                DataTable methodsDt = methodsDs.Tables["methods"];

                for (int i = 0; i < methodsDt.Rows.Count; i++)
                {
                    DataRow row = methodsDt.Rows[i];

                    employeeServiceQueueOrderMethodID = dal.InsertEmployeeServiceQueueOrderMethod(x_Dept_Employee_ServiceID, Convert.ToInt32(row["QueueOrderMethod"]),
                                                                                                                                updateUser);
                    if (row["phone"] != DBNull.Value)
                    {
                        Phone phone = new Phone(row);
                        dal.InsertEmployeeServiceQueueOrderPhone(employeeServiceQueueOrderMethodID, phone.PrePrefix, phone.PreFix, phone.PhoneNumber, phone.Extension, updateUser);
                    }
                }

                DataTable hoursDt = methodsDs.Tables["hours"];
                if (hoursDt != null && hoursDt.Rows.Count > 0 && employeeServiceQueueOrderMethodID != 0)
                {
                    for (int i = 0; i < hoursDt.Rows.Count; i++)
                    {
                        int receptionDay = Convert.ToInt32(hoursDt.Rows[i]["receptionDay"]);
                        string fromHour = hoursDt.Rows[i]["openingHour"].ToString();
                        string toHour = hoursDt.Rows[i]["closingHour"].ToString();

                        InsertEmployeeServiceQueueOrderHours(employeeServiceQueueOrderMethodID, receptionDay, fromHour, toHour, updateUser);
                    }
                }
                trans.Complete();
                trans.Dispose();
            }
        }

        public void InsertEmployeeServiceQueueOrderHours(int employeeServiceQueueOrderMethodID, int receptionDay, string fromHour,
                                                                                                    string toHour, string updateUser)
        {
            QueueOrderMethodDB queueOrderMethodDB = new QueueOrderMethodDB(conn.ConnectionString);

            queueOrderMethodDB.InsertEmployeeServiceQueueOrderHours(employeeServiceQueueOrderMethodID, receptionDay, fromHour, toHour, updateUser);
        }

        #endregion
    }            
}
