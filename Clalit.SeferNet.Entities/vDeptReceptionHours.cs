//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Clalit.SeferNet.Entities
{
    using System;
    using System.Collections.Generic;
    
    [Serializable()]
    public partial class vDeptReceptionHours
    {
        public int receptionID { get; set; }
        public int deptCode { get; set; }
        public int receptionDay { get; set; }
        public string openingHour { get; set; }
        public string closingHour { get; set; }
        public string RemarkText { get; set; }
        public string openingHourText { get; set; }
        public Nullable<byte> ReceptionHoursTypeID { get; set; }
        public string ReceptionTypeDescription { get; set; }
    }
}