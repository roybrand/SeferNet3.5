using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using SeferNet.DataLayer;
using SeferNet.BusinessLayer.BusinessObject;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class MushlamManager
    {
        MushlamDal dal = new MushlamDal();

        public MushlamService GetMushlamServiceByCode(int serviceCode, int groupCode, int subGroupCode)
        {
            List<rpc_GetMushlamServiceByCodeResult> list = dal.GetMushlamServiceByCode(serviceCode);

            MushlamService service = (from item in list
                                      where item.GroupCode == groupCode
                                      && item.SubGroupCode == subGroupCode
                                      select new MushlamService(item.ServiceCode, item.ServiceDescription, item.GeneralRemark,
                                          item.PrivateRemark, item.EligibilityRemark, item.AgreementRemark, item.LinkedSalServices, item.RepRemark,
                                          item.ClalitRefund, item.SelfParticipation, item.RequiredDocuments)
                                          ).ToList().First();
            return service;
        }

        public List<MushlamServiceSearchResults> GetMushlamServices(string serviceCodes, string searchWord, bool isExtendedSearch, 
                                                                                                        ClinicSearchParameters searchParams)
        {
            List<MushlamServiceSearchResults> services;

            
            if (isExtendedSearch || string.IsNullOrEmpty(searchWord))
            {
                 List<rpc_GetMushlamServiceExtendedSearchResult> list;

                 if (searchParams != null)
                 {
                     list = dal.GetMushlamServicesExtended(searchWord, searchParams.DeptName, searchParams.MapInfo.CityCode,
                                         searchParams.DistrictCodes, searchParams.CurrentReceptionTimeInfo.InHour,
                                         searchParams.CurrentReceptionTimeInfo.FromHour, searchParams.CurrentReceptionTimeInfo.ToHour,
                                         searchParams.CurrentReceptionTimeInfo.ReceptionDays, searchParams.DeptCode == -1 ? null : searchParams.DeptCode);
                 }
                 else
                 {
                     list = dal.GetMushlamServicesExtended(searchWord, null , null, null, null, null, null, null, null);                     
                 }

                 services = (from item in list
                             select new MushlamServiceSearchResults(item.ServiceCode, item.MushlamServiceName,
                               item.NumOfSuppliers ?? 0, item.GroupCode, item.SubGroupCode, item.OriginalServiceCode)).ToList();
            }
            else
            {
                List<rpc_GetMushlamServicesByCodesSearchResult> list;
                if (searchParams != null)
                {
                    list = dal.GetMushlamServicesByCodesSearch(serviceCodes, searchParams.DeptName, searchParams.MapInfo.CityCode,
                                                 searchParams.DistrictCodes, searchParams.CurrentReceptionTimeInfo.InHour,
                                                 searchParams.CurrentReceptionTimeInfo.FromHour, searchParams.CurrentReceptionTimeInfo.ToHour,
                                                 searchParams.CurrentReceptionTimeInfo.ReceptionDays);
                }
                else
                {
                    list = dal.GetMushlamServicesByCodesSearch(searchWord, null, null, null, null, null, null, null); 
                }

                services = (from item in list
                            select new MushlamServiceSearchResults(item.ServiceCode, item.MushlamServiceName,
                              item.NumOfSuppliers ?? 0, item.GroupCode, item.SubGroupCode, item.OriginalServiceCode)).ToList();
            }           



            return services;
        }

        public List<MushlamModel> GetMushlamModelsForService(int serviceCode)
        {
            List<rpc_GetMushlamModelsForServiceResult> list = dal.GetMushlamModelsForService(serviceCode);

            List<MushlamModel> retList = (from model in list
                                          select new MushlamModel(model.GroupCode, model.SubGroupCode, model.ModelDescription, model.Remark,
                                                                     model.WaitingPeriod, model.ParticipationAmount)).ToList();

            return retList;


        }

        public List<LinkedService> GetLinkedServicesForMushlamService(MushlamService service)
        {
            string[] linkedServices = service.LinkedBasketServices.Split(';');
            linkedServices = linkedServices.Where(item => item != string.Empty).ToArray();

            List<LinkedService> servicesList = (from ser in linkedServices
                                                select new LinkedService(Convert.ToInt32(ser.Split('#')[0]), ser.Split('#')[1])).ToList();
            return servicesList;
        }

        public DataSet GetMushlamConnectionTables(int? tableCode, string seferServiceName, string mushlamServiceName)
        {
            return new MushlamDal().GetMushlamConnectionTables(tableCode, seferServiceName, mushlamServiceName);
        }
    }
}
