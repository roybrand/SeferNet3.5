using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

namespace Clalit.SeferNet.WCFInterfaces
{
    // NOTE: If you change the interface name "IStamService" here, you must also update the reference to "IStamService" in Web.config.
    [ServiceContract]
    public interface ILoadBalancerService
    {
        [OperationContract]
        void DoWork();

        [OperationContract(AsyncPattern = true)]
        IAsyncResult BeginReloadCacheItem(string itemName, AsyncCallback callback, object state);

        object EndReloadCacheItem(IAsyncResult result);

        [OperationContract(AsyncPattern = true)]
        IAsyncResult BeginRefreshCache(AsyncCallback callback, object state);

        object EndRefreshCache(IAsyncResult result);

        [OperationContract]
        bool TestService();
    }
}