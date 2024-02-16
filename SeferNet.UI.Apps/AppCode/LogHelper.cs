using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using LogClalitLibrary;
using System.Data.Common;
using SeferNet.Globals;
using SeferNet.DataLayer.Base;
using System.Data;
using SeferNet.BusinessLayer.BusinessObject;
/// <summary>
/// Summary description for LogHelper
/// </summary>
public class LogHelper
{
    public LogHelper()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static string GetLogSessionExtraInfo()
    {
        string valToReturn = string.Empty;
        StringBuilder sb = new StringBuilder();
        if (HttpContext.Current != null)
        {
            if (HttpContext.Current.Request.Form.Keys.Count > 0)
            {
                sb.AppendLine("Request Form Variables");
                // HttpContext.Current.Request.QueryString
                foreach (object key in HttpContext.Current.Request.Form.Keys)
                {
                    //all the values except viewstate will be saved to log
                    if (key.ToString() != "__VIEWSTATE")
                    {
                        sb.Append(string.Format("{0}={1}, ", key, HttpContext.Current.Request.Form[key.ToString()]));
                    }
                }
            }

            //not sure we need it
            if (HttpContext.Current.Request.QueryString.Keys.Count > 0)
            {
                sb.AppendLine("Request QueryString Variables");
                // HttpContext.Current.Request.QueryString
                foreach (object key in HttpContext.Current.Request.QueryString.Keys)
                {
                    sb.Append(string.Format("{0}={1}, ", key, HttpContext.Current.Request.QueryString[key.ToString()]));
                }
            }

            valToReturn = sb.ToString();
        }

        return valToReturn;
    }

    public static string GetUserIdForExtraInfo()
    {
        string valToReturn = string.Empty;
        UserInfo userInfo = null;
        if (HttpContext.Current.Session != null)
        {
            userInfo = HttpContext.Current.Session["currentUser"] as UserInfo;
        }

        if (userInfo != null)
        {
            valToReturn = userInfo.UserNameWithPrefix;
        }
        else
        {
            valToReturn = "not logged in";
        }

        return valToReturn;
    }


    #region DBNotification handling

    public static void Init()
    {
        RegisterToBLFacadeActionNotification();
        RegisterToDBActionNotification();
        RegisterToBLGeneralActionNotification();
    }

    private static void RegisterToBLFacadeActionNotification()
    {
        BLFacadeActionNotifications.OnBLFacadeActionEnter += new OnBLFacadeActionDelegate(BLFacadeActionNotifications_OnBLFacadeActionEnter);
        BLFacadeActionNotifications.OnBLFacadeActionExit += new OnBLFacadeActionDelegate(BLFacadeActionNotifications_OnBLFacadeActionExit);
    }

    private static void RegisterToBLGeneralActionNotification()
    {
        BLGeneralActionNotifications.OnBLGeneralActionEnter += new OnBLGeneralActionDelegate(BLGeneralActionNotifications_OnBLGeneralActionEnter);
        BLGeneralActionNotifications.OnBLGeneralActionEnter += new OnBLGeneralActionDelegate(BLGeneralActionNotifications_OnBLGeneralActionExit);
    }

    private static void RegisterToDBActionNotification()
    {
        DBActionNotification.RegisterOnGetParametersMethod(new SqlDalEx().GetInputParameters);
        //not sure i need it
        DBActionNotification.OnDBUpdate -= new OnDBActionDelegate(DBActionNotification_OnDBUpdate);
        DBActionNotification.OnDBInsert -= new OnDBActionDelegate(DBActionNotification_OnDBInsert);
        DBActionNotification.OnDBDelete -= new OnDBActionDelegate(DBActionNotification_OnDBDelete);
        DBActionNotification.OnDBSelect -= new OnDBActionDelegate(DBActionNotification_OnDBSelect);
        //

        DBActionNotification.OnDBUpdate += new OnDBActionDelegate(DBActionNotification_OnDBUpdate);
        DBActionNotification.OnDBInsert += new OnDBActionDelegate(DBActionNotification_OnDBInsert);
        DBActionNotification.OnDBDelete += new OnDBActionDelegate(DBActionNotification_OnDBDelete);
        DBActionNotification.OnDBSelect += new OnDBActionDelegate(DBActionNotification_OnDBSelect);

        DBActionNotification.OnDBAction_targeted += new OnDBActionDelegate_targeted(DBActionNotification_OnDBAction);
    }

    static void BLFacadeActionNotifications_OnBLFacadeActionEnter(BLFacadeActionArg arg)
    {
        Logger.SendLog(new LogRequest(SeverityLevel.Information, "Entering method", LogHelper.GetUserIdForExtraInfo(), LogTraceLevel.DetailedTraceBLFacade, null, arg.SenderType));
    }

    static void BLFacadeActionNotifications_OnBLFacadeActionExit(BLFacadeActionArg arg)
    {
        Logger.SendLog(new LogRequest(SeverityLevel.Information, "Exiting method", LogHelper.GetUserIdForExtraInfo(), LogTraceLevel.DetailedTraceBLFacade, null, arg.SenderType));
    }
    static void BLGeneralActionNotifications_OnBLGeneralActionEnter(BLGeneralActionArg arg)
    {
        Logger.SendLog(new LogRequest(SeverityLevel.Information, arg.InfoMessage, LogHelper.GetUserIdForExtraInfo(), LogTraceLevel.DetailedTraceBLFacade, null, arg.SenderType));
    }

    static void BLGeneralActionNotifications_OnBLGeneralActionExit(BLGeneralActionArg arg)
    {
        Logger.SendLog(new LogRequest(SeverityLevel.Information, arg.InfoMessage, LogHelper.GetUserIdForExtraInfo(), LogTraceLevel.DetailedTraceBLFacade, null, arg.SenderType));
    }

    static void DBActionNotification_OnDBUpdate(string spName, IDataParameter[] paramCollection)
    {
        string className = string.Empty;
        string methodName = string.Empty;

        //i can get class name and method name from the previous frame
        //System.Diagnostics.StackTrace trace =  new System.Diagnostics.StackTrace();
        //System.Diagnostics.StackFrame frame =  trace.GetFrame(1);
        //System.Reflection.MethodBase mb = frame.GetMethod();
        //methodName = mb.Name;
        //className = frame.
        Logger.SendLog(new LogRequest(SeverityLevel.Information, string.Empty, className, methodName, LogHelper.GetUserIdForExtraInfo(), LogTraceLevel.DetailedTraceDalUpdate, null, new DBObjectInfo(spName, paramCollection)));
    }

    static void DBActionNotification_OnDBDelete(string spName, IDataParameter[] paramCollection)
    {
        string className = string.Empty;
        string methodName = string.Empty;

        //i can get class name and method name from the previous frame
        //System.Diagnostics.StackTrace trace =  new System.Diagnostics.StackTrace();
        //System.Diagnostics.StackFrame frame =  trace.GetFrame(1);
        //System.Reflection.MethodBase mb = frame.GetMethod();
        //methodName = mb.Name;
        //className = frame.
        Logger.SendLog(new LogRequest(SeverityLevel.Information, string.Empty, className, methodName, LogHelper.GetUserIdForExtraInfo(), LogTraceLevel.DetailedTraceDalDelete, null, new DBObjectInfo(spName, paramCollection)));
    }

    static void DBActionNotification_OnDBAction(int target_of_action, int changeType, int districtID, int adminClinicID, int clinicID)
    {
        string className = string.Empty;
        string methodName = string.Empty;

        //i can get class name and method name from the previous frame
        //System.Diagnostics.StackTrace trace =  new System.Diagnostics.StackTrace();
        //System.Diagnostics.StackFrame frame =  trace.GetFrame(1);
        //System.Reflection.MethodBase mb = frame.GetMethod();
        //methodName = mb.Name;
        //className = frame.
        Logger.SendLog(new LogRequest(target_of_action, SeverityLevel.Success, clinicID.ToString(), className, clinicID, LogHelper.GetUserIdForExtraInfo(), DateTime.Now, LogTraceLevel.DetailedTraceBLFacade));
    }

    static void DBActionNotification_OnDBSelect(string spName, IDataParameter[] paramCollection)
    {
        string className = string.Empty;
        string methodName = string.Empty;

        //i can get class name and method name from the previous frame
        //System.Diagnostics.StackTrace trace =  new System.Diagnostics.StackTrace();
        //System.Diagnostics.StackFrame frame =  trace.GetFrame(1);
        //System.Reflection.MethodBase mb = frame.GetMethod();
        //methodName = mb.Name;
        //className = frame.
        Logger.SendLog(new LogRequest(SeverityLevel.Information, string.Empty, className, methodName, LogHelper.GetUserIdForExtraInfo(), LogTraceLevel.DetailedTraceDalSelect, null, new DBObjectInfo(spName, paramCollection)));
    }

    static void DBActionNotification_OnDBInsert(string spName, IDataParameter[] paramCollection)
    {
        string className = string.Empty;
        string methodName = string.Empty;

        //i can get class name and method name from the previous frame
        //System.Diagnostics.StackTrace trace =  new System.Diagnostics.StackTrace();
        //System.Diagnostics.StackFrame frame =  trace.GetFrame(1);
        //System.Reflection.MethodBase mb = frame.GetMethod();
        //methodName = mb.Name;
        //className = frame.
        Logger.SendLog(new LogRequest(SeverityLevel.Information, string.Empty, className, methodName, LogHelper.GetUserIdForExtraInfo(), LogTraceLevel.DetailedTraceDalInsert, null, new DBObjectInfo(spName, paramCollection)));
    }

    #endregion
}
