using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using SeferNet.Globals;
using System.IO;
using System.Xml; 

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class SendMessage
    {
        const string SendFaxesURLKey = "SendFaxesURL";
        static string SendFaxesURLValue = string.Empty;

        public enum SendType
        {
            SMS = 20,
            Fax = 30
        }
        public SendMessage()
        {
            if (string.IsNullOrEmpty(SendFaxesURLValue) == true)
            {
                SendFaxesURLValue = ConfigurationManager.AppSettings[SendFaxesURLKey];
            }
            InitMembers();
        }

        private void InitMembers()
        {
            ApplyID = 0;
            FileBase64Data = string.Empty;
            FileType = string.Empty;
            SenderName = string.Empty;
            SenderPhone = string.Empty;
            SendTo = string.Empty;
            SenderAccount = string.Empty;
            ApplicationCode = "237";
            FacilityCode = "071";
        }

        private bool _IsImage = false;
        private string _FileBase64Data;
        private string _FileType;
        private string _SenderName;
        private string _SenderPhone;
        private SendType _SendType = SendType.Fax;
        private string _SendTo;
        private string _ApplicationCode;
        private string _FacilityCode;
        private long _ApplyID;
        private string _SenderAccount;
        private string _ClientID = "990000099";
        private string _MessageText;
        private int _DistrictID = 0;
        private int _clinicId = 0;

        private string SenderAccount
        {
            get { return _SenderAccount; }
            set { _SenderAccount = value; }
        }

        private long ApplyID
        {
            get { return _ApplyID; }
            set { _ApplyID = value; }
        }

        private string FileBase64Data
        {
            get { return _FileBase64Data; }
            set { _FileBase64Data = value; }
        }

        private string FileType
        {
            get { return _FileType; }
            set { _FileType = value; }
        }

        private string SenderName
        {
            get { return _SenderName; }
            set { _SenderName = value; }
        }

        private string SenderPhone
        {
            get { return _SenderPhone; }
            set { _SenderPhone = value; }
        }

        private string SendTo
        {
            get { return _SendTo; }
            set { _SendTo = value; }
        }

        private string ApplicationCode
        {
            get { return _ApplicationCode; }
            set { _ApplicationCode = value; }
        }


        private string FacilityCode
        {
            get { return _FacilityCode; }
            set { _FacilityCode = value; }
        }

        // Convert String to Base64

        public static string StringToBase64(string str)
        {
            byte[] b = Encoding.GetEncoding(ConstsLangage.HEBREW_ENCODING_HTML).GetBytes(str);
            //byte[] b = System.Text.Encoding.UTF8.GetBytes(str);

            string b64 = Convert.ToBase64String(b);

            return b64;

        }


        private string BuildXML()
        {
            MemoryStream ms;
            XmlTextReader Reader;
            string Postpone = string.Empty;
            string strXML = string.Empty;

            string guid = System.Guid.NewGuid().ToString();

            Postpone = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss");

            StreamReader sReader = null;

            ms = new MemoryStream();
            XmlTextWriter tw = new XmlTextWriter(ms, System.Text.Encoding.UTF8);

            try
            {
                tw.WriteStartDocument();
                tw.WriteStartElement("MessagingService");
                tw.WriteAttributeString("xmlns", "http://www.clalit.org.il/EAI/1.0");
                tw.WriteAttributeString("xmlns", "xsi", null, "http://www.w3.org/2001/XMLSchema-instance");
                tw.WriteStartElement("MessageHeader");
                tw.WriteStartElement("Sending_Application");
                tw.WriteElementString("identifier", this.ApplicationCode);
                tw.WriteEndElement();//end of "Sending_Application"
                tw.WriteStartElement("Sending_Facility");
                tw.WriteElementString("identifier", FacilityCode);
                tw.WriteEndElement();//end of "Sending_Facility"
                tw.WriteStartElement("Message_Type");
                tw.WriteStartElement("Message_Type_ID");
                tw.WriteElementString("identifier", "MSR");
                tw.WriteEndElement();//End Message_Type_ID
                tw.WriteElementString("Version_ID", "1.10");
                tw.WriteEndElement();//end "Message_Type"

                tw.WriteElementString("Message_Control_ID", guid);//sUniqueNum);
                tw.WriteElementString("Date_Time_Of_Message", Postpone);
                tw.WriteStartElement("MessagingService");
                //tw.WriteElementString("identifier", _SendType == SendType.Fax ? "GM0002" : "GM0005"); //002 is for form17
                tw.WriteElementString("identifier", _SendType == SendType.Fax ? "GM0004" : "GM0005");
                tw.WriteEndElement();//End of "MessagingService"

                tw.WriteStartElement("ShipTo");
                tw.WriteStartElement("ContactIdentifiers");
                tw.WriteElementString("Id", _ClientID);
                tw.WriteStartElement("IdentifierType");
                tw.WriteElementString("identifier", _SendType == SendType.Fax ? "99" : "10");
                tw.WriteEndElement();//of IdentifierType
                tw.WriteEndElement();//of ContactIdentifiers
                tw.WriteStartElement("PreferredMethodOfContact");
                tw.WriteStartElement("CommunicationUseCode");
                tw.WriteElementString("identifier", "0" + (int)_SendType);//see reamarks below- 030==Fax
                //010	Email	אינטרנט מייל	כתובת מייל חוקית
                //020	SMS	מיסרונים	מס טלפון סלולארי, כולל קידומת
                //030 	Fax	פקסים	מס טלפון
                //040	KodKod Email	קודקוד מייל	כתובת קודקוד חוקית


                tw.WriteEndElement();//CommunicationUseCode
                if (_SendType == SendType.Fax && SendTo != null && SendTo != string.Empty)
                    tw.WriteElementString("Address", SendTo);

                tw.WriteEndElement();//of PreferredMethodOfContact
                tw.WriteEndElement();//End of "ShipTo"

                /*tw.WriteStartElement("ShipTo");
                tw.WriteStartElement("ContactIdentifiers");
                tw.WriteElementString("Id", _ClientID);
                tw.WriteStartElement("IdentifierType");
                tw.WriteElementString("identifier", "99");
                tw.WriteEndElement();//of IdentifierType
                tw.WriteEndElement();//of ContactIdentifiers
                tw.WriteStartElement("PreferredMethodOfContact");
                tw.WriteStartElement("CommunicationUseCode");
                tw.WriteElementString("identifier", "0" + (int)_SendType);
                tw.WriteEndElement();//CommunicationUseCode
                tw.WriteElementString("Address", SendToPhone);
                tw.WriteEndElement();//of PreferredMethodOfContact
                tw.WriteEndElement();//End of "ShipTo"*/

                tw.WriteEndElement();//End of "MessageHeader" Element    


                tw.WriteStartElement("UserAccount");
                tw.WriteElementString("Code", ApplicationCode + FacilityCode);
                tw.WriteEndElement();//End of "UserAccount" Element

                tw.WriteStartElement("Messages_Notes");

                // writing the file data as base64 
                if (FileType != null && FileType != string.Empty)
                {
                    tw.WriteStartElement("Attachments");

                    tw.WriteAttributeString("MediaType", FileType);

                    if (_SendType == SendType.Fax)
                    {
                        tw.WriteString(FileBase64Data); //To make System.Convert.ToBase64String						
                    }
                    else
                    {
                        tw.WriteRaw(FileBase64Data); //To make System.Convert.ToBase64String
                    }

                    tw.WriteEndElement();//End of "Attachments" Element
                    tw.WriteElementString("Text", string.Empty);
                }

                // write text message text
                if (_MessageText != null && _MessageText != string.Empty)
                {
                    tw.WriteElementString("Text", _MessageText);
                    if (_SenderPhone != null && _SenderPhone != string.Empty)
                    {
                        tw.WriteStartElement("AdditionalParameter");
                        tw.WriteElementString("text", "From");
                        tw.WriteStartElement("ParameterValue");
                        tw.WriteStartElement("Value");
                        tw.WriteElementString("text", _SenderPhone);
                        tw.WriteEndElement(); //End of "Value" element
                        tw.WriteEndElement(); //End of "ParameterValue" element
                        tw.WriteEndElement(); //End of "AdditionalParameter" element
                    }
                }

                //tw.WriteElementString("Text", "");

                tw.WriteEndElement();//End of "Messages_Notes" Element
                tw.WriteEndElement(); //End of "MessagingService" Element
                tw.WriteEndDocument();//END XMLDOCUMENT

            }
            catch { }

            try
            {
                tw.Flush();
                //string s= tw.
                ms.Position = 0;
                Reader = new XmlTextReader(ms);


                ms.Position = 0;

                sReader = new StreamReader(ms);

            }
            catch { }

            strXML = sReader.ReadToEnd();

            tw.Close();      //close XmlTextWriter           

            ms.Close();      //close MemoryStream

            sReader.Close(); //close StreamReader          

            return strXML;
        }

        public string SendFaxAsImage(long p_ApplyID, byte[] p_FileBinaryData, string p_SendToFaxNumber, string p_FileType, string p_SenderAccount, int p_DistrictID, int p_ClinicId)
        {
            //test
            //System.Drawing.Image img = System.Drawing.Image.FromFile(@"c:\1.jpg");
            //MemoryStream ms1 = new MemoryStream();
            // img.Save(ms1, System.Drawing.Imaging.ImageFormat.Jpeg);
            // ms1.Seek(0, SeekOrigin.Begin);
            // byte[] b = new byte[ms1.Length];
            // ms1.Read(b, 0, b.Length);
            _IsImage = true;

            string b64 = Convert.ToBase64String(p_FileBinaryData);

            return SendFax(p_ApplyID, b64, p_SendToFaxNumber, p_FileType, p_SenderAccount, p_DistrictID, p_ClinicId);
        }

        public string SendFax(long p_ApplyID, string p_FileData, string p_SendToFaxNumber, string p_FileType, string p_SenderAccount, int p_DistrictID, int p_ClinicId)
        {
            ApplyID = p_ApplyID;
            _clinicId = p_ClinicId;
            SendTo = p_SendToFaxNumber;
            FileBase64Data = StringToBase64(p_FileData);
            FileType = p_FileType;
            SenderAccount = p_SenderAccount;
            _DistrictID = p_DistrictID / 1000; // defined as smallint in WS DB

            int sendingApplication = Convert.ToInt32(ApplicationCode);
            int iAggrigateFilesSize = 0;

            string strXML = BuildXML();
            iAggrigateFilesSize = strXML.Length;
            string msgDescription = BuildMessageDescription();
            WSSendMessages.WSFaxSender ws = new WSSendMessages.WSFaxSender();
            //ws.Url = SendFaxesURLValue;
            string s = ws.SendFax(strXML, SenderAccount, sendingApplication, SendTo, iAggrigateFilesSize, _DistrictID, msgDescription);
            return s;
        }
        
        public string SendFax( string p_FileData, string p_SendToFaxNumber, string p_FileType, string p_SenderAccount)
        {
             SendTo = p_SendToFaxNumber;
            FileBase64Data = StringToBase64(p_FileData);
            FileType = p_FileType;
            SenderAccount = p_SenderAccount;
            //_DistrictID = p_DistrictID / 1000; // defined as smallint in WS DB
            _DistrictID = 10000 / 1000; // defined as smallint in WS DB

            int sendingApplication = Convert.ToInt32(ApplicationCode);
            int iAggrigateFilesSize = 0;

            string strXML = BuildXML();
            iAggrigateFilesSize = strXML.Length;
            string msgDescription = BuildMessageDescription();
            WSSendMessages.WSFaxSender ws = new WSSendMessages.WSFaxSender();
            //ws.Url = SendFaxesURLValue;
            string s = ws.SendFax(strXML, SenderAccount, sendingApplication, SendTo, iAggrigateFilesSize, _DistrictID, msgDescription);
            return s;
        }

        /// <summary>
        /// send sms
        /// </summary>
        /// <param name="p_MsgText">message text</param>
        /// <param name="p_ClientId">client id</param>
        /// <param name="p_SenderNumber">sender number</param>
        /// <param name="p_SenderAccount">sender ad account</param>
        /// <returns>guid if ok, else empty string</returns>
        public string SendSMS(long p_ApplyID, string p_MsgText, string p_ClientId, string p_SenderNumber, string p_SenderAccount, int p_DistrictID, int p_ClinicID)
        {
            ApplyID = p_ApplyID;
            _clinicId = p_ClinicID;
            _MessageText = p_MsgText;
            _ClientID = _SendTo = p_ClientId;
            _SenderPhone = p_SenderNumber;
            _SendType = SendType.SMS;
            SenderAccount = p_SenderAccount;
            _DistrictID = p_DistrictID / 1000; // defined as smallint in WS DB

            int sendingApplication = Convert.ToInt32(ApplicationCode);
            int iAggrigateFilesSize = 0;
            string strXML = BuildXML();
            iAggrigateFilesSize = strXML.Length;
            string msgDescription = BuildMessageDescription();

            WSSendMessages.WSFaxSender ws = new WSSendMessages.WSFaxSender();
            return ws.SendSMS(strXML, SenderAccount, sendingApplication, SendTo, iAggrigateFilesSize, _DistrictID, msgDescription);
        }

        private string BuildMessageDescription()
        {
            string xml = string.Empty;
            MemoryStream ms = new MemoryStream();
            XmlTextWriter writer = new XmlTextWriter(ms, Encoding.UTF8);
            StreamReader reader = null;
            try
            {
                writer.WriteStartDocument();
                writer.WriteStartElement("msgDescription");
                writer.WriteAttributeString("xmlns", "http://www.clalit.org.il/EAI/1.0");
                writer.WriteAttributeString("xmlns", "xsi", null, "http://www.w3.org/2001/XMLSchema-instance");
                writer.WriteElementString("applyId", _ApplyID.ToString());
                writer.WriteElementString("sender", _SenderAccount);
                writer.WriteElementString("clinicId", _clinicId.ToString());
                writer.WriteEndElement();

                writer.Flush();
                ms.Position = 0;
                reader = new StreamReader(ms);
                xml = reader.ReadToEnd();
            }
            catch (Exception ex)
            {
                string s = ex.Message;
            }
            finally
            {
                ms.Close();
                writer.Close();
                if (reader != null)
                    reader.Close();
            }

            return xml;
        }
    }
}
