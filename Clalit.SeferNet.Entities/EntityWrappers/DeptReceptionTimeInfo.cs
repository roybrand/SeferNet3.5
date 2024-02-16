using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.SeferNet.Entities;

namespace Clalit.SeferNet.Entities
{
    //public class DeptReceptionTimeInfo : ReceptionTimeInfo
    //{
    //    public int DeptCode { get; set; }

    //    /// <summary>
    //    /// for example :
    //    /// reception hours
    //    /// office hours 
    //    /// ...
    //    /// </summary>
    //    public List<ReceptionHourTypeInfo> ReceptionHourTypeInfoList { get; set; }
       
    //    public void AddReceptionHoursInfo(vDeptReceptionHours deptItem)
    //    {
    //        ReceptionHourTypeInfo receptionType =(from r in ReceptionHourTypeInfoList
    //         where r.ReceptionHoursTypeID == deptItem.ReceptionHoursTypeID
    //         select r).FirstOrDefault();

    //        receptionType.AddReceptionHoursInfo(deptItem);
    //    }

    //    public DeptReceptionTimeInfo(int deptCode)
    //    {
    //        DeptCode = deptCode;
    //        ReceptionHourTypeInfoList = new List<ReceptionHourTypeInfo>();
    //    }	
    //}

    public class ReceptionHourTypeInfo : ReceptionTimeInfo
    {
        public byte ReceptionHoursTypeID { get; set; }
        public string ReceptionTypeDescription { get; set; }
        public int DeptCode { get; set; }

        public void AddReceptionHoursInfo(vDeptReceptionHours deptItem)
        {
            ReceptionHoursInfo hoursInfo = GetReceptionHoursInfoFromdeptItem(deptItem);
            base.AddReceptionHoursInfo(deptItem.receptionDay, deptItem.receptionID, hoursInfo);
        }

        private ReceptionHoursInfo GetReceptionHoursInfoFromdeptItem(vDeptReceptionHours deptItem)
        {
            ReceptionHoursInfo hoursInfo = new ReceptionHoursInfo
            {
                ClosingHour = deptItem.closingHour,
                OpeningHour = deptItem.openingHour,
                OpeningHourText = deptItem.openingHourText,
                ReceptionId = deptItem.receptionID,
                RemarkTextList = new List<string> { deptItem.RemarkText },
            };
            return hoursInfo;
        }		
    }

}
