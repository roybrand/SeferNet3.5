using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for ILoadBalancerService
/// </summary>
public interface ILoadBalancerService : Clalit.Infrastructure.ServiceInterfaces.ICacheService
{
    void Stam();
}

public class LoadBalancerService : Clalit.Infrastructure.CacheManager.CacheManager, ILoadBalancerService
{

    #region ILoadBalancerService Members

    public void Stam()
    {
        
    }

    #endregion
}
