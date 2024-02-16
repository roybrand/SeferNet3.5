using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;

/// <summary>
/// Summary description for GlobalConst
/// </summary>
public static class GlobalConst
{
    /// <summary>
    /// consts for session key names ( instead of hard coded)
    /// </summary>
    public static class Session
    {
        public const string ReturnUrl = "ReturnUrl";

        public const string ConfirmationUser = "ConfirmationUser";

    }

    /// <summary>
    /// consts for query request key names ( instead of hard coded)
    /// 
    /// </summary>
    public static class QueryVariable
    {
        public const string JoinedStringSeperator = ",";

        public static class Pages
        {
            public static class DeptsMapProperties
            {
                public const string AllDepts = "AllDepts";
                public static readonly string FocusedDeptCode = "FocusedDeptCode";
                public const string CoordX = "CoordX";
                public const string CoordY = "CoordY";
            }
        }
    }
}
