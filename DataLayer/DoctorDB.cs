using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Web;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using SeferNet.Globals;

//
namespace SeferNet.DataLayer
{
    public class DoctorDB : Base.SqlDalEx
    {
        public void GetEmployeeGeneralData(ref DataSet p_ds, int p_EmployeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_EmployeeID };

            string spName = "rpc_GetEmployeeGeneralData";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void getDoctorDetails(ref DataSet p_ds, Int64 p_EmployeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { p_EmployeeID };

            string spName = "rpc_DoctorOverView";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void getDoctorNameList(ref DataSet p_ds, string p_SearchStrFirstName, string p_SearchStrLastName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[2] { p_SearchStrFirstName, p_SearchStrLastName };

            string spName = "rpc_getDoctorNameList";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetDoctorByFirstNameAndSector(string p_SearchStr, string p_SearchStr_LastName,
													int isOnlyDoctorConnectedToClinic, int sector, Dictionary<Enums.SearchMode, bool> membershipValues)
        {
            object[] outputParams = new object[1] { new object() };
			object[] inputParams = new object[] { p_SearchStr, p_SearchStr_LastName, isOnlyDoctorConnectedToClinic, sector, 
				membershipValues[Enums.SearchMode.Community], 
				membershipValues[Enums.SearchMode.Mushlam], 
				membershipValues[Enums.SearchMode.Hospitals]  };

            string spName = "rpc_findDoctorByFirstNameAndSector";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            DataSet ds = FillDataSet(spName, ref outputParams, inputParams);
            return ds;
        }

		public DataSet GetDoctorByLastNameAndSector(string p_SearchStr, string p_SearchStr_LastName,
													int isOnlyDoctorConnectedToClinic, int sector, Dictionary<Enums.SearchMode, bool> membershipValues)
		{
			object[] outputParams = new object[1] { new object() };
			object[] inputParams = new object[] { p_SearchStr, p_SearchStr_LastName, isOnlyDoctorConnectedToClinic, sector, 
				membershipValues[Enums.SearchMode.Community], 
				membershipValues[Enums.SearchMode.Mushlam], 
				membershipValues[Enums.SearchMode.Hospitals]  };

            string spName = "rpc_findDoctorByLastNameAndSector";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            DataSet ds = FillDataSet(spName, ref outputParams, inputParams);
            return ds;
        }

        #region Employee reception hours

        public int DeleteDoctorHours(int receptionID)
        {
            int errorCode = 0;
            object[] outputParams = new object[1] { errorCode };
            object[] inputParams = new object[] { receptionID };

            string spName = "rpc_deleteDoctorHours";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            return ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        /// <summary>
        /// get the list of doctor's professions attributed to specific reception hours
        /// </summary>
        /// <param name="receptionID"></param>
        /// <returns></returns>
        public DataSet GetDeptEmployeeReceptionProfessions_Attributed(int receptionID )
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { receptionID };
            DataSet ds;

            string spName = "rpc_getDeptEmployeeReceptionProfessions_Attributed";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        /// <summary>
        /// get the list of doctor's services attributed to specific reception hours
        /// </summary>
        /// <param name="receptionID"></param>
        /// <returns></returns>
        public DataSet GetDeptEmployeeServicesForReceptionToAdd(int receptionID, int deptCode, int employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { receptionID, deptCode, employeeID };
            DataSet ds;

            string spName = "rpc_getDeptEmployeeServicesForReceptionToAdd";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public string DeleteDeptEmployeeReceptionProfessions(int deptEmployeeReceptionProfessionsID)
        {
            string outputMessage = string.Empty;
            object[] outputParams = new object[1] { outputMessage };
            object[] inputParams = new object[] { deptEmployeeReceptionProfessionsID };

            string spName = "rpc_deleteDeptEmployeeReceptionProfessions";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return outputMessage;
        }

        public DataSet GetDeptEmployeeReceptionRemarks(int employeeReceptionID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeReceptionID };
            DataSet ds;

            string spName = "rpc_getDeptEmployeeReceptionRemarks";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetDeptEmployeeReceptionRemarksByID(int deptEmployeeReceptionRemarkID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptEmployeeReceptionRemarkID };
            DataSet ds;

            string spName = "rpc_getDeptEmployeeReceptionRemarksByID";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        /// <summary>
        /// If the remark to be removed is the sort of "EnableOverlappingHours"
        /// we have to check what will with overlapping and, consequently, to permit or not permit the deletion.
        /// The "outputMessage" is what to be returned in case of "deletion isn't permitted" .
        /// </summary>
        /// <param name="DeptEmployeeReceptionRemarkID"></param>
        /// <returns></returns>
        public int DeleteDeptEmployeeReceptionRemarks(int DeptEmployeeReceptionRemarkID)
        {
            string outputMessage = string.Empty;
            int errorCode = 0;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { DeptEmployeeReceptionRemarkID };

            string spName = "rpc_deleteDeptEmployeeReceptionRemarks";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            errorCode = Convert.ToInt32(outputParams[0]);

            return errorCode;

        }

        #endregion

        public void getDoctorList_PagedSorted(ref DataSet p_ds, int userIsRegistered, string firstName,
            string lastName, string districtCode, long? employeeID, 
            string serviceCode, int? expProfession, string languageCode, string receptionDays, string openAtHour, string openFromHour,
            string openToHour, bool openNow, int? active, int? cityCode, int? employeeSectorCode, int? sex, int? agreementType,
			bool? isInCommunity, bool? isInMushlam, bool? isInHospitals,
            string deptHandicappedFacilities, int? licenseNumber, int? positionCode, bool ReceiveGuests,
            int? pageSize, int? startingPage, string SortedBy, int isOrderDescending, int? numberOfRecordsToShow,
            double? coordinatX, double? coordinatY, bool IsGetEmployeesReceptionInfo, string QueueOrderMethodsAndOptionsCodes)
        {
            //always null
            //string subProfessionCode = null;
            string cityName = null;

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { firstName, lastName, districtCode, employeeID, cityName,
                serviceCode, expProfession, languageCode, receptionDays, openAtHour, openFromHour,  
                openToHour, openNow, active, cityCode, employeeSectorCode, sex, agreementType,
                isInCommunity, isInMushlam, isInHospitals, deptHandicappedFacilities, licenseNumber, positionCode, ReceiveGuests,
                pageSize, startingPage, SortedBy, isOrderDescending, numberOfRecordsToShow,
                coordinatX, coordinatY, userIsRegistered,IsGetEmployeesReceptionInfo, QueueOrderMethodsAndOptionsCodes};
          

            string spName = "rpc_getDoctorList_PagedSorted";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void getDoctorList_PagedSorted(ref DataSet p_ds, string CodesListForPage, int IsOrderDescending, bool isGetEmployeesReceptionHours)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { CodesListForPage, IsOrderDescending, isGetEmployeesReceptionHours };

            string spName = "rpc_getDoctorList_OnePage";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void getDoctorList_ForPrinting(ref DataSet p_ds, int userIsRegistered, string firstName,
            string lastName, string districtCode, long? employeeID, 
            string serviceCode, int? expProfession, string languageCode, string receptionDays, string openAtHour, string openFromHour,
            string openToHour, bool openNow, int? active, int? cityCode, int? employeeSectorCode, int? sex, int? agreementType,
			bool? isInCommunity, bool? isInMushlam, bool? isInHospitals,
            string deptHandicappedFacilities, int? licenseNumber, int? positionCode, bool ReceiveGuests,
            int? pageSize, int? startingPage, string SortedBy, int isOrderDescending, int? numberOfRecordsToShow,
            double? coordinatX, double? coordinatY)
        {
            //always null
            //string subProfessionCode = null;
            string cityName = null;

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { firstName, lastName, districtCode, employeeID, cityName,
                serviceCode, expProfession, languageCode, receptionDays, openAtHour, openFromHour,  
                openToHour, openNow, active, cityCode, employeeSectorCode, sex, agreementType,
                isInCommunity, isInMushlam, isInHospitals, deptHandicappedFacilities, licenseNumber, positionCode, ReceiveGuests,
                pageSize, startingPage, SortedBy, isOrderDescending, numberOfRecordsToShow,
                coordinatX, coordinatY, userIsRegistered};


            string spName = "rpc_getDoctorList_ForPrinting";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet PopulateAbsenceData(SqlDataAdapter adapter)
        {
            DataSet ds = new DataSet();
            adapter.FillSchema(ds, SchemaType.Source);
            adapter.Fill(ds);
            return ds;
        }

        public void getEmployeeReceptionAndRemarks(ref DataSet p_ds, int deptEmployeeID, string serviceCode, DateTime expirationDate)
        {
            if (expirationDate == DateTime.MinValue)
                expirationDate = Convert.ToDateTime("1/1/1900");

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[3] { deptEmployeeID, serviceCode, expirationDate };

            string spName = "rpc_getEmployeeReceptionAndRemarks";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }


        public DataSet GetEmployee(long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID };
            DataSet ds;

            string spName = "rpc_getEmployee";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeListForSpotting(string firstName, string lastName, int licenseNumber, long employeeID, int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { firstName, lastName, licenseNumber, employeeID, deptCode };
            DataSet ds;

            if (inputParams[0].ToString() == string.Empty)//firstName
                inputParams[0] = null;
            if (inputParams[1].ToString() == string.Empty)//lastName
                inputParams[1] = null;
            if (Convert.ToInt32(inputParams[2]) == -1)//licenseNumber
                inputParams[2] = null;
            if (Convert.ToInt32(inputParams[3]) == -1)//employeeID
                inputParams[3] = null;


            string spName = "rpc_getEmployeeListForSpotting";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeList(string firstName, string lastName, int licenseNumber, long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { firstName, lastName, licenseNumber, employeeID };
            DataSet ds;

            if (inputParams[0].ToString() == string.Empty)//firstName
                inputParams[0] = null;
            if (inputParams[1].ToString() == string.Empty)//lastName
                inputParams[1] = null;
            if (Convert.ToInt32(inputParams[2]) == -1)//licenseNumber
                inputParams[2] = null;
            if (Convert.ToInt32(inputParams[3]) == -1)//employeeID
                inputParams[3] = null;


            string spName = "rpc_getEmployeeList";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeListForSpotting_MF(string firstName, string lastName, int licenseNumber, int employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { firstName, lastName, licenseNumber, employeeID };
            DataSet ds;

            if (inputParams[0].ToString() == string.Empty)//firstName
                inputParams[0] = null;
            if (inputParams[1].ToString() == string.Empty)//lastName
                inputParams[1] = null;
            if (Convert.ToInt32(inputParams[2]) == -1)//licenseNumber
                inputParams[2] = null;
            if (Convert.ToInt32(inputParams[3]) == -1)//employeeID
                inputParams[3] = null;

            string spName = "rpc_getEmployeeListForSpotting_MF";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeByLastNameFrom226(string lastName, string firstName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { lastName, firstName };
            DataSet ds;

            if (inputParams[0].ToString() == string.Empty)//lastName
                inputParams[0] = null;
            if (inputParams[1].ToString() == string.Empty)//firstName
                inputParams[1] = null;

            string spName = "rpc_getEmployeeByLastNameFrom226";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeByFirstNameFrom226(string firstName, string lastName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { firstName, lastName };
            DataSet ds;

            if (inputParams[0].ToString() == string.Empty)//firstName
                inputParams[0] = null;
            if (inputParams[1].ToString() == string.Empty)//lastName
                inputParams[1] = null;

            string spName = "rpc_getEmployeeByFirstNameFrom226";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public int UpdateEmployee(long employeeID, int degreeCode, string firstName, string lastName,
            int EmployeeSectorCode, int sex, int primaryDistrict,
            string email, bool showEmailInInternet, string updateUser)
        {
            int result = 0;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, degreeCode, firstName, lastName,
                EmployeeSectorCode, sex, primaryDistrict,
                email, showEmailInInternet, updateUser};


            string spName = "rpc_updateEmployee";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            result = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);


            return result;
        }

        public int UpdateEmployeeProfessionLicence(long employeeID, int profLicence,  string updateUser)
        {
            int result = 0;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, profLicence, updateUser};

            string spName = "rpc_UpdateEmployeeProfessionLicence";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            result = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);


            return result;
        }

        public void UpdateEmployeeInClinicPreselected(long? employeeID, int? deptCode,  int? deptEmployeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, deptEmployeeID };

            string spName = "rpc_Update_EmployeeInClinic_preselected";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public int UpdateEmployeeProfessionLicences(DataTable EmployeeProfessionLicences)
        {
            int result = 0;

            string ConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"].ConnectionString;

            SqlConnection conn = new SqlConnection(ConnectionString);
            SqlDataAdapter da = new SqlDataAdapter();
            SqlCommand cmd = new SqlCommand();

            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = "rpc_UpdateEmployeeProfessionLicences";

            cmd.Parameters.Add("@EmployeeProfessionLicences", SqlDbType.Structured);
            cmd.Parameters["@EmployeeProfessionLicences"].Value = EmployeeProfessionLicences;

            cmd.Parameters.Add("@numOfRowsAffected", SqlDbType.Int);
            cmd.Parameters["@numOfRowsAffected"].Direction = ParameterDirection.Output;

            cmd.Connection = conn;

            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
                //result = Convert.ToInt32(cmd.Parameters["@numOfRowsAffected"]);
            }

            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                conn.Close();
            }

            return result;
        }
        public DataSet GetEmployeesToUpdateProfessionLicences()
        {
            int result = 0;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };
            DataSet ds;

            string spName = "rpc_GetEmployeesToUpdateProfessionLicences";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetX_EmployeeSubSector_ProfLicenseType()
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };
            DataSet ds;

            string spName = "rpc_GetX_EmployeeSubSector_ProfLicenseType";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void InsertEmployeeIntoSefer(int employeeID, string lastName, string firstName,
            int employeeSectorCode, int primaryDistrict, bool isVirtualDoctor, string updateUser,int gender, int profLicence, bool isDental, ref Int64 NewEmployeeID)
        {
            int insertedRecords = 0;
            int ErrCode = 0;
            object[] outputParams = new object[] { NewEmployeeID, ErrCode };
            object[] inputParams = new object[] { employeeID, lastName, firstName, employeeSectorCode, primaryDistrict, isVirtualDoctor, updateUser, gender, profLicence, isDental };

            if (primaryDistrict == -1)
                inputParams[4] = null;

            inputParams[5] = Convert.ToInt32(inputParams[5]);//isVirtualDoctor


            string spName = "rpc_insertEmployeeIntoSefer";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            insertedRecords = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrCode = Convert.ToInt32(outputParams[1]);
            NewEmployeeID = Convert.ToInt64(outputParams[0]);
            if (insertedRecords == 0)
                throw new Exception("No records were inserted");
        }

        public DataSet GetAllEmployeeDegrees()
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };
            DataSet ds;

            string spName = "rpc_GetAllEmployeeDegree";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        #region EmployeeProfession

        public DataSet GetEmployeeProfessions(long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID };
            DataSet ds;

            string spName = "rpc_getEmployeeProfessions";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeProfessionForUpdate(int employeeID, int professionCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, professionCode };
            DataSet ds;

            string spName = "rpc_getEmployeeProfessionForUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void InsertEmployeeProfession(long employeeID, string professionCodes, string updateUser)
        {

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, professionCodes, updateUser };

            string spName = "rpc_insertEmployeeProfession";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void UpdateEmployeeProfession(int employeeID, int professionCode,
            int mainProfession, int expProfession, string updateUser)
        {
            int ErrorCode = 0;
            object[] outputParams = new object[] { ErrorCode };
            object[] inputParams = new object[] { employeeID, professionCode, 
                mainProfession, expProfession, updateUser};

            string spName = "rpc_updateEmployeeProfession";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
        }

        public void DeleteEmployeeProfession(int employeeID, int professionCode)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, professionCode };

            string spName = "rpc_deleteEmployeeProfession";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteEmployeeProfessions(long employeeID, string professionCodes)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, professionCodes };

            string spName = "rpc_deleteEmployeeProfessions";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }
        public void DeleteAllEmployeeProfessions(long employeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[2] { employeeID, DBNull.Value };

            string spName = "rpc_deleteEmployeeProfession";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetProfessionsForEmployee(int employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID };
            DataSet ds;

            string spName = "rpc_getProfessionsForEmployee";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetEmployeeProfessionsExtended(long employeeCode, int deptCode, bool IsLinkedToEmployeeOnly, bool EnableExpert)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeCode, deptCode, IsLinkedToEmployeeOnly, EnableExpert };
            DataSet ds;

            string spName = "rpc_GetEmployeeProfessionsExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetAllProfessionsExtended(string professionCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { professionCode };
            DataSet ds;

            string spName = "rpc_getAllProfessionsExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

       #endregion

        #region EmployeeServices

        public DataSet GetEmployeeServices(long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID };
            DataSet ds;

            string spName = "rpc_getEmployeeServices";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void InsertEmployeeServices(long employeeID, string serviceCodes, string updateUser)
        {

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, serviceCodes, updateUser };

            string spName = "rpc_insertEmployeeServices";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteEmployeeService(int employeeID, int serviceCode)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, serviceCode };

            string spName = "rpc_deleteEmployeeService";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

	    #endregion
        #region EmployeeLanguages

        public void DeleteEmployeeLanguages(int employeeID, int languageCode)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, languageCode };

            string spName = "rpc_deleteEmployeeLanguages";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void InsertEmployeeLanguages(long employeeID, string languageCodes, string updateUser)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, languageCodes, updateUser };

            string spName = "rpc_insertEmployeeLanguages";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetLanguagesForEmployee(long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID };
            DataSet ds;

            string spName = "rpc_getLanguagesForEmployee";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetLanguagesExtended(string selectedLanguages)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { selectedLanguages };
            DataSet ds;

            string spName = "rpc_getLanguagesExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

   #endregion
        #region EmployeeSector

        public DataSet GetEmployeeSectors(int IsDoctor)
        {
            // if IsDoctor == -1 then select ALL
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { IsDoctor };
            DataSet ds;

            string spName = "rpc_getEmployeeSectors";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

    #endregion

        #region EmployeeReception 
        public void GetEmployeeReceptions(ref DataSet p_ds, long p_EmployeeCode, int? p_deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_EmployeeCode, p_deptCode };

            string spName = "rpc_GetEmployeeReceptionByServiceAndProfession";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        #endregion         

       
    
        public void DeleteAllEmployeeServices(long employeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, null };

            string spName = "rpc_deleteEmployeeService";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteEmployeeReception(long employeeID, int deptCode, int agreementType)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, agreementType };

            string spName = "rpc_DeleteEmployeeReception";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            ExecuteNonQuery( "rpc_DeleteEmployeeReception", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void Update_DeptEmployeeReception_Regular_ThisWeak(long employeeID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { employeeID };

            string spName = "rpc_Update_DeptEmployeeReception_Regular_ThisWeak";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);

            ExecuteNonQuery("rpc_Update_DeptEmployeeReception_Regular_ThisWeak", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void InsertEmployeeReception(int deptCode, int EmployeeID, int agreementType, int receptionDay, string openingHour, string closingHour, string receptionRoom,
                            bool? receiveGuests, string itemType, int itemID, string remarkText, int remarkID, DateTime? validFrom, DateTime? validTo, string updateUser)
        {
            int errorCode = 0;
            SqlDateTime dateFrom = SqlDateTime.Null, dateTo = SqlDateTime.Null;

            if (validFrom != null)
            {
                dateFrom = (SqlDateTime)validFrom;
            }
            if (validTo != null)
            {
                dateTo = (SqlDateTime)validTo;
            }
            object[] outputParams = new object[ ] { errorCode };
            object[] inputParams = new object[ ] { EmployeeID, deptCode, agreementType,  
                receptionDay, openingHour, closingHour, receptionRoom, receiveGuests, dateFrom, dateTo, itemType, itemID, remarkText, remarkID, updateUser};

            string spName = "rpc_InsertEmployeeReception";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            errorCode = Convert.ToInt32(outputParams[0]);
        }

        public DataSet GetLanguagesForEmployeeExtended(long employeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID };
            DataSet ds;

            string spName = "rpc_GetLanguagesForEmployeeExtended";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;
        }

        public void DeleteAllEmployeeLanguages(long employeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, null };

            string spName = "rpc_deleteEmployeeLanguages";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void UpdateEmployeeExpertise(long employeeID, string professionCodes, string expertDiplomaNumbers, string userName)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, professionCodes, expertDiplomaNumbers, userName };

            string spName = "rpc_updateEmployeeExpertise";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetEmployeeExpertiseToUpdate(long employeeID, string professionCodes)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, professionCodes };
            DataSet ds;

            string spName = "rpc_GetEmployeeExpertiseToUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return ds;
        }
        public DataSet GetAllEmployeeStatusesInDept(long employeeID, int deptCode)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode };
            DataSet ds;

            string spName = "rpc_GetEmployeeStatusInDept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetAllEmployeeStatuses(long employeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID };
            DataSet ds;

            string spName = "rpc_GetEmployeeStatus";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);


            return ds;
        }

        public void InsertEmployeeStatusInDept(long employeeID, int deptCode, int agreementType, int status, DateTime fromDate, DateTime? toDate, string updateUser)
        {
            SqlDateTime sqlToDate = SqlDateTime.Null;

            if (toDate != null)
            {
                sqlToDate = (SqlDateTime)toDate;
            }

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, agreementType, status, fromDate, sqlToDate, updateUser };

            ExecuteNonQuery("rpc_InsertEmployeeStatusInDept", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void UpdateEmployeeInDeptCurrentStatus(long employeeID, int deptCode, int agreementType, int status, DateTime? toDate, string updateUser)
        {

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, agreementType, status, toDate, updateUser };


            ExecuteNonQuery("rpc_UpdateEmployeeInDeptCurrentStatus", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void UpdateEmployeeInDeptCurrentStatusByDeptEmployeeID(int deptEmployeeID, int status, string updateUser)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { deptEmployeeID, status, updateUser };

            ExecuteNonQuery("rpc_UpdateEmployeeInDeptCurrentStatusByDeptEmployeeID", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

 		public void UpdateEmployeeInDeptStatusWhenNoProfessions(long employeeID, int deptCode, string updateUser)
        {

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, updateUser };


            ExecuteNonQuery("rpc_UpdateEmployeeInDeptStatusWhenNoProfessions", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void DeleteEmployeeReceptionInDept(long employeeID, int deptCode, int agreementType)
        {

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, agreementType };


            ExecuteNonQuery("rpc_DeleteEmployeeReceptionInDept", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }


        public void InsertEmployeeStatus(long employeeID, int status, DateTime fromDate, DateTime? toDate, string updateUser)
        {
            SqlDateTime sqlToDate = SqlDateTime.Null;

            if (toDate != null)
            {
                sqlToDate = (SqlDateTime)toDate;
            }

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, status, fromDate, sqlToDate, updateUser };

            string spName = "rpc_InsertEmployeeStatus";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public int InsertEmployeeStatus(IDbTransaction trans, long employeeID, int status, DateTime fromDate, DateTime? toDate, string updateUser)
        {
            SqlDateTime sqlToDate = SqlDateTime.Null;
            int count = 0;

            if (toDate != null)
            {
                sqlToDate = (SqlDateTime)toDate;
            }

            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, status, fromDate, sqlToDate, updateUser };


            count = ExecuteNonQuery(trans, "rpc_InsertEmployeeStatus", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return count;

        }

        public void UpdateEmployeeCurrentStatus(long employeeID, int status, string updateUser)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, status, updateUser };


            string spName = "rpc_UpdateEmployeeCurrentStatus";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void DeleteEmployeeStatusInDept(long employeeID, int deptCode, int agreementType)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID, deptCode, agreementType };

            ExecuteNonQuery("rpc_DeleteEmployeeStatusInDept", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteEmployeeStatus(long employeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID };

            string spName = "rpc_DeleteEmployeeStatus";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public int DeleteEmployeeStatus(IDbTransaction trans, long employeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID };
            int Error = 0;


            ExecuteNonQuery(trans, "rpc_DeleteEmployeeStatus", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            Error = Convert.ToInt32(outputParams[0]);

            return Error;
        }

        public DataSet GetCurrentStatusForEmployeeInDept(int deptEmployeeID)
        {
            object[] outputParams = new object[] {  };
            object[] inputParams = new object[] { deptEmployeeID };
            DataSet ds;


            string spName = "rpc_GetCurrentStatusForEmployeeInDept";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);


            return ds;
        }

        public DataSet GetCurrentStatusForEmployeeInDept_byEpmployeeIDandDeptCode(long EmployeeID, int deptCode, int AgreementType)
        {
            object[] outputParams = new object[] {  };
            object[] inputParams = new object[] { EmployeeID, deptCode, AgreementType };
            DataSet ds;


            string spName = "rpc_GetCurrentStatusForEmployeeInDept_byEpmployeeIDandDeptCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);


            return ds;
        }
        public DataSet GetCurrentStatusForEmployee(long employeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID };
            DataSet ds;


            string spName = "rpc_GetCurrentStatusForEmployee";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);


            return ds;
        }


        public DataSet CheckHoursOverlappingRemark(string commaSpereatedStr)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { commaSpereatedStr };
            DataSet ds;


            string spName = "rpc_checkHoursOverlappRemark";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);


            return ds;
        }

        public DataSet GetEmployeeServicesForPopUp(int m_employeeID, int m_deptCode)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { m_employeeID, m_deptCode };
            DataSet ds;


            string spName = "rpc_GetServicesForPopup";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return ds;
        }

        public bool CheckIfEmployeeIsDoctor(long employeeID)
        {
            object[] outputParams = new object[] { new object() };
            object[] inputParams = new object[] { employeeID };
            DataSet ds;
            bool ret = false;


            string spName = "rpc_CheckIfEmployeeIsDoctor";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                ret = Convert.ToInt32(ds.Tables[0].Rows[0][0]) != 0;
            }


            return ret;
        }

        public DataSet IsVirtualDoctorOrMedicalTeam(long employeeID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeID };


            string spName = "rpc_IsVirtualDoctorOrMedicalTeam";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            DataSet ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;

        }

        public bool CheckIfEmployeeExistsInDoctorsList(long employeeID, int? licenseNumber)
        {
            bool retValue = false;
            object[] outputParams = new object[] { retValue };
            object[] inputParams = new object[] { employeeID, licenseNumber };

            string spName = "rpc_CheckIfEmployeeExistsInDoctorsList";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return (bool)outputParams[0];
        }

		public bool CheckIfEmployeeExistsInEmployee(long employeeID)
		{
			bool retValue = false;
			object[] outputParams = new object[] { retValue };
			object[] inputParams = new object[] { employeeID };

			string spName = "rpc_CheckIfEmployeeExistsInEmployee";
			DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
			ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
			return (bool)outputParams[0];
		}

        public bool IsProfessionAllowedForEmployee(long employeeID)
        {
            bool retValue = false;
            object[] outputParams = new object[] { retValue };
            object[] inputParams = new object[] { employeeID };


            string spName = "rpc_IsProfessionAllowedToEmployee";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return (bool)outputParams[0];
        }

        public DataSet GetAllPositionsByName(string prefixText, long employeeID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { prefixText, employeeID };
            DataSet ds;


            string spName = "rpc_GetPositionsByNameAndSector";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;
        }

        public DataSet GetEmployeeSpecialityByName(string prefixText, long employeeID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { prefixText, employeeID };
            DataSet ds;


            string spName = "rpc_GetEmployeeSpecialityByName";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;
        }

        public void InsertDeptEmployeeServiceRemark(IDbTransaction trans, int deptEmployeeID, int serviceCode, int remarkID, string remarkText,
                                                               DateTime dateFrom, DateTime? dateTo, DateTime? activeFrom, bool displayOnInternet, string userName)
        {
            SqlDateTime sqlDateTo = SqlDateTime.Null;

            if (dateTo != null)
            {
                sqlDateTo = (SqlDateTime)dateTo;

            }

            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { deptEmployeeID, serviceCode, remarkID, remarkText, 
                                                            dateFrom, sqlDateTo, activeFrom, displayOnInternet, userName};

            if (trans == null)
            {
                string spName = "rpc_InsertDeptEmployeeServiceRemark";
                DBActionNotification.RaiseOnDBInsert(spName, inputParams);
                ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            }
            else
            {
                ExecuteNonQuery(trans, "rpc_InsertDeptEmployeeServiceRemark", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            }
        }

        public void DeleteEmployeeServiceRemark(IDbTransaction trans, int deptEmployeeID, int serviceCode)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { deptEmployeeID, serviceCode };

            if (trans == null)
            {
                string spName = "rpc_DeleteDeptEmployeeServiceRemark";
                DBActionNotification.RaiseOnDBDelete(spName, inputParams);
                ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            }
            else
            {
                ExecuteNonQuery(trans, "rpc_DeleteDeptEmployeeServiceRemark", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            }
        }
        public void DeleteDeptEmployeeServiceRemarkByRemarkID(int remarkID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { remarkID };

            string spName = "rpc_DeleteDeptEmployeeServiceRemarkByRemarkID";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetProfessionsBySector(int sectorType, string professionCodesSelected)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { sectorType, professionCodesSelected };
            DataSet ds;


            string spName = "rpc_GetProfessionsForSector";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;

        }

        public DataSet GetDeptEmployeeServiceRemark(int RemarkID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { RemarkID };
            DataSet ds;

            string spName = "rpc_GetDeptEmployeeServiceRemark";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;
        }

        public DataSet GetEmployeeDeptsByText(string prefixText, long employeeID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { prefixText, employeeID };
            DataSet ds;


            string spName = "rpc_GetEmployeeDeptsByText";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;
        }

        public DataSet GetRelatedDeptsForEmployeeRemark(int employeeRemarkID)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeRemarkID };
            DataSet ds;

            string spName = "rpc_GetDeptsForEmployeeRemarkFromAllDepts";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;
        }

        public bool IsEmployeeParaMedicalOrSiudSector(long employeeID)
        {
            bool retValue = false;
            object[] outputParams = new object[] { retValue };
            object[] inputParams = new object[] { employeeID };

            string spName = "rpc_IsEmployeeParaMedicalOrSiudSector";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            retValue = Convert.ToBoolean(outputParams[0]);
            return retValue;
        }


        public DataSet GetEmployeeServiceInDeptStatus(long employeeID, int deptCode, int serviceCode)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeID, deptCode, serviceCode };
            DataSet ds;

            string spName = "rpc_GetEmployeeServiceInDeptStatus";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;
        }

        public DataSet GetCurrentEmployeeServiceInDeptStatus(long employeeID, int deptCode, int serviceCode)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeID, deptCode, serviceCode };
            DataSet ds;

            string spName = "rpc_GetCurrentEmployeeServiceInDeptStatus";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return ds;
        }


        public void UpdateEmployeeServiceInDeptCurrentStatus(long employeeID, int deptCode, int serviceCode, int status, string userName)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeID, deptCode, serviceCode, status, userName };


            string spName = "rpc_UpdateEmployeeServiceInDeptCurrentStatus";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }


        public void DeleteEmployeeServiceInDeptStatus(long employeeID, int deptCode, int serviceCode)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeID, deptCode, serviceCode };


            string spName = "rpc_DeleteEmployeeServiceInDeptStatus";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void InsertEmployeeServiceInDeptStatus(long employeeID, int deptCode, int serviceCode, int status, DateTime fromDate,
                                                        DateTime? toDate, string userName)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { employeeID, deptCode, serviceCode, status, fromDate, toDate, userName };


            string spName = "rpc_InsertEmployeeServiceInDeptStatus";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void CascadeEmployeeServiceQueueOrderFromDept(int x_Dept_Employee_ServiceID, string updateUser)
        {
            object[] outputParams = new object[] { };
            object[] inputParams = new object[] { x_Dept_Employee_ServiceID, updateUser };


            string spName = "rpc_CascadeEmployeeServiceQueueOrderFromDept";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }
    }
}
