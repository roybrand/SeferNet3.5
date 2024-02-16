using System;
using System.Web;
using System.Collections;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using SeferNet.FacadeLayer;
using SeferNet.DataLayer;
using SeferNet.Globals;



[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.Web.Script.Services.ScriptService]
public class AutoComplete : WebService
{
    SqlConnection m_Connection;
    private Facade applicFacade;
    public AutoComplete()
    {
    }


    [WebMethod]
    public string[] GetCitiesAndDistricts(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        string[] tempArr = contextKey.Split(',');

        int districtCode = Convert.ToInt32(tempArr[0].Split('_')[0]);
        int deptCode = -1;
        if (tempArr[0].Split('_').Length > 1)
        { 
            deptCode = Convert.ToInt32(tempArr[0].Split('_')[1]);        
        }

        DataSet ds = new DataSet();
        ds = applicFacade.GetCitiesAndDistrictsByNameAndDistrict(prefixText, districtCode, deptCode);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["cityname"].ToString(), dr["cityCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;

    }

    [WebMethod]
    public string[] GetCitiesAndDistricts_MultipleDistricts(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        string[] tempArr = contextKey.Split(';');

        string districtCodes = tempArr[0].ToString();
        DataSet ds = new DataSet();
        ds = applicFacade.GetCitiesAndDistrictsByNameAndDistricts(prefixText, districtCodes);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);


            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["cityname"].ToString(), dr["cityCode"].ToString() + "~" + dr["cityNameOnly"].ToString()));
            }

            return items.ToArray();
        }
        return null;

    }

    [WebMethod]
    public string[] GetClinicByName(string prefixText, int count)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();
        ds = applicFacade.getClinicByName(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            //        string[] items = new string[dt.Rows.Count]; 
            List<string> items = new List<string>(count);


            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ClinicName"].ToString(), dr["deptCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetClinicByName_DistrictDepended(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();
        string[] param = contextKey.Split('~');

        Dictionary<Enums.SearchMode, bool> agreementTypes = StringHelper.ConverAgreementNamesListToBoolArray(param[param.Length - 1]);
        
        int clinicStatus = 1;
        if (param.Length >= 2 &&
            !String.IsNullOrEmpty(param[1]))
        {
            clinicStatus = 0;
        }
        
        ds = applicFacade.getClinicByName_DistrictDepended(prefixText, param[0], clinicStatus,
            false, agreementTypes);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            //        string[] items = new string[dt.Rows.Count]; 
            List<string> items = new List<string>(count);


            foreach (DataRow dr in dt.Rows)
            {

                //items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ClinicName"].ToString(), dr["deptCode"].ToString()));
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ClinicName"].ToString(), dr["deptCode"].ToString() + "," + dr["ClinicName"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetClinicByName_District_City_ClinicType_Status_Depended(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();
        string[] param = contextKey.Split('~');

        Dictionary<Enums.SearchMode, bool> agreementTypes = StringHelper.ConverAgreementNamesListToBoolArray(param[param.Length - 1]);

        int clinicStatus = 1;
        //if (param.Length >= 2 &&
        //    !String.IsNullOrEmpty(param[1]))
        //{
        //    clinicStatus = 0;
        //}

        int cityCode = 0;
        string clinicType = string.Empty;

        string[] City_ClinicType_Status = param[1].Split(';');

        if (City_ClinicType_Status[0] != string.Empty)
            cityCode = Convert.ToInt32(City_ClinicType_Status[0]);

        if (City_ClinicType_Status[1] != string.Empty)
            clinicType = City_ClinicType_Status[1].ToString();

        if (City_ClinicType_Status[2] != string.Empty)
            clinicStatus = Convert.ToInt32(City_ClinicType_Status[2]);



        ds = applicFacade.getClinicByName_District_City_ClinicType_Status_Depended(prefixText, param[0], clinicStatus, cityCode, clinicType,
            false, agreementTypes);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            //        string[] items = new string[dt.Rows.Count]; 
            List<string> items = new List<string>(count);


            foreach (DataRow dr in dt.Rows)
            {

                //items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ClinicName"].ToString(), dr["deptCode"].ToString()));
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ClinicName"].ToString(), dr["deptCode"].ToString() + "," + dr["ClinicName"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetHealthOfficeDesc(string prefixText , int count)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetHealthOfficeDesc(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["Description"].ToString(), dr["Code"].ToString() ));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetICD9Desc(string prefixText, int count)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetICD9Desc(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["name"].ToString(), dr["diagnosisID"].ToString() + ";" + dr["name"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetServiceCodesForSalServices(string prefixText, int count)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetServiceCodesForSalServices(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ServiceName"].ToString(), dr["ServiceCode"].ToString() + "," + dr["ServiceName"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetMedicalAspects(string prefixText, int count)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetMedicalAspectsForAutocomplete(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["MedicalAspectDescription"].ToString(), dr["MedicalAspectCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetClalitServices(string prefixText, int count)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetClalitServicesForAutocomplete(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ClalitServiceDescription"].ToString(), dr["ClalitServiceCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetClinicByName_DeptCodePrefixed_DistrictDepended(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        string[] param = contextKey.Split(',');
        Dictionary<Enums.SearchMode, bool> agreementTypes = StringHelper.ConverAgreementNamesListToBoolArray(param[param.Length - 1]);
        Facade applicFacade = Facade.getFacadeObject();

        DataSet ds = new DataSet();

        if (contextKey == null)
        {
            contextKey = string.Empty;
        }

        int clinicStatus = 1;
        if (param.Length >= 2 &&
            !String.IsNullOrEmpty(param[1]))
        {
            clinicStatus = 0;
        }

        ds = applicFacade.getClinicByName_DistrictDepended(prefixText, param[0], clinicStatus,
            true, agreementTypes);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            //        string[] items = new string[dt.Rows.Count]; 
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ClinicName"].ToString(), dr["deptCode"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetClinicByName_AdministrationDepended(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        int administrationCode = Convert.ToInt32(contextKey);
        Facade applicFacade = Facade.getFacadeObject();

        DataSet ds = new DataSet();

        ds = applicFacade.GetClinicByName_AdministrationDepended(prefixText, administrationCode);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["deptName"].ToString(), dr["deptCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetAdminByName_DistrictDepended(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        string districtCodes = contextKey;
        Facade applicFacade = Facade.getFacadeObject();

        DataSet ds = new DataSet();

        ds = applicFacade.getAdminByName_DistrictDepended(prefixText, districtCodes);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["deptName"].ToString(), dr["deptCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;

    }

    [WebMethod]
    public string[] getDoctorByFirstNameAndSector(string prefixText, int count, string contextKey)
	{
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
       
		string[] param = contextKey.Split('~');
		
		string LoggedinUser = param[0];
        string otherName = param[1];
        int sector = Convert.ToInt32(param[2]);
		Dictionary<Enums.SearchMode, bool> membershipValues = StringHelper.ConverAgreementNamesListToBoolArray(param[3]);
		
        //--- if user registred - get all doctors, else if is not user registred - get isOnlyDoctorConnectedToClinic,
        int isOnlyDoctorConnectedToClinic = 1;
        if (!String.IsNullOrEmpty(LoggedinUser))
        {
            isOnlyDoctorConnectedToClinic = 0;
        }

		DataSet ds = applicFacade.GetDoctorByFirstNameAndSector(prefixText, otherName, isOnlyDoctorConnectedToClinic, sector, membershipValues);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);
            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["firstName"].ToString(), dr["firstName"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetDoctorByLastNameAndSector(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();

		string[] param = contextKey.Split('~');

		string LoggedinUser = param[0];
		string otherName = param[1];
		int sector = Convert.ToInt32(param[2]);
		Dictionary<Enums.SearchMode, bool> membershipValues = StringHelper.ConverAgreementNamesListToBoolArray(param[3]);

		//--- if user registred - get all doctors, else if is not user registred - get isOnlyDoctorConnectedToClinic,
		int isOnlyDoctorConnectedToClinic = 1;
		if (!String.IsNullOrEmpty(LoggedinUser))
		{
			isOnlyDoctorConnectedToClinic = 0;
		}

		DataSet ds = applicFacade.GetDoctorByLastNameAndSector(prefixText, otherName, isOnlyDoctorConnectedToClinic, sector, membershipValues);
     
        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);
            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["lastName"].ToString(), dr["lastName"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetEmployeeByLastNameFrom226(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        string[] strArray = contextKey.Split(',');
        string prefixFirstName = strArray[0];

        DataSet ds = applicFacade.GetEmployeeByLastNameFrom226(prefixText, prefixFirstName);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["lastName"].ToString(), dr["lastName"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetEmployeeByFirstNameFrom226(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        string[] strArray = contextKey.Split(',');
        string prefixLastName = strArray[0];

        //DataSet ds = applicFacade.GetEmployeeByLastNameFrom226(prefixText, prefixFirstName);
        DataSet ds = applicFacade.GetEmployeeByFirstNameFrom226(prefixText, prefixLastName);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["firstName"].ToString(), dr["firstName"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] getDistricts(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();

        DataTable tbl = applicFacade.GetDistrictsByName(prefixText, contextKey).Tables[0];

        if (tbl != null)
        {
            List<string> items = new List<string>(count);

            foreach (DataRow dr in tbl.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["districtName"].ToString(), dr["districtCode"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] getLanguagesByName(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();

        DataTable tbl = applicFacade.getLanguagesByName(prefixText).Tables[0];

        if (tbl != null)
        {
            List<string> items = new List<string>(count);

            foreach (DataRow dr in tbl.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["languageDescription"].ToString(), dr["languageCode"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] getDoctorActiveByFirstName(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        string[] param = contextKey.Split('~');
        string prefixLastName = param[0];
        int sector = 0;
        Dictionary<Enums.SearchMode, bool> membershipValues = StringHelper.ConverAgreementNamesListToBoolArray(param[1]);
		int isOnlyDoctorConnectedToClinic = 0;

        DataSet ds = applicFacade.GetDoctorByFirstNameAndSector(prefixText, prefixLastName, isOnlyDoctorConnectedToClinic, sector, membershipValues);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            //        string[] items = new string[dt.Rows.Count]; 
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["firstName"].ToString(), dr["firstName"].ToString()));
            }

            return items.ToArray();
        }
        return null;

    }

    [WebMethod]
    public string[] getDoctorActiveByLastName(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();

        string[] param = contextKey.Split('~');
        string prefixFirstName = param[0];
		int sector = 0;

		Dictionary<Enums.SearchMode, bool> membershipValues = StringHelper.ConverAgreementNamesListToBoolArray(param[1]);
		int isOnlyDoctorConnectedToClinic = 0;

        DataSet ds = applicFacade.GetDoctorByLastNameAndSector(prefixText, prefixFirstName, isOnlyDoctorConnectedToClinic, sector, membershipValues);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            //        string[] items = new string[dt.Rows.Count]; 
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["lastName"].ToString(), dr["lastName"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetStreetsByCityCode(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        int cityCode;

        if (contextKey != string.Empty)
            cityCode = Convert.ToInt32(contextKey);
        else
            cityCode = -1;

        DataSet ds = new DataSet();
        ds = applicFacade.getStreetsByCityCode(cityCode, prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            //        string[] items = new string[dt.Rows.Count]; 
            List<string> items = new List<string>(count);


            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["StreetName"].ToString(), dr["StreetCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;


    }
    
    [WebMethod]
    public string[] GetNeighbourhoodsByCityCode(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        int cityCode;

        if (contextKey != string.Empty)
            cityCode = Convert.ToInt32(contextKey);
        else
            cityCode = -1;

        DataSet ds = new DataSet();
        ds = applicFacade.getNeighbourhoodsByCityCode(cityCode, prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["NeighbourhoodName"].ToString(), dr["NeighbourhoodCode"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod] 
    public string[] GetNeighbourhoodsAndSitesByCityCode(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        int cityCode;

        if (contextKey != string.Empty)
            cityCode = Convert.ToInt32(contextKey);
        else
            cityCode = -1;

        DataSet ds = new DataSet();
        ds = applicFacade.GetNeighbourhoodsAndSitesByCityCode(cityCode, prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["Name"].ToString(), dr["Code"].ToString() + "," + dr["IsSite"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetSitesByCityCode(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        int cityCode;

        if (contextKey != string.Empty)
            cityCode = Convert.ToInt32(contextKey);
        else
            cityCode = -1;

        DataSet ds = new DataSet();
        ds = applicFacade.getSitesByCityCode(cityCode, prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["InstituteName"].ToString(), dr["InstituteName"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetStreets(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        DataSet ds = new DataSet();
        string connStr = ConnectionHandler.ResolveConnStrByLang();

        SqlConnection m_Connection = new SqlConnection(connStr);

        using (SqlCommand command = new SqlCommand(string.Empty, m_Connection))
        {
            command.CommandType = CommandType.Text;
            command.CommandText = "select rtrim(streetCode) as streetCode,rtrim(Name) as Name from streets where cityCode=" + contextKey + " and Name like '" + prefixText + "'+ '%'";
            //where cityName like @SearchStr+'%'

            SqlDataAdapter da;
            using (da = new SqlDataAdapter(command))
            {
                da.SelectCommand = command;
                try
                {
                    da.FillSchema(ds, SchemaType.Mapped);
                    da.Fill(ds);
                }
                catch (Exception ex)
                {
                    string err = ex.ToString();
                    throw;
                }
            }

        }
        DataTable dt = ds.Tables[0];
        List<string> items = new List<string>(count);
        int i = 0;
        foreach (DataRow dr in dt.Rows)
        {
            items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["Name"].ToString(), dr["streetCode"].ToString()));
        }

        return items.ToArray();

    }

	[WebMethod]
    public string[] GetServicesAndEventsByName(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Dictionary<Enums.SearchMode, bool> agreementTypes = StringHelper.ConverAgreementNamesListToBoolArray(contextKey);

		Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();
		ds = applicFacade.GetServicesAndEventsByName(prefixText, agreementTypes);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["description"].ToString(), dr["code"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

	[WebMethod]
	public string[] GetServicesByNameAndSector(string prefixText, int count, string contextKey)
	{
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
		string[] parametrs = contextKey.Split('~');
		int sectorCode = -1;
		DataSet ds = new DataSet();

		if (!string.IsNullOrEmpty(parametrs[0]))
		{
			if(!int.TryParse(parametrs[0], out sectorCode))
				sectorCode = -1;
		}

		System.Text.StringBuilder agreementTypesStr = new System.Text.StringBuilder(contextKey.Length);
		for (int i = 1; i < parametrs.Length; i++)
		{
			agreementTypesStr.Append(parametrs[i] + ',');
		}
		Dictionary<Enums.SearchMode, bool> agreementTypes = StringHelper.ConverAgreementNamesListToBoolArray(parametrs[1]);

        ds = applicFacade.GetServicesByNameAndSector(prefixText, sectorCode, agreementTypes);

		if (ds != null && ds.Tables[0] != null)
		{
			DataTable dt = ds.Tables[0];

			List<string> items = new List<string>(count);

			foreach (DataRow dr in dt.Rows)
			{
				items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem( dr["serviceDescription"].ToString(), dr["serviceCode"].ToString() ));
			}

			return items.ToArray();
		}
		return null;
	}


    [WebMethod]
    public string[] GetEventsByName(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        string lang = contextKey;
        DataSet ds = new DataSet();
        ds = applicFacade.GetEventsByName(prefixText, lang);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["description"].ToString(), dr["code"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetServicesByName(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        string lang = contextKey;
        DataSet ds = new DataSet();
        ds = applicFacade.GetServicesByName(prefixText, lang);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["serviceDescription"].ToString(), dr["serviceCode"].ToString() + "," + dr["serviceDescription"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetHandicappedFacilitiesByName(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        string lang = contextKey;
        DataSet ds = new DataSet();
        ds = applicFacade.GetHandicappedFacilitiesByName(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["FacilityDescription"].ToString(), dr["FacilityCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetQueueOrderMethodsAndOptions(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        string lang = contextKey;
        DataSet ds = new DataSet();
        ds = applicFacade.GetDicQueueOrderMethodsAndOptionsCombinedByName(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["QueueOrderDescription"].ToString(), dr["QueueOrderCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetProfessionsByName(string prefixText, int count)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetProfessionsByName(prefixText );

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["Description"].ToString(), dr["Description"].ToString() + ";" + dr["Code"].ToString()));            
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetGroupsByName(string prefixText, int count)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetGroupsByName(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["GroupDesc"].ToString(), dr["GroupDesc"].ToString() + ";" + dr["GroupCode"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] GetOmriCodesByName(string prefixText, int count)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetOmriReturnsByName(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];
            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ReturnDescription"].ToString(), dr["ReturnDescription"].ToString() + ";" + dr["ReturnCode"].ToString()));
            }

            return items.ToArray();
        }

        return null;
    }

    [WebMethod]
    public string[] getUnitTypesByName(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();
        Dictionary<Enums.SearchMode, bool> agreementTypes = StringHelper.ConverAgreementNamesListToBoolArray(contextKey);
        ds = applicFacade.getUnitTypesByName(prefixText, agreementTypes);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["UnitTypeName"].ToString(), dr["UnitTypeCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;

    }

    [WebMethod]
    public string[] getUnitTypesByName_Extended(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();
        Dictionary<Enums.SearchMode, bool> agreementTypes = StringHelper.ConverAgreementNamesListToBoolArray(contextKey);
        ds = applicFacade.getUnitTypesByName_Extended(prefixText, agreementTypes);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["UnitTypeName"].ToString(), dr["UnitTypeCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;

    }

    [WebMethod]
    public string[] GetPositionsByName(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();
        long employeeID;
        long.TryParse(contextKey, out employeeID);

        ds = applicFacade.GetPositionsByName(prefixText, employeeID);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["PositionDescription"].ToString(), dr["PositionCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetEmployeeDepts(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();
        long employeeID;
        List<string> items = new List<string>(count);
        
        long.TryParse(contextKey, out employeeID);

        ds = applicFacade.GetEmployeeDeptsByText(prefixText, employeeID);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["DeptName"].ToString(), dr["DeptCode"].ToString()));
            }
        }

        string allDeptsString = "כל היחידות";

        if (allDeptsString.IndexOf(prefixText) > -1)
        {
            items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(allDeptsString, "-1"));
        }

        if (items.Count > 0)
        {
            return items.ToArray();
        }
        else
        {
            return null;
        }


    }

    [WebMethod]
    public string[] GetSpecialityByNameForEmployee(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();
        long employeeID;
        long.TryParse(contextKey, out employeeID);

        ds = applicFacade.GetSpecialityByNameForEmployee(prefixText, employeeID);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["PositionDescription"].ToString(), dr["PositionCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="prefixText"></param>
    /// <param name="count"></param>
    /// <param name="contextKey">if there is value - returned description is without leading code. 
    /// otherwise - leading service code is shown</param>
    /// <returns></returns>
    [WebMethod]
    public string[] GetAllServices(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetServiceByNameOrCode(prefixText);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);
            string serviceDesc;

            foreach (DataRow dr in dt.Rows)
            {
                if (!string.IsNullOrEmpty(contextKey))
                {
                    serviceDesc = dr["ServiceDescription"].ToString();                    
                }
                else
                {
                    serviceDesc = dr["ServiceCode"].ToString() + " - " + dr["ServiceDescription"].ToString();
                }

                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(serviceDesc , dr["ServiceCode"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }


    [WebMethod]
    public string[] GetAllServiceCategories(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetServiceCategories(null,prefixText,null);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {

                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ServiceCategoryDescription"].ToString(), dr["ServiceCategoryID"].ToString()));
            }

            return items.ToArray();
        }
        return null;
    }

    [WebMethod]
    public string[] GetServiceCategories(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();

        ds = applicFacade.GetServiceCategories(null, prefixText, null);

        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ServiceCategoryDescription"].ToString(), dr["ServiceCategoryID"].ToString()));
            }

            return items.ToArray();
        }
        return null;

    }

    [WebMethod]
    public string[] GetServicesFromMFTables(string prefixText, int count, string contextKey)
    {
        HttpRequest request = HttpContext.Current.Request;
        if (request.ApplicationPath != ConfigurationManager.AppSettings["ApplicationPath"])
        {
            return null;
        }

        Facade applicFacade = Facade.getFacadeObject();
        DataSet ds = new DataSet();        

        
        if (ds != null && ds.Tables[0] != null)
        {
            DataTable dt = ds.Tables[0];

            List<string> items = new List<string>(count);

            foreach (DataRow dr in dt.Rows)
            {
                items.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(dr["ServiceCategoryDescription"].ToString(), dr["ServiceCategoryID"].ToString()));
            }

            return items.ToArray();
        }
        return null; 
    }
}




