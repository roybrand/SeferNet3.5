using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clalit.SeferNet.Entities
{
    public partial class VMessageInfoLanguages
    {
        /// <summary>
        /// returns the translated message, if there is no translated message it returns 
        /// the basic usermessage
        /// </summary>
        public string MessageDefault
        {
            get
            {
                string retVal = string.Empty;

                if (string.IsNullOrEmpty(LanguageMessageText) == true)
                {
                    retVal = UserMessageText;
                }
                else
                {
                    retVal = LanguageMessageText;
                }

                return LanguageMessageText;
            }
        }
    }
}
