using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SeferNet.DataLayer.Base;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class ReportErrorDB: SqlDalEx
    {

        public void InsertIncorrectData(int deptCode, long employeeID, string errorDesc,
                    string pageUrl, string mailToList, DateTime ReportDate, string reportedBy)
        {
            object[] outputParams = { new object() };
            object[] inputParams = { deptCode, employeeID, errorDesc, pageUrl, mailToList, ReportDate, reportedBy };

            string spName = "rpc_InsertIncorrectDataReport";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public string GetMailtoList(long employeeID, int deptCode)
        {
            string mailList = string.Empty;
            object[] outputParams = { mailList };
            object[] inputParams = { employeeID, deptCode};

            string spName = "rpc_GetMailToList";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            if (outputParams[0] != null)
                return outputParams[0].ToString();
            else
                return null;
        }

        public string GetMailtoListForSalServices()
        {
            string mailList = string.Empty;
            object[] outputParams = { mailList };

            string spName = "rpc_GetMailToList_ForSalServices";
            DBActionNotification.RaiseOnDBInsert(spName, null);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Read, ref outputParams, null);

            if (outputParams[0] != null)
                return outputParams[0].ToString();
            else
                return null;
        }
    }
}
