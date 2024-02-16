<%@ WebHandler Language="C#" Class="SendFax" %>

using System;
using System.Web;
using SeferNet.BusinessLayer.WorkFlow;
using Clalit.Infrastructure.ApplicationFileManager;
using System.Text;

public class SendFax : IHttpHandler {

    string _faxNumber;
    string FaxNumber
    {
        set
        {
            if (!string.IsNullOrEmpty(value))
            {
                
                if (value.Substring(0, 1) == "0")
                {
                    _faxNumber = "+972-" + value.Remove(0, 1);
                }
                else
                {
                    _faxNumber = "+972-" + value;
                }     
            }
            
        }
        get
        {
            return _faxNumber;
        }
    }
    
    
    
    public void ProcessRequest (HttpContext context) {
        string filesNames = "";
        filesNames = (string.IsNullOrEmpty(context.Request.Form["fNames"]) ? "" : context.Request.Form["fNames"].ToString());
        FaxNumber = context.Request.Form["fNumber"];

        if (filesNames != "" && FaxNumber != "")
        {
            try
            {
                string[] files = filesNames.Split('~');
                foreach (string file in files)
                {
                    sendFax(file, FaxNumber);    
                }
                
                context.Response.Write("1");// Success
            }
            catch (Exception ex)
            {
                Matrix.ExceptionHandling.ExceptionHandlingManager mgr = new Matrix.ExceptionHandling.ExceptionHandlingManager();
                mgr.Publish(ex, new Clalit.Exceptions.ExceptionData.ErrorMessagExtraInfoGenerator((int)Clalit.SeferNet.GeneratedEnums.eDIC_ErrorMessageInfo.BugInSendingFax),
                  new Clalit.Exceptions.ExceptionData.WebPageExtraInfoGenerator());
                context.Response.Write("0");// Failure
            }
        }
        else
        {
            context.Response.Write("3");// Missing details
        }
        
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

    private void sendFax(string fName, string fNumber)
    {
        string fullPath = "";
        string formsAndBrochuresPath = System.Configuration.ConfigurationManager.AppSettings["formsAndBrochuresPath"].ToString();
        SendMessage msg = new SendMessage();
        FileManager fileManager = new FileManager();
        string userName = string.Empty;
        
        fullPath = formsAndBrochuresPath + "\\" + fName;

        string content = fileManager.GetFileContent(fullPath, Encoding.GetEncoding("iso-8859-8-i"));
        msg.SendFax(content, fNumber, "pdf", userName);
    }
    

}