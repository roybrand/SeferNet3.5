using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.SeferNet.Entities;

namespace Clalit.SeferNet.EntitiesBL
{
    public class ServiceReceptionTimeInfoExtended : ReceptionTimeInfo
    {
        public int ServiceCode { get; set; }

        public string ServiceDescription { get; set; }

        public string QueueOrder { get; set; }

        public List<vDeptServicesRemarks> ServiceRemarkList { get; set; }

        /// <summary>
        /// Fills the reception details  - Days, hours  from the given raw object
        /// </summary>
        /// <param name="employeeItem"></param>
        public ServiceReceptionTimeInfoExtended(int serviceCode)
        {
            ServiceCode = serviceCode;
            ServiceRemarkList = new List<vDeptServicesRemarks>();
        }

        private ReceptionHoursInfo GetReceptionHoursInfoFromEmployeeItem(vServicesReceptionWithRemarks serviceItem)
        {
            ReceptionHoursInfo hoursInfo = new ReceptionHoursInfo
            {
                ClosingHour = serviceItem.closingHour,
                OpeningHour = serviceItem.openingHour,
                OpeningHourText = serviceItem.OpeningHourText,
                ReceptionId = serviceItem.receptionID,

            };
            return hoursInfo;
        }

        public void AddReceptionHoursInfo(vServicesReceptionWithRemarks serviceItem)
        {
            ReceptionHoursInfo hoursInfo = GetReceptionHoursInfoFromEmployeeItem(serviceItem);
            base.AddReceptionHoursInfo(serviceItem.receptionDay, serviceItem.receptionID, hoursInfo);
        }

        public void SetServiceInfo(vServicesAndQueueOrder serviceOrderItem)
        {
            ServiceDescription = serviceOrderItem.ServiceDescription;
            QueueOrder = serviceOrderItem.QueueOrder;
        }

        public string ServiceRemarksHTML
        {
            get
            {
                string retval = string.Empty;
                string remTitle = string.Empty;
                string validTo = string.Empty;
                string validTitle = string.Empty;

                foreach (vDeptServicesRemarks item in ServiceRemarkList)
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
                        retval += "<tr><td class='tdLable_b_rem_first'>" + remTitle + "</td><td colspan='6' class='tdLable_b_rem_first'>" + item.RemarkText + "</td><td class='tdLable_b_rem_first'>" + validTitle + "</td><td class='tdLable_b_rem_end_first'>" + validTo + "</td></tr>";
                    }
                    else
                    {
                        remTitle = "&nbsp;";
                        retval += "<tr><td class='tdLable_b_rem'>" + remTitle + "</td><td colspan='6' class='tdLable_b_rem'>" + item.RemarkText + "</td><td class='tdLable_b_rem'>" + validTitle + "</td><td class='tdLable_b_rem_end'>" + validTo + "</td></tr>";
                    }

                }

                if (retval == string.Empty)
                    retval = " ";

                return retval;
            }

        }
    }
}
