using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.DataLayer;
using System.Data;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class phoneHandler
    {
        string m_ConnStr;

        public phoneHandler()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang(); 
        }

        public DataSet GetDeptFirstPhone(int deptCode)
        {
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);

            DataSet ds = phoneDB.GetDeptFirstPhone(deptCode);
            return ds;
        }


        public DataSet getPhonePrefixListAll()
        {
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);
            return phoneDB.getPhonePrefixListAll();
        }

        public int DeletePhonePrefix(int p_prefixCode)
        {
            int ErrorCode = 0;
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);
            ErrorCode = phoneDB.DeletePhonePrefix(p_prefixCode);

            if (ErrorCode != 0)
            {
                switch (ErrorCode)
                {
                    case 2627: //duplicate key
                        System.Web.HttpContext.Current.Session["ErrorMessage"] = System.Web.HttpContext.GetGlobalResourceObject("ErrorResource", "IsAlreadyExists") as string;
                        break;

                    case 547: //Data constraint violation
                        System.Web.HttpContext.Current.Session["ErrorMessage"] = System.Web.HttpContext.GetGlobalResourceObject("ErrorResource", "ConstraintViolation") as string;
                        break;

                    default:
                        System.Web.HttpContext.Current.Session["ErrorMessage"] = System.Web.HttpContext.GetGlobalResourceObject("ErrorResource", "generalInsertError") as string;
                        break;
                }
            }

            return ErrorCode;
        }

        public int InsertPhonePrefix(string p_prefixValue, int p_phoneType)
        { 
            int ErrorCode = 0;
            int NewPrefixCode = 0;
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);
            NewPrefixCode = phoneDB.InsertPhonePrefix(ref ErrorCode, p_prefixValue, p_phoneType);

            return NewPrefixCode;
        }

        public void UpdatePhonePrefix(int p_prefixCode, string p_prefixValue, int p_phoneType)
        { 
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);
            phoneDB.UpdatePhonePrefix(p_prefixCode, p_prefixValue, p_phoneType);
        }
    }
}
