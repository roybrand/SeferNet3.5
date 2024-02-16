using System;
using System.Collections.Generic;

namespace Backend.Models;

public partial class DicYesAndNo : BaseTable
{
    public int Id { get; set; }

    public string Description { get; set; } = null!;
}
