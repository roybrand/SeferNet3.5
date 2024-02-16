using System;
using System.Data;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class LanguagesManager
    {
        public DataTable GetLanguages()
        {
            DataTable retTable;
            ICacheService cache = ServicesManager.GetService<ICacheService>();
            retTable = cache.getCachedDataTable("View_Languages");
            return retTable;
        }
    }
}
