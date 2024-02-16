IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_getDoctorList_PagedSorted]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_getDoctorList_PagedSorted]
GO

CREATE Procedure [dbo].[rpc_getDoctorList_PagedSorted]
(
@FirstName varchar(max)=null,
@LastName varchar(max)=null,
@DistrictCodes varchar(max)=null,
@EmployeeID bigint=null,
@CityName varchar(max)=null,
@serviceCode varchar(max)=null,
@ExpProfession int=null,
@LanguageCode varchar(max)=null,
@ReceptionDays varchar(max)=null,
@OpenAtHour_Str varchar(max)=null,	-- string in format "hh:mm"
@OpenFromHour_Str varchar(max)=null,	-- string in format "hh:mm"
@OpenToHour_Str varchar(max)=null,	-- string in format "hh:mm"
@OpenNow bit,
@Active int=null,
@CityCode int=null,
@EmployeeSectorCode int = null,
@sex int = null,
@agreementType int = null,
@isInCommunity bit,
@isInMushlam bit,
@isInHospitals bit,
@deptHandicappedFacilities varchar(max) = null,
@licenseNumber int = null,
@positionCode int = null,
@ReceiveGuests bit,

@PageSise int = null,
@StartingPage int = null,
@SortedBy varchar(max),
@IsOrderDescending int = null,

@NumberOfRecordsToShow int=null,
@CoordinateX float=null,
@CoordinateY float=null,

@userIsRegistered int=null,

@isGetEmployeesReceptionHours bit=null,
@QueueOrderOptionsAndMethods varchar(100) = null	-- NEW parameter
)

AS

SET @StartingPage = @StartingPage - 1

IF(@OpenNow IS NULL)
	SET @OpenNow = 0

DECLARE @StartingPosition int
SET @StartingPosition = (@StartingPage * @PageSise)

DECLARE @SortedByDefault varchar(max)
SET @SortedByDefault = 'lastname'

DECLARE @Count int

DECLARE @HandicappedFacilitiesCount int

IF(@deptHandicappedFacilities is NOT null)
	SET @HandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@DeptHandicappedFacilities)), 0)

IF (@CoordinateX = -1)
BEGIN
	SET @CoordinateX = null
	SET @CoordinateY = null
END

IF @CityCode <> null
BEGIN
	SET @CityName = null
END

IF(@NumberOfRecordsToShow <> -1)
	BEGIN
	IF(@NumberOfRecordsToShow < @PageSise)
		BEGIN
			SET @PageSise = @NumberOfRecordsToShow
		END
	END	

DECLARE @OpenAtHour_var varchar(5)
DECLARE @OpenFromHour_var varchar(5)
DECLARE @OpenToHour_var varchar(5)
DECLARE @OpenAtThisHour_var varchar(5)

SET @OpenAtHour_var = IsNull(@OpenAtHour_Str,'00:00')
SET @OpenFromHour_var = IsNull(@OpenFromHour_Str,'00:00')
SET @OpenToHour_var = IsNull(@OpenToHour_Str,'24:00')
SET @OpenAtThisHour_var = '00:00'

DECLARE @DateNow date = GETDATE()

DECLARE @ReceptionDayNow tinyint

DECLARE @UseReceptionHours tinyint
	IF(@OpenAtHour_Str is null AND @OpenFromHour_Str is null AND @OpenToHour_Str is null AND @OpenNow <> 1)
		SET @UseReceptionHours = 0
	ELSE
		SET @UseReceptionHours = 1

DECLARE @ShowProvidersWithNoReceptionHours tinyint
	IF(@OpenAtHour_Str is NOT null OR @OpenFromHour_Str is NOT null OR @OpenToHour_Str is NOT null OR @OpenNow = 1 OR @ReceptionDays is NOT NULL)
		SET @ShowProvidersWithNoReceptionHours = 1
	ELSE
		SET @ShowProvidersWithNoReceptionHours = 0

--print '@UseReceptionHours = ' + CAST (@ShowProvidersWithNoReceptionHours as varchar(10))

IF (@OpenNow = 1)
BEGIN

	SET @ReceptionDayNow = DATEPART(WEEKDAY, GETDATE())
	IF(@ReceptionDays is NULL)
		SET @ReceptionDays = CAST(@ReceptionDayNow as varchar(1))
	ELSE
		IF(PATINDEX('%' + CAST(@ReceptionDayNow as varchar(1)) + '%', @ReceptionDays) = 0)
			SET @ReceptionDays = @ReceptionDays + ',' + CAST(@ReceptionDayNow as varchar(1))
		
	SET @OpenAtThisHour_var =	RIGHT('0' + CAST(DATEPART(HH, GETDATE()) as varchar(2)), 2) 
								+ ':' 
								+ RIGHT('0' + CAST(DATEPART(MINUTE, GETDATE()) as varchar(2)), 2)							 
END
CREATE TABLE #tempTableAllRows
(
	RowNumber int,
	ID bigint NOT NULL,
	employeeID bigint NOT NULL,
	EmployeeName varchar(100) NULL,	
	lastName varchar(50) NULL,
	firstName varchar(50) NULL,
	deptName varchar(100) NULL,
	deptCode int NULL,
	DeptEmployeeID bigint NULL,
	QueueOrderDescription varchar(50) NULL,
	[address] varchar(500) NULL,
	cityName varchar(50) NULL,
	phone varchar(50) NULL,
	fax varchar(50) NULL,
	HasReception bit NULL,
	HasRes varchar(50) NULL,
	expert varchar(500) NULL,		
	HasRemarks bit NULL,
	professions varchar(4000) NULL,
	[services] varchar(4000) NULL,
	positions varchar(500) NULL,
	AgreementType tinyint NULL,
	AgreementTypeDescription varchar(50) NULL,
	EmployeeLanguage varchar(100) NULL,
	EmployeeLanguageDescription varchar(500) NULL,
	distance float,
	hasMapCoordinates tinyint NULL,
	EmployeeStatus tinyint NULL,
	EmployeeStatusInDept tinyint NULL,
	orderLastNameLike tinyint,
	IsMedicalTeam bit NULL,
	IsVirtualDoctor bit NULL,
	ReceiveGuests int NULL,
	xcoord float NULL,
	ycoord float NULL,
)
-- *************************
CREATE TABLE #QueueOrderMethods (MethodCode int)
CREATE TABLE #QueueOrderOptions (OptionCode int)

INSERT INTO #QueueOrderMethods
(MethodCode)
SELECT IntField
FROM dbo.SplitString(@QueueOrderOptionsAndMethods)
WHERE IntField > 0

INSERT INTO #QueueOrderOptions
(OptionCode)
SELECT IntField + 2
FROM dbo.SplitString(@QueueOrderOptionsAndMethods)
WHERE IntField <= 0

SELECT IntField INTO #LanguageCodeTable FROM dbo.SplitString(@LanguageCode)
SELECT IntField INTO #deptHandicappedFacilitiesTable FROM dbo.SplitString(@deptHandicappedFacilities)
SELECT IntField INTO #districtCodesTable FROM dbo.SplitString(@DistrictCodes)
SELECT IntField INTO #serviceCodeTable FROM dbo.SplitString(@serviceCode)
SELECT IntField INTO #receptionDaysTable FROM dbo.SplitString(@ReceptionDays)

SELECT distinct x_Dept_Employee_Service.DeptEmployeeID, x_Dept_Employee_Service.serviceCode, x_Dept_Employee.EmployeeID, x_Dept_Employee.deptCode
INTO #AllEmployeeServicesRecordsFilteredByQueueOrder
FROM x_Dept_Employee_Service
JOIN x_Dept_Employee ON x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod ON x_Dept_Employee_Service.x_Dept_Employee_ServiceID = EmployeeServiceQueueOrderMethod.x_dept_employee_serviceID
LEFT JOIN EmployeeQueueOrderMethod ON x_Dept_Employee.DeptEmployeeID = EmployeeQueueOrderMethod.DeptEmployeeID
LEFT JOIN #QueueOrderMethods SQOM ON EmployeeServiceQueueOrderMethod.QueueOrderMethod = SQOM.MethodCode
LEFT JOIN #QueueOrderOptions SQOO ON x_Dept_Employee_Service.QueueOrder = SQOO.OptionCode

LEFT JOIN #QueueOrderMethods EQOM ON EmployeeQueueOrderMethod.QueueOrderMethod = EQOM.MethodCode
LEFT JOIN #QueueOrderOptions EQOO ON x_Dept_Employee.QueueOrder = EQOO.OptionCode

LEFT JOIN #serviceCodeTable ON x_Dept_Employee_Service.serviceCode = #serviceCodeTable.IntField
WHERE (
		(SQOM.MethodCode is not null OR SQOO.OptionCode is not null)
		OR 
		(x_Dept_Employee_Service.QueueOrder IS NULL AND (EQOM.MethodCode is not null OR EQOO.OptionCode is not null))
	)
AND (@serviceCode IS NULL OR @serviceCode = '' OR #serviceCodeTable.IntField IS NOT NULL)
--**************************
IF(@NumberOfRecordsToShow <> -1)
-- search by distance **************************
	BEGIN
		SELECT * INTO #tempTableAllRowsDistance FROM
		( 
			SELECT *, 'RowNumber' = row_number() over (order by distance )	

		FROM

		-- inner selection - "employees themself"
		(

		SELECT DISTINCT 
		EmployeeInClinic_preselected.ID,
		EmployeeInClinic_preselected.employeeID,
		EmployeeInClinic_preselected.deptCode,
		EmployeeInClinic_preselected.DeptEmployeeID,
		'distance' = (EmployeeInClinic_preselected.xcoord - @CoordinateX)*(EmployeeInClinic_preselected.xcoord - @CoordinateX) + (EmployeeInClinic_preselected.ycoord - @CoordinateY)*(EmployeeInClinic_preselected.ycoord - @CoordinateY)

		FROM EmployeeInClinic_preselected

		LEFT JOIN x_Dept_Employee ON EmployeeInClinic_preselected.employeeID = x_Dept_Employee.employeeID
			AND EmployeeInClinic_preselected.deptCode = x_Dept_Employee.deptCode
			AND (@userIsRegistered = 1 OR x_Dept_Employee.employeeID is NOT NULL)
		LEFT JOIN dept ON EmployeeInClinic_preselected.deptCode = dept.deptCode
			AND (@userIsRegistered = 1 OR dept.status = 1)

		LEFT JOIN vEmplServReseption as vEmSerRecep	
			ON x_Dept_Employee.deptCode = vEmSerRecep.deptCode
			AND x_Dept_Employee.employeeID = vEmSerRecep.employeeID
			AND CAST(GETDATE() as date) between ISNULL(vEmSerRecep.validFrom,'1900-01-01') and ISNULL(vEmSerRecep.validTo,'2079-01-01')
			
		LEFT JOIN vEmplServAgreemExpert as vEmSerExp
			ON x_Dept_Employee.deptCode = vEmSerExp.deptCode
			AND x_Dept_Employee.employeeID = vEmSerExp.employeeID

		LEFT JOIN #AllEmployeeServicesRecordsFilteredByQueueOrder 
			ON x_Dept_Employee.DeptEmployeeID = #AllEmployeeServicesRecordsFilteredByQueueOrder.DeptEmployeeID

		WHERE  (@DistrictCodes is NULL
			OR
				dept.districtCode IN (SELECT IntField FROM #districtCodesTable)
			OR
				dept.DeptCode IN (SELECT x_Dept_District.DeptCode FROM #districtCodesTable
									 JOIN  x_Dept_District ON #districtCodesTable.IntField = x_Dept_District.districtCode) 
			)
		AND (@QueueOrderOptionsAndMethods IS NULL OR @QueueOrderOptionsAndMethods = '' OR #AllEmployeeServicesRecordsFilteredByQueueOrder.DeptEmployeeID IS NOT NULL) -- !!! NEW

		AND (@FirstName is NULL OR EmployeeInClinic_preselected.FirstName like @FirstName +'%')
		AND (@LastName is NULL OR EmployeeInClinic_preselected.LastName like @LastName +'%')
		AND (@EmployeeID is NULL OR EmployeeInClinic_preselected.EmployeeID = @EmployeeID )
		AND (@CityName is NULL OR  EmployeeInClinic_preselected.CityName like @CityName +'%')
		AND (@CoordinateX is NOT NULL OR (@CityCode is NULL OR EmployeeInClinic_preselected.cityCode = @CityCode))
		AND (@Active is NULL
			OR
			(
				(@Active = 1 
					AND (EmployeeInClinic_preselected.EmployeeStatusInDept IN (1,2) 
						or 
						(EmployeeInClinic_preselected.EmployeeStatusInDept is null and EmployeeInClinic_preselected.EmployeeStatus IN (1,2))
						)
				)

				OR
				
				(@Active <> 1
				AND (EmployeeInClinic_preselected.EmployeeStatusInDept = @Active 
					or
					(EmployeeInClinic_preselected.EmployeeStatusInDept is null and EmployeeInClinic_preselected.EmployeeStatus = @Active))
			)
			)
			)
		AND (@EmployeeSectorCode is NULL OR EmployeeInClinic_preselected.EmployeeSectorCode = @EmployeeSectorCode)
		AND (@Sex is NULL OR EmployeeInClinic_preselected.sex = @Sex)
		AND (@ExpProfession is NULL OR @serviceCode is NOT NULL OR EmployeeInClinic_preselected.IsExpert = @ExpProfession ) 
		AND (@serviceCode is NULL 
				OR
				(vEmSerExp.serviceCode IN (SELECT IntField FROM #serviceCodeTable)
					AND	
					((@IsInCommunity = 1 AND (vEmSerExp.AgreementType in (1,2,6)))
						OR
					(@IsInMushlam = 1 AND (vEmSerExp.AgreementType in (3,4)))
						OR
					(@IsInHospitals = 1 AND vEmSerExp.AgreementType = 5)
					)
					AND
					(@ExpProfession is NULL OR vEmSerExp.ExpProfession = @ExpProfession)
				)
			)
		AND (@AgreementType is NULL OR EmployeeInClinic_preselected.AgreementType = @AgreementType)

		AND (
				(@isInCommunity is not NULL AND EmployeeInClinic_preselected.IsInCommunity = @IsInCommunity 
						AND (Dept.IsCommunity = @IsInCommunity OR Dept.IsCommunity IS NULL)
				)
			OR (@isInMushlam is not NULL AND EmployeeInClinic_preselected.IsInMushlam = @IsInMushlam 
						AND (Dept.IsMushlam = @IsInMushlam OR Dept.IsMushlam IS NULL)
				)
			OR (@isInHospitals is not NULL AND EmployeeInClinic_preselected.isInHospitals = @isInHospitals 
						AND (Dept.isHospital = @isInHospitals OR Dept.isHospital IS NULL)
				)
			)
			
		AND (@LanguageCode is NULL 
				OR 
				exists (
				SELECT * FROM dbo.SplitString(EmployeeInClinic_preselected.EmployeeLanguage) as T 
				JOIN #LanguageCodeTable ON #LanguageCodeTable.IntField = T.IntField)
			)

		AND (@deptHandicappedFacilities is NULL 
				OR 
				(SELECT COUNT(T.IntField) FROM dbo.SplitString(EmployeeInClinic_preselected.DeptHandicappedFacilities) as T 
				JOIN #deptHandicappedFacilitiesTable ON #deptHandicappedFacilitiesTable.IntField = T.IntField) = @HandicappedFacilitiesCount)	
			
		AND (@positionCode is NULL 
				OR 
				exists (SELECT xd.employeeID 
						FROM x_Dept_Employee_Position xdep
						INNER JOIN x_Dept_Employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
						WHERE x_Dept_Employee.employeeID = xd.employeeID
						AND xdep.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID									
						AND xdep.positionCode = @PositionCode)
			)
		AND	(
				(@ReceptionDays is NULL AND @OpenNow = 0)
				OR
				(
					(
						vEmSerRecep.receptionDay IN (SELECT IntField FROM #receptionDaysTable)
						AND
						(@ServiceCode is NULL OR vEmSerRecep.serviceCode IN (SELECT IntField FROM #serviceCodeTable))		
					)	
				)
			)
		AND (
				(@OpenToHour_Str is NULL AND @OpenFromHour_Str is NULL)
				OR
				 ( vEmSerRecep.openingHour < @OpenToHour_var AND vEmSerRecep.closingHour > @OpenFromHour_var )
			)
		AND ( @OpenAtHour_Str is NULL 
				OR (vEmSerRecep.openingHour <= @OpenAtHour_var AND vEmSerRecep.closingHour >= @OpenAtHour_var )
			)
		AND ( @OpenNow = 0
				OR  ( vEmSerRecep.openingHour <= @OpenAtThisHour_var AND vEmSerRecep.closingHour >= @OpenAtThisHour_var )
			)
		AND ((@ReceiveGuests is NULL OR @ReceiveGuests = 0 
				OR ((@UseReceptionHours = 0 AND @ReceptionDays is NULL) OR vEmSerRecep.ReceiveGuests = @ReceiveGuests) )
			)				
		AND (@CoordinateX is NULL OR ( xcoord <> 0 AND ycoord <> 0)) -- redundantly????

		AND (@licenseNumber is NULL OR EmployeeInClinic_preselected.licenseNumber = @LicenseNumber)

		AND (@ReceiveGuests is NULL OR @ReceiveGuests = 0 OR EmployeeInClinic_preselected.ReceiveGuests = @ReceiveGuests)

		AND (@NumberOfRecordsToShow is NULL OR (EmployeeInClinic_preselected.xcoord <> 0 and EmployeeInClinic_preselected.ycoord <> 0))

		) as innerSelection
		) as middleSelection
		OPTION (RECOMPILE)
	
		INSERT INTO #tempTableAllRows 
		SELECT 
		#tempTableAllRowsDistance.RowNumber,
		EmployeeInClinic_preselected.ID,		 
		EmployeeInClinic_preselected.employeeID,
		EmployeeInClinic_preselected.EmployeeName,
		EmployeeInClinic_preselected.lastname,
		EmployeeInClinic_preselected.firstName,
		EmployeeInClinic_preselected.deptName,
		EmployeeInClinic_preselected.deptCode,
		EmployeeInClinic_preselected.DeptEmployeeID,
		EmployeeInClinic_preselected.QueueOrderDescription,
		EmployeeInClinic_preselected.address,
		EmployeeInClinic_preselected.cityName,
		EmployeeInClinic_preselected.phone,
		EmployeeInClinic_preselected.fax,
		EmployeeInClinic_preselected.HasReception,
		CASE WHEN EmployeeInClinic_preselected.HasReception = 1 THEN 'כן' else 'לא' end as  HasRes,
		'expert' = EmployeeInClinic_preselected.ExpProfession,
		EmployeeInClinic_preselected.HasRemarks,
		EmployeeInClinic_preselected.professions_ASC as 'professions',
		EmployeeInClinic_preselected.[services],
		EmployeeInClinic_preselected.positions,	
		EmployeeInClinic_preselected.AgreementType,
		EmployeeInClinic_preselected.AgreementTypeDescription,
		EmployeeInClinic_preselected.EmployeeLanguage,
		EmployeeInClinic_preselected.EmployeeLanguageDescription,		
		#tempTableAllRowsDistance.distance,
		EmployeeInClinic_preselected.hasMapCoordinates,
		EmployeeInClinic_preselected.EmployeeStatus,
		EmployeeInClinic_preselected.EmployeeStatusInDept,
		'orderLastNameLike' = 1,
		EmployeeInClinic_preselected.IsMedicalTeam,
		EmployeeInClinic_preselected.IsVirtualDoctor,
		EmployeeInClinic_preselected.ReceiveGuests,
		EmployeeInClinic_preselected.xcoord,
		EmployeeInClinic_preselected.ycoord
		FROM EmployeeInClinic_preselected
		JOIN #tempTableAllRowsDistance 
			ON #tempTableAllRowsDistance.employeeID = EmployeeInClinic_preselected.employeeID
			AND #tempTableAllRowsDistance.deptCode = EmployeeInClinic_preselected.deptCode					
			AND #tempTableAllRowsDistance.DeptEmployeeID = EmployeeInClinic_preselected.DeptEmployeeID		
	END		
-- END search by distance **************************
ELSE
-- regular search **************************
	BEGIN
		INSERT INTO #tempTableAllRows SELECT * FROM
			( 
			SELECT 
		'RowNumber' = row_number() over (order by 
									(	CASE WHEN @ShowProvidersWithNoReceptionHours = 1 THEN
												HasRes 
											ELSE
												null 														
											END
									)
									,
									(case	
											when @SortedBy='lastname' 
											then lastname
											when @SortedBy='deptName' 
											then deptName 
											when @SortedBy='professions' 
											then professions
											when @SortedBy='cityName' 
											then cityName									
											when @SortedBy='phone' 
											then phone	
											when @SortedBy='address' 
											then 'address'
											when @SortedBy='AgreementType' 
											then CAST(AgreementType	as varchar(50))
											else 

											CAST(newid() as varchar(50))
											end 
											)									
											+
									case	when @IsOrderDescending = 0 
											then '' else null end
									,case when @SortedBy='distance' then CAST(deptCode as varchar(50)) else null end									
									,(case	
											when @SortedBy='lastname' 
											then lastname
											when @SortedBy='deptName' 
											then deptName 
											when @SortedBy='professions' 
											then professions
											when @SortedBy='cityName' 
											then cityName									
											when @SortedBy='phone' 
											then phone	
											when @SortedBy='address' 
											then 'address'
											when @SortedBy='AgreementType' 
											then CAST(AgreementType	as varchar(50))	
											else CAST(newid() as varchar(50)) --lastname 																			
											end )
											+
									case	when @IsOrderDescending = 1 
											then '' else null end
											
											DESC
							)	
		,*
		FROM

		-- inner selection - "employees themself"
		(

		SELECT DISTINCT 
		EmployeeInClinic_preselected.ID,
		EmployeeInClinic_preselected.employeeID,
		EmployeeInClinic_preselected.EmployeeName,
		EmployeeInClinic_preselected.lastname,
		EmployeeInClinic_preselected.firstName,
		EmployeeInClinic_preselected.deptName,
		EmployeeInClinic_preselected.deptCode,
		EmployeeInClinic_preselected.DeptEmployeeID,
		EmployeeInClinic_preselected.QueueOrderDescription,
		EmployeeInClinic_preselected.address,
		EmployeeInClinic_preselected.cityName,
		EmployeeInClinic_preselected.phone,
		EmployeeInClinic_preselected.fax,
		EmployeeInClinic_preselected.HasReception,
		CASE WHEN EmployeeInClinic_preselected.HasReception = 1 THEN 'כן' else 'לא' end as  HasRes,
		'expert' = EmployeeInClinic_preselected.ExpProfession,
		EmployeeInClinic_preselected.HasRemarks,
		CASE WHEN @IsOrderDescending = 0 THEN EmployeeInClinic_preselected.professions_ASC
			ELSE EmployeeInClinic_preselected.professions_DESC END as 'professions',
		EmployeeInClinic_preselected.[services],
		EmployeeInClinic_preselected.positions,	
		EmployeeInClinic_preselected.AgreementType,
		EmployeeInClinic_preselected.AgreementTypeDescription,
		EmployeeInClinic_preselected.EmployeeLanguage,
		EmployeeInClinic_preselected.EmployeeLanguageDescription,		
		'distance' = (EmployeeInClinic_preselected.xcoord - @CoordinateX)*(EmployeeInClinic_preselected.xcoord - @CoordinateX) + (EmployeeInClinic_preselected.ycoord - @CoordinateY)*(EmployeeInClinic_preselected.ycoord - @CoordinateY),
		EmployeeInClinic_preselected.hasMapCoordinates,
		EmployeeInClinic_preselected.EmployeeStatus,
		EmployeeInClinic_preselected.EmployeeStatusInDept,
		'orderLastNameLike' =
			CASE WHEN @LastName is NOT null AND EmployeeInClinic_preselected.LastName like @LastName + '%' THEN 0
				 WHEN @LastName is NOT null AND EmployeeInClinic_preselected.LastName like '%' + @LastName + '%' THEN 1 
				 ELSE 0 END,
		EmployeeInClinic_preselected.IsMedicalTeam,
		EmployeeInClinic_preselected.IsVirtualDoctor,
		EmployeeInClinic_preselected.ReceiveGuests,
		EmployeeInClinic_preselected.xcoord,
		EmployeeInClinic_preselected.ycoord

		FROM EmployeeInClinic_preselected

		LEFT JOIN x_Dept_Employee ON EmployeeInClinic_preselected.employeeID = x_Dept_Employee.employeeID
			AND EmployeeInClinic_preselected.deptCode = x_Dept_Employee.deptCode
			AND (@userIsRegistered = 1 OR x_Dept_Employee.employeeID is NOT NULL)
		LEFT JOIN dept ON EmployeeInClinic_preselected.deptCode = dept.deptCode
			AND (@userIsRegistered = 1 OR dept.status = 1)

		LEFT JOIN vEmplServReseption as vEmSerRecep	
			ON x_Dept_Employee.deptCode = vEmSerRecep.deptCode
			AND x_Dept_Employee.employeeID = vEmSerRecep.employeeID
			AND CAST(GETDATE() as date) between ISNULL(vEmSerRecep.validFrom,'1900-01-01') and ISNULL(vEmSerRecep.validTo,'2079-01-01')
			
		LEFT JOIN vEmplServAgreemExpert as vEmSerExp
			ON x_Dept_Employee.deptCode = vEmSerExp.deptCode
			AND x_Dept_Employee.employeeID = vEmSerExp.employeeID

		LEFT JOIN #AllEmployeeServicesRecordsFilteredByQueueOrder 
			ON x_Dept_Employee.DeptEmployeeID = #AllEmployeeServicesRecordsFilteredByQueueOrder.DeptEmployeeID

		WHERE 
			(@DistrictCodes is NULL
			OR
				dept.districtCode IN (SELECT IntField FROM #districtCodesTable)
			OR
				dept.DeptCode IN (SELECT x_Dept_District.DeptCode FROM #districtCodesTable
									 JOIN  x_Dept_District ON #districtCodesTable.IntField = x_Dept_District.districtCode) 
			)
		AND (@QueueOrderOptionsAndMethods IS NULL OR @QueueOrderOptionsAndMethods = '' OR #AllEmployeeServicesRecordsFilteredByQueueOrder.DeptEmployeeID IS NOT NULL) -- !!! NEW

		AND (@FirstName is NULL OR EmployeeInClinic_preselected.FirstName like @FirstName +'%')
		AND (@LastName is NULL OR EmployeeInClinic_preselected.LastName like @LastName +'%')
		AND (@EmployeeID is NULL OR EmployeeInClinic_preselected.EmployeeID = @EmployeeID )
		AND (@CityName is NULL OR  EmployeeInClinic_preselected.CityName like @CityName +'%')
		AND (@CoordinateX is NOT NULL OR (@CityCode is NULL OR EmployeeInClinic_preselected.cityCode = @CityCode))
		AND (@Active is NULL
			OR
			(
				(@Active = 1 
					AND (EmployeeInClinic_preselected.EmployeeStatusInDept IN (1,2) 
						or 
						(EmployeeInClinic_preselected.EmployeeStatusInDept is null and EmployeeInClinic_preselected.EmployeeStatus IN (1,2))
						)
				)

				OR
				
				(@Active <> 1
				AND (EmployeeInClinic_preselected.EmployeeStatusInDept = @Active 
					or
					(EmployeeInClinic_preselected.EmployeeStatusInDept is null and EmployeeInClinic_preselected.EmployeeStatus = @Active))
			)
			)
			)
		AND (@EmployeeSectorCode is NULL OR EmployeeInClinic_preselected.EmployeeSectorCode = @EmployeeSectorCode)
		AND (@Sex is NULL OR EmployeeInClinic_preselected.sex = @Sex)
		--AND (@ExpProfession is NULL OR EmployeeInClinic_preselected.IsExpert = @ExpProfession ) 
		AND (@ExpProfession is NULL OR @serviceCode is NOT NULL OR EmployeeInClinic_preselected.IsExpert = @ExpProfession ) 
		AND (@serviceCode is NULL 
				OR
				(vEmSerExp.serviceCode IN (SELECT IntField FROM #serviceCodeTable)
					AND	
					((@IsInCommunity = 1 AND (vEmSerExp.AgreementType in (1,2,6)))
						OR
					(@IsInMushlam = 1 AND (vEmSerExp.AgreementType in (3,4)))
						OR
					(@IsInHospitals = 1 AND vEmSerExp.AgreementType = 5)
					)
					AND
					(@ExpProfession is NULL OR vEmSerExp.ExpProfession = @ExpProfession)
				)
			)
		AND (@AgreementType is NULL OR EmployeeInClinic_preselected.AgreementType = @AgreementType)

		AND (
				(@isInCommunity is not NULL AND EmployeeInClinic_preselected.IsInCommunity = @IsInCommunity 
						AND (Dept.IsCommunity = @IsInCommunity OR Dept.IsCommunity IS NULL)
				)
			OR (@isInMushlam is not NULL AND EmployeeInClinic_preselected.IsInMushlam = @IsInMushlam 
						AND (Dept.IsMushlam = @IsInMushlam OR Dept.IsMushlam IS NULL)
				)
			OR (@isInHospitals is not NULL AND EmployeeInClinic_preselected.isInHospitals = @isInHospitals 
						AND (Dept.isHospital = @isInHospitals OR Dept.isHospital IS NULL)
				)
			)
		AND (@LanguageCode is NULL 
				OR 
				exists (
				SELECT * FROM dbo.SplitString(EmployeeInClinic_preselected.EmployeeLanguage) as T 
				JOIN #LanguageCodeTable ON #LanguageCodeTable.IntField = T.IntField)
			)

		AND (@deptHandicappedFacilities is NULL 
				OR 
				(SELECT COUNT(T.IntField) FROM dbo.SplitString(EmployeeInClinic_preselected.DeptHandicappedFacilities) as T 
				JOIN #deptHandicappedFacilitiesTable ON #deptHandicappedFacilitiesTable.IntField = T.IntField) = @HandicappedFacilitiesCount)	
			
		AND (@positionCode is NULL 
				OR 
				exists (SELECT xd.employeeID 
						FROM x_Dept_Employee_Position xdep
						INNER JOIN x_Dept_Employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
						WHERE x_Dept_Employee.employeeID = xd.employeeID
						AND xdep.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID									
						AND xdep.positionCode = @PositionCode)
			)
		AND ( 
				(@ShowProvidersWithNoReceptionHours = 1 
					AND 
					(HasReception = 0 
						OR 
						(	@serviceCode = NULL
							AND
							NOT exists(SELECT * FROM vEmplServReseption vESR 
										WHERE vESR.employeeID = vEmSerRecep.employeeID 
										AND vESR.deptCode = vEmSerRecep.deptCode 
										AND vESR.serviceCode IN (SELECT IntField FROM #serviceCodeTable) 
										) 
						)
					)
---- Check if clinic works
					AND
					(
						EXISTS 
						(SELECT deptCode FROM DeptReception_Regular as T
						 WHERE T.deptCode = dept.deptCode
						 AND @DateNow between ISNULL(T.validFrom,'1900-01-01') and ISNULL(T.validTo,'2079-01-01')
						 AND (	@OpenToHour_str IS NULL 
								OR
								(
									openingHour < @OpenToHour_str 
									AND 
									closingHour > @OpenFromHour_str 
								)
							 )

						 AND (	@OpenAtHour_Str IS NULL 
								OR
								(
									openingHour <= @OpenAtHour_str 
									AND
									closingHour > @OpenAtHour_str 
								)
							)
						AND (@OpenNow = 0 
								OR
								(
									openingHour  <= @OpenAtHour_str 
									AND
									closingHour > @OpenAtHour_str 
								)
							)
						AND (@ReceptionDays IS NULL 
								OR
								exists (select * from #receptionDaysTable where IntField = T.receptionDay)
							)
						)
					)

				)
				OR 
				( (
						(@ReceptionDays is NULL AND @OpenNow = 0)
						OR
						(
							(
								vEmSerRecep.receptionDay IN (SELECT IntField FROM #receptionDaysTable)
								AND
								(@ServiceCode is NULL OR vEmSerRecep.serviceCode IN (SELECT IntField FROM #serviceCodeTable))		
							)	
						)
					)
				AND (
						(@OpenToHour_Str is NULL AND @OpenFromHour_Str is NULL)
						OR
						 ( vEmSerRecep.openingHour < @OpenToHour_var AND vEmSerRecep.closingHour > @OpenFromHour_var )
					)
				AND ( @OpenAtHour_Str is NULL 
						OR (vEmSerRecep.openingHour <= @OpenAtHour_var AND vEmSerRecep.closingHour >= @OpenAtHour_var )
					)
				AND ( @OpenNow = 0
						OR  ( vEmSerRecep.openingHour <= @OpenAtThisHour_var AND vEmSerRecep.closingHour >= @OpenAtThisHour_var )
					)
				AND ((@ReceiveGuests is NULL OR @ReceiveGuests = 0 
						OR ((@UseReceptionHours = 0 AND @ReceptionDays is NULL) OR vEmSerRecep.ReceiveGuests = @ReceiveGuests) )
					)
				)
			)				
		AND (@CoordinateX is NULL OR ( xcoord <> 0 AND ycoord <> 0)) -- redundant????

		AND (@licenseNumber is NULL OR EmployeeInClinic_preselected.licenseNumber = @LicenseNumber)

		AND (@ReceiveGuests is NULL OR @ReceiveGuests = 0 OR EmployeeInClinic_preselected.ReceiveGuests = @ReceiveGuests)

		AND (@NumberOfRecordsToShow is NULL OR (EmployeeInClinic_preselected.xcoord <> 0 and EmployeeInClinic_preselected.ycoord <> 0))

		) as innerSelection
		) as middleSelection
	END	
-- END regular search **************************


SELECT TOP (@PageSise) * INTO #tempTable FROM #tempTableAllRows
WHERE RowNumber > @StartingPosition AND RowNumber <= @StartingPosition + @PageSise
ORDER BY RowNumber

SELECT #tempTable.*,
		CASE WHEN EXISTS
			(SELECT * from View_DeptRemarks
			JOIN Dept d ON View_DeptRemarks.deptCode = d.deptCode
			WHERE View_DeptRemarks.deptCode = #tempTable.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
			AND (IsSharedRemark = 0 OR d.IsCommunity = 1)
			)

			OR 
	
			EXISTS
			(SELECT * from View_DeptEmployee_EmployeeRemarks as v_DE_ER	
			WHERE v_DE_ER.deptCode = #tempTable.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01')))
		THEN 1 ELSE 0 END as countDeptRemarks,
		CASE WHEN EXISTS
			(select * from DeptReception_Regular
			where deptCode = #tempTable.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
			) THEN 1 ELSE 0 END
		as 	countReception,
		IsNull(dept.subUnitTypeCode, -1) as subUnitTypeCode,
		dept.IsCommunity,
		dept.IsMushlam,
		dept.IsHospital
FROM #tempTable
LEFT JOIN Dept ON #tempTable.deptCode = Dept.deptCode

/***** DeptPhones ************************/
SELECT *
INTO #tempTableDeptPhones
FROM(
-- DeptPhones (new via employees services)
SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID
	,dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
INNER JOIN #tempTable ON xdes.DeptEmployeeID = #tempTable.DeptEmployeeID 
INNER JOIN DIC_QueueOrderMethod ON esqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTable.deptCode = DeptPhones.deptCode
WHERE phoneType = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1 

UNION

-- DeptPhones (old via Employee)
SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID,  
	dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTable.deptCode = DeptPhones.deptCode

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	AND  esqom.QueueOrderMethod = 1
WHERE phoneType = 1 AND SpecialPhoneNumberRequired = 0 
AND ShowPhonePicture = 1 AND esqom.x_dept_employee_serviceID is null
--OPTION (FORCE order)
) T

/*****  END DeptPhones ************************/

/*****  QueueOrderPhones ************************/
SELECT *
INTO #tempQueueOrderPhones
FROM(
-- SpecialPhones (new via employees services)
SELECT xde.deptCode, xde.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(esqop.prePrefix, esqop.prefix, esqop.phone, esqop.extension) as Phone
FROM #tempTable
JOIN x_Dept_Employee xde ON #tempTable.deptCode = xde.deptCode
	AND #tempTable.employeeID = xde.employeeID
JOIN x_Dept_Employee_Service xdes ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	--AND #tempTableFinalSelect.ServiceID = xdes.serviceCode
JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID

UNION

-- SpecialPhones (old via Employee)
SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
WHERE esqom.x_dept_employee_serviceID is null
) T
/*****  END QueueOrderPhones ************************/

/********************  QueueOrderMethods *************************/
SELECT QO.*, Ph.Phone
INTO #tempTableQueueOrder
FROM(
	-- QueueOrderMethods (via employees services)
	SELECT ISNULL(esqom.QueueOrderMethod, 0) as QueueOrderMethod, #tempTable.deptCode, #tempTable.employeeID, 
		DIC_ReceptionDays.receptionDayName, esqoh.FromHour, esqoh.ToHour, xdes.serviceCode as ServiceID,
		s.ServiceDescription,
		DIC_QueueOrder.QueueOrderDescription, DIC_QueueOrder.QueueOrder,
		#tempTable.RowNumber
	FROM x_Dept_Employee_Service xdes 
	INNER JOIN x_Dept_Employee xde ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	INNER JOIN #tempTable ON xdes.DeptEmployeeID = #tempTable.DeptEmployeeID
	INNER JOIN [Services] s ON xdes.serviceCode = s.ServiceCode	
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
	LEFT JOIN dbo.DIC_QueueOrder ON xdes.QueueOrder = DIC_QueueOrder.QueueOrder

	LEFT JOIN EmployeeServiceQueueOrderHours esqoh ON esqom.EmployeeServiceQueueOrderMethodID = esqoh.EmployeeServiceQueueOrderMethodID
	LEFT JOIN DIC_ReceptionDays ON esqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	WHERE xdes.QueueOrder is not null
	
	UNION

	-- QueueOrderMethods (via Employee)
	SELECT ISNULL(eqom.QueueOrderMethod, 0) as QueueOrderMethod, #tempTable.deptCode, #tempTable.employeeID, 
		DIC_ReceptionDays.receptionDayName, eqoh.FromHour, eqoh.ToHour
		,xdes.serviceCode as ServiceID, s.ServiceDescription,
		ISNULL(DIC_QueueOrder.QueueOrderDescription, '') as QueueOrderDescription, ISNULL(DIC_QueueOrder.QueueOrder, 2) as QueueOrder,
		#tempTable.RowNumber		
	FROM #tempTable
	LEFT JOIN EmployeeQueueOrderMethod eqom ON eqom.DeptEmployeeID = #tempTable.DeptEmployeeID 
	LEFT JOIN EmployeeQueueOrderHours eqoh ON eqom.QueueOrderMethodID = eqoh.QueueOrderMethodID
	LEFT JOIN DIC_ReceptionDays ON eqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	JOIN x_Dept_Employee xde ON #tempTable.DeptEmployeeID = xde.DeptEmployeeID
	LEFT JOIN dbo.DIC_QueueOrder ON xde.QueueOrder = DIC_QueueOrder.QueueOrder
	-- exclude when queue order for service exists
	JOIN x_Dept_Employee_Service xdes 
		ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
	LEFT JOIN [Services] s ON xdes.serviceCode = s.ServiceCode
	WHERE xdes.QueueOrder is null
	
	) QO
LEFT JOIN
(	
	-- SpecialPhones (new via employees services)
	SELECT xde.deptCode, xde.employeeID, xdes.serviceCode as ServiceID,
	dbo.fun_ParsePhoneNumberWithExtension(esqop.prePrefix, esqop.prefix, esqop.phone, esqop.extension) as Phone
	FROM #tempTable
	JOIN x_Dept_Employee xde ON #tempTable.deptCode = xde.deptCode
		AND #tempTable.employeeID = xde.employeeID
	JOIN x_Dept_Employee_Service xdes ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID

	UNION

	-- SpecialPhones (old via Employee)
	SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID,
	dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
	FROM #tempTable  
	INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
	INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

	LEFT JOIN x_Dept_Employee_Service xdes 
		ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom
		ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	WHERE esqom.x_dept_employee_serviceID is null
) Ph 
	ON QO.deptCode = Ph.deptCode 
	AND QO.employeeID = Ph.employeeID
	AND QO.ServiceID = Ph.ServiceID	

----------------------------------------
SELECT DISTINCT QueueOrderMethod, ISNULL(QueueOrder, 2) as QueueOrder, deptCode, employeeID, ServiceID
INTO #tempTableMarker
FROM #tempTableQueueOrder

SELECT QueueOrderMethod, QueueOrder, deptCode, employeeID, ServiceID,
LEFT(CAST(QueueOrder as varchar(1))
		+ REPLACE(
			 stuff((SELECT ',' + CONVERT(VARCHAR,QueueOrderMethod) 
			 FROM #tempTableMarker ttM2
			 WHERE ttM2.employeeID = ttM.employeeID
			 AND  ttM2.deptCode = ttM.deptCode
			 AND  ttM2.ServiceID = ttM.ServiceID
			 order by ttM2.QueueOrderMethod
			 for xml path ('')
			 ), 1, 1, ''), ',','')
		+ '0000', 5)
		 as 'Marker'
INTO #tempTableMarkerStuff
FROM #tempTableMarker ttM

----------------------------------------
SELECT ttQO.QueueOrderMethod, ttQO.QueueOrderDescription, ttQO.QueueOrder, ttQO.deptCode, ttQO.employeeID, ttQO.receptionDayName, ttQO.FromHour, ttQO.ToHour, ttQO.ServiceID, ttQO.ServiceDescription
,ttM.Marker + LEFT( REPLACE( REPLACE(ISNULL(ttQO.Phone, '000000000'), '-', ''),'*', '')  , 9) as 'Marker'
,ttQO.RowNumber
,ttDP.Phone as DeptPhone, ttQOP.Phone as QueueOrderPhone
FROM #tempTableQueueOrder ttQO
JOIN #tempTableMarkerStuff ttM 
	ON ttQO.deptCode = ttM.deptCode AND ttQO.employeeID = ttM.employeeID
	AND ttQO.ServiceID = ttM.ServiceID AND ttQO.QueueOrderMethod = ttM.QueueOrderMethod
	AND ttQO.QueueOrder = ttM.QueueOrder

LEFT JOIN #tempTableDeptPhones ttDP
	ON ttQO.deptCode = ttDP.deptCode
	AND ttQO.employeeID = ttDP.employeeID
	AND ttQO.ServiceID = ttDP.ServiceID
	
LEFT JOIN #tempQueueOrderPhones ttQOP
	ON ttQO.deptCode = ttQOP.deptCode
	AND ttQO.employeeID = ttQOP.employeeID
	AND ttQO.ServiceID = ttQOP.ServiceID	
/******************** END  QueueOrderMethods *************************/

DROP TABLE #tempTable
DROP TABLE #tempTableQueueOrder
DROP TABLE #tempTableMarkerStuff
DROP TABLE #tempTableMarker
DROP TABLE #tempTableDeptPhones
DROP TABLE #tempQueueOrderPhones

-- select with same joins and conditions as above
-- just to get count of all the records in select

SET @Count = (SELECT COUNT(*) FROM #tempTableAllRows)

IF(@NumberOfRecordsToShow is NOT null)
BEGIN
	IF(@Count > @NumberOfRecordsToShow)
	BEGIN
		SET @Count = @NumberOfRecordsToShow
	END
END
	
SELECT @Count

-- For values to be passed as parameters for page by page search
 SELECT ID FROM #tempTableAllRows ORDER BY RowNumber
--SELECT @Count -- temp

IF(@isGetEmployeesReceptionHours = 1)
BEGIN
	SELECT v.[deptCode]
		  ,v.[receptionID]
		  ,v.[EmployeeID]
		  ,v.[receptionDay]
		  ,v.[openingHour]
		  ,v.[closingHour]
		  ,v.[ReceptionDayName]
		  ,v.[OpeningHourText]
		  ,v.[EmployeeSectorCode]
		  ,v.[ServiceDescription]
		  ,DERR.RemarkText
		  ,v.[ServiceCode]
		  ,v.[AgreementType]
	  FROM [dbo].[vEmployeeReceptionHours_Having180300service] v
	  left join deptEmployeeReception dER on v.receptionID = dER.receptionID
	  left join DeptEmployeeReceptionRemarks DERR on dER.receptionID = DERR.EmployeeReceptionID
	  inner join #tempTableAllRows tbl
	  on tbl.deptCode = v.deptCode
	  and tbl.EmployeeID = v.EmployeeID
	  and tbl.AgreementType = v.AgreementType
	  order by v.[EmployeeID],v.[deptCode],v.[ServiceDescription]


	--Remarks
	SELECT distinct
		v_DE_ER.EmployeeID,
		v_DE_ER.DeptCode,
		dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as RemarkText,
		CONVERT(VARCHAR(2),DAY(v_DE_ER.ValidTo)) + '/' + CONVERT(VARCHAR(2),MONTH(v_DE_ER.ValidTo)) + '/' + CONVERT(VARCHAR(4),YEAR(v_DE_ER.ValidTo)) as ValidTo
	FROM View_DeptEmployee_EmployeeRemarks v_DE_ER
		inner join #tempTableAllRows tbl
		on tbl.deptCode = v_DE_ER.deptCode
		and tbl.EmployeeID = v_DE_ER.EmployeeID
		where GETDATE() between ISNULL(v_DE_ER.validFrom,'1900-01-01') 
						and ISNULL(v_DE_ER.validTo,'2079-01-01')

	UNION

	SELECT
		xde.EmployeeID,
		xde.DeptCode,
		dbo.rfn_GetFotmatedRemark(desr.RemarkText),
		CONVERT(VARCHAR(2),DAY(desr.ValidTo)) + '/' + CONVERT(VARCHAR(2),MONTH(desr.ValidTo)) + '/' + CONVERT(VARCHAR(4),YEAR(desr.ValidTo))
	FROM view_DeptEmployeeServiceRemarks desr
	INNER JOIN x_dept_employee_service xdes ON desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID AND xdes.Status = 1
	inner join x_dept_employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
	inner join #tempTableAllRows tbl on tbl.deptCode = xde.deptCode
	and tbl.EmployeeID = xde.EmployeeID
	where GETDATE() between ISNULL(desr.validFrom,'1900-01-01') 
						and ISNULL(desr.validTo,'2079-01-01')

END

DROP TABLE #tempTableAllRows


GO

GO

GRANT EXEC ON rpc_getDoctorList_PagedSorted TO [clalit\webuser]
GO

GRANT EXEC ON rpc_getDoctorList_PagedSorted TO [clalit\IntranetDev]
GO
