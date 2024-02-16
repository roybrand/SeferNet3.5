using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;

/// <summary>
/// Summary description for AsyncCallbackHelper
/// </summary>
public  class AsyncCallbackHelper
{
    private Dictionary<string, List<string>> _CallbackFunctionsDictionary = new Dictionary<string, List<string>>();
    public Page CurrentPage { get; set; }
    private Control _CallbackEventHandlerControl;

    /// <summary>
    /// register the items in the dictionary to be called asynchronized from javascript to server
    /// </summary>
    /// <param name="page"></param>
    /// <param name="callbackFunctionsDictionary">each item contain the name of the Javascript function
    /// and its list is the parameters that are sent to the server  (if required )
    /// for example we have a javascript function 'OnLoginFinished' that will be called after going to the server
    /// and back from the server, its parameters will be 'username','password' so that's what we define as 1 item
    /// of the dictionary, 
    /// we can have many JS functions like that with their parameter that we can register to be called
    /// asynchronized
    /// </param>
    public AsyncCallbackHelper(Control callbackEventHandlerControl, Dictionary<string, List<string>> callbackFunctionsDictionary)
    {
        _CallbackEventHandlerControl = callbackEventHandlerControl;
        CurrentPage = _CallbackEventHandlerControl.Page;

        _CallbackFunctionsDictionary = callbackFunctionsDictionary;
       
        foreach (KeyValuePair<string, List<string>> item in _CallbackFunctionsDictionary)
        {
            AddAsyncCallbackFromJS(item.Key);
        }
    }

    void AddAsyncCallbackFromJS(string jsLoginFinished)
    {
        string js = CurrentPage.ClientScript.GetCallbackEventReference(_CallbackEventHandlerControl, "arg",
     jsLoginFinished, "ctx", true);

        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("function " + GetCallServerForFunctionName(jsLoginFinished) + @"(arg, ctx) {");
        sb.Append(js);
        sb.Append("}");
        CurrentPage.ClientScript.RegisterClientScriptBlock(this.GetType(),
           jsLoginFinished + "Key", sb.ToString(), true);

        BuildJSRaiseDoActionAtServerMethod(jsLoginFinished);
    }

    void BuildJSRaiseDoActionAtServerMethod(string jsLoginFinished)
    {
        string buildParamValue = "'" + jsLoginFinished + "'";
        string buildArgs = string.Empty;

        for (int i = 0; i < _CallbackFunctionsDictionary[jsLoginFinished].Count; i++)
        {
            buildParamValue += "+';'+" + _CallbackFunctionsDictionary[jsLoginFinished][i];

            buildArgs += i == 0 ? string.Empty : ",";
            buildArgs += _CallbackFunctionsDictionary[jsLoginFinished][i];
        }

        string methodDef = @" function "
           + GetRaiseDoActionAtServerFunctionName(jsLoginFinished) + @"(" + buildArgs + @") {            
            if (" + GetCallServerForFunctionName(jsLoginFinished) + @" != null) {"
                  + GetCallServerForFunctionName(jsLoginFinished)
                  + @"(" + buildParamValue + @", 'ctxParam');
            }                 
        }";

        CurrentPage.ClientScript.RegisterClientScriptBlock(this.GetType(),
            jsLoginFinished + "RaiseDoAction", methodDef, true);

    }

    private static string GetCallServerForFunctionName(string jsFunctionNameReturnedFromServer)
    {
        string retVal = string.Empty;

        retVal = "CallServerFor" + jsFunctionNameReturnedFromServer;

        return retVal;
    }

    private static string GetRaiseDoActionAtServerFunctionName(string jsFunctionNameReturnedFromServer)
    {
        string retVal = string.Empty;

        retVal = "RaiseDoActionAtServer" + jsFunctionNameReturnedFromServer;

        return retVal;
    }

}
