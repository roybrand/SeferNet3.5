using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using SeferNet.Globals;
using SeferNet.DataLayer.Base;

namespace SeferNet.DataLayer
{
    public class ServiceDal : SqlDalEx
    {
        public DataSet GetServiceByNameOrCode(string prefixText)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { prefixText };
                        

            string spName = "rpc_getServiceByNameOrCode";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });

            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetServiceCategoriesByName(string prefixText)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { prefixText };


            string spName = "rpc_getServiceCategoriesByName";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });

            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetServicesForUpdate(int? serviceCode, string serviceName, int? serviceCategory, int? sectorCode, int? requireQueueOrder, bool? isCommunity, bool? isMushlam,
                                                                                                                            bool? isHospitals)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCode, serviceName, serviceCategory, sectorCode, requireQueueOrder, isCommunity, isMushlam, isHospitals };


            string spName = "rpc_GetServicesForUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });

            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }
        public DataSet GetServiceByCode(int serviceCode)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCode };


            string spName = "rpc_GetServiceByCode";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });

            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetServiceCategoriesExtended(int? serviceCode, string selectedValues)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCode, selectedValues };


            string spName = "rpc_GetServiceCategoriesExtended";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });

            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void UpdateService(int serviceCode, string serviceDesc, bool isService, bool isProfession, string sectors,
                                bool isCommunity, bool isMushlam, bool isHospitals, string categories, bool enableExpert, string showExpert, int? SectorToShowWith,
                                bool displayInInternet, bool requiresQueueOrder)
        {  
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] {  serviceCode, serviceDesc, isService, isProfession, sectors, 
                                        isCommunity, isMushlam, isHospitals, categories, enableExpert, showExpert,
                                        SectorToShowWith, displayInInternet, requiresQueueOrder};

                string spName = "rpc_UpdateService";
                DBActionNotification.RaiseOnDBDelete(spName, inputParams);
                ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        

        public void DeleteServiceCategory(int serviceCategoryID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCategoryID };

            string spName = "rpc_DeleteServiceCategory";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetServiceCategories(int? serviceCategoryID, string serviceCategoryDescription, int? subCategoryFromTableMF51)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCategoryID, serviceCategoryDescription, subCategoryFromTableMF51 };

            DataSet ds;

            string spName = "rpc_getServiceCategories";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetServiceCategory(int serviceCategoryID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCategoryID };

            DataSet ds;

            string spName = "rpc_getServiceCategory";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }


        public int InsertServiceCategory(string serviceCategoryDescription, int? subCategoryFromTableMF51, string attributedServices)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCategoryDescription, subCategoryFromTableMF51, attributedServices };

            string spName = "rpc_InsertServiceCategory";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return Convert.ToInt32(outputParams[0]);
        }

        public void UpdateServiceCategory(int serviceCategoryID, string serviceCategoryDescription, string attributedServices, int? subCategoryFromTableMF51)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCategoryID, serviceCategoryDescription, attributedServices, subCategoryFromTableMF51 };


            string spName = "rpc_UpdateServiceCategory";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public DataSet GetMF_Specialities051(int? code, string description, string selectedValues)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { code, description, selectedValues };

            DataSet ds;

            string spName = "rpc_GetMF_Specialities051";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetMF_Specialities051(int? code, string description)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { code, description, null };

            DataSet ds;

            string spName = "rpc_GetMF_Specialities051";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void InsertService(int serviceCode, string serviceDesc, bool isService, bool isProfession, string sectors,
                                        bool isCommunity, bool isMushlam, bool isHospitals, string categories, bool enableExpert, string showExpert, int? SectorToShowWith,
                                        bool displayInInternet, bool requiresQueueOrder)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCode,  serviceDesc,  isService,  isProfession,  sectors, 
                                                        isCommunity, isMushlam, isHospitals, categories, enableExpert, showExpert, SectorToShowWith,
                                                        displayInInternet, requiresQueueOrder };


            string spName = "rpc_InsertService";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void AddSynonymToService(string servicesCodes, string synonym, string userName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { servicesCodes, synonym, userName };
            string spName = "rpc_InsertSynonymToService";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetSynonymToService(int? serviceCode, string serviceName, string synonym, int? categorie)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCode, serviceName, synonym, categorie };

            DataSet ds;

            string spName = "rpc_GetSynonymsToService";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void UpdateServiceSynonym(int synonymID, string synonym, string userName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { synonymID, synonym, userName };

            string spName = "rpc_UpdateServiceSynonym";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteServiceSynonym(int synonymID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { synonymID};
            string spName = "rpc_DeleteServiceSynonym";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        #region MedicalAspects

        //rpc_GetClinicMedicalAspects
        public DataSet GetClinicMedicalAspects(int deptCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };

            DataSet ds;

            string spName = "rpc_GetClinicMedicalAspects";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void InsertClinicMedicalAspects(int deptCode, string medicalAspectsList, string updateUser)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode,  medicalAspectsList, updateUser };


            string spName = "rpc_InsertClinicMedicalAspects";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteClinicMedicalAspect(int deptCode, int medicalAspectCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode, medicalAspectCode };
            string spName = "rpc_DeleteClinicMedicalAspect";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        #endregion

        public DataSet GetSalCategories(int? salCategoryId, string salCategoryDescription)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { salCategoryId , salCategoryDescription };

            DataSet ds;

            string spName = "rpc_GetSalCategories";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void UpdateSalCategory(int salCategoryID, string salCategoryDescription)
        {
            object[] inputParams = new object[] { salCategoryID, salCategoryDescription };

            string spName = "rpc_UpdateSalCategory";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);

            ExecuteNonQuery(spName, inputParams);
        }

        public void DeleteSalCategory(int salCategoryID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { salCategoryID };

            string spName = "rpc_DeleteSalCategory";

            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void AddSalCategory(string salCategoryDescription, DateTime dtAdd_Date)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { salCategoryDescription, dtAdd_Date };

            string spName = "rpc_InsertSalCategory";

            DBActionNotification.RaiseOnDBDelete(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public DataSet GetSalProfessionToCategories(int? salCategoryID, int? professionCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { salCategoryID, professionCode };

            DataSet ds;

            string spName = "rpc_GetSalProfessionToCategories";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;            
        }

        public void AddSalProfessionToCategory(int professionCode, int salCategoryID, DateTime dtAdd_Date , string updateUser)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { professionCode, salCategoryID, dtAdd_Date, updateUser };

            string spName = "rpc_InsertSalProfessionToCategory";

            DBActionNotification.RaiseOnDBDelete(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);            
        }

        public void UpdateSalProfessionToCategory(int SalProfessionToCategoryID, int salCategoryID, int professionCode , string updateUser)
        {
            object[] inputParams = new object[] { SalProfessionToCategoryID, salCategoryID, professionCode, updateUser };

            string spName = "rpc_UpdateSalProfessionToCategory";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);

            ExecuteNonQuery(spName, inputParams);            
        }

        public void DeleteSalProfessionToCategory(int SalProfessionToCategoryID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { SalProfessionToCategoryID };

            string spName = "rpc_DeleteSalProfessionToCategory";

            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);            
        }

        public DataSet GetSalBodyOrgans()
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };

            DataSet ds;

            string spName = "rpc_GetSalBodyOrgans";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams);

            return ds;            
        }

        public DataSet GetProfessionsForInternet(int? professionCode, string professionDescription)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { professionCode, professionDescription };

            DataSet ds;

            string spName = "rpc_GetProfessionsForInternet";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public void UpdateProfessionForInternet(int professionCode, string professionDescriptionForInternet, string professionExtraData, byte ShowProfessionInInternet)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { professionCode, professionDescriptionForInternet, professionExtraData, ShowProfessionInInternet };

            string spName = "rpc_UpdateProfessionForInternet";

            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);            
        }

        public void AddSalServicesAdminComment(string title, string comment, DateTime? startDate, DateTime? expiredDate, byte active, DateTime updateDate, string updateUser)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { title, comment, startDate, expiredDate, active, updateDate, updateUser };

            string spName = "rpc_InsertAdminComment";

            DBActionNotification.RaiseOnDBDelete(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);            
        }

        public void UpdateSalServicesAdminComment(int ID, string title, string comment, DateTime? startDate, DateTime? expiredDate, byte active, DateTime updateDate, string updateUser)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { ID , title, comment, startDate, expiredDate, active, updateDate, updateUser };

            string spName = "rpc_UpdateAdminComment";

            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteSalServiceAdminComment(int adminCommentId)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { adminCommentId };

            string spName = "rpc_DeleteAdminComment";

            DBActionNotification.RaiseOnDBDelete(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }
        public DataSet GetMushlamServicesForSalService(int salServiceCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { salServiceCode };

            DataSet ds;

            string spName = "rpc_GetMushlamServicesForSalService";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }
        public DataSet GetSalServicesForUpdate(int ServiceCode, string ServiceDescription, int ServiceStatus, int ExtensionExists)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { ServiceCode, ServiceDescription, ServiceStatus, ExtensionExists };

            DataSet ds;

            string spName = "rpc_GetSalServicesForUpdate";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }
        public void UpdateServiceReturnExist(int serviceCode, int isChecked)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { serviceCode, isChecked };

            string spName = "rpc_UpdateServiceReturnExist";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

    }
}
