using System;
using System.Collections.Generic;

namespace Backend.Models;

public partial class DicActivityStatus : BaseTable
{
    public short Status { get; set; }

    public string? StatusDescription { get; set; }

    public string? EnumName { get; set; }

    public byte[] TimeStamp { get; set; } = null!;
}
