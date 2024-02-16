using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.Infrastructure.ServiceInterfaces;
using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using System.Diagnostics;
using LogClalitLibrary;
using Clalit.Infrastructure.ServicesManager;

namespace Clalit.SeferNet.Services
{
    public class SaveErrorToDBService : ISaveErrorToDBService
    {
        #region ISaveErrorToDBService Members

        public void Save(Exception ex, object additionalData)
        {
             //here we'll save to the DB - 
            //either directly from the BL or from the 
            //or from the logging infra ( when it's ready )
          //   additionalData as Clalit.

            string systemMessageText = string.Empty;
            string userMessageText = string.Empty;
            int errorMessageId = 0;
            string className;
            string methodName;

            ExceptionExtraInfo info = additionalData as ExceptionExtraInfo;
            if (info != null)
            {
                errorMessageId = SetErrorMessageId(errorMessageId, info);

                SetUserAndSystemMessage(ref systemMessageText, ref userMessageText, info);
            }          

           
            SetClassNameAndMethodName(ex, out className, out methodName);
            ILoggedInUserService loggedinUserServ = ServicesManager.GetService<ILoggedInUserService>();
            string loggedInUserId = string.Empty;
            if (loggedinUserServ != null)
            {
                loggedInUserId = loggedinUserServ.GetUserId();
            }

            Logger.SendLog(
                new LogRequest(
                    errorMessageId,           //the messageId - relevant to the applicative message - like failed approving customer...
                    LogClalitLibrary.SeverityLevel.Error,
                    systemMessageText,
                    ex,
                    className,
                    loggedInUserId,
                    LogTraceLevel.Exception));  // the type means - which application sent the message - confirmation/sefer sherut...

        }

        private static int SetErrorMessageId(int errorMessageId, ExceptionExtraInfo info)
        {
            object errorMessageIdObj = ExceptionExtraInfoHelper.GetValueByKey(info, eExceptionExtraInfoKey.ErrorMessageID);
            if (errorMessageIdObj != null)
            {
                int.TryParse(errorMessageIdObj.ToString(), out errorMessageId);
            }
            return errorMessageId;
        }

        private static void SetUserAndSystemMessage(ref string systemMessageText, ref string userMessageText, ExceptionExtraInfo info)
        {
            //in case there was no system message, we take it from the user message

            userMessageText = ExceptionExtraInfoHelper.GetValueByKey(info, eExceptionExtraInfoKey.UserErrorMessage) as string;
            systemMessageText = ExceptionExtraInfoHelper.GetValueByKey(info, eExceptionExtraInfoKey.SystemErrorMessage) as string;
            if (string.IsNullOrEmpty(systemMessageText) == true)
            {
                systemMessageText = userMessageText;
            }
        }
        
        private static void SetClassNameAndMethodName(Exception ex, out string className, out string methodName)
        {
            className = string.Empty;
            methodName = string.Empty;
            StackTrace st = new StackTrace(ex);
            StackFrame sf = st.GetFrame(st.FrameCount - 1);
            className = sf.GetMethod().DeclaringType.FullName;
            methodName = sf.GetMethod().Name;
        }

        #endregion
    }
}
