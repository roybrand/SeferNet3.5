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
    public partial class vDeptEvents
    {
        public int EventCode { get; set; }
        public string EventName { get; set; }
        public string registrationStatusDescription { get; set; }
        public int MeetingsNumber { get; set; }
        public Nullable<System.DateTime> FirstEventDate { get; set; }
        public int deptCode { get; set; }
        public int DeptEventID { get; set; }
        public System.DateTime fromDate { get; set; }
        public System.DateTime toDate { get; set; }
    }
}
