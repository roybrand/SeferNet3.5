using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.Global.EntitiesDal;
using Clalit.SeferNet.EntitiesDal;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using Clalit.SeferNet.Entities;

namespace Clalit.SeferNet.EntitiesBL
{
    public  class VMessageInfoLanguagesBL
    {
        private bool _IsUseCache = false;
        public bool IsUseCache
        {
            get { return _IsUseCache; }
            set { _IsUseCache = value; }
        }

        public VMessageInfoLanguagesBL()
        {

        }

        public VMessageInfoLanguagesBL(bool isUseCache)
        {
            _IsUseCache = isUseCache;
        }

        public List<VMessageInfoLanguages> GetAllMessages()
        {
            List<VMessageInfoLanguages> listToReturn = null;
            //********************* cache ???****************
            //here we can consider if we want to save all the messages in the cache
            //so we don't need to go to the DB every time some one want's to get a message            
            if (_IsUseCache == true)
            {
                EntityFrameworkHelper.ICacheWithEFService cache = ServicesManager.GetService<EntityFrameworkHelper.ICacheWithEFService>();
                listToReturn = cache.GetCacheEntities(eCachedTables.VMessageInfoLanguages.ToString()) as List<VMessageInfoLanguages>; 
            }

            //in case cache is not initialized from some reason
            if (listToReturn == null)
            {
                SeferNetEntities entities = SeferNetEntitiesFactory.GetSeferNetEntities();
				//entities.VMessageInfoLanguages.MergeOption = System.Data.Objects.MergeOption.NoTracking;
                var result = from v in entities.VMessageInfoLanguages
                             select v;
                listToReturn = result.ToList();
            }

            return listToReturn;
        }

        public VMessageInfoLanguages GetMessageInfo(int messageInfoId)
        {
            VMessageInfoLanguages messageInfoToReturn = null;
            try
            {
                ILoggedInUserService loggedInUserService = ServicesManager.GetService<ILoggedInUserService>();
                List<VMessageInfoLanguages> listAllFromCache = null;

                //look in cache if required
                if (_IsUseCache == true)
                {
                    EntityFrameworkHelper.ICacheWithEFService cache = ServicesManager.GetService<EntityFrameworkHelper.ICacheWithEFService>();
                    listAllFromCache = cache.GetCacheEntities(eCachedTables.VMessageInfoLanguages.ToString()) as List<VMessageInfoLanguages>;
                }

                if (listAllFromCache == null)
                {
                    //from DB
                    SeferNetEntities entities = SeferNetEntitiesFactory.GetSeferNetEntities();

                    var result = from v in entities.VMessageInfoLanguages
                                 where v.MessageInfoId == messageInfoId && v.ApplicationLanguageId == loggedInUserService.UserLanguageId
                                 select v;

                    listAllFromCache = result.ToList();
                }
                else
                {
                    //from list that was taken from  cache
                    var result = from v in listAllFromCache
                                 where v.MessageInfoId == messageInfoId && v.ApplicationLanguageId == loggedInUserService.UserLanguageId
                                 select v;

                    listAllFromCache = result.ToList();
                }

                if (listAllFromCache.Count == 1)
                {
                    messageInfoToReturn = listAllFromCache[0];
                }

            }
            catch (Exception ex)
            {
                //publish the exception
            }

            return messageInfoToReturn;

        }


        public VMessageInfoLanguages GetMessageInfo(eMessageInfo messageInfoEnum)
        {
            int messageInfoId = (int)messageInfoEnum;
            return GetMessageInfo(messageInfoId);
        }

        public VMessageInfoLanguages GetMessageInfo(eDIC_ConfQuestionMessageInfo messageInfoEnum)
        {
            int messageInfoId = (int)messageInfoEnum;
            return GetMessageInfo(messageInfoId);
        }

        public VMessageInfoLanguages GetMessageInfo(eDIC_DataValidationMessageInfo messageInfoEnum)
        {
            int messageInfoId = (int)messageInfoEnum;
            return GetMessageInfo(messageInfoId);
        }

        public VMessageInfoLanguages GetMessageInfo(eDIC_ErrorMessageInfo messageInfoEnum)
        {
            int messageInfoId = (int)messageInfoEnum;
            return GetMessageInfo(messageInfoId);
        }

        public VMessageInfoLanguages GetMessageInfo(eDIC_InformationMessageInfo messageInfoEnum)
        {
            int messageInfoId = (int)messageInfoEnum;
            return GetMessageInfo(messageInfoId);
        }
    }
}
