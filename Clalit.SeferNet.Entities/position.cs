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
    public partial class position
    {
        public int positionCode { get; set; }
        public int gender { get; set; }
        public string positionDescription { get; set; }
        public Nullable<int> relevantSector { get; set; }
        public Nullable<System.DateTime> UpdateDate { get; set; }
        public string UpdateUser { get; set; }
        public int useInSearches { get; set; }
        public Nullable<byte> IsActive { get; set; }
    }
}
