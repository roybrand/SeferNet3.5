using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clalit.SeferNet.Entities
{
    public partial class vAllDeptDetails
    {
        #region Depts - lists
        public List<vDummy_LastUpdateDateOfRemarks> vDummy_LastUpdateDateOfRemarksList { get; set; }

        List<vDeptReceptionHours> _vDeptReceptionHoursList;
        public List<vDeptReceptionHours> vDeptReceptionHoursList
        {
            get
            {
                return _vDeptReceptionHoursList;
            }
            set
            {
                _vDeptReceptionHoursList = value;

                FillRececptionHoursTypesAndHours();
            }
        }

        private void FillRececptionHoursTypesAndHours()
        {
            var result = (from r in _vDeptReceptionHoursList
                          select new { r.ReceptionHoursTypeID, r.ReceptionTypeDescription, r.deptCode }).Distinct();

            _ReceptionHourTypeInfoList = new List<ReceptionHourTypeInfo>();
            foreach (var item in result)
            {
                _ReceptionHourTypeInfoList.Add(new ReceptionHourTypeInfo
                {
                    DeptCode = item.deptCode,
                    ReceptionHoursTypeID = item.ReceptionHoursTypeID.Value,
                    ReceptionTypeDescription = item.ReceptionTypeDescription,
                });

            }

            foreach (var item in _vDeptReceptionHoursList)
            {
                AddReceptionHoursInfo(item);
            }
        }

        public List<View_DeptRemarks> View_DeptRemarksList { get; set; }

        #endregion

        public string FullAddressFormatted
        {
            get
            {
                return string.Format("{0}{1}{2}", simpleAddress, string.IsNullOrEmpty(simpleAddress) == false ? ", " : string.Empty, cityName);
            }
        }

        public string RemarkText
        {
            get
            {
                string retval = string.Empty;
                string validTo = string.Empty;
                string validTitle = string.Empty;

                foreach (View_DeptRemarks item in View_DeptRemarksList)
                {
                    if (Convert.ToDateTime(item.validTo) != DateTime.MinValue)
                    {
                        validTo = Convert.ToDateTime(item.validTo).ToString("dd/MM/yyyy");
                        validTitle = "תוקף";
                    }
                    else
                    {
                        validTo = "&nbsp;";
                        validTitle = "&nbsp;";
                    }

                    if (retval.Length > 0)
                        retval += string.Format("<tr><td colspan='9' class='tdLable_b_rem'><table style='border:none;' cellpadding='0' cellspacing='0' class='tblOuter_2'><tr><td style='width:45px'>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr></table></td></tr>",
                        "&nbsp;", item.RemarkText, validTitle, validTo);
                    else

                        retval += string.Format("<tr><td colspan='9' class='tdLable_b_rem'><table style='border:none;' cellpadding='0' cellspacing='0' class='tblOuter_2'><tr><td style='width:45px'>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr></table></td></tr>",
                        "הערות ", item.RemarkText, validTitle, validTo);
                }

                if (retval == string.Empty)
                {
                    retval = "<tr style='display:none;'><td colspan='9'></td></tr>";

                }
                return retval;
            }
        }

        public string RemarkText_PrintClinicList
        {
            get
            {
                string retval = string.Empty;
                string validTo = string.Empty;
                string validTitle = string.Empty;

                foreach (View_DeptRemarks item in View_DeptRemarksList)
                {
                    if (Convert.ToDateTime(item.validTo) != DateTime.MinValue)
                    {
                        validTo = Convert.ToDateTime(item.validTo).ToString("dd/MM/yyyy");
                        validTitle = "תוקף";
                    }
                    else
                    {
                        validTo = "&nbsp;";
                        validTitle = "&nbsp;";
                    }

                    if (retval.Length > 0)
                        retval += string.Format("<tr><td class='tdRemBorderLeftDotted' style='width:45px'>{0}</td><td class='tdRemBorderTopLeftDotted' style='padding-right:5px;'>{1}</td><td class='tdRemBorderTopDotted' style='padding-right:5px;'>{2}</td><td class='tdRemBorderTopDotted'>{3}</td></tr>",
                        "&nbsp;", item.RemarkText, validTitle, validTo);
                    else
                        retval += string.Format("<tr><td class='tdRemBorderLeftDotted' style='width:45px;padding-right:5px;'>{0}</td><td class='tdRemBorderLeftDotted' style='padding-right:5px;'>{1}</td><td style='padding-right:5px;'>{2}</td><td style='width:65px'>{3}</td></tr>",
                        "הערות ", item.RemarkText, validTitle, validTo);
                }

                if (retval == string.Empty)
                {
                    retval = "<tr style='display:none;'><td></td></tr>";

                }
                return retval;
            }
        }

        List<ReceptionHourTypeInfo> _ReceptionHourTypeInfoList;
        public List<ReceptionHourTypeInfo> ReceptionHourTypeInfoList
        {
            get
            {
                return _ReceptionHourTypeInfoList;
            }
            set
            {
                _ReceptionHourTypeInfoList = value;
            }
        }
       
        public void AddReceptionHoursInfo(vDeptReceptionHours deptItem)
        {
            ReceptionHourTypeInfo receptionType =(from r in ReceptionHourTypeInfoList
             where r.ReceptionHoursTypeID == deptItem.ReceptionHoursTypeID
             select r).FirstOrDefault();

            receptionType.AddReceptionHoursInfo(deptItem);
        }    

        #region Sub depts lists

        public List<vAllDeptDetails> vSubDept_AllDeptDetailsList { get; set; }

        List<vDeptReceptionHours> _vSubDept_vDeptReceptionHoursList;
        public List<vDeptReceptionHours> vSubDept_vDeptReceptionHoursList
        {
            get
            {
                return _vSubDept_vDeptReceptionHoursList;
            }
            set
            {
                _vSubDept_vDeptReceptionHoursList = value;
                //fill the child remarks on each sub clinics
                foreach (var item in vSubDept_AllDeptDetailsList)
                {
                    item.FillDeptReceptionHoursList(_vSubDept_vDeptReceptionHoursList);
                }
            }
        }
     
        public List<View_DeptRemarks> _View_SubDeptRemarksList = null;
        public List<View_DeptRemarks> View_SubDeptRemarksList
        {
            get
            {
                return _View_SubDeptRemarksList;
            }
            set
            {
                _View_SubDeptRemarksList = value;

                //fill the child remarks on each sub clinics
                foreach (var item in vSubDept_AllDeptDetailsList)
                {
                    item.FillRemarks(_View_SubDeptRemarksList);
                }
            }
        }

        #endregion

        #region In area depts - lists

      
        public List<vAllDeptDetails> vInAreaDept_AllDeptDetailsList { get; set; }

        List<vDeptReceptionHours> _vInAreaDept_vDeptReceptionHoursList;
        public List<vDeptReceptionHours> vInAreaDept_vDeptReceptionHoursList
        {
            get
            {
                return _vInAreaDept_vDeptReceptionHoursList;
            }
            set
            {
                _vInAreaDept_vDeptReceptionHoursList = value;
                //fill the child remarks on each sub clinics
                foreach (var item in vInAreaDept_AllDeptDetailsList)
                {
                    item.FillDeptReceptionHoursList(_vInAreaDept_vDeptReceptionHoursList);
                }
            }
        }

        public List<View_DeptRemarks> _View_InAreaDeptRemarksList = null;
        public List<View_DeptRemarks> View_InAreaDeptRemarksList
        {
            get
            {
                return _View_InAreaDeptRemarksList;
            }
            set
            {
                _View_InAreaDeptRemarksList = value;

                //fill the child remarks on each sub clinics
                foreach (var item in vInAreaDept_AllDeptDetailsList)
                {
                    item.FillRemarks(value);
                }
            }
        }

        #endregion

        #region Employee - lists

        public List<vEmployeeReceptionHours> vEmployeeReceptionHoursList { get; set; }
        public List<vEmployeeReceptionRemarks> vEmployeeReceptionRemarksList { get; set; }
        public List<vEmployeeProfessionalDetails> vEmployeeProfessionalDetailsList { get; set; }
        public List<vEmployeeDeptRemarks> vEmployeeDeptRemarksList { get; set; }

        #endregion

        #region Events And Services - lists

        public List<vDeptEvents> vDeptEventsList { get; set; }
        public List<vDeptServices> vDeptServicesList { get; set; }
        public List<vServicesReceptionWithRemarks> vServicesReceptionWithRemarksList { get; set; }
        public List<vServicesAndQueueOrder> vServicesAndQueueOrderList { get; set; }
        public List<vDeptServicesRemarks> vDeptServicesRemarksList { get; set; }
        #endregion

        #region Custom properties - for template fields

        public string managerNameFormatted
        {
            get
            {
                string retVal = string.Empty;
                if (string.IsNullOrEmpty(managerName) == true)
                {
                    retVal = "---";
                }
                else
                {
                    retVal = managerName;
                }
                return retVal;
            }
        }

        public string administrativeManagerNameFormatted
        {
            get
            {
                string retVal = string.Empty;
                if (string.IsNullOrEmpty(administrativeManagerName) == true)
                {
                    retVal = "---";
                }
                else
                {
                    retVal = administrativeManagerName;
                }
                return retVal;
            }
        }

        public string geriatricsManagerNameFormatted
        {
            get
            {
                string retVal = string.Empty;
                if (string.IsNullOrEmpty(geriatricsManagerName) == true)
                {
                    retVal = "---";
                }
                else
                {
                    retVal = geriatricsManagerName;
                }
                return retVal;
            }
        }

        public string pharmacologyManagerNameFormatted
        {
            get
            {
                string retVal = string.Empty;
                if (string.IsNullOrEmpty(pharmacologyManagerName) == true)
                {
                    retVal = "---";
                }
                else
                {
                    retVal = pharmacologyManagerName;
                }
                return retVal;
            }
        }

        public string DeptRemarksHtml
        {
            get
            {
                string retStr = string.Empty;

                foreach (View_DeptRemarks rmk in View_DeptRemarksList)
                {
                    if (retStr.IndexOf("הערות") >= 0)
                        retStr += rmk.RemarkTextHtmlRow.Replace("הערות", "&nbsp;");
                    else
                        retStr += rmk.RemarkTextHtmlRow;
                }

                return retStr;
            }
        }

        public string LastUpdateDate
        {
            get
            {
                string retStr = string.Empty;

                if (vDummy_LastUpdateDateOfRemarksList != null && vDummy_LastUpdateDateOfRemarksList.Count == 1)
                {
                    if (vDummy_LastUpdateDateOfRemarksList[0].LastUpdateDateOfDept != DateTime.MinValue)
                        retStr = vDummy_LastUpdateDateOfRemarksList[0].LastUpdateDateOfDept.ToString("dd/MM/yyyy");
                    else
                        retStr = "&nbsp;";
                }

                return retStr;
            }
        }
        #endregion

        public void FillRemarks(List<View_DeptRemarks> subDeptRemarksList)
        {
            if (subDeptRemarksList != null)
            {
                View_DeptRemarksList = subDeptRemarksList.FindAll(delegate(View_DeptRemarks itemToSearch)
                {
                    return itemToSearch.deptCode == this.deptCode;
                });
            }
        }

        public void FillDeptReceptionHoursList(List<vDeptReceptionHours> receptionHoursList)
        {
            if (receptionHoursList != null)
            {
                vDeptReceptionHoursList = receptionHoursList.FindAll(delegate(vDeptReceptionHours itemToSearch)
                {
                    return itemToSearch.deptCode == this.deptCode;
                });
            }
        }

        public vAllDeptDetails()
	    {
           
        }
    }
}
