IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSweepingRemarks_MultiSelected')
	BEGIN
		DROP  Procedure  rpc_GetSweepingRemarks_MultiSelected
	END

GO

CREATE Procedure [dbo].[rpc_GetSweepingRemarks_MultiSelected]
(	@DistrictCode varchar(50), 
	@AdminClinicCode varchar(50), 
	@SectorCode varchar(50), 
	@UnitType varchar(50),
	@subUnitTypeCode INT,
	@UserPermittedDistrict INT,
	@serviceCodes varchar(50),	
	@cityCodes varchar(MAX),
	@freeText varchar(100)
)

AS
 

DECLARE @RelatedRemarksID_NotPermitted TABLE
(
	RelatedRemarkID int
)

IF (@UserPermittedDistrict = 0) BEGIN SET @UserPermittedDistrict = null END

IF(@UserPermittedDistrict is NOT null)
BEGIN
	INSERT INTO @RelatedRemarksID_NotPermitted
	SELECT * FROM 
		(SELECT distinct DeptRemarkID
		FROM dbo.SweepingDeptRemarks_District as r 
		WHERE (DistrictCode <> @UserPermittedDistrict)
		) as T
END

-- Current Remarks 
Select  distinct DeptRemarkID as RelatedRemarkID, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText,  
convert(varchar, ValidFrom, 103) as ValidFrom, convert(varchar, ValidTo, 103)  as ValidTo ,
displayInInternet as Internetdisplay
,(SELECT count(*) 
	FROM SweepingDeptRemarks_Exclusions as rex
	WHERE rex.DeptRemarkID = r.DeptRemarkID) as ExcludedDeptsCount
	
from View_Remarks as r

Where 
r.DeptCode = -1
and dbo.rfn_IsDatesCurrent(validFrom, validTo, getdate()) = 1  
and r.DistrictCode in (Select IntField from  dbo.SplitString(@DistrictCode))
and (r.administrationCode in (Select IntField from  dbo.SplitString(@AdminClinicCode)) or (@AdminClinicCode is null/* and r.administrationCode = -1*/))
and (r.UnitTypeCode in (Select IntField from  dbo.SplitString(@UnitType)) or (@UnitType is null /*and r.UnitTypeCode = -1*/))
and (r.populationSector in (Select IntField from  dbo.SplitString(@SectorCode)) or (@SectorCode is null /*and r.populationSector = -1*/))
AND r.DeptRemarkID NOT IN (SELECT * FROM @RelatedRemarksID_NotPermitted)
AND (r.SubUnitTypeCode = @subUnitTypeCode OR @subUnitTypeCode = -1)
AND ( @cityCodes = '' OR (r.cityCode in (Select IntField from dbo.SplitString(@cityCodes)) ))
AND ( @freeText = '' OR r.RemarkText LIKE '%' + @freeText +'%')

AND (r.serviceCode in (Select IntField from dbo.SplitString(@serviceCodes)) or @serviceCodes is null )
Order by DeptRemarkID 

-- Future Remarks 
Select  distinct DeptRemarkID as RelatedRemarkID, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText,  
convert(varchar, ValidFrom, 103) as ValidFrom, convert(varchar, ValidTo , 103)  as ValidTo ,
displayInInternet as Internetdisplay
,(SELECT count(*) 
	FROM SweepingDeptRemarks_Exclusions as rex
	WHERE rex.DeptRemarkID = r.DeptRemarkID) as ExcludedDeptsCount
	
from View_Remarks as r 

Where 
r.DeptCode = -1
and ValidFrom > getdate() 
and r.DistrictCode in (Select IntField from  dbo.SplitString(@DistrictCode))
and (r.administrationCode in (Select IntField from  dbo.SplitString(@AdminClinicCode)) or (@AdminClinicCode is null /*and r.administrationCode = -1*/))
and (r.UnitTypeCode in (Select IntField from  dbo.SplitString(@UnitType)) or (@UnitType is null /*and r.UnitTypeCode = -1*/))
and (r.populationSector in (Select IntField from  dbo.SplitString(@SectorCode)) or (@SectorCode is null /*and r.populationSector = -1*/))
AND r.DeptRemarkID NOT IN (SELECT * FROM @RelatedRemarksID_NotPermitted)
AND (r.SubUnitTypeCode = @subUnitTypeCode OR @subUnitTypeCode = -1)
AND ( @cityCodes = '' OR (r.cityCode in (Select IntField from dbo.SplitString(@cityCodes)) ))
AND (r.serviceCode in (Select IntField from dbo.SplitString(@serviceCodes)) or @serviceCodes is null )

Order by DeptRemarkID 

-- Historic Remarks 
Select  distinct 
DeptRemarkID as RelatedRemarkID,
dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText,  
convert(varchar, ValidFrom, 103) as ValidFrom,
 convert(varchar, ValidTo , 103)  as ValidTo ,
displayInInternet as Internetdisplay
,(SELECT count(*) 
	FROM SweepingDeptRemarks_Exclusions as rex
	WHERE rex.DeptRemarkID = r.DeptRemarkID) as ExcludedDeptsCount
	
from View_Remarks as r 
	
Where 
 r.DeptCode = -1 
and DateDiff(day, ValidTo, getdate()) >= 1 
and r.DistrictCode in (Select IntField from  dbo.SplitString(@DistrictCode))
and (r.administrationCode in (Select IntField from  dbo.SplitString(@AdminClinicCode)) or (@AdminClinicCode is null /*and r.administrationCode = -1*/))
and (r.UnitTypeCode in (Select IntField from  dbo.SplitString(@UnitType)) or (@UnitType is null /*and r.UnitTypeCode = -1*/))
and (r.populationSector in (Select IntField from  dbo.SplitString(@SectorCode)) or (@SectorCode is null /*and r.populationSector = -1*/))
AND r.DeptRemarkID NOT IN (SELECT * FROM @RelatedRemarksID_NotPermitted)
AND (r.SubUnitTypeCode = @subUnitTypeCode OR @subUnitTypeCode = -1)
AND ( @cityCodes = '' OR (r.cityCode in (Select IntField from dbo.SplitString(@cityCodes)) ))
AND (r.serviceCode in (Select IntField from dbo.SplitString(@serviceCodes)) or @serviceCodes is null )

Order by DeptRemarkID 

--------------------------
-- Attributions for all sweeping remarks 
SELECT   
DeptRemarkID as RelatedRemarkID,
districtName, AdministrationName, UnitTypeName, IsNull(dic.subUnitTypeName,'') as SubUnitTypeName, PopulationSectorDescription,
r.districtCode, r.administrationCode, r.UnitTypeCode, r.populationSector,
r.cityCode, Cities.cityName, r.serviceCode, s.ServiceDescription
from View_Remarks as r 
left join dbo.DIC_GeneralRemarks as dgr on r.DicRemarkID = dgr.RemarkID
INNER JOIN View_AllDistricts ON r.districtCode = View_AllDistricts.districtCode
LEFT JOIN View_AllAdministrations ON r.administrationCode = View_AllAdministrations.AdministrationCode
LEFT JOIN UnitType ON r.UnitTypeCode = UnitType.UnitTypeCode
LEFT JOIN PopulationSectors ON r.populationSector = PopulationSectors.PopulationSectorID
LEFT JOIN DIC_SubUnitTypes dic ON r.SubUnitTypeCode = dic.SubUnitTypeCode
LEFT JOIN Cities ON r.cityCode = Cities.cityCode
LEFT JOIN [Services] s ON r.serviceCode = s.ServiceCode

Where r.DeptCode = -1   
and 
	(select count(*) 
	from SweepingDeptRemarks_District as swe 
	inner join dbo.SplitString(@DistrictCode) as par
	on r.DeptRemarkID = swe.DeptRemarkId 
	and swe.districtCode = par.IntField) > 0
--and r.DistrictCode in (Select IntField from  dbo.SplitString(@DistrictCode))

and ((@AdminClinicCode is null) 
or 	(select count(*) 
	from SweepingDeptRemarks_Admin as swe 
	inner join dbo.SplitString(@AdminClinicCode) as par
	on r.DeptRemarkID = swe.DeptRemarkId 
	and swe.administrationCode = par.IntField) > 0
--r.administrationCode in (Select IntField from  dbo.SplitString(@AdminClinicCode)) 
 )

and ( (@UnitType is null)
 or	(select count(*) 
	from SweepingDeptRemarks_UnitType as swe 
	inner join dbo.SplitString(@UnitType) as par
	on r.DeptRemarkID = swe.DeptRemarkId 
	and swe.UnitTypeCode = par.IntField) > 0
	--r.UnitTypeCode in (Select IntField from  dbo.SplitString(@UnitType))
)

and ((@SectorCode is null)
or (select count(*) 
	from SweepingDeptRemarks_PopulationSector as swe 
	inner join dbo.SplitString(@SectorCode) as par
	on r.DeptRemarkID = swe.DeptRemarkId 
	and swe.PopulationSectorCode = par.IntField) > 0
--r.populationSector in (Select IntField from  dbo.SplitString(@SectorCode)) 
 )
 
and ((@cityCodes is null OR @cityCodes = '')
or (select count(*) 
	from SweepingDeptRemarks_City as swe
	WHERE swe.DeptRemarkId = r.DeptRemarkID  
	) > 0
 ) 
 
and ((@serviceCodes is null)
or (select count(*) 
	from SweepingDeptRemarks_Service as swe 
	inner join dbo.SplitString(@serviceCodes) as par
	on r.DeptRemarkID = swe.DeptRemarkId 
	and swe.serviceCode = par.IntField) > 0
 )
 
AND r.DeptRemarkID NOT IN (SELECT * FROM @RelatedRemarksID_NotPermitted)
AND (r.SubUnitTypeCode = @subUnitTypeCode OR @subUnitTypeCode = -1)
GO

GRANT EXEC ON rpc_GetSweepingRemarks_MultiSelected TO PUBLIC

GO


