using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Data.SqlClient;
using SeferNet.DataLayer;
using System.Data;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
  public  class ManageItemsBO
    {
        private SqlConnection _conn= null;
        private ManageItems mng = null;
        /// <summary>
        /// Propery to hold our SQL connection
        /// </summary>
        private SqlConnection conn
        {
            get
            {
                if (_conn == null)
                    _conn = new SqlConnection(ConnectionHandler.ResolveConnStrByLang());

                return _conn;
            }
        }


        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataTable GetTreeViewProfessions()
        {
            mng = new ManageItems(conn.ConnectionString);
            DataSet ds = mng.GetTreeViewProfessions();
            if (ds != null && ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0)
                return ds.Tables[0];
            else
                return null;
        }
        

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataTable GetTreeViewPositions()
        {
            mng = new ManageItems(conn.ConnectionString);
            DataSet ds = mng.GetTreeViewPositions();
            if (ds != null && ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0)
                return ds.Tables[0];
            else
                return null;
        }
        
        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataTable GetTreeViewLanguages()
        {
            mng = new ManageItems(conn.ConnectionString);
            DataSet ds = mng.GetTreeViewLanguages();
            if (ds != null && ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0)
                return ds.Tables[0];
            else
                return null;
        }
       
        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataTable GetTreeViewhandicappedFacilities()
        {
            mng = new ManageItems(conn.ConnectionString);
            DataSet ds = mng.GetTreeViewhandicappedFacilities();
            if (ds != null && ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0)
                return ds.Tables[0];
            else
                return null;
        }

            [DataObjectMethod(DataObjectMethodType.Select)]
        public DataTable GetTreeViewServices()
        {
            mng = new ManageItems(conn.ConnectionString);
            DataSet ds = mng.GetTreeViewServices();
            if (ds != null && ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0)
                return ds.Tables[0];
            else
                return null;
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataTable GetTreeViewUnitTypes()
        {
            mng = new ManageItems(conn.ConnectionString);
            DataSet ds = mng.GetTreeViewUnitTypes();
            if (ds != null && ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0)
                return ds.Tables[0];
            else
                return null;
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataTable GetSubUnitTypes(int UnitTypeCode)
        {
            mng = new ManageItems(conn.ConnectionString);
            DataSet ds = mng.GetSubUnitTypes(UnitTypeCode);
            if (ds != null && ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0)
                return ds.Tables[0];
            else
                return null;
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataTable GetUnitTypes()
        {
            mng = new ManageItems(conn.ConnectionString);
            DataSet ds = mng.GetUnitTypes();
            if (ds != null && ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0)
                return ds.Tables[0];
            else
                return null;
        }
        
        public void UpdateLanguages(int code, int showInInternet, string userName)
        {
            try
            {
                ManageItems mng = new ManageItems(conn.ConnectionString);
                mng.UpdateLanguages(code, showInInternet, userName);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public void insertSubUnitTypes(string subUnitTypeCode, int unitTypeCode, string userName)
        {
            try
            {
                ManageItems dal = new ManageItems(conn.ConnectionString);
                dal.InsertSubUnitTypes(subUnitTypeCode, unitTypeCode, userName);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        public void UpdateUnitTypes(int code, string desc, string userName, bool showInInternet,
            bool allowQueueOrder, bool isActive, int defaultsubUnitCode, int categoryID)
        {
            try
            {
                ManageItems dal = new ManageItems(conn.ConnectionString);
                dal.UpdateUnitTypes(code, desc, userName, showInInternet, allowQueueOrder, isActive, defaultsubUnitCode, categoryID);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        [DataObjectMethod(DataObjectMethodType.Update)]
        public void UpdatePosition(int code, string name, int gender, string usrName, int sector, bool showInSearches, bool isActive)
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);
            dal.UpdatePosition(code, name, gender, usrName, sector, showInSearches, isActive);
        }

        [DataObjectMethod(DataObjectMethodType.Update)]
        public void UpdateHandicappedFacility(int code, string name, bool active)
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);
            dal.UpdateHandicappedFacility(code, name, active);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void AddUnitType(int newCode, string newDescription, bool allowQueueOrder,
                                                            bool showInInternet, int defaultSubUnitTypeCode, string userName, int categoryID)
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);

            dal.AddUnitType(newCode, newDescription, allowQueueOrder, showInInternet, defaultSubUnitTypeCode, userName, categoryID);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void AddSubUnitTypeCodeToUnitTypeCode(int subUnitTypeCode, int parentUnitTypeCode, string userName)
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);
            dal.AddSubUnitTypeCodeToUnitTypeCode(subUnitTypeCode, parentUnitTypeCode, userName);
        }

        public int AddPosition(int positionCode, int gender, string positionDescription, string updateUser, int sector)
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);
            return dal.AddPosition(positionCode, gender, positionDescription, updateUser, sector);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
        public void AddHandicappedFacility(int newCode, string newDescription, int active)
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);
            dal.AddHandicappedFacility(newCode, newDescription, active);
        }

        public bool DeleteSubUnitType(string parentCode, string code)
        {
            int records = -1;
            ManageItems dal = new ManageItems(conn.ConnectionString);
            records = dal.DeleteSubUnitType(parentCode, code);
            if (records > 0)
            {
                return true;
            }
            else
                return false;
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetRelevatSectors()
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);
            return dal.GetRelevatSectors();
        }

        public void UpdateMushlamProfessionMapping(int tableCode, int mappingID,
            int? mushlamServiceCode, int seferServiceCode, int? parentCode,
            int? groupCode, int? subgroupCode)
        {
            UserInfo user = new UserManager().GetUserInfoFromSession();
            ManageItems dal = new ManageItems(conn.ConnectionString);
            dal.UpdateMushlamProfessionMapping(tableCode, mappingID, mushlamServiceCode,
                                     seferServiceCode, parentCode, groupCode, subgroupCode, user.UserNameWithPrefix);
        }

        public void DeleteMushlamToSeferMapping(int id, int mushlamTableCode)
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);
            dal.DeleteMushlamToSeferMapping(id, mushlamTableCode);
        }

        public void InsertMushlamToSeferMapping(int tableCode, int? mushlamServiceCode, int seferServiceCode,
            int? parentCode, int? groupCode, int? subGroupCode)
        {
            UserInfo user = new UserManager().GetUserInfoFromSession();
            ManageItems dal = new ManageItems(conn.ConnectionString);
            dal.InsertMushlamToSeferMapping(tableCode, mushlamServiceCode, seferServiceCode, parentCode,
                groupCode, subGroupCode, user.UserNameWithPrefix);
        }

        public void AddNewMushlamToSeferMapping(int tableCode, int mushlamServiceCode, int? parentCode,
                                                                            int seferServiceCode)
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);

            dal.AddNewMushlamToSeferMapping(tableCode, mushlamServiceCode, parentCode, seferServiceCode,
                                                                                    new UserManager().GetLoggedinUserNameWithPrefix());
        }

        public DataSet GetServicesFromMFTables(string prefixText, string tableNum)
        {
            ManageItems dal = new ManageItems(conn.ConnectionString);

            return dal.GetServicesFromMFTables(prefixText, tableNum);
        }


    }
}

