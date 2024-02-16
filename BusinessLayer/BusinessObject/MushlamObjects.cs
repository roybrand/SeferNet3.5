using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class MushlamService
    {
        public int ServiceCode { get; set; }
        public string ServiceName { get; set; }
        public string PrivateRemark { get; set; }
        public string AgreementRemark { get; set; }
        public string GeneralRemark { get; set; }
        public string LinkedBasketServices { get; set; }
        public string RepresentativeRemark { get; set; }
        public string ClalitRefund { get; set; }
        public string SelfParticipation { get; set; }
        public string RequiredDocuments { get; set; }
        public string EligibilityRemark { get; set; }

        public MushlamService(int code, string name, string serviceGeneralRemark, string servicePrivateRemark, string eligibilityRemark,
            string serviceAgreementRemark, string linkedBasketServices, string repRemark,
            string clalitRefund, string selfParticipation, string requiredDocuments)
        {
            ServiceCode = code;
            ServiceName = name;
            PrivateRemark = servicePrivateRemark;
            GeneralRemark = serviceGeneralRemark;
            AgreementRemark = serviceAgreementRemark;
            LinkedBasketServices = linkedBasketServices;
            RepresentativeRemark = repRemark;
            ClalitRefund = clalitRefund;
            SelfParticipation = selfParticipation;
            RequiredDocuments = requiredDocuments;
            EligibilityRemark = eligibilityRemark;
        }
    }


    public class MushlamServiceSearchResults
    {
        public int ServiceCode { get; set; }
        public string ServiceName { get; set; }
        public int NumberOfSuppliers { get; set; }
        public int GroupCode { get; set; }
        public int SubGroupCode { get; set; }
        public int OriginalServiceCode { get; set; }

        public MushlamServiceSearchResults(int code, string name, int numberOfSuppliers, int groupCode, int subGroupCode, int originalServiceCode)
        {
            ServiceCode = code;
            ServiceName = name;
            NumberOfSuppliers = numberOfSuppliers;
            GroupCode = groupCode;
            SubGroupCode = subGroupCode;
            OriginalServiceCode = originalServiceCode;
        }
    }


    public class MushlamModel
    {
        public int GroupCode { get; set; }
        public int SubGroupCode { get; set; }
        public string ModelDescription { get; set; }
        public string Remark { get; set; }
        public int WaitingPeriod { get; set; }
        public int? ParticipationAmount { get; set; }

        public MushlamModel()
        {}

        public MushlamModel(int groupCode, int subGroupCode, string description, string remark, int waitingPeriod, int? participationAmount)
        {
            GroupCode = groupCode;
            SubGroupCode = subGroupCode;
            ModelDescription = description;
            Remark = remark;
            WaitingPeriod = waitingPeriod;
            ParticipationAmount = participationAmount;
        }
    }


    public class LinkedService
    {
        public int ServiceCode { get; set; }
        public string ServiceName { get; set; }

        public LinkedService(int code, string name)
        {
            ServiceCode = code;
            ServiceName = name;
        }
    }

}
