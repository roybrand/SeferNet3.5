using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using SeferNet.DataLayer;
using System.Transactions;
using SeferNet.Globals;
using SeferNet.BusinessLayer.BusinessObject;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class ServiceManager
    {
        ServiceDal dal = new ServiceDal();
        string m_ConnStr;

        public ServiceManager()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang();
        }

        public DataSet GetServiceByNameOrCode(string prefixText)
        {
            return dal.GetServiceByNameOrCode(prefixText);
        }

        public DataSet GetServiceCategoriesByName(string prefixText)
        {
            return dal.GetServiceCategoriesByName(prefixText);
        }

        public DataSet GetServicesForUpdate(int? serviceCode, string serviceName, int? serviceCategory, int? sectorCode, int? requireQueueOrder, bool? isCommunity, 
                                                                                                    bool? isMushlam,bool? isHospitals)

        {
            return dal.GetServicesForUpdate(serviceCode, serviceName, serviceCategory, sectorCode, requireQueueOrder, isCommunity, isMushlam, isHospitals);
        }
        public DataSet GetServiceByCode(int serviceCode)
        {
            return dal.GetServiceByCode(serviceCode);
            
        }

        public DataSet GetServiceCategories(int? serviceCategoryID, string serviceCategoryDescription, int? subCategoryFromTableMF51)
        {
            DataSet ds = new DataSet();
            ServiceDal dal = new ServiceDal();
            return dal.GetServiceCategories(serviceCategoryID, serviceCategoryDescription, subCategoryFromTableMF51);
        }

        public DataSet GetServiceCategoriesExtended(int? serviceCode, string selectedValues)
        {
            return dal.GetServiceCategoriesExtended(serviceCode, selectedValues);
        }

        public DataSet GetServiceCategory(int serviceCategoryID)
        {
            DataSet ds = new DataSet();
            ServiceDal dal = new ServiceDal();
            return dal.GetServiceCategory(serviceCategoryID);
        }

        public int InsertServiceCategory(string serviceCategoryDescription, int? subCategoryFromTableMF51, string attributedServices)
        {
            ServiceDal dal = new ServiceDal();
            return dal.InsertServiceCategory(serviceCategoryDescription, subCategoryFromTableMF51, attributedServices);
        }

        public void UpdateServiceCategory(int serviceCategoryID, string serviceCategoryDescription, string attributedServices, int? subCategoryFromTableMF51)
        {
            ServiceDal dal = new ServiceDal();
            dal.UpdateServiceCategory(serviceCategoryID, serviceCategoryDescription, attributedServices, subCategoryFromTableMF51);
        }

        public void DeleteServiceCategory(int serviceCategoryID)
        {
            ServiceDal dal = new ServiceDal();
            dal.DeleteServiceCategory(serviceCategoryID);
        }

        

        public DataSet GetMF_Specialities051(int? code, string description)
        {
            DataSet ds = new DataSet();
            ServiceDal dal = new ServiceDal();
            return dal.GetMF_Specialities051(code, description);
        }

        public void UpdateService(int serviceCode, string serviceDesc, bool isService, bool isProfession, string sectors, bool isCommunity, bool isMushlam, bool isHospitals,
                                    string categories, bool enableExpert, string showExpert, int? SectorToShowWith, bool displayInInternet, bool requiresQueueOrder)
        {
            using (TransactionScope trans = TranscationScopeFactory.GetForUpdatedRecords())
            {
                dal.UpdateService(serviceCode, serviceDesc, isService, isProfession, sectors, isCommunity,
                                isMushlam, isHospitals, categories, enableExpert, showExpert, SectorToShowWith, displayInInternet, requiresQueueOrder);

                trans.Complete();
                trans.Dispose();
            }
        }

        public DataSet GetMF_Specialities051(int? code, string description, string selectedValues)
        {
            DataSet ds = new DataSet();
            ServiceDal dal = new ServiceDal();
            return dal.GetMF_Specialities051(code, description, selectedValues);
        }


        public void InsertService(int serviceCode, string serviceDesc, bool isService, bool isProfession, string sectors, 
                                    bool isCommunity, bool isMushlam, bool isHospitals, string categories, bool enableExpert, string showExpert, int? SectorToShowWith,
                                    bool displayInInternet, bool requiresQueueOrder)
        {
            ServiceDal dal = new ServiceDal();
            dal.InsertService(serviceCode,  serviceDesc,  isService,  isProfession,  sectors,
                                     isCommunity, isMushlam, isHospitals, categories, enableExpert, showExpert, SectorToShowWith, displayInInternet, requiresQueueOrder);
        }

        public void AddSynonymToService(string servicesCodes, string synonym)
        {
            ServiceDal dal = new ServiceDal();
            UserInfo user = new UserManager().GetUserInfoFromSession();

            dal.AddSynonymToService(servicesCodes, synonym.Trim(), user.UserNameWithPrefix);
        }

        public DataSet GetSynonymsByService(int? serviceCode, string serviceName, string synonym, int? categorie)
        {
            ServiceDal dal = new ServiceDal();

            if (!string.IsNullOrEmpty(serviceName))
            {
                serviceName = serviceName.Trim();
            }

            return dal.GetSynonymToService(serviceCode, serviceName, synonym, categorie);
        }

        public void DeleteServiceSynonym(int synonymID)
        {
            ServiceDal dal = new ServiceDal();

            dal.DeleteServiceSynonym(synonymID);
        }

        public void UpdateServiceSynonym(int synonymID, string synonym)
        {
            ServiceDal dal = new ServiceDal();
            UserInfo user = new UserManager().GetUserInfoFromSession();
            dal.UpdateServiceSynonym(synonymID, synonym.Trim(), user.UserNameWithPrefix);
        }

        #region MedicalAspects

        public DataSet GetClinicMedicalAspects(int deptCode)
        {
            ServiceDal dal = new ServiceDal();
            return dal.GetClinicMedicalAspects(deptCode);
        }

        public void InsertClinicMedicalAspects(int deptCode, string medicalAspectsList, string updateUser)
        {
            ServiceDal dal = new ServiceDal();
            dal.InsertClinicMedicalAspects(deptCode, medicalAspectsList, updateUser);
        }

        public void DeleteClinicMedicalAspect(int deptCode, int medicalAspectCode)
        {
            ServiceDal dal = new ServiceDal();
            dal.DeleteClinicMedicalAspect(deptCode, medicalAspectCode);
        }
        
        #endregion

        public DataSet GetSalCategories(int? salCategoryId, string salCategoryDescription)
        {
            ServiceDal dal = new ServiceDal();

            if (!string.IsNullOrEmpty(salCategoryDescription))
            {
                salCategoryDescription = salCategoryDescription.Trim();
            }
            
            return dal.GetSalCategories(salCategoryId, salCategoryDescription);
        }

        public void AddSalCategory(string salCategoryDescription, DateTime dtAdd_Date)
        {
            ServiceDal dal = new ServiceDal();
            UserInfo user = new UserManager().GetUserInfoFromSession();

            dal.AddSalCategory(salCategoryDescription, dtAdd_Date);
        }

        public void UpdateSalCategory(int salCategoryID, string salCategoryDescription)
        {
            ServiceDal dal = new ServiceDal();

            UserInfo user = new UserManager().GetUserInfoFromSession();

            dal.UpdateSalCategory(salCategoryID, salCategoryDescription.Trim());
        }

        public void DeleteSalCategory(int salCategoryID)
        {
            ServiceDal dal = new ServiceDal();

            dal.DeleteSalCategory(salCategoryID);
        }

        public DataSet GetSalProfessionToCategories(int? salCategoryID, int? professionCode)
        {
            ServiceDal dal = new ServiceDal();

            return dal.GetSalProfessionToCategories(salCategoryID, professionCode);
        }

        public void AddSalProfessionToCategory(int professionCode, int salCategoryID, DateTime dtAdd_Date , string updateUser)
        {
            ServiceDal dal = new ServiceDal();
            UserInfo user = new UserManager().GetUserInfoFromSession();

            dal.AddSalProfessionToCategory(professionCode, salCategoryID, dtAdd_Date, updateUser);
        }

        public void UpdateSalProfessionToCategory(int SalProfessionToCategoryID, int salCategoryID, int professionCode , string updateUser)
        {
            ServiceDal dal = new ServiceDal();

            UserInfo user = new UserManager().GetUserInfoFromSession();

            dal.UpdateSalProfessionToCategory(SalProfessionToCategoryID, salCategoryID, professionCode, updateUser);
        }

        public void DeleteSalProfessionToCategory(int SalProfessionToCategoryID)
        {
            ServiceDal dal = new ServiceDal();

            dal.DeleteSalProfessionToCategory(SalProfessionToCategoryID);
        }

        public DataSet GetSalBodyOrgans()
        {
            ServiceDal dal = new ServiceDal();

            return dal.GetSalBodyOrgans();           
        }

        public DataSet GetProfessionsForInternet(int? professionCode, string professionDescription)
        {
            ServiceDal dal = new ServiceDal();

            return dal.GetProfessionsForInternet(professionCode, professionDescription);
        }

        public void UpdateProfessionForInternet(int professionCode, string professionDescriptionForInternet, string professionExtraData, byte showProfessionInInternet)
        {
            ServiceDal dal = new ServiceDal();
            
            dal.UpdateProfessionForInternet(professionCode, professionDescriptionForInternet, professionExtraData, showProfessionInInternet);
        }

        public void AddSalServicesAdminComment(string title, string comment, DateTime? startDate, DateTime? expiredDate, byte active, DateTime updateDate, string updateUser)
        {
            ServiceDal dal = new ServiceDal();
            
            UserInfo user = new UserManager().GetUserInfoFromSession();

            dal.AddSalServicesAdminComment(title, comment, startDate, expiredDate, active, updateDate, updateUser);
        }

        public void UpdateSalServicesAdminComment(int ID, string title, string comment, DateTime? startDate, DateTime? expiredDate, byte active, DateTime updateDate, string updateUser)
        {
            ServiceDal dal = new ServiceDal();

            UserInfo user = new UserManager().GetUserInfoFromSession();

            dal.UpdateSalServicesAdminComment(ID , title, comment, startDate, expiredDate, active, updateDate, updateUser);
        }

        public void DeleteSalServiceAdminComment(int adminCommentId)
        {
            ServiceDal dal = new ServiceDal();

            dal.DeleteSalServiceAdminComment(adminCommentId);
        }

        public DataSet GetMushlamServicesForSalService(int salServiceCode)
        {
            ServiceDal dal = new ServiceDal();

            return dal.GetMushlamServicesForSalService(salServiceCode);
        }

        public DataSet GetSalServicesForUpdate(int ServiceCode, string ServiceDescription, int ServiceStatus, int ExtensionExists)
        {
            ServiceDal dal = new ServiceDal();

            return dal.GetSalServicesForUpdate(ServiceCode, ServiceDescription, ServiceStatus, ExtensionExists);
        }

        public void UpdateServiceReturnExist(int serviceCode, int isChecked)
        {
            ServiceDal dal = new ServiceDal();
            UserInfo user = new UserManager().GetUserInfoFromSession();
            dal.UpdateServiceReturnExist(serviceCode, isChecked);
        }
    }
}