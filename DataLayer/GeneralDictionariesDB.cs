using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SeferNet.Globals;
using System.Data;

namespace SeferNet.DataLayer
{
    public class GeneralDictionariesDB: Base.SqlDalEx
    {

        public void UpdateEvent(int eventCode, string eventText, bool isActive, string updateUser)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { eventCode, eventText, isActive, updateUser };

            string spName = "rpc_updateEvent";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }


        public void AddFileToEvent(int eventCode, string fileName, string fileDisplayName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { eventCode, fileName, fileDisplayName };

            string spName = "rpc_AttachFileToEvent";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
        }

        /// <summary>
        /// deletes from db the given event file id, and return in the ref parameter - the file name in the FS
        /// need to be deleted
        /// </summary>
        /// <param name="eventFileID">event file id</param>
        /// <param name="physicalFileName">returns the related physical file name</param>
        public void DeleteEventFile(int eventFileID, ref string physicalFileName)
        {
            object[] outputParams = new object[1] { physicalFileName };
            object[] inputParams = new object[] { eventFileID };

            string spName = "rpc_DeleteEventFile";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);
            physicalFileName = outputParams[0].ToString();
        }


        public DataSet GetTreeViewEvents()
        {
            string spName = "rpc_GetTreeViewEvents";
            DBActionNotification.RaiseOnDBSelect(spName, new object[] { });
            return FillDataSet(spName);
        }

        public object GetNextEventCode()
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { };

            string spName = "rpc_GetNextEventCode";
            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

            if (outputParams != null)
            {
                return outputParams[0];
            }
            return null;
        }

        public void AddEvent(int eventCode, string desc, bool isActive, string userName)
        {
            object[] outputParams = new object[1] { new object() };
            object[] inputParams = new object[] { eventCode, desc, isActive, userName };

            string spName = "rpc_AddEvent";
            DBActionNotification.RaiseOnDBUpdate(spName, inputParams);
            ExecuteNonQuery(spName, Matrix.Infrastructure.GenericDal.ConnectionType.Write, ref outputParams, inputParams);

        }

        public DataSet GetReceptionDays(bool byDisplay)
        {
            
            string spName = "rpc_getReceptionDays";
            object[] inputParams = new object[] { byDisplay };
            object[] outputParams = new object[] { new object() };

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            
            return FillDataSet(spName,ref outputParams,inputParams);
            
        }

        public DataSet GetReceptionTypesByGeneralBelongings(bool isCommunity, bool isMushlam, bool isHospital)
        {

            string spName = "rpc_getReceptionTypesByGeneralBelongings";
            object[] inputParams = new object[] { isCommunity, isMushlam, isHospital };
            object[] outputParams = new object[] { new object() };

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            
            return FillDataSet(spName,ref outputParams,inputParams);
            
        }

        public void UpdateReceptionDays(int receptionDayCode, int display, int useInSearch)
        {

            string spName = "rpc_updateDIC_ReceptionDays";
            object[] inputParams = new object[] { receptionDayCode, display, useInSearch };

            DBActionNotification.RaiseOnDBSelect(spName, inputParams);
            ExecuteNonQuery(spName, inputParams);
        }
    }


}
