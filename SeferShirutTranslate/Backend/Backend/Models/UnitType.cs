using System;
using System.Collections.Generic;

namespace Backend.Models;

public partial class UnitType : BaseTable
{
    public int UnitTypeCode { get; set; }

    public string UnitTypeName { get; set; } = null!;

    public DateTime? UpdateDate { get; set; }

    public string? UpdateUser { get; set; }

    public bool? ShowInInternet { get; set; }

    public bool? AllowQueueOrder { get; set; }

    public bool? IsActive { get; set; }

    public int DefaultSubUnitTypeCode { get; set; }

    public string? EnumName { get; set; }

    public byte CategoryId { get; set; }

    public bool? IsCommunity { get; set; }

    public bool? IsMushlam { get; set; }

    public bool? IsHospital { get; set; }

    public byte[] TimeStamp { get; set; } = null!;

    public virtual ICollection<Dept> Depts { get; set; } = new List<Dept>();
}
