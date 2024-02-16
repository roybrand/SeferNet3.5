using System;
using System.Collections.Generic;

namespace Backend.Models;

public partial class Language : BaseTable
{
    public int LanguageCode { get; set; }

    public string LanguageDescription { get; set; } = null!;

    public DateTime? UpdateDate { get; set; }

    public string? UpdateUsername { get; set; }

    public byte? IsShow { get; set; }

    public string? DisplayDescription { get; set; }

    public virtual ICollection<DicTranslation> DicTranslations { get; set; } = new List<DicTranslation>();
}
