using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using Clalit.SeferNet.GeneratedEnums;
using System.IO;
using System.Net.Mime;


namespace SeferNet.BusinessLayer.WorkFlow
{
    public class EmailHandler
    {
        public EmailHandler()
		{
			//
			// TODO: Add constructor logic here
			//
		}

        public static bool SendEmailFromDefaultAddress(string subject, string body, List<string> toAddresses, string htmlAttachmentBody, string htmlAttachmentFilenameExtension, string fileName, Encoding encoding)
        {
            return SendEmail(subject, body, System.Configuration.ConfigurationManager.AppSettings["DefaultFromMail"], toAddresses, htmlAttachmentBody, htmlAttachmentFilenameExtension, fileName, encoding);
        }

        public static bool SendEmailFromDefaultAddress(string p_subject, string body, string p_toAddress, string htmlAttachmentBody, string htmlAttachmentFilenameExtension, string fileName, Encoding encoding, Dictionary<string, string> linkedResources)
        {
            return SendEmail(p_subject, body, System.Configuration.ConfigurationManager.AppSettings["DefaultFromMail"], p_toAddress, htmlAttachmentBody, htmlAttachmentFilenameExtension, fileName, encoding, linkedResources);
        }

        public static bool SendEmailFromDefaultAddressMultAttach(string p_subject, string body, string p_toAddress, string htmlAttachmentBody, string htmlAttachmentFilenameExtension, string[] fileNames, Encoding encoding, Dictionary<string, string> linkedResources, string filesPath)
        {
            return SendEmailMultAttach(p_subject, body, System.Configuration.ConfigurationManager.AppSettings["DefaultFromMail"], p_toAddress, htmlAttachmentBody, htmlAttachmentFilenameExtension, fileNames, encoding, linkedResources, filesPath);
        }

        public static bool SendEmail(string subject, string body, string fromAddress, List<string> toAddresses, string htmlAttachmentBody, string htmlAttachmentFilenameExtension, string fileName, Encoding encoding)
        {
            MailMessage message = GetMailMessage(toAddresses, fromAddress, subject, body);

            //add attachment if requied
            if (!string.IsNullOrEmpty(htmlAttachmentBody))
            {
                AddAttachmentToMessage(ref message, fileName + '.' + htmlAttachmentFilenameExtension, htmlAttachmentBody, encoding);
            }

            return SendMessage(message);
        }

        public static bool SendEmail(string p_subject, string body, string p_fromAddress, string p_toAddress, string htmlAttachmentBody, string htmlAttachmentFilenameExtension, string fileName, Encoding encoding, Dictionary<string, string> linkedResources)
        {
            MailMessage message = GetMailMessage(p_toAddress, p_fromAddress, p_subject, body, linkedResources);

            //add attachment if requied
            if (!string.IsNullOrEmpty(htmlAttachmentBody))
            {
                AddAttachmentToMessage(ref message, fileName + '.' + htmlAttachmentFilenameExtension, htmlAttachmentBody, encoding);
            }

            return SendMessage(message);
        }
        public static bool SendEmailMultAttach(string p_subject, string body, string p_fromAddress, string p_toAddress, string htmlAttachmentBody, string htmlAttachmentFilenameExtension, string[] fileNames, Encoding encoding, Dictionary<string, string> linkedResources, string filesPath)
        {
            MailMessage message = GetMailMessage(p_toAddress, p_fromAddress, p_subject, body, linkedResources);

            filesPath = @filesPath + "\\\\";

            //fileName = @"\\clalit\dfs$\IntraDev\SeferNet\FormsAndBrochures\tofesmushlam.pdf";

            foreach (string fileName in fileNames)
            {
                message.Attachments.Add(new Attachment(@filesPath + fileName));
            }

            return SendMessage(message);
        }
        private static bool AddAttachmentToMessage(ref MailMessage message, string p_fileName, string p_fileContent)
        {
            byte[] contentAsBytes = Encoding.UTF8.GetBytes(p_fileContent);
            MemoryStream memoryStream = new MemoryStream();
            memoryStream.Write(contentAsBytes, 0, contentAsBytes.Length);

            // Set the position to the beginning of the stream.

            memoryStream.Seek(0, SeekOrigin.Begin);

            // Create attachment

            ContentType contentType = new ContentType();
            contentType.MediaType = MediaTypeNames.Application.Octet;
            contentType.Name = p_fileName;
            Attachment attachment = new Attachment(memoryStream, contentType);

            // Add the attachment

            message.Attachments.Add(attachment);

            return true;
        }

        private static bool AddAttachmentToMessage(ref MailMessage message, string p_fileName, string p_fileContent, Encoding p_encoding)
        {
            bool resultToReturn = false;
            if (!string.IsNullOrEmpty(p_fileContent))
            {
                byte[] bytes;

                bytes = p_encoding.GetBytes(p_fileContent);

                resultToReturn = AddAttachmentToMessage(ref message, p_fileName, bytes);
            }

            return resultToReturn;
        }

        private static bool AddAttachmentToMessage(ref MailMessage message, string p_fileName, byte[] bytes)
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

        private static MailMessage GetMailMessage(string p_toAddress, string p_fromAddress, string p_subject, string p_body, Dictionary<string, string> linkedResources)
        {
            MailMessage message = new MailMessage();
            message.To.Add(p_toAddress);
            message.From = new MailAddress(p_fromAddress);
            message.Subject = p_subject;

            AlternateView htmlView = AlternateView.CreateAlternateViewFromString(p_body, null, "text/html");
            LinkedResource linkedImage;

            foreach (KeyValuePair<string, string> dicItem in linkedResources)
            {
                linkedImage = new LinkedResource(dicItem.Value);
                linkedImage.ContentId = dicItem.Key;
                htmlView.LinkedResources.Add(linkedImage);
            }

            message.AlternateViews.Add(htmlView);

            return message;
        }

        private static bool SendMessage(MailMessage message)
        {
            bool resultToReturn = true;

            SmtpClient client = new SmtpClient(System.Configuration.ConfigurationManager.AppSettings["smtpServer"]);
            client.UseDefaultCredentials = false;
            try
            {
                client.Send(message);
            }
            catch (Exception ex)
            {
                resultToReturn = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();

                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInSendingEmail),
                  new WebPageExtraInfoGenerator());
            }

            return resultToReturn;
        }

    }
}
