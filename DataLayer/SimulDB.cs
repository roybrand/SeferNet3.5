using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Web;
using SeferNet.Globals;


namespace SeferNet.DataLayer
{
  public  class SimulDB : Base.SqlDal
    {
        SqlDataAdapter m_da;
        SqlConnection conn;

        public SimulDB(string p_conString): base(p_conString)
        {
        }


        public DataSet getSimulExceptions()
        {
            object[] outputParams = new object[1] { new object() };

            DataSet ds;

            string spName = "rpc_getSimulExceptions";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });
            ds = FillDataSet(spName, ref outputParams);

            return ds;
        }

        public void deleteSimulException(int simulExceptionID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { simulExceptionID };

            string spName = "rpc_deleteSimulExceptions";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

    }

}
