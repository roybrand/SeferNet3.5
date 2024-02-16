using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clalit.SeferNet.Entities
{
    public 	class ReceptionDayInfo
	{
		public string  Title { get; set; }

		public int DayNumber { get; set; }

		public List<ReceptionHoursInfo> ReceptionHoursInfoList { get; set; }

		public string AllReceptionHoursInfoFormatted {
			get
			{
				string retVal = string.Empty;
				if (ReceptionHoursInfoList != null && ReceptionHoursInfoList.Count > 0)
				{
					foreach (ReceptionHoursInfo hours in ReceptionHoursInfoList)
					{
                        if (retVal.Length > 0 && retVal.IndexOf("<br>", retVal.Length - 4) == -1)
						    retVal += "<br>" + hours.OpeningHourText;
                        else
                            retVal += hours.OpeningHourText;
					}
				}
				return retVal;
			}
		}

		public ReceptionDayInfo(int dayNumber)
		{
			ReceptionHoursInfoList = new List<ReceptionHoursInfo>();
			DayNumber = dayNumber;
		}
	}
}
