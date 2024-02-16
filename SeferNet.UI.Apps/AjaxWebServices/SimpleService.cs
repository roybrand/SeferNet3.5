using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Linq;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System;
using System.ComponentModel;
using System.Data.SqlClient;
using System.Configuration;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;

/// <summary>
/// Summary description for SimpleService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
[System.Web.Script.Services.ScriptService]
public class SimpleService : System.Web.Services.WebService
{
    SessionParams sessionParams;

    public SimpleService()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod(true)]
    public bool SetSelectedTabInSession(string selectedTabKey)
    {
        sessionParams = SessionParamsHandler.GetSessionParams();
        sessionParams.SelectedTab_Key = selectedTabKey;
        return true;
    }

    [WebMethod(true)]
    public void NoteChangedRows(int rowIndex)
    {
        List<Int32> list = null;

        if (Session["List"] == null)
        {
            list = new List<int>();

            if (list.Contains(rowIndex)) return;

            list.Add(rowIndex);
            Session["List"] = list;
        }

        else
        {
            list = Session["List"] as List<Int32>;

            if (list.Contains(rowIndex)) return;

            list.Add(rowIndex);
        }
    }


    [WebMethod(true)]
    public void NoteDeletedRows(int rowIndex)
    {
        List<Int32> list = null;

        if (Session["deleteList"] == null)
        {
            list = new List<int>();

            if (list.Contains(rowIndex)) return;

            list.Add(rowIndex);
            Session["deleteList"] = list;
        }

        else
        {
            list = Session["deleteList"] as List<Int32>;

            if (list.Contains(rowIndex)) return;

            list.Add(rowIndex);
        }
    }

    [WebMethod]
    public string[] GetCompletionList(string prefixText, int count)
    {
        if (count == 0)
        {
            count = 10;
        }

        Random random = new Random();
        List<string> items = new List<string>(count);
        for (int i = 0; i < count; i++)
        {
            char c1 = (char)random.Next(65, 90);
            char c2 = (char)random.Next(97, 122);
            char c3 = (char)random.Next(97, 122);

            items.Add(prefixText + c1 + c2 + c3);
        }

        return items.ToArray();
    }


    
       
        

}

