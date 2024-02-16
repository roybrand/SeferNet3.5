using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Configuration;
using SeferNet.DataLayer;
using System.Data.SqlClient;
using SeferNet.Globals;
using System.Globalization;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Transactions;




namespace SeferNet.BusinessLayer.WorkFlow
{
    public class ClinicManager
    {
        string m_ConnStr;
        public ClinicManager()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang(); 
        }
        public ClinicManager(string lang)
        {

            m_ConnStr = ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"].ConnectionString;

        }

        public DataSet getClinicDetails(int deptCode, string RemarkCategoriesForAbsence, string RemarkCategoriesForClinicActivity)
        {

            ClinicDB clinicdb = new ClinicDB();
            DataSet dsClinic = new DataSet();

            clinicdb.getClinicDetails(ref dsClinic, deptCode, RemarkCategoriesForAbsence, RemarkCategoriesForClinicActivity);
             
            dsClinic.Tables[0].TableName = "deptDetails";
            dsClinic.Tables[1].TableName = "deptLastUpdateDates";
            dsClinic.Tables[2].TableName = "HandicappedFacilities";
            dsClinic.Tables[3].TableName = "generalRemarks";            
            dsClinic.Tables[4].TableName = "DeptQueueOrderMethods";
            dsClinic.Tables[5].TableName = "HoursForDeptQueueOrder";
            dsClinic.Tables[6].TableName = "MushlamServices";
            dsClinic.Tables[7].TableName = "DeptPhones";
            dsClinic.Tables[8].TableName = "EmployeeAndServiceRemarks";

            return dsClinic;
        }

        public DataSet getDeptSubClinics(int deptCode)
        {

            ClinicDB clinicdb = new ClinicDB();
            DataSet dsClinic = new DataSet();

            clinicdb.getDeptSubClinics(ref dsClinic, deptCode);

            dsClinic.Tables[0].TableName = "subClinics";

            return dsClinic;
        }


        public DataSet getClinicByName(string searchStr)
        {
           ClinicDB deptdb = new ClinicDB();           
           return deptdb.getClinicByName(searchStr);            
        }

        public DataSet getDistrictsByName(string searchStr, string unitTypeCodes)
        {
           ClinicDB deptdb = new ClinicDB();
           return deptdb.getDistrictsByName(searchStr, unitTypeCodes);            
        }

        public DataSet getDistrictsByUnitType(string unitTypeCodes)
        {
            ClinicDB deptdb = new ClinicDB();
            return deptdb.getDistrictsByUnitType(unitTypeCodes);
        }

        public DataSet getClinicByName_DistrictDepended(string searchStr, string districtCodes, int clinicStatus,
            bool deptCodeLeading, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
           ClinicDB deptdb = new ClinicDB();
           
            if (deptCodeLeading)
               return deptdb.getClinicByName_DistrictDepended_DeptCodeLeading(searchStr, districtCodes);
           else
                return deptdb.getClinicByName_DistrictDepended(searchStr, districtCodes, clinicStatus, agreementTypes);
        }
        public DataSet getClinicByName_District_City_ClinicType_Status_Depended(string searchStr, string districtCodes, int clinicStatus, int cityCode, string clinicType, 
            bool deptCodeLeading, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
           ClinicDB deptdb = new ClinicDB();
           
            if (deptCodeLeading)
               return deptdb.getClinicByName_DistrictDepended_DeptCodeLeading(searchStr, districtCodes);
           else
                return deptdb.getClinicByName_District_City_ClinicType_Status_Depended(searchStr, districtCodes, clinicStatus, cityCode, clinicType, agreementTypes);
        }
        
        public DataSet GetHealthOfficeDesc(string searchStr)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetHealthOfficeDesc(searchStr);
        }

        public DataSet GetICD9Desc(string searchStr)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetICD9Desc(searchStr);
        }

        public DataSet GetServiceCodesForSalServices(string searchStr)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetServiceCodesForSalServices(searchStr);
        }

        public DataSet GetMedicalAspectsForAutocomplete(string searchStr)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetMedicalAspectsForAutocomplete(searchStr);
        }

        public DataSet GetClalitServiceDescription_ByClalitServiceCode(int clalitServiceCode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetClalitServiceDescription_ByClalitServiceCode(clalitServiceCode);
        }

        public DataSet GetMedicalAspectDescription_ByMedicalAspectCode(string medicalAspectCode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetMedicalAspectDescription_ByMedicalAspectCode(medicalAspectCode);
        }

        public DataSet GetClalitServicesForAutocomplete(string searchStr)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetClalitServicesForAutocomplete(searchStr);
        }

        public DataSet getAdminByName_DistrictDepended(string searchStr, string districtCodes)
        {
           ClinicDB deptdb = new ClinicDB();
           return deptdb.getAdminByName_DistrictDepended(searchStr, districtCodes);            
        }
        
		public DataSet GetEventsByName(string searchStr)
        {
           ClinicDB deptdb = new ClinicDB();
           return deptdb.GetEventsByName(searchStr);            
        }

		public DataSet GetServicesAndEventsByName(string searchStr, Dictionary<Enums.SearchMode, bool> AgreementTypes)
        {
           ClinicDB deptdb = new ClinicDB();
           return deptdb.GetServicesAndEventsByName(searchStr, AgreementTypes);            
        }

        public DataSet GetServicesByName(string searchStr)
        {
           ClinicDB deptdb = new ClinicDB();
           return deptdb.GetServicesByName(searchStr);            
        }

        public DataSet GetServicesByNameAndSector(string searchStr, int sectorCode, Dictionary<Enums.SearchMode, bool> AgreementTypes)
		{
			ClinicDB deptdb = new ClinicDB();
            return deptdb.GetServicesByNameAndSector(searchStr, sectorCode, AgreementTypes);
		}

        public DataSet GetHandicappedFacilitiesByName(string searchStr)
        {
           ClinicDB deptdb = new ClinicDB();
           return deptdb.GetHandicappedFacilitiesByName(searchStr);            
        }

        public int getDeptDistrict(int deptCode)
        {
           ClinicDB deptdb = new ClinicDB();
           return deptdb.getDeptDistrict(deptCode);           
        }


        public DataSet getClinicServices(int deptCode)
        {
            ClinicDB clinicdb = new ClinicDB();
            DataSet dsClinicServices = new DataSet();
            clinicdb.getClinicServices(ref dsClinicServices, deptCode);

            dsClinicServices.Tables[0].TableName = "DeptEmployeePositions";
            dsClinicServices.Tables[1].TableName = "DeptEmployeeProfessions";
            dsClinicServices.Tables[2].TableName = "DeptEmployeeServices";
            dsClinicServices.Tables[3].TableName = "EmployeeQueueOrderMethods";
            dsClinicServices.Tables[4].TableName = "HoursForEmployeeQueueOrder";
            dsClinicServices.Tables[5].TableName = "EmployeeOtherPlaces";
            dsClinicServices.Tables[6].TableName = "EmployeeProfessionsAtOtherPlaces";
            dsClinicServices.Tables[7].TableName = "EmployeeServicesAtOtherPlaces";
            dsClinicServices.Tables[8].TableName = "deptDoctors";
            dsClinicServices.Tables[9].TableName = "deptEventPhones";
            dsClinicServices.Tables[10].TableName = "DeptPhones";
            dsClinicServices.Tables[11].TableName = "deptEvents";
            dsClinicServices.Tables[12].TableName = "EmployeeRemarks";

            return dsClinicServices;
        }

        public DataSet getClinicReceptionAndRemarks(int deptCode, DateTime expirationDate, string serviceCodes, string remarkCategoriesForAbsence, string RemarkCategoriesForClinicActivity)
        {
            ClinicDB clinicdb = new ClinicDB();
            DataSet dsClinicReception = new DataSet();
            clinicdb.getClinicReceptionAndRemarks(ref dsClinicReception, deptCode, expirationDate, serviceCodes, remarkCategoriesForAbsence, RemarkCategoriesForClinicActivity);

            dsClinicReception.Tables[0].TableName = "deptReception";
            dsClinicReception.Tables[1].TableName = "deptRemarks";
            dsClinicReception.Tables[2].TableName = "deptName";
            dsClinicReception.Tables[3].TableName = "deptReceptionRemarks";
            dsClinicReception.Tables[4].TableName = "ReceptionDaysUnited";
            dsClinicReception.Tables[5].TableName = "closestDeptReceptionChange";
            dsClinicReception.Tables[6].TableName = "closestOfficeReceptionChange";
            dsClinicReception.Tables[7].TableName = "ReceptionHoursType";
            dsClinicReception.Tables[8].TableName = "DefaultReceptionHoursType";
            dsClinicReception.Tables[9].TableName = "closestDateChanges";
            dsClinicReception.Tables[10].TableName = "employeeAndServiceRemarks";

            foreach (DataRow dr in dsClinicReception.Tables["deptRemarks"].Rows)
            {
                dr["RemarkText"] = dr["RemarkText"].ToString().Replace("<a href", "<a target='_blank' href");
            }
            return dsClinicReception;
        }

        public DataSet getClinicList_PagedSorted(ClinicSearchParameters clinicSearchParameters, ClinicSearchParametersForMushlamServices clinicSearchParametersForMushlamServices,
          SearchPagingAndSortingDBParams searchPagingAndSortingDBParams)
        {

            DataSet dsClinicList = Globals.CacheHandler.Instance.GetPersonalCacheItem<DataSet>(Globals.CacheItemsEnum.SearchResults);
            if (clinicSearchParameters.IsFromCached && dsClinicList != null)
            {
                return dsClinicList;
            }

            ClinicDB clinicdb = new ClinicDB();
            
            int? status = (clinicSearchParameters.Status == -1) ? null : clinicSearchParameters.Status;

            clinicSearchParameters.PrepareParametersForDBQuery();
            dsClinicList = clinicdb.getClinicList_PagedSorted(
                clinicSearchParameters.UserIsLogged,
                clinicSearchParameters.DistrictCodes,
                clinicSearchParameters.MapInfo.CityCode,  
				clinicSearchParameters.UnitTypeCodes,clinicSearchParameters.SubUnitTypeCodes,
				clinicSearchParameters.ServiceCodes, clinicSearchParameters.DeptName, clinicSearchParameters.DeptCode,//julia
				clinicSearchParameters.CurrentReceptionTimeInfo.ReceptionDays, clinicSearchParameters.CurrentReceptionTimeInfo.InHour,
				clinicSearchParameters.CurrentReceptionTimeInfo.FromHour, clinicSearchParameters.CurrentReceptionTimeInfo.ToHour, clinicSearchParameters.CurrentReceptionTimeInfo.OpenNow,
				clinicSearchParameters.CurrentSearchModeInfo.IsCommunitySelected,
				clinicSearchParameters.CurrentSearchModeInfo.IsMushlamSelected,
				clinicSearchParameters.CurrentSearchModeInfo.IsHospitalsSelected,
                status, clinicSearchParameters.PopulationSectorCode, clinicSearchParameters.HandicappedFacilitiesCodes,
                clinicSearchParameters.ReceiveGuests,
				searchPagingAndSortingDBParams.PageSize,searchPagingAndSortingDBParams.StartingPage,searchPagingAndSortingDBParams.SortedBy,searchPagingAndSortingDBParams.IsOrderDescending,
                clinicSearchParameters.MapInfo.CoordinatX, 
                clinicSearchParameters.MapInfo.CoordinatY, clinicSearchParameters.NumberOfRecordsToShow,
                clinicSearchParameters.ClalitServiceCode, clinicSearchParameters.ClalitServiceDescription, clinicSearchParameters.MedicalAspectCode, clinicSearchParameters.MedicalAspectDescription,
                clinicSearchParametersForMushlamServices.ServiceCodeForMuslam, clinicSearchParametersForMushlamServices.GroupCode, clinicSearchParametersForMushlamServices.SubGroupCode, clinicSearchParameters.QueueOrderMethodsAndOptionsCodes);

            dsClinicList.Tables[0].TableName = "depts";
            dsClinicList.Tables[1].TableName = "rowsCount";
            dsClinicList.Tables[3].TableName = "QueueOrderMethods";
            dsClinicList.Tables[4].TableName = "DeptPhones";
            dsClinicList.Tables[5].TableName = "QueueOrderPhones";
            dsClinicList.Tables[6].TableName = "AllSelectedCodes";

            Globals.CacheHandler.Instance.AddPersonalCacheItem(Globals.CacheItemsEnum.SearchResults, dsClinicList);

            return dsClinicList;
        }

        public DataSet getClinicList_PagedSorted(string CodesListForPage_1, string CodesListForPage_2, string CodesListForPage_3, ClinicSearchParameters clinicSearchParameters, ClinicSearchParametersForMushlamServices clinicSearchParametersForMushlamServices,
          SearchPagingAndSortingDBParams searchPagingAndSortingDBParams)
        {

            DataSet dsClinicList = Globals.CacheHandler.Instance.GetPersonalCacheItem<DataSet>(Globals.CacheItemsEnum.SearchResults);
            if (clinicSearchParameters.IsFromCached && dsClinicList != null)
            {
                return dsClinicList;
            }

            ClinicDB clinicdb = new ClinicDB();
            
            int? status = (clinicSearchParameters.Status == -1) ? null : clinicSearchParameters.Status;

            clinicSearchParameters.PrepareParametersForDBQuery();
            dsClinicList = clinicdb.getClinicList_PagedSorted(CodesListForPage_1, CodesListForPage_2, CodesListForPage_3,

				clinicSearchParameters.ServiceCodes,
				clinicSearchParameters.CurrentReceptionTimeInfo.ReceptionDays, clinicSearchParameters.CurrentReceptionTimeInfo.InHour,
				clinicSearchParameters.CurrentReceptionTimeInfo.FromHour, clinicSearchParameters.CurrentReceptionTimeInfo.ToHour, clinicSearchParameters.CurrentReceptionTimeInfo.OpenNow,
				clinicSearchParameters.CurrentSearchModeInfo.IsCommunitySelected,
				clinicSearchParameters.CurrentSearchModeInfo.IsMushlamSelected,
				clinicSearchParameters.CurrentSearchModeInfo.IsHospitalsSelected,
                clinicSearchParameters.ReceiveGuests,
                clinicSearchParameters.MapInfo.CoordinatX, 
                clinicSearchParameters.MapInfo.CoordinatY, 
                clinicSearchParameters.ClalitServiceCode, 
                clinicSearchParametersForMushlamServices.ServiceCodeForMuslam);

            dsClinicList.Tables[0].TableName = "depts";
            dsClinicList.Tables[1].TableName = "QueueOrderMethods";
            dsClinicList.Tables[2].TableName = "DeptPhones";
            dsClinicList.Tables[3].TableName = "QueueOrderPhones";

            Globals.CacheHandler.Instance.AddPersonalCacheItem(Globals.CacheItemsEnum.SearchResults, dsClinicList);

            return dsClinicList;
        }


        public DataSet getClinicList_ForPrinting(ClinicSearchParameters clinicSearchParameters, ClinicSearchParametersForMushlamServices clinicSearchParametersForMushlamServices,
           string foundDeptCodeList)
        {
            ClinicDB clinicdb = new ClinicDB();
            
            int? status = (clinicSearchParameters.Status == -1) ? null : clinicSearchParameters.Status;

            clinicSearchParameters.PrepareParametersForDBQuery();
            DataSet dsClinicList = clinicdb.getClinicList_ForPrinting(
				clinicSearchParameters.ServiceCodes, clinicSearchParameters.CurrentReceptionTimeInfo.ReceptionDays,
                clinicSearchParameters.CurrentReceptionTimeInfo.InHour,
				clinicSearchParameters.CurrentReceptionTimeInfo.FromHour, clinicSearchParameters.CurrentReceptionTimeInfo.ToHour, clinicSearchParameters.CurrentReceptionTimeInfo.OpenNow,
				clinicSearchParameters.CurrentSearchModeInfo.IsCommunitySelected,
				clinicSearchParameters.CurrentSearchModeInfo.IsMushlamSelected,
				clinicSearchParameters.CurrentSearchModeInfo.IsHospitalsSelected, status, 
                clinicSearchParameters.ReceiveGuests, clinicSearchParametersForMushlamServices.ServiceCodeForMuslam, 
                clinicSearchParametersForMushlamServices.GroupCode, clinicSearchParametersForMushlamServices.SubGroupCode,
                foundDeptCodeList);

            return dsClinicList;
        }

        public DataSet GetDeptRandomOrder()
        {
            ClinicDB clinicdb = new ClinicDB();

            DataSet dsDeptRandomOrder = clinicdb.GetDeptRandomOrder();

            return dsDeptRandomOrder;
        }

        public DataSet getZoomClinic_ForPrinting(int deptCode, bool isInternal, string deptCodesInArea)
        {
            ClinicDB clinicdb = new ClinicDB();

            DataSet dsZoomClinic = clinicdb.getZoomClinic_ForPrinting(deptCode, isInternal, deptCodesInArea);

            return dsZoomClinic;
        }
        public DataSet getNewClinicsList(int? DeptCode, string DeptName, DateTime? OpenDateSimul, int? ExistsInSefer)
        {
            DataSet dsClinicList;
            ClinicDB clinicdb = new ClinicDB();
            dsClinicList = clinicdb.getNewClinicsList(DeptCode, DeptName, OpenDateSimul, ExistsInSefer);
            return dsClinicList;
        }

        public int InsertNewClinicsList()
        {
            ClinicDB clinicdb = new ClinicDB();

            return clinicdb.InsertNewClinicsList();
        }

        public int InsertUnitTypeConvertSimul()
        {
            ClinicDB clinicdb = new ClinicDB();

            return clinicdb.InsertUnitTypeConvertSimul();
        }

        public DataSet GetErrorsListSimulVcSefer(int errorCode)
        {
            DataSet dsClinicList;
            ClinicDB clinicdb = new ClinicDB();
            dsClinicList = clinicdb.GetErrorsListSimulVcSefer(errorCode);
            return dsClinicList;
        }

        public DataSet GetNewClinic(int deptCode)
        {
            DataSet dsClinic;
            ClinicDB clinicdb = new ClinicDB();
            dsClinic = clinicdb.GetNewClinic(deptCode);
            return dsClinic;
        }

        public void DeleteSimulNewDepts(int deptCode)
        {
            ClinicDB clinicdb = new ClinicDB();
            clinicdb.DeleteSimulNewDepts(deptCode);
        }


        public DataSet GetDeptEventForPopUp(int deptEventID)
        {
            ClinicDB clinicdb = new ClinicDB();

            DataSet dsEvent = clinicdb.GetDeptEventForPopUp(deptEventID);

            return dsEvent;
        }

        public DataSet GetDeptEventForUpdate(int deptEventID)
        {
            ClinicDB clinicdb = new ClinicDB();

            DataSet dsEvent = clinicdb.GetDeptEventForUpdate(deptEventID);
            dsEvent.Tables[0].TableName = "DeptEvent";
            dsEvent.Tables[1].TableName = "DeptEventParticulars";
            dsEvent.Tables[2].TableName = "DeptEventPhones";
            dsEvent.Tables[3].TableName = "DeptEventFiles";

            return dsEvent;
        }

        public DataSet GetServiceForPopUp_ViaEmployee(int deptCode, long employeeID, int agreementType, int serviceCode, DateTime expirationDate, string RemarkCategoriesForAbsence, string RemarkCategoriesForClinicActivity)
        {
            ClinicDB clinicdb = new ClinicDB();

            DataSet dsEvent = clinicdb.GetServiceForPopUp_ViaEmployee(deptCode, employeeID, agreementType, serviceCode, expirationDate, RemarkCategoriesForAbsence, RemarkCategoriesForClinicActivity);

            return dsEvent;
        }

        public DataSet GetDeptDetailsForUpdate(int p_deptCode)
        {
            ClinicDB deptdb = new ClinicDB();
            DataSet dsDept = new DataSet();
            deptdb.GetDeptDetailsForUpdate(ref dsDept, p_deptCode);

            dsDept.Tables[0].TableName = "DeptDetails";            
            dsDept.Tables[1].TableName = "DeptHandicappedFacilities";
            dsDept.Tables[2].TableName = "DeptQueueOrderMethods_ForHeadline";                       
            dsDept.Tables[3].TableName = "Remarks";
            dsDept.Tables[4].TableName = "DeptPhones";
            dsDept.Tables[5].TableName = "DeptFaxes";
            dsDept.Tables[6].TableName = "DeptDirectPhones";
            dsDept.Tables[7].TableName = "WhatsAppPhones";

            return dsDept;
        }

        public DataSet GetDeptNamesForUpdate(int p_deptCode)
        {
            ClinicDB deptdb = new ClinicDB();
            DataSet dsDept = new DataSet();
            deptdb.GetDeptNamesForUpdate(ref dsDept, p_deptCode);

            dsDept.Tables[0].TableName = "DeptDetails";
            dsDept.Tables[1].TableName = "DeptNames";

            return dsDept;
        }

        public string GetDefaultDeptNameForIndependentClinic(int p_deptCode)
        {
            ClinicDB deptdb = new ClinicDB();
            DataSet dsDept = new DataSet();
            return deptdb.GetDefaultDeptNameForIndependentClinic(p_deptCode);
        }

        public DataSet GetDeptDetailsForPopUp(int p_deptCode)
        {
            ClinicDB deptdb = new ClinicDB();
            DataSet dsDept = new DataSet();
            deptdb.GetDeptDetailsForPopUp(ref dsDept, p_deptCode);

            return dsDept;
        }

        public DataSet getAdministrationList(int p_districtCode)
        {
            DataSet dsAdministration = new DataSet();
            getAdministrationList(ref dsAdministration, p_districtCode);
            return dsAdministration;
        }

        public void  getAdministrationList(ref DataSet p_dsAdmins , int p_districtCode)
        {
            ClinicDB clinicdb = new ClinicDB();

            clinicdb.getAdministrationList(ref p_dsAdmins, p_districtCode);

            if ((p_dsAdmins != null) && (p_dsAdmins.Tables.Count > 0))
            {
                p_dsAdmins.Tables[0].TableName = "AdministrationList";
            } 
        }

        public void UpdateDeptEventTransaction(int deptCode, object[] inputParamsDeptEvent,
            DataTable dtDeptEventMeetings, DataTable dtDeptEventPhones, bool phonesFromDept)
        {
            string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();
            int eventID = 0;

            using (TransactionScope trans = TranscationScopeFactory.GetForUpdatedRecords())
            {

                ClinicDB clinicdb = new ClinicDB();
                PhoneDB phoneDB = new PhoneDB(m_ConnStr);

                eventID = Convert.ToInt32(inputParamsDeptEvent[1]);
                //UpdateDeptEvent
                clinicdb.UpdateDeptEvent(inputParamsDeptEvent);

                clinicdb.DeleteDeptEventParticulars(eventID);

                for (int i = 0; i < dtDeptEventMeetings.Rows.Count; i++)
                {
                    clinicdb.InsertDeptEventParticular(eventID,
                       Convert.ToDateTime(dtDeptEventMeetings.Rows[i]["Date"]),
                       dtDeptEventMeetings.Rows[i]["OpeningHour"].ToString(),
                       dtDeptEventMeetings.Rows[i]["ClosingHour"].ToString(), updateUser);
                }

                //update event phone
                phoneDB.DeleteDeptEventPhones(eventID);

                if (!phonesFromDept)
                {
                    for (int i = 0; i < dtDeptEventPhones.Rows.Count; i++)
                    {
                        int prePrefix = -1;
                        int prefix = -1;
                        int extension = -1;
                        if (dtDeptEventPhones.Rows[i]["prePrefix"] != null && dtDeptEventPhones.Rows[i]["prePrefix"].ToString() != string.Empty)
                            prePrefix = Convert.ToInt32(dtDeptEventPhones.Rows[i]["prePrefix"]);
                        if (dtDeptEventPhones.Rows[i]["prefixCode"] != null && dtDeptEventPhones.Rows[i]["prefixCode"].ToString() != string.Empty)
                            prefix = Convert.ToInt32(dtDeptEventPhones.Rows[i]["prefixCode"]);
                        if (dtDeptEventPhones.Rows[i]["extension"] != null && dtDeptEventPhones.Rows[i]["extension"].ToString() != string.Empty)
                            extension = Convert.ToInt32(dtDeptEventPhones.Rows[i]["extension"]);

                        phoneDB.InsertDeptEventPhone(eventID, prePrefix, prefix,
                           Convert.ToInt32(dtDeptEventPhones.Rows[i]["phone"]), extension, updateUser);
                    }
                }

                trans.Complete();
                trans.Dispose();
            }
        }


        public int InsertDeptEvent(int deptCode, object[] inputParamsDeptEvent,
            DataTable dtDeptEventMeetings, DataTable dtDeptEventPhones, bool cascadePhonesFromDept)
        {
            string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();
            int count = 0;
            int eventID = 0;

            using (TransactionScope trans = TranscationScopeFactory.GetForUpdatedRecords())
            {

                ClinicDB clinicdb = new ClinicDB();
                PhoneDB phoneDB = new PhoneDB(m_ConnStr);               
                
                eventID = clinicdb.InsertDeptEvent(inputParamsDeptEvent);

                //update event meetings
                clinicdb.DeleteDeptEventParticulars(eventID);

                for (int i = 0; i < dtDeptEventMeetings.Rows.Count; i++)
                {
                    count = clinicdb.InsertDeptEventParticular(eventID,
                        Convert.ToDateTime(dtDeptEventMeetings.Rows[i]["Date"]),
                        dtDeptEventMeetings.Rows[i]["OpeningHour"].ToString(),
                        dtDeptEventMeetings.Rows[i]["ClosingHour"].ToString(), updateUser);
                }

                //update event phone
                phoneDB.DeleteDeptEventPhones(eventID);

                if (!cascadePhonesFromDept)
                {
                    for (int i = 0; i < dtDeptEventPhones.Rows.Count; i++)
                    {
                        int prePrefix = -1;
                        int prefix = -1;
                        int extension = -1;
                        if (dtDeptEventPhones.Rows[i]["prePrefix"] != null && dtDeptEventPhones.Rows[i]["prePrefix"].ToString() != string.Empty)
                            prePrefix = Convert.ToInt32(dtDeptEventPhones.Rows[i]["prePrefix"]);
                        if (dtDeptEventPhones.Rows[i]["prefixCode"] != null && dtDeptEventPhones.Rows[i]["prefixCode"].ToString() != string.Empty)
                            prefix = Convert.ToInt32(dtDeptEventPhones.Rows[i]["prefixCode"]);
                        if (dtDeptEventPhones.Rows[i]["extension"] != null && dtDeptEventPhones.Rows[i]["extension"].ToString() != string.Empty)
                            extension = Convert.ToInt32(dtDeptEventPhones.Rows[i]["extension"]);

                        phoneDB.InsertDeptEventPhone(eventID, prePrefix, prefix,
                           Convert.ToInt32(dtDeptEventPhones.Rows[i]["phone"]), extension, updateUser);
                    }
                }

                trans.Complete();
                trans.Dispose();

                return eventID;
            }
        }

        public int DeleteDeptEvent(int deptEventID)
        {
            ClinicDB deptdb = new ClinicDB();
            int deletedRecordsCount = 0;
            // delete ...
            return deletedRecordsCount;
        }
        public int InsertNewDept(int deptCode, string updateUser, double coordinateX, double coordinateY, double XLongitude, double YLatitude, string SPSlocationLink, ref string errorMessage)
        {
            int ErrorStatus = 0;
            int count = 0;

            ClinicDB clinicdb = new ClinicDB();
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);

            //  insert to "dept"
            count = clinicdb.InsertDept(deptCode, updateUser);

            if (count == 0)
                ErrorStatus = 1;

            // insert to "deptSimul"
            count = clinicdb.InsertDeptSimul(deptCode);

            if (count == 0)
                ErrorStatus = 1;

            //  insert into "DeptNames"
            count = clinicdb.InsertDeptNameForNewDept(deptCode, updateUser);

            if (count == 0)
                ErrorStatus = 1;

            //  insert into "DeptStatus"
            count = clinicdb.InsertDeptStatusForNewDept( deptCode, updateUser);

            if (count == 0)
                ErrorStatus = 1;

            //  insert into "X_dept_XY"
            ErrorStatus = clinicdb.InsertX_dept_XY(deptCode, coordinateX, coordinateY, XLongitude, YLatitude, false, SPSlocationLink);

            ErrorStatus = phoneDB.InsertDeptPhonesForNewDept(deptCode, updateUser);

            return ErrorStatus;
        }

        public void UpdateDeptToCommunity(int deptCode, string updateUser, ref string errorMessage)
        {
            ClinicDB clinicdb = new ClinicDB();
          
            clinicdb.InsertDeptSimul(deptCode);
            clinicdb.UpdateDeptGeneralBelongings(deptCode, true, null, null);
       }

        public void UpdateDeptNames(int deptCode,  int deptLevel, int? displayPriority, DataTable deptNames, ref string errorMessage)
        {
            string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();

            ClinicDB clinicdb = new ClinicDB();
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);
            QueueOrderMethodDB queueOrderMethodDB = new QueueOrderMethodDB(m_ConnStr);

            //  update "deptDeptLevel" and "showUnitInInternet"
            clinicdb.UpdateDeptLevelAndShowInInternet(deptCode, deptLevel, displayPriority, updateUser);

            //  delete from "DeptNames"
            clinicdb.DeleteDeptNames(deptCode);

            for (int i = 0; i < deptNames.Rows.Count; i++)
            {
                DateTime? toDate = null;
                if (deptNames.Rows[i]["toDate"] != DBNull.Value)
                    toDate = Convert.ToDateTime(deptNames.Rows[i]["toDate"]);

                clinicdb.InsertDeptName(deptCode, deptNames.Rows[i]["deptName"].ToString(),
                                    deptNames.Rows[i]["deptNameFreePart"].ToString(),
                                    Convert.ToDateTime(deptNames.Rows[i]["fromDate"]), 
                                    toDate ,  updateUser);
            }
        }

        public void UpdateDeptNamesOnly(int deptCode, DataTable deptNames, ref string errorMessage)
        {
            string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();

            ClinicDB clinicdb = new ClinicDB();
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);
            QueueOrderMethodDB queueOrderMethodDB = new QueueOrderMethodDB(m_ConnStr);

            //  delete from "DeptNames"
            clinicdb.DeleteDeptNames(deptCode);

            for (int i = 0; i < deptNames.Rows.Count; i++)
            {
                DateTime? toDate = null;
                if (deptNames.Rows[i]["toDate"] != DBNull.Value)
                    toDate = Convert.ToDateTime(deptNames.Rows[i]["toDate"]);

                clinicdb.InsertDeptName(deptCode, deptNames.Rows[i]["deptName"].ToString(),
                                    deptNames.Rows[i]["deptNameFreePart"].ToString(),
                                    Convert.ToDateTime(deptNames.Rows[i]["fromDate"]),
                                    toDate, updateUser);
            }
        }

        public int UpdateDeptDetailsTransaction(int deptCode, string updateUser, object[] inputParams, string deptHandicappedFacilities,
            DataTable dtDeptPhones, DataTable dtDeptFaxes, DataTable dtDeptDirectPhones, DataTable dtDeptWhatsApp, double coordinateX, double coordinateY,
            double XLongitude, double YLatitude,
            bool getCoordXYfromWServiceOK, bool needToUpdateCoordinates, bool updateCoordinatesManually, string locationLink)
        {
            int ErrorStatus = 0;
            int count = 0;

            //add PhoneType column to "dtDeptFaxes" and to "dtDeptPhones"
            // and setting appropriate values
            DataColumn clmnPhoneType = new DataColumn("phoneType", System.Type.GetType("System.Int32"));
            DataColumn clmnFaxType = new DataColumn("phoneType", System.Type.GetType("System.Int32"));
            if(dtDeptPhones.Columns["phoneType"] == null)
                dtDeptPhones.Columns.Add(clmnPhoneType);
            if (dtDeptFaxes.Columns["phoneType"] == null)
                dtDeptFaxes.Columns.Add(clmnFaxType);
            if(dtDeptDirectPhones.Columns["phoneType"] == null)
                dtDeptDirectPhones.Columns.Add(clmnPhoneType);
            if(dtDeptWhatsApp.Columns["phoneType"] == null)
                dtDeptWhatsApp.Columns.Add(clmnPhoneType);

            for (int i = 0; i < dtDeptPhones.Rows.Count; i++ )
            {
                dtDeptPhones.Rows[i]["phoneType"] = (int)Enums.PhoneType.RegularPhone;
            }
            for (int i = 0; i < dtDeptFaxes.Rows.Count; i++)
            {
                dtDeptFaxes.Rows[i]["phoneType"] = (int)Enums.PhoneType.Fax;
            }
            for (int i = 0; i < dtDeptDirectPhones.Rows.Count; i++)
            {
                dtDeptDirectPhones.Rows[i]["phoneType"] = (int)Enums.PhoneType.DirectPhone;
            }
            for (int i = 0; i < dtDeptWhatsApp.Rows.Count; i++)
            {
                dtDeptWhatsApp.Rows[i]["phoneType"] = (int)Enums.PhoneType.WhatsApp;
            }


            DataTable dtDeptPhonesCopy = dtDeptPhones.Copy();


            if (dtDeptFaxes != null)
            {
                DataTable dtDeptFaxesCopy = dtDeptFaxes.Copy();
                dtDeptPhonesCopy.Merge(dtDeptFaxesCopy);
            }
            if (dtDeptDirectPhones != null)
            {
                DataTable dtDeptDirectPhonesCopy = dtDeptDirectPhones.Copy();
                dtDeptPhonesCopy.Merge(dtDeptDirectPhonesCopy);
            }
            if (dtDeptWhatsApp != null)
            {
                DataTable dtDeptWhatsAppCopy = dtDeptWhatsApp.Copy();
                dtDeptPhonesCopy.Merge(dtDeptWhatsAppCopy);
            }

            ClinicDB clinicdb = new ClinicDB();
            PhoneDB phoneDB = new PhoneDB(m_ConnStr);
            QueueOrderMethodDB queueOrderMethodDB = new QueueOrderMethodDB(m_ConnStr);

        //  update "dept"
            ErrorStatus = clinicdb.UpdateDept(inputParams);

        //  update "x_dept_XY"
            if (getCoordXYfromWServiceOK && needToUpdateCoordinates)
            {
                ErrorStatus = clinicdb.DeleteX_dept_XY(deptCode);

                ErrorStatus = clinicdb.InsertX_dept_XY(deptCode, coordinateX, coordinateY, XLongitude, YLatitude, updateCoordinatesManually, locationLink);
            }

        // update DeptHandicappedFacilities
            ErrorStatus = clinicdb.UpdateDeptHandicappedFacilities(deptCode, deptHandicappedFacilities);

        //  delete from "DeptPhones"
            ErrorStatus = phoneDB.DeleteDeptPhones(deptCode);

        //  insert into "DeptPhones"
            for (int i = 0; i < dtDeptPhonesCopy.Rows.Count; i++)
            {
                if (dtDeptPhonesCopy.Rows[i]["extension"].ToString().Trim() == string.Empty)
                    dtDeptPhonesCopy.Rows[i]["extension"] = -1;

                if (dtDeptPhonesCopy.Rows[i]["prePrefix"] == DBNull.Value || dtDeptPhonesCopy.Rows[i]["prePrefix"].ToString().Trim() == string.Empty)
                    dtDeptPhonesCopy.Rows[i]["prePrefix"] = -1;

                if (dtDeptPhonesCopy.Rows[i]["prefixCode"] == DBNull.Value || dtDeptPhonesCopy.Rows[i]["prefixCode"].ToString().Trim() == string.Empty)
                    dtDeptPhonesCopy.Rows[i]["prefixCode"] = -1;

                if (dtDeptPhonesCopy.Rows[i]["Remark"] == DBNull.Value || dtDeptPhonesCopy.Rows[i]["Remark"].ToString().Trim() == string.Empty)
                    dtDeptPhonesCopy.Rows[i]["Remark"] = string.Empty;

                count = phoneDB.InsertDeptPhone( deptCode, Convert.ToInt32(dtDeptPhonesCopy.Rows[i]["PhoneType"]), // 1 - phoneType "phone"
                    Convert.ToInt32(dtDeptPhonesCopy.Rows[i]["phoneOrder"]), Convert.ToInt32(dtDeptPhonesCopy.Rows[i]["prePrefix"]),
                    Convert.ToInt32(dtDeptPhonesCopy.Rows[i]["prefixCode"]), Convert.ToInt32(dtDeptPhonesCopy.Rows[i]["phone"]),
                    Convert.ToInt32(dtDeptPhonesCopy.Rows[i]["extension"]), dtDeptPhonesCopy.Rows[i]["Remark"].ToString(), updateUser);

                if (count == 0)
                    ErrorStatus = 1;
            }

            return ErrorStatus;

        }

        public bool UpdateSalServiceInternetDetails(int serviceCode, string serviceNameForInternet, string serviceDetails,
            string serviceBrief, string serviceDetailsInternet, byte queueOrder, byte showServiceInInternet, byte updateComplete, string updateUser,
            byte diagnosis, byte treatment, int salOrganCode, string synonyms, string refund)
        {
            ClinicDB clinicdb = new ClinicDB();

            return (clinicdb.UpdateSalServiceInternetDetails(serviceCode, serviceNameForInternet, serviceDetails,
                serviceBrief, serviceDetailsInternet, queueOrder, showServiceInInternet, updateComplete, updateUser,
                diagnosis, treatment, salOrganCode, synonyms, refund) > 0);
        }

        public int InsertDoctorInClinic(int deptCode, long employeeID,
            int agreementType, string updateUser, bool active )
        {
            ClinicDB clinicdb = new ClinicDB();

            return clinicdb.InsertDoctorInClinic(deptCode, employeeID, agreementType, updateUser, active);
        }

        public DataSet GetClinicTeamAgreementsInDept(int deptCode)
        { 
            DataSet ds = new DataSet();

            ClinicDB clinicdb = new ClinicDB();
            ds = clinicdb.GetClinicTeamAgreementsInDept(deptCode);

            return ds;
        }

        public DataSet GetDeptEmployeeID(int deptCode, long employeeID)
        { 
            DataSet ds = new DataSet();

            ClinicDB clinicdb = new ClinicDB();
            ds = clinicdb.GetDeptEmployeeID(deptCode, employeeID);

            return ds;
        }

        public DataSet GetEmployeeClinicTeam(int deptCode)
        {
            DataSet ds = new DataSet();

            ClinicDB clinicdb = new ClinicDB();
            ds = clinicdb.GetEmployeeClinicTeam(deptCode);

            return ds;
        }

        /// <summary>
        /// This is a general method that retrieves a view or a small table
        /// using the table name parameter
        /// </summary>
        /// <param name="dataTableName"></param>
        /// <returns></returns>
        public DataSet getGeneralDataTable( string dataTableName)
        {
            DataSet ds = new DataSet();

            ClinicDB clinicdb = new ClinicDB();
            clinicdb.getGeneralDataTable(ref ds, dataTableName);

            return ds;
            
        }

        public DataSet GetUnitTypeWithAttributes(int unitTypeCode)
        {
            ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.GetUnitTypeWithAttributes(unitTypeCode);

            return ds;
        }

        public DataSet getUnitTypesByName(string p_searchString, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            ClinicDB clinicdb = new ClinicDB();
            return clinicdb.getUnitTypesByName(p_searchString, agreementTypes);
        }

        public DataSet getUnitTypesByName_Extended(string p_searchString, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            ClinicDB clinicdb = new ClinicDB();
            return clinicdb.getUnitTypesByName_Extended(p_searchString, agreementTypes);
        }

        public DataSet getSubUnitTypesWithSubstituteNames()
        {
            ClinicDB clinicdb = new ClinicDB();
            return clinicdb.getSubUnitTypesWithSubstituteNames();
        }

        public void DeleteSubUnitTypeSubstituteName(int unitTypeCode, int subUnitTypeCode)
        {
            ClinicDB clinicdb = new ClinicDB();
            clinicdb.DeleteSubUnitTypeSubstituteName(unitTypeCode, subUnitTypeCode);
        }

        public void InsertSubUnitTypeSubstituteName(int unitTypeCode, int subUnitTypeCode, string substituteName, string updateUser)
        {
            ClinicDB clinicdb = new ClinicDB();
            clinicdb.InsertSubUnitTypeSubstituteName(unitTypeCode, subUnitTypeCode, substituteName, updateUser);
        }

        public DataSet GetAllServicesExtended(string serviceCode)
        {
            ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.GetAllServicesExtended( serviceCode);

            return ds;
        }

		public DataSet GetServicesNewBySector(string ServicesCodesSelected, int sectorType, bool IncludeService, bool IncludeProfession,
			bool isCommunity, bool isMushlam, bool isHospitals)
		{
			ClinicDB clinicdb = new ClinicDB();
			DataSet ds = clinicdb.GetServicesNewBySector(ServicesCodesSelected, sectorType,IncludeService, IncludeProfession, isCommunity, isMushlam, isHospitals);

			return ds;
		}

        public DataSet GetProfessionsForSalServices( string ServicesCodesSelected )
		{
			ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.GetProfessionsForSalServices(ServicesCodesSelected);

			return ds;
		}

        public DataSet GetProfessionsForSalServices_UnCategorized(int? salCategoryId, int? professionCode)
		{
			ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.GetProfessionsForSalServices_UnCategorized(salCategoryId, professionCode);

			return ds;
		}

        public DataSet GetAdminCommentsForSalServices(string title, string comment, DateTime? startDate, DateTime? expiredDate, byte? active)
		{
			ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.GetAdminCommentsForSalServices( title , comment , startDate , expiredDate , active);

			return ds;
		}
        

        public DataSet GetGroupsForSalServices(string groupsCodesSelected)
		{
			ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.GetGroupsForSalServices(groupsCodesSelected);

			return ds;
		}

        public DataSet GetPopulationsForSalServices(string populationsCodesSelected)
		{
			ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.GetPopulationsForSalServices(populationsCodesSelected);

			return ds;
		}

        public DataSet GetOmriReturnsForSalServices(string omriReturnCodesSelected)
		{
			ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.GetOmriReturnsForSalServices(omriReturnCodesSelected);

			return ds;
		}

        public DataSet GetICD9ReturnsForSalServices(string ICD9ReturnCodesSelected)
		{
			ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.GetICD9ReturnsForSalServices(ICD9ReturnCodesSelected);

			return ds;
		}

		public DataSet GetServicesNewAndEventsBySector(string ServicesCodesSelected, int sectorType,
			Dictionary<Enums.SearchMode, bool> AgreementTypes)
		{
			ClinicDB clinicdb = new ClinicDB();
			DataSet ds = clinicdb.GetServicesNewAndEventsBySector(ServicesCodesSelected, sectorType, AgreementTypes);

			return ds;
		}

        

        public void InsertSimulExceptions(int codeSimul, int seferSherut, string userName)
        {
            ClinicDB clinicdb = new ClinicDB();
            clinicdb.InsertSimulExceptions(codeSimul, seferSherut, userName);
        }

        public void UpdateDeptReceptionsTransaction(int deptCode, int receptionHoursTypeID, DataTable dtDeptReceptions)
        {
            string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();       
         
            ClinicDB clinicdb = new ClinicDB();

            // Delete DeptReceptions
            clinicdb.DeleteDeptReceptionsTansaction(deptCode, receptionHoursTypeID);
          
            for (int i = 0; i < dtDeptReceptions.Rows.Count; i++)
            {
                int receptionDay = -1;
                string openingHour = String.Empty;
                string closingHour = String.Empty;
                DateTime validFrom;
                DateTime validTo;
                int RemarkID = -1;
                string RemarkText = String.Empty;

                if (dtDeptReceptions.Rows[i]["receptionDay"].ToString() != String.Empty)
                {
                    receptionDay = int.Parse(dtDeptReceptions.Rows[i]["receptionDay"].ToString());
                }
                if (dtDeptReceptions.Rows[i]["openingHour"].ToString() != String.Empty)
                {
                    openingHour = dtDeptReceptions.Rows[i]["openingHour"].ToString();
                }
                if (dtDeptReceptions.Rows[i]["closingHour"].ToString() != String.Empty)
                {
                    closingHour = dtDeptReceptions.Rows[i]["closingHour"].ToString();
                }
                if (dtDeptReceptions.Rows[i]["validFrom"].ToString() != String.Empty)
                {
                    validFrom = Convert.ToDateTime(dtDeptReceptions.Rows[i]["validFrom"].ToString());
                }
                else
                    validFrom = Convert.ToDateTime("1/1/1900");

                if (dtDeptReceptions.Rows[i]["validTo"].ToString() != String.Empty)
                {
                    validTo = Convert.ToDateTime(dtDeptReceptions.Rows[i]["validTo"].ToString());
                }
                else
                    validTo = Convert.ToDateTime("1/1/1900");

                if (dtDeptReceptions.Rows[i]["RemarkID"].ToString() != String.Empty)
                {
                    RemarkID = int.Parse(dtDeptReceptions.Rows[i]["RemarkID"].ToString());
                }
                if (dtDeptReceptions.Rows[i]["RemarkText"].ToString() != String.Empty)
                {
                    RemarkText = dtDeptReceptions.Rows[i]["RemarkText"].ToString();
                }
                if (receptionDay > -1 && closingHour != String.Empty && openingHour != String.Empty)
                {
                    clinicdb.InsertDeptReceptions( deptCode, receptionHoursTypeID, receptionDay, openingHour, closingHour, validFrom, validTo, RemarkID, RemarkText, updateUser);
                }
            }

            clinicdb.Update_DeptReception_Regular_ThisWeek_From_DeptReception(deptCode);

            DataSet ds_EmployeeList = new DataSet(); 
            clinicdb.getEmployeesList_For_Dept(ref ds_EmployeeList, deptCode);

            DoctorDB dal = new DoctorDB();
            foreach (DataRow dr in ds_EmployeeList.Tables[0].Rows)
            {
                dal.Update_DeptEmployeeReception_Regular_ThisWeak(Convert.ToInt64(dr["employeeID"]));
            }
        }

        public void UpdateDeptReception_TemporarilyClosed(int deptCode, string receptionDays, DateTime dateFrom, DateTime dateTo, string updateUser)
        {
            //string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();

            ClinicDB clinicdb = new ClinicDB();

            // Delete DeptReceptions
            clinicdb.UpdateDeptReception_TemporarilyClosed(deptCode, receptionDays, dateFrom, dateTo, updateUser);

            //for (int i = 0; i < dtDeptReceptions.Rows.Count; i++)
            //{
            //    int receptionDay = -1;
            //    string openingHour = String.Empty;
            //    string closingHour = String.Empty;
            //    DateTime validFrom;
            //    DateTime validTo;
            //    int RemarkID = -1;
            //    string RemarkText = String.Empty;

            //    if (dtDeptReceptions.Rows[i]["receptionDay"].ToString() != String.Empty)
            //    {
            //        receptionDay = int.Parse(dtDeptReceptions.Rows[i]["receptionDay"].ToString());
            //    }
            //    if (dtDeptReceptions.Rows[i]["openingHour"].ToString() != String.Empty)
            //    {
            //        openingHour = dtDeptReceptions.Rows[i]["openingHour"].ToString();
            //    }
            //    if (dtDeptReceptions.Rows[i]["closingHour"].ToString() != String.Empty)
            //    {
            //        closingHour = dtDeptReceptions.Rows[i]["closingHour"].ToString();
            //    }
            //    if (dtDeptReceptions.Rows[i]["validFrom"].ToString() != String.Empty)
            //    {
            //        validFrom = Convert.ToDateTime(dtDeptReceptions.Rows[i]["validFrom"].ToString());
            //    }
            //    else
            //        validFrom = Convert.ToDateTime("1/1/1900");

            //    if (dtDeptReceptions.Rows[i]["validTo"].ToString() != String.Empty)
            //    {
            //        validTo = Convert.ToDateTime(dtDeptReceptions.Rows[i]["validTo"].ToString());
            //    }
            //    else
            //        validTo = Convert.ToDateTime("1/1/1900");

            //    if (dtDeptReceptions.Rows[i]["RemarkID"].ToString() != String.Empty)
            //    {
            //        RemarkID = int.Parse(dtDeptReceptions.Rows[i]["RemarkID"].ToString());
            //    }
            //    if (dtDeptReceptions.Rows[i]["RemarkText"].ToString() != String.Empty)
            //    {
            //        RemarkText = dtDeptReceptions.Rows[i]["RemarkText"].ToString();
            //    }
            //    if (receptionDay > -1 && closingHour != String.Empty && openingHour != String.Empty)
            //    {
            //        clinicdb.InsertDeptReceptions(deptCode, receptionHoursTypeID, receptionDay, openingHour, closingHour, validFrom, validTo, RemarkID, RemarkText, updateUser);
            //    }
            //}
        }

        public DataSet WeekDaysNotInDateRange(string WeekDays, DateTime dateFrom, DateTime dateTo)
        {
            DataSet dsAdministration = new DataSet();

            ClinicDB clinicdb = new ClinicDB();
            DataSet ds = clinicdb.WeekDaysNotInDateRange(WeekDays, dateFrom, dateTo);

            return ds;
        }

        #region Reception Hours for dept 

        public void GetDeptReceptions(ref DataSet p_ds, int p_deptCode, int p_ReceptionHoursType)
        {
            ClinicDB clinicdb = new ClinicDB();
            clinicdb.GetDeptReceptions(ref p_ds, p_deptCode, p_ReceptionHoursType);
        }

        #endregion

        #region Professions
        public DataSet getProfessionsByName(string p_searchString)
        {
            ClinicDB clinicdb = new ClinicDB();
            return clinicdb.getProfessionsByName(p_searchString);
        }
        #endregion

        #region Languages
        public DataSet getLanguagesByName(string p_searchString)
        {
            ClinicDB clinicdb = new ClinicDB();
            return clinicdb.getLanguagesByName(p_searchString);
        }
        #endregion

        #region phones

        public DataSet GetEmployeeServicePhones(int? x_Dept_Employee_ServiceID, int? phoneType, bool? simulateCascadeUpdate)
        {
            PhoneDB phonedb = new PhoneDB(m_ConnStr);
            return phonedb.GetEmployeeServicePhones(x_Dept_Employee_ServiceID, phoneType, simulateCascadeUpdate);
        }

        public void UpdateEmployeeServicePhones(int x_Dept_Employee_ServiceID, DataTable phonesDt, bool cascadeUpdate, string updateUser)
        {
            PhoneDB phonedb = new PhoneDB(m_ConnStr);
            Phone phone;

            phonedb.DeleteEmployeeServicePhones(x_Dept_Employee_ServiceID, null);

            phonedb.Update_x_Dept_Employee_Service_CascadeUpdatePhones(x_Dept_Employee_ServiceID, cascadeUpdate);

            if (!cascadeUpdate && phonesDt.Rows.Count > 0)
            {
                for (int i = 0; i < phonesDt.Rows.Count; i++)
                {
                    phone = new Phone(phonesDt.Rows[i]);

                    phonedb.InsertEmployeeServicePhones(x_Dept_Employee_ServiceID, phone.PhoneType, i + 1, phone.PrePrefix, phone.PreFix, phone.PhoneNumber, phone.Extension, updateUser);
                }
            }

        }

        public void DeleteEmployeeServicePhones(int? x_Dept_Employee_ServiceID, int? phoneType)
        {
            PhoneDB phonedb = new PhoneDB(m_ConnStr);
            phonedb.DeleteEmployeeServicePhones(x_Dept_Employee_ServiceID, phoneType);
        }

        #endregion

        public DataSet GetClinicByName_AdministrationDepended(string searchText, int administrationCode)
        {
            ClinicDB deptdb = new ClinicDB();
            return deptdb.GetClinicByName_AdministrationDepended(searchText, administrationCode);
        }


        /// <summary>
        /// return all the relevant unit types for given unit type codes, including the given types
        /// </summary>
        /// <param name="selectedUnitTypes">selected unit types comma delimited</param>
        /// <returns>comma delimited string contains all the given types, in addition to
        /// relevant types for search if necessary</returns>
        public string GetUnitTypesGroups(string selectedUnitTypes)
        {
            string returnTypes = selectedUnitTypes;

            //(כאשר מחפשים מרפאה ראשונית (קוד סוג 102) או מקצועית (קוד סוג 104), יוצגו גם מרפאות משולבות (קוד סוג 103
            string[] strTypeUnitCode = selectedUnitTypes.Split(',');
            for (int i = 0; i < strTypeUnitCode.Length; i++)
            {
                if (strTypeUnitCode[i] == "102" || strTypeUnitCode[i] == "104")
                {
                    returnTypes += ",103";
                }
            }

            return returnTypes;
        }

        public DataSet GetAllDeptServiceStatuses(int deptCode, int serviceCode, long employeeID)
        {
            ClinicDB dal = new ClinicDB();

            return dal.GetAllDeptServiceStatuses(deptCode, serviceCode, employeeID);
        }

        public int UpdateStatus(int deptCode, long employeeID, int serviceCode, int agreementType, DataTable statusTable, Enums.EntityTypesStatus entity)
        {
            string userName = new UserManager().GetLoggedinUserNameWithPrefix();
            StatusBO bo = new StatusBO();
            DoctorsInClinicBO docBO = new DoctorsInClinicBO();
            int currentStatus = -1;

            switch (entity)
            {
                case Enums.EntityTypesStatus.Dept:
                    currentStatus = bo.UpdateDeptStatus(deptCode, statusTable, userName);
                    break;

                case Enums.EntityTypesStatus.DeptService:
                    bo.UpdateDeptServiceStatus(deptCode, serviceCode, employeeID, statusTable, userName);
                    break;

                case Enums.EntityTypesStatus.Employee:
                    bo.UpdateEmployeeStatus(employeeID, statusTable, userName);
                    break;

                case Enums.EntityTypesStatus.EmployeeInDept:
                    bo.UpdateEmployeeStatusInDept(employeeID, deptCode, agreementType, statusTable, userName);
                    currentStatus = docBO.GetCurrentStatusForEmployeeInDept_byEpmployeeIDandDeptCode(employeeID, deptCode, agreementType);
                    break;

                case Enums.EntityTypesStatus.EmployeeServiceInDept:
                    bo.UpdateEmployeeServiceInDeptStatus(employeeID, deptCode, serviceCode, statusTable, userName);
                    currentStatus = bo.GetCurrentEmployeeServiceInDeptStatus(employeeID, deptCode, serviceCode);
                    break;

                default:
                    break;
            }

            return currentStatus;
        }

        public DataSet GetAllStatuses(int deptCode, long employeeID, int serviceCode, Enums.EntityTypesStatus entityType)
        {
            StatusBO bo = new StatusBO();
            DataSet ds = null;

            switch (entityType)
            {
                case Enums.EntityTypesStatus.Dept:
                    ds = bo.GetDeptStatus(deptCode);
                    break;

                case Enums.EntityTypesStatus.DeptService:
                    ds = bo.GetDeptServiceStatus(deptCode, serviceCode, employeeID);
                    break;

                case Enums.EntityTypesStatus.Employee:
                    ds = bo.GetEmployeeStatus(employeeID);
                    break;

                case Enums.EntityTypesStatus.EmployeeInDept:
                    ds = bo.GetEmployeeInDeptStatus(employeeID, deptCode);
                    break;

                case Enums.EntityTypesStatus.EmployeeServiceInDept:
                    ds = bo.GetEmployeeServiceInDeptStatus(employeeID, deptCode, serviceCode);
                    break;

                default:
                    break;
            }

            return ds;
        }

        #region Search Sal Services Methods

        public DataSet GetServiceCodeDescription_ForSearchSalServices(int servicecode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetServiceCodeDescription_ForSearchSalServices(servicecode);
        }

        #endregion

        public DataSet GetHealthOfficeCodeDescription_ForSearchSalServices(string healthOfficeCode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetHealthOfficeCodeDescription_ForSearchSalServices(healthOfficeCode);
        }

        public DataSet GetGroupCodeDescription_ForSearchSalServices(int groupCode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetGroupCodeDescription_ForSearchSalServices(groupCode);
        }

        public DataSet GetProfessionCodeDescription_ForSearchSalServices(int iProfessionCode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetProfessionCodeDescription_ForSearchSalServices(iProfessionCode);
        }

        public DataSet GetOmriReturnCodeDescription_ForSearchSalServices(int iOmriReturnCode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetOmriReturnCodeDescription_ForSearchSalServices(iOmriReturnCode);
        }

        public DataSet GetICD9CodeDescription_ForSearchSalServices(string ICD9Code)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetICD9CodeDescription_ForSearchSalServices(ICD9Code);
        }

        public DataSet GetSalServices(byte? includeInBasket, byte? common, byte? showServiceInInternet, byte? isActive, bool isLoggedIn, string searchText, int? serviceCode, string serviceDescription,
            string healthOfficeCode, string healthOfficeDescription, string groupsCodes, string professionsCodes, string omriReturnsCodes, string icd9Code,
            string populationCodes, int salCategoryID, int salOrganCode, DateTime? basketApproveFromDate, DateTime? basketApproveToDate, DateTime? ADD_DATE_FromDate, 
            DateTime? ADD_DATE_ToDate , bool showCanceledServices , DateTime? DEL_DATE_FromDate , DateTime? DEL_DATE_ToDate , DateTime? internetUpdated_FromDate, DateTime? internetUpdated_ToDate )
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetSalServices(includeInBasket, common, showServiceInInternet , isActive , isLoggedIn, searchText, serviceCode, serviceDescription, healthOfficeCode,
                healthOfficeDescription, groupsCodes, professionsCodes, omriReturnsCodes, icd9Code, populationCodes, salCategoryID, salOrganCode , 
                basketApproveFromDate, basketApproveToDate, ADD_DATE_FromDate, ADD_DATE_ToDate , showCanceledServices , DEL_DATE_FromDate , DEL_DATE_ToDate , 
                internetUpdated_FromDate, internetUpdated_ToDate);
        }

        public DataSet GetSalServices_Populations(byte? includeInBasket, byte? common, byte? showServiceInInternet, byte? isActive, bool isLoggedIn , string searchText, int? serviceCode, string serviceDescription,
            string healthOfficeCode, string healthOfficeDescription, string groupsCodes, string professionsCodes, string omriReturnsCodes,
            string icd9Code, string populationCodes, int salCategoryID, int salOrganCode, DateTime? basketApproveFromDate, DateTime? basketApproveToDate,
            DateTime? ADD_DATE_FromDate, DateTime? ADD_DATE_ToDate, bool showCanceledServices , DateTime? DEL_DATE_FromDate, DateTime? DEL_DATE_ToDate, DateTime? internetUpdated_FromDate, DateTime? internetUpdated_ToDate)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetSalServices_Populations(includeInBasket, common, showServiceInInternet , isActive , isLoggedIn, searchText, 
                serviceCode, serviceDescription, healthOfficeCode, healthOfficeDescription, groupsCodes, professionsCodes, omriReturnsCodes, 
                icd9Code, populationCodes , salCategoryID, salOrganCode, basketApproveFromDate, basketApproveToDate, ADD_DATE_FromDate,
                ADD_DATE_ToDate, showCanceledServices, DEL_DATE_FromDate, DEL_DATE_ToDate, internetUpdated_FromDate, internetUpdated_ToDate);
        }

        public DataSet GetSalServices_NewTests(byte? includeInBasket, byte? common, string searchText, int? serviceCode, string serviceDescription,
            string healthOfficeCode, string healthOfficeDescription, string groupsCodes, string professionsCodes, string omriReturnsCodes, 
            string icd9Code, string populationCodes, DateTime? basketApproveFromDate, DateTime? basketApproveToDate, 
            DateTime? ADD_DATE_FromDate, DateTime? ADD_DATE_ToDate, bool showCanceledServices , DateTime? DEL_DATE_FromDate, DateTime? DEL_DATE_ToDate )
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetSalServices_NewTests( includeInBasket, common, searchText, serviceCode, serviceDescription, healthOfficeCode,
                healthOfficeDescription, groupsCodes, professionsCodes, omriReturnsCodes, icd9Code, populationCodes,
                basketApproveFromDate, basketApproveToDate, ADD_DATE_FromDate, ADD_DATE_ToDate, showCanceledServices, DEL_DATE_FromDate, DEL_DATE_ToDate);
        }

        public DataSet GetSalServiceDetails(int servicecode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetSalServiceDetails(servicecode);
        }

        public DataSet GetSalServiceTarifon(int servicecode , bool isBasicPermission)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetSalServiceTarifon(servicecode, isBasicPermission);
        }

        public DataSet GetSalServiceICD9(int servicecode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetSalServiceICD9(servicecode);
        }

        public DataSet GetSalServiceTarifonHistory(int serviceCode, byte populationCode, byte subPopulationCode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetSalServiceTarifonHistory(serviceCode, populationCode, subPopulationCode);
        }

        public DataSet GetPopulationDetails(byte populationCode, byte subPopulationCode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetPopulationDetails(populationCode, subPopulationCode);
        }

        public DataSet GetSalServiceHistoryDetails(int serviceCode, DateTime updateDate)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetSalServiceHistoryDetails(serviceCode, updateDate);
        }

        public DataSet GetGroupsByName(string searchStr)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetGroupsByName(searchStr);
        }

        public DataSet GetOmriReturnsByName(string searchStr)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetOmriReturnsByName(searchStr);
        }

        public DataSet GetSalServiceInternetDetails(int servicecode)
        {
            ClinicDB deptdb = new ClinicDB();

            return deptdb.GetSalServiceInternetDetails(servicecode);   
        } 

        public DataSet GetTypeOfDefenceList()
        {
            ClinicDB deptdb = new ClinicDB();
            return deptdb.GetTypeOfDefenceList();   
        }

        public DataSet GetDefencePolicyList()
        {
            ClinicDB deptdb = new ClinicDB();
            return deptdb.GetDefencePolicyList();   
        } 
    }
}
