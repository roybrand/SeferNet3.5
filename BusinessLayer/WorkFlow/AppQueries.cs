using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Collections; 


namespace SeferNet.BusinessLayer.WorkFlow
{
    public class AppQueries
    {
        public void GetQueryParameters(ref DataSet p_ds, int p_QueryNumber)
        {
            BusinessObject.AppQueries appq = new SeferNet.BusinessLayer.BusinessObject.AppQueries();

            appq.GetQueryParameters(ref p_ds, p_QueryNumber);
        }

        public void GetQueryFields(ref DataSet p_ds, int p_QueryNumber)
        {
            BusinessObject.AppQueries appq = new SeferNet.BusinessLayer.BusinessObject.AppQueries();
            appq.GetQueryFields(ref p_ds, p_QueryNumber);
        }       

        public void GetReportDetails(ref DataSet p_ds, int p_CurrentReport)
        {
            BusinessObject.AppQueries appq = new SeferNet.BusinessLayer.BusinessObject.AppQueries();
            appq.GetReportDetails(ref  p_ds,  p_CurrentReport);
 
        }
    }
}
