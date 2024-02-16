IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertSweepingDeptRemark')
	BEGIN
		DROP  Procedure  rpc_InsertSweepingDeptRemark
	END

GO

CREATE Procedure dbo.rpc_InsertSweepingDeptRemark
	(
	@DicRemarkID INT,
	@remarkText VARCHAR(500),
	@districtCodes varchar(max),
	@administrationCodes varchar(max),
	@unitTypeCodes varchar(max),
	@subUnitTypeCodes varchar(max),
	@populationSectorCodes varchar(max),
	@excludedDeptCodes varchar(max),
	@validFrom datetime,
	@validTo datetime,
	@displayInInternet BIT,
	@cityCodes VARCHAR(MAX),
	@servicesParameter varchar(max),
	@updateUser varchar(50)
	)

AS

IF @validFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @validFrom = null
	END	

IF @validTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @validTo = null
	END		


declare @newRowDeptRemarkID int
declare @RelatedToService tinyint = CASE @servicesParameter WHEN '' THEN 0 ELSE 1 END 

INSERT INTO DeptRemarks
(DicRemarkID
, RemarkText
, DeptCode
, ValidFrom
, ValidTo
, DisplayInInternet
, UpdateDate
, ActiveFrom
, UpdateUser
, RelatedToService)
VALUES
( @DicRemarkID
, @remarkText
, -1
, @validFrom
, @validTo
, @displayInInternet
, GetDate()
, DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = @DicRemarkID), @validFrom)
, @updateUser
, @RelatedToService)

set @newRowDeptRemarkID =  (select scope_identity() )

SELECT ItemID as districtCode 
INTO #districtsCodes
FROM dbo.rfn_SplitStringValues(@districtCodes) as t_Districts
WHERE (@cityCodes = '')
OR EXISTS (Select * 
			from dbo.SplitString(@cityCodes) t_Cities 
			JOIN Cities ON t_Cities.IntField = Cities.cityCode AND Cities.districtCode = t_Districts.ItemID)

--------- insert DistrictCodes ------------------------------------
insert into dbo.SweepingDeptRemarks_District
	(DeptRemarkId
	,districtCode)
select @newRowDeptRemarkID as DeptRemarkId, t.districtCode
from #districtsCodes as t

--------- insert administrationCodes ------------------------------------
insert into dbo.SweepingDeptRemarks_Admin
	(DeptRemarkId
	,administrationCode)
select @newRowDeptRemarkID as DeptRemarkId
	, t.ItemID as administrationCode
from dbo.rfn_SplitStringValues(@administrationCodes) as t
JOIN Dept as AdminDepts ON t.ItemID = AdminDepts.deptCode
WHERE AdminDepts.districtCode IN (SELECT districtCode FROM #districtsCodes)
	
--------- insert populationSectorCodes ------------------------------------
insert into dbo.SweepingDeptRemarks_PopulationSector
	(DeptRemarkId
	,PopulationSectorCode)
select @newRowDeptRemarkID as DeptRemarkId
	, t.ItemID as PopulationSectorCode
from 	dbo.rfn_SplitStringValues(@populationSectorCodes) as t
			

--------- insert unitTypeCodes ------------------------------------
insert into dbo.SweepingDeptRemarks_UnitType
	(DeptRemarkId
	,UnitTypeCode)
select @newRowDeptRemarkID as DeptRemarkId
	, t.ItemID as UnitTypeCode
from 	dbo.rfn_SplitStringValues(@unitTypeCodes) as t
		

--------- insert SubUnitType ------------------------------------
insert into dbo.SweepingDeptRemarks_SubUnitType
	(DeptRemarkId
	,SubUnitTypeCode)
select @newRowDeptRemarkID as DeptRemarkId
	, t.ItemID as SubUnitTypeCode
from 	dbo.rfn_SplitStringValues(@subUnitTypeCodes) as t

--------- insert cityCode ------------------------------------
IF (@cityCodes <> '')
BEGIN
	insert into dbo.SweepingDeptRemarks_City
		(DeptRemarkId, cityCode)
	Select @newRowDeptRemarkID, IntField as cityCode from dbo.SplitString(@cityCodes) t_Cities
	JOIN Cities ON t_Cities.IntField = Cities.cityCode
	JOIN #districtsCodes ON Cities.districtCode = #districtsCodes.districtCode
END	

--------- insert services ------------------------------------
insert into dbo.SweepingDeptRemarks_Service
	(DeptRemarkId
	,serviceCode)
select @newRowDeptRemarkID as DeptRemarkId
	, t.ItemID as serviceCode
from 	dbo.rfn_SplitStringValues(@servicesParameter) as t

--------- insert SweepingDeptRemarks_Exclusions ------------------------------------
insert into dbo.SweepingDeptRemarks_Exclusions
	(DeptRemarkId
	,ExcludedDeptCode)
select @newRowDeptRemarkID as DeptRemarkId
	, t.ItemID as ExcludedDeptCode
from 	dbo.rfn_SplitStringValues(@excludedDeptCodes) as t
	
GO	


GRANT EXEC ON dbo.rpc_InsertSweepingDeptRemark TO PUBLIC

GO

