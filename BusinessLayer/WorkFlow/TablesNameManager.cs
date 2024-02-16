using System;
using Clalit.Infrastructure.ServiceInterfaces;
using System.Data;
using Clalit.Infrastructure.ServicesManager;


namespace SeferNet.BusinessLayer.WorkFlow
{
    public class TablesNameManager
    {
        public DataTable GetTablesName()
        {
            DataTable retTable;
            ICacheService cache = ServicesManager.GetService<ICacheService>();
            retTable = cache.getCachedDataTable("DIC_TablesName");
            return retTable;
        }
    }
}
