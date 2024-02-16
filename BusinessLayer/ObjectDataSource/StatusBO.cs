using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using SeferNet.DataLayer;
using System.Transactions;
using SeferNet.Globals;
using System.Data.SqlClient;
using System.Collections;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    public class StatusBO
    {
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
        /// select method
        /// </summary>
        /// <param name="searchFilter">The parameter used to filter the data with</param>
        /// <returns>System.Data.Dataset</returns>
        public DataSet GetDeptStatus(int deptCode)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetDeptStatus(deptCode);
        }
        
        public DataSet GetDeptStatusByID(int statusID)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetDeptStatusByID(statusID);
        }

        public void InsertDeptStatus(int deptCode, int status, DateTime fromDate, DateTime toDate, string updateUser)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.InsertDeptStatus(deptCode, status, fromDate, toDate, updateUser);
        }

        public DateTime? GetClosestNotActiveStatusDate(int deptCode)
        {
            ClinicDB clinicDB = new ClinicDB();
            DateTime? date = null;

            DataSet ds = clinicDB.GetClosestNotActiveDate(deptCode, DateTime.Now);
            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                date = Convert.ToDateTime(ds.Tables[0].Rows[0][0]);
            }
            return date;
        }

        

        public int UpdateDeptStatus(int deptCode, DataTable statusDt, string userName)
        {
            ClinicDB clinicdb = new ClinicDB();
            DateTime? toDate = null;
            int currentStatus = -1;

            using (TransactionScope trans = TranscationScopeFactory.GetForUpdatedRecords())
            {
                clinicdb.DeleteDeptStatuses(deptCode);

                //  insert into "DeptStatus"
                for (int i = 0; i < statusDt.Rows.Count; i++)
                {
                    toDate = null;

                    if (!string.IsNullOrEmpty(statusDt.Rows[i]["ToDate"].ToString()))
                    {
                        toDate = (DateTime)statusDt.Rows[i]["ToDate"];
                    }

                    clinicdb.InsertDeptStatus(deptCode, Convert.ToInt32(statusDt.Rows[i]["Status"]),
                                                    Convert.ToDateTime(statusDt.Rows[i]["FromDate"]), toDate, userName);
                }

                currentStatus = clinicdb.UpdateDeptStatus(deptCode, userName);

                trans.Complete();
                trans.Dispose();
            }

            return currentStatus;
        }

        public void UpdateEmployeeStatusInDept(long employeeID, int deptCode, int agreementType, DataTable statusDt, string updateUser)
        {
            DateTime fromDate;
            DateTime? toDate;
            int status;

            DoctorDB dal = new DoctorDB();

            // delete all employee statuses
            dal.DeleteEmployeeStatusInDept(employeeID, deptCode, agreementType);

            // insert the new statuses
            for (int i = 0; i < statusDt.Rows.Count; i++)
            {
                toDate = null;
                fromDate = Convert.ToDateTime(statusDt.Rows[i]["fromDate"]);
                status = Convert.ToInt32(statusDt.Rows[i]["status"]);

                if (statusDt.Rows[i]["toDate"] != DBNull.Value)
                {
                    toDate = Convert.ToDateTime(statusDt.Rows[i]["toDate"]);
                }

                if (fromDate.Date == DateTime.Now.Date || (fromDate.Date < DateTime.Now.Date && toDate == null))
                {
                    UpdateEmployeeInDeptCurrentStatus(employeeID, deptCode, agreementType, status, toDate, updateUser);

                    Enums.Status newStatus = (Enums.Status)Enum.Parse(typeof(Enums.Status),status.ToString());

                    // delete receptions, reset queue order, and delete queue order methods if employee became not active
                    if (newStatus == Enums.Status.NotActive)
                    {
                        dal.DeleteEmployeeReceptionInDept(employeeID, deptCode, agreementType);
                    }
                }

                dal.InsertEmployeeStatusInDept(employeeID, deptCode, agreementType, status, fromDate, toDate, updateUser);
            }

        }

        public void UpdateEmployeeInDeptCurrentStatus(long employeeID, int deptCode, int agreementType, int status, DateTime? toDate, string updateUser)
        {
            DoctorDB dal = new DoctorDB();

            dal.UpdateEmployeeInDeptCurrentStatus(employeeID, deptCode, agreementType, status, toDate, updateUser);
        }

        public void UpdateEmployeeInDeptCurrentStatusByDeptEmployeeID(int deptEmployeeID, int status, string updateUser)
        {
            DoctorDB dal = new DoctorDB();

            dal.UpdateEmployeeInDeptCurrentStatusByDeptEmployeeID(deptEmployeeID, status, updateUser);
        }

        public void UpdateEmployeeInDeptStatusWhenNoProfessions(long employeeID, int deptCode, string updateUser)
        {
            DoctorDB dal = new DoctorDB();

            dal.UpdateEmployeeInDeptStatusWhenNoProfessions(employeeID, deptCode, updateUser);
        }

        public void UpdateEmployeeStatus(long employeeID, DataTable statusDt, string updateUser)
        {
            if (statusDt != null)
            {
                DateTime fromDate;
                DateTime? toDate;
                int status = 0;
                DoctorDB doctorDB = new DoctorDB();


                using (TransactionScope trans = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    doctorDB.DeleteEmployeeStatus(employeeID);

                    // insert the new statuses
                    for (int i = 0; i < statusDt.Rows.Count; i++)
                    {
                        toDate = null;
                        fromDate = Convert.ToDateTime(statusDt.Rows[i]["fromDate"]);
                        status = Convert.ToInt32(statusDt.Rows[i]["status"]);

                        if (statusDt.Rows[i]["toDate"] != DBNull.Value)
                        {
                            toDate = Convert.ToDateTime(statusDt.Rows[i]["toDate"]);
                        }

                        // status need to be updated now
                        if ((fromDate.Date == DateTime.Now.Date) || (fromDate.Date < DateTime.Now.Date && toDate == null))
                        {
                            UpdateEmployeeCurrentStatus(employeeID, status, updateUser);
                        }

                        doctorDB.InsertEmployeeStatus(employeeID, status, fromDate, toDate, updateUser);
                    }

                    trans.Complete();
                    trans.Dispose();
                }
            }
        }

        public void UpdateEmployeeCurrentStatus(long employeeID, int status, string updateUser)
        {
            DoctorDB dal = new DoctorDB();

            dal.UpdateEmployeeCurrentStatus(employeeID, status, updateUser);
        }

        public void UpdateDeptServiceStatus(int deptCode, int serviceCode, long employeeID, DataTable statusDt, string userName)
        {
            if (statusDt != null)
            {
                DateTime fromDate;
                DateTime? toDate;
                int status = 0;
                ClinicDB dal = new ClinicDB();

                using (TransactionScope trans = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    dal.DeleteDeptServiceStatus(deptCode, serviceCode, employeeID);

                    // insert the new statuses
                    for (int i = 0; i < statusDt.Rows.Count; i++)
                    {
                        toDate = null;
                        fromDate = Convert.ToDateTime(statusDt.Rows[i]["fromDate"]);
                        status = Convert.ToInt32(statusDt.Rows[i]["status"]);

                        if (statusDt.Rows[i]["toDate"] != DBNull.Value)
                        {
                            toDate = Convert.ToDateTime(statusDt.Rows[i]["toDate"]);
                        }

                        

                        dal.InsertDeptServiceStatus(deptCode, serviceCode, employeeID, status, fromDate, toDate, userName);
                    }

                    trans.Complete();
                    trans.Dispose();
                }
            }
        }

        

        public DataSet GetDeptServiceStatus(int deptCode, int serviceCode, long employeeID)
        {
            ClinicDB dal = new ClinicDB();

            return dal.GetAllDeptServiceStatuses(deptCode, serviceCode, employeeID);
        }

        public DataSet GetEmployeeStatus(long employeeID)
        {
            DoctorDB dal = new DoctorDB();

            return dal.GetAllEmployeeStatuses(employeeID);
        }

        public DataSet GetEmployeeInDeptStatus(long employeeID, int deptCode)
        {
            DoctorDB dal = new DoctorDB();

            return dal.GetAllEmployeeStatusesInDept(employeeID, deptCode);
        }

        public DataSet GetEmployeeServiceInDeptStatus(long employeeID, int deptCode, int serviceCode)
        {
            DoctorDB dal = new DoctorDB();

            return dal.GetEmployeeServiceInDeptStatus(employeeID, deptCode, serviceCode);
        }

        public int GetCurrentEmployeeServiceInDeptStatus(long employeeID, int deptCode, int serviceCode)
        {
            DoctorDB dal = new DoctorDB();

            DataSet ds = dal.GetCurrentEmployeeServiceInDeptStatus(employeeID, deptCode, serviceCode);

            return Convert.ToInt32(ds.Tables[0].Rows[0]["Status"]);
        }

        public void UpdateEmployeeServiceInDeptStatus(long employeeID, int deptCode, int serviceCode, DataTable statusDt, string userName)
        {
            if (statusDt != null)
            {
                DateTime fromDate;
                DateTime? toDate;
                int status = 0;
                DoctorDB dal = new DoctorDB();

                dal.DeleteEmployeeServiceInDeptStatus(employeeID, deptCode, serviceCode);

                // insert the new statuses
                for (int i = 0; i < statusDt.Rows.Count; i++)
                {
                    toDate = null;
                    fromDate = Convert.ToDateTime(statusDt.Rows[i]["fromDate"]);
                    status = Convert.ToInt32(statusDt.Rows[i]["status"]);

                    if (statusDt.Rows[i]["toDate"] != DBNull.Value)
                    {
                        toDate = Convert.ToDateTime(statusDt.Rows[i]["toDate"]);
                    }

                    // status need to be updated now
                    if ((fromDate.Date <= DateTime.Now.Date) && (toDate == null || toDate.Value.Date > DateTime.Now.Date))
                    {
                        UpdateEmployeeServiceInDeptCurrentStatus(employeeID, deptCode, serviceCode, status, userName);
                    }

                    dal.InsertEmployeeServiceInDeptStatus(employeeID, deptCode, serviceCode, status, fromDate, toDate, userName);
                }

            }
        }

        private void UpdateEmployeeServiceInDeptCurrentStatus(long employeeID, int deptCode, int serviceCode, int status, string userName)
        {
            DoctorDB dal = new DoctorDB();

            dal.UpdateEmployeeServiceInDeptCurrentStatus(employeeID, deptCode, serviceCode, status, userName);
        }
    }
}
