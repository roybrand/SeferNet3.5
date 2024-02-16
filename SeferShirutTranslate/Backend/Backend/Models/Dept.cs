using System;
using System.Collections.Generic;

namespace Backend.Models;

public partial class Dept : BaseTable
{
    public int DeptCode { get; set; }

    public string? DeptName { get; set; }

    public int? DeptType { get; set; }

    public int? DistrictCode { get; set; }

    public int? DeptLevel { get; set; }

    public int? TypeUnitCode { get; set; }

    public int? SubUnitTypeCode { get; set; }

    public int? AdministrationCode { get; set; }

    public int? SubAdministrationCode { get; set; }

    public string? ManagerName { get; set; }

    public string? AdministrativeManagerName { get; set; }

    public int CityCode { get; set; }

    public string? ZipCode { get; set; }

    public string? StreetCode { get; set; }

    public string? StreetName { get; set; }

    public string? House { get; set; }

    public string? Flat { get; set; }

    public string? Entrance { get; set; }

    public string? Floor { get; set; }

    public string? Email { get; set; }

    public byte? ShowEmailInInternet { get; set; }

    public string? AddressComment { get; set; }

    public string? Transportation { get; set; }

    public short? Status { get; set; }

    public byte? Independent { get; set; }

    public DateTime UpdateDate { get; set; }

    public string? UpdateUser { get; set; }

    public byte? ShowUnitInInternet { get; set; }

    public int? Parking { get; set; }

    public int? PopulationSectorCode { get; set; }

    public byte? CascadeUpdateSubDeptPhones { get; set; }

    public int? QueueOrder { get; set; }

    public string? MfstreetCode { get; set; }

    public string? MfstreetName { get; set; }

    public byte? DisplayPriority { get; set; }

    public bool? IsCommunity { get; set; }

    public bool IsMushlam { get; set; }

    public bool IsHospital { get; set; }

    public string? NeighbourhoodOrInstituteCode { get; set; }

    public byte? IsSite { get; set; }

    public bool? IsNewHospital { get; set; }

    public string? LinkToBlank17 { get; set; }

    public string? LinkToContactUs { get; set; }

    public string? Building { get; set; }

    public int? TypeOfDefenceCode { get; set; }

    public int? DefencePolicyCode { get; set; }

    public bool? HasElectricalPanel { get; set; }

    public bool? HasGenerator { get; set; }

    public bool? IsUnifiedClinic { get; set; }

    public string? DeptNameFreePart { get; set; }

    public long? DeptShalaCode { get; set; }

    public int? ParentClinic { get; set; }

    public int? ReligionCode { get; set; }

    public byte? AllowContactHospitalUnit { get; set; }

    public byte[] TimeStamp { get; set; } = null!;

    public virtual UnitType? TypeUnitCodeNavigation { get; set; }
}
