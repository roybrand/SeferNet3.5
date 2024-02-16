using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class SearchModeInfo
    {
        public SearchModeInfo()
        {
            AllModesSelected = IsMushlamSelected = IsCommunitySelected = IsHospitalsSelected = null;
        }

        public bool? AllModesSelected { get; set; } 
        public bool? IsMushlamSelected { get; set; }
        public bool? IsCommunitySelected { get; set; }
        public bool? IsHospitalsSelected { get; set; }

    }
}
