using System;
using System.Collections.Generic;

namespace Backend.Models;

public partial class DicTranslation : BaseTable
{
    public long Id { get; set; }

    public string TableName { get; set; } = null!;

    public short? TableTypeCode { get; set; }

    public string RowName { get; set; } = null!;

    public int TableCode { get; set; }

    public int LanguageCode { get; set; }

    public string? Translate { get; set; }

    public DateTime? LastUpdate { get; set; }

    public virtual Language LanguageCodeNavigation { get; set; } = null!;

    public virtual TableType? TableTypeCodeNavigation { get; set; }
}
