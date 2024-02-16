using Backend.Data;
using Backend.Entities.BusinessLayer.BusinessObject;
using Backend.Entities.BusinessLayer.WorkFlow;
using Backend.Utilities;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Backend.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    //AuthenticationController
    public class LoginController : ControllerBase // change controller name to auth
    {
        DataContext context;

        IConfiguration configuration;

        public LoginController(DataContext context, IConfiguration configuration)
        {
            this.context = context;
            this.configuration = configuration;
        }

        //This login function return bug result if the user not exists.
        [HttpPost]
        public UserInfo Login([FromBody] JsonElement data) //save data to cookie? https://stackoverflow.com/questions/30977809/saving-login-cookie-and-use-it-for-other-request
        {
            try
            {
                JsonDocument document = JsonDocument.Parse(data.ToString());

                JsonElement root = document.RootElement;

                //context.Logs.Add(new Log("SaveProduct post start. data => " + data.ToString(), "ProductController"));
                //context.SaveChanges();

                string domain = root.GetProperty("domain").ToString();
                string username = root.GetProperty("username").ToString();
                string password = root.GetProperty("password").ToString();

                UserManager userManager = new UserManager();
                UserInfo userInfo = userManager.GetUserFromAD(domain, username);

                /*string userWithDomain = "";
                string domainName = "";
                UserManager userManager = new UserManager();
                string activeDirectoryPath = userManager.BuildActiveDirectoryPath(domain);//"LDAP://DC=clalit,DC=org,DC=il";
                string userWithoutDomain = "";

                System.DirectoryServices.DirectoryEntry entry;
                System.DirectoryServices.DirectorySearcher searcher;
                System.DirectoryServices.SearchResult searchResult;

                UserInfo userInfo = new UserInfo();

                userWithDomain = domain + @"\" + username;
                domainName = System.IO.Path.GetDirectoryName(userWithDomain);

                userWithoutDomain = System.IO.Path.GetFileNameWithoutExtension(userWithDomain);

                entry = new System.DirectoryServices.DirectoryEntry(activeDirectoryPath, userWithDomain, password);
                searcher = new System.DirectoryServices.DirectorySearcher(entry);
                searcher.Filter = string.Format("(SAMAccountName={0})", userWithoutDomain);// "(SAMAccountName=" + userWithoutDomain + ")";
                searcher.PropertiesToLoad.Add("cn");

                try
                {
                    searchResult = searcher.FindOne();

                    if(searchResult == null)
                    {
                        return new UserInfo(1);
                    }
                }
                catch (Exception exception)
                {
                    return new UserInfo(2);
                }
                //return searchResult;

                System.DirectoryServices.DirectoryEntry directoryEntry = searchResult.GetDirectoryEntry();

                if (directoryEntry.Properties["extensionAttribute15"].Value != null && directoryEntry.Properties["extensionAttribute15"].ToString() != string.Empty && (directoryEntry.Properties["employeeID"].Value == null || directoryEntry.Properties["employeeID"].Value.ToString() == string.Empty))
                {
                    userInfo.UserID = Convert.ToInt64(directoryEntry.Properties["extensionAttribute15"].Value.ToString() + directoryEntry.Properties["extensionAttribute14"].Value.ToString());
                }
                else
                {
                    if (directoryEntry.Properties["employeeID"].Value != null && directoryEntry.Properties["employeeID"].ToString() != string.Empty)
                    {
                        userInfo.UserID = Convert.ToInt64(directoryEntry.Properties["employeeID"].Value.ToString());
                    }
                    else
                    {
                        userInfo.UserID = 0;
                    }
                }

                userInfo.UserAD = username;
                userInfo.Domain = domain;

                if (directoryEntry.Properties["title"].Value != null)
                {
                    userInfo.Title = directoryEntry.Properties["title"].Value.ToString();
                }
                else
                {
                    userInfo.Title = string.Empty;
                }

                userInfo.FirstName = directoryEntry.Properties["givenName"].Value.ToString();
                userInfo.LastName = directoryEntry.Properties["sn"].Value.ToString();
                userInfo.Name = directoryEntry.Properties["name"].Value.ToString();

                if (directoryEntry.Properties["telephoneNumber"].Value != null)
                {
                    userInfo.Phone = directoryEntry.Properties["telephoneNumber"].Value.ToString();
                }
                else
                {
                    userInfo.Phone = string.Empty;
                }

                if (directoryEntry.Properties["mobile"].Value != null)
                {
                    userInfo.PhoneMobile = directoryEntry.Properties["mobile"].Value.ToString();
                }
                else
                {
                    userInfo.PhoneMobile = string.Empty;
                }

                if (directoryEntry.Properties["facsimileTelephoneNumber"].Value != null)
                {
                    userInfo.Fax = directoryEntry.Properties["facsimileTelephoneNumber"].Value.ToString();
                }
                else
                {
                    userInfo.Fax = string.Empty;
                }

                if (directoryEntry.Properties["mail"].Value != null)
                {
                    userInfo.Mail = directoryEntry.Properties["mail"].Value.ToString();
                }
                else
                {
                    userInfo.Mail = string.Empty;
                }*/

                return userInfo;
            }
            catch(Exception exception)
            {
                Emails emails = new Emails(this.configuration);

                emails.Send("Error LoginController.Login", exception.ToString(), null);

                return new UserInfo(2);
            }
        }

        // GET api/<LoginController>/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "value";
        }

        // POST api/<LoginController>
        [HttpPost]
        public void Post([FromBody]string value)
        {

        }

        // PUT api/<LoginController>/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {

        }

        // DELETE api/<LoginController>/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {

        }
    }
}
