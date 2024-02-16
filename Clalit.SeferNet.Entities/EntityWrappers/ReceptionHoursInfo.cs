using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clalit.SeferNet.Entities
{
	public class ReceptionHoursInfo
	{
		public int ReceptionId{ get; set; }		

		public string OpeningHour { get; set; }
		public string ClosingHour { get; set; }
		public string OpeningHourText { get; set; }
		
		public string RemarkText
		{
			get
			{
				string retval = string.Empty;

				foreach (var item in RemarkTextList)
				{
					retval += item;
				}

				return retval;
			}
		}
		public List<string> RemarkTextList { get; set; }

        public byte ReceptionHoursTypeID { get; set; }
        public string ReceptionTypeDescription { get; set; }
        
		public ReceptionHoursInfo()
		{
			RemarkTextList = new List<string>();
		}
	}
}
