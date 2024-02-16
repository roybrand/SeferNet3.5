using System;
using System.Collections.Generic;
using System.Text;
 
namespace SeferNet.UI
{
    public enum clinicStatus
    {
        Inactive = 0,
        Active = 1,
        TemporarilyInactive = 2,
        IncludeAll = 3
    }

    public enum employeeSector
    { 
        Doctor = 1,
        Paramedic = 2,
        NotDoctor = 3
    }
   
    public enum sortingOrder
    { 
        NotSettled = 0,
        Ascending = 0,
        Descending = 1
    }


    public enum SortingOrder
    {
        
        Ascending = 0,
        Descending = 1,
        Undefined = 2,
    }

}


