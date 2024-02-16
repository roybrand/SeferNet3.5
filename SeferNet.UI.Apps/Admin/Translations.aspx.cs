using System;
using Newtonsoft.Json;
using System.Xml.Serialization;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.BusinessLayer.BusinessObject;

namespace SeferNet.UI.Apps.Admin
{
    public partial class Translations : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack == false)
            {
                UserManager userManager = new UserManager();

                UserInfo userInfo = userManager.GetUserInfoFromSession();

                if (Session["TranslationToken"] == null)
                {
                    BakaratKnisotService.IHandshakeService service = new BakaratKnisotService.HandshakeServiceClient();

                    BakaratKnisotService.GetTokenBaseInput tokenRequest = new BakaratKnisotService.GetTokenBaseInput()
                    {
                        IP = "192.160.10.10",
                        ApplicationCallingId = BakaratKnisotService.ApplicationEnum.SeferNet,
                        ApplicationDestinationId = BakaratKnisotService.ApplicationEnum.SeferNet,
                        EventDateTime = DateTime.Now,
                        MachineName = System.Environment.MachineName,
                        UserRealName = System.Security.Principal.WindowsIdentity.GetCurrent().Name.ToString().ToUpper(),
                        ApplicationJsonFormatParams = JsonConvert.SerializeObject(userInfo)
                    };

                    BakaratKnisotService.GetTokenBaseResult result = service.GetToken(tokenRequest);

                    string xmlTokenRequest = SerializeGetTokenBaseInput(tokenRequest);

                    string token = result.Token;

                    Session["TranslationToken"] = token;
                }

                const string defaultPage = "tables";
                const string defaultTable = "All";
                const string defaultTableTypeCode = "0";
                const string defaultStatusCode = "0";

                this.IframeLanguageManagement.Src = string.Format("{0}/{1}/{2}/{3}/{4}/{5}", "https://sefernettest.clalit.org.il:4444", defaultPage, defaultTable, defaultTableTypeCode, defaultStatusCode, Session["TranslationToken"]);
                
                this.IframeLanguageManagement.DataBind();
            }
        }

        private string SerializeGetTokenBaseInput(BakaratKnisotService.GetTokenBaseInput dataToSerialize)
        {
            var stringwriter = new System.IO.StringWriter();
            var serializer = new XmlSerializer(typeof(BakaratKnisotService.GetTokenBaseInput));
            serializer.Serialize(stringwriter, dataToSerialize);
            string s = stringwriter.ToString();
            return s;
        }

        private void oldRedirect(string token)
        {
            const string defaultPage = "translate";
            const string defaultTable = "All";
            const string defaultTableTypeCode = "0";
            const string defaultStatusCode = "0";

            string page = Request.QueryString["page"];
            string table = Request.QueryString["table"];
            string tableTypeCode = Request.QueryString["tableType"];
            string statusCode = Request.QueryString["status"];

            string link;

            if (page == null || page == "")
            {
                this.IframeLanguageManagement.Src = string.Format("{0}/{1}/{2}/{3}/{4}/{5}", "https://sefernettest.clalit.org.il:4444", defaultPage, defaultTable, defaultTableTypeCode, defaultStatusCode, "");
                //this.IframeLanguageManagement.Src = string.Format("{0}/{1}/{2}/{3}/{4}/{5}", "http://localhost:3000", "translate", "All", "0", "0", token);
                this.IframeLanguageManagement.DataBind();

                Session["TranslationPage"] = defaultPage;
                Session["TranslationTable"] = defaultTable;
                Session["TranslationTableTypeCode"] = defaultTableTypeCode;
                Session["TranslationStatusCode"] = defaultStatusCode;
                
                link = string.Format("{0}?page={1}&table={2}&tableType={3}&status={4}", Request.Url, defaultPage, defaultTable, defaultTableTypeCode, defaultStatusCode);
                
                Response.Redirect(link, false);

                return;
            }

            bool isNeedRedirect = false;

            object sessionPage = Session["TranslationPage"];
            if (sessionPage == null || sessionPage.ToString() != page)
            {
                Session["TranslationPage"] = page;
                isNeedRedirect = true;
            }

            object sessionTable = Session["TranslationTable"];
            if (sessionTable == null || sessionTable.ToString() != table)
            {
                Session["TranslationTable"] = table;
                isNeedRedirect = true;
            }

            object sessionTableCode = Session["TranslationTableTypeCode"];
            if (sessionTableCode == null || sessionTableCode.ToString() != tableTypeCode)
            {
                Session["TranslationTableTypeCode"] = tableTypeCode;
                isNeedRedirect = true;
            }

            object sessionStatusCode = Session["TranslationStatusCode"];
            if (sessionStatusCode == null || sessionStatusCode.ToString() != statusCode)
            {
                Session["TranslationStatusCode"] = statusCode;
                isNeedRedirect = true;
            }

            //Link = string.Format("{0}?page={1}&table={2}&tableType={3}&status={4}", Request.Url, page, table, tableTypeCode, statusCode);

            if (isNeedRedirect)
            {
                link = string.Format("{0}://{1}?page={2}&table={3}&tableType={4}&status={5}", Request.Url.Scheme ,Request.Url.Authority + Request.Url.AbsolutePath, page, table, tableTypeCode, statusCode);
                
                Response.Redirect(link, false);
            }
            else
            {
                this.IframeLanguageManagement.Src = string.Format("{0}/{1}/{2}/{3}/{4}/{5}", "https://sefernettest.clalit.org.il:4444", page, table, tableTypeCode, statusCode, token);
                this.IframeLanguageManagement.DataBind();
            }
        }

        private void redirect(string token)
        {
            const string defaultPage = "translate";
            const string defaultTable = "All";
            const string defaultTableTypeCode = "0";
            const string defaultStatusCode = "0";

            this.IframeLanguageManagement.Src = string.Format("{0}/{1}/{2}/{3}/{4}/{5}", "https://sefernettest.clalit.org.il:4444", defaultPage, defaultTable, defaultTableTypeCode, defaultStatusCode, token);
            //this.IframeLanguageManagement.Src = string.Format("{0}/{1}/{2}/{3}/{4}/{5}", "http://localhost:3000", "translate", "All", "0", "0", token);
            this.IframeLanguageManagement.DataBind();
        }
    }
}