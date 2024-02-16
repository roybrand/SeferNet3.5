using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{

    public enum deptType
    {
        District = 1,
        Administration = 2,
        Clinic = 3
    }
    public enum PopupType
    {
        Positions = 1,
        Professions = 2,
        Services = 3,
        Languages = 4,
        Expertise = 5,
        UnitType = 6,
        District = 7,
        HandicappedFacilities = 8,
        Cities = 9,
        Admins = 10,
        ObjectType = 11,
        ServicesAndEvents = 12,
        DeptAndServicesRemarks = 13,
        Events = 14,
        ServicesNew = 15,
        MF_Specialities051 = 16,
        ServiceCategories = 17,
        Membership = 18,
        UserPermittedDistrictsForReports = 19,
        ProfessionsForSalServices = 20,
        GroupsForSalServices = 21,
        PopulationsForSalServices = 22,
        OmriReturnsForSalServices = 23,
        MedicalAspects = 24,
        Clinics = 25,
        ICD9 = 26,
        ChangeType = 27,
        UpdateUser = 28,
        QueueOrders = 29,
        ServicesForEmployeeInClinic = 30
    }

    public enum PopupMode
    {
        MultiSelect = 1,
        SingleSelect = 2
    }

}
