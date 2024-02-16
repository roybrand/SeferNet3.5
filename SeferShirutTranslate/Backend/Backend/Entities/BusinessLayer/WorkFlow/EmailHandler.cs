using System.Net.Mail;
using System.Text;

namespace Backend.Entities.BusinessLayer.WorkFlow
{
    public class EmailHandler
    {
        IConfiguration configuration;

        public EmailHandler(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public bool SendEmail(string subject, string body, string fromAddress, List<string> toAddress, string htmlAttachmentBody, string htmlAttachmentFilenameExtension, string fileName, Encoding encoding)
        {
            MailMessage message = GetMailMessage(toAddress, fromAddress, subject, body);

            if (!string.IsNullOrEmpty(htmlAttachmentBody))
            {
                AddAttachmentToMessage(ref message, fileName + '.' + htmlAttachmentFilenameExtension, htmlAttachmentBody, encoding);
            }

            return SendMessage(message);
        }

        private static MailMessage GetMailMessage(List<string> toAddresses, string fromAddress, string subject, string body)
        {
            MailMessage message = new MailMessage();
            foreach (string toAddress in toAddresses)
            {
                message.To.Add(toAddress);
            }
            message.From = new MailAddress(fromAddress);
            message.Subject = subject;
            message.IsBodyHtml = true;
            message.Body = body;
            return message;
        }

        private bool AddAttachmentToMessage(ref MailMessage message, string fileName, string fileContent, Encoding encoding)
        {
            bool resultToReturn = false;
            if (!string.IsNullOrEmpty(fileContent))
            {
                byte[] bytes;

                bytes = encoding.GetBytes(fileContent);

                resultToReturn = AddAttachmentToMessage(ref message, fileName, bytes);
            }

            return resultToReturn;
        }

        private bool AddAttachmentToMessage(ref MailMessage message, string p_fileName, byte[] bytes)
        {
            bool resultToReturn = false;

            //save the attachment content in memory
            MemoryStream ms = new MemoryStream(bytes);
            ms.Seek(0, 0);

            //add the attachment to the email
            Attachment attach = new Attachment(ms, p_fileName);
            message.Attachments.Add(attach);
            resultToReturn = true;

            return resultToReturn;
        }

        private bool SendMessage(MailMessage message)
        {
            SmtpClient client = new SmtpClient(configuration["Email:SmtpServer"]);
            client.UseDefaultCredentials = false;

            client.Send(message);

            return true;
        }
    }
}
