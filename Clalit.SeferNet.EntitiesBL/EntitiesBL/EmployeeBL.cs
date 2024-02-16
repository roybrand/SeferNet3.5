using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.SeferNet.Entities;
using SeferNet.BusinessLayer.BusinessObject;
using Clalit.SeferNet.EntitiesDal;
using SeferNet.BusinessLayer.WorkFlow;

namespace Clalit.SeferNet.EntitiesBL
{
    public  class EmployeeBL
    {
        public List<vDummyEmployeeDetails> getDoctorList(DoctorSearchParameters doctorSearchParameters,
        SearchPagingAndSortingDBParams searchPagingAndSortingDBParams)
        {
            List<vDummyEmployeeDetails> listToReturn = null;

            SeferNetEntities entities = SeferNetEntitiesFactory.GetSeferNetEntities();

            int userIsRegistered = 0;
            UserManager userMgr = new UserManager();
            if (userMgr.GetUserInfoFromSession() != null)
                userIsRegistered = 1;

            doctorSearchParameters.PrepareParametersForDBQuery();
            entities.getDoctorList(userIsRegistered, doctorSearchParameters.FirstName, 
                doctorSearchParameters.LastName,
               doctorSearchParameters.DistrictCodes,
               doctorSearchParameters.EmployeeID,
               doctorSearchParameters.MapInfo.CityName,
              doctorSearchParameters.ServiceCode,
              doctorSearchParameters.ExpertProfession,
              doctorSearchParameters.LanguageCode,
              doctorSearchParameters.CurrentReceptionTimeInfo.ReceptionDays, 
              doctorSearchParameters.CurrentReceptionTimeInfo.InHour, 
              doctorSearchParameters.CurrentReceptionTimeInfo.FromHour,
              doctorSearchParameters.CurrentReceptionTimeInfo.ToHour
                , doctorSearchParameters.Status,
                doctorSearchParameters.MapInfo.CityCode,
                doctorSearchParameters.EmployeeSectorCode,
                doctorSearchParameters.Sex, 
                doctorSearchParameters.AgreementType,
               doctorSearchParameters.CurrentSearchModeInfo.IsCommunitySelected, 
               doctorSearchParameters.CurrentSearchModeInfo.IsMushlamSelected,
              doctorSearchParameters.CurrentSearchModeInfo.IsHospitalsSelected,
                doctorSearchParameters.HandicappedFacilitiesCodes,
                doctorSearchParameters.LicenseNumber, doctorSearchParameters.PositionCode,
                searchPagingAndSortingDBParams.PageSize, searchPagingAndSortingDBParams.StartingPage
                , searchPagingAndSortingDBParams.SortedBy, searchPagingAndSortingDBParams.IsOrderDescending, doctorSearchParameters.NumberOfRecordsToShow,
               doctorSearchParameters.MapInfo.CoordinatX, doctorSearchParameters.MapInfo.CoordinatY);

            return listToReturn;
        }
    }
}
