
------ new concept   Services = Services + Proffesions

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesNewBySector')
	BEGIN
		DROP  Procedure  rpc_GetServicesNewBySector
	END

GO

CREATE Procedure [dbo].[rpc_GetServicesNewBySector]
(
	@selectedServices VARCHAR(max),
	@sectorCode INT,
	@IncludeService int = 1, -- in case  = 1 include Services with s.IsService = 1; case = 0 don't include them;
	@IncludeProfession int = 1,-- in case  = 1 include Professions with s.IsProfession = 1; case = 0 don't include them;
	@IsInCommunity bit,
	@IsInMushlam bit, 
	@IsInHospitals bit
)
 
AS


select distinct 
ServiceCode 
,ServiceDescription
,ServiceCategoryID 
,selected
,CategoryIDForSort
,CategoryDescrForSort
,AgreementType
,IsService
,IsProfession

from

------------------- ServiceCategory table
( -- begin union
SELECT 
ISNULL(SeCa_Se.ServiceCategoryID, -1) as ServiceCode   --'ServiceCategoryID'
,ISNULL(SeCa.ServiceCategoryDescription, 'שירותים שונים') as ServiceDescription ---'ServiceCategoryDescription'
,null as ServiceCategoryID
,0 as selected
,ISNULL(SeCa_Se.ServiceCategoryID, -1)as CategoryIDForSort
,ISNULL(SeCa.ServiceCategoryDescription, 'תתתת') AS CategoryDescrForSort
,null as 'AgreementType'
,0 as 'IsService'
,0 as IsProfession

FROM [Services] as s
left JOIN  x_ServiceCategories_Services as SeCa_Se
	ON 	SeCa_Se.ServiceCode = s.ServiceCode
		
left join x_Services_EmployeeSector as Se_EmSec
	on SeCa_Se.ServiceCode = Se_EmSec.ServiceCode
	 
left join ServiceCategories SeCa 
	on  SeCa.ServiceCategoryID = SeCa_Se.ServiceCategoryID

where	(	@sectorCode = -1
		or (Se_EmSec.EmployeeSectorCode is null 
			or Se_EmSec.EmployeeSectorCode = @sectorCode)
		)
		and (@IncludeService = 1 and s.IsService = 1 
			or	@IncludeProfession = 1 and s.IsProfession = 1)
		
		and(@IsInCommunity = 1 and s.IsInCommunity = 1
			or @IsInMushlam = 1 and  s.IsInMushlam = 1
			or @IsInHospitals = 1 and s.IsInHospitals = 1)

union

------------- Services table
SELECT 
s.ServiceCode
,s.ServiceDescription
,ISNULL(SeCa_Se.ServiceCategoryID, -1) AS 'ServiceCategoryID'
, CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END as 'selected'
,ISNULL(SeCa_Se.ServiceCategoryID, -1) AS 'CategoryIDForSort'
,ISNULL(SeCa.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,case when (s.IsInMushlam = 1
			and isnull(s.IsInCommunity, 0) = 0 
			and isnull(s.IsInHospitals, 0) = 0) 
	then 3 else null end as 'AgreementType'
,s.IsService as 'IsService'
,s.IsProfession

FROM [Services] as s
left JOIN  x_ServiceCategories_Services as SeCa_Se
	ON 	SeCa_Se.ServiceCode = s.ServiceCode
	
left join x_Services_EmployeeSector as Se_EmSec
	on SeCa_Se.ServiceCode = Se_EmSec.ServiceCode
	
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@selectedServices)) as sel ON s.ServiceCode = sel.IntField

left join ServiceCategories SeCa 
	on  SeCa.ServiceCategoryID = SeCa_Se.ServiceCategoryID
	
where	(	@sectorCode = -1
		or (Se_EmSec.EmployeeSectorCode is null 
			or Se_EmSec.EmployeeSectorCode = @sectorCode)
		)
		and (@IncludeService = 1 and s.IsService = 1 
		or	@IncludeProfession = 1 and s.IsProfession = 1)
		
		and(@IsInCommunity = 1 and s.IsInCommunity = 1
			or @IsInMushlam = 1 and  s.IsInMushlam = 1
			or @IsInHospitals = 1 and s.IsInHospitals = 1)
) as t     -- end union


ORDER BY  CategoryDescrForSort, IsService, ServiceCategoryID, ServiceDescription

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 3GO


GRANT EXEC ON dbo.rpc_GetServicesNewBySector TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetServicesNewBySector TO [clalit\IntranetDev]
GO  


