using System;
using System.Collections.Generic;

namespace Backend.Models;

public partial class TimeStampHistory : BaseTable
{
    public long Id { get; set; }

    public string? TableName { get; set; }

    public byte[]? MaxTimeStamp { get; set; }

    public DateTime? InsertDate { get; set; }
}

public partial class TimeStampHistoryDto
{
    public string? TableName { get; set; }

    public byte[]? TimeStamp { get; set; }
}
