using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.ComponentModel;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class ManageItems : Base.SqlDal
    {
        public ManageItems(string p_conString)
            : base(p_conString)
        {
        }

        public DataSet GetTreeViewProfessions()
        {
            string spName = "rpc_showProfessionsTree";
            DBActionNotification.RaiseOnDBUpdate(spName, new object[]{});
            return FillDataSet(spName);
        }

        public DataSet GetTreeViewPositions()
        {
            string spName = "rpc_showPositionsTree";
            DBActionNotification.RaiseOnDBUpdate(spName, new object[]{});
            return FillDataSet(spName);
        }

        public DataSet GetTreeViewLanguages()
        {
            string spName = "rpc_showLanguagesTree";
            DBActionNotification.RaiseOnDBUpdate(spName, new object[]{});
            return FillDataSet(spName);
        }

        public DataSet GetTreeViewhandicappedFacilities()
        {
            string spName = "rpc_showHandicappedFacilities";
            DBActionNotification.RaiseOnDBUpdate(spName, new object[]{});
            return FillDataSet(spName);
        }

        public DataSet GetTreeViewServices()
        {
            string spName = "rpc_showServicesTree";
            DBActionNotification.RaiseOnDBUpdate(spName, new object[]{});
            return FillDataSet(spName);
        }

        public DataSet GetTreeViewUnitTypes()
        {
            string spName = "rpc_showTreeViewUnitTypes";
            DBActionNotification.RaiseOnDBUpdate(spName, new object[]{});
            return FillDataSet(spName);             
        }

        public DataSet GetSubUnitTypes(int UnitTypeCode)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { UnitTypeCode };
            string spName = "rpc_getSubUnitTypes";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public DataSet GetUnitTypes()
        {
            string spName = "rpc_GetUnitTypes";
            DBActionNotification.RaiseOnDBUpdate(spName, new object[] { });
            return FillDataSet(spName);
        }

        public DataSet GetUnitTypeConvertSimul(int ConvertId)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { ConvertId };
            if (ConvertId == -1 || ConvertId == 0)
                inputParams[0] = null;
            string spName = "rpc_getUnitTypeConvertSimul";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }

        public void UpdateUnitTypeConvertSimul(int ConvertId, int Active, int TypeUnit, int PopSectorID, string UserUpdate)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { ConvertId, Active, TypeUnit, PopSectorID, UserUpdate };

            string spName = "rpc_UpdateUnitTypeConvertSimul";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void UpdateLanguages(int code, int showInInternet, string userName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };

            //update table subUnitType
            inputParams = new object[] { code, showInInternet, userName };
            string spName = "rpc_updateLanguages";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }
        
        public void UpdateUnitTypes(int code, string desc, string userName, bool showInInternet,
            bool allowQueueOrder, bool isActive, int defaultSubUnitTypeCode, int categoryID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };

            inputParams = new object[] { code, desc, userName, showInInternet, allowQueueOrder, isActive, defaultSubUnitTypeCode, categoryID};
            string spName = "rpc_updateUnitTypes";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void InsertSubUnitTypes(string subUnitTypeCode, int unitTypeCode, string userName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };

            inputParams = new object[] { subUnitTypeCode, unitTypeCode, userName };
            string spName = "rpc_insertSubUnitTypes";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void UpdatePosition(int code, string name, int gender, string usrName, int sector, bool showInSearches, bool isActive)
        {

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { code, name, gender, usrName, sector, showInSearches, isActive };

            string spName = "rpc_updatePosition";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void UpdateHandicappedFacility(int code, string name, bool active)
        {

            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { code, name, active };

            string spName = "rpc_updateHandicappedFacility";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public int AddUnitType(int newCode, string newDescription, bool allowQueueOrder, bool showInInternet,
                                                                                            int defaultSubUnitTypeCode, string userName, int categoryID)
        {
            int records = -1;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { newCode, newDescription, allowQueueOrder, showInInternet, defaultSubUnitTypeCode, userName, categoryID};

            string spName = "rpc_insertUnitType";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            records = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return records;
        }

        public void AddSubUnitTypeCodeToUnitTypeCode(int subUnitTypeCode, int parentUnitTypeCode, string userName)
        {
            int records = -1;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { subUnitTypeCode, parentUnitTypeCode, userName };

            string spName = "rpc_insertSubUnitTypeCodeToUnitTypeCode";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            records = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public int AddPosition(int positionCode, int gender, string positionDescription, string updateUser, int sector)
        {
            int records = -1;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { positionCode, gender, positionDescription, updateUser, sector };

            string spName = "rpc_insertPosition";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            records = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return records;
        }


        public int AddHandicappedFacility(int newCode, string newDescription, int active)
        {
            int records = -1;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { newCode, newDescription, active };

            string spName = "rpc_insertHandicappedFacility";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            records = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return records;
        }

        public int DeleteSubUnitType(string parentCode, string code)
        {
            int records = -1;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };

            //update table subUnitType
            inputParams = new object[] { parentCode, code };
            string spName = "rpc_deleteSubUnitType";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            records = ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            return records;
        }

        public DataSet GetRelevatSectors()
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[0] { };

            string spName = "rpc_GetRelevatSectors";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);
            return ds;
        }

        public void UpdateMushlamProfessionMapping(int tableCode, int mappingID,
            int? mushlamServiceCode, int seferServiceCode, int? parentCode,
            int? groupCode, int? subgroupCode, string updateUser)
        {
            object[] inputParams = new object[] { tableCode, mappingID, mushlamServiceCode, seferServiceCode,
                                                   parentCode, groupCode, subgroupCode, updateUser};
            object[] outputParams = new object[1] { new object() };

            string spName = "rpc_updateMushlamToSeferMapping";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams,
                                                                                            inputParams);
        }

        public void AddNewMushlamToSeferMapping(int tableCode, int mushlamServiceCode, int? parentCode, int seferServiceCode, string updateUser)
        {
            object[] inputParams = new object[] { tableCode, mushlamServiceCode, parentCode, seferServiceCode, updateUser };
            object[] outputParams = new object[1] { new object() };

            string spName = "rpc_insertMushlamToSeferServiceMapping";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);

            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams,
                                                                                            inputParams);
        }

        public void DeleteMushlamToSeferMapping(int id, int mushlamTableCode)
        {
            object[] inputParams = new object[] {id, mushlamTableCode};
            object[] outputParams = new object[1] { new object() };
            string spName = "rpc_deleteMushlamToSeferMapping";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams,
                                                                                            inputParams);
        }


        public void InsertMushlamToSeferMapping(int tableCode, int? mushlamServiceCode, int seferServiceCode,
            int? parentCode, int? groupCode, int? subGroupCode, string updateUser)
        {
            object[] inputParams = new object[] { tableCode, mushlamServiceCode, seferServiceCode, parentCode, groupCode, subGroupCode, updateUser };
            object[] outputParams = new object[1] { new object() };
            string spName = "rpc_insertMushlamToSeferMapping";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams,
                                                                                            inputParams);
        }


        public DataSet GetServicesFromMFTables(string prefixText, string tableNum)
        {
            object[] inputParams = new object[] { prefixText, tableNum };
            object[] outputParams = new object[1] { new object() };
            string spName = "rpc_GetServicesFromMFTables";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            return FillDataSet(spName, ref outputParams, inputParams);
        }
    }
}
