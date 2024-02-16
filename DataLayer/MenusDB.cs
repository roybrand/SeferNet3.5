using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Web;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class MenusDB : Base.SqlDal
    {
        public MenusDB(string p_conString)
            : base(p_conString)
        {
        }

    #region MainMenu

        public DataSet GetMainMenuData(string delimitedPermissions, string currentPageName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { delimitedPermissions, currentPageName };
            DataSet ds;

            string spName = "rpc_getMainMenuData";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);

            return ds;
        }

        public DataSet GetMainMenuItem(int itemID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[1] { itemID };
            DataSet ds;

            string spName = "rpc_getMainMenuItem";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ds = FillDataSet(spName, ref outputParams, inputParams);
            
            return ds;
        }

        public int InsertMainMenuItem(string title, string description, string url, string roles, int parentID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { title, description, url, roles, parentID };
            string spName = "rpc_InsertMainMenuItem";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            return Convert.ToInt32(outputParams[0]);
        }

        public int UpdateMainMenuItem(int itemID, string title, string description, string url, string roles)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { itemID, title, description, url, roles };
            int ErrorCode = 0;


            string spName = "rpc_UpdateMainMenuItem";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
            return ErrorCode;
        }


        public int UpdateMainMenu_MoveItem(int itemID, int moveDirection)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { itemID, moveDirection };
            int ErrorCode = 0;

            string spName = "rpc_UpdateMainMenu_MoveItem";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
            return ErrorCode;
        }


        public int DeleteMainMenuItem(int itemID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { itemID };
            int ErrorCode = 0;

            string spName = "rpc_DeleteMainMenuItem";
            DBActionNotification.RaiseOnDBDelete(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            ErrorCode = Convert.ToInt32(outputParams[0]);
            return ErrorCode;
        }

        public void InsertMainMenuRestriction(int mainMenuItemID, string pageName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { mainMenuItemID, pageName };
            string spName = "rpc_InsertMainMenuRestriction";
            DBActionNotification.RaiseOnDBInsert(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        public void DeleteMainMenuRestrictions(int mainMenuItemID)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { mainMenuItemID };
            string spName = "rpc_DeleteMainMenuRestrictions";
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

    #endregion

    #region PrintTemplates
        public DataSet GetZoomClinicTemplate(int deptCode)
        {
            DataSet ds;
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { deptCode };
            string spName = "rpc_GetZoomClinicTemplate_temp";
            ds = FillDataSet(spName, ref outputParams, inputParams);
            return ds;
        }

    #endregion
    }
}
