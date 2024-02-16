using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.DataLayer;

using System.Data;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class UpdateTablesManager
    {
        string m_ConnStr;
        public UpdateTablesManager()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang(); 
        }

        public DataSet getTableData(string selectCommandText)
        {
            UpdateTablesDb up = new UpdateTablesDb();
            //DataSet ds = up.getTableData(selectCommandText);
            DataSet ds = new DataSet();
            return ds;
        }

        public void ModifyDbTable(DataSet ds, string selectCommandText)
        {
            //UpdateTablesDb up = new UpdateTablesDb();
            //up.ModifyDbTable(ds, selectCommandText);

        }

        public DataSet GetUnitTypeConvertSimul(int ConvertId)
        {
            ManageItems mi = new ManageItems(m_ConnStr);
            DataSet ds = mi.GetUnitTypeConvertSimul(ConvertId);
            return ds;
        }

        public void UpdateUnitTypeConvertSimul(int ConvertId, int Active, int TypeUnit, int PopSectorID)
        {
            string updateUser = new UserManager().GetLoggedinUserNameWithPrefix();

            ManageItems mi = new ManageItems(m_ConnStr);
            mi.UpdateUnitTypeConvertSimul(ConvertId, Active, TypeUnit, PopSectorID, updateUser);
        }
    }
}
