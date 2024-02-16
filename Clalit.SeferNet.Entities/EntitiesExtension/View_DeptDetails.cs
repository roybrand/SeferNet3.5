using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clalit.SeferNet.Entities
{
    public partial class View_DeptDetails
    {
        public string AddressMapFormatted
        {
            get
            {
                string strToReturn = string.Empty;
                if (string.IsNullOrEmpty(street) == false)
                {
                    strToReturn = string.Format("{0}", street);
                }

                if (string.IsNullOrEmpty(house) == false)
                {
                    strToReturn = string.Format("{0}{1}", strToReturn, house);
                }

                if (string.IsNullOrEmpty(cityName) == false)
                {
                    if (string.IsNullOrEmpty(strToReturn) == false)
                    {
                        strToReturn = string.Format("{0}{1}", strToReturn, ",");
                    }

                    strToReturn = string.Format("{0}{1}", strToReturn, cityName);
                }
               
                return strToReturn;
            }

        }

        public int DisplayOrder { get; set; }
    }
}
