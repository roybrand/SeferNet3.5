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
using System.Transactions;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class EmployeeProfessionBO
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
        public DataSet GetEmployeeProfessions(long employeeID)
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetEmployeeProfessions(employeeID); 
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployeeProfessionForUpdate(int employeeID, int professionCode)
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetEmployeeProfessionForUpdate(employeeID, professionCode); 
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetProfessionsForEmployee(int employeeID)
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetProfessionsForEmployee(employeeID); 
        }

        /// <summary>
        /// gets employee professions. if deptCode is specified - indicates whether the profession is linked to this dept code.
        /// if child profession is linked to the employee,gets also the parent profession,and specify that the parent is not linked
        /// </summary>
        /// <param name="employeeCode"></param>
        /// <returns></returns>
        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetEmployeeProfessionsExtended(long employeeID, int deptCode, bool IsLinkedToEmployeeOnly, bool EnableExpert )
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetEmployeeProfessionsExtended(employeeID, deptCode, IsLinkedToEmployeeOnly, EnableExpert);
        }  

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteEmployeeProfession(int employeeID, int professionCode )
        {
            DoctorDB doctorDB = new DoctorDB();
            doctorDB.DeleteEmployeeProfession(employeeID, professionCode );
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void InsertEmployeeProfession(int employeeID, string professionCodes, string updateUser)
        {
            DoctorDB doctorDB = new DoctorDB();
            doctorDB.InsertEmployeeProfession(employeeID, professionCodes, updateUser);
        }

        [DataObjectMethod(DataObjectMethodType.Update)]
        public void UpdateEmployeeProfession(int employeeID, int professionCode, 
            int mainProfession, int expProfession, string updateUser)
        {
            DoctorDB doctorDB = new DoctorDB();
            doctorDB.UpdateEmployeeProfession(employeeID, professionCode, 
                mainProfession, expProfession, updateUser);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetAllProfessionsExtended(string professionCodesSelected)
        {
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetAllProfessionsExtended(professionCodesSelected);
        }       

		//public DataSet GetEmployeeProfessionsFromWholeList(long employeeID)
		//{
		//    DoctorDB dal = new DoctorDB();
		//    return dal.GetEmployeeProfessionsFromWholeList(employeeID);
		//}

        public void UpdateEmployeeExpertise(long employeeID, string professionCodes, string expertDiplomaNumbers, string userName)
        {
            DoctorDB dal = new DoctorDB();
            dal.UpdateEmployeeExpertise(employeeID, professionCodes, expertDiplomaNumbers, userName);
        }
        public DataSet GetEmployeeExpertiseToUpdate(long employeeID, string selectedValues)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetEmployeeExpertiseToUpdate(employeeID, selectedValues);
        }

        public bool CheckIfEmployeeMustHasProfession(int employeeID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.CheckIfEmployeeIsDoctor(employeeID);
             
        }

        public DataSet GetSpecialityByNameForEmployee(string prefixText, long employeeID)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetEmployeeSpecialityByName(prefixText, employeeID);
        }

        public DataSet GetProfessionsBySector(string professionCodesSelected, int sectorType)
        {
            DoctorDB dal = new DoctorDB();
            return dal.GetProfessionsBySector(sectorType, professionCodesSelected);
        }
    }
}





