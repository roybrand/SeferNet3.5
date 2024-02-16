using System;
using System.Web.Caching;

namespace SeferNet.Globals
{
    /// <summary>
    /// Represents a cache items and cache handlers. 
    /// <summary>
    /// <example>
    /// The following code shows the usage of the cache handling.
    /// <code>
    /// //do something
    /// int cacheItem = CacheHandler.Instance.GetData<int>(CacheItemsEnum.CacheItemName);
    /// </code>
    /// </example>
    public class CacheHandler
    {
        #region members 

        private static CacheHandler _cacheHandler;

        System.Web.Caching.Cache _cache = System.Web.HttpContext.Current.Cache as System.Web.Caching.Cache;

        #endregion

        #region initialize

        /// <summary>
        /// Represent an instance of the <see cref="CacheHandler"/>. Read only
        /// </summary>
        public static CacheHandler Instance
        {
            get
            {
                if (_cacheHandler == null)
                    _cacheHandler = new CacheHandler();

                return (_cacheHandler);
            }
        }

        /// <summary>
        /// Represent an instance of the <see cref="CacheHandler"/>.
        /// </summary>
        private CacheHandler()
        {
            Cache _cache = new Cache();
        }

        #endregion

        /// <summary>
        /// Add the value associated with the given key into the cache (optional: for specified user).
        /// </summary>
        /// <param name="cacheType">Key of item to return from cache.</param>
        /// <param name="cacheValue"></param>
        /// <param name="userKey"></param>
        public void AddPersonalCacheItem(CacheItemsEnum cacheType, object cacheValue)
        {
            string uniqKew = string.Concat(System.Web.HttpContext.Current.Session.SessionID, "-", cacheType.ToString());

            if (_cache[uniqKew] != null)
            {
                _cache.Remove(uniqKew);
            }
            _cache.Add(
                uniqKew, cacheValue, null, 
                DateTime.Now.AddMinutes(20), Cache.NoSlidingExpiration, CacheItemPriority.High, null);
        }


        /// <summary>
        /// Returns the value associated with the given key (optional: for specified user).
        /// </summary>
        /// <typeparam name="T">Generic type parameter</typeparam>
        /// <param name="cacheType">Key of item to return from cache.</param>
        /// <param name="userKey">Current user uniq (optional)</param>
        /// <returns></returns>
        public T GetPersonalCacheItem<T>(CacheItemsEnum cacheType)
        {
            string uniqKew = string.Concat(System.Web.HttpContext.Current.Session.SessionID, "-", cacheType.ToString());
            
            object item = null;

            if (_cache[uniqKew] != null)
            {
                item = _cache[uniqKew];    
            }

            return (T)item;
        }
    }
}
