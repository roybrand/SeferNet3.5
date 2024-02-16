using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

using Clalit.Infrastructure.CacheManageService;
using System.ServiceModel.Activation;

// NOTE: If you change the class name "WCFCacheService" here, you must also update the reference to "WCFCacheService" in Web.config.
[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Required)]
public class WCFCacheService : BaseCacheService
{
    public WCFCacheService()
    {

    }
}
