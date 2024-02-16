using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Configuration;
using SeferNet.DataLayer;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.WorkFlow

{
    public class doctorManager
    {
        string m_ConnStr;

        public doctorManager()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang();
        }
        public doctorManager(string lang)
        {
            m_ConnStr = ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"].ConnectionString;
        }
        

        public DataSet getDoctorList_PagedSorted(DoctorSearchParameters doctorSearchParameters,
             SearchPagingAndSortingDBParams searchPagingAndSortingDBParams)
        {
            DataSet dsDoctorList = new DataSet();
            DoctorDB doctorDB = new DoctorDB();

            int userIsRegistered = 0;          
            UserManager userMgr = new UserManager();
            if (userMgr.GetUserInfoFromSession() != null )
                userIsRegistered = 1;
            int? status = (doctorSearchParameters.Status == -1) ? null : doctorSearchParameters.Status;
            doctorSearchParameters.PrepareParametersForDBQuery();
            doctorDB.getDoctorList_PagedSorted(ref dsDoctorList, userIsRegistered,doctorSearchParameters.FirstName,doctorSearchParameters.LastName,
               doctorSearchParameters.DistrictCodes,doctorSearchParameters.EmployeeID,
              doctorSearchParameters.ServiceCode,
			  doctorSearchParameters.ExpertProfession,doctorSearchParameters.LanguageCode,
              doctorSearchParameters.CurrentReceptionTimeInfo.ReceptionDays, doctorSearchParameters.CurrentReceptionTimeInfo.InHour, doctorSearchParameters.CurrentReceptionTimeInfo.FromHour, 
              doctorSearchParameters.CurrentReceptionTimeInfo.ToHour, doctorSearchParameters.CurrentReceptionTimeInfo.OpenNow,
                status, doctorSearchParameters.MapInfo.CityCode, doctorSearchParameters.EmployeeSectorCode, doctorSearchParameters.Sex, doctorSearchParameters.AgreementType,
			   doctorSearchParameters.CurrentSearchModeInfo.IsCommunitySelected, doctorSearchParameters.CurrentSearchModeInfo.IsMushlamSelected,
			  doctorSearchParameters.CurrentSearchModeInfo.IsHospitalsSelected, 
				doctorSearchParameters.HandicappedFacilitiesCodes,doctorSearchParameters.LicenseNumber,doctorSearchParameters.PositionCode,
                doctorSearchParameters.ReceiveGuests,
                searchPagingAndSortingDBParams.PageSize,searchPagingAndSortingDBParams.StartingPage
                ,searchPagingAndSortingDBParams.SortedBy,searchPagingAndSortingDBParams.IsOrderDescending, doctorSearchParameters.NumberOfRecordsToShow,
               doctorSearchParameters.MapInfo.CoordinatX, doctorSearchParameters.MapInfo.CoordinatY, doctorSearchParameters.IsGetEmployeesReceptionInfo,
               doctorSearchParameters.QueueOrderMethodsAndOptionsCodes);

            dsDoctorList.Tables[0].TableName = "Results";
            dsDoctorList.Tables[1].TableName = "QueueOrderMethods";
            dsDoctorList.Tables[2].TableName = "RowsCount";
            dsDoctorList.Tables[3].TableName = "AllSelectedCodes";
            if (doctorSearchParameters.IsGetEmployeesReceptionInfo)
            {
                dsDoctorList.Tables[4].TableName = "EmployeesReceptionInfo";
                dsDoctorList.Tables[5].TableName = "EmployeesRemarks";
            }
            return dsDoctorList;
        }

        public DataSet getDoctorList_PagedSorted(string CodesListForPage, int IsOrderDescending, bool isGetEmployeesReceptionHours)
        {
            DataSet dsDoctorList = new DataSet();
            DoctorDB doctorDB = new DoctorDB();

            doctorDB.getDoctorList_PagedSorted(ref dsDoctorList, CodesListForPage, IsOrderDescending, isGetEmployeesReceptionHours);

            dsDoctorList.Tables[0].TableName = "Results";
            dsDoctorList.Tables[1].TableName = "QueueOrderMethods";

            if (isGetEmployeesReceptionHours)
            {
                dsDoctorList.Tables[2].TableName = "EmployeesReceptionInfo";
                dsDoctorList.Tables[3].TableName = "EmployeesRemarks";
            }
            return dsDoctorList;
        }
        public DataSet getDoctorList_ForPrinting(DoctorSearchParameters doctorSearchParameters,
             SearchPagingAndSortingDBParams searchPagingAndSortingDBParams)
        {
            DataSet dsDoctorList = new DataSet();
            DoctorDB doctorDB = new DoctorDB();

            int userIsRegistered = 0;          
            UserManager userMgr = new UserManager();
            if (userMgr.GetUserInfoFromSession() != null )
                userIsRegistered = 1;
            int? status = (doctorSearchParameters.Status == -1) ? null : doctorSearchParameters.Status;
            doctorSearchParameters.PrepareParametersForDBQuery();
            doctorDB.getDoctorList_ForPrinting(ref dsDoctorList, userIsRegistered, doctorSearchParameters.FirstName, doctorSearchParameters.LastName,
               doctorSearchParameters.DistrictCodes,doctorSearchParameters.EmployeeID,
              doctorSearchParameters.ServiceCode,
			  doctorSearchParameters.ExpertProfession,doctorSearchParameters.LanguageCode,
              doctorSearchParameters.CurrentReceptionTimeInfo.ReceptionDays, doctorSearchParameters.CurrentReceptionTimeInfo.InHour, doctorSearchParameters.CurrentReceptionTimeInfo.FromHour, 
              doctorSearchParameters.CurrentReceptionTimeInfo.ToHour, doctorSearchParameters.CurrentReceptionTimeInfo.OpenNow,
                status, doctorSearchParameters.MapInfo.CityCode, doctorSearchParameters.EmployeeSectorCode, doctorSearchParameters.Sex, doctorSearchParameters.AgreementType,
			   doctorSearchParameters.CurrentSearchModeInfo.IsCommunitySelected, doctorSearchParameters.CurrentSearchModeInfo.IsMushlamSelected,
			  doctorSearchParameters.CurrentSearchModeInfo.IsHospitalsSelected, 
				doctorSearchParameters.HandicappedFacilitiesCodes,doctorSearchParameters.LicenseNumber,doctorSearchParameters.PositionCode,
                doctorSearchParameters.ReceiveGuests,
                searchPagingAndSortingDBParams.PageSize,searchPagingAndSortingDBParams.StartingPage
                ,searchPagingAndSortingDBParams.SortedBy,searchPagingAndSortingDBParams.IsOrderDescending, doctorSearchParameters.NumberOfRecordsToShow,
               doctorSearchParameters.MapInfo.CoordinatX, doctorSearchParameters.MapInfo.CoordinatY);

            return dsDoctorList;
        }      
        public DataSet getDoctorNameList(string SearchStrFirstName, string SearchStrLastName)
        {
            DataSet dsDoctorNameList = new DataSet();
            DoctorDB doctorDB = new DoctorDB();

            try
            {
                doctorDB.getDoctorNameList(ref dsDoctorNameList, SearchStrFirstName, SearchStrLastName);
            }
            catch (Exception ex)
            {
                PAB.ExceptionHandler.ExceptionLogger.WriteToLog(ex, "Failed to retrieve doctorNames (rpc_getDoctorNameList).\n Parameters: SearchStrFirstName=" + SearchStrFirstName + ", SearchStrLastName = " + SearchStrLastName);
                throw;
            }
            return dsDoctorNameList;
        }

        public DataSet GetDoctorByFirstNameAndSector(string p_SearchStr, string p_SearchStr_LastName,
														int isOnlyDoctorConnectedToClinic, int sector, Dictionary<Enums.SearchMode, bool> membershipValues)
        {            
            DoctorDB doctorDB = new DoctorDB();
            return doctorDB.GetDoctorByFirstNameAndSector(p_SearchStr, p_SearchStr_LastName,
												isOnlyDoctorConnectedToClinic, sector, membershipValues);
        }

		public DataSet GetDoctorByLastNameAndSector(string p_SearchStr, string p_SearchStr_FirstName,
														int isOnlyDoctorConnectedToClinic, int sector, Dictionary<Enums.SearchMode, bool> membershipValues)
		{            
            DoctorDB doctorDB = new DoctorDB();
			return doctorDB.GetDoctorByLastNameAndSector(p_SearchStr, p_SearchStr_FirstName,
												isOnlyDoctorConnectedToClinic, sector, membershipValues);
        }

        public DataSet getDoctorDetails(Int64 employeeID)
        {
            DataSet dsDoctorDetails = new DataSet();
            DoctorDB doctorDB = new DoctorDB();

            try
            { 
                doctorDB.getDoctorDetails(ref dsDoctorDetails, employeeID);
            }
            catch (Exception ex)
            {
                PAB.ExceptionHandler.ExceptionLogger.WriteToLog(ex, "Failed to retrieve doctorDetails (rpc_DoctorOverView).\n Parameters: employeeID=" + employeeID);
                throw;
            }

            dsDoctorDetails.Tables[0].TableName = "doctorDetails";
            dsDoctorDetails.Tables[1].TableName = "clinics";
            dsDoctorDetails.Tables[2].TableName = "doctorReceptionHours";
            dsDoctorDetails.Tables[3].TableName = "doctorClosestReceptionAddDate";
            dsDoctorDetails.Tables[4].TableName = "doctorUpdateDate";
            dsDoctorDetails.Tables[5].TableName = "clinicsUpdateDate";
            dsDoctorDetails.Tables[6].TableName = "receptionUpdateDate";
            dsDoctorDetails.Tables[7].TableName = "doctorRemarks";
            dsDoctorDetails.Tables[8].TableName = "clinicsForRemarks";
            dsDoctorDetails.Tables[9].TableName = "EmployeeQueueOrderMethods";
            dsDoctorDetails.Tables[10].TableName = "HoursForEmployeeQueueOrder";
            dsDoctorDetails.Tables[11].TableName = "DeptEmployeeServices";

            return dsDoctorDetails;
        }

        public DataSet getEmployeeReceptionAndRemarks(int deptEmployeeID, string serviceCode, DateTime expirationDate)
        {
            DoctorDB doctordb = new DoctorDB();
            DataSet dsEmployeeReception = new DataSet();
            doctordb.getEmployeeReceptionAndRemarks(ref dsEmployeeReception, deptEmployeeID, serviceCode, expirationDate);

            dsEmployeeReception.Tables[0].TableName = "employeeRemark";
            dsEmployeeReception.Tables[1].TableName = "employeeName";
            dsEmployeeReception.Tables[2].TableName = "closestNewReception";
            dsEmployeeReception.Tables[3].TableName = "doctorReception";
            dsEmployeeReception.Tables[4].TableName = "DeptEmployeePhones";
            dsEmployeeReception.Tables[5].TableName = "ClinicActivityRemarks";

            return dsEmployeeReception;
        }

        public DataSet GetEmployeeReceptionAfterExpiration(int employeeID, DateTime expirationDate)
        {
            ClinicDB clinicDB = new ClinicDB();
            DataSet dsEmployeeReception = new DataSet();
            dsEmployeeReception = clinicDB.GetEmployeeReceptionAfterExpiration(employeeID, expirationDate);

            dsEmployeeReception.Tables[0].TableName = "doctorDetails";
            dsEmployeeReception.Tables[1].TableName = "doctorReceptionHours";

            return dsEmployeeReception;
        }

        public DataSet GetEmployeeSectors(int isDoctor)
        { 
            DoctorDB doctordb = new DoctorDB();
            return doctordb.GetEmployeeSectors(isDoctor);
        }

        public void GetEmployeeGeneralData(ref DataSet p_ds, int p_EmployeeID)
        {
            doctor docbo = new doctor(m_ConnStr);
            docbo.GetEmployeeGeneralData(ref p_ds, p_EmployeeID); 
        }

        public DataSet GetEmployeeListForSpotting(string firstName, string lastName, int licenseNumber, long employeeID, int deptCode)
        {
            DoctorDB doctordb = new DoctorDB();
            return doctordb.GetEmployeeListForSpotting(firstName, lastName, licenseNumber, employeeID, deptCode ); 
        }

        public DataSet GetEmployeeList(string firstName, string lastName, int licenseNumber, long employeeID)
        {
            DoctorDB doctordb = new DoctorDB();
            return doctordb.GetEmployeeList(firstName, lastName, licenseNumber, employeeID); 
        }

        public DataSet GetEmployeeListForSpotting_MF(string firstName, string lastName, int licenseNumber, int employeeID)
        {
            DoctorDB doctordb = new DoctorDB();
            return doctordb.GetEmployeeListForSpotting_MF(firstName, lastName, licenseNumber, employeeID); 
        }

        public DataSet GetEmployeeByLastNameFrom226(string lastName, string firstName)
        {
            DoctorDB doctordb = new DoctorDB();
            return doctordb.GetEmployeeByLastNameFrom226( lastName, firstName ); 
        }

        public DataSet GetEmployeeByFirstNameFrom226(string firstName, string lastName)
        {
            DoctorDB doctordb = new DoctorDB();
            return doctordb.GetEmployeeByFirstNameFrom226( firstName, lastName ); 
        }

        public void InsertEmployeeIntoSefer(int employeeID, string lastName, string firstName,
            int employeeSectorCode, int primaryDistrict, bool isVirtualDoctor, string updateUser, int gender, int profLicence, bool isDental, ref Int64 NewEmployeeID)
        {
            DoctorDB doctordb = new DoctorDB();

            doctordb.InsertEmployeeIntoSefer(employeeID, lastName, firstName, employeeSectorCode, primaryDistrict, isVirtualDoctor, updateUser, gender, profLicence, isDental, ref NewEmployeeID);
        }

        /// <summary>
        /// This is a general method that retrieves a view or a small table
        /// using the table name parameter
        /// </summary>
        /// <param name="dataTableName"></param>
        /// <returns></returns>
        public DataSet getGeneralDataTable(string dataTableName)
        {
            DataSet ds = new DataSet();

            ClinicDB clinicdb = new ClinicDB();
            clinicdb.getGeneralDataTable(ref ds, dataTableName);

            return ds;
        }

        #region Reception 
        public void GetEmployeeReceptions(ref DataSet p_ds, long p_EmployeeCode, int? p_deptCode)
        {
            BusinessLayer.BusinessObject.doctor doc = new doctor(m_ConnStr); 

            doc.GetEmployeeReceptions(ref p_ds, p_EmployeeCode, p_deptCode);
        }
  
        #endregion 

    }
}
