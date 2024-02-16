using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clalit.SeferNet.Entities
{
    public partial class vDeptEvents
    {
        public string FirstEventDateFormatted
        {
            get
            {
                string retVal;

                if (FirstEventDate != null)
                    retVal = FirstEventDate.Value.ToString("dd/MM/yyyy");
                else
                    retVal = string.Empty;

                return retVal;
            }
        }

    }
}
