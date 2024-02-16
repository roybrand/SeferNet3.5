using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using SeferNet.Globals;
using System.Data.SqlTypes;


namespace SeferNet.DataLayer
{
    public class ClinicDB : Base.SqlDalEx
    {
        public void getClinicDetails(ref DataSet p_ds, int p_deptCode, string RemarkCategoriesForAbsence, string RemarkCategoriesForClinicActivity)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_deptCode, RemarkCategoriesForAbsence, RemarkCategoriesForClinicActivity };

            string spName = "rpc_DeptOverView";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void getDeptSubClinics(ref DataSet p_ds, int p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_deptCode };

            string spName = "rpc_GetDepSubClinics";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }



        public DataSet getUnitTypesExtended(string p_selectedUnitTypeCodes, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_selectedUnitTypeCodes,
				agreementTypes[Enums.SearchMode.Community], 
				agreementTypes[Enums.SearchMode.Mushlam], 
				agreementTypes[Enums.SearchMode.Hospitals] };
            string spName = "rpc_getUnitTypesExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getObjectTypesExtended(string selectedCodes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { selectedCodes };

            string spName = "rpc_getObjectTypesExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getEventsExtended(string selectedCodes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { selectedCodes };

            string spName = "rpc_getEventsExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getUnitTypesByName(string p_searchString, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_searchString,
				agreementTypes[Enums.SearchMode.Community], 
				agreementTypes[Enums.SearchMode.Mushlam], 
				agreementTypes[Enums.SearchMode.Hospitals] };
            string spName = "rpc_getUnitTypesByName";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getUnitTypesByName_Extended(string p_searchString, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_searchString,
				agreementTypes[Enums.SearchMode.Community], 
				agreementTypes[Enums.SearchMode.Mushlam], 
				agreementTypes[Enums.SearchMode.Hospitals] };
            string spName = "rpc_getUnitTypesByName_Extended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getSubUnitTypesWithSubstituteNames()
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { new object() };

            string spName = "rpc_getSubUnitTypesWithSubstituteNames";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void DeleteSubUnitTypeSubstituteName(int unitTypeCode, int subUnitTypeCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { unitTypeCode, subUnitTypeCode };


            string spName = "rpc_DeleteSubUnitTypeSubstituteName";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void InsertSubUnitTypeSubstituteName(int unitTypeCode, int subUnitTypeCode, string substituteName, string updateUser)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { unitTypeCode, subUnitTypeCode, substituteName, updateUser };


            string spName = "rpc_InsertSubUnitTypeSubstituteName";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetUnitTypeWithAttributes(int unitTypeCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { unitTypeCode };

            string spName = "rpc_getUnitTypeWithAttributes";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getDistrictsExtended(string p_selectedDistricts, string unitTypeCodes, string permittedDistricts)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_selectedDistricts, unitTypeCodes, permittedDistricts };

            string spName = "rpc_getDistrictsExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getAdminsExtended(string p_selectedAdmins, string p_districts)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_selectedAdmins, p_districts };

            string spName = "rpc_getAdminsExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetClinicsExtended(string p_selectedClinics, string p_selectedAdmins, string p_districts, string p_unitTypeListCodes, string p_subUnitTypeCode, string p_populationSector)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_selectedClinics, p_selectedAdmins, p_districts, p_unitTypeListCodes, p_subUnitTypeCode, p_populationSector };

            string spName = "rpc_getClinicsExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getClinicByName(string deptSearchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptSearchStr };

            string spName = "rpc_FindClinicByName";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getDistrictsByName(string deptSearchStr, string unitTypeCodes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptSearchStr, unitTypeCodes };

            string spName = "rpc_findDistrictsByName";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getDistrictsByUnitType(string unitTypeCodes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { unitTypeCodes };

            string spName = "rpc_getDistrictsByUnitType";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getClinicByName_DistrictDepended(string deptSearchStr, string districtCodes,
            int clinicStatus, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };

            object[] inputParams = new object[] { deptSearchStr, districtCodes, clinicStatus,
				agreementTypes[Enums.SearchMode.Community], 
				agreementTypes[Enums.SearchMode.Mushlam], 
				agreementTypes[Enums.SearchMode.Hospitals] };

            string spName = "rpc_getClinicByName_DistrictDepended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);


            return ds;
        }

        public DataSet getClinicByName_District_City_ClinicType_Status_Depended(string deptSearchStr, string districtCodes,
            int clinicStatus, int cityCode, string clinicType, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };


            object[] inputParams = new object[] { deptSearchStr, districtCodes, clinicStatus, cityCode, clinicType,
				agreementTypes[Enums.SearchMode.Community], 
				agreementTypes[Enums.SearchMode.Mushlam], 
				agreementTypes[Enums.SearchMode.Hospitals] };

            string spName = "rpc_getClinicByName_District_City_ClinicType_Status_Depended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);


            return ds;
        }

        public DataSet getClinicByName_DistrictDepended_DeptCodeLeading(string deptSearchStr, string districtCodes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptSearchStr, districtCodes };

            string spName = "rpc_getClinicByNameWithDeptCode_DistrictDepended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetHealthOfficeDesc(string healthOfficeSearchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { healthOfficeSearchStr };

            string spName = "rpc_GetHealthOfficeDesc";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetICD9Desc(string icd9SearchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { icd9SearchStr };

            string spName = "rpc_GetICD9DescForSalServices";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetServiceCodesForSalServices(string serviceCodesSearchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCodesSearchStr };

            string spName = "rpc_getServiceCodesForSalServices";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetMedicalAspectsForAutocomplete(string searchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchStr };

            string spName = "rpc_GetMedicalAspectsForAutocomplete";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetClalitServiceDescription_ByClalitServiceCode(int clalitServiceCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { clalitServiceCode };

            string spName = "rpc_GetClalitServiceDescription_ByClalitServiceCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetMedicalAspectDescription_ByMedicalAspectCode(string medicalAspectCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { medicalAspectCode };

            string spName = "rpc_GetMedicalAspectDescription_ByMedicalAspectCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetClalitServicesForAutocomplete(string searchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchStr };

            string spName = "rpc_GetClalitServicesForAutocomplete";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getAdminByName_DistrictDepended(string deptSearchStr, string districtCodes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptSearchStr, districtCodes };

            string spName = "rpc_getAdminByName_DistrictDepended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet getLanguagesByName(string searchString)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchString };

            string spName = "rpc_getLanguagesByName";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetServicesAndEventsByName(string searchStr, Dictionary<Enums.SearchMode, bool> AgreementTypes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchStr,
				AgreementTypes[Enums.SearchMode.Community], 
				AgreementTypes[Enums.SearchMode.Mushlam], 
				AgreementTypes[Enums.SearchMode.Hospitals] };

            string spName = "rpc_getServicesAndEventsByName";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEventsByName(string searchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchStr };

            string spName = "rpc_getEventsByName";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetServicesByName(string searchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchStr };

            string spName = "rpc_getServicesByName";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetServicesByNameAndSector(string searchStr, int sectorCode, Dictionary<Enums.SearchMode, bool> AgreementTypes)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchStr, sectorCode,
				AgreementTypes[Enums.SearchMode.Community], 
				AgreementTypes[Enums.SearchMode.Mushlam], 
				AgreementTypes[Enums.SearchMode.Hospitals]};

            string spName = "rpc_getServicesByNameAndSector";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetHandicappedFacilitiesByName(string searchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchStr };

            string spName = "rpc_getHandicappedFacilitiesByName";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public int getDeptDistrict(int deptCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };

            string spName = "rpc_getDeptDistrict";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);
            if (ds.Tables[0].Rows.Count > 0)
                return Convert.ToInt32(ds.Tables[0].Rows[0].ItemArray[0]);
            else
                return 0;

        }

        public void getGeneralDataTable(ref DataSet p_ds, Enums.CachedTables dataTableName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { (byte)dataTableName };

            string spName = "rpc_GetGeneralTable";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        /// <summary>
        ///  This is a general method that retrieves a view or a small table
        /// using the table name parameter
        /// </summary>
        /// <param name="p_ds"></param>
        /// <param name="dataTableName"></param>
        public void getGeneralDataTable(ref DataSet p_ds, string dataTableName)
        {
            p_ds = FillDataSet("select * from " + dataTableName);
        }

        public void getClinicReceptionAndRemarks(ref DataSet p_ds, int p_deptCode, DateTime expirationDate, string serviceCodes, string remarkCategoriesForAbsence, string RemarkCategoriesForClinicActivity)
        {
            if (expirationDate == DateTime.MinValue)
                expirationDate = DateTime.Now;

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[5] { p_deptCode, expirationDate, serviceCodes, remarkCategoriesForAbsence, RemarkCategoriesForClinicActivity };

            string spName = "rpc_GetDeptReceptionAndRemarks";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }

        public void getClinicServices(ref DataSet p_ds, int p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_deptCode };

            string spName = "rpc_GetDeptServices";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }

        public DataSet getClinicList_PagedSorted(bool UserIsLogged, string districtCodes, int? cityCode,
            string typeUnitCode, string subUnitTypeCode, string serviceCodes,
            string deptName, int? deptCode, string receptionDays,
            string openAtHour, string openFromHour, string openToHour, bool openNow,
            bool? isCommunity, bool? isMushlam, bool? isHospitals,
            int? status, int? populationSectorCode, string deptHandicappedFacilities, bool? ReceiveGuests,
            int? pageSize, int? startingPage, string sortedBy, int isOrderDescending,
            double? coordinateX, double? coordinateY, int? maxNumberOfRecords,
            string clalitServiceCode, string clalitServiceDescription, string medicalAspectCode, string medicalAspectDescription,
            string serviceCodeForMuslam, int? groupCode, int? subGroupCode, string QueueOrderMethodsAndOptionsCodes)
        {
            DataSet ds;

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { UserIsLogged, districtCodes, cityCode, typeUnitCode, subUnitTypeCode,
                serviceCodes, deptName, deptCode, receptionDays, openAtHour,
                openFromHour, openToHour, openNow, isCommunity, isMushlam, isHospitals,
                status, populationSectorCode, deptHandicappedFacilities, ReceiveGuests, pageSize, startingPage, sortedBy, isOrderDescending,
                coordinateX, coordinateY, maxNumberOfRecords, clalitServiceCode, clalitServiceDescription, medicalAspectCode, medicalAspectDescription,
                serviceCodeForMuslam, groupCode, subGroupCode, QueueOrderMethodsAndOptionsCodes};

            string spName = "rpc_getDeptList_PagedSorted";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }
        public DataSet getClinicList_PagedSorted(string CodesListForPage_1, string CodesListForPage_2, string CodesListForPage_3,
            string serviceCodes,
            string receptionDays, string openAtHour, string openFromHour, string openToHour, bool openNow,
            bool? isCommunity, bool? isMushlam, bool? isHospitals,
            bool? ReceiveGuests, double? coordinateX, double? coordinateY,
            string clalitServiceCode, string serviceCodeForMuslam)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };

            object[] inputParams = new object[] { CodesListForPage_1, CodesListForPage_2, CodesListForPage_3,
                serviceCodes, receptionDays, openAtHour,
                openFromHour, openToHour, openNow, isCommunity, isMushlam, isHospitals,
                ReceiveGuests, coordinateX, coordinateY, clalitServiceCode, serviceCodeForMuslam };

            string spName = "rpc_getDeptList_OnePage";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);


            return ds;
        }

        public DataSet getClinicList_ForPrinting(string serviceCodes, string receptionDays,
            string openAtHour, string openFromHour, string openToHour, bool openNow,
            bool? isCommunity, bool? isMushlam, bool? isHospitals, int? status, 
            bool? ReceiveGuests, string serviceCodeForMuslam, int? groupCode, int? subGroupCode, string foundDeptCodeList)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] {serviceCodes, receptionDays, openAtHour,
                openFromHour, openToHour, openNow, isCommunity, isMushlam, isHospitals, status, 
                ReceiveGuests, serviceCodeForMuslam, groupCode, subGroupCode, foundDeptCodeList};

            string spName = "rpc_getClinicList_ForPrinting";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;

        }

        public DataSet GetDeptRandomOrder()
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { new object() };

            string spName = "rpc_GetDeptRandomOrder";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }
        public DataSet getZoomClinic_ForPrinting(int deptCode, bool isInternal, string deptCodesInArea)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] {deptCode, isInternal, deptCodesInArea};

            string spName = "rpc_GetZoomClinicTemplate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;

        }

        public DataSet getNewClinicsList(int? DeptCode, string DeptName, DateTime? OpenDateSimul, int? ExistsInSefer)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[4] { DeptCode,  DeptName, OpenDateSimul, ExistsInSefer};

            string spName = "rpc_getNewClinicsList";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;

        }

        public int InsertNewClinicsList()
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[0] { };

            string spName = "rpc_InsertNewClinicsList";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            return ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public int InsertUnitTypeConvertSimul()
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[0] { };

            string spName = "rpc_InsertUnitTypeConvertSimul";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            return ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetErrorsListSimulVcSefer(int errorCode)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { errorCode };


            string spName = "rpc_getErrorsListSimulVcSefer";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;

        }

        public DataSet GetNewClinic(int deptCode)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { deptCode };

            string spName = "rpc_getNewClinic";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void DeleteSimulNewDepts(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { deptCode };


            string spName = "rpc_deleteSimulNewDepts";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void GetDeptDetailsForUpdate(ref DataSet ds_ClinicDetails, int p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_deptCode };

            string spName = "rpc_getDeptDetailsForUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds_ClinicDetails = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void GetDeptNamesForUpdate(ref DataSet ds_ClinicDetails, int p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_deptCode };

            string spName = "rpc_getDeptNamesForUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds_ClinicDetails = FillDataSet(spName, ref outputParams, inputParams);
        }
        public string GetDefaultDeptNameForIndependentClinic(int p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_deptCode };

            string spName = "rpc_GetDefaultDeptNameForIndependentClinic";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            DataSet ds = FillDataSet(spName, ref outputParams, inputParams);
            return ds.Tables[0].Rows[0][0].ToString();
        }

        public void GetDeptDetailsForPopUp(ref DataSet ds_ClinicDetails, int p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_deptCode };

            string spName = "rpc_getDeptDetailsForPopUp";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds_ClinicDetails = FillDataSet(spName, ref outputParams, inputParams);
        }


        public void getAdministrationList(ref DataSet ds_AdministrationList, int p_districtCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_districtCode };

            string spName = "rpc_getAdministrationList";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds_AdministrationList = FillDataSet(spName, ref outputParams, inputParams);

        }

        public int UpdateDept(object[] inputParams)
        {
            int ErrorStatus = 0;
            object[] outputParams = new object[1] { ErrorStatus };

            ExecuteNonQuery("rpc_updateDept", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return Convert.ToInt32(outputParams[0]);
        }

        public int UpdateDeptLevelAndShowInInternet(int deptCode, int deptLevel, int? displayPriority, string updateUser)
        {
            object[] inputParams = new object[] { deptCode, deptLevel, displayPriority, updateUser };
            object[] outputParams = new object[1] { new object() };

            return ExecuteNonQuery("rpc_UpdateDeptLevelAndShowInInternet", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }


        public int InsertDept(int deptCode, string updateUser)
        {
            int ErrorStatus = 0;
            int count = 0;
            object[] inputParams = new object[] { deptCode, updateUser };
            object[] outputParams = new object[1] { ErrorStatus };

            count = ExecuteNonQuery("rpc_insertDept", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return count;
        }

        public int InsertDeptSimul(int deptCode)
        {
            int ErrorStatus = 0;
            int count = 0;
            object[] inputParams = new object[] { deptCode };
            object[] outputParams = new object[1] { ErrorStatus };

            count = ExecuteNonQuery("rpc_insertDeptSimul", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return count;
        }

        public int UpdateDeptGeneralBelongings(int deptCode, bool? isCommunity, bool? isMushlam, bool? isHospital)
        {
            int ErrorStatus = 0;
            int count = 0;
            object[] inputParams = new object[] { deptCode, isCommunity, isMushlam, isHospital };
            object[] outputParams = new object[1] { ErrorStatus };

            count = ExecuteNonQuery("rpc_UpdateDeptGeneralBelongings", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return count;
        }

        public int InsertX_dept_XY(int deptCode, double xcoord, double ycoord, double XLongitude, double YLatitude, bool updateCoordinatesManually, string locationLink)
        {
            int ErrorStatus = 0;
            object[] inputParams = new object[] { deptCode, xcoord, ycoord, XLongitude, YLatitude, updateCoordinatesManually, locationLink};
            object[] outputParams = new object[1] { ErrorStatus };

            ExecuteNonQuery("rpc_InsertX_dept_XY", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return Convert.ToInt32(outputParams[0]);
        }

        public int DeleteX_dept_XY(int deptCode)
        {
            int ErrorStatus = 0;
            object[] inputParams = new object[] { deptCode };
            object[] outputParams = new object[1] { ErrorStatus };

            ExecuteNonQuery("rpc_DeleteX_dept_XY", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return Convert.ToInt32(outputParams[0]);
        }



        public DataSet getDeptProfessions(int p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_deptCode };

            string spName = "rpc_getDeptProfessions";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            DataSet ds_deptProfessions = FillDataSet(spName, ref outputParams, inputParams);
            return ds_deptProfessions;
        }

        public DataSet getProfessionsByName(string p_searchString)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_searchString };

            string spName = "rpc_getProfessionsByName";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }



        public void DeleteDeptReceptionsTansaction(int deptCode, int receptionHoursTypeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { deptCode, receptionHoursTypeID };

            string spName = "rpc_DeleteDeptReceptions";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public int UpdateDeptReception_TemporarilyClosed(int deptCode, string receptionDays, DateTime dateFrom, DateTime dateTo, string updateUser)
        {
            int ErrorStatus = 0;

            string dateFrom_string = dateFrom.ToString("yyyy-MM-dd");
            string dateTo_string = dateTo.ToString("yyyy-MM-dd");

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, receptionDays, dateFrom_string, dateTo_string, updateUser };

            string spName = "rpc_UpdateDeptReception_TemporarilyClosed";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            //return Convert.ToInt32(outputParams[0]);
            return ErrorStatus;
        }

        public DataSet WeekDaysNotInDateRange(string WeekDays, DateTime dateFrom, DateTime dateTo)
        {
            DataSet ds;

            string dateFrom_string = dateFrom.ToString("yyyy-MM-dd");
            string dateTo_string = dateTo.ToString("yyyy-MM-dd");

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[3] { WeekDays, dateFrom_string, dateTo_string };

            string spName = "rpc_WeekDaysNotInDateRange";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }


        public int Update_DeptReception_Regular_ThisWeek_From_DeptReception(int deptCode)
        {
            int ErrorStatus = 0;

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, -1, -1 };

            string spName = "rpc_Update_DeptReception_Regular_ThisWeek_From_DeptReception";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            //return Convert.ToInt32(outputParams[0]);
            return ErrorStatus;
        }

        public void getEmployeesList_For_Dept(ref DataSet ds_EmployeeList, int p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_deptCode };

            string spName = "rpc_getEmployeesList_For_Dept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds_EmployeeList = FillDataSet(spName, ref outputParams, inputParams);
        }

        public int DeleteDeptProfession(int DeptCode, int ProfessionCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[2] { DeptCode, ProfessionCode };

            string spName = "rpc_DeleteDeptProfession";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            return ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }



        public int InsertDeptReceptions(int deptCode, int receptionHoursTypeID, int receptionDay, string openingHour, string closingHour,
            DateTime validFrom, DateTime validTo, int RemarkID, string RemarkText, string updateUser)
        {
            object[] outputParams = new object[1] { new object() };

            object[] inputParams = new object[] { deptCode,  receptionDay,  openingHour,  closingHour,validFrom , 
                                                    validTo , RemarkID , RemarkText ,  updateUser, receptionHoursTypeID};
            if (inputParams[4].ToString() == "01/01/1900 00:00:00")
            {
                inputParams[4] = DBNull.Value;
            }
            if (inputParams[5].ToString() == "01/01/1900 00:00:00")
            {
                inputParams[5] = DBNull.Value;
            }

            string spName = "rpc_insertDeptReceptions";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            return ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }



        public void InsertDeptProfession(int DeptCode, string ProfessionCodes, string userName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[3] { DeptCode, ProfessionCodes, userName };

            string spName = "rpc_insertDeptProfessions";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }



        public DataSet GetEmployeeInDeptDetails(int deptEmployeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEmployeeID };

            string spName = "rpc_getEmployeeInClinicDetails";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }



        public void UpdateDeptProfessionHours(int receptionID, int receptionTypeCode, int receptionDay,
        string openingHour, string closingHour,
        DateTime validFrom, DateTime validTo, string updateUserName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[8] { receptionID, receptionTypeCode, receptionDay,
                            openingHour, closingHour, validFrom, validTo,updateUserName};

            string spName = "rpc_updateDeptProfessionHours";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }


        public void insertDeptProfessionHours(int deptCode, int professionCode, int receptionTypeCode, int receptionDay,
        string openingHour, string closingHour,
        DateTime validFrom, DateTime validTo, string updateUserName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, professionCode, receptionTypeCode, receptionDay,
                            openingHour, closingHour, validFrom, validTo, updateUserName};

            string spName = "rpc_insertDeptProfessionHours";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }


        #region Handicapped Facilities

        public DataSet GetHandicappedFacilitiesExtended(string selectedFacilities)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { selectedFacilities };

            string spName = "rpc_getHandicappedFacilitiesExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetHandicappedFacilitiesInDept(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };

            string spName = "rpc_getHandicappedFacilitiesInDept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetHandicappedFacilitiesForDept(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };

            string spName = "rpc_getHandicappedFacilitiesForDept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public void DeleteDeptHandicappedFacilities(int deptCode, int facilityCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, facilityCode };

            string spName = "rpc_deleteDeptHandicappedFacilities";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void InsertDeptHandicappedFacilities(int deptCode, string handicappedFacilities)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, handicappedFacilities };

            string spName = "rpc_insertDeptHandicappedFacilities";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public int UpdateDeptHandicappedFacilities(int deptCode, string handicappedFacilities)
        {
            int ErrorStatus = 0;
            object[] outputParams = new object[1] { ErrorStatus };
            object[] inputParams = new object[] { deptCode, handicappedFacilities };

            ExecuteNonQuery("rpc_updateDeptHandicappedFacilities", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return Convert.ToInt32(outputParams[0]);
        }

        #endregion

        #region Dept Status

        public DataSet GetDeptStatus(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };

            string spName = "rpc_getDeptStatus";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetDeptStatusByID(int statusID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { statusID };

            string spName = "rpc_getDeptStatusByID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public int DeleteDeptStatuses(int deptCode)
        {
            int ErrorStatus = 0;

            object[] outputParams = new object[1] { ErrorStatus };
            object[] inputParams = new object[] { deptCode };


            ExecuteNonQuery("rpc_deleteDeptStatuses", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return Convert.ToInt32(outputParams[0]);
        }

        public int InsertDeptStatus(int deptCode, int status, DateTime fromDate, DateTime toDate, string updateUser)
        {
            int ErrorCode = 0;
            string Message = string.Empty;
            object[] outputParams = new object[] { ErrorCode, Message };
            object[] inputParams = new object[] { deptCode, status, fromDate, toDate, updateUser };

            string spName = "rpc_insertDeptStatus";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);

            return ErrorCode;
        }

        public int UpdateDeptStatus(int deptCode, string updateUser)
        {
            int currentStatus = 0;
            object[] outputParams = new object[] { currentStatus };
            object[] inputParams = new object[] { deptCode, updateUser };

            ExecuteNonQuery("rpc_UpdateDeptStatus", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return Convert.ToInt32(outputParams[0]);
        }

        public int InsertDeptStatus(int deptCode, int status, DateTime fromDate, DateTime? toDate, string updateUser)
        {
            int count = 0, ErrorCode = 0;

            string Message = string.Empty;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptCode, status, fromDate, toDate, updateUser };

            if (fromDate == DateTime.MinValue)
                inputParams[2] = null;

            if (toDate != null)
                inputParams[3] = (SqlDateTime)toDate;

            count = ExecuteNonQuery("rpc_insertDeptStatusWithoutDependency", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return count;
        }

        public int InsertDeptStatusForNewDept(int deptCode, string updateUser)
        {
            int ErrorCode = 0;
            int count = 0;

            string Message = string.Empty;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptCode, updateUser };

            count = ExecuteNonQuery("rpc_insertDeptStatusForNewDept", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);

            return count;
        }

        public int InsertDeptStatusForNewDept(IDbTransaction trans, int deptCode, int status, DateTime fromDate, DateTime toDate, string updateUser)
        {
            int ErrorCode = 0;
            int count = 0;

            string Message = string.Empty;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptCode, status, fromDate, toDate, updateUser };
            if (fromDate == DateTime.MinValue)
                inputParams[2] = null;
            if (toDate == DateTime.MinValue)
                inputParams[3] = null;


            count = ExecuteNonQuery(trans, "rpc_insertDeptStatusWithoutDependency", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);

            return count;

        }






        #endregion

        #region Employee in Dept


        public int updateDoctorsInClinic(int deptCode, long employeeID, int agreementType_Old, int agreementType_New, bool receiveGuests,
            string updateUser, bool showPhonesFromDept)
        {
            int ErrorStatus = 0;
            object[] outputParams = new object[1] { ErrorStatus };
            object[] inputParams = new object[] { deptCode, employeeID, agreementType_Old, agreementType_New, receiveGuests, updateUser, showPhonesFromDept };

            string spName = "rpc_updateDoctorsInClinic";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return Convert.ToInt32(outputParams[0]);
        }

        public int InsertDoctorInClinic(int DeptCode, long employeeID,
            int agreementType, string updateUser, bool active)
        {
            int insertedRecords = 0;
            int ErrorStatus = 0;
            int DeptEmployeeID = 0;

            object[] outputParams = new object[2] { ErrorStatus, DeptEmployeeID };
            object[] inputParams = new object[] { DeptCode, employeeID, agreementType, updateUser, active };


            string spName = "rpc_InsertDoctorInClinic";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            insertedRecords = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorStatus = Convert.ToInt32(outputParams[0]);
            DeptEmployeeID = Convert.ToInt32(outputParams[1]);

            return DeptEmployeeID;
        }

        public DataSet GetClinicTeamAgreementsInDept(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };

            string spName = "rpc_GetClinicTeamAgreementsInDept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetDeptEmployeeID(int deptCode, long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, employeeID };

            string spName = "rpc_GetDeptEmployeeID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public void DeleteDoctorInClinic(int deptEmployeeID, int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEmployeeID, deptCode };


            string spName = "rpc_deleteDoctorInClinic";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        #endregion

        #region Employee Profession in Dept

        public DataSet GetEmployeeProfessionsInDept(int deptEmployeeID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { deptEmployeeID };
            DataSet ds;

            string spName = "rpc_getEmployeeProfessionsInDept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void DeleteAllEmployeeProfessionsInDept(int employeeID, int deptCode)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeID, deptCode };


            string spName = "rpc_deleteEmployeeProfessionsInDept";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }


        public void DeleteDeptEmployeeProfession(int employeeID, int deptCode, int professionCode)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeID, deptCode, professionCode };


            string spName = "rpc_deleteDeptEmployeeProfession";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        #endregion

        #region Employee Services in Dept

        public DataSet GetEmployeeServicesForDept(int employeeID, int deptCode)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeID, deptCode };
            DataSet ds;

            string spName = "rpc_getEmployeeServicesForDept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeServicesInDept(int deptEmployeeID)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[1] { ErrorCode };
            object[] inputParams = new object[] { deptEmployeeID };
            DataSet ds;

            string spName = "rpc_getEmployeeServicesInDept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void InsertDeptEmployeeService(int deptEmployeeID, string serviceCodes, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[1] { ErrorCode };
            object[] inputParams = new object[] { 
                deptEmployeeID, serviceCodes, updateUser};

            string spName = "rpc_insertDeptEmployeeService";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
        }

        public void DeleteDeptEmployeeService(int deptEmployeeID, int serviceCode)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { deptEmployeeID, serviceCode };


            string spName = "rpc_deleteDeptEmployeeService";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetEmployeeServicesExtended(int employeeID, int deptCode, int deptEmployeeID, bool IsLinkedToEmployeeOnly, bool? isService)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, deptEmployeeID, IsLinkedToEmployeeOnly, isService };
            DataSet ds;

            string spName = "rpc_getEmployeeServicesExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetMedicalAspects(int? deptCode, bool isLinkedToDept, bool? isService)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, isLinkedToDept, isService };
            DataSet ds;

            string spName = "rpc_GetMedicalAspects";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetServicesForMedicalAspects(int deptCode, string services)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, services };
            DataSet ds;

            string spName = "rpc_GetServicesForMedicalAspects";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        #endregion

        #region Employee Positions in Dept


        public DataSet GetEmployeePositionsForPopup(int deptEmployeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { deptEmployeeID };
            DataSet ds;

            string spName = "rpc_getEmployeePositionsExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeClinicTeam(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };
            DataSet ds;

            string spName = "rpc_GetEmployeeClinicTeam";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void InsertEmployeePositionsInDept(int employeeID, int deptCode, string positionCodes, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[1] { ErrorCode };
            object[] inputParams = new object[] { employeeID, deptCode, positionCodes, updateUser };

            string spName = "rpc_insertEmployeePositionsInDept";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
        }

        public void InsertSimulExceptions(int codeSimul, int seferSherut, string userUpdate)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[1] { ErrorCode };
            object[] inputParams = new object[] { codeSimul, seferSherut, userUpdate };

            string spName = "rpc_insertSimulExceptions";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteAllEmployeePositionInDept(int employeeID, int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, null };

            string spName = "rpc_deleteEmployeePositionInDept";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteEmployeePositionInDept(int employeeID, int deptCode, int positionCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, positionCode };


            string spName = "rpc_deleteEmployeePositionInDept";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        #endregion



        #region DeptReceptionRemarks

        public DataSet GetDeptReceptionRemarks(int receptionID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { receptionID };
            DataSet ds;

            string spName = "rpc_getDeptReceptionRemarks";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void DeleteDeptReceptionRemark(int deptReceptionRemarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptReceptionRemarkID };

            string spName = "rpc_deleteDeptReceptionRemark";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public DataSet GetDeptReceptionRemarkForUpdate(int deptReceptionRemarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptReceptionRemarkID };
            DataSet ds;

            string spName = "rpc_getDeptReceptionRemarkForUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void InsertDeptReceptionRemark(int receptionID, string remarkText,
            DateTime validFrom, DateTime validTo, int DisplayInInternet, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[1] { ErrorCode };
            object[] inputParams = new object[] { 
                receptionID,	
                remarkText,
                validFrom,
                validTo,
                DisplayInInternet,
                updateUser};

            string spName = "rpc_insertDeptReceptionRemark";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
        }

        public void UpdateDeptReceptionRemark(int deptReceptionRemarkID, string remarkText,
            DateTime validFrom, DateTime validTo, int DisplayInInternet, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[1] { ErrorCode };
            object[] inputParams = new object[] { 
                deptReceptionRemarkID,
                remarkText,
                validFrom,
                validTo,
                DisplayInInternet,
                updateUser};

            string spName = "rpc_updateDeptReceptionRemark";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
        }

        #endregion

        #region DeptEvent


        public DataSet GetDeptEvents(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };
            DataSet ds;

            string spName = "rpc_getDeptEvents";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetDeptEventForPopUp(int deptEventID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEventID };
            DataSet ds;

            string spName = "rpc_getDeptEventForPopUp";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetDeptEventByID(int DeptEventID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { DeptEventID };
            DataSet ds;

            string spName = "rpc_getDeptEventByID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetDeptEventForUpdate(int DeptEventID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { DeptEventID };
            DataSet ds;

            string spName = "rpc_getDeptEventForUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void DeleteDeptEvent(int DeptEventID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { DeptEventID };

            string spName = "rpc_deleteDeptEvent";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public int InsertDeptEvent(int deptCode, int eventCode, string EventDescription,
                int MeetingsNumber, int RepeatingEvent, DateTime FromDate, DateTime ToDate,
                int RegistrationStatus, int PayOrder, float CommonPrice, float MemberPrice, float FullMemberPrice,
                string TargetPopulation, string Remark, int DisplayInInternet, string UpdateUser, bool cascadePhonesFromDept)
        {
            int DeptEventIDInserted = 0;
            object[] outputParams = new object[] { DeptEventIDInserted };
            object[] inputParams = new object[] {deptCode, eventCode, EventDescription,
                MeetingsNumber, RepeatingEvent, FromDate, ToDate, 
                RegistrationStatus, PayOrder, CommonPrice, MemberPrice, FullMemberPrice,
                TargetPopulation, Remark, DisplayInInternet, UpdateUser, cascadePhonesFromDept};

            string spName = "rpc_insertDeptEvent";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            DeptEventIDInserted = Convert.ToInt32(outputParams[0]);

            return DeptEventIDInserted;
        }


        public int InsertDeptEvent(object[] inputParams)
        {
            int DeptEventIDInserted = 0;
            object[] outputParams = new object[] { DeptEventIDInserted };


            ExecuteNonQuery("rpc_insertDeptEvent", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            DeptEventIDInserted = Convert.ToInt32(outputParams[0]);

            return DeptEventIDInserted;
        }


        public void UpdateDeptEvent(int DeptEventID, int eventCode, string EventDescription,
            int MeetingsNumber, int RepeatingEvent, DateTime FromDate, DateTime ToDate,
            int RegistrationStatus, int PayOrder, float CommonPrice, float MemberPrice, float FullMemberPrice,
            string TargetPopulation, string Remark, int displayInInternet, string UpdateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { 
                DeptEventID, eventCode, EventDescription, MeetingsNumber, RepeatingEvent, FromDate, ToDate,
		        RegistrationStatus, PayOrder, CommonPrice, MemberPrice, FullMemberPrice,
		        TargetPopulation, Remark, displayInInternet, UpdateUser};

            string spName = "rpc_updateDeptEvent";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
        }


        public void UpdateDeptEvent(object[] inputParams)
        {

            object[] outputParams = new object[] { new object() };
            ExecuteNonQuery("rpc_updateDeptEvent", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public DataSet GetDeptEventParticulars(int deptEventID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEventID };
            DataSet ds;

            string spName = "rpc_getDeptEventParticulars";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }


        public DataSet GetDeptEventParticularByID(int deptEventParticularsID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEventParticularsID };
            DataSet ds;

            string spName = "rpc_getDeptEventParticularByID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void DeleteDeptEventParticulars(int deptEventID)
        {
            object[] inputParams = new object[] { deptEventID };

            string spName = "rpc_deleteDeptEventParticulars";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, inputParams);
        }

        public int InsertDeptEventParticular(int deptEventID, DateTime date, string openingHour,
            string closingHour, string updateUser)
        {
            int count = 0;

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { deptEventID, date, openingHour, closingHour, updateUser };

            string spName = "rpc_insertDeptEventParticular";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            count = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return count;

        }

        public void UpdateDeptEventParticular(int deptEventParticularsID, DateTime date,
            string openingHour, string duration, string updateUser, int repeatingEvent, int deptEventID)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { deptEventParticularsID, date, openingHour, duration, updateUser, repeatingEvent, deptEventID };

            string spName = "rpc_updateDeptEventParticular";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);

        }

        #endregion

        #region Services

        public DataSet GetServicesNewBySector(string professionCodesSelected, int sectorType, bool IncludeService, bool IncludeProfession,
            bool isCommunity, bool isMushlam, bool isHospitals)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[7] {  professionCodesSelected, sectorType, IncludeService, IncludeProfession, 
				isCommunity, 
				isMushlam, 
				isHospitals};
            DataSet ds;

            string spName = "rpc_GetServicesNewBySector";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetProfessionsForSalServices(string professionCodesSelected)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { professionCodesSelected };
            DataSet ds;

            string spName = "rpc_GetProfessionsForSalServices";

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetProfessionsForSalServices_UnCategorized(int? salCategoryId, int? professionCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[2] { salCategoryId, professionCode }; ;
            DataSet ds;

            string spName = "GetProfessionsForSalServices_UnCategorized";

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetAdminCommentsForSalServices(string title, string comment, DateTime? startDate, DateTime? expiredDate, byte? active)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { title  , comment , startDate , expiredDate , active};
            DataSet ds;

            string spName = "rpc_getAdminComments";

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetGroupsForSalServices(string groupsCodesSelected)
        {
            //object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { groupsCodesSelected };
            DataSet ds;

            string spName = "rpc_GetGroupsForSalServices";

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            int status = 0;
            ds = FillDataSet(spName, ref status, inputParams);

            return ds;
        }

        public DataSet GetPopulationsForSalServices(string populationsCodesSelected)
        {
            object[] inputParams = new object[1] { populationsCodesSelected };
            DataSet ds;

            string spName = "rpc_GetPopulationsForSalServices";

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            int status = 0;
            ds = FillDataSet(spName, ref status, inputParams);

            return ds;
        }

        public DataSet GetOmriReturnsForSalServices(string populationsCodesSelected)
        {
            object[] inputParams = new object[1] { populationsCodesSelected };
            DataSet ds;

            string spName = "rpc_GetOmriReturnsForSalServices";

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            int status = 0;
            ds = FillDataSet(spName, ref status, inputParams);

            return ds;
        }
        public DataSet GetICD9ReturnsForSalServices(string ICD9ReturnCodesSelected)
        {
            object[] inputParams = new object[1] { ICD9ReturnCodesSelected };
            DataSet ds;

            string spName = "rpc_GetICD9ReturnsForSalService";

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            int status = 0;
            ds = FillDataSet(spName, ref status, inputParams);

            return ds;
        }

        public DataSet GetServicesNewAndEventsBySector(string professionCodesSelected, int sectorType,
            Dictionary<Enums.SearchMode, bool> AgreementTypes)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[5] {professionCodesSelected, sectorType, 
				AgreementTypes[Enums.SearchMode.Community], 
				AgreementTypes[Enums.SearchMode.Mushlam], 
				AgreementTypes[Enums.SearchMode.Hospitals]};
            DataSet ds;


            string spName = "rpc_GetServicesNewAndEventsBySector";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetAllServicesExtended(string serviceCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { serviceCode };
            DataSet ds;


            string spName = "rpc_getAllServicesExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);
            return ds;
        }





        public DataSet GetServiceForPopUp_ViaEmployee(int deptCode, long employeeID, int agreementType, int serviceCode, DateTime expirationDate, string RemarkCategoriesForAbsence, string RemarkCategoriesForClinicActivity)
        {
            if (expirationDate == DateTime.MinValue)
                expirationDate = Convert.ToDateTime("1/1/1900");

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, employeeID, agreementType, serviceCode, expirationDate, RemarkCategoriesForAbsence, RemarkCategoriesForClinicActivity };
            DataSet ds;

            string spName = "rpc_getServiceForPopUp_ViaEmployee";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeReceptionAfterExpiration(int employeeID, DateTime expirationDate)
        {
            if (expirationDate == DateTime.MinValue)
                expirationDate = Convert.ToDateTime("1/1/1900");

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, expirationDate };
            DataSet ds;

            string spName = "rpc_getEmployeeReceptionAfterExpiration";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        #endregion

        #region DeptNames

        public int DeleteDeptNames(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };


            string spName = "rpc_deleteDeptNames";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            return ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public int InsertDeptName(int deptCode, string deptName, string deptNameFreePart, DateTime fromDate, DateTime? toDate, string updateUser)
        {
            int count = 0;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, deptName, deptNameFreePart, fromDate, toDate, updateUser };


            string spName = "rpc_insertDeptName";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            count = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return count;
        }


        public int InsertDeptNameForNewDept(int deptCode, string updateUser)
        {
            int ErrorStatus = 0;
            int count = 0;
            object[] outputParams = new object[1] { ErrorStatus };
            object[] inputParams = new object[] { deptCode, updateUser };

            count = ExecuteNonQuery("rpc_insertDeptNameForNewDept", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return count;
        }

        #endregion


        public string GetMainDeptPhone(int deptCode, int phoneType)
        {
            string phoneNum = string.Empty;
            object[] outputParams = new object[1] { phoneNum };
            object[] inputParams = new object[] { deptCode, phoneType };

            string spName = "rpc_GetMainDeptPhone";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return outputParams[0].ToString();
        }

        public string GetMainDeptPhoneByDeptEmployeeID(int deptEmployeeID)
        {
            string phoneNum = string.Empty;
            object[] outputParams = new object[1] { phoneNum };
            object[] inputParams = new object[] { deptEmployeeID };

            string spName = "rpc_GetMainDeptPhoneByDeptEmployeeID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return outputParams[0].ToString();
        }

        #region DeptReception

        public void GetDeptReceptions(ref DataSet p_ds, int p_deptCode, int p_ReceptionHoursType)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_deptCode, p_ReceptionHoursType };

            string spName = "rpc_GetDeptReceptions";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }
        #endregion


        public DataSet GetClosestNotActiveDate(int deptCode, DateTime startDate)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, startDate };

            string spName = "rpc_CheckIfDeptHasFutureNotActiveStatus";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }



        public DataSet GetClinicByName_AdministrationDepended(string searchText, int administrationCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchText, administrationCode };

            string spName = "rpc_GetClinicByName_AdministrationDepended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }


        public DataSet GetServicesAndEvents(string selectedValuesList)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { selectedValuesList };

            string spName = "rpc_GetServicesAndEvents";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetDeptListByParams(int deptCode, string deptName, int cityCode, int districtCode, int unitTypeCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, deptName, cityCode, districtCode, unitTypeCode };

            string spName = "rpc_GetDeptsListByParams";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetAllDeptServiceStatuses(int deptCode, int serviceCode, long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, serviceCode, employeeID };

            string spName = "rpc_GetAllDeptServiceStatuses";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public void DeleteDeptServiceStatus(int deptCode, int serviceCode, long employeeID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { deptCode, serviceCode, employeeID };


            string spName = "rpc_DeleteDeptServiceStatus";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }


        public void InsertDeptServiceStatus(int deptCode, int serviceCode, long employeeID, int status, DateTime fromDate, DateTime? toDate, string userName)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { deptCode, serviceCode, employeeID, status, fromDate, toDate, userName };


            string spName = "rpc_InsertDeptServiceStatus";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }




        public void AttachFileToDeptEvent(int deptEventID, string fileDisplayName, string fileName)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { deptEventID, fileDisplayName, fileName };


            string spName = "rpc_AttachFileToDeptEvent";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public string GetFileNameByDeptEventFileID(int deptEventFileID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEventFileID };
            string retValue = string.Empty;

            string spName = "rpc_GetFileNameByDeptEventFileID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            DataSet ds = FillDataSet(spName, ref outputParams, inputParams);

            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                retValue = ds.Tables[0].Rows[0][0].ToString();
            }

            return retValue;
        }

        public void DeleteAttachedFileToevent(int deptEventFileID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { deptEventFileID };


            string spName = "rpc_DeleteAttachedFileToEvent";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetDeptEventFiles(int deptEventID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEventID };

            string spName = "rpc_GetDeptEventFiles";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetDeptGeneralBelongings(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };

            string spName = "rpc_GetDeptGeneralBelongings";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetDeptGeneralBelongingsByDeptEmployee(int deptEmployeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEmployeeID };

            string spName = "rpc_GetDeptGeneralBelongingsByEmployee";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            return FillDataSet(spName, ref outputParams, inputParams);
        }

        #region Search Sal Services Methods

        public DataSet GetServiceCodeDescription_ForSearchSalServices(int servicecode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { servicecode };

            string spName = "rpc_getServiceDescriptionForSalServicesByServiceCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        #endregion

        public DataSet GetHealthOfficeCodeDescription_ForSearchSalServices(string healthOfficeCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { healthOfficeCode };

            string spName = "rpc_getHealthOfficeCodeDescriptionForSalServicesByServiceCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetGroupCodeDescription_ForSearchSalServices(int groupCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { groupCode };

            string spName = "rpc_GetGroupCodeDescription_ForSearchSalServices";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetProfessionCodeDescription_ForSearchSalServices(int iProfessionCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { iProfessionCode };

            string spName = "rpc_GetProfessionCodeDescription_ForSearchSalServices";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetOmriReturnCodeDescription_ForSearchSalServices(int iOmriReturnCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { iOmriReturnCode };

            string spName = "rpc_GetOmriReturnCodeDescription_ForSearchSalServices";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetICD9CodeDescription_ForSearchSalServices(string ICD9Code)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { ICD9Code };

            string spName = "rpc_GetICD9CodeDescription_ForSearchSalServices";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetSalServices(byte? includeInBasket, byte? common, byte? showServiceInInternet, byte? isActive, bool isLoggedIn, string searchText, int? serviceCode, string serviceDescription,
            string healthOfficeCode, string healthOfficeDescription, string groupsCodes, string professionsCodes,
            string omriReturnsCodes, string icd9Code, string populationCodes , int salCategoryID, int salOrganCode , 
            DateTime? basketApproveFromDate, DateTime? basketApproveToDate, DateTime? ADD_DATE_FromDate,
            DateTime? ADD_DATE_ToDate , bool showCanceledServices , DateTime? DEL_DATE_FromDate, DateTime? DEL_DATE_ToDate, DateTime? internetUpdated_FromDate, DateTime? internetUpdated_ToDate )
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { includeInBasket, common , showServiceInInternet , isActive , isLoggedIn , searchText , serviceCode , serviceDescription , 
                healthOfficeCode , healthOfficeDescription , groupsCodes , professionsCodes , omriReturnsCodes , icd9Code , 
                populationCodes , salCategoryID, salOrganCode , basketApproveFromDate , basketApproveToDate , ADD_DATE_FromDate , ADD_DATE_ToDate , showCanceledServices , DEL_DATE_FromDate , 
                DEL_DATE_ToDate , internetUpdated_FromDate , internetUpdated_ToDate};

            string spName = "rpc_GetSalServices";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetSalServices_Populations(byte? includeInBasket, byte? common, byte? showServiceInInternet, byte? isActive, bool isLoggedIn, string searchText,
            int? serviceCode, string serviceDescription, string healthOfficeCode, string healthOfficeDescription,
            string groupsCodes, string professionsCodes, string omriReturnsCodes, string icd9Code, string populationCodes, int salCategoryID, int salOrganCode, 
            DateTime? basketApproveFromDate, DateTime? basketApproveToDate, DateTime? ADD_DATE_FromDate, DateTime? ADD_DATE_ToDate,
            bool showCanceledServices , DateTime? DEL_DATE_FromDate, DateTime? DEL_DATE_ToDate, DateTime? internetUpdated_FromDate, DateTime? internetUpdated_ToDate)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { includeInBasket, common , showServiceInInternet , isActive , isLoggedIn , searchText , serviceCode , serviceDescription , 
                healthOfficeCode , healthOfficeDescription , groupsCodes , professionsCodes , omriReturnsCodes , icd9Code , 
                populationCodes ,salCategoryID, salOrganCode , basketApproveFromDate , basketApproveToDate , ADD_DATE_FromDate , ADD_DATE_ToDate , 
                showCanceledServices , DEL_DATE_FromDate , DEL_DATE_ToDate , internetUpdated_FromDate , internetUpdated_ToDate };

            string spName = "rpc_GetSalServices_PopulationTariff";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetSalServices_NewTests(byte? includeInBasket, byte? common, string searchText, int? serviceCode, string serviceDescription,
            string healthOfficeCode, string healthOfficeDescription, string groupsCodes, string professionsCodes, string omriReturnsCodes, string icd9Code,
            string populationCodes, DateTime? basketApproveFromDate, DateTime? basketApproveToDate, DateTime? ADD_DATE_FromDate,
            DateTime? ADD_DATE_ToDate, bool showCanceledServices, DateTime? DEL_DATE_FromDate, DateTime? DEL_DATE_ToDate)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { includeInBasket , common , searchText , serviceCode , serviceDescription , healthOfficeCode , 
                healthOfficeDescription , groupsCodes , professionsCodes , omriReturnsCodes , icd9Code , populationCodes , 
                basketApproveFromDate , basketApproveToDate , ADD_DATE_FromDate , ADD_DATE_ToDate, showCanceledServices, DEL_DATE_FromDate , DEL_DATE_ToDate };

            string spName = "rpc_GetSalServices_NewTests";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetSalServiceDetails(int servicecode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { servicecode };

            string spName = "rpc_GetSalServiceDetails";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetSalServiceTarifon(int servicecode , bool isBasicPermission)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { servicecode, isBasicPermission };

            string spName = "rpc_GetSalServiceTarifon";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetSalServiceICD9(int servicecode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { servicecode };

            string spName = "rpc_GetSalServiceICD9";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetSalServiceTarifonHistory(int serviceCode, byte populationCode, byte subPopulationCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCode, populationCode, subPopulationCode };

            string spName = "rpc_GetSalServiceTarifonHistory";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetPopulationDetails(byte populationCode, byte subPopulationCode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { populationCode, subPopulationCode };

            string spName = "rpc_GetPopulationDetails";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetSalServiceHistoryDetails(int serviceCode, DateTime updateDate)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCode, updateDate };

            string spName = "rpc_GetSalServiceHistoryDetails";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetGroupsByName(string searchStr)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { searchStr };

            string spName = "rpc_GetGroupsByGroupName";

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetOmriReturnsByName(string searchStr)
        {
            object[] inputParams = new object[1] { searchStr };
            DataSet ds;

            string spName = "rpc_GetOmriReturnsByName";

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            int status = 0;
            ds = FillDataSet(spName, ref status, inputParams);

            return ds;
        }

        public DataSet GetSalServiceInternetDetails(int servicecode)
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { servicecode };

            string spName = "rpc_GetSalServiceInternetDetails";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public int UpdateSalServiceInternetDetails(int serviceCode, string serviceNameForInternet, string serviceDetails,
            string serviceBrief, string serviceDetailsInternet, byte queueOrder, byte showServiceInInternet, byte updateComplete, string updateUser,
            byte diagnosis, byte treatment, int salOrganCode, string synonyms, string refund)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { serviceCode, serviceNameForInternet, serviceDetails, serviceBrief, serviceDetailsInternet, queueOrder
                , showServiceInInternet, updateComplete , updateUser , diagnosis, treatment, salOrganCode, synonyms , refund };

            string spName = "rpc_UpdateSalServiceInternetDetails";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            return ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetTypeOfDefenceList()
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { new object() };

            string spName = "rpc_getTypeOfDefenceList";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetDefencePolicyList()
        {
            DataSet ds = new DataSet();
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { new object() };

            string spName = "rpc_getDefencePolicyList";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }
    }
}
