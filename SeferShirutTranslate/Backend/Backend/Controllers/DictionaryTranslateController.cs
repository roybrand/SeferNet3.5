using Backend.Data;
using Backend.Models;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using Backend.Utilities;
using System.Data;
using System.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.Data.SqlClient;
using System.Linq;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System.Xml.Linq;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.CompilerServices;

namespace Backend.Controllers
{
    [ApiController]
    //public class DictionaryTranslateController : ControllerBase
    //public class DictionaryTranslateController<T> : Controller where T : class
    public class DictionaryTranslateController : ControllerBase
    {
        DataContext context;

        IConfiguration configuration;

        //bool isTokenValid;

        public DictionaryTranslateController(DataContext context, IConfiguration configuration)
        {
            this.context = context;
            this.configuration = configuration;
            //this.isTokenValid = false;
        }

        [HttpGet]
        [Route("api/[controller]/[action]")]
        public IActionResult GetTimestampChanges()
        {
            var result = this.context.Set<TimeStampHistoryDto>().FromSql($"rpc_GetChangesInDictionaryTables").ToList();

            return Ok(result);
        }

        [HttpPost]
        [Route("api/[controller]/[action]")]
        public async Task<IActionResult> CheckToken([FromBody] JsonElement data)
        {
            JsonDocument document = JsonDocument.Parse(data.ToString());

            JsonElement root = document.RootElement;

            string token = root.GetProperty("token").ToString();

            if (await checkToken(token) == false)
            {
                this.addLog("DictionaryTranslateController", "GetTranslates", string.Format("token is not valid. token => {0}", token));

                return BadRequest("Token no valid");
            }

            return Ok();
        }

        [HttpPost]
        [Route("api/[controller]/[action]")]
        public async Task<IActionResult> GetTranslates([FromBody] JsonElement data)
        {
            try
            {
                //this.SendEmail(JsonDocument.Parse(string.Format("{ function : {0}, exception: {1} }", "DictionaryTranslateController.GetTranslates", "")).RootElement);
                //this.SendEmail(JsonDocument.Parse(string.Format("{ \"token\": \"123456\" }", "DictionaryTranslateController.GetTranslates", "")).RootElement);

                JsonDocument document = JsonDocument.Parse(data.ToString());

                JsonElement root = document.RootElement;

                string tableName = root.GetProperty("tableName").ToString();
                int tableTypeCode = int.Parse(root.GetProperty("tableTypeCode").ToString());
                int statusCode = int.Parse(root.GetProperty("statusCode").ToString());
                int pageIndex = int.Parse(root.GetProperty("pageIndex").ToString()) - 1;
                int pageSize = int.Parse(root.GetProperty("pageSize").ToString());

                if (tableName == "All")
                {
                    /*(this.context.DicTranslations.Join(this.context.UnitTypes,
                                   code => translate.TableCode,
                                   //name => translate.TableName,
                                   //(code, name) => new { code = unitType.UnitTypeCode, name = unitType.UnitTypeName }
                                   (code) => new { code = unitType.UnitTypeCode }
                                    )).ToArray().Count*/

                    var result = (from translate in this.context.DicTranslations
                                  join language in this.context.Languages on translate.LanguageCode equals language.LanguageCode
                                  join tableType in this.context.TableTypes on translate.TableTypeCode equals tableType.Code
                                  join unitType in this.context.UnitTypes on new { code = translate.TableCode, name = translate.TableName } equals new { code = unitType.UnitTypeCode, name = "UnitType" } into unitTypeGroup
                                  from unitType in unitTypeGroup.DefaultIfEmpty()
                                  join activityStatus in this.context.DicActivityStatuses on new { code = translate.TableCode, name = translate.TableName } equals new { code = (int)activityStatus.Status, name = "DIC_ActivityStatus" } into activityStatusGroup
                                  from activityStatus in activityStatusGroup.DefaultIfEmpty()
                                  join agreementType in this.context.DicAgreementTypes on new { code = translate.TableCode, name = translate.TableName } equals new { code = (int)agreementType.AgreementTypeId, name = "DIC_AgreementTypes" } into agreementGroup
                                  from agreementType in agreementGroup.DefaultIfEmpty()
                                  join dept in this.context.Depts on new { code = translate.TableCode, name = translate.TableName } equals new { code = dept.DeptCode, name = "Dept" } into deptGroup
                                  from dept in deptGroup.DefaultIfEmpty()
                                  join yesAndNo in this.context.DicYesAndNos on new { code = translate.TableCode, name = translate.TableName } equals new { code = yesAndNo.Id, name = "yesAndNo" } into yesAndNoGroup
                                  from yesAndNo in yesAndNoGroup.DefaultIfEmpty()

                                  select new
                                  {
                                      translate.Id,
                                      translate.TableName,
                                      translate.TableCode,
                                      translate = translate.Translate == null ? "" : translate.Translate,
                                      tableTypeCode = tableType.Code,
                                      unitType = (unitType == null ? "" : unitType.UnitTypeName),
                                      unitTypeTimestamp = unitType == null ? "" : Convert.ToBase64String(unitType.TimeStamp),
                                      activityStatus = (activityStatus.StatusDescription == null ? "" : activityStatus.StatusDescription),
                                      activityStatusTimestamp = activityStatus.StatusDescription == null ? "" : Convert.ToBase64String(activityStatus.TimeStamp),
                                      agreementType = (agreementType == null ? "" : agreementType.AgreementTypeDescription),
                                      agreementTypeTimestamp = agreementType == null ? "" : Convert.ToBase64String(agreementType.TimeStamp),
                                      dept = (dept == null ? "" : dept.DeptName),
                                      deptTimestamp = dept == null ? "" : Convert.ToBase64String(dept.TimeStamp),
                                      language.LanguageDescription,
                                      translate.LastUpdate,
                                      totalCount = (from translate in this.context.DicTranslations
                                                    join language in this.context.Languages on translate.LanguageCode equals language.LanguageCode
                                                    select translate.Id).ToList().Count


                                  }).OrderBy(row => row.Id).Skip(pageIndex * pageSize).Take(pageSize).ToList();

                    return Ok(result);
                }
                else
                {
                    var result = (from translate in this.context.DicTranslations
                                  join language in this.context.Languages on translate.LanguageCode equals language.LanguageCode
                                  join tableType in this.context.TableTypes on translate.TableTypeCode equals tableType.Code
                                  join unitType in this.context.UnitTypes on new { code = translate.TableCode, name = translate.TableName } equals new { code = unitType.UnitTypeCode, name = "UnitType" } into unitTypeGroup
                                  from unitType in unitTypeGroup.DefaultIfEmpty()
                                  join activityStatus in this.context.DicActivityStatuses on new { code = translate.TableCode, name = translate.TableName } equals new { code = (int)activityStatus.Status, name = "DIC_ActivityStatus" } into activityStatusGroup
                                  from activityStatus in activityStatusGroup.DefaultIfEmpty()
                                  join agreementType in this.context.DicAgreementTypes on new { code = translate.TableCode, name = translate.TableName } equals new { code = (int)agreementType.AgreementTypeId, name = "DIC_AgreementTypes" } into agreementGroup
                                  from agreementType in agreementGroup.DefaultIfEmpty()
                                  join dept in this.context.Depts on new { code = translate.TableCode, name = translate.TableName } equals new { code = dept.DeptCode, name = "Dept" } into deptGroup
                                  from dept in deptGroup.DefaultIfEmpty()
                                  join yesAndNo in this.context.DicYesAndNos on new { code = translate.TableCode, name = translate.TableName } equals new { code = yesAndNo.Id, name = "yesAndNo" } into yesAndNoGroup
                                  from yesAndNo in yesAndNoGroup.DefaultIfEmpty()
                                  where translate.TableName == tableName 

                                  select new
                                  {
                                      translate.Id,
                                      translate.TableName,
                                      translate.TableCode,
                                      translate = translate.Translate == null ? "" : translate.Translate,
                                      tableTypeCode = tableType.Code,
                                      unitType = (unitType == null ? "" : unitType.UnitTypeName),
                                      unitTypeTimestamp = unitType == null ? "" : Convert.ToBase64String(unitType.TimeStamp),
                                      activityStatus = (activityStatus.StatusDescription == null ? "" : activityStatus.StatusDescription),
                                      activityStatusTimestamp = activityStatus.StatusDescription == null ? "" : Convert.ToBase64String(activityStatus.TimeStamp),
                                      agreementType = (agreementType == null ? "" : agreementType.AgreementTypeDescription),
                                      agreementTypeTimestamp = agreementType == null ? "" : Convert.ToBase64String(agreementType.TimeStamp),
                                      dept = (dept == null ? "" : dept.DeptName),
                                      deptTimestamp = dept == null ? "" : Convert.ToBase64String(dept.TimeStamp),
                                      language.LanguageDescription,
                                      translate.LastUpdate,
                                      totalCount = (from translate in this.context.DicTranslations
                                                    join language in this.context.Languages on translate.LanguageCode equals language.LanguageCode
                                                    select translate.Id).ToList().Count

                                  }).OrderBy(row => row.Id).Skip(pageIndex * pageSize).Take(pageSize).ToList();

                    return Ok(result);
                }

                //Emails emails = new Emails(this.configuration);
                //emails.Send("function", "exception", null);
                //return result;
                //return Ok(result);
                //return this.context.DicTranslates.ToList();
            }
            catch (Exception exception)
            {
                this.addLog("DictionaryTranslateController", "GetTranslates", exception.ToString());

                //JsonElement response = new JsonParser().parse(jsonString);
                //JsonElement j = new JsonParser.parse(jsonString);
                //JsonDocument j = JsonDocument.Parse(exception.ToString());

                //this.SendEmail(JsonDocument.Parse(string.Format("{ function : {0}, exception: {1} }", "DictionaryTranslateController.GetTranslates", exception.ToString())).RootElement);

                return BadRequest(exception.Message);
            }
        }






        //[HttpGet]
        //[Route("api/[controller]/[action]")]
        //public IActionResult TestTranslates(TEntity entity)
        //{
        //    var result = "1243";

        //    return Ok(result);
        //}

        //[HttpGet]
        //public IQueryable<T> Get()
        //{
        //    return this.db.Set<T>();
        //}





        [HttpGet]
        [Route("api/[controller]/[action]")]
        public IActionResult GetTables()
        {
            var result = (from translate in this.context.DicTranslations
                          //join language in this.context.Languages on translate.LanguageCode equals language.LanguageCode
                          join tableType in this.context.TableTypes on translate.TableTypeCode equals tableType.Code
                          //join unitType in this.context.UnitTypes on translate.TableCode equals unitType.UnitTypeCode
                          select new { translate.TableName, /*language.LanguageDescription*/ tableType.Type, LastUpdate = translate.LastUpdate.ToString().Substring(0, 11) }).ToList().Distinct();

            //return result;
            return Ok(result);
            //return this.context.DicTranslates.ToList();
        }

        [HttpPost]
        [Route("api/[controller]/[action]")]
        public IActionResult SetTranslate([FromBody] JsonElement data) 
        {
            JsonDocument document = JsonDocument.Parse(data.ToString());

            JsonElement root = document.RootElement;
            string rowName = root.GetProperty("rowname").ToString();
            string tableName = root.GetProperty("table").ToString();
            int tableCode = int.Parse(root.GetProperty("code").ToString());
            string translate = root.GetProperty("translate").ToString();
            string timestamp = root.GetProperty("timestamp").ToString();

            List<DicTranslation> result = this.context.DicTranslations.Where(item => item.TableName == tableName && item.TableCode.Equals(tableCode))
                                                                      .ToList();

            if (result.Count > 1)
            {
                //Send email
                //this.SendEmail(new JsonElement {  })
                return BadRequest("Duplicate value in table");
            }

            result[0].Translate = translate;

            this.context.TimeStampHistories.Add(new TimeStampHistory {
                                                                        TableName = tableName,
                                                                        MaxTimeStamp = Convert.FromBase64String(timestamp),
                                                                        InsertDate = DateTime.Now
                                                                     });

            this.context.SaveChanges();

            return Ok(result);
        }

        [HttpPost]
        [Route("api/[controller]/[action]")]
        public IActionResult SendEmail([FromBody] JsonElement data)
        {
            try
            {
                JsonDocument document = JsonDocument.Parse(data.ToString());

                JsonElement root = document.RootElement;

                string function = root.GetProperty("function").ToString();
                string exception = root.GetProperty("exception").ToString();

                Emails emails = new Emails(this.configuration);

                bool result = true;//emails.Send(function, exception, null);

                return result ? Ok() : BadRequest(); //ModelStateDictionary.
            }
            catch (Exception exception)
            {
                this.SendEmail(new JsonElement());
                
                return BadRequest(exception.Message);
            }
        }

        private async Task<bool> checkToken(string token)
        {
            BakaratKnisotService.IHandshakeService service = new BakaratKnisotService.HandshakeServiceClient();

            BakaratKnisotService.CheckTokenBaseInput input = new BakaratKnisotService.CheckTokenBaseInput();

            input.Token = token;
            input.ApplicationCallingId = BakaratKnisotService.ApplicationEnum.SeferNet;
            input.ApplicationDestinationId = BakaratKnisotService.ApplicationEnum.SeferNet;

            BakaratKnisotService.CheckTokenBaseResult result = await service.CheckTokenAsync(input);

            //string xmlPCheck = SerializeCheckTokenBaseInput(input);

            //string xmlRCheck = SerializeCheckTokenBaseResult(result2);

            //this.isTokenValid = result.IsValid;

            return result.IsValid;
        }

        private bool addLog(string pageName, string  functionName, string description)
        {
            int result = this.context.Database.ExecuteSqlRaw(string.Format("AddLog '{0}', '{1}', '{2}'", pageName, functionName, description));//, new SqlParameter("PageName", pageName), new SqlParameter("FunctionName", functionName), new SqlParameter("Description", description));

            if (result == 0) return false;
            else return true;
        }

        private bool sendEmail(string functionName, string exceptionDescription)
        {
            Emails emails = new Emails(this.configuration);

            return true;//emails.Send(functionName, exceptionDescription, null);
        }
    }
}
