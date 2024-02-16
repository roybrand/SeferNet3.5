using System;
using System.Collections.Generic;
using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Data;

public partial class DataContext : DbContext
{
    public DataContext()
    {
    }

    public DataContext(DbContextOptions<DataContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Dept> Depts { get; set; }

    public virtual DbSet<DicActivityStatus> DicActivityStatuses { get; set; }

    public virtual DbSet<DicAgreementType> DicAgreementTypes { get; set; }

    public virtual DbSet<DicTranslation> DicTranslations { get; set; }

    public virtual DbSet<DicYesAndNo> DicYesAndNos { get; set; }

    public virtual DbSet<Language> Languages { get; set; }

    public virtual DbSet<TableType> TableTypes { get; set; }

    public virtual DbSet<TimeStampHistory> TimeStampHistories { get; set; }

    public virtual DbSet<UnitType> UnitTypes { get; set; }

    public virtual DbSet<User> Users { get; set; }

    //public virtual DbSet Set(string name)
    //{
    //    // you may need to fill in the namespace of your context
    //    return base.Set(Type.GetType(name));
    //}

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.UseSqlServer("Name=ConnectionStrings:DefaultConnection");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Dept>(entity =>
        {
            entity.HasKey(e => e.DeptCode).HasName("PK_dept");

            entity.ToTable("Dept", "dbo");

            entity.HasIndex(e => e.AdministrationCode, "IX_Dept_AdministrationCode");

            entity.HasIndex(e => e.DistrictCode, "IX_Dept_DistrictCode");

            entity.HasIndex(e => e.SubAdministrationCode, "IX_Dept_SubAdministrationCode");

            entity.HasIndex(e => new { e.DeptName, e.Status }, "IX_Dept_deptName_status_i_else");

            entity.HasIndex(e => new { e.DeptType, e.Status, e.AdministrationCode }, "IX_Dept_deptType");

            entity.HasIndex(e => e.DeptName, "IX_Dept_name");

            entity.HasIndex(e => e.Status, "IX_Dept_status");

            entity.HasIndex(e => new { e.TypeUnitCode, e.AdministrationCode }, "IX_Dept_typeUnitCode");

            entity.HasIndex(e => e.Status, "ix_Dept__status");

            entity.HasIndex(e => new { e.SubAdministrationCode, e.TypeUnitCode, e.Status }, "ix_Dept__subAdministrationCode_typeUnitCode_status");

            entity.Property(e => e.DeptCode)
                .ValueGeneratedNever()
                .HasColumnName("deptCode");
            entity.Property(e => e.AddressComment)
                .HasMaxLength(500)
                .IsUnicode(false)
                .HasColumnName("addressComment");
            entity.Property(e => e.AdministrationCode).HasColumnName("administrationCode");
            entity.Property(e => e.AdministrativeManagerName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("administrativeManagerName");
            entity.Property(e => e.AllowContactHospitalUnit).HasDefaultValueSql("((0))");
            entity.Property(e => e.Building)
                .HasMaxLength(500)
                .IsUnicode(false);
            entity.Property(e => e.CascadeUpdateSubDeptPhones).HasDefaultValueSql("((0))");
            entity.Property(e => e.CityCode).HasColumnName("cityCode");
            entity.Property(e => e.DeptLevel).HasColumnName("deptLevel");
            entity.Property(e => e.DeptName)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("deptName");
            entity.Property(e => e.DeptNameFreePart)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("deptNameFreePart");
            entity.Property(e => e.DeptType).HasColumnName("deptType");
            entity.Property(e => e.DistrictCode).HasColumnName("districtCode");
            entity.Property(e => e.Email)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("email");
            entity.Property(e => e.Entrance)
                .HasMaxLength(1)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("entrance");
            entity.Property(e => e.Flat)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("flat");
            entity.Property(e => e.Floor)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("floor");
            entity.Property(e => e.House)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("house");
            entity.Property(e => e.Independent).HasColumnName("independent");
            entity.Property(e => e.IsCommunity)
                .IsRequired()
                .HasDefaultValueSql("((1))");
            entity.Property(e => e.LinkToBlank17)
                .HasMaxLength(500)
                .IsUnicode(false);
            entity.Property(e => e.LinkToContactUs)
                .HasMaxLength(500)
                .IsUnicode(false);
            entity.Property(e => e.ManagerName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("managerName");
            entity.Property(e => e.MfstreetCode)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("MFStreetCode");
            entity.Property(e => e.MfstreetName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("MFStreetName");
            entity.Property(e => e.NeighbourhoodOrInstituteCode)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Parking)
                .HasDefaultValueSql("((0))")
                .HasColumnName("parking");
            entity.Property(e => e.PopulationSectorCode).HasColumnName("populationSectorCode");
            entity.Property(e => e.ReligionCode).HasDefaultValueSql("((0))");
            entity.Property(e => e.ShowEmailInInternet).HasColumnName("showEmailInInternet");
            entity.Property(e => e.ShowUnitInInternet).HasColumnName("showUnitInInternet");
            entity.Property(e => e.Status).HasColumnName("status");
            entity.Property(e => e.StreetCode)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.StreetName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("streetName");
            entity.Property(e => e.SubAdministrationCode).HasColumnName("subAdministrationCode");
            entity.Property(e => e.SubUnitTypeCode).HasColumnName("subUnitTypeCode");
            entity.Property(e => e.TimeStamp)
                .IsRowVersion()
                .IsConcurrencyToken();
            entity.Property(e => e.Transportation)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("transportation");
            entity.Property(e => e.TypeUnitCode).HasColumnName("typeUnitCode");
            entity.Property(e => e.UpdateDate)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("smalldatetime")
                .HasColumnName("updateDate");
            entity.Property(e => e.UpdateUser)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("updateUser");
            entity.Property(e => e.ZipCode)
                .HasMaxLength(50)
                .IsUnicode(false)
                .UseCollation("SQL_Latin1_General_CP1255_CI_AS")
                .HasColumnName("zipCode");

            entity.HasOne(d => d.TypeUnitCodeNavigation).WithMany(p => p.Depts)
                .HasForeignKey(d => d.TypeUnitCode)
                .HasConstraintName("FK_Dept_UnitType");
        });

        modelBuilder.Entity<DicActivityStatus>(entity =>
        {
            entity.HasKey(e => e.Status).HasName("PK_deptStatus");

            entity.ToTable("DIC_ActivityStatus", "dbo");

            entity.Property(e => e.Status)
                .ValueGeneratedNever()
                .HasColumnName("status");
            entity.Property(e => e.EnumName)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.StatusDescription)
                .HasMaxLength(50)
                .HasColumnName("statusDescription");
            entity.Property(e => e.TimeStamp)
                .IsRowVersion()
                .IsConcurrencyToken();
        });

        modelBuilder.Entity<DicAgreementType>(entity =>
        {
            entity.HasKey(e => e.AgreementTypeId).HasName("PK_Dic_AgreementTypes");

            entity.ToTable("DIC_AgreementTypes", "dbo");

            entity.Property(e => e.AgreementTypeId)
                .ValueGeneratedOnAdd()
                .HasColumnName("AgreementTypeID");
            entity.Property(e => e.AgreementTypeDescription)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.EnumName)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.OrganizationSectorId).HasColumnName("OrganizationSectorID");
            entity.Property(e => e.TimeStamp)
                .IsRowVersion()
                .IsConcurrencyToken();
        });

        modelBuilder.Entity<DicTranslation>(entity =>
        {
            entity.HasKey(e => new { e.TableName, e.TableCode }).HasName("PK_TableNameTableCode");

            entity.ToTable("DIC_Translations", "dbo");

            entity.Property(e => e.TableName)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Id).ValueGeneratedOnAdd();
            entity.Property(e => e.LastUpdate).HasColumnType("datetime");
            entity.Property(e => e.RowName).IsUnicode(false);

            entity.HasOne(d => d.LanguageCodeNavigation).WithMany(p => p.DicTranslations)
                .HasForeignKey(d => d.LanguageCode)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_LanguageTranslate");

            entity.HasOne(d => d.TableTypeCodeNavigation).WithMany(p => p.DicTranslations)
                .HasForeignKey(d => d.TableTypeCode)
                .HasConstraintName("FK_TableTypeTranslate");
        });

        modelBuilder.Entity<DicYesAndNo>(entity =>
        {
            entity.ToTable("DIC_YesAndNo", "dbo");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Description).HasMaxLength(50);
        });

        modelBuilder.Entity<Language>(entity =>
        {
            entity.HasKey(e => e.LanguageCode);

            entity.ToTable("languages", "dbo");

            entity.Property(e => e.LanguageCode)
                .ValueGeneratedNever()
                .HasColumnName("languageCode");
            entity.Property(e => e.DisplayDescription)
                .HasMaxLength(50)
                .HasColumnName("displayDescription");
            entity.Property(e => e.IsShow)
                .HasDefaultValueSql("((0))")
                .HasColumnName("isShow");
            entity.Property(e => e.LanguageDescription)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("languageDescription");
            entity.Property(e => e.UpdateDate)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("smalldatetime")
                .HasColumnName("updateDate");
            entity.Property(e => e.UpdateUsername)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("updateUsername");
        });

        modelBuilder.Entity<TableType>(entity =>
        {
            entity.HasKey(e => e.Code).HasName("PK__TableTyp__A25C5AA6694F30EC");

            entity.ToTable("TableTypes", "dbo");

            entity.Property(e => e.Type).IsUnicode(false);
        });

        modelBuilder.Entity<TimeStampHistory>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__TimeStam__3214EC274934FB07");

            entity.ToTable("TimeStampHistory", "dbo");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.InsertDate).HasColumnType("datetime");
            entity.Property(e => e.MaxTimeStamp)
                .HasMaxLength(8)
                .IsFixedLength();
            entity.Property(e => e.TableName)
                .HasMaxLength(100)
                .IsUnicode(false);
        });

        modelBuilder.Entity<UnitType>(entity =>
        {
            entity.HasKey(e => e.UnitTypeCode);

            entity.ToTable("UnitType", "dbo");

            entity.Property(e => e.UnitTypeCode).ValueGeneratedNever();
            entity.Property(e => e.CategoryId)
                .HasDefaultValueSql("((1))")
                .HasColumnName("CategoryID");
            entity.Property(e => e.EnumName)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.IsActive)
                .IsRequired()
                .HasDefaultValueSql("((1))");
            entity.Property(e => e.TimeStamp)
                .IsRowVersion()
                .IsConcurrencyToken();
            entity.Property(e => e.UnitTypeName)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.UpdateDate).HasColumnType("smalldatetime");
            entity.Property(e => e.UpdateUser)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("PK__Users__1788CCAC21B932B9");

            entity.ToTable("Users", "dbo");

            entity.Property(e => e.UserId)
                .ValueGeneratedNever()
                .HasColumnName("UserID");
            entity.Property(e => e.DefinedInAd)
                .HasDefaultValueSql("((1))")
                .HasColumnName("DefinedInAD");
            entity.Property(e => e.Domain)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Email)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.FirstName)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.LastName)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.PhoneNumber)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.UpdateUser)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.UserDescription)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.UserName)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
