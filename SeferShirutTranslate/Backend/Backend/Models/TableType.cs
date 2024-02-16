using System;
using System.Collections.Generic;

namespace Backend.Models;

public partial class TableType : BaseTable
{
    public short Code { get; set; }

    public string Type { get; set; } = null!;

    public virtual ICollection<DicTranslation> DicTranslations { get; set; } = new List<DicTranslation>();
}
