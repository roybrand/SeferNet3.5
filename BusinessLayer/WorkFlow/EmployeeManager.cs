using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using SeferNet.DataLayer;
using SeferNet.BusinessLayer.BusinessObject;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class EmployeeManager
    {
        string m_ConnStr;

        public EmployeeManager()
        {
            m_ConnStr = ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"].ConnectionString;
        }

        public void UpdateEmployeeAndPhones(long employeeID, int degreeCode, string firstName, string lastName,
         int EmployeeSectorCode, int sex, int primaryDistrict, string email, bool showEmailInInternet, Phone homePhone, Phone cellPhone)
        {
            string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();
            DoctorDB doctorDB = new DoctorDB();
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);

            doctorDB.UpdateEmployee(employeeID, degreeCode, firstName, lastName, EmployeeSectorCode, sex,
                       primaryDistrict, email, showEmailInInternet, updateUser);

            phoneDB.DeleteEmployeePhones(employeeID);


            if (homePhone != null && homePhone.PhoneNumber != -1)
            {
                phoneDB.InsertEmployeePhone(employeeID, 1, 1,
                        homePhone.PrePrefix, homePhone.PreFix, homePhone.PhoneNumber, homePhone.Extension,
                Convert.ToInt16(homePhone.IsUnListed), updateUser);
            }

            if (cellPhone != null && cellPhone.PhoneNumber != -1)
            {
                phoneDB.InsertEmployeePhone(employeeID, 3, 1,
                    cellPhone.PrePrefix, cellPhone.PreFix, cellPhone.PhoneNumber, cellPhone.Extension,
                    Convert.ToInt16(cellPhone.IsUnListed), updateUser);

            }
        }


        public void UpdateEmployeeProfessions(long employeeID, string selectedProfessionCodes)
        {
            DoctorDB dal = new DoctorDB();

            // delete not relevant professions
            dal.DeleteEmployeeProfessions(employeeID, selectedProfessionCodes);

            if (!string.IsNullOrEmpty(selectedProfessionCodes))
            {
                // insert the professions to the employee
                dal.InsertEmployeeProfession(employeeID, selectedProfessionCodes, new UserManager().GetLoggedinUserNameWithPrefix());
            }
        }

        public void UpdateEmployeeExpertise(long employeeID, string professionCodes, string expertDiplomaNumbers)
        {
            DoctorDB dal = new DoctorDB();
            dal.UpdateEmployeeExpertise(employeeID, professionCodes, expertDiplomaNumbers, new UserManager().GetLoggedinUserNameWithPrefix());
        }

        public void UpdateEmployeeInClinicPreselected(long? employeeID, int? deptCode, int? deptEmployeeID)
        {
            DoctorDB dal = new DoctorDB();
            dal.UpdateEmployeeInClinicPreselected(employeeID, deptCode, deptEmployeeID);
        }
        public void DeleteAllEmployeeServicesAndInsert(long employeeID, string selectedValues)
        {
            DoctorDB dal = new DoctorDB();

            dal.DeleteAllEmployeeServices(employeeID);

            if (!string.IsNullOrEmpty(selectedValues))
            {
                dal.InsertEmployeeServices(employeeID, selectedValues, new UserManager().GetLoggedinUserNameWithPrefix());
            }
        }

        public void DeleteAllLanguagesAndInsert(long employeeID, string seperatedValues)
        {
            DoctorDB dal = new DoctorDB();

            dal.DeleteAllEmployeeLanguages(employeeID);

            if (!string.IsNullOrEmpty(seperatedValues))
            {
                // link the languages to the employee
                dal.InsertEmployeeLanguages(employeeID, seperatedValues, new UserManager().GetLoggedinUserNameWithPrefix());
            }
        }
    }
}
