using System;
using System.Web;
using System.Diagnostics;
using System.Data;
using System.Data.SqlClient;
using System.Web.Mail;
using System.Text;
using System.Reflection;
namespace PAB.ExceptionHandler
{	 
	public class  ExceptionLogger  
	{
		private static bool logExceptions = Convert.ToBoolean(System.Configuration.ConfigurationSettings.AppSettings["logExceptions"]);
		private static bool sendSysLogMessages =  Convert.ToBoolean(System.Configuration.ConfigurationSettings.AppSettings["sendSysLogMessages"]);
		private static string sysLogIp=System.Configuration.ConfigurationSettings.AppSettings["sysLogIp"];

		private ExceptionLogger( ) //pvt ctor, all methods static
		{ 
		}	

		public static void WriteToLog( Exception ex, string msgDetails)
		{
			if(!logExceptions) return; // user set web.config setting to false, abort
			HttpContext ctx = HttpContext.Current;	
			string strData=String.Empty;
			Guid eventId =	System.Guid.NewGuid();			 
           string dbConnString=
	System.Configuration.ConfigurationSettings.AppSettings["exceptionLogConnString"].ToString();				
		 string referer=String.Empty;
         string appName = System.Environment.MachineName + "_" + Assembly.GetCallingAssembly().FullName;

         string appPath = ctx.Request.Url.AbsoluteUri;
				if(ctx.Request.ServerVariables["HTTP_REFERER"]!=null)
				{
					referer = ctx.Request.ServerVariables["HTTP_REFERER"].ToString();
				}
		string sForm = 
			(ctx.Request.Form !=null)?ctx.Request.Form.ToString():String.Empty;
        
        string Data = "";
        StringBuilder sb = new StringBuilder();
        if (ex.Data.Count > 0)
        {
            foreach (object key in ex.Data.Keys)
            {
                sb.Append((string)key);
                sb.Append("=");
                sb.Append((string)ex.Data[key]);
                sb.Append("|");
            }
            sb.Remove(sb.Length - 1, 1);
            Data = sb.ToString();
        }
            
               
      
       //string logDateTime =DateTime.Now.ToString();
        string sQuery =
			(ctx.Request.QueryString !=null)?ctx.Request.QueryString.ToString():String.Empty;
        strData = "\nSOURCE: " + ex.Source +
        "\nAppName: " + appName+
        //"\nLogDateTime: " + logDateTime +
        "\nMESSAGE: " + ex.Message +
       "\nFORM: " + sForm +
       "\nQUERYSTRING: " + sQuery +
       "\nTARGETSITE: " + ex.TargetSite +
       "\nSTACKTRACE: " + ex.StackTrace +
       "\nREFERER: " + referer +
       "\nDATA: " + Data +
       "\nPath: " + appPath;
				
		if(sendSysLogMessages)Sender.Send(Sender.PriorityType.Critical,DateTime.Now,strData);
			
		if(dbConnString.Length >0)
			{                 	
				SqlCommand cmd = new SqlCommand();
				cmd.CommandType=CommandType.StoredProcedure;
				cmd.CommandText="usp_WebAppLogsInsert";
				SqlConnection cn = new SqlConnection(dbConnString);
				cmd.Connection=cn;
				cn.Open(); 
 				
				try
				{	
				cmd.Parameters.Add(new SqlParameter("@EventId",eventId ));
                cmd.Parameters.Add(new SqlParameter("@AppName", appName));
                if(ex.Source!= null)
				    cmd.Parameters.Add(new SqlParameter("@Source", ex.Source));
                else
                    cmd.Parameters.AddWithValue("@Source", string.Empty);

				//cmd.Parameters.Add(new SqlParameter("@LogDateTime", logDateTime));
                string completeMessage = ex.Message;
                if (!String.IsNullOrEmpty(msgDetails))
                {
                    completeMessage = ex.Message + "\n"+msgDetails;
                }

                cmd.Parameters.Add(new SqlParameter("@Message", completeMessage)); 
                cmd.Parameters.Add(new SqlParameter("@Form", sForm));
				cmd.Parameters.Add(new SqlParameter("@QueryString",sQuery));
                if(ex.TargetSite != null)
				    cmd.Parameters.Add(new SqlParameter("@TargetSite",ex.TargetSite.ToString()));
                else
				    cmd.Parameters.AddWithValue("@TargetSite",string.Empty);
                if(ex.StackTrace != null)
				    cmd.Parameters.Add(new SqlParameter("@StackTrace",ex.StackTrace.ToString()));
                else
                    cmd.Parameters.AddWithValue("@StackTrace", string.Empty);

				cmd.Parameters.Add(new SqlParameter("@Referer",referer));
                cmd.Parameters.Add(new SqlParameter("@Data", Data));
                cmd.Parameters.Add(new SqlParameter("@Path", appPath));
				cmd.ExecuteNonQuery();				
				cmd.Dispose();
				cn.Close();			
				}
				catch (Exception exc)
				{
				 // database error, not much you can do here except for debugging
	         	 System.Diagnostics.Debug.WriteLine(exc.Message);
				}
				finally
				{
				cmd.Dispose();
				cn.Close();
				}			   
			}
	
     //   string strEmails =System.Configuration.ConfigurationSettings.AppSettings["emailAddresses"].ToString();
     //   if (strEmails.Length >0) 
     //       {
     //           string[] emails = strEmails.Split(Convert.ToChar(";"));
     //           string fromEmail=System.Configuration.ConfigurationSettings.AppSettings["fromEmail"].ToString();	 
     //           string subject = "Web application error on " +System.Environment.MachineName;
     //           string detailURL=System.Configuration.ConfigurationSettings.AppSettings["detailURL"].ToString();
     //           string fullMessage=strData + detailURL +"?EvtId="+ eventId.ToString();	
     //           string SmtpServer =System.Configuration.ConfigurationSettings.AppSettings["smtpServer"].ToString();
     //           System.Web.Mail.MailMessage msg = new MailMessage();
     //           string ccs=String.Join(";",emails,1,emails.Length -1);
     //           msg.To =emails[0];
     //           msg.From =fromEmail;
     //           msg.Cc=ccs;
     //           msg.Body=fullMessage;
     //           msg.Subject =subject;
     //           try
     //           {						 
     //               System.Web.Mail.SmtpMail.Send(msg);					
     //           }
     //           catch (Exception excm )
     //           {
     //               Debug.WriteLine(excm.Message);
     //               // nothing worthwhile to do here other than for debugging.
     //           }
     //     }
     } // end method HandleException
   }
}