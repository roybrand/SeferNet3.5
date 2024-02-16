using System;

namespace SeferNet.Globals
{
	/// <summary>
	/// Summary description for Globals.
	/// </summary>

	public class Globals
	{
		public Globals()
		{
			 // To do here.........
		}

	}
    public class ConstsSystem
    {
        //public const string All_PROPERTIES_FROM_AD_USER = "givenName|name|telephoneNumber|facsimileTelephoneNumber|mail|extensionAttribute11|title|extensionAttribute15";
        public const string All_PROPERTIES_FROM_AD_USER = "givenName|name|sn|mobile|telephoneNumber|facsimileTelephoneNumber|mail|extensionAttribute11|title|extensionAttribute15|extensionAttribute14";

        public const string GENERAL_EXPIRE_MESSAGE = "��� ��, ������ {0} ����� ������� �";
        public const string EXPIRE_MESSAGE = "��� ��, ������ {0} ����� ������� ����� �����";
        public const string RECEPTION_STARTING_FROM = "���� ����� ��� ������ {0}";
        public const string CHOOSE = "���";
        public const string EMPTY = "Empty";
        public const string SURGEON = "����";
        public const string FOUND_SERVICES_EXTENDED_SEARCH = "����� {0} ������� ����";
        public const string NO_RESULTS = "�� ����� ������ ����";
        public const string CONNECTION_STRING_CONFIG_ENTRY = "SeferNetConnectionStringNew";
        public const string EMAIL_SUBJECT_MUSHLAM = "����� �����";
    }

    public class ConstsLangage
    {
        public const string LNG_ENTER_NAME = "�� ������ �� ���";

        public const string HEBREW_ENCODING_HTML = "windows-1255";
        //public const string HEBREW_ENCODING_HTML = "iso-8859-8-i";
    }

    public class ConstsSession
    {
        public const string SERVICE_CATEGORIES_SEARCH_PARAMETERS = "ServiceCategoriesSearchParameters";
        public const string SEARCH_MODE_CONTROL_PARAMETERS = "SearchModeControlParameters";
        public const string CLINIC_HAS_MEDICAL_ASPECTS = "ClinicHasMedicalAspects";
        public const string CLINIC_IS_HOSPITAL = "ClinicIsHospital";
        public const string IS_POST_BACK_AFTER_LOGIN_LOGOUT = "IsPostBackAfterLoginLogout";
        public const string SUCCESSFUL_LOGIN_TOOK_PLACE = "SuccessfulLoginTookPlace";
        public const string LOGIN_FAILED = "LoginFailed";
    }

    public class PagesConsts
    {
        public const string SEARCH_CLINICS_URL = "~/SearchClinics.aspx";
        public const string SEARCH_DOCTORS_URL = "~/SearchDoctors.aspx";
        public const string SEARCH_EVENTS_URL = "~/SearchEvents.aspx";
        public const string SEARCH_SERVICES_URL = "~/SearchSalServices.aspx";
    }

}
