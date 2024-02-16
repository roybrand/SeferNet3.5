using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Collections;
using System.Configuration;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class MushlamDal : Base.SqlDalEx
    {
        DataClasses1DataContext dc;
        
        public MushlamDal()
        {
            dc = new DataClasses1DataContext(ConfigurationManager.ConnectionStrings[Globals.ConstsSystem.CONNECTION_STRING_CONFIG_ENTRY].ConnectionString);
        }


        public List<rpc_GetMushlamServiceByCodeResult> GetMushlamServiceByCode(int serviceCode)
        {
            return dc.rpc_GetMushlamServiceByCode(serviceCode).ToList();                        
        }

        public List<rpc_GetMushlamServiceExtendedSearchResult> GetMushlamServicesExtended(string searchText,
                                                                                          string deptName,
                                                                                          int? cityCode,
                                                                                          string districtCodes,
                                                                                          string inHour,
                                                                                          string fromHour,
                                                                                          string toHour,
                                                                                          string receptionDays,
                                                                                          int? deptCode)
        {
            return dc.rpc_GetMushlamServiceExtendedSearch(searchText, deptName, cityCode, districtCodes, inHour,
                                                                fromHour, toHour, receptionDays, deptCode).ToList();
        }

        public List<rpc_GetMushlamServicesByCodesSearchResult> GetMushlamServicesByCodesSearch( string serviceCodes,
                                                                                                string deptName,
                                                                                                int? cityCode,
                                                                                                string districtCodes,
                                                                                                string inHour,
                                                                                                string fromHour,
                                                                                                string toHour,
                                                                                                string receptionDays)
        {
            return dc.rpc_GetMushlamServicesByCodesSearch(serviceCodes, deptName, cityCode, districtCodes, inHour,
                                                                fromHour, toHour, receptionDays).ToList();
        }

        public List<rpc_GetMushlamModelsForServiceResult> GetMushlamModelsForService(int serviceCode)
        {
            return dc.rpc_GetMushlamModelsForService(serviceCode).ToList();
        }

        public DataSet GetMushlamConnectionTables(int? tableCode, string seferServiceName, string mushlamServiceName)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { tableCode, seferServiceName, mushlamServiceName };

            string spName = "rpc_GetMushlamConnectionTables";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        
    }
}
