using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class SessionParams
    {
        public Int64 EmployeeID = 0;
        public string EmployeeName;
        public bool MarkEmployeeInClinicSelected = false;
        public bool MarkServiceInClinicSelected = false;
        public int DeptCode = 0;
        public string DeptName;
        public int counter = 0;
        public List<QueryParam> queryParamsList;
        public List<QueryField> queryFieldsList;
        public List<QueryJoin> queryJoinList; 
        public string SelectedDistrictForReport;
        public string SelectedProfessionForReport;
        public string SelectedUnitTypeCodeForReport;
        public string CallerUrl;
        public int ? ServiceCode;
        public string CurrentTab_ZoomClinic;
        public string CurrentTab_ZoomDoctor;
        public string SelectedTab_Key;
        public int ? CurrentRemarkID;
        public string LastSearchPageURL; 
        public int LastRowIndexOnSearchPage;
        public int ScrollPosition_DoctorsAndEmployees_ZoomClinic;
        public Enums.IncorrectDataReportEntity CurrentEntityToReport;
        public int totalRows = 0;
        public int DefaultReceptionHoursTypeIDForClinic = 1;
        public int RowID = 0;
        public bool isDistrictOrHospital = false;
    }

    public class SessionParams_SalServices
    {
        public string uniqueSearchParamater { get; set; }
        public int LastRowIndexOnSearchPage { get; set; }
        public int LastSelectedTabOnSearchPage { get; set; }

        public Int64 EmployeeID = 0;

        public byte? IncludeInBasket;
        public byte? Common;
        public byte? Limiter;
        public byte? ShowServiceInInternet;
        public byte? IsActive;

        public string AdvanceSearchText;

        public int? ServiceCode;
        public string ServiceName;
        public string HealthOfficeCode;
        public string HealthOfficeDesc;

        public string GroupCodes;
        public string GroupDescription;
        public string ProfessionCodes;
        public string ProfessionDescription;
        public string OmriCodes;
        public string OmriDescription;
        public string ICD9Codes;
        public string ICD9Description;

        public string PopulationCodes;
        public string PopulationDescription;
        public int SalCategoryID;
        public int SalOrganCode;

        public DateTime? BasketApproveFromDate;
        public DateTime? BasketApproveToDate;
        public DateTime? ADD_DATE_FromDate;
        public DateTime? ADD_DATE_ToDate;

        public bool? ShowCanceledServices;
        public DateTime? DEL_DATE_FromDate;
        public DateTime? DEL_DATE_ToDate;
        public DateTime? InternetUpdated_FromDate;
        public DateTime? InternetUpdated_ToDate;

        public string Condition;

        public bool IsEmpty
        {
            get
            {
                return (!this.IncludeInBasket.HasValue && !this.Common.HasValue && !this.Limiter.HasValue &&
                        !string.IsNullOrEmpty(this.AdvanceSearchText) && !this.ServiceCode.HasValue && !string.IsNullOrEmpty(this.HealthOfficeCode) &&
                        !string.IsNullOrEmpty(this.GroupCodes) && !string.IsNullOrEmpty(this.ProfessionCodes) && !string.IsNullOrEmpty(this.OmriCodes) &&
                        !string.IsNullOrEmpty(this.ICD9Codes) && !string.IsNullOrEmpty(this.PopulationCodes) && !this.BasketApproveFromDate.HasValue &&
                        this.SalCategoryID == 0 && this.SalOrganCode == 0 && !ShowCanceledServices.HasValue &&
                        !this.BasketApproveToDate.HasValue && !this.ADD_DATE_FromDate.HasValue && !this.ADD_DATE_ToDate.HasValue &&
                        !this.DEL_DATE_FromDate.HasValue && !this.DEL_DATE_ToDate.HasValue && !this.InternetUpdated_FromDate.HasValue && !this.InternetUpdated_ToDate.HasValue
                        && !string.IsNullOrEmpty(this.Condition));
            }
        }
    }

}
