using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SeferNet.DataLayer;
using System.Data;
using SeferNet.Globals;
using System.Net.Mail;


namespace SeferNet.BusinessLayer.WorkFlow
{
    public class ReportErrorBO
    {
        ReportErrorDB _dal = new ReportErrorDB();

        public void InsertIncorrectDataReport(int deptCode, long employeeID, Enums.IncorrectDataReportEntity currEntity,
                                                                                                            string errorDesc, string pageUrl, string reportedBy)
        {
            string mailToList;
            string mailSubject = string.Empty;
            DataSet ds = null;


            if (currEntity == Enums.IncorrectDataReportEntity.Employee)
            {
                DoctorDB dal = new DoctorDB();

                mailToList = GetMailListByEmployeeID(employeeID);
                ds = dal.GetEmployee(employeeID);
                string name = ds.Tables[0].Rows[0]["firstName"].ToString() + " " + ds.Tables[0].Rows[0]["LastName"].ToString();
                mailSubject = GenerateMailSubject(employeeID, name, Enums.EntityTypesStatus.Employee);
                deptCode = 0; // reset dept code

            }
            else
            {
                if (currEntity == Enums.IncorrectDataReportEntity.Dept)
                {
                    ClinicDB dal = new ClinicDB();

                    mailToList = GetMailtoListByDeptCode(deptCode);
                    dal.GetDeptDetailsForPopUp(ref ds, deptCode);
                    mailSubject = GenerateMailSubject((long)deptCode, ds.Tables[0].Rows[0]["DeptName"].ToString(), Enums.EntityTypesStatus.Dept);
                    employeeID = 0; // reset employeeID
                }
                else
                {
                    // (currEntity == Enums.IncorrectDataReportEntity.SalService)
                    ClinicDB dal = new ClinicDB();

                    mailToList = GetMailtoListForSalServices();
                    mailSubject = "דיווח מידע שגוי על סל שירותים";
                }
            }


            _dal.InsertIncorrectData(deptCode, employeeID, errorDesc, pageUrl, mailToList, DateTime.Now, reportedBy);
            SendIncorrectDataMail(mailSubject, mailToList, errorDesc, pageUrl, reportedBy);
        }



        public void SendIncorrectDataMail(string mailSubject, string mailToList, string errorDesc, string pageUrl, string reportedBy)
        {
            string smtpServer = ConfigHelper.GetSmtpServer();
            string fromName = ConfigHelper.GetMailSenderName();
            string fromEmail = ConfigHelper.GetFromEmailAddress();

            if (!string.IsNullOrEmpty(mailToList.Trim()))
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, fromName);
                mail.Subject = "דיווח על מידע שגוי";
                mail.IsBodyHtml = true;

                // add all recipients
                mailToList = mailToList.Trim(';');
                string[] toArr = mailToList.Split(';');
                foreach (string address in toArr)
                {
                    if (!string.IsNullOrEmpty(address))
                        mail.To.Add(new MailAddress(address));
                }

                mail.Body = "<body dir='rtl' style='font-family:arial;font-size:12px;font-weight:normal'>" + "<br/> <font size='4' bold>" + mailSubject + " <font/> <br/><br/>" +
                    "דווח של מידע שגוי עלידי:<br/>" + reportedBy + "<br/><br/>" +
                    "תיאור הבעיה:<br/>" + errorDesc.Replace("\n", "<br/>") + "<br/><br/>" +
                    "<a href='" + pageUrl + "'>קישור לדף הרלוונטי</a> <br/> </body>";

                SmtpClient client = new SmtpClient(smtpServer);
                client.Send(mail);

                mail.Dispose();
                client = null;
            }
        }


        /// <summary>
        /// gets dept code - and returns all the mail addresses of users with district permission that should be 
        /// informed in case of incorrect data reprot, including system administrator
        /// </summary>
        /// <param name="deptCode">dept code</param>
        /// <returns>mail addresses delimited by ";"</returns>
        public string GetMailtoListByDeptCode(int deptCode)
        {
            return _dal.GetMailtoList(0,deptCode);
        }

        private string GetMailListByEmployeeID(long employeeID)
        {
            return _dal.GetMailtoList(employeeID,0);
        }

        private string GetMailtoListForSalServices()
        {
            return _dal.GetMailtoListForSalServices();
        }


        private string GenerateMailSubject(long entityID, string name, Enums.EntityTypesStatus entityType)
        {
            string generatedString = string.Empty;

            switch (entityType)
            {
                case Enums.EntityTypesStatus.Dept:
                    generatedString = "דיווח מידע שגוי על יחידה " + entityID + " - " + name;
                    break;

                case Enums.EntityTypesStatus.Employee:
                    generatedString = "דיווח מידע שגוי על נותן שירות " + name + " ת.ז. " + entityID;
                    break;

            }

            return generatedString;
        }
                                        
    }
}
