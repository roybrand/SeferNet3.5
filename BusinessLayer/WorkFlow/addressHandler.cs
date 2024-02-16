using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class addressHandler
    {
        public string getClinicAddress(object street, object houseNumber, object flat)
        {

            string streetStr = String.Empty;
            if (street == null)
                streetStr = String.Empty;
            else
                streetStr = street.ToString();

            string houseNumberStr = String.Empty;
            if (houseNumber == null)
                houseNumberStr = String.Empty;
            else
                houseNumberStr = houseNumber.ToString();

            string flatStr = String.Empty;
            if (flat == null)
                flatStr = String.Empty;
            else
            {
                if (flat.ToString().Trim() != String.Empty)
                    flatStr = "/" + flat.ToString();
            }

            string Address = streetStr + " " + houseNumberStr + flatStr;
            return Address;
        }

        public string getClinicAddress(object city, object street, object houseNumber, object flat)
        {
            string cityStr = String.Empty;
            if (city == null)
                cityStr = String.Empty;
            else
            {
                if (city.ToString().Trim() != string.Empty)
                { 
                    cityStr = " " + city.ToString();
                }
            }


            string streetStr = String.Empty;
            if (street == null)
                streetStr = String.Empty;
            else
            {
                if (street.ToString().Trim() != string.Empty)
                { 
                    streetStr = street.ToString();
                }
            }

            string houseNumberStr = String.Empty;
            if (houseNumber == null)
                houseNumberStr = String.Empty;
            else
                houseNumberStr = " " + houseNumber.ToString();

            string flatStr = String.Empty;
            if (flat == null)
                flatStr = String.Empty;
            else
            {
                if (flat.ToString().Trim() != String.Empty)
                    flatStr = "/" + flat.ToString();
            }

            string Address = streetStr + houseNumberStr + flatStr + cityStr;
            return Address;
        }

    }
}
