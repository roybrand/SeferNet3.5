using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.UI.Apps.GetEmployeeDetailes;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;

namespace SeferNet.UI.Apps.AppCode
{
    public class GetEmployeeDetailesByID
    {
        public int GetProfLicence(long employeeID, bool isDental)
        {
            int profLicence = 0;

            //////////////////////
            string userName = ConfigurationManager.AppSettings["WebUserName"];
            string password = ConfigurationManager.AppSettings["WebUserPwd"];
            string domain = ConfigurationManager.AppSettings["WebUserDomain"];
            var Credentials = new System.Net.NetworkCredential(userName, password, domain);
            ///////////////////////

            GetEmployeeDetailsByIDClient service = new GetEmployeeDetailsByIDClient();
            ///////////////////////
            service.ClientCredentials.Windows.ClientCredential = Credentials;
            ///////////////////////



            GetEmployeeDetailsByIDMessageInfo messageInfo = new GetEmployeeDetailsByIDMessageInfo();

            messageInfo.RequestID = Guid.NewGuid().ToString();
            messageInfo.RequestDatetime = DateTime.Now;
            messageInfo.RequestingApplication = Convert.ToInt32(ConfigurationManager.AppSettings["RequestingApplication"]);
            messageInfo.ServingApplication = Convert.ToInt32(ConfigurationManager.AppSettings["ServingApplication"]);
            messageInfo.RequestingSite = Convert.ToInt32(ConfigurationManager.AppSettings["RequestingSite"]);
            messageInfo.ServingSite = Convert.ToInt32(ConfigurationManager.AppSettings["ServingSite"]);

            GetEmployeeDetailsByIDParameters parameters = new GetEmployeeDetailsByIDParameters();

            parameters.EmployeeID = employeeID.ToString();

            GetEmployeeDetailsByID_Request requestEmp = new GetEmployeeDetailsByID_Request();
            requestEmp.MessageInfo = messageInfo;
            requestEmp.Parameters = parameters;

            try
            {

                service.ClientCredentials.Windows.AllowedImpersonationLevel = System.Security.Principal.TokenImpersonationLevel.Impersonation;

                var response = service.GetEmployeeDetailsByIDAction(requestEmp);

                GetEmployeeDetailsByIDResults results = response.Results;

                GetEmployeeDetailsByIDProfessionalLicenses professionalLicensesField = results.ProfessionalLicenses;
                GetEmployeeDetailsByIDAssignations AssignationsField = results.Assignations;

                if (professionalLicensesField != null && AssignationsField != null && !isDental)
                {
                    string subSectorCode = AssignationsField[0].SectorCode;
                    string typeCode = string.Empty;

                    DataTable dtSubSector_LicenseType = GetX_EmployeeSubSector_ProfLicenceType().Tables[0];

                    for (int i = 0; i < dtSubSector_LicenseType.Rows.Count; i++)
                    {
                        if (dtSubSector_LicenseType.Rows[i]["SubSectorCode"].ToString() == subSectorCode)
                        {
                            typeCode = dtSubSector_LicenseType.Rows[i]["ProfLicenceType"].ToString();

                            if (professionalLicensesField != null && professionalLicensesField.Count > 0)
                            {
                                DateTime startDate = Convert.ToDateTime("1900-01-01");

                                for (int ii = 0; ii < professionalLicensesField.Count; ii++)
                                {
                                    if (professionalLicensesField[ii].TypeCode == typeCode)
                                    {
                                        if (Convert.ToDateTime(professionalLicensesField[ii].StartDate) > startDate)
                                        {
                                            profLicence = Convert.ToInt32(professionalLicensesField[ii].LicenseNumber);
                                            startDate = Convert.ToDateTime(professionalLicensesField[ii].StartDate);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else if (professionalLicensesField != null && professionalLicensesField.Count > 0 && isDental)
                {
                    profLicence = Convert.ToInt32(professionalLicensesField[0].LicenseNumber);
                }
            }
            catch(Exception ex)
            {
                profLicence = 0;
            }

            return profLicence;
        }

        public void UpdateProfLicences()
        {
            long employeeID;
            int profLicence;
            EmployeePositionsBO bo = new EmployeePositionsBO();
            DataSet ds = bo.GetEmployeesToUpdateProfessionLicences();
            DataTable dt = ds.Tables[0];
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                employeeID = Convert.ToInt64(dt.Rows[i]["EmployeeID"]);
                profLicence = GetProfLicence(employeeID, false);
                dt.Rows[i]["ProfessionalLicenseNumber"] = profLicence;
            }
            string username = "admin.update_employee_prof_licences";
            bo.UpdateEmployeeProfessionLicences(dt);
        }

        public DataSet GetX_EmployeeSubSector_ProfLicenceType()
        {
            EmployeePositionsBO bo = new EmployeePositionsBO();
            DataSet ds = bo.GetX_EmployeeSubSector_ProfLicenseType();

            return ds;
        }
    }
}