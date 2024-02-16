using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class DvRemarkInfo
    {

        private string remarkText;
        public string RemarkText
	    {
            get { return remarkText; }
            set { remarkText = value; }
	    }

        private string remarkID;
        public string RemarkID
	    {
            get { return remarkID; }
            set { remarkID = value; }
	    }

        private string validFrom;
        public string ValidFrom
        {
            get { return validFrom; }
            set { validFrom = value; }
        }

        private string validTo;
        public string ValidTo
        {
            get { return validTo; }
            set { validTo = value; }
        }

        private string districtCode;
        public string DistrictCode
        {
            get { return districtCode; }
            set { districtCode = value; }
        }

        private string administrationCode;
        public string AdministrationCode
        {
            get { return administrationCode; }
            set { administrationCode = value; }
        }

        private string unitTypeCode;
        public string UnitTypeCode
        {
            get { return unitTypeCode; }
            set { unitTypeCode = value; }
        }

        private string populationSector;
        public string PopulationSector
        {
            get { return populationSector; }
            set { populationSector = value; }
        }

        private string displayInInternet;
        public string DisplayInInternet
        {
            get { return displayInInternet; }
            set { displayInInternet = value; }
        }

    }
}
