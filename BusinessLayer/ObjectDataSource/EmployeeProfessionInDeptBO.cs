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

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class EmployeeProfessionInDeptBO
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

        //[DataObjectMethod(DataObjectMethodType.Select)]
        //public DataSet GetEmployeeProfessionsForDept(int employeeID, int deptCode)
        //{
        //    ClinicDB clinicDB = new ClinicDB();
        //    return clinicDB.GetEmployeeProfessionsForDept(employeeID, deptCode);
        //}

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployeeProfessionsInDept(int deptEmployeeID)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetEmployeeProfessionsInDept(deptEmployeeID); 
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteDeptEmployeeProfession(int employeeID, int deptCode, int professionCode )
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.DeleteDeptEmployeeProfession(employeeID, deptCode, professionCode );
        }

    }
}





