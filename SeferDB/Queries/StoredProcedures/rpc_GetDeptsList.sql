IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptsList')
	BEGIN
		DROP  Procedure  rpc_GetDeptsList
	END

GO

/*
**************
FOR INTERNET
**************
*/

CREATE Procedure dbo.rpc_GetDeptsList
(
	@deptName VARCHAR(50),
	@deptCode INT,
	@cityCode INT, 
	@typeUnitCode VARCHAR(50), 
	@professionOrServiceCode VARCHAR(100),
    @subTypeUnitCode INT,
	@DistrictCode INT, 
	@deptHandicappedFacilities varchar(50) = null,	
	@receptionDays VARCHAR(50), 
	@OpenFromHour_Str VARCHAR(50),  
	@OpenToHour_Str VARCHAR(50),
	@OpenAtHour_Str VARCHAR(50),
	@exactSearch BIT
)

AS


DECLARE @HandicappedFacilitiesCount int
SET @HandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@deptHandicappedFacilities)), 0)

DECLARE @OpenAtHour int -- in minutes
DECLARE @OpenFromHour int-- in minutes
DECLARE @OpenToHour int-- in minutes

IF @OpenFromHour_Str = ''
	SET @OpenFromHour_Str = NULL	
IF @OpenToHour_Str = ''
	SET @OpenToHour_Str = NULL

SET @OpenFromHour = LEFT( @OpenFromHour_Str, 2)*60 + RIGHT(@OpenFromHour_Str, 2)
SET @OpenToHour = LEFT( @OpenToHour_Str, 2)*60 + RIGHT(@OpenToHour_Str, 2)
SET @OpenAtHour = LEFT( @OpenAtHour_Str, 2)*60 + RIGHT(@OpenAtHour_Str, 2)


IF @OpenFromHour_Str IS NULL AND @OpenToHour_Str IS NOT NULL
	SET @OpenAtHour = LEFT( @OpenToHour_Str, 2)*60 + RIGHT(@OpenToHour_Str, 2)

IF @OpenFromHour_Str IS NOT NULL AND @OpenToHour_Str IS NULL
	SET @OpenAtHour = LEFT( @OpenFromHour_Str, 2)*60 + RIGHT(@OpenFromHour_Str, 2)





SELECT
dept.deptCode,
dept.deptName,
Cities.cityName,
'Street' = Streets.Name,
Dept.House,
Dept.Floor,
Dept.Flat,
'Phones' = dbo.fun_GetDeptPhones(dept.DeptCode, 1) ,
'Fax' = dbo.fun_GetDeptPhones(dept.DeptCode, 2) ,
'Services' = dbo.fun_GetDeptServices(dept.DeptCode),
'Professions' = dbo.fun_GetDeptProfessions(dept.DeptCode),
dept.addressComment,
xCoord,
yCoord



FROM dept
INNER JOIN Cities on dept.cityCode = Cities.cityCode
INNER JOIN x_dept_xy ON Dept.DeptCode = x_dept_xy.DeptCode
LEFT JOIN Streets ON Dept.Street = Streets.StreetCode

WHERE 

(@DistrictCode IS NULL OR dept.districtCode = @DistrictCode)
AND (@CityCode IS NULL OR dept.CityCode = @CityCode)
AND (@typeUnitCode is null or typeUnitCode IN (SELECT IntField FROM  dbo.SplitString(@typeUnitCode)) )
AND (@subTypeUnitCode is null OR subUnitTypeCode in (Select IntField from  dbo.SplitString(@subTypeUnitCode)))
AND (@DeptName IS NULL OR (dept.DeptName LIKE @DeptName + '%' AND @exactSearch = 0) OR (dept.DeptName = @DeptName AND @exactSearch = 1) )
AND (@DeptCode IS NULL OR (dept.deptCode = @DeptCode))

AND (@ReceptionDays IS NULL 
	OR
	-- logical OR for "@ReceptionDays"
	dept.deptCode IN (SELECT DISTINCT deptCode 
					FROM DeptReception 
					WHERE receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)) 
						)
					
	)
				
AND ( (@OpenAtHour IS NULL)
	OR
	dept.deptCode IN
		(SELECT DISTINCT deptCode FROM DeptReception as T
			WHERE 
				T.deptCode = dept.deptCode
			AND ( (LEFT( openingHour, 2)*60 + RIGHT(openingHour, 2)) <= @OpenAtHour 
																	AND (LEFT( closingHour, 2)*60 + RIGHT(closingHour, 2)) >= @OpenAtHour 
				)
			AND (@ReceptionDays IS NULL OR T.receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)))
		)
		
	)
	
AND ( (@openFromHour IS NULL OR @OpenToHour IS NULL)
	OR
	dept.deptCode IN
		(SELECT DISTINCT deptCode FROM DeptReception as T
			WHERE 
				T.deptCode = dept.deptCode
			AND ( (LEFT( openingHour, 2)*60 + RIGHT(openingHour, 2)) <= @openFromHour 
																	AND (LEFT( closingHour, 2)*60 + RIGHT(closingHour, 2)) >= @OpenToHour 
				)
			AND (@ReceptionDays IS NULL OR T.receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)))
		)
		
	)	
	
AND
	(@deptHandicappedFacilities IS NULL
	OR
	dept.deptCode IN (SELECT deptCode FROM dept as New
								WHERE (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
										WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@deptHandicappedFacilities))
										AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )
	
)
AND (@professionOrServiceCode IS NULL
	 OR
		(SELECT COUNT(*)
		FROM x_dept_employee_profession p
		INNER JOIN x_Dept_service s on p.DeptCode = s.DeptCode
		WHERE p.DeptCode = dept.DeptCode 
		AND ( p.professionCode IN  (SELECT IntField FROM dbo.SplitString(@professionOrServiceCode)) 
			  OR 
			  s.ServiceCode IN  (SELECT IntField FROM dbo.SplitString(@professionOrServiceCode))
			)) > 0
	)
	
AND ( Dept.DeptCode NOT IN	(SELECT DISTINCT DeptCode 
							FROM DeptStatus 
							WHERE Status = 0 AND DATEDIFF(dd,FromDate, GETDATE()) >= 0 
							AND (ToDate IS NULL OR DATEDIFF(dd, ToDate, GETDATE()) <= 0 )
							)
	)



order by DeptCode




GO


GRANT EXEC ON rpc_GetDeptsList TO PUBLIC

GO


