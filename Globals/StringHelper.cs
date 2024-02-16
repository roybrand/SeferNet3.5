using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SeferNet.Globals
{
    public static class StringHelper
    {
        public static void CleanStringAndSetToNullIfRequired(ref string str)
        {
            str = GetCleanStringAndSetToNullIfRequired(str);
        }

        public static string GetCleanStringAndSetToNullIfRequired(string str)
        {
            if (str != null)
            {
                str = str.Trim();

                if (str == string.Empty)
                {
                    str = null;
                }
            }

            return str;
        }

		public static Dictionary<Enums.SearchMode, bool> ConverAgreementNamesListToBoolArray(string AgreementTypes)
		{
			Dictionary<Enums.SearchMode, bool> agreememtsDic = new Dictionary<Enums.SearchMode, bool>();

			//----- if SearchMode.All
			if (string.IsNullOrWhiteSpace(AgreementTypes)
				|| AgreementTypes == Enum.GetName(typeof(Enums.SearchMode), Enums.SearchMode.All))
			{
				agreememtsDic.Add(Enums.SearchMode.Community, true);
				agreememtsDic.Add(Enums.SearchMode.Hospitals, true);
				agreememtsDic.Add(Enums.SearchMode.Mushlam, true);
				return agreememtsDic;
			}

			foreach (string name in Enum.GetNames(typeof(Enums.SearchMode)))
			{
				Enums.SearchMode value = (Enums.SearchMode)Enum.Parse(typeof(Enums.SearchMode), name);
				if (AgreementTypes.Contains(name))
				{
					agreememtsDic.Add(value, true);
				}
				else
				{
					agreememtsDic.Add(value, false);
				}
			}
			return agreememtsDic;
		}

    }

}

