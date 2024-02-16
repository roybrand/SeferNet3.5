using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.Infrastructure.ServiceInterfaces;
using System.Web;
using SeferNet.BusinessLayer.BusinessObject;

namespace Clalit.SeferNet.Services
{
    public class LoggedInUserService : ILoggedInUserService
    {
        #region ILoggedInUserService Members

        public string GetUserId()
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

        public int UserLanguageId
        {
            get
            {
                //default language id
               int languageId = (int)Clalit.SeferNet.GeneratedEnums.eApplicationLanguage.Hebrew;

               if (HttpContext.Current != null && HttpContext.Current.Session["LanguageId"] != null)
               {
                 languageId =  Convert.ToInt32(HttpContext.Current.Session["LanguageId"]);
               }

               return languageId;
            }
            set
            {
                if (HttpContext.Current != null )
                {
                   HttpContext.Current.Session["LanguageId"] = value;
                }
            }
        }

        #endregion
    }
}
