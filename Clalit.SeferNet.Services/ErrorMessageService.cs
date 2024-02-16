using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.SeferNet.EntitiesBL;
using Clalit.Global.EntitiesDal;
using Clalit.SeferNet.Entities;


namespace Clalit.SeferNet.Services
{
    public class ErrorMessageService : IErrorMessageService
    {
        #region IErrorMessageService Members
        private const string _DefaultMessage = "General Error";

        public string GetUserErrorMessage(int messageCode)
        {
          //********************TO BE ADDED
          //this will go instead of the rows at the bottom
            VMessageInfoLanguagesBL miBL = new VMessageInfoLanguagesBL();
            //dal.GetAllMessageInfo();
          //Clalit.Confirmation.GeneratedEnums.eMessageInfo

           VMessageInfoLanguages message = miBL.GetMessageInfo(messageCode);
           if (message != null)
           {
               return string.Format("{0}({1})",message.MessageDefault,messageCode);
           }
           else
           {
               return string.Format("{0}({1})", _DefaultMessage, messageCode);
           }
        }

        #endregion
    }   
}
