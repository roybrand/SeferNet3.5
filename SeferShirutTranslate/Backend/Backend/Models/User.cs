using System;
using System.Collections.Generic;

namespace Backend.Models;

public partial class User : BaseTable
{
    public string UserName { get; set; } = null!;

    public string? UserDescription { get; set; }

    public string? PhoneNumber { get; set; }

    public string? FirstName { get; set; }

    public string? LastName { get; set; }

    public string? Domain { get; set; }

    public long UserId { get; set; }

    public string? Email { get; set; }

    public byte DefinedInAd { get; set; }

    public string? UpdateUser { get; set; }
}
