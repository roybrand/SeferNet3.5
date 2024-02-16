using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public  class ReceptionTimeInfo
    {
        public string ReceptionDays { get; set; }
        public string FromHour { get; set; }
        public string ToHour { get; set; }
        public string InHour { get; set; }
        public bool OpenNow { get; set; }

        public virtual void PrepareParametersForDBQuery()
        {
            ReceptionDays = StringHelper.GetCleanStringAndSetToNullIfRequired(ReceptionDays);
            FromHour = StringHelper.GetCleanStringAndSetToNullIfRequired(FromHour);
            ToHour = StringHelper.GetCleanStringAndSetToNullIfRequired(ToHour);
            InHour = StringHelper.GetCleanStringAndSetToNullIfRequired(InHour);          
        }
    }
}
