IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getClinicsExtended')
	BEGIN
		DROP  Procedure  rpc_getClinicsExtended
	END

GO

CREATE Procedure [dbo].[rpc_getClinicsExtended] 
	(
		@SelectedClinics varchar(500),
		@AdminCodes varchar(100),
		@DistrictCode varchar(100),
		@UnitTypeListCodes varchar(100),
		@SubUnitTypeCode varchar(100),
		@PopulationSector varchar(100)
	)

AS

IF(@DistrictCode = '')
	BEGIN SET @DistrictCode = null END

IF(@AdminCodes = '')
	BEGIN SET @AdminCodes = null END

IF(@UnitTypeListCodes = '')
	BEGIN SET @UnitTypeListCodes = null END

IF(@SubUnitTypeCode = '' OR @SubUnitTypeCode = '-1')
	BEGIN SET @SubUnitTypeCode = null END

IF(@PopulationSector = '')
	BEGIN SET @PopulationSector = null END

SELECT
CAST(DeptCode as varchar(10)) + ' - ' + DeptName  as clinicName,
deptCode as clinicCode,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END

FROM
Dept
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedClinics)) as sel ON Dept.deptCode = sel.IntField

WHERE deptType = 3
AND status = 1
AND (@DistrictCode is null
	OR
	districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCode)))
AND (@AdminCodes is null
	OR
	administrationCode in (SELECT IntField FROM dbo.SplitString(@AdminCodes)))
AND (@UnitTypeListCodes is null
	OR
	typeUnitCode in (SELECT IntField FROM dbo.SplitString(@UnitTypeListCodes)))
AND (@SubUnitTypeCode is null
	OR
	subUnitTypeCode = CAST(@SubUnitTypeCode as Int))
AND (@PopulationSector is null
	OR
	populationSectorCode = CAST(@PopulationSector as Int))

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 25

GO

GRANT EXEC ON dbo.rpc_getClinicsExtended TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getClinicsExtended TO [clalit\IntranetDev]
GO  
