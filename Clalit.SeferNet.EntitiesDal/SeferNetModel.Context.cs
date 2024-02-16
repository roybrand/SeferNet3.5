﻿//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Clalit.SeferNet.EntitiesDal
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using Clalit.SeferNet.Entities;
    using System.Data.Objects;
    
    public partial class SeferNetEntities : DbContext
    {
        public SeferNetEntities()
            : base("name=SeferNetEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public DbSet<View_Events> View_Events { get; set; }
        public DbSet<position> position { get; set; }
        public DbSet<View_CacheTablesRefreshingSP> View_CacheTablesRefreshingSP { get; set; }
        public DbSet<VMessageInfoLanguages> VMessageInfoLanguages { get; set; }
        public DbSet<View_AllDeptAddressAndPhone> View_AllDeptAddressAndPhone { get; set; }
        public DbSet<vAllDeptDetails> vAllDeptDetails { get; set; }
        public DbSet<vEmployeeReceptionHours> vEmployeeReceptionHours { get; set; }
        public DbSet<View_DeptRemarks> View_DeptRemarks { get; set; }
        public DbSet<vEmployeeReceptionRemarks> vEmployeeReceptionRemarks { get; set; }
        public DbSet<vDeptReceptionHours> vDeptReceptionHours { get; set; }
        public DbSet<vDeptEvents> vDeptEvents { get; set; }
        public DbSet<vDummy_LastUpdateDateOfRemarks> vDummy_LastUpdateDateOfRemarks { get; set; }
        public DbSet<vEmployeeDeptRemarks> vEmployeeDeptRemarks { get; set; }
        public DbSet<vReceptionDaysForDisplay> vReceptionDaysForDisplay { get; set; }
        public DbSet<vDeptServices> vDeptServices { get; set; }
        public DbSet<vServicesAndQueueOrder> vServicesAndQueueOrder { get; set; }
        public DbSet<vServicesReceptionWithRemarks> vServicesReceptionWithRemarks { get; set; }
        public DbSet<vDeptServicesRemarks> vDeptServicesRemarks { get; set; }
        public DbSet<vEmployeeProfessionalDetails> vEmployeeProfessionalDetails { get; set; }
        public DbSet<View_DeptDetails> View_DeptDetails { get; set; }
    
        public virtual ObjectResult<vAllDeptDetails> GetZoomClinicTemplate(Nullable<int> deptCode, Nullable<bool> isInternal, string deptCodesInArea)
        {
            ((IObjectContextAdapter)this).ObjectContext.MetadataWorkspace.LoadFromAssembly(typeof(vAllDeptDetails).Assembly);
    
            var deptCodeParameter = deptCode.HasValue ?
                new ObjectParameter("DeptCode", deptCode) :
                new ObjectParameter("DeptCode", typeof(int));
    
            var isInternalParameter = isInternal.HasValue ?
                new ObjectParameter("IsInternal", isInternal) :
                new ObjectParameter("IsInternal", typeof(bool));
    
            var deptCodesInAreaParameter = deptCodesInArea != null ?
                new ObjectParameter("DeptCodesInArea", deptCodesInArea) :
                new ObjectParameter("DeptCodesInArea", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<vAllDeptDetails>("GetZoomClinicTemplate", deptCodeParameter, isInternalParameter, deptCodesInAreaParameter);
        }
    
        public virtual ObjectResult<vAllDeptDetails> GetZoomClinicTemplate(Nullable<int> deptCode, Nullable<bool> isInternal, string deptCodesInArea, MergeOption mergeOption)
        {
            ((IObjectContextAdapter)this).ObjectContext.MetadataWorkspace.LoadFromAssembly(typeof(vAllDeptDetails).Assembly);
    
            var deptCodeParameter = deptCode.HasValue ?
                new ObjectParameter("DeptCode", deptCode) :
                new ObjectParameter("DeptCode", typeof(int));
    
            var isInternalParameter = isInternal.HasValue ?
                new ObjectParameter("IsInternal", isInternal) :
                new ObjectParameter("IsInternal", typeof(bool));
    
            var deptCodesInAreaParameter = deptCodesInArea != null ?
                new ObjectParameter("DeptCodesInArea", deptCodesInArea) :
                new ObjectParameter("DeptCodesInArea", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<vAllDeptDetails>("GetZoomClinicTemplate", mergeOption, deptCodeParameter, isInternalParameter, deptCodesInAreaParameter);
        }
    }
}
