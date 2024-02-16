
------ new concept   Services = Services + Proffesions

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesNewAndEventsBySector')
	BEGIN
		DROP  Procedure  rpc_GetServicesNewAndEventsBySector
	END

GO

CREATE Procedure dbo.rpc_GetServicesNewAndEventsBySector
(
	@selectedServices VARCHAR(max),
	@sectorCode INT,
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
,IsProfession
from

-- ServiceCategory table
( -- begin union
SELECT 
ISNULL(SeCa_Se.ServiceCategoryID, -1) as ServiceCode   --'ServiceCategoryID'
,ISNULL(SeCa.ServiceCategoryDescription, 'שירותים שונים') as ServiceDescription ---'ServiceCategoryDescription'
,null as ServiceCategoryID
,0 as selected
,ISNULL(SeCa_Se.ServiceCategoryID, -1)as CategoryIDForSort
,ISNULL(SeCa.ServiceCategoryDescription, 'תתתא') AS CategoryDescrForSort
,null as 'AgreementType'
, 0 as IsProfession -- 0 as it not relevant for category

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
,ISNULL(SeCa.ServiceCategoryDescription, 'תתתא') AS 'CategoryDescrForSort'
,case when (s.IsInMushlam = 1
			and isnull(s.IsInCommunity, 0) = 0 
			and isnull(s.IsInHospitals, 0) = 0) 
	then 3 else null end as 'AgreementType'
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
		and(@IsInCommunity = 1 and s.IsInCommunity = 1
			or @IsInMushlam = 1 and  s.IsInMushlam = 1
			or @IsInHospitals = 1 and s.IsInHospitals = 1)

union
--------- Events ---------------------------------

SELECT
Eventcode as ServiceCode
,EventName as ServiceDescription
,-2 AS 'ServiceCategoryID'
, CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END as 'selected'
,-2 AS 'CategoryIDForSort'
,'תתתת' AS 'CategoryDescrForSort'
,null as 'AgreementType'
,'' as 'IsProfession'

FROM DIC_Events e
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@selectedServices)) as sel ON e.EventCode = sel.IntField


union
--------- Events category  ---------------------------------

SELECT
-2 as ServiceCode
,'פעילות' as ServiceDescription
,null AS 'ServiceCategoryID'
,0 as 'selected'
,-2 AS 'CategoryIDForSort'
,'תתתת' AS 'CategoryDescrForSort'
,null as 'AgreementType'
,'' as 'IsProfession'

) as t     -- end union


ORDER BY CategoryDescrForSort, ServiceCategoryID, ServiceDescription

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 12

GO


GRANT EXEC ON dbo.rpc_GetServicesNewAndEventsBySector TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetServicesNewAndEventsBySector TO [clalit\IntranetDev]
GO  


