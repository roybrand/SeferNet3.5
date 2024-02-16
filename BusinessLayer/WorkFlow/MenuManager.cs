using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.DataLayer;
using System.Configuration;
using System.Data;
using System.Web;
using System.Xml;
using System.Xml.XPath;
using SeferNet.BusinessLayer.ADClalit;
using System.IO;
using System.Web.Security;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class MenuManager
    {
        string m_ConnStr;

        //constructor
        public MenuManager()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang(); 
        }

        public DataSet GetMainMenuData(List<Enums.UserPermissionType> userPermissions, string currentPageName)
        {
            DataSet ds = new DataSet();
            MenusDB menusDB = new MenusDB(m_ConnStr);
            StringBuilder delimitedPermissions = new StringBuilder();

            if (userPermissions == null)
            {
                userPermissions = new List<Enums.UserPermissionType>();                
            }
            
            // add permission which available to all
            if (!userPermissions.Contains(Enums.UserPermissionType.AvailableToAll))
                userPermissions.Add(Enums.UserPermissionType.AvailableToAll);

            foreach (Enums.UserPermissionType permission in userPermissions)
            {
                delimitedPermissions.Append((int)permission + ",");
            }

            return menusDB.GetMainMenuData(delimitedPermissions.ToString(), currentPageName);
        }

        public DataSet GetMainMenuItem(int itemID)
        {
            DataSet ds = new DataSet();
            MenusDB menusDB = new MenusDB(m_ConnStr);
            return menusDB.GetMainMenuItem(itemID);
        }

        public void InsertMainMenuItem(string title, string description, string url, string roles, int parentID, DataTable dtMainMenuRestrictions)
        {
            MenusDB menusDB = new MenusDB(m_ConnStr);
            int itemID = menusDB.InsertMainMenuItem(title, description, url, roles, parentID);

            if (dtMainMenuRestrictions != null) 
            {
                foreach (DataRow dr in dtMainMenuRestrictions.Rows)
                {
                    menusDB.InsertMainMenuRestriction(itemID, dr["PageName"].ToString());
                }
            }
        }

        public void UpdateMainMenuItem(int itemID, string title, string description, string url, string roles, DataTable dtMainMenuRestrictions)
        {
            MenusDB menusDB = new MenusDB(m_ConnStr);
            menusDB.UpdateMainMenuItem(itemID, title, description, url, roles);
            menusDB.DeleteMainMenuRestrictions(itemID);
            if (dtMainMenuRestrictions != null)
            {
                foreach (DataRow dr in dtMainMenuRestrictions.Rows)
                {
                    menusDB.InsertMainMenuRestriction(itemID, dr["PageName"].ToString());
                }
            }
        }

        public int UpdateMainMenu_MoveItem(int itemID, int moveDirection)
        {
            MenusDB menusDB = new MenusDB(m_ConnStr);
            return menusDB.UpdateMainMenu_MoveItem(itemID, moveDirection);
        }

        public int DeleteMainMenuItem(int itemID)
        {
            MenusDB menusDB = new MenusDB(m_ConnStr);
            return menusDB.DeleteMainMenuItem(itemID);
        }
    }
}
