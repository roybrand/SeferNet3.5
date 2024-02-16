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
using SeferNet.BusinessLayer.WorkFlow;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class EmployeeServiceInDeptBO
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

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployeeServicesForDept(int employeeID, int deptCode)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetEmployeeServicesForDept(employeeID, deptCode);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteDeptEmployeeService(int deptEmployeeID, int serviceCode)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.DeleteDeptEmployeeService(deptEmployeeID, serviceCode);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertDeptEmployeeService(int deptEmployeeID, string serviceCodes, string updateUser)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.InsertDeptEmployeeService(deptEmployeeID, serviceCodes, updateUser);
        }


        public DataSet GetEmployeeServicesExtended(int m_empCode, int m_deptCode, int deptEmployeeID, bool IsLinkedToEmployeeOnly, bool? isService)
        {
            ClinicDB dal = new ClinicDB();
            return dal.GetEmployeeServicesExtended(m_empCode, m_deptCode, deptEmployeeID, IsLinkedToEmployeeOnly, isService);
        }

        public DataSet GetEmployeeServicesInDept(int deptEmployeeID)
        {
            ClinicDB dal = new ClinicDB();
            return dal.GetEmployeeServicesInDept(deptEmployeeID);
        }

        public void UpdateEmployeeServicesInDept(int deptEmployeeID, string seperatedValues, string userName)
        {
            SqlTransaction trans = null;

            try
            {
                ClinicDB dal = new ClinicDB();
                EmployeeServicesBO servicesBO = new EmployeeServicesBO();

                conn.Open();
                trans = conn.BeginTransaction();

                if (!string.IsNullOrEmpty(seperatedValues))
                {
                    dal.InsertDeptEmployeeService(deptEmployeeID, seperatedValues, userName);
                }
                else
                {
                    // delete queue order in dept, if there are no professions neither
                    QueueOrderMethodBO bo = new QueueOrderMethodBO();
                    EmployeeProfessionInDeptBO profBO = new EmployeeProfessionInDeptBO();
                    DataSet ds = profBO.GetEmployeeProfessionsInDept(deptEmployeeID);
                    if (ds.Tables[0].Rows.Count == 0)
                    {
                        bo.DeleteQueueOrderMethodsForEmployee(deptEmployeeID);
                    }
                }
               
                trans.Commit();
            }
            catch (Exception ex)
            {
                if (conn != null)
                    conn.Close();

                if (trans != null)
                    trans.Rollback();

            }
        }

        public DataSet GetEmployeeServicesForPopUp(int m_employeeID, int m_deptCode)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetEmployeeServicesForPopUp(m_employeeID, m_deptCode);
        }

        public bool InsertDeptEmployeeServiceRemark(int deptEmployeeID, int serviceCode, 
                        int remarkID, string remarkText, DateTime dateFrom, DateTime? dateTo, DateTime? activeFrom, bool displayOnInternet, string userName)
        {
            bool result = false;
            SqlTransaction trans = null;

            try
            {
                DoctorDB dal = new DoctorDB();
                conn.Open();
                trans = conn.BeginTransaction();

                if (dateTo == DateTime.MinValue)
                    dateTo = Convert.ToDateTime("1/1/1900");

                //DeleteDeptEmployeeServiceRemark(trans, deptEmployeeID, serviceCode);


                dal.InsertDeptEmployeeServiceRemark(trans, deptEmployeeID, serviceCode, remarkID,
                                                    remarkText, dateFrom, dateTo, activeFrom, displayOnInternet, userName);

                trans.Commit();
            }
            catch
            {
                if (trans != null)
                {
                    trans.Rollback();
                }
                result = false;
            }
            finally
            {
                if (conn != null)
                {
                    conn.Close();
                }
                result = true;
            }

            return result;
        }

        public void DeleteDeptEmployeeServiceRemark(IDbTransaction trans, int deptEmployeeID, int serviceCode)
        {
            DoctorDB dal = new DoctorDB();

            dal.DeleteEmployeeServiceRemark(trans, deptEmployeeID, serviceCode);
        }

        public void DeleteDeptEmployeeServiceRemarkByRemarkID(int remarkID)
        {
            DoctorDB dal = new DoctorDB();

            dal.DeleteDeptEmployeeServiceRemarkByRemarkID(remarkID);
        }

        public DataSet GetDeptEmployeeServiceRemark(int RemarkID)
        {
            DoctorDB dal = new DoctorDB();

            return dal.GetDeptEmployeeServiceRemark(RemarkID);
        }


        public void CascadeEmployeeServiceQueueOrderFromDept(int x_Dept_Employee_ServiceID)
        {
            DoctorDB dal = new DoctorDB();
            UserManager man = new UserManager();

            dal.CascadeEmployeeServiceQueueOrderFromDept(x_Dept_Employee_ServiceID, man.GetUserNameForLog());
        }

        #region Medical Aspects

        public DataSet GetMedicalAspects(int? deptCode, bool isLinkedToDept, bool? isService)
        {
            ClinicDB dal = new ClinicDB();
            return dal.GetMedicalAspects(deptCode, isLinkedToDept, isService);
        }

        public DataSet GetServicesForMedicalAspects(int deptCode, string services)
        {
            ClinicDB dal = new ClinicDB();
            return dal.GetServicesForMedicalAspects(deptCode, services);
        }

        #endregion
    }
}
