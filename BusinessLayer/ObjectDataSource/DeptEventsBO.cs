using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
using System.ComponentModel;
using SeferNet.DataLayer;
using System.Globalization;
using System.IO;
using Clalit.Infrastructure.ApplicationFileManager;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class DeptEventsBO
    {

        /// <summary>
        /// private field for conn property
        /// </summary>
        private SqlConnection _conn;
        /// <summary>
        /// Propery to hold our SQL connection
        /// </summary>
        private SqlConnection conn
        {
            get
            {
                if (_conn == null)
                    _conn = new SqlConnection(ConnectionHandler.ResolveConnStrByLang());

                return _conn;
            }
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptEvents(int deptCode)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetDeptEvents(deptCode);
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
        public DataSet GetDeptEventForUpdate(int deptEventID)
        {
            ClinicDB clinicDB = new ClinicDB();
            return clinicDB.GetDeptEventByID(deptEventID);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
        public void DeleteDeptEvent(int deptEventID)
        {
            ClinicDB clinicDB = new ClinicDB();
            clinicDB.DeleteDeptEvent(deptEventID);
        }

        [DataObjectMethod(DataObjectMethodType.Update)]
        public void UpdateDeptEvent(int DeptEventID, int EventCode, string EventDescription,
            int MeetingsNumber, int RepeatingEvent, DateTime FromDate, DateTime ToDate,
            int RegistrationStatus, int PayOrder, float CommonPrice, float MemberPrice, float FullMemberPrice,
            string TargetPopulation, string Remark, int displayInInternet, string UpdateUser)
        {
            if (FromDate == DateTime.MinValue)
                FromDate = Convert.ToDateTime("1/1/1900");
            if (ToDate == DateTime.MinValue)
                ToDate = Convert.ToDateTime("1/1/1900");

            ClinicDB clinicDB = new ClinicDB();
            clinicDB.UpdateDeptEvent(DeptEventID, EventCode, EventDescription, MeetingsNumber, RepeatingEvent, FromDate, ToDate,
                RegistrationStatus, PayOrder, CommonPrice, MemberPrice, FullMemberPrice,
                TargetPopulation, Remark, displayInInternet, UpdateUser);
        }

        //[DataObjectMethod(DataObjectMethodType.Insert)]
        //public int InsertDeptEvent(int deptCode, int EventCode, string EventDescription,
        //    int MeetingsNumber, int RepeatingEvent, DateTime FromDate, DateTime ToDate,
        //    int RegistrationStatus, int PayOrder, float CommonPrice, float MemberPrice, float FullMemberPrice,
        //    string TargetPopulation, string Remark, int DisplayInInternet, string UpdateUser)
        //{
        //    if (FromDate == DateTime.MinValue)
        //        FromDate = Convert.ToDateTime("1/1/1900");
        //    if (ToDate == DateTime.MinValue)
        //        ToDate = Convert.ToDateTime("1/1/1900");

        //    ClinicDB clinicDB = new ClinicDB();
        //    int DeptEventIDInserted = clinicDB.InsertDeptEvent(deptCode, EventCode, EventDescription,
        //        MeetingsNumber, RepeatingEvent, FromDate, ToDate,
        //        RegistrationStatus, PayOrder, CommonPrice, MemberPrice, FullMemberPrice,
        //        TargetPopulation, Remark, DisplayInInternet, UpdateUser);

        //    return DeptEventIDInserted;
        //}


        public DataSet GetServicesAndEvents(string selectedValuesList)
        {
            ClinicDB dal = new ClinicDB();
            return dal.GetServicesAndEvents(selectedValuesList);
        }

        public void AttachFileToDeptEvent(int deptEventID, int deptCode, int eventID, string sourceFilePath, string savedFileName)
        {
            ClinicDB dal = new ClinicDB();
            
            string fileDisplayName = sourceFilePath.Substring(sourceFilePath.LastIndexOf('\\') + 1);          

            dal.AttachFileToDeptEvent(deptEventID, fileDisplayName, savedFileName);
        }


        public void DeleteAttachedFileToEvent(int deptEventFileID)
        {
            FileManager fileMan = new FileManager();
            ClinicDB dal = new ClinicDB();

            string filePath = ConfigHelper.GetEventFilesStoragePath();
            
            filePath  += GetFileNameByDeptEventFileID(deptEventFileID);            

            fileMan.DeleteFile(filePath);

            dal.DeleteAttachedFileToevent(deptEventFileID);
        }


        public string GetFileNameByDeptEventFileID(int deptEventFileID)
        {
            ClinicDB dal = new ClinicDB();

            return dal.GetFileNameByDeptEventFileID(deptEventFileID);

        }

        public DataSet GetDeptEventFiles(int deptEventID)
        {
            ClinicDB dal = new ClinicDB();

            return dal.GetDeptEventFiles(deptEventID);
        }
    }
}






