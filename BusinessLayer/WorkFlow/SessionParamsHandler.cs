using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.BusinessLayer.BusinessObject;
using System.Web;

namespace SeferNet.BusinessLayer.WorkFlow
{ 
    public static class SessionParamsHandler
    {
        public static SessionParams GetSessionParams()
        {
            if (HttpContext.Current.Session["SessionParameters"] == null)
            {
                HttpContext.Current.Session["SessionParameters"] = new SessionParams();
            }
            return HttpContext.Current.Session["SessionParameters"] as SessionParams;
        }

        public static void SetSessionParams(SessionParams sessionParams)
        {
            HttpContext.Current.Session["SessionParameters"] = sessionParams;
        }
        
        public static string GetPageCounter()
        {           
            return GetSessionParams().counter.ToString();
        }

        /*
        public static string GetLastSearchPageURL()
        {
            SessionParams sessionParams = this.getSessionParams();
            return sessionParams.LastSearchPageURL.ToString();
        }

        public static string GetCallerPageUrl()
        {
            SessionParams sessionParams = GetSessionParams();
            return sessionParams.CallerUrl;
        }
        */
        public static void SetLastSearchPageURL(string lastSearchPageName)
        {
            SessionParams sessionParams = GetSessionParams();
            
            sessionParams.LastSearchPageURL = @"~/" + lastSearchPageName;
            SetSessionParams(sessionParams);                        
        }
        
        public static SweepingRemarksParameters GetSweepingRemarksParameters()
        {
            if (HttpContext.Current.Session["SweepingRemarksParameters"] == null)
            {
                HttpContext.Current.Session["SweepingRemarksParameters"] = new SweepingRemarksParameters();
            }
            return HttpContext.Current.Session["SweepingRemarksParameters"] as SweepingRemarksParameters;
        }

      
        public static void SetSweepingRemarksParameters(SweepingRemarksParameters sweepingRemarksParameters)
        {
            HttpContext.Current.Session["SweepingRemarksParameters"] = sweepingRemarksParameters;
        }


        public static void ClearSweepingRemarksParameters()
        {
            HttpContext.Current.Session["SweepingRemarksParameters"] = null;
        }

		public static GeneralRemarkParameters GeneralRemarkParametersUI
		{
			get
			{
				if (HttpContext.Current.Session[typeof(GeneralRemarkParameters).Name] != null)
				{
					return HttpContext.Current.Session[typeof(GeneralRemarkParameters).Name ] as GeneralRemarkParameters;
				}
				else return null;
			}
			set
			{
				HttpContext.Current.Session[typeof(GeneralRemarkParameters).Name] = value;
			}
		}
         
      
        public static void IncrementPageCounter()
        {
            //update the deptcode field, in the object stored in session, with the selected deptcode
            SessionParams sessionParams = GetSessionParams();

            sessionParams.counter++;
        }

        
        // Vladimir 17/06/2009
        public static string GetDeptNameFromSession()
        {
            return GetSessionParams().DeptName;
        }

        
        public static void SetDeptNameInSession(string DeptName)
        {
            //update the deptname field, in the object stored in session, with the selected deptcode
            GetSessionParams().DeptName = DeptName;
        }        

        public static void SetEmployeeIDInSession(Int64 employeeID)
        {
            
            GetSessionParams().EmployeeID = employeeID;
        }

        
        public static void RemoveEmployeeCodeFromSession()
        {            
            GetSessionParams().EmployeeID = 0;            
        }

        
        public static void SetDeptCodeInSession(int DeptCode)
        {
            //update the deptcode field, in the object stored in session, with the selected deptcode
            GetSessionParams().DeptCode = DeptCode;
        }        

        public static int GetDeptCodeFromSession()
        {
            return GetSessionParams().DeptCode;            
        }

         

        public static long GetEmployeeIdFromSession()
        {
            //update the deptname field, in the object stored in session, with the selected deptcode     
   
            return GetSessionParams().EmployeeID;
        }

        
        public static void SetEmployeeNameToSession(string EmployeeName)
        {
            //update the deptcode field, in the object stored in session, with the selected deptcode
            GetSessionParams().EmployeeName = EmployeeName;
        }
        

        public static string GetEmployeeNameFromSession()
        {
            //update the deptname field, in the object stored in session, with the selected deptcode
            return GetSessionParams().EmployeeName;
        }

        
        public static void RemoveDeptCodeFromSession()
        {            
            GetSessionParams().DeptCode = 0;
        }         
        
         
    }

}
