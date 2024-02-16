using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class DvDeptRemarkInfo
    {
        private string deptRemarkID;

        public string DeptRemarkID
	    {
            get { return deptRemarkID; }
            set { deptRemarkID = value; }
	    }

        private string deptCode;

        public string DeptCode
        {
            get { return deptCode; }
            set { deptCode = value; }
        }

        private string startDate;

        public string StartDate
        {
            get { return startDate; }
            set { startDate = value; }
        }

        private string endDate;

        public string EndDate
        {
            get { return endDate; }
            set { endDate = value; }
        }

        private string remark;

        public string Remark
        {
            get { return remark; }
            set { remark = value; }
        }

        private bool active;

        public bool Active
        {
            get { return active; }
            set { active = value; }
        }

    }
}
