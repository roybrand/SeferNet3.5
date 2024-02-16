using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SeferNet.DataLayer;
using Clalit.Infrastructure.ApplicationFileManager;
using SeferNet.BusinessLayer.WorkFlow;
using System.Transactions;
using SeferNet.Globals;
using System.Data;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    public class GeneralDictionariesBO
    {
        GeneralDictionariesDB _dal = new GeneralDictionariesDB();

        public void UpdateEvent(int eventCode, string EventText, bool isActive)
        {
           string userName = new UserManager().GetUserInfoFromSession().UserNameWithPrefix;
           
            _dal.UpdateEvent(eventCode, EventText, isActive, userName);
        }

        public void AddFileToEvent(int eventCode, string sourceFilePath)
        {
            FileManager file = new FileManager();
            char underscore = '_';

            using (TransactionScope trans = TranscationScopeFactory.GetForInsertedRecords())
            {
                string targetPath = ConfigHelper.GetEventFilesStoragePath();
                string extension = sourceFilePath.Substring(sourceFilePath.LastIndexOf('.') + 1);
                string fileDisplayName = sourceFilePath.Substring(sourceFilePath.LastIndexOf('\\') + 1);


                string fileName = eventCode.ToString() + underscore + DateTime.Now.Date.Day.ToString() +
                                    DateTime.Now.Date.Month.ToString() + DateTime.Now.Date.Year.ToString() +
                                    DateTime.Now.TimeOfDay.Hours.ToString() + DateTime.Now.TimeOfDay.Minutes.ToString() +
                                    DateTime.Now.TimeOfDay.Seconds.ToString() + "." + extension;


                file.SaveFileToPath(sourceFilePath, targetPath, fileName);

                _dal.AddFileToEvent(eventCode, fileName, fileDisplayName);

                
                trans.Complete();
                trans.Dispose();
            }
        }

        public void DeleteEventFile(int eventFileID)
        {
            FileManager file = new FileManager();

            using (TransactionScope trans = TranscationScopeFactory.GetForInsertedRecords())
            {
                string storagePath = ConfigHelper.GetEventFilesStoragePath();
                string physicalFileName = string.Empty;

                _dal.DeleteEventFile(eventFileID, ref physicalFileName);

                file.DeleteFile(storagePath + physicalFileName);                

                trans.Complete();
                trans.Dispose();
            }
        }

        public DataSet GetTreeViewEvents()
        {
            return _dal.GetTreeViewEvents();            
        }

        public int GetNextEventCode()
        {
            object obj = _dal.GetNextEventCode();
            int eventCode = 0;

            if (obj != null)
            {
                eventCode = Convert.ToInt32(obj);
            }

            return eventCode;
        }

        public void AddEvent(int eventCode, string desc, bool isActive, string userName)
        {
            _dal.AddEvent(eventCode, desc, isActive, userName);
        }

        public DataSet GetReceptionDays(bool byDisplay)
        {
            return _dal.GetReceptionDays(byDisplay);
        }

        public DataSet GetReceptionTypesByGeneralBelongings(bool isCommunity, bool isMushlam, bool isHospital)
        {
            return _dal.GetReceptionTypesByGeneralBelongings(isCommunity, isMushlam, isHospital);
        }

        public void UpdateReceptionDays(int receptionDayCode, int display, int useInSearch)
        {
            _dal.UpdateReceptionDays(receptionDayCode, display, useInSearch);
        }
    }
}
