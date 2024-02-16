using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Collections;
using SeferNet.Globals;


namespace SeferNet.DataLayer
{
    public class AppQueries : Base.SqlDal
    {

        public AppQueries(string p_conString)
            : base(p_conString)
        {
        }

        public void GetQueryParameters(ref DataSet p_ds, int p_QueryNumber)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_QueryNumber };

            string spName = "rpc_GetQueryParameters";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void GetQueryFields(ref DataSet p_ds, int p_QueryNumber)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_QueryNumber };

            string spName = "rpc_GetQueryFields";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }
      
        private string GetHashtTableValue(Hashtable p_htbl, string key)
        {
            string hValue = String.Empty;

            if (p_htbl != null && p_htbl[key] != null)
            {
                hValue  = p_htbl[key].ToString();
            }
            return hValue;
        }



        public void GetReportDetails(ref DataSet p_ds, int p_CurrentReport)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { p_CurrentReport };

            string spName = "rpc_GetReportDetails";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);

        }
    }
}
