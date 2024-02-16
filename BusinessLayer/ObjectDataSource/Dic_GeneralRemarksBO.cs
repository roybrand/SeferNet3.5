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
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.ObjectDataSource
{
    [DataObject(true)]
    public class Dic_GeneralRemarksBO
    {

        internal class Constants
        {
            //public const String SeferNetConnectionString = "SeferNetConnectionString";
        }

        /// <summary>
        /// priviate field for ObjData property
        /// </summary>
        private DataSet _objData;
      
		/// <summary>
        /// Property to hold our dataset
        /// </summary>
        public DataSet ObjData
        {
            get
            {
                if (_objData == null)
                    _objData = new DataSet("dsRemarks");

                return _objData;
            }
        }

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

        /// <summary>
        /// select method
        /// </summary>
        /// <param name="searchFilter">The parameter used to filter the data with</param>
        /// <returns>System.Data.Dataset</returns>
        [DataObjectMethod(DataObjectMethodType.Select)]
		public DataSet Select(int? remarkTypeint, bool userIsAdmin, int RemarkCategoryID)
        {
            RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);

			Enums.remarkType? remType = null;
			if (remarkTypeint != null)
			{
				remType = (Enums.remarkType)Enum.ToObject(typeof(Enums.remarkType), remarkTypeint);
			}
			DataSet ds = remarksdb.getDicGeneralRemarks(remType, userIsAdmin, RemarkCategoryID);
            return ds;
        }

        public DataSet getRemarkTags()
        {
            RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
            DataSet ds = remarksdb.getRemarkTags();
            return ds;
        }

        public DataSet getRemarkTagsToCreateRemark()
        {
            RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
            DataSet ds = remarksdb.getRemarkTagsToCreateRemark();
            return ds;
        }


        public DataSet GetGeneralRemarksToCorrect(int? remarkTypeint, bool userIsAdmin, int RemarkCategoryID)
        {
            RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);

			Enums.remarkType? remType = null;
			if (remarkTypeint != null)
			{
				remType = (Enums.remarkType)Enum.ToObject(typeof(Enums.remarkType), remarkTypeint);
			}
			DataSet ds = remarksdb.getDicGeneralRemarksToCorrect(remType, userIsAdmin, RemarkCategoryID);
            return ds;
        }

		public DataSet GetGeneralRemarkCategoriesByLinkedTo(int remarkTypeint, bool userIsAdmin)
		{
			RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);

			Enums.remarkType remType = (Enums.remarkType)Enum.ToObject(typeof(Enums.remarkType), remarkTypeint);

			DataSet ds = remarksdb.GetGeneralRemarkCategoriesByLinkedTo(remType, userIsAdmin);
			return ds;
		}

		public DataSet GetDIC_RemarkCategory()
		{
			RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
			DataSet ds = remarksdb.GetDIC_RemarkCategory();
			return ds;
		}

		public bool DeleteRemarkCategory(int RemarkCategoryID)
		{
			RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
			return remarksdb.DeleteRemarkCategory(RemarkCategoryID);
		}

		public bool UpdateRemarkCategory(int RemarkCategoryID, string RemarkCategoryName)
		{
			RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
			return remarksdb.UpdateRemarkCategory(RemarkCategoryID, RemarkCategoryName);
		}

		public bool ApproveDICRemark_AndUpdateRemarks(int DIC_remarkID, string UserName, string newRemarkText)
		{
			RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
			return remarksdb.ApproveDICRemark_AndUpdateRemarks(DIC_remarkID, UserName, newRemarkText);
		}

		public bool InsertRemarkCategory(string RemarkCategoryName)
		{
			RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
			return remarksdb.InsertRemarkCategory(RemarkCategoryName);
		}

        public bool RenewRemarks(int remarkID)
        {
			RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
			return remarksdb.RenewRemarks(remarkID);
        }

        [DataObjectMethod(DataObjectMethodType.Delete)]
		public void DeleteGeneralRemark(int remarkID)
        {
            RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
            remarksdb.deleteDic_GeneralRemark(remarkID);            
        }

        [DataObjectMethod(DataObjectMethodType.Select)]
		public DataSet GetGeneralRemarkByRemarkID(int remarkID)
        {
            RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
            return remarksdb.GetGeneralRemarkByRemarkID(remarkID);
        }

		public DataSet getGeneralRemarks_ToCorrect_ByRemarkID(int remarkID)
        {
            RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);
            return remarksdb.getGeneralRemarks_ToCorrect_ByRemarkID(remarkID);
        }

        [DataObjectMethod(DataObjectMethodType.Update)]
		public void UpdateDicGeneralRemark(
			int remarkID,
			string remark,
			int remarkCategory,
			bool active,
            bool linkedToDept,
			bool linkedToDoctor,
			bool linkedToDoctorInClinic,
			bool linkedToServiceInClinic,
            bool linkedToReceptionHours,
			bool EnableOverlappingHours,
            float factor,
            bool openNow,
            int showForPreviousDays,
            string UserName)
		{
            RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);

            remarksdb.UpdateDicGeneralRemark(
				remarkID,
                remark,
				remarkCategory,
                active,
                linkedToDept,
                linkedToDoctor,
                linkedToDoctorInClinic,
                linkedToServiceInClinic,
                linkedToReceptionHours,
                EnableOverlappingHours,
                factor,
                openNow,
                showForPreviousDays,
                UserName);
        }

        [DataObjectMethod(DataObjectMethodType.Insert)]
		public void InsertDicGeneralRemark(
			string remark,
			int remarkCategory,
			bool active,
			bool linkedToDept,
			bool linkedToDoctor,
			bool linkedToDoctorInClinic,
			bool linkedToServiceInClinic,
			bool linkedToReceptionHours,
			bool EnableOverlappingHours,
            float factor,
            bool openNow,
            int showForPreviousDays,
            string UserName)
        {
           RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);

           remarksdb.InsertDicGeneralRemark(
			   remark,
			   remarkCategory,
               active,
               linkedToDept,
               linkedToDoctor,
               linkedToDoctorInClinic,
               linkedToServiceInClinic,
               linkedToReceptionHours,
               EnableOverlappingHours,
               factor,
               openNow,
               showForPreviousDays,
               UserName);

        }

		public void InsertDicGeneralRemarkToCorrect(
			string remark,
			int DIC_GeneralRemarks_remarkID,
            string UserName)
        {
           RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);

           remarksdb.InsertDicGeneralRemarkToCorrect(
			   remark,
               DIC_GeneralRemarks_remarkID,
               UserName);
        }

		public void DeleteDicGeneralRemarkToCorrect(int DIC_GeneralRemarks_remarkID)
        {
           RemarksDB remarksdb = new RemarksDB(conn.ConnectionString);

           remarksdb.DeleteDicGeneralRemarkToCorrect(DIC_GeneralRemarks_remarkID);
        }

    }
}





