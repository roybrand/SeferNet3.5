using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SeferNet.Globals
{
    public class Enums
    {
        public enum CachedTables
        {
            AllDistricts = 1,
            UnitTypes = 2,
            Services = 3,
            Sectors = 4,
            Professions = 5
        }


        public enum Status
        {
            All = -1,
            NotActive = 0,
            Active = 1,
            TemporaryNotActive = 2
        }

        public enum ReportType
        {
            A = 1,
            B = 2,
            C = 3
        }

        public enum doctorInClinic
        {
            doctorsInClinic = 0,
            clinicsWhereDoctorWorks = 1
        }

        public enum remarkType
        {
            Clinic = 1,
            Doctor = 2,
            DoctorInClinic = 3,
            ServiceInClinic = 4,
            ReceptionHours = 5,
            Sweeping = 6,
            DoctorServiceInClinic = 7
        }

        #region User Permissions

        public enum UserPermissionType
        {
            AvailableToAll = 0,
            District = 1,
            AdminClinic = 2,
            Clinic = 3,
            ViewHiddenDetails = 4,
            Administrator = 5,
            ViewHiddenAndReports = 6,
            ManageTarifonViews = 7,
            ViewTarifon = 8,
            ManageInternetSalServices = 9,
            LanguageManagement = 10
        }

        #endregion

        public enum PhoneType
        {
            RegularPhone = 1,
            Fax = 2,
            MobilePhone = 3,
            Beeper = 4,
            DirectPhone = 5,
            WhatsApp = 6
        }

        public enum LoginResult
        {
            Unknown = int.MinValue,
            Failed = 0,
            Success = 1,
            UserNameOrPasswordNotCorrect = 2,
            NoPermissionsForUser = 3,
        }

        public enum LogoutResult
        {
            Unknown = int.MinValue,
            Failed = 0,
            Success = 1,
        }

        public enum MoveDirection
        {
            Up = 0,
            Down = 1
        }

        public enum EntityTypesStatus
        {
            Dept,
            DeptService,
            Employee,
            EmployeeInDept,
            EmployeeServiceInDept
        }

        public enum SalServicesSearchConditions
        {
            CurrentDay = 1,
            BasketApproveDate = 2,
            AddedDate = 3,
            CanceledDate = 4,
            InternetUpdatedDate = 5
        }

        public enum IncorrectDataReportEntity
        {
            Dept,
            Employee,
            SalService
        }

        public enum SortableData
        {
            address,
            cityName,
            deptName,
            doctorName,
            professions,
            QueueOrderDescription,
            HasAnotherWorkplace,
            services,
            phone,
            phones,
            subUnitTypeCode,
            lastName,
            firstName,
            agreementType,
            independent,
            serviceOrEventName,
            givenBy,
            remark,
            remarkID,
            active,
            RemarkCategoryName,
            RemarkCategoryID,
            MushlamTableCode,
            TableName,
            MushlamCode,
            MushlamServiceCode,
            MushlamDescription,
            Name,
            ParentCode,
            ParentDescription,
            PositionCode,
            QueueOrder,
            SeferServiceCode,
            ShowInInternet,
            SourceTable,
            ServiceCode,
            ServiceDescription,
            SeferServiceDescription,
            Sector,
            isProfession,
            isService,
            IsInCommunity,
            IsInMushlam,
            IsInHospitals,
            ServiceCategoryID,
            ServiceCategoryDescription,
            SubCategoryFromTableMF51,
            SubCategoryCodeFromTableMF51,
            SubCode,
            UnitTypeCode,
            UnitTypeName,
            ServiceSynonym,
            DoctorNameNoTitle,

            /* Sal Services Fields  */
            ServiceName, HealthOfficeDescription, IncludeInBasket, Limiter, Common,
            ProfessionDesc, BudgetCard, EshkolDesc, PaymentRules, MIN_CODE,
            ProfessionCode, ProfessionDescription, ProfessionDescriptionForInternet, ShowProfessionInInternet,
            SalCategoryDescription, SalCategoryID,

            /* Admin comments for sal service */
            Title, Comment, StartDate, ExpiredDate, Active,


            /* Population Pivot Sorting Columns */
            IthashbenutPnimit, IshtatfutAzmit, TaarifZiburiBet, TeunotDrahim, TaarifMale,
            KatsatPnimi, KlalitMushlam, KatsatHizoni, MimunEtzLemecutah, OvdimZarim,
            Hechzerim, bituahOhMeyuhad, TaarifeyShuk, TikzuvBetHolim, TaarifAlef,
            TaarifZiburiZam, TaarifZiburiGemel, ZahalBeklalitHova, ZahalBeklalitKeva, TaarifZiburiEskemim,

            /**/
            ServiceReturnExist, DateUpdate,
            /**/
            displayInInternet,
            RequiresQueueOrder,
            /**/
            Expert,
            /**/
            ShowForPreviousDays,
            OpenNow
        }


        public enum SearchMode
        {
            All = -1,
            Community = 1,
            Mushlam = 2,
            Hospitals = 3
        }

        public enum Target
        {
            ClinicDetailes = 10,
            ClinicDetailes_Add = 11,
            ClinicDetailes_Update = 12,
            ClinicDetailes_Delete = 13,

            ClinicPhones_Update = 15,
            ClinicAddress_Update = 16,

            ClinicReceptionHours = 20,
            ClinicReceptionHours_Add = 21,
            ClinicReceptionHours_Update = 22,
            ClinicReceptionHours_Delete = 23,

            ClinicRemarks = 30,
            ClinicRemarks_Add = 31,
            ClinicRemarks_Update = 32,
            ClinicRemarks_Delete = 33,

            EmployeeInClinic = 40,
            EmployeeInClinic_Add = 41,
            EmployeeInClinic_Update = 42,
            EmployeeInClinic_Delete = 43,

            EmployeeClinicServices = 50,
            EmployeeClinicServices_Add = 51,
            EmployeeClinicServices_Update = 52,
            EmployeeClinicServices_Delete = 53,

            EmployeeClinicServiceReceptions = 60,
            EmployeeClinicServiceReceptions_Add = 61,
            EmployeeClinicServiceReceptions_Update = 62,
            EmployeeClinicServiceReceptions_Delete = 63
        }

        public enum ChangeType
        {
            ClinicAddress_Update = 1,
            ClinicPhones_Update = 2,
            ClinicDetailes_Update = 3,
            ClinicReceptionHoursAndRemarks_Update = 4,
            ClinicRemarks_Update = 5,
            ClinicRemarks_Add = 6,
            ClinicRemarks_Delete = 7,
            // *************************
            EmployeeInClinic_Add = 11,
            EmployeeInClinic_Delete = 12,

            EmployeeInClinicPosition_Update = 13,
            EmployeeInClinicPhone_Update = 14,
            EmployeeInClinicQueueOrder_Update = 15,
            EmployeeInClinicStatus_Update = 16,
            EmployeeInClinicRemark_Update = 17,
            EmployeeInClinicRemark_Delete = 18,
            EmployeeInClinicRemark_Add = 19,

            EmployeeInClinicHoursAndRemark_Update = 25,
            EmployeeInClinicService_Delete = 26,
            EmployeeInClinicService_Add = 27,

            EmployeeInClinicServiceRemark_Update = 28,
            EmployeeInClinicServiceRemark_Add = 29,
            EmployeeInClinicServiceRemark_Delete = 30
        }

    }
}
