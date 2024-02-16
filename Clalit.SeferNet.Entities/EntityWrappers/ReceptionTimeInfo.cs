using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.SeferNet.GeneratedEnums;
using System.Data;
using Clalit.SeferNet.Entities;

namespace Clalit.SeferNet.Entities
{
	public class ReceptionTimeInfo
	{    
		/// <summary>
		///contains ALL the reception hours regardless of the day
		/// 
		/// </summary>
        public Dictionary<int, ReceptionHoursInfo> AllReceptionHoursInfoDict { get; set; }

        public string HasReceptionHours
        {
            get
            {
                string retVal = "none";
                if (AllReceptionHoursInfoDict != null)
                {
                    if (AllReceptionHoursInfoDict.Count > 0)
                        retVal = "block";
                }
               return  retVal;
            }
        }

        public string HasNoReceptionHours
        {
            get
            {
                string retVal = "none";
                if (AllReceptionHoursInfoDict == null || AllReceptionHoursInfoDict.Count == 0)
                {
                    retVal = "block";
                }
                return retVal;
            }
        }
        

		public ReceptionDayInfo Sunday { get; set; }
		public ReceptionDayInfo Monday { get; set; }
		public ReceptionDayInfo Tuesday { get; set; }
		public ReceptionDayInfo Wednesday { get; set; }
		public ReceptionDayInfo Thursday { get; set; }
		public ReceptionDayInfo Friday { get; set; }
        public ReceptionDayInfo Saturday { get; set; }
		public ReceptionDayInfo HolHamoed { get; set; }
		public ReceptionDayInfo HolidayEvening { get; set; }


       

		public string SundayAllReceptionHoursInfoFormatted
		{
			get { return Sunday.AllReceptionHoursInfoFormatted; }
		}

		public string MondayAllReceptionHoursInfoFormatted
		{
			get { return Monday.AllReceptionHoursInfoFormatted; }
		}

		public string TuesdayAllReceptionHoursInfoFormatted
		{
			get { return Tuesday.AllReceptionHoursInfoFormatted; }
		}

		public string WednesdayAllReceptionHoursInfoFormatted
		{
			get { return Wednesday.AllReceptionHoursInfoFormatted; }
		}

		public string ThursdayAllReceptionHoursInfoFormatted
		{
			get { return Thursday.AllReceptionHoursInfoFormatted; }
		}

		public string FridayAllReceptionHoursInfoFormatted
		{
			get { return Friday.AllReceptionHoursInfoFormatted; }
		}
        public string SaturdayAllReceptionHoursInfoFormatted
		{
            get { return Saturday.AllReceptionHoursInfoFormatted; }
		}
		public string HolHamoedAllReceptionHoursInfoFormatted
		{
			get { return HolHamoed.AllReceptionHoursInfoFormatted; }
		}

		public string HolidayEveningAllReceptionHoursInfoFormatted
		{
			get { return HolidayEvening.AllReceptionHoursInfoFormatted; }
		}

        
		public ReceptionTimeInfo()
		{
			AllReceptionHoursInfoDict = new Dictionary<int, ReceptionHoursInfo>();
			//TO DO - bring from dictionary
			Sunday = new ReceptionDayInfo((int)eDIC_ReceptionDays.Sunday);
			Monday = new ReceptionDayInfo((int)eDIC_ReceptionDays.Monday);
			Tuesday = new ReceptionDayInfo((int)eDIC_ReceptionDays.Tuesday);
			Wednesday = new ReceptionDayInfo((int)eDIC_ReceptionDays.Wednesday);
			Thursday = new ReceptionDayInfo((int)eDIC_ReceptionDays.Thursday);
			Friday = new ReceptionDayInfo((int)eDIC_ReceptionDays.Friday);
            Saturday = new ReceptionDayInfo((int)eDIC_ReceptionDays.Saturday);
			HolHamoed = new ReceptionDayInfo((int)eDIC_ReceptionDays.HolHamoeed);
			HolidayEvening = new ReceptionDayInfo((int)eDIC_ReceptionDays.HolidayEvening);

            
		}


		/// <summary>
		/// Add the ReceptionHoursInfo to the respective day - for example sunday can have a collection of 2 ReceptionHoursInfo items
		/// because there are 2 different opening hours on this day
		/// </summary>
		/// <param name="receptionDay"></param>
		/// <param name="receptionID"></param>
		/// <param name="hoursInfo"></param>
		public void AddReceptionHoursInfo(int receptionDay, int receptionID, ReceptionHoursInfo hoursInfo)
		{
			if (receptionDay == (int)eDIC_ReceptionDays.Sunday)
			{
				this.Sunday.ReceptionHoursInfoList.Add(hoursInfo);
			}
			else if (receptionDay == (int)eDIC_ReceptionDays.Monday)
			{
				this.Monday.ReceptionHoursInfoList.Add(hoursInfo);
			}
			else if (receptionDay == (int)eDIC_ReceptionDays.Tuesday)
			{
				this.Tuesday.ReceptionHoursInfoList.Add(hoursInfo);
			}
			else if (receptionDay == (int)eDIC_ReceptionDays.Wednesday)
			{
				this.Wednesday.ReceptionHoursInfoList.Add(hoursInfo);
			}
			else if (receptionDay == (int)eDIC_ReceptionDays.Thursday)
			{
				this.Thursday.ReceptionHoursInfoList.Add(hoursInfo);
			}
			else if (receptionDay == (int)eDIC_ReceptionDays.Friday)
			{
				this.Friday.ReceptionHoursInfoList.Add(hoursInfo);
			}
			else if (receptionDay == (int)eDIC_ReceptionDays.Saturday)
			{
				this.Saturday.ReceptionHoursInfoList.Add(hoursInfo);
			}
			else if (receptionDay == (int)eDIC_ReceptionDays.HolHamoeed)
			{
				this.HolHamoed.ReceptionHoursInfoList.Add(hoursInfo);
			}
			else if (receptionDay == (int)eDIC_ReceptionDays.HolidayEvening)
			{
				this.HolidayEvening.ReceptionHoursInfoList.Add(hoursInfo);
			}

			this.AllReceptionHoursInfoDict.Add(receptionID, hoursInfo);

		}
	}
}
