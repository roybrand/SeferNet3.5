using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;

namespace SeferNet.Globals
{
    public class GlobalMethods
    {

        public static string GetStringFromList(SortedList sList)
        {
            string values = string.Empty;

            foreach (string val in sList.Keys)
            {
                values += val + ",";
            }

            if (values.Length > 0)
            {
                values = values.Trim().Remove(values.Length - 1);
            }

            return values;
        }
    }
}
