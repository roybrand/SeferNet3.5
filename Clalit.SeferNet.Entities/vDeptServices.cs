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
    public partial class vDeptServices
    {
        public int DeptCode { get; set; }
        public int serviceCode { get; set; }
        public string serviceDescription { get; set; }
        public bool IsService { get; set; }
        public short ServiceStatus { get; set; }
    }
}
