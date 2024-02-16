using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SeferNet.DataLayer;
using System.Data;
using SeferNet.Globals;
using System.Net.Mail;
using System.Web;


namespace SeferNet.BusinessLayer.WorkFlow
{
    public class ReportToUsers
    {
        ReportToUsersDB reportToUsersDB = new ReportToUsersDB();
        string mailToList;
        string Url;

        public void SendNewClinicMailReport(int deptCode, string deptName, string Url)
        {
            mailToList = reportToUsersDB.GetMailtoListOfNewClinic(deptCode);
            SendReportNewClinicMail(mailToList, Url, deptCode, deptName);
        }

        public void SendReportNewClinicMail(string mailToList, string Url, int deptCode, string deptName)
        {
            string smtpServer = ConfigHelper.GetSmtpServer();
            string fromName = ConfigHelper.GetMailSenderName();
            string fromEmail = ConfigHelper.GetDefaultFromEmailAddress();

            if (!string.IsNullOrEmpty(mailToList.Trim()))
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, fromName);
                mail.Subject = "הודעה על פתיחת יחידה חדשה";
                mail.IsBodyHtml = true;

                // add all recipients
                mailToList = mailToList.Trim(';');
                string[] toArr = mailToList.Split(';');
                foreach (string address in toArr)
                {
                    if (!string.IsNullOrEmpty(address))
                        mail.To.Add(new MailAddress(address));
                }

                mail.Body = "<body dir='rtl' style='font-family:arial;font-size:12px;font-weight:normal'>" + "<br/>" +
                    "שלום,<br/><br/>" +
                    "נפתחה יחידה חדשה במחוז" + "<br/>" +
                    "שם היחידה: <b>" + deptName + "</b><br/>" +
                    "סימול היחידה: <b>" + deptCode.ToString() + "</b><br/><br/>" +

                    "ניתן לראות ולעדכן את הפרטים שלה ב<a href='" + Url + "'>לינק</a> הבא<br/> </body>";

                SmtpClient client = new SmtpClient(smtpServer);
                client.Send(mail);

                mail.Dispose();
                client = null;
            }
        }

        public void SendReportClinicNameChange(string mailToList, string Url, int deptCode, string deptName, string districtName, string UnitTypeName, string UserName)
        {
            string smtpServer = ConfigHelper.GetSmtpServer();
            string fromName = ConfigHelper.GetMailSenderName();
            string fromEmail = ConfigHelper.GetDefaultFromEmailAddress();

            if (!string.IsNullOrEmpty(mailToList.Trim()))
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, fromName);
                mail.Subject = "הודעה על שינוי שם יחידה";
                mail.IsBodyHtml = true;

                // add all recipients
                mailToList = mailToList.Trim(';');
                string[] toArr = mailToList.Split(';');
                foreach (string address in toArr)
                {
                    if (!string.IsNullOrEmpty(address))
                        mail.To.Add(new MailAddress(address));
                }

                mail.Body = "<body dir='rtl' style='font-family:arial;font-size:16px;font-weight:normal'>" + "<br/>" +
                    "לידיעתך,<br/><br/>" +
                    " השתנה שם יחידה ב - " + districtName + " על ידי משתמש " + UserName + "<br/>" + 
                    "קוד: <b>" + deptCode.ToString() + "</b><br/>" +
                    "שם: <b>"  + deptName + "</b><br/>" +
                    "סוג: <b>" + UnitTypeName + "</b><br/><br/>" +
                    "<a href='" + Url + "'>קישור ליחידה בספר השירות</a><br/> </body>";

                SmtpClient client = new SmtpClient(smtpServer);
                client.Send(mail);

                mail.Dispose();
                client = null;
            }
        }

        public void SendReportClinicUnitTypeChange(string mailToList, string Url, int deptCode, string deptName, string districtName, string UnitTypeName, string previeusUnitTypeName, string UserName)
        {
            string smtpServer = ConfigHelper.GetSmtpServer();
            string fromName = ConfigHelper.GetMailSenderName();
            string fromEmail = ConfigHelper.GetDefaultFromEmailAddress();

            if (!string.IsNullOrEmpty(mailToList.Trim()))
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, fromName);
                mail.Subject = "הודעה על שינוי סוג יחידה";
                mail.IsBodyHtml = true;

                // add all recipients
                mailToList = mailToList.Trim(';');
                string[] toArr = mailToList.Split(';');
                foreach (string address in toArr)
                {
                    if (!string.IsNullOrEmpty(address))
                        mail.To.Add(new MailAddress(address));
                }

                mail.Body = "<body dir='rtl' style='font-family:arial;font-size:16px;font-weight:normal'>" + "<br/>" +
                    "לידיעתך,<br/><br/>" +
                    " השתנה סוג יחידה ב - " + districtName + " על ידי משתמש " + UserName + "<br/>" + 
                    "קוד: <b>" + deptCode.ToString() + "</b><br/>" +
                    "שם: <b>"  + deptName + "</b><br/>" +
                    "סוג: <b>" + UnitTypeName + "</b><br/><br/>" +
                    "(" + "סוג הקודם: <b>" + previeusUnitTypeName + "</b>)<br/><br/>" +
                    "<a href='" + Url + "'>קישור ליחידה בספר השירות</a><br/> </body>";

                SmtpClient client = new SmtpClient(smtpServer);
                client.Send(mail);

                mail.Dispose();
                client = null;
            }
        }

        public void SendReportClinicNameChangeDueToTypeChange(string mailToList, string Url, int deptCode, string deptName, string districtName, string UnitTypeName, string previeusUnitTypeName, string UserName)
        {
            string smtpServer = ConfigHelper.GetSmtpServer();
            string fromName = ConfigHelper.GetMailSenderName();
            string fromEmail = ConfigHelper.GetDefaultFromEmailAddress();

            if (!string.IsNullOrEmpty(mailToList.Trim()))
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, fromName);
                mail.Subject = "הודעה על שינוי שם יחידה";
                mail.IsBodyHtml = true;

                // add all recipients
                mailToList = mailToList.Trim(';');
                string[] toArr = mailToList.Split(';');
                foreach (string address in toArr)
                {
                    if (!string.IsNullOrEmpty(address))
                        mail.To.Add(new MailAddress(address));
                }

                mail.Body = "<body dir='rtl' style='font-family:arial;font-size:16px;font-weight:normal'>" + "<br/>" +
                    "לידיעתך,<br/><br/>" +
                    " השתנה סוג יחידה ב - " + districtName + " על ידי משתמש " + UserName + "<br/>" +
                    " השינוי גרם לשינוי בשם היחידה " + "<br/>" +

                    " שם היחידה המעודכן " + "<br/>" +
                    "קוד: <b>" + deptCode.ToString() + "</b><br/>" +
                    "שם: <b>" + deptName + "</b><br/>" +
                    "סוג: <b>" + UnitTypeName + "</b><br/><br/>" +
                    "(" + "סוג הקודם: <b>" + previeusUnitTypeName + "</b>)<br/><br/>" +
                    "<a href='" + Url + "'>קישור ליחידה בספר השירות</a><br/> </body>";

                SmtpClient client = new SmtpClient(smtpServer);
                client.Send(mail);

                mail.Dispose();
                client = null;
            }
        }

        public void SendReportClinicActivation(string mailToList, string Url, int deptCode, string deptName, string districtName, string UnitTypeName, string UserName)
        {
            string smtpServer = ConfigHelper.GetSmtpServer();
            string fromName = ConfigHelper.GetMailSenderName();
            string fromEmail = ConfigHelper.GetDefaultFromEmailAddress();

            if (!string.IsNullOrEmpty(mailToList.Trim()))
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, fromName);
                mail.Subject = "הודעה על פתיחה יחידה חדשה";
                mail.IsBodyHtml = true;

                // add all recipients
                mailToList = mailToList.Trim(';');
                string[] toArr = mailToList.Split(';');
                foreach (string address in toArr)
                {
                    if (!string.IsNullOrEmpty(address))
                        mail.To.Add(new MailAddress(address));
                }

                mail.Body = "<body dir='rtl' style='font-family:arial;font-size:12px;font-weight:normal'>" + "<br/>" +
                    "לידיעתך,<br/><br/>" +
                    "נפתחה יחידה חדשה ב" + districtName + " על ידי משתמש " + UserName + "<br/>" + 
                    "קוד: <b>" + deptCode.ToString() + "</b><br/>" +
                    "שם: <b>"  + deptName + "</b><br/>" +
                    "סוג: <b>" + UnitTypeName + "</b><br/><br/>" +
                    "<a href='" + Url + "'>קישור ליחידה בספר השירות</a><br/> </body>";

                SmtpClient client = new SmtpClient(smtpServer);
                client.Send(mail);

                mail.Dispose();
                client = null;
            }
        }

        public void SendReportAboutFreeClinicRemark(string mailToList, string Url, int deptCode, string deptName, string remarkText, string UserName, string userEmail)
        {
            string smtpServer = ConfigHelper.GetSmtpServer();
            string fromName = ConfigHelper.GetMailSenderName();
            string fromEmail = ConfigHelper.GetDefaultFromEmailAddress();

            if (!string.IsNullOrEmpty(mailToList.Trim()))
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, fromName);
                mail.Subject = " 'אשור שינוי 'הערות פתוחות";
                mail.IsBodyHtml = true;

                // add all recipients
                mailToList = mailToList.Trim(';');
                string[] toArr = mailToList.Split(';');
                foreach (string address in toArr)
                {
                    if (!string.IsNullOrEmpty(address))
                        mail.To.Add(new MailAddress(address));
                }

                mail.Body = "<body dir='rtl' style='font-family:arial;font-size:12px;font-weight:normal'>" + "<br/>" +
                    " הוספה\\עדכון הערה 'פתוחה' הדורשת בדיקתך ואישורך <br/><br/>" +
                    "<u>יחידה:</u> " + deptName + "<br/>" +
                    "<u>הערה:</u> " + remarkText + "<br/><br/>" +
                    "<a href='" + Url + "'>הוספה\\עדכון הערה</a><br/><br/>" +
                    "בתודה,<br/>" + UserName + "<br/><br/>" +
                    "" + userEmail + "<br/>" +
                     "</body>";

                SmtpClient client = new SmtpClient(smtpServer);
                client.Send(mail);

                mail.Dispose();
                client = null;
            }
        }

        public void ApplyForChangeStatusToActive(string mailToList, string Url, int deptCode, string deptName, string districtName, string UnitTypeName, string UserName, string userMail)
        {
            //MailTo, Url, deptCode, deptName, districtName, unitTypeName, UserName, userMail
            string smtpServer = ConfigHelper.GetSmtpServer();
            string fromName = ConfigHelper.GetMailSenderName();
            string fromEmail = ConfigHelper.GetDefaultFromEmailAddress();

            if (!string.IsNullOrEmpty(mailToList.Trim()))
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, fromName);
                mail.Subject = "הודעה על פתיחה יחידה חדשה";
                mail.IsBodyHtml = true;

                // add all recipients
                mailToList = mailToList.Trim(';');
                string[] toArr = mailToList.Split(';');
                foreach (string address in toArr)
                {
                    if (!string.IsNullOrEmpty(address))
                        mail.To.Add(new MailAddress(address));
                }

                mail.Body = "<body dir='rtl' style='font-family:arial;font-size:12px;font-weight:normal'>" + "<br/>" +
                    "לידיעתך,<br/><br/>" +
                    "נפתחה יחידה חדשה ב <b>" + districtName + "<b><br/>" + 
                    "קוד: <b>" + deptCode.ToString() + "</b><br/>" +
                    "שם: <b>"  + deptName + "<b><br/>" +
                    "סוג: <b>" + UnitTypeName + "</b><br/><br/>" +
                    "נבקשך להפוך את היחידה לפעילה<br/><br/>" +
                    "<a href='" + Url + "'>קישור ליחידה בספר השירות</a><br/><br/> " +
                    "בתודה,<br/>&nbsp;&nbsp;&nbsp;" +  UserName + " <br/>&nbsp;&nbsp;&nbsp;" + userMail + "<br/><br/> </body>";
                SmtpClient client = new SmtpClient(smtpServer);
                client.Send(mail);

                mail.Dispose();
                client = null;
            }
        }

        public void ApplyForChangeDIC_remarks(string mailToList, string Url, string UserName, string userMail)
        {
            //MailTo, Url, deptCode, deptName, districtName, unitTypeName, UserName, userMail
            string smtpServer = ConfigHelper.GetSmtpServer();
            string fromName = ConfigHelper.GetMailSenderName();
            string fromEmail = ConfigHelper.GetDefaultFromEmailAddress();

            if (!string.IsNullOrEmpty(mailToList.Trim()))
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, fromName);
                mail.Subject = "בקשת אישור שינוי הערות";
                mail.IsBodyHtml = true;

                // add all recipients
                mailToList = mailToList.Trim(';');
                string[] toArr = mailToList.Split(';');
                foreach (string address in toArr)
                {
                    if (!string.IsNullOrEmpty(address))
                        mail.To.Add(new MailAddress(address));
                }

                mail.Body = "<body dir='rtl' style='font-family:arial;font-size:12px;font-weight:normal'>" + "<br/>" +
                    "יש שינויים במילון הערות דורשים אישורך<br/><br/>" +
                    "<a href='" + Url + "'>טיוב הערות</a><br/><br/> " +
                    "<br/><br/> " +
                    "בתודה,<br/>&nbsp;&nbsp;&nbsp;" + UserName + " <br/>&nbsp;&nbsp;&nbsp;" + userMail + "<br/><br/> </body>";
                SmtpClient client = new SmtpClient(smtpServer);
                client.Send(mail);

                mail.Dispose();
                client = null;
            }
        }

    }
}
