using Clalit.Exceptions.ExceptionData;
using Clalit.SeferNet.GeneratedEnums;
using Matrix.ExceptionHandling;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.Globals;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SeferNet.UI.Apps.Public
{
    public partial class SendBrochuresAndFormsByMailPopUp : System.Web.UI.Page
    {
        string fileNames = string.Empty;
        string body = string.Empty;
        string toAddress = string.Empty;
        string clalitLogoImage_FullPath = string.Empty;
        string clalitAndMushlamLogoImage_FullPath = string.Empty;
        public string subject = ConstsSystem.EMAIL_SUBJECT_MUSHLAM;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["fileNames"] != string.Empty)
            {
                fileNames = Request.QueryString["fileNames"];
            }
            else
            {
                ClientScript.RegisterStartupScript(this.GetType(), "close", "this.close();", true);
            }

            //txtTo.Text = "vladimirgr@clalit.org.il";
            //txtClientName.Text = "Vladimir";
            //txtRemark.Text = "Test";
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            Dictionary<string, string> linkedResources = new System.Collections.Generic.Dictionary<string, string>(); // ImageID, ImagePath

            GetImagePaths();

            linkedResources.Add("LogoClalit", clalitLogoImage_FullPath);
            linkedResources.Add("mushlamLogo", clalitAndMushlamLogoImage_FullPath);

            string formsAndBrochuresPath = System.Configuration.ConfigurationManager.AppSettings["formsAndBrochuresPath"].ToString();
            string template = "";
            string templatePath = "";
            string emailRemarks = txtRemark.Text;
            string emailClientName = txtClientName.Text;
            string str = string.Empty;

            toAddress = txtTo.Text;

            if (Request.QueryString["template"] != null && Request.QueryString["template"] != string.Empty)
            {
                template = Request.QueryString["template"];

                templatePath = Server.MapPath("~\\Templates\\Mails") + "\\" + template;
                body = getMailBody(template, templatePath, emailClientName, emailRemarks);
            }

            try
            {
                string filesPath = System.Configuration.ConfigurationManager.AppSettings["formsAndBrochuresPath"].ToString();
                string[] fileNamesArr = fileNames.Split('~');

                EmailHandler.SendEmailFromDefaultAddressMultAttach(subject, body, toAddress, string.Empty, string.Empty, fileNamesArr, Encoding.GetEncoding(ConstsLangage.HEBREW_ENCODING_HTML), linkedResources, filesPath);
                //str = "var obj = new Object(); obj.DataWasSaved = true; ";
                //str = str + "alert('המייל נשלח בהצלחה'); JQueryDialogClose();";

                str = "alert('המייל נשלח בהצלחה'); JQueryDialogClose();";
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();

                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInSendingEmail),
                  new WebPageExtraInfoGenerator());

                str = " alert('בעיה בשליחת הנתונים'); JQueryDialogClose();";
            }

            ClientScript.RegisterStartupScript(typeof(string), "selfClose", str, true);
        }
        private string getMailBody(string fileTamplate, string fileTamplatePath, string name, string remarks)
        {
            string content = "";

            StreamReader streamReader = new StreamReader(fileTamplatePath);

            content = streamReader.ReadToEnd();

            content = content.Replace("#clientName#", name);
            content = content.Replace("#body#", remarks);

            streamReader.Close();
            return content;
        }

        private void GetImagePaths()
        {
            string upToImagesPath = string.Empty;
            string[] pathSegments = Server.MapPath(".").Split('\\');
            for (int i = 0; i < pathSegments.Length - 1; i++)
            {
                upToImagesPath += pathSegments[i] + '\\';
            }

            clalitLogoImage_FullPath = upToImagesPath + @"Images\Applic\clalit100logo.gif";
            clalitAndMushlamLogoImage_FullPath = upToImagesPath + @"Images\Applic\clalit-mushlamLogo.gif";
        }
    }
}