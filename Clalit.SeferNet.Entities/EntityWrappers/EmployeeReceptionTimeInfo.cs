using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.SeferNet.Entities;

namespace  Clalit.SeferNet.Entities
{
	/// <summary>
	/// Contains the reception details - Days, hours, reception remarks + some extra details about the Employee
	/// </summary>
	public class EmployeeReceptionTimeInfoExtended : ReceptionTimeInfo
	{
		public long EmployeeId { get; set; }
		
		public string EmployeeRemark { get; set; }
		
		public string EmployeeName { get; set; }
		
		public string Experties { get; set; }
		
		public string ProfessionDescriptions { get; set; }

		public string ServiceDescriptions { get; set; }
		
		public string QueueOrderDescriptions { get; set; }
		
		public string HTMLRemarks { get; set; }

        public string Phones { get; set; }

        public string PhonesHTML
        {
            get
            {
                string retval = string.Empty;
                if (Phones != null && Phones != string.Empty)
                {
                    retval = "<tr><td class='tdLable_b_rem_first'>&nbsp;</td><td colspan='colspanPhone' class='tdLable_b_rem_end_first'>טלפון לפניות " + Phones + "</td></tr>";

                }
                else
                    retval = " ";
                return retval;
            }
        }

        public List<vEmployeeDeptRemarks> EmployeeRemarkList { get; set; }

        public string EmployeeRemarksHTML
        {
            get
            {
                string retval = string.Empty;
                string remTitle = string.Empty;
                string validTo = string.Empty;
                string validTitle = string.Empty;

                foreach (vEmployeeDeptRemarks item in EmployeeRemarkList)
                {

                    if (Convert.ToDateTime(item.ValidTo) != DateTime.MinValue)
                    {
                        validTo = Convert.ToDateTime(item.ValidTo).ToString("dd/MM/yyyy");
                        validTitle = "תוקף";
                    }
                    else
                    {
                        validTo = "&nbsp;";
                        validTitle = "&nbsp;";
                    }

                    if (retval == string.Empty)
                    {
                        remTitle = "הערות";
                        retval += "<tr><td class='tdLable_b_rem_first'>" + remTitle + "</td><td colspan='colspanRem' class='tdLable_b_rem_first'>" + item.RemarkText + "</td><td class='tdLable_b_rem_first'>" + validTitle + "</td><td class='tdLable_b_rem_end_first'>" + validTo + "</td></tr>";
                    }
                    else
                    {
                        remTitle = "&nbsp;";
                        retval += "<tr><td class='tdLable_b_rem'>" + remTitle + "</td><td colspan='colspanRem' class='tdLable_b_rem'>" + item.RemarkText + "</td><td class='tdLable_b_rem'>" + validTitle + "</td><td class='tdLable_b_rem_end'>" + validTo + "</td></tr>";
                    }
                }

                if(retval == string.Empty)
                    retval = " ";

                return retval;
            }
        }

		/// <summary>
		/// Fills the reception details  - Days, hours  from the given raw object
		/// </summary>
		/// <param name="employeeItem"></param>
		public EmployeeReceptionTimeInfoExtended(long employeeId)
		{
            EmployeeRemarkList = new List<vEmployeeDeptRemarks>();
			EmployeeId = employeeId;			
		}

		public void AddReceptionHoursInfo(vEmployeeReceptionHours employeeItem)
		{
			ReceptionHoursInfo hoursInfo = GetReceptionHoursInfoFromEmployeeItem(employeeItem);
			base.AddReceptionHoursInfo(employeeItem.receptionDay, employeeItem.receptionID, hoursInfo);
		}

		private ReceptionHoursInfo GetReceptionHoursInfoFromEmployeeItem(vEmployeeReceptionHours employeeItem)
		{
			ReceptionHoursInfo hoursInfo = new ReceptionHoursInfo
				{
					ClosingHour = employeeItem.closingHour,
					OpeningHour = employeeItem.openingHour,
					OpeningHourText = employeeItem.OpeningHourText,			
				    ReceptionId= employeeItem.receptionID,		
					//RemarkText = //will be taken from vEmployeeReceptionRemarks	
				};
			return hoursInfo;
		}

		/// <summary>
		/// A reception hour of an employee can has several remarks - this method add the remark to the respective reception hours
		/// </summary>
		/// <param name="employRemarkItem"></param>
		public void AddReceptionRemarkInfo(vEmployeeReceptionRemarks employRemarkItem)
		{			
			if (this.AllReceptionHoursInfoDict.ContainsKey(employRemarkItem.receptionID) == true)
			{
				this.AllReceptionHoursInfoDict[employRemarkItem.receptionID].RemarkTextList.Add(employRemarkItem.RemarkText);
			}
			else
			{
				//shouldn't happen!!!
			}
		}

        /// <summary>
        /// A reception hour of an employee can has several remarks - this method add the remark to the respective reception hours
        /// </summary>
        /// <param name="employRemarkItem"></param>
        public void AddEmployeeRemarkInfo(vEmployeeDeptRemarks employRemarkItem)
        {
            EmployeeRemarkList.Add(employRemarkItem);
        }

		/// <summary>
		/// Fills the extra details from the given employee raw object  - EmployeeRemark = employProfItem.EmployeeRemark;
		///	EmployeeName,Experties ,ProfessionDescriptions,ServiceDescriptions ,QueueOrderDescriptions, 
		///	HTMLRemarks 
		/// </summary>
		/// <param name="employProfItem"></param>
		public void SetProfessionInfo(vEmployeeProfessionalDetails employProfItem)
		{
			EmployeeRemark = employProfItem.EmployeeRemark;
			EmployeeName = employProfItem.EmployeeName;
			Experties = employProfItem.Experties;
			ProfessionDescriptions = employProfItem.ProfessionDescriptions;
			ServiceDescriptions = employProfItem.ServiceDescriptions;
			QueueOrderDescriptions = employProfItem.QueueOrderDescriptions;
			HTMLRemarks = employProfItem.HTMLRemarks;
            Phones = employProfItem.Phones;
		}
	}
}
