using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using Clalit.Global.EntitiesDal;
using Clalit.SeferNet.EntitiesDal;
using System.Data.Objects;
using EntityFrameworkHelper;

namespace Clalit.SeferNet.EntitiesBL
{
    public static  class EntityLoadHelper
    {
        /// <summary>
        /// Get all the application entities contexts, this is  used to initilize the cacheManager
        /// it's call when the cache is filling itself with entities data from the DB
        /// </summary>
        /// <returns></returns>
        public static List<EntityContextInfoBase> GetApplicationObjectContextList()
        {
            List<EntityContextInfoBase> contextList = new List<EntityContextInfoBase>();
            //contextList.Add(SeferNetEntitiesFactory.GetSeferNetEntities());
            contextList.Add(new SeferNetEntityContextInfo());
            contextList.Add(new ClalitEntityContextInfo());
            return contextList;

        }
    }
}
