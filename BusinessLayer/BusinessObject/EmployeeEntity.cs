using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;


namespace SeferNet.BusinessLayer.BusinessObject
{
    [XmlRoot("ClalitOnLine")]
    public class ClalitOnLine
    {
        public ClalitOnLine() { }

        [XmlElement("Main")]
        public Main main;
    }

    [XmlRoot("Main")]
    public class Main
    {
        public Main() { }

        [XmlElement("Service")]
        public string Service;

        [XmlElement("Sub")]
        public Sub sub;

        [XmlElement("Parameters")]
        public Parameters parameters;

        /// <summary>
        /// has data
        /// </summary>
        [XmlElement("Results")]
        public Results results;
    }

    [XmlRoot("Sub")]
    public class Sub
    {
        public Sub() { }

        [XmlElement("Priority")]
        public string Priority;

        [XmlElement("MessageInfo")]
        public MessageInfo messageInfo;
    }

    [XmlRoot("MessageInfo")]
    public class MessageInfo
    {
        public MessageInfo() { }

        [XmlElement("InstituteCode")]
        public string InstituteCode;

        [XmlElement("Application")]
        public string Application;
    }

    [XmlRoot("Parameters")]
    public class Parameters
    {
        public Parameters() { }
        [XmlElement("PatientId")]
        public string PatientId;
    }

    [XmlRoot("Results")]
    public class Results
    {
        public Results() { }

        [XmlElement("InstitutionID")]
        public string InstitutionID;
        [XmlElement("AppCode")]
        public string AppCode;
        [XmlElement("RequestCode")]
        public string RequestCode;
        [XmlElement("QueryCode")]
        public string QueryCode;
        [XmlElement("Version")]
        public string Version;
        [XmlElement("CardType")]
        public string CardType;


        [XmlElement("PatientId")]
        public string PatientId;
        [XmlElement("CheckNumber")]
        public string CheckNumber;
        [XmlElement("LastName")]
        public string LastName;
        [XmlElement("LastNameAdapted")]
        public string LastNameAdapted;
        [XmlElement("FirstName")]
        public string FirstName;
        [XmlElement("FatherName")]
        public string FatherName;
        [XmlElement("MotherName")]
        public string MotherName;
        [XmlElement("BirthDate")]
        public string BirthDate;
        [XmlElement("Sex")]
        public string Sex;
        [XmlElement("FamilyStatus")]
        public string FamilyStatus;



        [XmlElement("Religion")]
        public string Religion;
        [XmlElement("BirthCountry")]
        public string BirthCountry;
        [XmlElement("FatherBirthCountry")]
        public string FatherBirthCountry;
        [XmlElement("MotherBirthCountry")]
        public string MotherBirthCountry;
        [XmlElement("DateImmigration")]
        public string DateImmigration;
        [XmlElement("FlatNo")]
        public string FlatNo;
        [XmlElement("HouseNo")]
        public string HouseNo;
        [XmlElement("Street")]
        public string Street;
        [XmlElement("Entrance")]
        public string Entrance;

        [XmlElement("TownCode")]
        public string TownCode;
        [XmlElement("PostCode")]
        public string PostCode;
        [XmlElement("AreaCodeTelephone")]
        public string AreaCodeTelephone;
        [XmlElement("TelephoneNo")]
        public string TelephoneNo;
        [XmlElement("TelephoneUpdatingDate")]
        public string TelephoneUpdatingDate;
        [XmlElement("EligibilityCode")]
        public string EligibilityCode;

        [XmlElement("EligibilityUpdate")]
        public string EligibilityUpdate;

        [XmlElement("DistrictCode")]
        public string DistrictCode;

        private string m_ClinicCode;
        [XmlElement("ClinicCode")]
        public string ClinicCode
        {
            get
            {
                return m_ClinicCode;
            }
            set
            {

                m_ClinicCode = value;
            }
        }
        [XmlElement("JobDoctor")]
        public string JobDoctor;
        [XmlElement("AccidentDate")]
        public string AccidentDate;
        [XmlElement("CaseCloseDate")]
        public string CaseCloseDate;

        [XmlElement("CaseStatus")]
        public string CaseStatus;
        [XmlElement("ReasonCaseClose")]
        public string ReasonCaseClose;
        [XmlElement("AccidentDateUpdating")]
        public string AccidentDateUpdating;
        [XmlElement("FactorUpdatingAccident")]
        public string FactorUpdatingAccident;

        [XmlElement("PatientIdPrevious")]
        public string PatientIdPrevious;
        [XmlElement("PreviousCheckNumber")]
        public string PreviousCheckNumber;
        [XmlElement("LastNamePrevious")]
        public string LastNamePrevious;
        [XmlElement("Identification")]
        public string Identification;
        [XmlElement("DeathDate")]
        public string DeathDate;
        [XmlElement("LicenseNo")]
        public string LicenseNo;
        [XmlElement("Personnel")]
        public string Personnel;
        [XmlElement("OrganizationCode")]
        public string OrganizationCode;
        [XmlElement("InsuranceType")]
        public string InsuranceType;
        [XmlElement("Elderly")]
        public string Elderly;
        [XmlElement("AddressUpdatingDate")]
        public string AddressUpdatingDate;
        [XmlElement("ClalitJoiningDate")]
        public string ClalitJoiningDate;
        [XmlElement("ClinicJoinDate")]
        public string ClinicJoinDate;
        [XmlElement("DoctorJoiningDate")]
        public string DoctorJoiningDate;
        [XmlElement("IdChiefFamily")]
        public string IdChiefFamily;
        [XmlElement("AreaCodeFax")]
        public string AreaCodeFax;
        [XmlElement("FaxNo")]
        public string FaxNo;
        [XmlElement("LeavingDate")]
        public string LeavingDate;
        [XmlElement("InsuranceJoiningDate")]
        public string InsuranceJoiningDate;
        [XmlElement("SpecialAgreement")]
        public string SpecialAgreement;
        [XmlElement("ClientType")]
        public string ClientType;
        [XmlElement("ClinicExemption")]
        public string ClinicExemption;
        [XmlElement("DoctorSelfEmployed")]
        public string DoctorSelfEmployed;
        [XmlElement("AddressBlocking")]
        public string AddressBlocking;
        [XmlElement("AccidentType")]
        public string AccidentType;
        [XmlElement("Eligible")]
        public string Eligible;
        [XmlElement("PoliceCertificateExist")]
        public string PoliceCertificateExist;
        [XmlElement("Abroad")]
        public string Abroad;
        [XmlElement("DrugExemption")]
        public string DrugExemption;
        [XmlElement("Subscriber")]
        public string Subscriber;
        [XmlElement("ChronicPatient")]
        public string ChronicPatient;
        [XmlElement("InternetPasswordSwitch")]
        public string InternetPasswordSwitch;
        [XmlElement("FactorUpdatingDeath")]
        public string FactorUpdatingDeath;
        [XmlElement("DistrictName")]
        public string DistrictName;
        [XmlElement("Mushlam")]
        public string Mushlam;
        [XmlElement("AddAreaCodeTelephone")]
        public string AddAreaCodeTelephone;
        [XmlElement("AddTelephoneNo")]
        public string AddTelephoneNo;
    }
}
