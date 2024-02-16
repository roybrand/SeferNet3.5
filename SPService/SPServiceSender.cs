using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Configuration;

namespace SPS
{
    public class SPServiceSender
    {
        #region members

        /// <summary>
        /// Represents the local input parameters class value
        /// </summary>
        private SPServiceSenderParameters _input;

        /// <summary>
        /// Represents the sps service url
        /// </summary>
        private string _spsUri;

        /// <summary>
        /// Represents the clalit proxy address
        /// </summary>
        private string _proxyUri;

        /// <summary>
        /// Represents the clalit proxy port
        /// </summary>
        private int _proxyPort;

        const string spsUriKey = "spsUri";
        const string proxyUriKey = "proxyUri";
        const string proxyPortKey = "proxyPort";

        #endregion

        #region initz

        /// <summary>
        /// Initialization new instance of the class
        /// </summary>
        /// <param name="input"></param>
        public SPServiceSender(SPServiceSenderParameters input)
        {
            _input = input;
            //_spsUri = "https://sps-app.com/he/ajax.php"; // must be taken from config
            //_proxyUri = "proxy.clalit.org.il"; // must be taken from config
            //_proxyPort = 8080; // must be taken from config

            _spsUri = ConfigurationManager.AppSettings[spsUriKey];
            _proxyUri = ConfigurationManager.AppSettings[proxyUriKey];
            _proxyPort = Convert.ToInt32(ConfigurationManager.AppSettings[proxyPortKey]);
        }

        #endregion

        #region methods

        /// <summary>
        /// Runs the sps service
        /// </summary>
        public SPServiceSenderOutput RunUpdateService()
        {
            string dataString =
                  "action=" + "clalit"
               + "&title=" + _input.LocationName
               + "&location=" + _input.Latitude + ";" + _input.Longitude
               + "&adress=" + _input.Address
               + "&extra=" + _input.ExtraInformation
               + "&id=" + _input.DepartmentId.ToString();

            return SendLergacySPI(_spsUri, dataString);
        }

        /// <summary>
        /// Runs the legacy web client code
        /// </summary>
        /// <param name="dataString">converted form input class</param>
        /// <returns></returns>
        private SPServiceSenderOutput SendLergacySPI(string url, string dataString)
        {
            SPServiceSenderOutput output = new SPServiceSenderOutput();
            HttpWebResponse httpWebReponse = null;
            try
            {
                HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
                byte[] b = System.Text.Encoding.ASCII.GetBytes(dataString);
                request.Method = "POST";
                request.ContentType = "application/x-www-form-urlencoded";
                request.ContentLength = b.Length;

                WebProxy proxy = new WebProxy(_proxyUri, _proxyPort);
                request.Proxy = proxy;

                var stream = request.GetRequestStream();
                stream.Write(b, 0, b.Length);
                using (httpWebReponse = (HttpWebResponse)request.GetResponse())
                {
                    if (httpWebReponse.StatusCode != HttpStatusCode.OK)
                    {
                        var ex = httpWebReponse.StatusCode;
                    }
                    var result = httpWebReponse.GetResponseStream();
                    StreamReader sr = new StreamReader(result);

                    String responseString = sr.ReadToEnd();

                    output.ServiceAnswer = responseString;
                    output.SPServiceStatusCode = httpWebReponse.StatusCode.ToString();
                    output.ErrorMessage = string.Empty;
                }
            }
            catch (Exception exxx)
            {
                //logs exception in the log system

                output.ServiceAnswer = "Error";
                output.SPServiceStatusCode = (httpWebReponse == null) ? "Before running service" : httpWebReponse.StatusCode.ToString();
                output.ErrorMessage = exxx.Message;
            }

            return output;
        }

        #endregion
    }
}
