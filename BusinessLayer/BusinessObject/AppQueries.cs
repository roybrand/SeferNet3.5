using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

using SeferNet.DataLayer;
using System.Collections; 
namespace SeferNet.BusinessLayer.BusinessObject
{
    class AppQueries
    {
        string m_ConnStr;
        public AppQueries()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang(); 
        }

        public void GetQueryParameters(ref DataSet p_ds, int p_QueryNumber)
        {
            DataLayer.AppQueries appq = new DataLayer.AppQueries(m_ConnStr);

            appq.GetQueryParameters(ref p_ds, p_QueryNumber);
        }

        public void GetQueryFields(ref DataSet p_ds, int p_QueryNumber)
        {
            DataLayer.AppQueries appq = new DataLayer.AppQueries(m_ConnStr);
            appq.GetQueryFields(ref p_ds, p_QueryNumber);
        }       

        public void GetReportDetails(ref DataSet p_ds, int p_CurrentReport)
        {
            DataLayer.AppQueries appq = new DataLayer.AppQueries(m_ConnStr);
            appq.GetReportDetails(ref  p_ds,  p_CurrentReport);
  
        }
    }
}
