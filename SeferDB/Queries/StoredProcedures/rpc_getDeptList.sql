IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptList')
	BEGIN
		DROP  Procedure  rpc_getDeptList
	END

GO

CREATE Procedure rpc_getDeptList
(
	@DistrictCode int=null,
	@CityCode int=null,
	@CityName varchar(50)=null,
	@typeUnitCode varchar(100)=null,
	@subUnitTypeCode varchar(50) = null,
	@professionCode int = null,
	@DeptName varchar(50)=null,
	@DeptCode int=null,
	@Simul228 int=null,
	@ServiceCode int=null,
	@ReceptionDays varchar(50)=null,
	@OpenAtHour varchar(2)=null,
	@OpenFromHour varchar(2)=null,
	@OpenToHour varchar(2)=null,
	@status int = null,
	@populationSectorCode int = null,
	@deptHandicappedFacilities varchar(50)
)

with recompile

AS

DECLARE @HandicappedFacilitiesCount int
--DECLARE @ReceptionDaysCount int
SET @HandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@deptHandicappedFacilities)), 0)
--SET @ReceptionDaysCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@ReceptionDays)), 0)

IF @CityCode <> null
BEGIN
	SET @CityName = null
END

SELECT
dept.deptCode,
dept.deptName,
dept.deptType,
dept.deptLevel,
DIC_DeptTypes.deptTypeDescription,
dept.typeUnitCode,
dept.subUnitTypeCode,
UnitType.UnitTypeName,
dept.cityCode,
Cities.cityName,
Streets.Name as street,
dept.house,
dept.flat,
dept.entrance,
dept.addressComment,
'prePrefix' = 
(
	select TOP 1 prePrefix
	from dbo.DeptPhones 
	where deptCode = dept.deptCode
	and phoneType=1 and phoneOrder=1
),
'prefix' = 
(
	select TOP 1 prefix
	from dbo.DeptPhones 
	where deptCode = dept.deptCode
	and phoneType=1 and phoneOrder=1
),
'phone' = 
(
	select TOP 1 phone
	from dbo.DeptPhones 
	where deptCode = dept.deptCode
	and phoneType=1 and phoneOrder=1
),
'countDeptRemarks' = 
	(SELECT COUNT(deptCode) FROM Remarks
	WHERE deptCode = dept.deptCode
	OR ( deptCode = -1
		AND districtCode = dept.districtCode
		AND (administrationCode = -1
			OR administrationCode = dept.administrationCode)
		AND (UnitTypeCode = -1
			OR UnitTypeCode = dept.typeUnitCode)
		AND (populationSector = -1
			OR populationSector = dept.populationSectorCode)
		)
	AND (validFrom <= getdate() AND (validTo is null OR validTo >= getdate()))
	), 
'countReception' = 
	(select count(receptionID) 
	from DeptReception
	where deptCode = dept.deptCode
	AND (validFrom <= getdate() AND (validTo is null OR validTo >= getdate()))),
Simul228					


FROM dept

inner join DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
inner join UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
inner join Cities on dept.cityCode = Cities.cityCode
left join Streets on dept.Street = Streets.StreetCode
left join DeptSimul on dept.deptCode = deptSimul.deptCode

where 

(@DistrictCode is null or dept.districtCode = @DistrictCode)
and (@CityCode is null or dept.CityCode = @CityCode)
and (@CityName is null or Cities.CityName like @CityName+'%')
and (@typeUnitCode is null or typeUnitCode in (Select IntField from  dbo.SplitString(@typeUnitCode)) )
AND (@subUnitTypeCode is null OR subUnitTypeCode in (Select IntField from  dbo.SplitString(@subUnitTypeCode)))
and (@DeptName is null or dept.DeptName like @DeptName+'%')
and (@DeptCode is null or (dept.deptCode = @DeptCode OR deptSimul.Simul228 = @DeptCode))
--and (@Simul228  is null or deptSimul.Simul228  = @Simul228 )
AND (
		@ServiceCode is null 
		OR
		( 
			dept.deptCode IN (SELECT deptCode FROM x_dept_service WHERE serviceCode = @ServiceCode)
		)

	)
and (@ReceptionDays is null 
	OR
	/*
	-- logical AND for "@ReceptionDays"
			(SELECT COUNT(distinct receptionDay) 
			FROM DeptReception as T
			WHERE receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays))
			AND T.deptCode = dept.deptCode) 
				= @ReceptionDaysCount
	*/
	-- logical OR for "@ReceptionDays"
	dept.deptCode IN (SELECT deptCode 
					FROM DeptReception 
					WHERE receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)) 
						)
					
	)
				
and ( (@OpenFromHour is null AND @OpenToHour is null)
	OR
	dept.deptCode IN
		(SELECT deptCode FROM DeptReception as T
			WHERE 
				T.deptCode = dept.deptCode
			AND (
					(Cast(Left(T.openingHour,2) as int ) <= Cast(@OpenFromHour as int) AND Cast(Left(T.closingHour,2) as int ) >= Cast(@OpenToHour as int) )
					OR
					(Cast(Left(T.openingHour,2) as int ) <= Cast(@OpenFromHour as int) AND Cast(Left(T.closingHour,2) as int ) > Cast(@OpenFromHour as int) )
					OR
					(Cast(Left(T.openingHour,2) as int ) < Cast(@OpenToHour as int) AND Cast(Left(T.closingHour,2) as int ) >= Cast(@OpenToHour as int) )
					OR
					(Cast(Left(T.openingHour,2) as int ) >= Cast(@OpenFromHour as int) AND Cast(Left(T.closingHour,2) as int ) <= Cast(@OpenToHour as int) )
				)
			AND 
				(@ReceptionDays is null OR T.receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)))
		)
		
	)
AND
	(@deptHandicappedFacilities is null
	OR
	dept.deptCode IN (SELECT deptCode FROM dept as New
								WHERE (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
										WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@deptHandicappedFacilities))
										AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )
	
)
and (@status is null or dept.status = @status)
and (@populationSectorCode is null or dept.populationSectorCode = @populationSectorCode)
AND (@professionCode is null OR
	(SELECT count(ProfessionCode) FROM x_dept_employee_profession 
	WHERE deptCode = dept.deptCode
	AND ProfessionCode = @professionCode) > 0)


order by deptLevel 

GO

GRANT EXEC ON rpc_getDeptList TO PUBLIC

GO

