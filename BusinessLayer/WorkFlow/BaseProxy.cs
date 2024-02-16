using System;
using System.Net;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Security.Principal;
using OnlineCommon;

using System.Security.Cryptography.X509Certificates;


namespace OnlineCommon.Proxies
{
    /// <summary>
    /// A base class of all the proxies.
    /// </summary>

    public class BaseProxy : SoapHttpClientProtocol
    {
        private static string _baseUrl = string.Empty;
        private static X509Certificate certificate = null;
        /// <summary>
        /// base of all web services proxies
        /// </summary>
        public BaseProxy()
        {


            // string subjectName = ApplicationManager.Instance.CertificateSubjectName;
            //Todo... Move value subjectName="81" to web.config or Constant
            string subjectName = "81"; //
            if (subjectName != string.Empty)
            {


                X509Store store = new X509Store(StoreName.My, StoreLocation.LocalMachine);
                try
                {
                    store.Open(OpenFlags.ReadOnly);
                    certificate = store.Certificates.Find(X509FindType.FindBySubjectName, subjectName, false)[0];
                }
                // always close the store
                finally
                {
                    if (store != null)
                        store.Close();
                }


            }

        }

        protected void SetWSCertificate()
        {
            if (certificate != null)
            {
                //Add the certificate to client request
                this.ClientCertificates.Add(certificate);
            }
        }


    }
}
