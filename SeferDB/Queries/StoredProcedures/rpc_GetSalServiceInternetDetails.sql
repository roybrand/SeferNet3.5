IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSalServiceInternetDetails')
	BEGIN
		DROP  Procedure  rpc_GetSalServiceInternetDetails
	END

GO

CREATE Procedure [dbo].[rpc_GetSalServiceInternetDetails]
@ServiceCode Int
As

Select	SS.FromAgePrivilege , SS.UntilAgePrivilege , SS.GenderPrivilege , SS.EntitlementCheck  , 
		SSDI.ServiceNameForInternet , SSDI.ServiceDetails , SSDI.ServiceBrief , SSDI.QueueOrder , 
		SSDI.ShowServiceInInternet , SSDI.UpdateComplete , 
		SC.SalCategoryID , SC.SalCategoryDescription , 
		SBO.SalOrganCode , SBO.OrganName , SSDI.Diagnosis , SSDI.Refund , SSDI.Treatment , 
		SSDI.UpdateDate , SSDI.UpdateUser , SSDI.[Synonyms],
		SSDI.ServiceDetailsInternet
From MF_SalServices386 SS
Left Join SalServiceDetailsForInternet SSDI On SS.ServiceCode = SSDI.ServiceCode
Left Join SalBodyOrgans SBO On SBO.SalOrganCode = SSDI.SalOrganCode
Left Join SalCategories SC On SC.SalCategoryID = SSDI.SalCategoryID
Where SS.ServiceCode = @ServiceCode

-- Select the service's professions 
Select P.[Description] , PDFI.ShowProfessionInInternet
From MF_ServiceProfessions SP
Join MF_Professions P On P.Code = SP.ProfessionCode
Join ProfessionDetailsForInternet PDFI On PDFI.ProfessionCode = SP.ProfessionCode
Where SP.Code = @ServiceCode
AND SP.LogicalDelete = 0
Order By P.[Description]

-- Select the service's profession's categories
Select DISTINCT SC.SalCategoryDescription 
From SalProfessionToCategory SPC
Join SalCategories SC On SC.SalCategoryID = SPC.SalCategoryID
Where SPC.ProfessionCode In (	Select P.Code
								From MF_ServiceProfessions SP
								Join MF_Professions P On P.Code = SP.ProfessionCode
								Join ProfessionDetailsForInternet PDFI On PDFI.ProfessionCode = SP.ProfessionCode
								Where SP.Code = @ServiceCode 
								and SP.LogicalDelete = 0)
Order By SC.SalCategoryDescription

GO

GRANT EXEC ON rpc_GetSalServiceInternetDetails TO PUBLIC

GO

