using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.Global.EntitiesDal;
using System.Configuration;
using EntityFrameworkHelper;

namespace Clalit.SeferNet.EntitiesBL
{
    public static class ClalitEntitiesFactory
    {
        private static string _ConnectionString;

        private static string GetConnectionStringFromConfig()
        {
            string connectionStringToReturn = string.Empty;
            if (string.IsNullOrEmpty(_ConnectionString) == true)
            {
                if (ConfigurationManager.ConnectionStrings[Consts.APP_CONFIG_CONNECTION_STRING_KEY] != null)
                {
                    _ConnectionString = ConfigurationManager.ConnectionStrings[Consts.APP_CONFIG_CONNECTION_STRING_KEY].ConnectionString;
                }
            }
            connectionStringToReturn = _ConnectionString;
            
            return connectionStringToReturn;
        }

        /// <summary>
        /// Initialize the entity DB object (ClalitEntities) with the connection string from the app/web config and
        /// returns it
        /// </summary>
        /// <returns></returns>
        public static ClalitEntities GetClalitEntities()
        {
            string connectionString = GetConnectionStringFromConfig();
            if (string.IsNullOrEmpty(connectionString) == true)
            {
                throw new Exception(string.Format("ConnectionString with key {0} is not defined in the Web.Config",  Consts.APP_CONFIG_CONNECTION_STRING_KEY));
            }

            return new ClalitEntities(DBConnectionHelper.GetConnection(connectionString, typeof(ClalitEntities).Name));
        }
    }
}
