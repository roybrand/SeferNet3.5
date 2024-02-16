using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
namespace SeferNet.Globals
{
    public static class MailHelper
    {
        
        public static void send(string from, string to, string cc, string mailSubject,string emailClientName,
            string mailBody, string mailServerName, string[] filesNames, string directoryPath,
            Dictionary<string, byte[]> dicEmbeddedImages)
        {
            
            SendMail.MailHandler mailHandler = new SendMail.MailHandler();
            SendMail.AttachedFile[] attachments = null;
            if(filesNames != null)
                attachments = attachFiles(filesNames, directoryPath);
            //mailHandler.SendMailCompleted += new SendMail.SendMailCompletedEventHandler(mailHandler_SendMailCompleted);

            if (dicEmbeddedImages != null)
            {
                SendMail.EmbeddedImage[] arrEmbeddedImages = new SendMail.EmbeddedImage[dicEmbeddedImages.Count];
                setEmbeddeImages(arrEmbeddedImages, dicEmbeddedImages);
                mailHandler.SendMailWithEmbeddedImageAsync(from, to, cc, mailSubject, mailBody, arrEmbeddedImages, true, attachments, mailServerName);
            }
            else // If there is no images at the mail body
                mailHandler.SendMailAsync(from, to, cc, mailSubject, mailBody, true, attachments, mailServerName);

        }

        private static void setEmbeddeImages(SendMail.EmbeddedImage[] arrEmbeddedImages, Dictionary<string, byte[]> dicEmbeddedImages)
        {
            int i = 0;
            foreach (var item in dicEmbeddedImages)
            {
                SendMail.EmbeddedImage l = new SendMail.EmbeddedImage();
                arrEmbeddedImages[i] = new SendMail.EmbeddedImage();
                l.ContentID = item.Key;
                l.FileStream = item.Value;
                arrEmbeddedImages[i] = l;
                i++;
            }
            
            
        }

        //static void mailHandler_SendMailCompleted(object sender, System.ComponentModel.AsyncCompletedEventArgs e)
        //{
        //    if (e.Error != null)
                
        //}

        private static SendMail.AttachedFile[] attachFiles(string[] filesNames, string directoryPath)
        {
            byte[] byteArray = null;
            SendMail.AttachedFile[] arrFiles = new SendMail.AttachedFile[filesNames.Length];
            int i = 0;
            
            foreach (string fileName in filesNames)
            {
                byteArray = System.IO.File.ReadAllBytes(directoryPath + "\\" + fileName);
                arrFiles[i] = new SendMail.AttachedFile();
                arrFiles[i].ContentStream = byteArray;
                arrFiles[i].FileName = fileName;
                i++;
            }

            return arrFiles;
        }

    }
}
