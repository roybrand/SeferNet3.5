<%@ WebHandler Language="C#" Class="SendMail" %>
using SeferNet.Globals;
using System;
using System.IO;
using System.Web;
using System.Net.Mail;
using System.Collections.Generic;
public class SendMail : IHttpHandler {
    
    
    public void ProcessRequest (HttpContext context) {
        string to = "";
        string from = "";
        string subject = "";
        string emailClientName = "";
        string emailRemarks = "";
        string[] filesNames = null;
        string mailServerName = "";
        string template = "";
        string templatePath = "";
        string mailBody = "";
        string[] embeddeImages = null;
        string formsAndBrochuresPath = System.Configuration.ConfigurationManager.AppSettings["formsAndBrochuresPath"].ToString();
        Dictionary<string, byte[]> dicEmbeddedImages = null;
        
        if (context.Request.Form["subject"] != null)
            subject = context.Request.Form["subject"];
        if (context.Request.Form["to"] != null)
            to = context.Request.Form["to"];
        if (context.Request.Form["from"] != null)
            from = context.Request.Form["from"];
        if (context.Request.Form["emailClientName"] != null)
            emailClientName = context.Request.Form["emailClientName"];
        if (context.Request.Form["emailRemarks"] != null)
            emailRemarks = context.Request.Form["emailRemarks"];
        if (context.Request.Form["mailServerName"] != null)
            mailServerName = context.Request.Form["mailServerName"];
        if (context.Request.Form["filesNames"] != null)
            filesNames = context.Request.Form["filesNames"].ToString().Split('~');
        if (context.Request.Form["template"] != null)
        {
            template = context.Request.Form["template"];
            templatePath = context.Server.MapPath("~\\Templates\\Mails") + "\\" + template;
            mailBody = getMailBody(template, templatePath, emailClientName, emailRemarks);
        }
        if (context.Request.Form["embeddeImages"] != null)
        {
            embeddeImages = context.Request.Form["embeddeImages"].Split('~');
            dicEmbeddedImages = getEmbeddedImages(embeddeImages, context.Server.MapPath("~"));
        }
            
        


        try
        {
            MailHelper.send(from, to, "", subject, emailClientName, mailBody, mailServerName, filesNames, formsAndBrochuresPath, dicEmbeddedImages);
            context.Response.Write("1");// Success
        }
        catch (Exception ex)
        {
            Matrix.ExceptionHandling.ExceptionHandlingManager mgr = new Matrix.ExceptionHandling.ExceptionHandlingManager();
            mgr.Publish(ex, new Clalit.Exceptions.ExceptionData.ErrorMessagExtraInfoGenerator((int)Clalit.SeferNet.GeneratedEnums.eDIC_ErrorMessageInfo.BugInSendingEmail),
              new Clalit.Exceptions.ExceptionData.WebPageExtraInfoGenerator());
            context.Response.Write("0");// Failure
        }

    }

    private Dictionary<string, byte[]> getEmbeddedImages(string[] embeddeImages, string serverPath)
    {
        byte[] byteArray = null;
        Dictionary<string, byte[]> dicEmbeddeImages = new Dictionary<string, byte[]>();
        foreach (string s in embeddeImages)
        {
            byteArray = System.IO.File.ReadAllBytes(serverPath + "\\" + s.Split(':')[1]);
            dicEmbeddeImages.Add(s.Split(':')[0], byteArray);
        }

        
        
        return dicEmbeddeImages;
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
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}