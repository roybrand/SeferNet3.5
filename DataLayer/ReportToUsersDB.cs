using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SeferNet.DataLayer.Base;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class ReportToUsersDB : SqlDalEx
    {
        public string GetMailtoListOfNewClinic(int deptCode)
        {
            string mailList = string.Empty;
            object[] outputParams = { mailList };
            object[] inputParams = { deptCode };

            string spName = "rpc_GetMailToListAboutNewClinic";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            if (outputParams[0] != null)
                return outputParams[0].ToString();
            else
                return null;
        }
    }
}
