using System;
using System.Data;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class Forms : Base.SqlDalEx
    {
        public void GetForms(ref DataSet p_ds, bool isCommunity, bool isMushlam)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { isCommunity, isMushlam };

            string spName = "rpc_GetForms";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void InsertForm(string fileName, string formDisplayName,
            bool isCommunity, bool isMushlam)
        {

            int count = 0;
            object[] inputParams = new object[] { fileName, formDisplayName, isCommunity, isMushlam };
            object[] outputParams = new object[] { };

            count = ExecuteNonQuery("rpc_InsertNewForm", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void UpdateForm(int formID, string fileName, string formDisplayName)
        {

            int count = 0;
            object[] inputParams = new object[] {formID, fileName, formDisplayName };
            object[] outputParams = new object[] { };

            count = ExecuteNonQuery("rpc_UpdateForm", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteForm(int formID)
        {

            int count = 0;
            object[] inputParams = new object[] { formID };
            object[] outputParams = new object[] { };

            count = ExecuteNonQuery("rpc_DeleteForm", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }
    }
}
