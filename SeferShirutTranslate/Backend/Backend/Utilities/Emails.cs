using Backend.Entities.BusinessLayer.BusinessObject;
using Backend.Entities.BusinessLayer.WorkFlow;
using Microsoft.Extensions.Configuration;
using System.Text.RegularExpressions;

namespace Backend.Utilities
{
    public class Emails
    {
        IConfiguration configuration;
        EmailHandler emailHandler;

        public Emails(IConfiguration configuration)
        {
            this.configuration = configuration;
            this.emailHandler = new EmailHandler(configuration);
        }

        public bool Send(string functionName, string exception, UserInfo userInfo)
        {
            try
            {
                //string developersEmails = this.configuration.GetValue<string>("Emails");
                string developersEmails = "shaulper@clalit.org.il";

                string[] developersEmailsArray = developersEmails.Split(';');

                List<string> developersEmailsList = new List<string>();

                if (developersEmailsArray.Length > 0)
                {
                    foreach (string item in developersEmailsArray)
                    {
                        if (isEmailValid(item))
                        {
                            developersEmailsList.Add(item);
                        }
                    }
                }

                if (developersEmailsList.Count > 0)
                {
                    new System.Threading.Thread(() =>
                    {
                        string userEmail = String.Empty;

                        //SeferNet.BusinessLayer.BusinessObject.UserInfo userInfo = (SeferNet.BusinessLayer.BusinessObject.UserInfo)Session["currentUser"];

                        try
                        {
                            //userInfo = (SeferNet.BusinessLayer.BusinessObject.UserInfo)Session["currentUser"];
                        }
                        catch
                        {
                            //userInfo = null;
                        }

                        if (userInfo != null)
                        {
                            userEmail = userInfo.Mail;
                        }
                        else
                        {
                            userEmail = "(Null)";
                        }

                        this.emailHandler.SendEmail("Error in " + functionName, "User " + userEmail + " got an error.<br/><br/>" + exception, "sefernet@clalit.org.il", developersEmailsList, "", "", "", System.Text.Encoding.UTF8);

                    }).Start();
                }

                return true;
            }
            catch
            {
                return false;
            }
        }

        bool isEmailValid(string email)
        {
            Regex regex = new Regex(@"^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$");
            Match match = regex.Match(email);
            if (match.Success) return true;
            else return false;
        }

        /*public void Send(string functionName, string exception, UserInfo userInfo)
        {
            new System.Threading.Thread(() =>
            {
                string userEmail = String.Empty;

                //string developersEmails = ConfigurationManager.AppSettings["DevelopersEmail"];

                string developersEmails = this.configuration.GetValue<string>("DevelopersEmail");

                string[] developersEmailsArray = developersEmails.Split(';');
                
                //string developersEmails = ConfigurationManager.AppSettings["DevelopersEmail"];

                //string[] developersEmailsArray = developersEmails.Split(';');

                //developersEmailsList = Configuration.GetConnectionString("DefaultConnection")

                //this.emailHandler.SendEmail("Error in " + functionName, "User " + username + " got an error.<br/>" + exception, "sefernet@clalit.org.il", "shaulper@clalit.org.il", "", "", "", System.Text.Encoding.UTF8);
                this.emailHandler.SendEmail("Error in " + functionName, "User " + userEmail + " got an error.<br/><br/>" + exception, "sefernet@clalit.org.il", developersEmailsList, "", "", "", System.Text.Encoding.UTF8);

            }).Start();
        }*/
    }
}