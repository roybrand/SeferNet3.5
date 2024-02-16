using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;
using System.Web.SessionState;
using System.Web;
using System.Data;
using SeferNet.BusinessLayer.ObjectDataSource;
using System.Transactions;

using SeferNet.Globals;
using System.Collections;
using Matrix.ExceptionHandling;
using Clalit.Exceptions.ExceptionData;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.SeferNet.EntitiesBL;
using System.Configuration;
using Clalit.SeferNet.Entities;
using SeferNet.BusinessLayer.TemplatesData;


namespace SeferNet.FacadeLayer
{
    public class Facade
    {

        private Facade()
        {

        }

        public static Facade getFacadeObject()
        {
            if (HttpContext.Current.Application["Facade"] == null)
            {
                Facade facade = new Facade();
                HttpContext.Current.Application["Facade"] = facade;
            }
            return HttpContext.Current.Application["Facade"] as Facade;

        }


        #region User Information

        public DataSet GetUserList(int districtCode, int permissionType, string userName, string firstName, string lastName, Int64? userID, string domain, bool? definedInAD, bool? errorReport, bool? trackingNewClinic, bool? ReportRemarksChange)
        {
            DataSet ds = null;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userManager = new UserManager();
            try
            {
                ds = userManager.GetUserList(districtCode, permissionType, userName, firstName, lastName, userID, domain, definedInAD, errorReport, trackingNewClinic, ReportRemarksChange);

            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUserList),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetUserListForExcell(int districtCode, int permissionType, string userName, string firstName, string lastName, Int64? userID, string domain, bool? definedInAD, bool? errorReport, bool? trackingNewClinic, bool? trackingRemarkChanges)
        {
            DataSet ds = null;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userManager = new UserManager();
            try
            {
                ds = userManager.GetUserListForExcell(districtCode, permissionType, userName, firstName, lastName, userID, domain, definedInAD, errorReport, trackingNewClinic, trackingRemarkChanges);

            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUserList),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public UserInfo GetUserInfoFromDB(Int64 userID)
        {
            UserManager userManager = new UserManager();
            return userManager.GetUserInfoFromDB(userID);
        }

        public bool DeleteUser(Int64 userID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userManager = new UserManager();
            try
            {
                userManager.DeleteUser(userID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteUser),
                  new WebPageExtraInfoGenerator());
                return false;
            }
            return true;
        }

        public UserInfo GetAllRelevantPropertiesOfUser(string domain, string userName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userManager = new UserManager();
            UserInfo currentUser = null;
            try
            {
                //currentUser = userManager.GetAllRelevantPropertiesOfUser(domain, userName);
                currentUser = userManager.GetUserPropertiesFromAD(domain, userName);

            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAdminByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return currentUser;
        }

        //public bool AuthenticateUserAgainstDBAndFillSession(string password)
        //{
        //    BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
        //    UserManager userManager = new UserManager();
        //    try
        //    {
        //        Int64 UserID = Convert.ToInt64(password);
        //        return userManager.AuthenticateUserAgainstDBAndFillSession(UserID);
        //    }
        //    catch (Exception ex)
        //    {
        //        ExceptionHandlingManager mgr = new ExceptionHandlingManager();
        //        mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInAuthenticateUserAgainstDB),
        //          new WebPageExtraInfoGenerator());

        //        return false;
        //    }
        //}

        public bool UpdateUserInDB(ref UserInfo userInfo, string updateUserName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userManager = new UserManager();
            try
            {
                userManager.UpdateUserInDB(ref userInfo, updateUserName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateUser),
                  new WebPageExtraInfoGenerator());

                return false;
            }
            return true;
        }

        public bool UpdateUser(UserInfo userInfo, DataTable userPermissions, bool newUser, string updateUserName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userManager = new UserManager();
            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    if (!newUser)
                        userManager.UpdateUserInDB(ref userInfo, updateUserName);
                    else
                        userManager.InsertUser(ref userInfo, updateUserName);

                    userManager.DeleteUserPermissions(userInfo.UserID);
                    userManager.InsertUserPermissions(userPermissions, updateUserName);

                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateUser),
                  new WebPageExtraInfoGenerator());

                return false;
            }
            return true;
        }

        public bool LoadUserInfo(long userID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userManager = new UserManager();
            try
            {
                userManager.LoadUserInfo(userID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUserInfo),
                  new WebPageExtraInfoGenerator());

                return false;
            }
            return true;
        }

        #endregion

        #region Simul table handling

        public bool InsertSimulExceptions(int codeSimul, int seferSherut, string userName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            bool result = true;
            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    clinicManager.InsertSimulExceptions(codeSimul, seferSherut, userName);
                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertSimulExceptions),
                  new WebPageExtraInfoGenerator());

                result = false;
            }
            return result;
        }

        public DataSet GetErrorsListSimulVcSefer(int errorCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetErrorsListSimulVcSefer(errorCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetErrorsListSimulVcSefer),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public void DeleteSimulNewDepts(int deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                clinicMgr.DeleteSimulNewDepts(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteSimulNewDepts),
                  new WebPageExtraInfoGenerator());
            }
        }

        #endregion

        #region Menu

        public bool UpdateMainMenuItem(int itemID, string title, string description, string url, string roles, DataTable dtMainMenuRestrictions)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            MenuManager menuManager = new MenuManager();
            bool result = true;
            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    menuManager.UpdateMainMenuItem(itemID, title, description, url, roles, dtMainMenuRestrictions);
                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                result = false;
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateMainMenuItem),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public int UpdateMainMenu_MoveItem(int itemID, int moveDirection)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            MenuManager menuManager = new MenuManager();
            int result = 0;
            try
            {
                result = menuManager.UpdateMainMenu_MoveItem(itemID, moveDirection);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateMainMenu_MoveItem),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public int DeleteMainMenuItem(int itemID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            MenuManager menuManager = new MenuManager();
            int result = 0;
            try
            {
                result = menuManager.DeleteMainMenuItem(itemID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteMainMenuItem),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public DataSet GetMainMenuData(List<Enums.UserPermissionType> userPermissions, string currentPageName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            MenuManager menuManager = new MenuManager();
            DataSet ds = null;
            try
            {
                ds = menuManager.GetMainMenuData(userPermissions, currentPageName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMainMenuData),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetMainMenuItem(int itemID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            MenuManager menuManager = new MenuManager();
            DataSet ds = null;
            try
            {
                ds = menuManager.GetMainMenuItem(itemID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMainMenuItem),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public bool InsertMainMenuItem(string title, string description, string url, string roles, int parentID, DataTable dtMainMenuRestrictions)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            MenuManager menuManager = new MenuManager();
            bool result = true;

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    menuManager.InsertMainMenuItem(title, description, url, roles, parentID, dtMainMenuRestrictions);
                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                result = false;
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertMainMenuItem),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        #endregion

        #region Dept

        #region Get Methods

        public DataSet getClinicDetails(int deptCode, string RemarkCategoriesForAbsence, string RemarkCategoriesForClinicActivity)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();

            DataSet ds = null;
            try
            {
                ds = clinicMgr.getClinicDetails(deptCode, RemarkCategoriesForAbsence, RemarkCategoriesForClinicActivity);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicDetails),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getDeptSubClinics(int deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();

            DataSet ds = null;
            try
            {
                ds = clinicMgr.getDeptSubClinics(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicDetails),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public int getDeptDistrict(int deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();

            int district = 0;
            try
            {
                district = clinicMgr.getDeptDistrict(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptDistrict),
                  new WebPageExtraInfoGenerator());
            }
            return district;
        }

        public DataSet getClinicList_PagedSorted(ClinicSearchParameters clinicSearchParameters, ClinicSearchParametersForMushlamServices clinicSearchParametersForMushlamServices,
          SearchPagingAndSortingDBParams searchPagingAndSortingDBParams)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            DataSet dsToReturn = null;
            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                dsToReturn = clinicMgr.getClinicList_PagedSorted(clinicSearchParameters, clinicSearchParametersForMushlamServices, searchPagingAndSortingDBParams);

            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();

                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugDuringGetClinicList),
                  new WebPageExtraInfoGenerator());
            }

            return dsToReturn;
        }

        public DataSet getClinicList_PagedSorted(string CodesListForPage_1, string CodesListForPage_2, string CodesListForPage_3, ClinicSearchParameters clinicSearchParameters, ClinicSearchParametersForMushlamServices clinicSearchParametersForMushlamServices,
          SearchPagingAndSortingDBParams searchPagingAndSortingDBParams)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            DataSet dsToReturn = null;
            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                dsToReturn = clinicMgr.getClinicList_PagedSorted(CodesListForPage_1, CodesListForPage_2, CodesListForPage_3, clinicSearchParameters, clinicSearchParametersForMushlamServices, searchPagingAndSortingDBParams);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();

                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugDuringGetClinicList),
                  new WebPageExtraInfoGenerator());
            }

            return dsToReturn;
        }

        public DataSet getClinicList_ForPrinting(ClinicSearchParameters clinicSearchParameters, ClinicSearchParametersForMushlamServices clinicSearchParametersForMushlamServices,
          string foundDeptCodeList)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            DataSet dsToReturn = null;
            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                dsToReturn = clinicMgr.getClinicList_ForPrinting(clinicSearchParameters, clinicSearchParametersForMushlamServices, foundDeptCodeList);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();

                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugDuringGetClinicList),
                  new WebPageExtraInfoGenerator());
            }

            return dsToReturn;
        }

        public DataSet GetDeptRandomOrder()
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            DataSet dsDeptRandomOrder = null;
            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                dsDeptRandomOrder = clinicMgr.GetDeptRandomOrder();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();

                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.GeneralBug),
                  new WebPageExtraInfoGenerator());
            }

            return dsDeptRandomOrder;
        }

        public DataSet getZoomClinic_ForPrinting(int deptCode, bool isInternal, string deptCodesInArea)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            DataSet dsToReturn = null;
            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                dsToReturn = clinicMgr.getZoomClinic_ForPrinting(deptCode, isInternal, deptCodesInArea);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();

                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugDuringGetClinicList),
                  new WebPageExtraInfoGenerator());
            }

            return dsToReturn;
        }

        public DataSet getNewClinicsList(int? DeptCode, string DeptName, DateTime? OpenDateSimul, int? ExistsInSefer)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            return clinicMgr.getNewClinicsList(DeptCode, DeptName, OpenDateSimul, ExistsInSefer);
        }

        public bool InsertNewClinicsList()
        {
            //BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            //return clinicMgr.getNewClinicsList();
            bool result = true;
            ServiceManager bl = new ServiceManager();
            //ClinicManager mng = new ClinicManager();
            EmployeeServiceInDeptBO ESInD = new EmployeeServiceInDeptBO();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForInsertedRecords())
                {
                    clinicMgr.InsertNewClinicsList();
                    //clinicMgr.InsertUnitTypeConvertSimul();

                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertClinicMedicalAspects),
                  new WebPageExtraInfoGenerator());
                result = false;
            }
            return result;
        }

        public DataSet getClinicByName(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.getClinicByName(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getClinicByName_DistrictDepended(string searchStr, string districtCodes, int clinicStatus,
            bool deptCodeLeading, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.getClinicByName_DistrictDepended(searchStr, districtCodes, clinicStatus, deptCodeLeading, agreementTypes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }
        public DataSet getClinicByName_District_City_ClinicType_Status_Depended(string searchStr, string districtCodes, int clinicStatus,
            int cityCode, string clinicType,
            bool deptCodeLeading, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.getClinicByName_District_City_ClinicType_Status_Depended(searchStr, districtCodes, clinicStatus, cityCode, clinicType, deptCodeLeading, agreementTypes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetHealthOfficeDesc(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetHealthOfficeDesc(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetICD9Desc(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetICD9Desc(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetServiceCodesForSalServices(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetServiceCodesForSalServices(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetMedicalAspectsForAutocomplete(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetMedicalAspectsForAutocomplete(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMedicalAspectsForAutocomplete),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetClalitServiceDescription_ByClalitServiceCode(int clalitServiceCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetClalitServiceDescription_ByClalitServiceCode(clalitServiceCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClalitServiceDescription_ByClalitServiceCode),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetMedicalAspectDescription_ByMedicalAspectCode(string medicalAspectCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetMedicalAspectDescription_ByMedicalAspectCode(medicalAspectCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClalitServiceDescription_ByClalitServiceCode),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetClalitServicesForAutocomplete(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetClalitServicesForAutocomplete(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClalitServicesForAutocomplete),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getAdminByName_DistrictDepended(string searchStr, string districtCodes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.getAdminByName_DistrictDepended(searchStr, districtCodes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAdminByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetDeptDetailsForUpdate(int p_deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();

            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetDeptDetailsForUpdate(p_deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptDetailsForUpdate),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetDeptNamesForUpdate(int p_deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();

            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetDeptNamesForUpdate(p_deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptNamesForUpdate),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public string GetDefaultDeptNameForIndependentClinic(int p_deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();

            string deptName = string.Empty;
            try
            {
                deptName = clinicMgr.GetDefaultDeptNameForIndependentClinic(p_deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptNamesForUpdate),
                  new WebPageExtraInfoGenerator());
            }
            return deptName;
        }

        public DataSet GetDeptDetailsForPopUp(int p_deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();

            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetDeptDetailsForPopUp(p_deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptDetailsForPopUp),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetDeptFirstPhone(int deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            phoneHandler phHandler = new phoneHandler();
            DataSet ds = null;
            try
            {
                ds = phHandler.GetDeptFirstPhone(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptFirstPhone),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public void GetUnitRemarks(ref DataSet p_ds, int UnitID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            try
            {
                rem.GetUnitRemarks(ref p_ds, UnitID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUnitRemarks),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetClinicByName_AdministrationDepended(string prefixText, int administrationCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetClinicByName_AdministrationDepended(prefixText, administrationCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_AdministrationDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetNewClinic(int deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetNewClinic(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetNewClinic),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public List<View_AllDeptAddressAndPhone> GetClinicsByAdministration(int administrationCode)
        {
            View_DeptAddressAndPhonesBL bl = new View_DeptAddressAndPhonesBL();
            List<View_AllDeptAddressAndPhone> list = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                list = bl.GetClinicsByAdministration(administrationCode);

                BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptsByAdminWithDetails),
                  new WebPageExtraInfoGenerator());
            }

            return list;
        }

        public bool IsDeptPermitted(int p_deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userMgr = new UserManager();
            bool result = false;

            try
            {
                result = userMgr.DeptPermittedForUser(p_deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInIsDeptPermitted),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        /// <summary>
        /// get all depts that fit the required params. "-1" value means not required
        /// </summary>
        /// <param name="deptCode"></param>
        /// <param name="cityCode"></param>
        /// <param name="districtCode"></param>
        /// <param name="typeUnitCode"></param>
        /// <returns>data set of relevant depts</returns>
        public DataSet GetDeptListByParams(int deptCode, string deptName, int cityCode, int districtCode, int unitTypeCode)
        {
            DataSet ds = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                DeptBO bo = new DeptBO();

                ds = bo.GetDeptListByParams(deptCode, deptName, cityCode, districtCode, unitTypeCode);

            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptsListByParams),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public Dept GetDeptGeneralBelongings(int deptCode)
        {
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                DeptBO bo = new DeptBO();

                return bo.GetDeptGeneralBelongings(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptBelonging),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }

        public Dept GetDeptGeneralBelongingsByEmployee(int deptEmployeeID)
        {
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                DeptBO bo = new DeptBO();

                return bo.GetDeptGeneralBelongingsByDeptEmployee(deptEmployeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptBelonging),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }

        #endregion

        #region Update Methods

        public bool UpdateDeptDetailsTransaction(int deptCode, string updateUser, long updateUserID, object[] inputParams, string deptHandicappedFacilities,
            DataTable dtDeptPhones, DataTable dtDeptFaxes, DataTable dtDeptDirectPhones, DataTable dtDeptWhatsApp, double coordinateX, double coordinateY, double XLongitude, double YLatitude, bool getCoordXYfromWServiceOK, bool needToUpdateCoordinates, bool updateCoordinatesManually, string locationLink,
            bool phonesHasChanged, bool addressHasChanged)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            bool result = true;

            ClinicManager clinicMgr = new ClinicManager();
            UserManager userManager = new UserManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    clinicMgr.UpdateDeptDetailsTransaction(deptCode, updateUser, inputParams, deptHandicappedFacilities,
                    dtDeptPhones, dtDeptFaxes, dtDeptDirectPhones, dtDeptWhatsApp, coordinateX, coordinateY, XLongitude, YLatitude, getCoordXYfromWServiceOK, needToUpdateCoordinates, updateCoordinatesManually, locationLink);

                    tranScope.Complete();
                }

                userManager.Insert_LogChange((int)Enums.ChangeType.ClinicDetailes_Update, updateUserID, deptCode, null, null, null, null, null, null);

                if (phonesHasChanged)
                    userManager.Insert_LogChange((int)Enums.ChangeType.ClinicPhones_Update, updateUserID, deptCode, null, null, null, null, null, null);

                if (addressHasChanged)
                    userManager.Insert_LogChange((int)Enums.ChangeType.ClinicAddress_Update, updateUserID, deptCode, null, null, null, null, null, null);

                UpdateEmployeeInClinicPreselected(null, deptCode, null);
            }
            catch (Exception ex)
            {
                result = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateDeptDetailsTransaction),
                  new WebPageExtraInfoGenerator());
            }

            return result;
        }

        public bool UpdateDeptNames(int deptCode, int deptLevel, int? displayPriority, DataTable deptNames, long updateUser, ref string errorMessage)
        {
            bool result = true;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            UserManager userManager = new UserManager();
            EmployeeManager employeeManager = new EmployeeManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    clinicMgr.UpdateDeptNames(deptCode, deptLevel, displayPriority, deptNames, ref errorMessage);

                    tranScope.Complete();
                }

                userManager.Insert_LogChange((int)Enums.ChangeType.ClinicDetailes_Update, updateUser, deptCode, null, null, null, null, null, null);

                employeeManager.UpdateEmployeeInClinicPreselected(null, deptCode, null);
            }
            catch (Exception ex)
            {
                result = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateDeptNamesTransaction),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public bool UpdateDeptNamesOnly(int deptCode, DataTable deptNames, long updateUser, ref string errorMessage)
        {
            bool result = true;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            UserManager userManager = new UserManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    clinicMgr.UpdateDeptNamesOnly(deptCode, deptNames, ref errorMessage);

                    tranScope.Complete();
                }

                userManager.Insert_LogChange((int)Enums.ChangeType.ClinicDetailes_Update, updateUser, deptCode, null, null, null, null, null, null);
            }
            catch (Exception ex)
            {
                result = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateDeptNamesTransaction),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public bool UpdateDeptRemarks(ref DataTable p_TblRemarks, int deptCode, string updateUser)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            UserManager userManager = new UserManager();

            try
            {
                rem.UpdateDeptRemarks(ref p_TblRemarks);

                if (p_TblRemarks.Select("Deleted = 1").Length > 0)
                {
                    DataRow[] rows = p_TblRemarks.Select("Deleted = 1");
                    foreach (DataRow dr in rows)
                    {
                        userManager.Insert_LogChange((int)Enums.ChangeType.ClinicRemarks_Delete, userManager.GetUserIDFromSession(), deptCode, null, null, null, Convert.ToInt32(dr["RemarkID"]), null, dr["RemarkText"].ToString());
                    }
                }

                //userManager.Insert_LogTeudPeulot((int)Enums.ChangeType.ClinicRemarks_Update, updateUser, deptCode, null, null, null, null, null);
                return true;
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateUnitRemarks),
                  new WebPageExtraInfoGenerator());

                return false;
            }
        }

        public bool UpdateSalServiceInternetDetails(int serviceCode, string serviceNameForInternet, string serviceDetails, string serviceBrief,
            string serviceDetailsInternet, byte queueOrder, byte showServiceInInternet, byte updateComplete, string updateUser,
            byte diagnosis, byte treatment, int salOrganCode, string synonyms, string refund)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            bool result = true;

            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    clinicMgr.UpdateSalServiceInternetDetails(serviceCode, serviceNameForInternet, serviceDetails,
                        serviceBrief, serviceDetailsInternet, queueOrder, showServiceInInternet, updateComplete, updateUser,
                        diagnosis, treatment, salOrganCode, synonyms, refund);

                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                result = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateDeptDetailsTransaction),
                  new WebPageExtraInfoGenerator());

            }
            return result;
        }


        #endregion

        #region Insert Methods

        public void SendNewClinicMailReport(int deptCode, string Url)
        {
            ReportToUsers reportToUsers = new ReportToUsers();

            DataSet ds = GetDeptDetailsForPopUp(deptCode);

            string deptName = ds.Tables[0].Rows[0]["deptName"].ToString();

            reportToUsers.SendNewClinicMailReport(deptCode, deptName, Url);
        }

        public void SendReportClinicNameChange(int deptCode, string Url, string MailTo, string UserName)
        {
            ReportToUsers reportToUsers = new ReportToUsers();

            DataSet ds = GetDeptDetailsForPopUp(deptCode);

            string deptName = ds.Tables[0].Rows[0]["deptName"].ToString();
            string districtName = ds.Tables[0].Rows[0]["districtName"].ToString();
            string UnitTypeName = ds.Tables[0].Rows[0]["UnitTypeName"].ToString();

            reportToUsers.SendReportClinicNameChange(MailTo, Url, deptCode, deptName, districtName, UnitTypeName, UserName);
        }
        public void SendReportClinicUnitTypeChange(int deptCode, string previeusUnitTypeName, string Url, string MailTo, string UserName)
        {
            ReportToUsers reportToUsers = new ReportToUsers();

            DataSet ds = GetDeptDetailsForPopUp(deptCode);

            string deptName = ds.Tables[0].Rows[0]["deptName"].ToString();
            string districtName = ds.Tables[0].Rows[0]["districtName"].ToString();
            string UnitTypeName = ds.Tables[0].Rows[0]["UnitTypeName"].ToString();

            reportToUsers.SendReportClinicUnitTypeChange(MailTo, Url, deptCode, deptName, districtName, UnitTypeName, previeusUnitTypeName, UserName);
        }

        public void SendReportClinicNameChangeDueToTypeChange(int deptCode, string previeusUnitTypeName, string Url, string MailTo, string UserName)
        {
            ReportToUsers reportToUsers = new ReportToUsers();

            DataSet ds = GetDeptDetailsForPopUp(deptCode);

            string deptName = ds.Tables[0].Rows[0]["deptName"].ToString();
            string districtName = ds.Tables[0].Rows[0]["districtName"].ToString();
            string UnitTypeName = ds.Tables[0].Rows[0]["UnitTypeName"].ToString();

            reportToUsers.SendReportClinicNameChangeDueToTypeChange(MailTo, Url, deptCode, deptName, districtName, UnitTypeName, previeusUnitTypeName, UserName);
        }


        public void SendReportClinicActivation(int deptCode, string Url, string MailTo, string UserName)
        {
            ReportToUsers reportToUsers = new ReportToUsers();

            DataSet ds = GetDeptDetailsForPopUp(deptCode);

            string deptName = ds.Tables[0].Rows[0]["deptName"].ToString();
            string districtName = ds.Tables[0].Rows[0]["districtName"].ToString();
            string UnitTypeName = ds.Tables[0].Rows[0]["UnitTypeName"].ToString();

            reportToUsers.SendReportClinicActivation(MailTo, Url, deptCode, deptName, districtName, UnitTypeName, UserName);
        }

        public void SendReportAboutFreeClinicRemark(int deptCode, string UrlToClinic, string RemarkTextNotFormatted, string UserName, string userEmail)
        {
            ReportToUsers reportToUsers = new ReportToUsers();

            DataSet ds = GetDeptDetailsForPopUp(deptCode);

            RemarkManager remarkManager = new RemarkManager();
            string RemarkText = remarkManager.getFormatedRemark(RemarkTextNotFormatted);

            string deptName = ds.Tables[0].Rows[0]["deptName"].ToString();
            string districtName = ds.Tables[0].Rows[0]["districtName"].ToString();
            string UnitTypeName = ds.Tables[0].Rows[0]["UnitTypeName"].ToString();

            string MailTo = string.Empty;
            // get mail list
            UserManager userManager = new UserManager();
            MailTo = userManager.getUserMailesToSendReportAboutClinicRemark(deptCode).Tables[0].Rows[0]["EmailList"].ToString();

            // remove sender's email from the list "MailTo"
            MailTo = MailTo.Replace(userEmail + ';', "");

            //if (MailTo.Trim(';') != userEmail)
            if (MailTo.Trim(';') != String.Empty) // if there is someting left in the list - then send mail 
            { 
                reportToUsers.SendReportAboutFreeClinicRemark(MailTo, UrlToClinic, deptCode, deptName, RemarkText, UserName, userEmail);            
            }
        }


        public void ApplyForChangeStatusToActive(int deptCode, string Url, string MailTo, string UserName, string deptName, string districtName, string unitTypeName, string userMail)
        {
            ReportToUsers reportToUsers = new ReportToUsers();

            //DataSet ds = GetDeptDetailsForPopUp(deptCode);

            //string deptName = ds.Tables[0].Rows[0]["deptName"].ToString();
            //string districtName = ds.Tables[0].Rows[0]["districtName"].ToString();
            //string UnitTypeName = ds.Tables[0].Rows[0]["UnitTypeName"].ToString();

            reportToUsers.ApplyForChangeStatusToActive(MailTo, Url, deptCode, deptName, districtName, unitTypeName, UserName, userMail);
        }
        public void ApplyForChangeDIC_remarks(string MailTo, string Url, string UserName, string userMail)
        {
            ReportToUsers reportToUsers = new ReportToUsers();

            reportToUsers.ApplyForChangeDIC_remarks(MailTo, Url, UserName, userMail);
        }

        public int InsertNewDeptTransaction(int deptCode, string updateUser, double coordinateX, double coordinateY, double XLongitude, double YLatitude, string SPSlocationLink, ref string errorMessage)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            int ErrorStatus = 0;
            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    ErrorStatus = clinicMgr.InsertNewDept(deptCode, updateUser, coordinateX, coordinateY, XLongitude, YLatitude, SPSlocationLink, ref errorMessage);
                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertNewDeptTransaction),
                  new WebPageExtraInfoGenerator());

                ErrorStatus = 1;
            }

            return ErrorStatus;
        }

        public int UpdateDeptToCommunity(int deptCode, string updateUser, ref string errorMessage)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            int ErrorStatus = 0;
            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    clinicMgr.UpdateDeptToCommunity(deptCode, updateUser, ref errorMessage);
                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertNewDeptTransaction),
                  new WebPageExtraInfoGenerator());

                ErrorStatus = 1;
            }
            return ErrorStatus;
        }

        #endregion

        #endregion

        #region EmployeeServices

        public DataSet GetEmployeeServicePhones(int? x_Dept_Employee_ServiceID, int? phoneType, bool? simulateCascadeUpdate)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();

            DataSet ds = null;
            try
            {
                return clinicManager.GetEmployeeServicePhones(x_Dept_Employee_ServiceID, phoneType, simulateCascadeUpdate);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeServicePhones),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }


        public bool UpdateEmployeeServicePhones(int x_Dept_Employee_ServiceID, DataTable phonesDt, bool cascadeUpdate, string updateUser)
        {
            bool result = true;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForInsertedRecords())
                {
                    clinicManager.UpdateEmployeeServicePhones(x_Dept_Employee_ServiceID, phonesDt, cascadeUpdate, updateUser);
                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                result = false;
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertEmployeeServicePhones),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public void CascadeEmployeeServiceQueueOrderFromDept(int x_Dept_Employee_ServiceID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeServiceInDeptBO bo = new EmployeeServiceInDeptBO();
            try
            {
                bo.CascadeEmployeeServiceQueueOrderFromDept(x_Dept_Employee_ServiceID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeeServiceQueueOrder),
                  new WebPageExtraInfoGenerator());
            }
        }

        public bool DeleteEmployeeServicePhones(int? x_Dept_Employee_ServiceID, int? phoneType)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            try
            {
                clinicManager.DeleteEmployeeServicePhones(x_Dept_Employee_ServiceID, phoneType);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteEmployeeServicePhones),
                  new WebPageExtraInfoGenerator());
                return false;
            }
            return true;
        }

        #endregion

        #region Employee

        public DataSet GetDoctorByFirstNameAndSector(string p_SearchStr, string p_SearchStr_LastName,
                                                int isOnlyDoctorConnectedToClinic, int sector, Dictionary<Enums.SearchMode, bool> membershipValues)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();

            DataSet ds = null;
            try
            {
                return doctorMgr.GetDoctorByFirstNameAndSector(p_SearchStr, p_SearchStr_LastName,
                                                    isOnlyDoctorConnectedToClinic, sector, membershipValues);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDoctorByFirstName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetDoctorByLastNameAndSector(string p_SearchStr, string p_SearchStr_LastName,
                                                int isOnlyDoctorConnectedToClinic, int sector, Dictionary<Enums.SearchMode, bool> membershipValues)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();

            DataSet ds = null;
            try
            {
                ds = doctorMgr.GetDoctorByLastNameAndSector(p_SearchStr, p_SearchStr_LastName,
                                                    isOnlyDoctorConnectedToClinic, sector, membershipValues);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDoctorByLastName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetEmployeeSectors(int isDoctor)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.GetEmployeeSectors(isDoctor);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeSectors),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getDoctorList_PagedSorted(DoctorSearchParameters doctorSearchParameters,
            SearchPagingAndSortingDBParams searchPagingAndSortingDBParams)
        {
            //log to db
            doctorSearchParameters.IsGetEmployeesReceptionInfo = false;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.getDoctorList_PagedSorted(doctorSearchParameters,
               searchPagingAndSortingDBParams); //iscall reception info 0
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDoctorList_PagedSorted),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getDoctorList_PagedSorted(string CodesListForPage, int IsOrderDescending, bool isGetEmployeesReceptionHours)
        {
            //log to db
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.getDoctorList_PagedSorted(CodesListForPage, IsOrderDescending, isGetEmployeesReceptionHours);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDoctorList_PagedSorted),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public EmployeeDetailsDataTemplateInfo GetDoctorTemplate(DoctorSearchParameters doctorSearchParameters,
          SearchPagingAndSortingDBParams searchPagingAndSortingDBParams)
        {
            doctorSearchParameters.IsGetEmployeesReceptionInfo = true;
            EmployeeDetailsDataTemplateInfo template = null;
            //log to db
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.getDoctorList_PagedSorted(doctorSearchParameters,
                searchPagingAndSortingDBParams);

                template = new EmployeeDetailsDataTemplateInfo(ds);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDoctorList_PagedSorted),
                  new WebPageExtraInfoGenerator());
            }
            return template;
        }


        public void GetEmployeeGeneralData(ref DataSet p_ds, int p_EmployeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();

            try
            {
                doctorMgr.GetEmployeeGeneralData(ref p_ds, p_EmployeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeGeneralData),
                  new WebPageExtraInfoGenerator());
            }

        }

        public DataSet GetEmployeeListForSpotting(string firstName, string lastName, int licenseNumber, long employeeID, int deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.GetEmployeeListForSpotting(firstName, lastName, licenseNumber, employeeID, deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeListForSpotting),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetEmployeeList(string firstName, string lastName, int licenseNumber, long employeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.GetEmployeeList(firstName, lastName, licenseNumber, employeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeListForSpotting),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetEmployeeListForSpotting_MF(string firstName, string lastName, int licenseNumber, int employeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.GetEmployeeListForSpotting_MF(firstName, lastName, licenseNumber, employeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeListForSpotting_MF),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetEmployeeByLastNameFrom226(string lastName, string firstName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.GetEmployeeByLastNameFrom226(lastName, firstName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeListForSpotting),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetEmployeeByFirstNameFrom226(string firstName, string lastName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.GetEmployeeByFirstNameFrom226(firstName, lastName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeListForSpotting),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getDoctorDetails(Int64 employeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.getDoctorDetails(employeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDoctorDetails),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getDoctorNameList(string SearchStrFirstName, string SearchStrLastName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.getDoctorNameList(SearchStrFirstName, SearchStrLastName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetgetDoctorNameList),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetEmployeeInDeptDetails(int deptEmployeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            DoctorsInClinicBO bo = new DoctorsInClinicBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetEmployeeInDeptDetails(deptEmployeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeInDeptDetails),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public int InsertDoctorInClinic(int deptCode, long employeeID,
            int agreementType, string updateUser, bool active, string email, bool showEmailInInternet)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            int DeptEmployeeID = 0;
            ClinicManager clinicMgr = new ClinicManager();
            UserManager userManager = new UserManager();
            EmployeeManager employeeManager = new EmployeeManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForInsertedRecords())
                {
                    DeptEmployeeID = clinicMgr.InsertDoctorInClinic(deptCode, employeeID, agreementType, updateUser, active);


                    tranScope.Complete();
                }

                employeeManager.UpdateEmployeeInClinicPreselected(employeeID, deptCode, DeptEmployeeID);

                userManager.Insert_LogChange((int)Enums.ChangeType.EmployeeInClinic_Add, userManager.GetUserIDFromSession(), deptCode, null, DeptEmployeeID, null, null, null, null);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertDoctorInClinic),
                  new WebPageExtraInfoGenerator());
            }
            return DeptEmployeeID;
        }

        public DataSet GetDeptEmployeeID(int deptCode, long employeeID)
        {
            DataSet ds = new DataSet();
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            ClinicManager clinicMgr = new ClinicManager();
            try
            {
                ds = clinicMgr.GetDeptEmployeeID(deptCode, employeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.GeneralBug),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetClinicTeamAgreementsInDept(int deptCode)
        {
            DataSet ds = new DataSet();
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            ClinicManager clinicMgr = new ClinicManager();
            try
            {
                ds = clinicMgr.GetClinicTeamAgreementsInDept(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.GeneralBug),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public bool InsertEmployeeIntoSefer(int employeeID, string lastName, string firstName,
            int employeeSectorCode, int primaryDistrict, bool isVirtualDoctor, string updateUser, int gender, int profLicence, bool isDental, ref Int64 NewEmployeeID)
        {
            bool result = true;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            EmployeeManager employeeManager = new EmployeeManager();
            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForInsertedRecords())
                {
                    doctorMgr.InsertEmployeeIntoSefer(employeeID, lastName, firstName, employeeSectorCode, primaryDistrict, isVirtualDoctor, updateUser, gender, profLicence, isDental, ref NewEmployeeID);

                    tranScope.Complete();
                }

                employeeManager.UpdateEmployeeInClinicPreselected(employeeID, null, null);
            }
            catch (Exception ex)
            {
                result = false;
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertEmployeeIntoSefer),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public bool IsEmployeeExistsInEmployee(long employeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeBO empBO = new EmployeeBO();

            bool rez = false;
            try
            {
                rez = empBO.IsEmployeeExistsInEmployee(employeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.GeneralBug),
                  new WebPageExtraInfoGenerator());
            }
            return rez;
        }

        public DataSet GetEmployeeClinicTeam(int deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager mng = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = mng.GetEmployeeClinicTeam(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.GeneralBug),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public void UpdateEmployeePositionsInDept(int employeeID, int deptCode, int deptEmployeeID, string seperatedValues, string userName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeePositionsBO bo = new EmployeePositionsBO();
            UserManager userManager = new UserManager();
            try
            {
                bo.UpdateEmployeePositionInDept(employeeID, deptCode, seperatedValues, userName);

                userManager.Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicPosition_Update, userManager.GetUserIDFromSession(), deptCode, null, deptEmployeeID, null, null, null, null);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeePositionsInDept),
                  new WebPageExtraInfoGenerator());
            }
        }
        public void UpdateEmployeeProfessionLicence(long employeeID, int profLicence, string userName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeePositionsBO bo = new EmployeePositionsBO();
            try
            {
                bo.UpdateEmployeeProfessionLicence(employeeID, profLicence, userName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeePositionsInDept),
                  new WebPageExtraInfoGenerator());
            }
        }

        public bool UpdateEmployeeServicesInDept(int deptEmployeeID, string seperatedValues, string userName, int deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeServiceInDeptBO bo = new EmployeeServiceInDeptBO();

            try
            {
                bo.UpdateEmployeeServicesInDept(deptEmployeeID, seperatedValues, userName);
                return true;
                //DBActionNotification.RaiseOnDBAction_targeted((int)Enums.Target.EmployeeClinicServices_Update, 0, 0, 0, deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeeServicesInDept),
                  new WebPageExtraInfoGenerator());
                return false;
            }
        }

        public void GetEmployeeDepts(ref DataSet p_ds, long p_EmployeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            try
            {
                rem.GetEmployeeDepts(ref p_ds, p_EmployeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeDepts),
                  new WebPageExtraInfoGenerator());
            }
        }

        public bool InsertEmployeeRemarks(int employeeID, string remarkText, int dicRemarkId, string delimitedDepts,
                                            bool displayInInternet, DateTime? validFrom, DateTime? validTo, DateTime? activeFrom, string updateUser)
        {
            try
            {
                EmployeeRemarksBO bo = new EmployeeRemarksBO();

                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                bo.InsertEmployeeRemarks(employeeID, remarkText, dicRemarkId, delimitedDepts,
                                                                                    displayInInternet, validFrom, validTo, activeFrom, updateUser);

                BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());

                return true;
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager exMan = new ExceptionHandlingManager();
                exMan.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertEmployeeRemarks),
                                new WebPageExtraInfoGenerator());
                return false;
            }
        }

        public bool UpdateEmployeeRemarks(ref DataTable tblCurrent, ref DataTable tblFuture, ref DataTable tblHistoric)
        {
            bool retValue = true;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    rem.UpdateEmployeeRemarks(ref tblCurrent);
                    rem.UpdateEmployeeRemarks(ref tblFuture);
                    rem.UpdateEmployeeRemarks(ref tblHistoric);
                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                retValue = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeeRemarks),
                  new WebPageExtraInfoGenerator());
            }

            return retValue;
        }
        public bool UpdateEmployeeServiceRemarks(ref DataTable tblCurrent, ref DataTable tblFuture, ref DataTable tblHistoric)
        {
            bool retValue = true;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    rem.UpdateEmployeeServiceRemarks(ref tblCurrent);
                    rem.UpdateEmployeeServiceRemarks(ref tblFuture);
                    rem.UpdateEmployeeServiceRemarks(ref tblHistoric);
                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                retValue = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeeRemarks),
                  new WebPageExtraInfoGenerator());
            }

            return retValue;
        }

        public bool UpdateEmployeeAndPhones(long employeeID, int degreeCode, string firstName, string lastName,
                                                  int EmployeeSectorCode, int sex, int primaryDistrict, string email,
                                                  bool showEmailInInternet, Phone homePhone, Phone cellPhone)
        {
            bool retValue = true;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    EmployeeManager mgr = new EmployeeManager();

                    mgr.UpdateEmployeeAndPhones(employeeID, degreeCode, firstName, lastName,
                    EmployeeSectorCode, sex, primaryDistrict, email, showEmailInInternet, homePhone, cellPhone);

                    tranScope.Complete();
                }

                UpdateEmployeeInClinicPreselected(employeeID, null, null);
            }
            catch (Exception ex)
            {
                retValue = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeeAndMainChildren),
                  new WebPageExtraInfoGenerator());
            }

            return retValue;
        }

        public void IsVirtualDoctorOrMedicalTeam(long employeeID, ref bool isVirtualDoctor, ref bool isMedicalTeam)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeBO bo = new EmployeeBO();
            try
            {
                bo.IsVirtualDoctorOrMedicalTeam(employeeID, ref isVirtualDoctor, ref isMedicalTeam);

                BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());

            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInIsVirtualDoctorOrMedicalTeam),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetEmployeeDeptsByText(string prefixText, long employeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeBO bo = new EmployeeBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetEmployeeDeptsByText(prefixText, employeeID); ;
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetPhonePrefixListAll),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        #endregion

        #region Receptions

        public DataSet getClinicServices(int deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.getClinicServices(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicReceptionAndRemarks),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getClinicReceptionAndRemarks(int deptCode, DateTime expirationDate, string serviceCodes, string remarkCategoriesForAbsence, string RemarkCategoriesForClinicActivity)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.getClinicReceptionAndRemarks(deptCode, expirationDate, serviceCodes, remarkCategoriesForAbsence, RemarkCategoriesForClinicActivity);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicReceptionAndRemarks),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public void GetDeptReceptions(ref DataSet p_ds, int p_DeptCode, int p_ReceptionHoursType)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            SeferNet.BusinessLayer.WorkFlow.ClinicManager doc = new ClinicManager();
            try
            {
                doc.GetDeptReceptions(ref p_ds, p_DeptCode, p_ReceptionHoursType);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptReceptions),
                  new WebPageExtraInfoGenerator());
            }
        }

        public bool UpdateDeptReceptionsTransaction(int deptCode, int receptionHoursTypeID, DataTable dtDeptReceptions, string updateUser)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            bool result = true;
            ClinicManager clinicMgr = new ClinicManager();
            UserManager userManager = new UserManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    clinicManager.UpdateDeptReceptionsTransaction(deptCode, receptionHoursTypeID, dtDeptReceptions);

                    tranScope.Complete();
                }

                userManager.Insert_LogChange((int)Enums.ChangeType.ClinicReceptionHoursAndRemarks_Update, userManager.GetUserIDFromSession(), deptCode, null, null, null, null, null, null);
            }
            catch (Exception ex)
            {
                result = false;
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateDeptReceptionsTransaction),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public bool UpdateDeptReception_TemporarilyClosed(int deptCode, string receptionDays, DateTime dateFrom, DateTime dateTo, string updateUser)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            bool result = true;
            ClinicManager clinicMgr = new ClinicManager();
            UserManager userManager = new UserManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    clinicManager.UpdateDeptReception_TemporarilyClosed(deptCode, receptionDays, dateFrom, dateTo, updateUser);

                    tranScope.Complete();
                }

                userManager.Insert_LogChange((int)Enums.ChangeType.ClinicReceptionHoursAndRemarks_Update, userManager.GetUserIDFromSession(), deptCode, null, null, null, null, null, null);
            }
            catch (Exception ex)
            {
                result = false;
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateDeptReceptionsTransaction),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public DataSet WeekDaysNotInDateRange(string WeekDays, DateTime dateFrom, DateTime dateTo)
        {
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;

            ds = clinicManager.WeekDaysNotInDateRange(WeekDays, dateFrom, dateTo);
            return ds;
        }

        public DataSet getEmployeeReceptionAndRemarks(int deptEmployeeID, string serviceCode, DateTime expirationDate)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.getEmployeeReceptionAndRemarks(deptEmployeeID, serviceCode, expirationDate);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeReceptionAndRemarks),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetEmployeeReceptionAfterExpiration(int employeeID, DateTime expirationDate)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            doctorManager doctorMgr = new doctorManager();
            DataSet ds = null;
            try
            {
                ds = doctorMgr.GetEmployeeReceptionAfterExpiration(employeeID, expirationDate);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeReceptionAfterExpiration),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public bool UpdateEmployeeReceptionsAndDetailesInDept(long employeeID, int deptCode, int deptEmployeeID,
                                                int agreementType_Old, int agreementType_New, bool receiveGuests, DataTable dt, DataTable phoneDt, bool showPhonesFromDept, string updateUser)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            bool result = true;
            bool isVirtualDoctor = false;
            bool isMedicalTeam = false;

            DoctorHoursBO dhBO = new DoctorHoursBO();
            DeptEmoloyeePhonesBO defBO = new DeptEmoloyeePhonesBO();
            DoctorsInClinicBO dincBO = new DoctorsInClinicBO();
            EmployeeBO empBO = new EmployeeBO();
            StatusBO statusBO = new StatusBO();
            EmployeeManager employeeManager = new EmployeeManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    // email option is obsolete meanwhile - so we pass string.empty
                    dincBO.updateDoctorsInClinic(deptCode, employeeID, agreementType_Old, agreementType_New, receiveGuests, updateUser, showPhonesFromDept);
                    empBO.IsVirtualDoctorOrMedicalTeam(employeeID, ref isVirtualDoctor, ref isMedicalTeam);

                    if (dt != null && dt.Rows.Count > 0)
                        dhBO.UpdateEmployeeReceptions(employeeID, dt, updateUser, isMedicalTeam, isVirtualDoctor, deptCode, agreementType_Old, agreementType_New);

                    //if (phoneDt != null && phoneDt.Rows.Count > 0)
                    if (phoneDt != null)
                        defBO.InsertDeptEmployeePhones(deptEmployeeID, phoneDt, updateUser);

                    statusBO.UpdateEmployeeInDeptStatusWhenNoProfessions(employeeID, deptCode, updateUser);

                    tranScope.Complete();
                }

                employeeManager.UpdateEmployeeInClinicPreselected(employeeID, deptCode, deptEmployeeID);
            }
            catch (Exception ex)
            {
                result = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeeReceptionsAndDetailesInDept),
                  new WebPageExtraInfoGenerator());
            }

            return result;
        }

        public bool UpdateEmployeeReceptions(long employeeID, DataTable dt, string updateUser)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            bool result = true;

            DoctorHoursBO dhBO = new DoctorHoursBO();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    dhBO.UpdateEmployeeReceptions(employeeID, dt, updateUser);

                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                result = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeeReceptions),
                  new WebPageExtraInfoGenerator());
            }

            return result;
        }

        public void GetEmployeeReceptions(ref DataSet p_ds, long p_EmployeeCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            try
            {
                GetEmployeeReceptions(ref p_ds, p_EmployeeCode, null);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeReceptions),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void GetEmployeeReceptions(ref DataSet p_ds, long p_EmployeeCode, int? p_deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

            SeferNet.BusinessLayer.WorkFlow.doctorManager doc = new doctorManager();
            try
            {
                doc.GetEmployeeReceptions(ref p_ds, p_EmployeeCode, p_deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeReceptions),
                  new WebPageExtraInfoGenerator());
            }
        }


        #endregion

        #region Unit Types

        public DataSet GetUnitTypesExtended(string selectedValuesList, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            DeptBO bo = new DeptBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetUnitTypesExtended(selectedValuesList, agreementTypes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetObjectTypesExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetUnitTypeWithAttributes(int unitTypeCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.GetUnitTypeWithAttributes(unitTypeCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUnitTypeWithAttributes),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getUnitTypesByName(string p_searchString, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.getUnitTypesByName(p_searchString, agreementTypes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUnitTypesByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getUnitTypesByName_Extended(string p_searchString, Dictionary<Enums.SearchMode, bool> agreementTypes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.getUnitTypesByName_Extended(p_searchString, agreementTypes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUnitTypesByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }
        public DataSet getSubUnitTypesWithSubstituteNames()
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.getSubUnitTypesWithSubstituteNames();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSubUnitTypesWithSubstituteNames),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public void DeleteSubUnitTypeSubstituteName(int unitTypeCode, int subUnitTypeCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();

            try
            {
                clinicManager.DeleteSubUnitTypeSubstituteName(unitTypeCode, subUnitTypeCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteSubUnitTypeSubstituteName),
                  new WebPageExtraInfoGenerator());
            }

        }

        public bool InsertSubUnitTypeSubstituteName(int unitTypeCode, int subUnitTypeCode, string substituteName, string updateUser)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            bool result = false;

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForInsertedRecords())
                {
                    clinicManager.DeleteSubUnitTypeSubstituteName(unitTypeCode, subUnitTypeCode);
                    clinicManager.InsertSubUnitTypeSubstituteName(unitTypeCode, subUnitTypeCode, substituteName, updateUser);

                    tranScope.Complete();
                    tranScope.Dispose();
                    result = true;
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertSubUnitTypeSubstituteName),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        #endregion

        #region Events

        public DataSet GetEventsExtended(string selectedValuesList)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            DeptBO bo = new DeptBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetEventsExtended(selectedValuesList);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEventsExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;

        }

        public DataSet GetDeptEventForPopUp(int deptEventID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetDeptEventForPopUp(deptEventID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptEventForPopUp),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetDeptEventForUpdate(int deptEventID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetDeptEventForUpdate(deptEventID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptEventForUpdate),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public bool UpdateDeptEventTransaction(int deptCode, string updateUser, object[] inputParamsDeptEvent,
                                                DataTable dtDeptEventMeetings, DataTable dtDeptEventPhones, bool phonesFromDept,
                                                ref string errorMessage)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            bool result = true;
            ClinicManager clinicMgr = new ClinicManager();
            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    clinicMgr.UpdateDeptEventTransaction(deptCode, inputParamsDeptEvent,
                        dtDeptEventMeetings, dtDeptEventPhones, phonesFromDept);

                    tranScope.Complete();
                    tranScope.Dispose();
                }
            }
            catch (Exception ex)
            {
                result = false;

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateDeptEventTransaction),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        public int InsertDeptEvent(int deptCode, object[] inputParamsDeptEvent,
                                        DataTable dtDeptEventMeetings, DataTable dtDeptEventPhones, bool cascadePhonesFromDept)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            int EventID = 0;
            ClinicManager clinicMgr = new ClinicManager();
            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    EventID = clinicMgr.InsertDeptEvent(deptCode, inputParamsDeptEvent,
                        dtDeptEventMeetings, dtDeptEventPhones, cascadePhonesFromDept);

                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertDeptEventTransaction),
                  new WebPageExtraInfoGenerator());
            }
            return EventID;
        }

        public int DeleteDeptEvent(int deptEventID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            int deletedRecordsCount = 0;
            try
            {
                deletedRecordsCount = clinicMgr.DeleteDeptEvent(deptEventID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteDeptEvent),
                  new WebPageExtraInfoGenerator());
            }
            return deletedRecordsCount;
        }


        public void AddAttachedFileToDeptEvent(int deptEventID, int deptCode, int eventCode, string sourceFilePath,
                                                                                                string savedFileName)
        {
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                DeptEventsBO bo = new DeptEventsBO();
                bo.AttachFileToDeptEvent(deptEventID, deptCode, eventCode, sourceFilePath, savedFileName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInSaveFileToEvent),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void DeleteFileAttachedToEvent(int deptEventFileID)
        {
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                DeptEventsBO bo = new DeptEventsBO();
                bo.DeleteAttachedFileToEvent(deptEventFileID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteAttachedFilesToEvent),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetDeptEventFiles(int deptEventID)
        {
            DataSet ds = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                DeptEventsBO bo = new DeptEventsBO();
                ds = bo.GetDeptEventFiles(deptEventID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptEventFiles),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        #endregion

        #region Professions

        public DataSet GetProfessionsBySector(string professionCodesSelected, int sectorType)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeProfessionBO bo = new EmployeeProfessionBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetProfessionsBySector(professionCodesSelected, sectorType);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetAllProfessionsExtended(string professionCodesSelected)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeProfessionBO bo = new EmployeeProfessionBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetAllProfessionsExtended(professionCodesSelected);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAllProfessionsExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public bool UpdateEmployeeProfessions(long employeeID, string selectedProfessionCodes)
        {
            EmployeeManager bo = new EmployeeManager();

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                using (TransactionScope trans = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    bo.UpdateEmployeeProfessions(employeeID, selectedProfessionCodes);

                    trans.Complete();
                }

                BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());

                return true;
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEmployeeProfessions),
                  new WebPageExtraInfoGenerator());

                return false;
            }
        }

        public DataSet GetEmployeeProfessionsPerDept(int deptEmployeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeProfessionInDeptBO bo = new EmployeeProfessionInDeptBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetEmployeeProfessionsInDept(deptEmployeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeProfessionsPerDept),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetProfessionsByName(string p_searchString)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.getProfessionsByName(p_searchString);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetSpecialityByNameForEmployee(string prefixText, long employeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeProfessionBO bo = new EmployeeProfessionBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetSpecialityByNameForEmployee(prefixText, employeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSpecialityByNameForEmployee),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        ///// <summary>
        ///// update profession meta-data
        ///// </summary>
        ///// <param name="code">profession code</param>
        ///// <param name="name">profession name</param>
        ///// <param name="parentCode">parent profession code</param>
        ///// <param name="currOldCode">current connected old profession code from MF</param>
        ///// <param name="selectedOldCode">desired connected old profession code from MF</param>
        ///// <param name="currOldTable">current connected old table from MF (profession/service)</param>
        ///// <param name="selectedOldTable">desired connected old table from MF (profession/service)</param>
        ///// <param name="sectorCodesDelimited">selected sectors connected to this profession</param>
        ///// <param name="showExpert"></param>
        ///// <param name="flag"></param>
        //public void UpdateRelevantProfession(int code, string name, int parentCode, int currOldCode, int selectedOldCode,
        //                        string currOldTable, string selectedOldTable, string sectorCodesDelimited, string showExpert, bool flag)
        //{

        //    try
        //    {
        //        BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

        //        ServiceManager bo = new ServiceManager();
        //        bo.UpdateRelevantProfession(code, name, parentCode, currOldCode,
        //                                selectedOldCode, currOldTable, selectedOldTable, sectorCodesDelimited, showExpert, flag);

        //        BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());
        //    }
        //    catch (Exception ex)
        //    {
        //        ExceptionHandlingManager mgr = new ExceptionHandlingManager();
        //        mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetRelevantForProfessionsSectors),
        //          new WebPageExtraInfoGenerator());
        //    }
        //}

        public DataSet GetRelevantForProfessionsSectors()
        {
            DataSet ds = null;
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                ManageItemsBO bo = new ManageItemsBO();
                ds = bo.GetRelevatSectors();

                BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetRelevantForProfessionsSectors),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        #endregion

        #region Services

        public DataSet GetServiceForPopUp_ViaEmployee(int deptCode, long employeeID, int agreementType, int serviceCode, DateTime expirationDate, string RemarkCategoriesForAbsence, string RemarkCategoriesForClinicActivity)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetServiceForPopUp_ViaEmployee(deptCode, employeeID, agreementType, serviceCode, expirationDate, RemarkCategoriesForAbsence, RemarkCategoriesForClinicActivity);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetServiceForPopUp_ViaEmployee),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetServicesAndEventsByName(string searchStr, Dictionary<Enums.SearchMode, bool> AgreementTypes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetServicesAndEventsByName(searchStr, AgreementTypes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetServicesAndEventsByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetEventsByName(string searchStr, string lang)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager(lang);
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetEventsByName(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetServicesAndEventsByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetServicesByName(string searchStr, string lang)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetServicesByName(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetServicesByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetServicesByNameAndSector(string searchStr, int sectorCode, Dictionary<Enums.SearchMode, bool> AgreementTypes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetServicesByNameAndSector(searchStr, sectorCode, AgreementTypes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetServicesByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }


        public DataSet GetServicesNewBySector(string ServicesCodesSelected, int sectorType, bool IncludeService, bool IncludeProfession,
            bool isCommunity, bool isMushlam, bool isHospitals)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.GetServicesNewBySector(ServicesCodesSelected, sectorType, IncludeService, IncludeProfession, isCommunity, isMushlam, isHospitals);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetProfessionsForSalServices(string ServicesCodesSelected)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.GetProfessionsForSalServices(ServicesCodesSelected);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetProfessionsForSalServices_UnCategorized(int? salCategoryId, int? professionCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.GetProfessionsForSalServices_UnCategorized(salCategoryId, professionCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetAdminCommentsForSalServices()
        {
            return this.GetAdminCommentsForSalServices(null, null, null, null, null);
        }

        public DataSet GetAdminCommentsForSalServices(string title, string comment, DateTime? startDate, DateTime? expiredDate, byte? active)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.GetAdminCommentsForSalServices(title, comment, startDate, expiredDate, active);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetGroupsForSalServices(string groupsCodesSelected)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.GetGroupsForSalServices(groupsCodesSelected);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetPopulationsForSalServices(string populationsCodesSelected)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.GetPopulationsForSalServices(populationsCodesSelected);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetOmriReturnsForSalServices(string omriReturnCodesSelected)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicManager.GetOmriReturnsForSalServices(omriReturnCodesSelected);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetICD9ReturnsForSalServices(string ICD9ReturnCodesSelected)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicManager.GetICD9ReturnsForSalServices(ICD9ReturnCodesSelected);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetChangeTypes(string changeTypeSelected)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userManager = new UserManager();

            DataSet ds = null;

            try
            {
                ds = userManager.GetChangeTypes(changeTypeSelected);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetGeneralDataTable),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetUpdateUser(string updateUserSelected)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userManager = new UserManager();

            DataSet ds = null;

            try
            {
                ds = userManager.GetUpdateUser(updateUserSelected);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetGeneralDataTable),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetServicesNewAndEventsBySector(string ServicesCodesSelected, int sectorType,
            Dictionary<Enums.SearchMode, bool> AgreementTypes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.GetServicesNewAndEventsBySector(ServicesCodesSelected, sectorType, AgreementTypes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetAllServicesExtended(string serviceCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.GetAllServicesExtended(serviceCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAllServicesExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }



        public DataSet GetServiceByCode(int serviceCode)
        {
            DataSet ds = null;
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                ServiceManager bo = new ServiceManager();

                ds = bo.GetServiceByCode(serviceCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetService),
                  new WebPageExtraInfoGenerator());

            }
            return ds;
        }

        public DataSet GetServicesForUpdate(int? serviceCode, string serviceName, int? serviceCategoryCode, int? sector, int? requireQueueOrder, bool? isCommunity,
                                                                                bool? isMushlam, bool? isHospitals)
        {
            DataSet ds = null;
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                ServiceManager bo = new ServiceManager();
                ds = bo.GetServicesForUpdate(serviceCode, serviceName, serviceCategoryCode, sector, requireQueueOrder, isCommunity, isMushlam, isHospitals);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetService),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetServiceByNameOrCode(string prefixText)
        {
            try
            {
                ServiceManager bo = new ServiceManager();

                return bo.GetServiceByNameOrCode(prefixText);
            }

            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetServicesByName),
                  new WebPageExtraInfoGenerator());
            }

            return null;
        }

        public DataSet GetServiceCategories(int? serviceCategoryID, string serviceCategoryDescription, int? subCategoryFromTableMF51)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetServiceCategories(serviceCategoryID, serviceCategoryDescription, subCategoryFromTableMF51);
            }

            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetServiceCategories),
                  new WebPageExtraInfoGenerator());
            }

            return null;
        }

        public DataSet GetServiceCategory(int serviceCategoryID)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetServiceCategory(serviceCategoryID);
            }

            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetServiceCategories),
                  new WebPageExtraInfoGenerator());
            }

            return null;
        }

        public DataSet GetServiceCategoriesExtended(int? serviceCode, string selectedValues)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();
                return serviceManager.GetServiceCategoriesExtended(serviceCode, selectedValues);
            }

            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetServiceCategories),
                  new WebPageExtraInfoGenerator());
            }

            return null;
        }

        public int InsertServiceCategory(string serviceCategoryDescription, int? subCategoryFromTableMF51, string attributedServices)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.InsertServiceCategory(serviceCategoryDescription, subCategoryFromTableMF51, attributedServices);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertServiceCategory),
                  new WebPageExtraInfoGenerator());
            }

            return 0;
        }

        public void UpdateServiceCategory(int serviceCategoryID, string serviceCategoryDescription, string attributedServices, int? subCategoryFromTableMF51)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.UpdateServiceCategory(serviceCategoryID, serviceCategoryDescription, attributedServices, subCategoryFromTableMF51);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateServiceCategory),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void DeleteServiceCategory(int serviceCategoryID)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.DeleteServiceCategory(serviceCategoryID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteServiceCategory),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void UpdateService(int serviceCode, string serviceDesc, bool isService, bool isProfession, string sectors, bool isCommunity, bool isMushlam, bool isHospitals,
            string categories, bool enableExpert, string showExpert, int? SectorToShowWith, bool displayInInternet, bool requiresQueueOrder)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.UpdateService(serviceCode, serviceDesc, isService, isProfession,
                                            sectors, isCommunity, isMushlam, isHospitals, categories,
                                            enableExpert, showExpert, SectorToShowWith, displayInInternet, requiresQueueOrder);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateService),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetMF_Specialities051(int? code, string description)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetMF_Specialities051(code, description);
            }

            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMF_Specialities051),
                  new WebPageExtraInfoGenerator());
            }

            return null;
        }

        public DataSet GetMF_Specialities051(int? code, string description, string selectedValues)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetMF_Specialities051(code, description, selectedValues);
            }

            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMF_Specialities051),
                  new WebPageExtraInfoGenerator());
            }

            return null;
        }



        public void InsertService(int serviceCode, string serviceDesc, bool isService, bool isProfession, string sectors, bool isCommunity,
                                    bool isMushlam, bool isHospitals, string categories, bool enableExpert, string showExpert, int? SectorToShowWith,
                                    bool displayInInternet, bool requiresQueueOrder)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.InsertService(serviceCode, serviceDesc, isService, isProfession, sectors, isCommunity,
                                            isMushlam, isHospitals, categories, enableExpert, showExpert, SectorToShowWith, displayInInternet, requiresQueueOrder);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertService),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void AddSynonymToService(string servicesCodes, string synonym)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.AddSynonymToService(servicesCodes, synonym);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInAddSynonymToService),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetSynonymsByService(int? serviceCode, string serviceName, string synonym, int? categorie)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetSynonymsByService(serviceCode, serviceName, synonym, categorie);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetService),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }

        public void DeleteServiceSynonym(int synonymID)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.DeleteServiceSynonym(synonymID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void UpdateServiceSynonym(int synonymID, string synonym)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.UpdateServiceSynonym(synonymID, synonym);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        #endregion

        #region Districts

        public DataSet GetDistrictsByName(string searchStr, string unitTypeCodes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.getDistrictsByName(searchStr, unitTypeCodes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDistrictsByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getDistrictsByUnitType(string unitTypeCodes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.getDistrictsByUnitType(unitTypeCodes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDistrictsByUnitType),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }


        public DataSet GetDistrictsExtended(string selectedValuesList, string unitTypeCodes, string permittedDistricts)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            DeptBO bo = new DeptBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetDistrictsExtended(selectedValuesList, unitTypeCodes, permittedDistricts);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDistrictsExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getUserPermittedDistricts(Int64 UserID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userMgr = new UserManager();
            DataSet ds = null;
            try
            {
                ds = userMgr.getUserPermittedDistricts(UserID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUserPermittedDistricts),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetUserPermissions(Int64 userID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            UserManager userMgr = new UserManager();
            DataSet ds = null;
            try
            {
                ds = userMgr.GetUserPermissions(userID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUserPermission),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public List<View_AllDeptAddressAndPhone> GetAllDistrictsWithDetails()
        {
            List<View_AllDeptAddressAndPhone> list = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                View_DeptAddressAndPhonesBL deptView = new View_DeptAddressAndPhonesBL();
                list = deptView.GetAllDistrictsWithDetails();

                BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAllDistrictsWithDetails),
                  new WebPageExtraInfoGenerator());
            }

            return list;
        }

        #endregion

        #region Handicapped Facilities

        public DataSet GetHandicappedFacilitiesByName(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetHandicappedFacilitiesByName(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetHandicappedFacilitiesByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetHandicappedFacilitiesExtended(string selectedValuesList)
        {
            DeptHandicappedFacilitiesBO bo = new DeptHandicappedFacilitiesBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetHandicappedFacilitiesExtended(selectedValuesList);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetHandicappedFacilitiesExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        #endregion

        #region Administrations

        public void getAdministrationList(ref DataSet p_Adminds, int p_districtCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();

            try
            {
                clinicMgr.getAdministrationList(ref p_Adminds, p_districtCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAdministrationList),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet getAdministrationList(int p_districtCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            DataSet dsAdmins = new DataSet();
            this.getAdministrationList(ref dsAdmins, p_districtCode);
            return dsAdmins;
        }

        public DataSet GetAdminsExtended(string selectedAdmins, string districts)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            DeptBO bo = new DeptBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetAdminsExtended(selectedAdmins, districts);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAdminsExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetClinicsExtended(string selectedClinics, string selectedAdmins, string districts, string unitTypeListCodes, string subUnitTypeCode, string populationSector)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            DeptBO bo = new DeptBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetClinicsExtended(selectedClinics, selectedAdmins, districts, unitTypeListCodes, subUnitTypeCode, populationSector);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicsExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public List<View_AllDeptAddressAndPhone> GetAdminWithDetails_DistrictDepended(int districtCode)
        {
            List<View_AllDeptAddressAndPhone> list = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                View_DeptAddressAndPhonesBL bl = new View_DeptAddressAndPhonesBL();

                list = bl.GetAdministrationsByDistrict(districtCode);


                BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAdministrationsWithDetails),
                  new WebPageExtraInfoGenerator());
            }

            return list;
        }

        #endregion

        #region Cities And Streets

        public DataSet getCitiesByNameAndDistrict(string p_strSearch, string p_districtCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            StreetAndCityManager strMgr = new StreetAndCityManager();

            DataSet ds = null;
            try
            {
                ds = strMgr.getCitiesByNameAndDistrict(p_strSearch, p_districtCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetCitiesByNameAndDistrict),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetCitiesAndDistrictsByNameAndDistrict(string p_strSearch, int p_districtCode, int p_deptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            StreetAndCityManager strMgr = new StreetAndCityManager();

            DataSet ds = null;
            try
            {
                ds = strMgr.GetCitiesAndDistrictsByNameAndDistrict(p_strSearch, p_districtCode, p_deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetCitiesAndDistrictsByNameAndDistrict),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetCitiesAndDistrictsByNameAndDistricts(string p_strSearch, string p_districtCodes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            StreetAndCityManager strMgr = new StreetAndCityManager();

            DataSet ds = null;
            try
            {
                ds = strMgr.GetCitiesAndDistrictsByNameAndDistricts(p_strSearch, p_districtCodes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetCitiesAndDistrictsByNameAndDistricts),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getStreetsByCityCode(int p_CityCode, string p_strSearch)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            try
            {
                StreetAndCityManager streetAndCityManager = new StreetAndCityManager();

                return streetAndCityManager.getStreetsByCityCode(p_CityCode, p_strSearch);
            }
            catch (Exception ex)
            {
                string str = ex.Message;
                return null;
            }
        }

        public DataSet getNeighbourhoodsByCityCode(int p_CityCode, string p_strSearch)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            StreetAndCityManager streetAndCityManager = new StreetAndCityManager();
            DataSet ds = null;
            try
            {
                ds = streetAndCityManager.getNeighbourhoodsByCityCode(p_CityCode, p_strSearch);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGgetNeighbourhoodsByCityCode),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetNeighbourhoodsAndSitesByCityCode(int p_CityCode, string p_strSearch)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            StreetAndCityManager streetAndCityManager = new StreetAndCityManager();
            DataSet ds = null;
            try
            {
                ds = streetAndCityManager.GetNeighbourhoodsAndSitesByCityCode(p_CityCode, p_strSearch);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGgetNeighbourhoodsByCityCode),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getSitesByCityCode(int p_CityCode, string p_strSearch)
        {
            DataSet ds = null;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            StreetAndCityManager streetAndCityManager = new StreetAndCityManager();

            try
            {
                ds = streetAndCityManager.getSitesByCityCode(p_CityCode, p_strSearch);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSitesByCityCode),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }
        public DataSet getCitiesDistrictsWithSelectedCodes(string selectedCityCodes, string districtCodes)
        {
            DataSet ds = null;
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            StreetAndCityManager streetAndCityManager = new StreetAndCityManager();

            try
            {
                ds = streetAndCityManager.getCitiesDistrictsWithSelectedCodes(selectedCityCodes, districtCodes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetCitiesByNameAndDistrict),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        #endregion

        #region Remarks
        //--- new Sweeping DeptRemarks concept
        public DataSet GetSweepingRemarkExclusions(int DeptRemarkID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            DataSet ds = null;
            try
            {
                rem.GetSweepingRemarkExclusions(ref ds, DeptRemarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkAreasByRelatedRemarkID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        //--- new Sweeping DeptRemarks concept
        public void DeleteDeptRemark(int DeptRemarkID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            try
            {
                rem.DeleteDeptRemark(DeptRemarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarks),
                  new WebPageExtraInfoGenerator());      // todo: add eDIC_ErrorMessageInfo.BugInDeleteDeptRemark
            }
        }

        //--- new Sweeping DeptRemarks concept
        public void InsertSweepingRemarkExclutions(DataTable TblRemarks, int DeptCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            try
            {
                rem.InsertSweepingRemarkExclutions(TblRemarks, DeptCode);

                DBActionNotification.RaiseOnDBAction_targeted((int)Enums.Target.ClinicRemarks_Delete, 0, 0, 0, DeptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarks),
                  new WebPageExtraInfoGenerator());      // todo: add eDIC_ErrorMessageInfo.InsertSweepingRemarkExclutions
            }
        }

        //--- new Sweeping DeptRemarks concept
        public bool InsertSweepingDeptRemark(int remarkDicID, string remarkText, string districtCodes, string administrationCodes,
            string UnitTypeCodes, string subUnitTypeCode, string populationSectorCodes,
            DateTime? validFrom, DateTime? validTo, DateTime? activeFrom, bool displayInInternet, string cityCodes, string servicesParameter)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            bool result = false;
            //DateTime? dateShowFrom = Convert.ToDateTime("1/1/1900");

            try
            {
                result = rem.InsertSweepingDeptRemark(remarkDicID, remarkText, districtCodes, administrationCodes,
                                 UnitTypeCodes, subUnitTypeCode, populationSectorCodes, string.Empty,
                                 validFrom, validTo, activeFrom, displayInInternet, cityCodes, servicesParameter);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarks),
                  new WebPageExtraInfoGenerator());             // todo: add eDIC_ErrorMessageInfo.BugInDeleteDeptRemark
            }
            return result;

        }

        //--- new Sweeping DeptRemarks concept
        public bool InsertDeptRemark(int remarkDicID, string remarkText, int deptCode,
            DateTime? validFrom, DateTime? validTo, DateTime? activeFrom, bool displayInInternet, long updateUser)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            UserManager userManager = new UserManager();

            bool result = false;
            try
            {
                result = rem.InsertDeptRemark(remarkDicID, remarkText, deptCode,
                                 validFrom, validTo, activeFrom, displayInInternet);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarks),
                  new WebPageExtraInfoGenerator());             // todo: add eDIC_ErrorMessageInfo.BugInInsertDeptRemark
            }

            if (result)
            {
                userManager.Insert_LogChange((int)Enums.ChangeType.ClinicRemarks_Add, updateUser, deptCode, null, null, null, remarkDicID, null, remarkText);
            }

            return result;
        }

        public bool Insert_LogChange(int codePeula, long updateUser, int deptCode, Int64? employeeID, int? deptEmployeeID, int? deptEmployeeServicesID, int? remarkID, int? serviceCode, string value)
        {
            UserManager userManager = new UserManager();
            bool result = false;
            try
            {
                userManager.Insert_LogChange(codePeula, updateUser, deptCode, employeeID, deptEmployeeID, deptEmployeeServicesID, remarkID, serviceCode, value);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.GeneralBug), new WebPageExtraInfoGenerator());
            }

            return result;
        }

        public void UpdateEmployeeInClinicPreselected(long? employeeID, int? deptCode, int? deptEmployeeID)
        {
            EmployeeManager employeeManager = new EmployeeManager();

            try
            {
                employeeManager.UpdateEmployeeInClinicPreselected(employeeID, deptCode, deptEmployeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.GeneralBug), new WebPageExtraInfoGenerator());
            }
        }

        //--- new Sweeping DeptRemarks concept
        public bool UpdateSweepingDeptRemark(int DeptRemarkID, int remarkDicID, string remarkText, string districtCodes, string administrationCodes,
            string UnitTypeCodes, string subUnitTypeCode, string populationSectorCodes, string excludedDeptCodes,
            string cityCodes, string servicesParameter,
            DateTime? validFrom, DateTime? validTo, DateTime? dateShowFrom, bool displayInInternet)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            //int cityCode = -1;
            //string servicesParameter = string.Empty;

            bool result = false;
            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    rem.DeleteDeptRemark(DeptRemarkID);
                    //result = rem.InsertSweepingDeptRemark(remarkDicID, remarkText, districtCodes, administrationCodes,
                    //                 UnitTypeCodes, subUnitTypeCode, populationSectorCodes, excludedDeptCodes,
                    //                 validFrom, validTo, displayInInternet);
                    result = rem.InsertSweepingDeptRemark(remarkDicID, remarkText, districtCodes, administrationCodes,
                                     UnitTypeCodes, subUnitTypeCode, populationSectorCodes, excludedDeptCodes,//string.Empty,
                                     validFrom, validTo, dateShowFrom, displayInInternet, cityCodes, servicesParameter);
                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarks),
                  new WebPageExtraInfoGenerator());             // todo: add eDIC_ErrorMessageInfo.BugInDeleteDeptRemark
            }
            return result;
        }

        public DataSet GetRemarksExtended(string selectedCodes, byte linkedToDept, byte linkedToServiceInClinic, byte linkedToDoctor,
            byte linkedToDoctorInClinic, byte linkedToReceptionHours)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            RemarkInfoBO bo = new RemarkInfoBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetRemarksExtended(selectedCodes, linkedToDept, linkedToServiceInClinic, linkedToDoctor,
                   linkedToDoctorInClinic, linkedToReceptionHours);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetRemarksExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public void GetSweepingRemarks(ref DataSet p_ds, string p_DistrictCode, string p_AdminClinicCode, string p_SectorCode,
                                                    string p_UnitTypeCode, int p_subUnitTypeCode, int p_userPermittedDistrict,
                                                    string p_servicesParameter, string p_cityCodes, string freeText)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            try
            {
                rem.GetSweepingRemarks(ref p_ds, p_DistrictCode, p_AdminClinicCode, p_SectorCode, p_UnitTypeCode,
                                                p_subUnitTypeCode, p_userPermittedDistrict, p_servicesParameter, p_cityCodes, freeText);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarks),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetSweepingRemarkByID(int p_remarkID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            DataSet ds = null;
            try
            {
                ds = rem.GetSweepingRemarkByID(p_remarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetSweepingRemarkAreasByRelatedRemarkID(int p_relatedRemarkID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();

            DataSet ds = null;
            try
            {
                ds = rem.GetSweepingRemarkAreasByRelatedRemarkID(p_relatedRemarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkAreasByRelatedRemarkID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public void GetEmployeeRemarks(ref DataSet p_ds, int p_EmployeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            try
            {
                rem.GetEmployeeRemarks(ref p_ds, p_EmployeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeRemarks),
                  new WebPageExtraInfoGenerator());
            }
        }
        public void GetEmployeeServiceRemarks(ref DataSet p_ds, int DeptEmployeeID, int serviceCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            try
            {
                rem.GetEmployeeServiceRemarks(ref p_ds, DeptEmployeeID, serviceCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetEmployeeRemarks),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetGeneralRemarks(int? remarkTypeint, bool userIsAdmin, int RemarkCategoryID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            DataSet ds = null;
            try
            {
                ds = bo.Select(remarkTypeint, userIsAdmin, RemarkCategoryID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getRemarkTags()
        {
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            DataSet ds = bo.getRemarkTags();
            return ds;
        }

        public DataSet getRemarkTagsToCreateRemark()
        {
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            DataSet ds = bo.getRemarkTagsToCreateRemark();
            return ds;
        }
        public DataSet GetGeneralRemarksToCorrect(int? remarkTypeint, bool userIsAdmin, int RemarkCategoryID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetGeneralRemarksToCorrect(remarkTypeint, userIsAdmin, RemarkCategoryID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        //ApproveDICRemark_AndUpdateRemarks(current_DIC_remarkID, currentUser.UserNameWithPrefix, remarkToCorrect);
        public bool ApproveDICRemark_AndUpdateRemarks(int DIC_remarkID, string UserName, string newRemarkText)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            bool result = false;
            try
            {
                result = bo.ApproveDICRemark_AndUpdateRemarks( DIC_remarkID, UserName, newRemarkText);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }

            return result;
        }

        public void InsertDicGeneralRemarkToCorrect(
            string remark,
            int DIC_GeneralRemarks_remarkID,
            string UserName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            try
            {
                bo.InsertDicGeneralRemarkToCorrect(
                remark,
                DIC_GeneralRemarks_remarkID,
                UserName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void DeleteDicGeneralRemarkToCorrect(int DIC_GeneralRemarks_remarkID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            try
            {
                bo.DeleteDicGeneralRemarkToCorrect(DIC_GeneralRemarks_remarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetRemarksTypes()
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            RemarkInfoBO bo = new RemarkInfoBO();
            DataSet ds = null;
            try
            {
                ds = bo.getRemarksTypes();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetGeneralRemarkCategoriesByLinkedTo(int remarkTypeint, bool userIsAdmin)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetGeneralRemarkCategoriesByLinkedTo(remarkTypeint, userIsAdmin);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public void DeleteGeneralRemark(int remarkID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            try
            {
                bo.DeleteGeneralRemark(remarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetGeneralRemarkByRemarkID(int RemarkID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetGeneralRemarkByRemarkID(RemarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getGeneralRemarks_ToCorrect_ByRemarkID(int RemarkID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            DataSet ds = null;
            try
            {
                ds = bo.getGeneralRemarks_ToCorrect_ByRemarkID(RemarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }


        public void UpdateDicGeneralRemark(
            int remarkID,
            string remark,
            int remarkCategory,
            bool active,
            bool linkedToDept,
            bool linkedToDoctor,
            bool linkedToDoctorInClinic,
            bool linkedToServiceInClinic,
            bool linkedToReceptionHours,
            bool EnableOverlappingHours,
            float factor,
            bool openNow,
            int showForPreviousDays,
            string UserName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            try
            {
                bo.UpdateDicGeneralRemark(remarkID,
                remark,
                remarkCategory,
                active,
                linkedToDept,
                linkedToDoctor,
                linkedToDoctorInClinic,
                linkedToServiceInClinic,
                linkedToReceptionHours,
                EnableOverlappingHours,
                factor,
                openNow,
                showForPreviousDays,
                UserName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void InsertDicGeneralRemark(
            string remark,
            int remarkCategory,
            bool active,
            bool linkedToDept,
            bool linkedToDoctor,
            bool linkedToDoctorInClinic,
            bool linkedToServiceInClinic,
            bool linkedToReceptionHours,
            bool EnableOverlappingHours,
            float factor,
            bool openNow,
            int showForPreviousDays,
            string UserName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            try
            {
                bo.InsertDicGeneralRemark(
                remark,
                remarkCategory,
                active,
                linkedToDept,
                linkedToDoctor,
                linkedToDoctorInClinic,
                linkedToServiceInClinic,
                linkedToReceptionHours,
                EnableOverlappingHours,
                factor,
                openNow,
                showForPreviousDays,
                UserName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
        }


        public DataSet GetDIC_RemarkCategory()
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();

            DataSet ds = null;
            try
            {
                ds = bo.GetDIC_RemarkCategory();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public bool DeleteRemarkCategory(int remarkID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            bool result = false;
            try
            {
                result = bo.DeleteRemarkCategory(remarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }

            return result;
        }

        public bool UpdateRemarkCategory(int RemarkCategoryID, string RemarkCategoryName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            bool result = false;
            try
            {
                result = bo.UpdateRemarkCategory(RemarkCategoryID, RemarkCategoryName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }

            return result;
        }

        public bool InsertRemarkCategory(string RemarkCategoryName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            bool result = false;
            try
            {
                result = bo.InsertRemarkCategory(RemarkCategoryName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetSweepingRemarkByID),
                  new WebPageExtraInfoGenerator());
            }

            return result;
        }

        public bool RenewRemarks(int remarkID, string UserName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            Dic_GeneralRemarksBO bo = new Dic_GeneralRemarksBO();
            bool result = false;

            try
            {
                result = bo.RenewRemarks(remarkID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.GeneralBug),
                  new WebPageExtraInfoGenerator());
            }
            return result;
        }

        #endregion

        #region General Information

        /// <summary>
        /// This is a general method that retrieves a view or a small table
        /// using the table name parameter
        /// </summary>
        /// <param name="dataTableName"></param>
        /// <returns></returns>
        public DataSet getGeneralDataTable(string dataTableName)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.getGeneralDataTable(dataTableName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetGeneralDataTable),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetObjectTypesExtended(string selectedValuesList)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            DeptBO bo = new DeptBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetObjectTypesExtended(selectedValuesList);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetObjectTypesExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetDicQueueOrderMethodsAndOptionsCombinedByName(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            QueueOrderMethodBO queueOrderMng = new QueueOrderMethodBO();
            DataSet ds = null;
            try
            {
                ds = queueOrderMng.GetDicQueueOrderMethodsAndOptionsCombinedByName(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.GeneralBug),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        #endregion

        #region Reports

        public void GetReportParameters(ref DataSet Paramsds, int ReportType)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            AppQueries quy = new AppQueries();
            try
            {
                quy.GetQueryParameters(ref Paramsds, ReportType);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetReportParameters),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void GetReportFields(ref DataSet Fieldsds, int ReportType)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            AppQueries quy = new AppQueries();

            try
            {
                quy.GetQueryFields(ref Fieldsds, ReportType);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetReportFields),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void GetReportDetails(ref DataSet Fieldsds, int p_CurrentReport)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            AppQueries quy = new AppQueries();

            try
            {
                quy.GetReportDetails(ref Fieldsds, p_CurrentReport);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetReportDetails),
                  new WebPageExtraInfoGenerator());
            }
        }

        #endregion

        #region PhonePrefix

        public DataSet getPhonePrefixListAll()
        {
            phoneHandler ph = new phoneHandler();
            DataSet ds = null;
            try
            {
                ds = ph.getPhonePrefixListAll();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetPhonePrefixListAll),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public int DeletePhonePrefix(int p_prefixCode)
        {
            phoneHandler ph = new phoneHandler();
            int res = 0;
            try
            {
                res = ph.DeletePhonePrefix(p_prefixCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeletePhonePrefix),
                  new WebPageExtraInfoGenerator());
            }
            return res;
        }

        public int InsertPhonePrefix(string p_prefixValue, int p_phoneType)
        {
            phoneHandler ph = new phoneHandler();
            int prefixCodeInserted = 0;
            try
            {
                prefixCodeInserted = ph.InsertPhonePrefix(p_prefixValue, p_phoneType);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertPhonePrefix),
                  new WebPageExtraInfoGenerator());
            }
            return prefixCodeInserted;
        }

        public bool UpdatePhonePrefix(int p_prefixCode, string p_prefixValue, int p_phoneType)
        {
            bool result = true;
            phoneHandler ph = new phoneHandler();
            try
            {
                ph.UpdatePhonePrefix(p_prefixCode, p_prefixValue, p_phoneType);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdatePhonePrefix),
                  new WebPageExtraInfoGenerator());
                result = false;
            }
            return result;
        }

        #endregion

        #region Languages

        public DataTable GetLanguages()
        {
            LanguagesManager bl = new LanguagesManager();
            DataTable dt = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                dt = bl.GetLanguages();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetLanguages),
                  new WebPageExtraInfoGenerator());
            }

            return dt;
        }

        public DataSet GetLanguagesExtended(string selectedCodes)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeeLanguagesBO bo = new EmployeeLanguagesBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetLanguagesExtended(selectedCodes);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetLanguagesExtended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet getLanguagesByName(string p_searchString)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicManager.getLanguagesByName(p_searchString);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetLanguagesByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        #endregion

        #region Positions

        public DataSet GetPositionsByName(string prefixText, long employeeID)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            EmployeePositionsBO bo = new EmployeePositionsBO();
            DataSet ds = null;
            try
            {
                ds = bo.GetAllPositionsByName(prefixText, employeeID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetPositionsByName),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        #endregion

        #region UpdateTables

        public DataSet GetUnitTypeConvertSimul(int convertId)
        {
            UpdateTablesManager tm = new UpdateTablesManager();
            DataSet ds = null;

            try
            {
                ds = tm.GetUnitTypeConvertSimul(convertId);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetUnitTypeConvertSimul),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public bool UpdateUnitTypeConvertSimul(int ConvertId, int Active, int TypeUnit, int PopSectorID)
        {
            bool result = true;
            UpdateTablesManager tm = new UpdateTablesManager();
            try
            {
                tm.UpdateUnitTypeConvertSimul(ConvertId, Active, TypeUnit, PopSectorID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateDeptServiceRemark),
                  new WebPageExtraInfoGenerator());
                result = false;
            }
            return result;
        }

        #endregion

        #region ActivityStatus


        public int UpdateStatus(int deptCode, long employeeID, int deptEmployeeID, int serviceCode, int AgreementType, DataTable statusTable, Enums.EntityTypesStatus currEntity, string updateUser)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            UserManager userManager = new UserManager();
            int currentStatus = -1;
            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForUpdatedRecords())
                {
                    currentStatus = clinicMgr.UpdateStatus(deptCode, employeeID, serviceCode, AgreementType, statusTable, currEntity);

                    tranScope.Complete();
                }

                if (currEntity == Enums.EntityTypesStatus.EmployeeInDept && deptEmployeeID != 0)
                {
                    userManager.Insert_LogChange((int)Enums.ChangeType.EmployeeInClinicStatus_Update, userManager.GetUserIDFromSession(), deptCode, null, deptEmployeeID, null, null, null, null);
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateStatus),
                  new WebPageExtraInfoGenerator());
            }

            return currentStatus;
        }

        public DataSet GetAllStatuses(int deptCode, long employeeID, int serviceCode, Enums.EntityTypesStatus entityType)
        {
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                ds = clinicManager.GetAllStatuses(deptCode, employeeID, serviceCode, entityType);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAllDeptServiceStatuses),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        #endregion

        public DataTable GetTablesName()
        {
            TablesNameManager bl = new TablesNameManager();
            DataTable dt = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                dt = bl.GetTablesName();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetTablesName),
                  new WebPageExtraInfoGenerator());
            }
            return dt;
        }

        #region AgreementTypes

        public DataTable GetAgreementTypes()
        {
            AgreementTypeManager bl = new AgreementTypeManager();
            DataTable dt = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                dt = bl.GetAgreementTypes();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAllDeptServiceStatuses),
                  new WebPageExtraInfoGenerator());
            }

            return dt;
        }

        #endregion



        #region OrganizationSector

        public DataTable GetOrganizationSector()
        {
            OrganizationSectorManager bl = new OrganizationSectorManager();
            DataTable dt = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                dt = bl.OrganizationSectors();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetOrganizationSectors),
                  new WebPageExtraInfoGenerator());
            }

            return dt;
        }

        #endregion

        #region General Dictionaries

        public void UpdateEvent(int eventCode, string eventName, bool isActive, string sourceFilePathToAttach)
        {
            GeneralDictionariesBO bo = new GeneralDictionariesBO();

            try
            {
                using (TransactionScope trans = TranscationScopeFactory.GetForUpdatedRecords())
                {

                    BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                    bo.UpdateEvent(eventCode, eventName, isActive);

                    if (!string.IsNullOrEmpty(sourceFilePathToAttach))
                    {
                        AddFileToEvent(eventCode, sourceFilePathToAttach);
                    }

                    trans.Complete();
                    trans.Dispose();

                    BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());

                }

            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateEvent),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void AddFileToEvent(int eventCode, string sourceFilePath)
        {
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                GeneralDictionariesBO bo = new GeneralDictionariesBO();
                bo.AddFileToEvent(eventCode, sourceFilePath);

                BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());

            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInSaveFileToEvent),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void DeleteEventFile(int eventFileID)
        {
            try
            {
                GeneralDictionariesBO bo = new GeneralDictionariesBO();
                bo.DeleteEventFile(eventFileID);
            }
            catch (Exception ex)
            {

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteAttachedFilesToEvent),
                  new WebPageExtraInfoGenerator());
            }
        }




        public DataSet GetReceptionDays(bool byDisplay)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            GeneralDictionariesBO gd = new GeneralDictionariesBO();

            DataSet ds = null;
            try
            {
                ds = gd.GetReceptionDays(byDisplay);
            }
            catch (Exception ex)
            {

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAllDeptServiceStatuses),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetReceptionTypesByGeneralBelongings(bool isCommunity, bool isMushlam, bool isHospital)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            GeneralDictionariesBO gd = new GeneralDictionariesBO();

            DataSet ds = null;
            try
            {
                ds = gd.GetReceptionTypesByGeneralBelongings(isCommunity, isMushlam, isHospital);
            }
            catch (Exception ex)
            {

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetReceptionTypesByGeneralBelongings),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }
        public void UpdateReceptionDays(int receptionDayCode, int display, int useInSearch)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            GeneralDictionariesBO gd = new GeneralDictionariesBO();


            try
            {
                gd.UpdateReceptionDays(receptionDayCode, display, useInSearch);
            }
            catch (Exception ex)
            {

                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetAllDeptServiceStatuses),
                  new WebPageExtraInfoGenerator());
            }
        }

        #endregion

        #region ReportOnIncorrectData

        public void ReportOnIncorrectData(int deptCode, long employeeID, Enums.IncorrectDataReportEntity currEntity,
                                                                                                string errorDescription, string callerPage, string reportedBy)
        {
            ReportErrorBO bo = new ReportErrorBO();

            bo.InsertIncorrectDataReport(deptCode, employeeID, currEntity, errorDescription, callerPage, reportedBy);
        }

        #endregion

        #region HTML Templates data

        public AllDeptDetailsDataTemplateInfo Get_AllDeptDetailsDataTemplateInfo(GetAllDeptDetailsForTemplatesParameters deptParams)
        {
            View_DeptDetailsBL bl = new View_DeptDetailsBL();

            AllDeptDetailsDataTemplateInfo retObj = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());

                retObj = bl.Get_AllDeptDetailsDataTemplateInfo(deptParams);

                BLFacadeActionNotifications.RaiseOnBLFacadeActionExit(this.GetType());
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetDeptsByAdminWithDetails),
                  new WebPageExtraInfoGenerator());
            }

            return retObj;
        }
        #endregion

        #region Mushlam

        public List<MushlamServiceSearchResults> GetMushlamServices(string serviceCodes, string searchWord, bool isExtendedSearch,
                                                                                                        ClinicSearchParameters searchParams)
        {
            MushlamManager mm = new MushlamManager();

            try
            {
                return mm.GetMushlamServices(serviceCodes, searchWord, isExtendedSearch, searchParams);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMushlamServices),
                  new WebPageExtraInfoGenerator());
            }

            return null;
        }

        public MushlamService GetMushlamServiceByCode(int serviceCode, int groupCode, int subGroupCode)
        {
            MushlamManager mm = new MushlamManager();

            try
            {
                return mm.GetMushlamServiceByCode(serviceCode, groupCode, subGroupCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMushlamServices),
                  new WebPageExtraInfoGenerator());
            }

            return null;
        }

        public List<MushlamModel> GetMushlamModelsForService(int serviceCode)
        {
            MushlamManager man = new MushlamManager();

            try
            {
                return man.GetMushlamModelsForService(serviceCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetMushlamServices),
                  new WebPageExtraInfoGenerator());
            }

            return null;
        }

        public DataSet GetForms(bool isCommunity, bool isMushlam)
        {
            Forms forms = new Forms();
            DataSet ds = null;
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                forms.GetForms(ref ds, isCommunity, isMushlam);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGettingForms),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetBrochures(bool isCommunity, bool isMushlam)
        {
            Brochures brochures = new Brochures();
            DataSet ds = null;
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                brochures.GetBrochures(ref ds, isCommunity, isMushlam);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGettingBrochures),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public void InsertBrochure(string displayName, string fileName, int languageCode,
            bool isCommunity, bool isMushlam)
        {
            Brochures brochures = new Brochures();
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                brochures.InsertBrochure(displayName, fileName, languageCode, isCommunity, isMushlam);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertingBrochure),
                  new WebPageExtraInfoGenerator());
            }


        }

        public void UpdateBrochure(int brochureID, string DisplayName, string fileName, int languageCode)
        {
            Brochures brochures = new Brochures();
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                brochures.UpdateBrochure(brochureID, DisplayName, fileName, languageCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdatingBrochures),
                  new WebPageExtraInfoGenerator());
            }


        }

        public void DeleteBrochure(int brochureID)
        {
            Brochures brochures = new Brochures();
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                brochures.DeleteBrochure(brochureID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeletingBrochure),
                  new WebPageExtraInfoGenerator());
            }


        }

        public void InsertForm(string fileName, string formDisplayName,
            bool isCommunity, bool isMushlam)
        {
            Forms forms = new Forms();
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                forms.InsertForm(fileName, formDisplayName, isCommunity, isMushlam);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertingNewForm),
                  new WebPageExtraInfoGenerator());
            }


        }

        public void UpdateForm(int formID, string fileName, string formDisplayName)
        {
            Forms forms = new Forms();
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                forms.UpdateForm(formID, fileName, formDisplayName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdatingForms),
                  new WebPageExtraInfoGenerator());
            }


        }

        public void DeleteForm(int formID)
        {
            Forms forms = new Forms();
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                forms.DeleteForm(formID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeletingForm),
                  new WebPageExtraInfoGenerator());
            }


        }

        public DataSet GetMushlamConnectionTables(int? tableCode, string seferServiceName, string mushlamServiceName)
        {
            MushlamManager mushlamManager = new MushlamManager();
            DataSet ds = null;
            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                ds = mushlamManager.GetMushlamConnectionTables(tableCode, seferServiceName, mushlamServiceName);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetTablesName),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public void InsertMushlamToSeferMapping(int tableCode, int? mushlamServiceCode, int seferServiceCode,
            int? parentCode, int? groupCode, int? subGroupCode)
        {
            ManageItemsBO bo = new ManageItemsBO();

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                bo.InsertMushlamToSeferMapping(tableCode, mushlamServiceCode, seferServiceCode, parentCode,
                groupCode, subGroupCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertMushlamToSeferMapping),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void UpdateMushlamToSeferMapping(int tableCode, int mappingID,
            int? mushlamServiceCode, int seferServiceCode, int? parentCode,
            int? groupCode, int? subgroupCode)
        {
            ManageItemsBO bo = new ManageItemsBO();

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                bo.UpdateMushlamProfessionMapping(tableCode, mappingID, mushlamServiceCode, seferServiceCode,
                                                   parentCode, groupCode, subgroupCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateMushlamToSeferMapping),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void DeleteMushlamToSeferMapping(int id, int mushlamTableCode)
        {

            ManageItemsBO bo = new ManageItemsBO();

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                bo.DeleteMushlamToSeferMapping(id, mushlamTableCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeletingMushlamToSeferMapping),
                  new WebPageExtraInfoGenerator());
            }


        }

        #endregion

        #region MedicalAspects

        public DataSet GetClinicMedicalAspects(int deptCode)
        {
            ServiceManager bl = new ServiceManager();
            DataSet ds = null;

            try
            {
                BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
                ds = bl.GetClinicMedicalAspects(deptCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicMedicalAspects),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public bool InsertClinicMedicalAspects(int deptCode, string medicalAspectsList, string updateUser)
        {
            bool result = true;
            ServiceManager bl = new ServiceManager();
            ClinicManager mng = new ClinicManager();
            EmployeeServiceInDeptBO ESInD = new EmployeeServiceInDeptBO();
            StatusBO statusBO = new StatusBO();
            DataSet ds = null;

            int DeptEmployeeID = 0;
            long selectedEmployeeID = 0;

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForInsertedRecords())
                {
                    //Is clinic team exists in the clinic?
                    ds = mng.GetEmployeeClinicTeam(deptCode);
                    if (ds.Tables[0].Rows.Count == 0) //clinic team does not exists in the clinic
                    {
                        ds = mng.GetEmployeeClinicTeam(0);
                        selectedEmployeeID = Convert.ToInt64(ds.Tables[0].Rows[0]["EmployeeID"]);

                        DeptEmployeeID = mng.InsertDoctorInClinic(deptCode, selectedEmployeeID, Convert.ToInt32(eDIC_AgreementTypes.Hospitals), updateUser, true);
                    }
                    else
                        DeptEmployeeID = Convert.ToInt32(ds.Tables[0].Rows[0]["DeptEmployeeID"]);

                    //Does services for medicalAspectsList exist in x_Dept_Employee_Services?
                    ds = ESInD.GetServicesForMedicalAspects(deptCode, medicalAspectsList);
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        ESInD.InsertDeptEmployeeService(DeptEmployeeID, ds.Tables[0].Rows[0]["Services"].ToString(), updateUser);
                    }
                    //make sure employee status in Dept is "active"
                    statusBO.UpdateEmployeeInDeptCurrentStatusByDeptEmployeeID(DeptEmployeeID, 1, updateUser);

                    bl.InsertClinicMedicalAspects(deptCode, medicalAspectsList, updateUser);

                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInInsertClinicMedicalAspects),
                  new WebPageExtraInfoGenerator());
                result = false;
            }
            return result;
        }

        public bool DeleteClinicMedicalAspect(int deptCode, int medicalAspectCode)
        {
            bool ThereMedicalAspectsLeft = true;
            ServiceManager bl = new ServiceManager();

            try
            {
                using (TransactionScope tranScope = TranscationScopeFactory.GetForDeleteRecords())
                {
                    //ds = mng.GetEmployeeClinicTeam(deptCode);
                    //DeptEmployeeID = Convert.ToInt32(ds.Tables[0].Rows[0]["DeptEmployeeID"]);

                    ////Does services for medicalAspectsList exist in x_Dept_Employee_Services?
                    //ds = ESInD.GetServicesForMedicalAspects(deptCode, medicalAspectsList);
                    //if (ds.Tables[0].Rows.Count > 0)
                    //{
                    //    ESInD.InsertDeptEmployeeService(DeptEmployeeID, ds.Tables[0].Rows[0]["Services"].ToString(), updateUser);
                    //}

                    bl.DeleteClinicMedicalAspect(deptCode, medicalAspectCode);

                    DataSet ds = bl.GetClinicMedicalAspects(deptCode);
                    if (ds.Tables[0].Rows.Count > 0)
                        ThereMedicalAspectsLeft = true;
                    else
                        ThereMedicalAspectsLeft = false;

                    tranScope.Complete();
                }
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteClinicMedicalAspect),
                  new WebPageExtraInfoGenerator());
                ThereMedicalAspectsLeft = true;
            }
            return ThereMedicalAspectsLeft;
        }

        #endregion
        #region Search Sal Services Methods

        public DataSet GetServiceCodeDescription_ForSearchSalServices(int servicecode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetServiceCodeDescription_ForSearchSalServices(servicecode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        #endregion

        public DataSet GetHealthOfficeCodeDescription_ForSearchSalServices(string healthOfficeCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetHealthOfficeCodeDescription_ForSearchSalServices(healthOfficeCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetGroupCodeDescription_ForSearchSalServices(int groupCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetGroupCodeDescription_ForSearchSalServices(groupCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetProfessionCodeDescription_ForSearchSalServices(int iProfessionCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetProfessionCodeDescription_ForSearchSalServices(iProfessionCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetOmriReturnCodeDescription_ForSearchSalServices(int iOmriReturnCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetOmriReturnCodeDescription_ForSearchSalServices(iOmriReturnCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetICD9CodeDescription_ForSearchSalServices(string ICD9Code)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetICD9CodeDescription_ForSearchSalServices(ICD9Code);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalServices(byte? includeInBasket, byte? common, byte? showServiceInInternet, byte? isActive, bool isLoggedIn, string searchText, int? serviceCode, string serviceDescription,
            string healthOfficeCode, string healthOfficeDescription, string groupsCodes, string professionsCodes, string omriReturnsCodes, string icd9Code,
            string populationCodes, int salCategoryID, int salOrganCode, DateTime? basketApproveFromDate, DateTime? basketApproveToDate, DateTime? ADD_DATE_FromDate, DateTime? ADD_DATE_ToDate,
            bool showCanceledServices, DateTime? DEL_DATE_FromDate, DateTime? DEL_DATE_ToDate, DateTime? internetUpdated_FromDate, DateTime? internetUpdated_ToDate)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetSalServices(includeInBasket, common, showServiceInInternet, isActive, isLoggedIn, searchText, serviceCode, serviceDescription, healthOfficeCode,
                    healthOfficeDescription, groupsCodes, professionsCodes, omriReturnsCodes, icd9Code, populationCodes, salCategoryID, salOrganCode,
                    basketApproveFromDate, basketApproveToDate, ADD_DATE_FromDate, ADD_DATE_ToDate, showCanceledServices, DEL_DATE_FromDate, DEL_DATE_ToDate,
                    internetUpdated_FromDate, internetUpdated_ToDate);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalServices_Populations(byte? includeInBasket, byte? common, byte? showServiceInInternet, byte? isActive, bool isLoggedIn, string searchText, int? serviceCode, string serviceDescription,
            string healthOfficeCode, string healthOfficeDescription, string groupsCodes, string professionsCodes, string omriReturnsCodes, string icd9Code,
            string populationCodes, int salCategoryID, int salOrganCode, DateTime? basketApproveFromDate, DateTime? basketApproveToDate, DateTime? ADD_DATE_FromDate,
            DateTime? ADD_DATE_ToDate, bool showCanceledServices, DateTime? DEL_DATE_FromDate, DateTime? DEL_DATE_ToDate, DateTime? internetUpdated_FromDate, DateTime? internetUpdated_ToDate)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetSalServices_Populations(includeInBasket, common, showServiceInInternet, isActive, isLoggedIn, searchText, serviceCode, serviceDescription, healthOfficeCode,
                    healthOfficeDescription, groupsCodes, professionsCodes, omriReturnsCodes, icd9Code, populationCodes, salCategoryID, salOrganCode,
                    basketApproveFromDate, basketApproveToDate, ADD_DATE_FromDate, ADD_DATE_ToDate, showCanceledServices, DEL_DATE_FromDate, DEL_DATE_ToDate,
                    internetUpdated_FromDate, internetUpdated_ToDate);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalServices_NewTests(byte? includeInBasket, byte? common, string searchText, int? serviceCode, string serviceDescription,
            string healthOfficeCode, string healthOfficeDescription, string groupsCodes, string professionsCodes, string omriReturnsCodes, string icd9Code,
            string populationCodes, DateTime? basketApproveFromDate, DateTime? basketApproveToDate, DateTime? ADD_DATE_FromDate,
            DateTime? ADD_DATE_ToDate, bool showCanceledServices, DateTime? DEL_DATE_FromDate, DateTime? DEL_DATE_ToDate)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetSalServices_NewTests(includeInBasket, common, searchText, serviceCode, serviceDescription, healthOfficeCode,
                    healthOfficeDescription, groupsCodes, professionsCodes, omriReturnsCodes, icd9Code, populationCodes, basketApproveFromDate,
                    basketApproveToDate, ADD_DATE_FromDate, ADD_DATE_ToDate, showCanceledServices, DEL_DATE_FromDate, DEL_DATE_ToDate);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }


        public DataSet GetSalServiceTarifonByServiceCode(int servicecode)
        {
            throw new NotImplementedException();
        }

        public DataSet GetSalServiceDetails(int servicecode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetSalServiceDetails(servicecode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalServiceTarifon(int servicecode, bool isBasicPermission)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetSalServiceTarifon(servicecode, isBasicPermission);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalServiceICD9(int servicecode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetSalServiceICD9(servicecode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalServiceTarifonHistory(int serviceCode, byte populationCode, byte subPopulationCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetSalServiceTarifonHistory(serviceCode, populationCode, subPopulationCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetPopulationDetails(byte populationCode, byte subPopulationCode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetPopulationDetails(populationCode, subPopulationCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalServiceHistoryDetails(int serviceCode, DateTime updateDate)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetSalServiceHistoryDetails(serviceCode, updateDate);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalCategories(int? salCategoryId, string salCategoryDescription)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetSalCategories(salCategoryId, salCategoryDescription);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetService),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }

        public void AddSalCategory(string salCategoryDescription, DateTime dtAdd_Date)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.AddSalCategory(salCategoryDescription, dtAdd_Date);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInAddSynonymToService),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void UpdateSalCategory(int salCategoryID, string salCategoryDescription)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.UpdateSalCategory(salCategoryID, salCategoryDescription);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void DeleteSalCategory(int salCategoryID)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.DeleteSalCategory(salCategoryID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetSalProfessionToCategories(int? salCategoryID, int? professionCode)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetSalProfessionToCategories(salCategoryID, professionCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetService),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }

        public void AddSalProfessionToCategory(int professionCode, int salCategoryID, DateTime dtAdd_Date, string updateUser)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.AddSalProfessionToCategory(professionCode, salCategoryID, dtAdd_Date, updateUser);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInAddSynonymToService),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void UpdateSalProfessionToCategory(int SalProfessionToCategoryID, int salCategoryID, int professionCode, string updateUser)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.UpdateSalProfessionToCategory(SalProfessionToCategoryID, salCategoryID, professionCode, updateUser);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void DeleteSalProfessionToCategory(int SalProfessionToCategoryID)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.DeleteSalProfessionToCategory(SalProfessionToCategoryID);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void AddSalServicesAdminComment(string title, string comment, DateTime? startDate, DateTime? expiredDate, byte active, string updateUser)
        {
            DateTime updateDate = DateTime.Now;

            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.AddSalServicesAdminComment(title, comment, startDate, expiredDate, active, updateDate, updateUser);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInAddSynonymToService),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void UpdateSalServicesAdminComment(int ID, string title, string comment, DateTime? startDate, DateTime? expiredDate, byte active, string updateUser)
        {
            DateTime updateDate = DateTime.Now;

            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.UpdateSalServicesAdminComment(ID, title, comment, startDate, expiredDate, active, updateDate, updateUser);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        public void DeleteSalServiceAdminComment(int adminCommentId)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.DeleteSalServiceAdminComment(adminCommentId);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetGroupsByName(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;
            try
            {
                ds = clinicMgr.GetGroupsByName(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }
            return ds;
        }

        public DataSet GetOmriReturnsByName(string searchStr)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicManager = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicManager.GetOmriReturnsByName(searchStr);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetProfessionsBySector),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalServiceInternetDetails(int servicecode)
        {
            BLFacadeActionNotifications.RaiseOnBLFacadeActionEnter(this.GetType());
            ClinicManager clinicMgr = new ClinicManager();
            DataSet ds = null;

            try
            {
                ds = clinicMgr.GetSalServiceInternetDetails(servicecode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetClinicByName_DistrictDepended),
                  new WebPageExtraInfoGenerator());
            }

            return ds;
        }

        public DataSet GetSalBodyOrgans()
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetSalBodyOrgans();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetService),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }

        public DataSet GetProfessionsForInternet(int? professionCode, string professionDescription)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetProfessionsForInternet(professionCode, professionDescription);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetService),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }


        public void UpdateProfessionForInternet(int professionCode, string professionDescriptionForInternet, string professionExtraData, byte showProfessionInInternet)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.UpdateProfessionForInternet(professionCode, professionDescriptionForInternet, professionExtraData, showProfessionInInternet);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInDeleteServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetMushlamServicesForSalService(int salServiceCode)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetMushlamServicesForSalService(salServiceCode);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetService),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }
        public DataSet GetSalServicesForUpdate(int ServiceCode, string ServiceDescription, int ServiceStatus, int ExtensionExists)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                return serviceManager.GetSalServicesForUpdate(ServiceCode, ServiceDescription, ServiceStatus, ExtensionExists);
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetService),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }

        public void UpdateServiceReturnExist(int serviceCode, int isChecked)
        {
            try
            {
                ServiceManager serviceManager = new ServiceManager();

                serviceManager.UpdateServiceReturnExist(serviceCode, isChecked);

            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInUpdateServiceSynonym),
                  new WebPageExtraInfoGenerator());
            }
        }

        public DataSet GetTypeOfDefenceList()
        {
            try
            {
                ClinicManager clinicManager = new ClinicManager();

                return clinicManager.GetTypeOfDefenceList();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetGeneralDataTable),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }

        public DataSet GetDefencePolicyList()
        {
            try
            {
                ClinicManager clinicManager = new ClinicManager();

                return clinicManager.GetDefencePolicyList();
            }
            catch (Exception ex)
            {
                ExceptionHandlingManager mgr = new ExceptionHandlingManager();
                mgr.Publish(ex, new ErrorMessagExtraInfoGenerator((int)eDIC_ErrorMessageInfo.BugInGetGeneralDataTable),
                  new WebPageExtraInfoGenerator());
            }
            return null;
        }
    }
}


