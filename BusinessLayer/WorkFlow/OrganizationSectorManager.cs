using System.Data;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class OrganizationSectorManager
    {
        public DataTable OrganizationSectors()
        {
            DataTable retTable;
            ICacheService cache = ServicesManager.GetService<ICacheService>();
            retTable = cache.getCachedDataTable("DIC_OrganizationSector");
            return retTable;
        }
    }
}
