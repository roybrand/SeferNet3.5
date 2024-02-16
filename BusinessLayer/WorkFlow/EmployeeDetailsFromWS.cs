using System;
using System.Net;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using System.Security.Cryptography;
using SeferNet.BusinessLayer.BusinessObject;
using Microsoft.ApplicationBlocks.ExceptionManagement;
using SeferNet.BusinessLayer.ClalitOnlineWS_NEW;

namespace SeferNet.BusinessLayer.WorkFlow
{
    /// <summary>
    /// Summary description for EmployeeDetailsFromWS.
    /// </summary>
    public class EmployeeDetailsFromWS
    {
        private string _tzNumber = string.Empty;
        private string _district = string.Empty;
        private ClalitOnLine _patientResult = null;

        /// <summary>
        /// constractor that 
        /// </summary>
        /// <param name="TZNumber">Patient TZ number</param>
        public EmployeeDetailsFromWS(string tzNumber, string district)
        {
            //check XXX

            //assign
            _tzNumber = tzNumber;
            _district = district;
        }

        public DemogResults LoadPatientDetails()
        {
            ClalitCustomersResponse clalitCustomersResponse = GetResponse_NEW(_tzNumber, _district);

            DemogResults results = clalitCustomersResponse.Results;

            return results;
        }

        private ClalitCustomersResponse GetResponse_NEW(string patientId, string district)
        {
            ClalitCustomersResponse clalitCustomersResponse = new ClalitCustomersResponse();
            StringBuilder sb = new StringBuilder(1000);

            ClalitCustomersService onLine = new ClalitCustomersService();

            string userName = ConfigHelper.GetWebUserName();
            string password = ConfigHelper.GetWebUserPassword();
            string domain = ConfigHelper.GetWebUserDomain();

            try
            {
                byte[] data = new byte[50];
                byte[] key = new byte[50];
                HMACSHA1 cryptObj = new HMACSHA1(key);
                if (password != string.Empty)
                {
                    MemoryStream ms = new MemoryStream();
                    CryptoStream cs = new CryptoStream(Stream.Null, cryptObj, CryptoStreamMode.Write);
                    cs.Write(data, 0, data.Length);
                    cs.Close();
                    //password = Convert.ToBase64String(cryptObj.Hash, 0, cryptObj.Hash.Length); 
                    onLine.Credentials = new NetworkCredential(userName, password, domain);

                    ClalitCustomersRequest clalitCustomersRequest = new ClalitCustomersRequest();
                    clalitCustomersRequest.Parameters = new DemogParameters();
                    clalitCustomersRequest.MessageInfo = new DemogMessageInfo();

                    clalitCustomersRequest.Parameters.PatientId = Convert.ToInt64(patientId);
                    //clalitCustomersRequest.Parameters.PatientId = 2950806; //!!!!!!!!!!!!!!!!
                    clalitCustomersRequest.Parameters.PatientIdSpecified = true;
                    clalitCustomersRequest.Parameters.Decentralization = 1;

                    clalitCustomersRequest.MessageInfo.InstituteCode = 71;
                    clalitCustomersRequest.MessageInfo.Application = 237;
                    //clalitCustomersRequest.MessageInfo.MessageID = "361654e7-19b6-4c29-aefb-7298d3ac535e";//!!!!!!!!!!!!!!!!
                    clalitCustomersRequest.MessageInfo.MessageID = System.Guid.NewGuid().ToString();
                    clalitCustomersRequest.MessageInfo.DateSent = DateTime.Now;
                    clalitCustomersResponse = onLine.ClalitCustomersQuery(clalitCustomersRequest);
                }
            }
            catch (Exception ex)
            {
                string s = ex.Message;
            }

            //return xml string
            return clalitCustomersResponse;
        }


        #region properties

        /// <summary>
        /// the all Deserialize class
        /// </summary>
        public ClalitOnLine Result
        {
            get { return _patientResult; }
        }

        public string FirstName
        {
            get { return _patientResult.main.results.FirstName; }
        }

        public string LastName
        {
            get { return _patientResult.main.results.LastName; }
        }

        #endregion
    }

}
