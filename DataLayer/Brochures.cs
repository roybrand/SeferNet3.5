using System;
using System.Data;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class Brochures : Base.SqlDalEx
    {
        public void GetBrochures(ref DataSet p_ds, bool isCommunity, bool isMushlam)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { isCommunity, isMushlam };
            string spName = "rpc_GetBrochures";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            p_ds = FillDataSet(spName, ref outputParams, inputParams);
        }

        public void InsertBrochure(string displayName, string fileName, int languageCode,
            bool isCommunity, bool isMushlam)
        {
            
            int count = 0;
            object[] inputParams = new object[] { displayName, fileName, languageCode, isCommunity, isMushlam };
            object[] outputParams = new object[] {  };

            count = ExecuteNonQuery("rpc_InsertNewBrochure", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void UpdateBrochure(int brochureID, string DisplayName, string fileName, int languageCode)
        {

            int count = 0;
            object[] inputParams = new object[] { brochureID, DisplayName, fileName, languageCode };
            object[] outputParams = new object[] { };

            count = ExecuteNonQuery("rpc_UpdateBrochure", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public void DeleteBrochure(int brochureID)
        {

            int count = 0;
            object[] inputParams = new object[] { brochureID };
            object[] outputParams = new object[] { };

            count = ExecuteNonQuery("rpc_DeleteBrochure", Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }
    }
}
