using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class AgreementTypeManager
    {
        public DataTable GetAgreementTypes()
        {
            DataTable retTable;
            ICacheService cache = ServicesManager.GetService<ICacheService>();
            retTable = cache.getCachedDataTable("DIC_AgreementTypes");
            return retTable;
        }
    }
}
