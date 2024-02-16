using System;
using System.Resources;
using System.Globalization;
using System.Threading;
using System.Text;
using System.Data; 


namespace SeferNet.Globals
{
	/// <summary>
	/// Summary description for Utils.
	/// </summary>
	public class Utils
	{
        private ResourceManager m_ResourceManager = new ResourceManager("SeferNet.Globals.ResourceUpdateServices", System.Reflection.Assembly.GetExecutingAssembly());
		private CultureInfo m_HebrewCulture = new CultureInfo("he-IL");

		public Utils()
		{
			
		}
		
		public string GetHebrewString(string p_keyResource)
		{
			
			string result = "";
			try
			{
				Thread.CurrentThread.CurrentUICulture = m_HebrewCulture;
				result = m_ResourceManager.GetString(p_keyResource);										
			}
			catch (Exception ex)
			{
				throw new Exception(ex.Message); 
			}
			return result ;			
		}

		public string strReverse(string p_stringToReverse) 
		{
			StringBuilder sb1 = new StringBuilder(p_stringToReverse); 
			StringBuilder sb2 = new StringBuilder(); 

			int len = sb1.Length; 
			for(int i = len - 1; i >= 0; i--) 
				sb2.Append(p_stringToReverse[i]); 

			return sb2.ToString(); 
		}


        /// <summary>
        /// gets data table, and text column name, and returns the values comma seperated.
        /// if column "LinkedToEmpInDept" is exists, gets only the records that have "1" in that column 
        /// </summary>
        /// <param name="dt">data table</param>
        /// <param name="textColumnName">the column name</param>
        /// <returns>comma seperated string</returns>
        public static string GetDelimitedContentFromTable(DataTable dt, string textColumnName)
        {
            string returnStr = string.Empty;

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (dt.Columns.Contains("LinkedToEmpInDept"))
                {
                    if (Convert.ToBoolean(dt.Rows[i]["LinkedToEmpInDept"]))
                    {
                        returnStr += dt.Rows[i][textColumnName].ToString() + "; ";
                    }
                }
                else
                {
                    returnStr += dt.Rows[i][textColumnName].ToString() + "; ";
                }
            }


            if (!string.IsNullOrEmpty(returnStr))
            {
                returnStr.Substring(0, returnStr.LastIndexOf(";") + 1);
            }

            return returnStr;
        }
        public static bool IsServiceRelevantForReceivingGuests(int serviceCode)
        {
            string ServicesRelevantForReceivingGuests = System.Configuration.ConfigurationManager.AppSettings["ServicesRelevantForReceivingGuests"].ToString();
            string[] relevantServices = ServicesRelevantForReceivingGuests.Split(',');
            foreach (string service in relevantServices)
            {
                if (Convert.ToInt32(service) == serviceCode)
                    return true;
            }
            return false;
        }
        public static bool HasServiceRelevantForReceivingGuests(string servicesCodes)
        {
            string ServicesRelevantForReceivingGuests = System.Configuration.ConfigurationManager.AppSettings["ServicesRelevantForReceivingGuests"].ToString();
            string[] relevantServices = ServicesRelevantForReceivingGuests.Split(',');
            string[] services = servicesCodes.Split(',');

            foreach (string rel_service in relevantServices)
            {
                foreach (string service in services)
                {
                    if (Convert.ToInt32(rel_service) == Convert.ToInt32(service))
                        return true;
                }
            }
            return false;
        }

    }
}
