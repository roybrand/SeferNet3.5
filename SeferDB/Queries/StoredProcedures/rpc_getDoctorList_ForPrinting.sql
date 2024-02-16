IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDoctorList_ForPrinting')
	BEGIN
		DROP  Procedure  rpc_getDoctorList_ForPrinting
	END
GO

CREATE Procedure [dbo].[rpc_getDoctorList_ForPrinting]
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

@userIsRegistered int=null

)

AS

SET @StartingPage = @StartingPage - 1

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

DECLARE @DateNow datetime
SET @DateNow = GETDATE()

DECLARE @ReceptionDayNow tinyint

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
	expert varchar(500) NULL,		
	HasRemarks bit NULL,
	professions varchar(500) NULL,
	[services] varchar(500) NULL,
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
	ReceiveGuests bit NULL,
	xcoord float NULL,
	ycoord float NULL,
)
-- *************************
SELECT IntField INTO #LanguageCodeTable FROM dbo.SplitString(@LanguageCode)
SELECT IntField INTO #deptHandicappedFacilitiesTable FROM dbo.SplitString(@deptHandicappedFacilities)
SELECT IntField INTO #districtCodesTable FROM dbo.SplitString(@DistrictCodes)
SELECT IntField INTO #serviceCodeTable FROM dbo.SplitString(@serviceCode)
SELECT IntField INTO #receptionDaysTable FROM dbo.SplitString(@ReceptionDays)

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

		WHERE  (@DistrictCodes is NULL
			OR
				dept.districtCode IN (SELECT IntField FROM #districtCodesTable)
			OR
				dept.DeptCode IN (SELECT x_Dept_District.DeptCode FROM #districtCodesTable
									 JOIN  x_Dept_District ON #districtCodesTable.IntField = x_Dept_District.districtCode) 
			)
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
		AND (@ExpProfession is NULL OR EmployeeInClinic_preselected.IsExpert = @ExpProfession ) 
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
				(@ReceptionDays is NULL AND (@OpenNow is NULL OR @OpenNow = 0))
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
				 ( vEmSerRecep.openingHour < @OpenToHour_var AND (vEmSerRecep.closingHour > @OpenFromHour_var) )
			)
		AND ( @OpenAtHour_Str is NULL 
				OR (vEmSerRecep.openingHour <= @OpenAtHour_var AND (vEmSerRecep.closingHour >= @OpenAtHour_var) )
			)
		AND ((@OpenNow is NULL OR @OpenNow = 0)
				OR  ( vEmSerRecep.openingHour <= @OpenAtThisHour_var AND vEmSerRecep.closingHour >= @OpenAtThisHour_var )
			)
		AND (@CoordinateX is NULL OR ( xcoord <> 0 AND ycoord <> 0)) -- redundantly????

		AND (@licenseNumber is NULL OR EmployeeInClinic_preselected.licenseNumber = @LicenseNumber)

		AND (@ReceiveGuests is NULL OR @ReceiveGuests = 0 OR x_Dept_Employee.ReceiveGuests = @ReceiveGuests)

		AND (@NumberOfRecordsToShow is NULL OR (EmployeeInClinic_preselected.xcoord <> 0 and EmployeeInClinic_preselected.ycoord <> 0))

		) as innerSelection
		) as middleSelection
		OPTION (RECOMPILE)
	
		INSERT INTO #tempTableAllRows 
		SELECT 
		#tempTableAllRowsDistance.RowNumber, 
		em_pr.employeeID,
		em_pr.EmployeeName,
		em_pr.lastname,
		em_pr.firstName,
		em_pr.deptName,
		em_pr.deptCode,
		em_pr.DeptEmployeeID,
		em_pr.QueueOrderDescription,
		CASE em_pr.address WHEN '' THEN '' ELSE '<br>' + em_pr.address END as address,		
		CASE em_pr.cityName WHEN '' THEN '' ELSE '<br>' + em_pr.cityName END as cityName,	
		CASE em_pr.phone WHEN '' THEN '' ELSE '<br>' + 'טלפון: ' + em_pr.phone END as phone,		
		CASE em_pr.fax WHEN '' THEN '' ELSE '<br>' + 'פקס: ' + em_pr.fax END as fax,	
		em_pr.HasReception,
		CASE em_pr.ExpProfession WHEN '' THEN '' ELSE '<br>' + em_pr.ExpProfession END as expert,
		em_pr.HasRemarks,
		em_pr.professions_ASC as 'professions',
		em_pr.[services],
		em_pr.positions,	
		em_pr.AgreementType,
		em_pr.AgreementTypeDescription,
		em_pr.EmployeeLanguage,
		replace(em_pr.EmployeeLanguageDescription, ',','<br>') as EmployeeLanguages,	
		#tempTableAllRowsDistance.distance,
		em_pr.hasMapCoordinates,
		em_pr.EmployeeStatus,
		em_pr.EmployeeStatusInDept,
		'orderLastNameLike' = 1,
		em_pr.IsMedicalTeam,
		em_pr.IsVirtualDoctor,
		em_pr.ReceiveGuests,
		em_pr.xcoord,
		em_pr.ycoord
		FROM EmployeeInClinic_preselected as em_pr
		JOIN #tempTableAllRowsDistance 
			ON #tempTableAllRowsDistance.employeeID = em_pr.employeeID
			AND #tempTableAllRowsDistance.deptCode = em_pr.deptCode					
			AND #tempTableAllRowsDistance.DeptEmployeeID = em_pr.DeptEmployeeID		
	END		
-- END search by distance **************************
ELSE
-- regular search **************************
	BEGIN
		INSERT INTO #tempTableAllRows SELECT * FROM
			( 
			SELECT 
		'RowNumber' = row_number() over (order by 
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
											else lastname 																				
											end )									
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
											else lastname 																			
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

		em_pr.employeeID,
		em_pr.EmployeeName,
		em_pr.lastname,
		em_pr.firstName,
		em_pr.deptName,
		em_pr.deptCode,
		em_pr.DeptEmployeeID,
		em_pr.QueueOrderDescription,
		CASE em_pr.address WHEN '' THEN '' ELSE '<br>' + em_pr.address END as address,	
		CASE em_pr.cityName WHEN '' THEN '' ELSE '<br>' + em_pr.cityName END as cityName,		
		CASE em_pr.phone WHEN '' THEN '' ELSE '<br>' + 'טלפון: ' + em_pr.phone END as phone,
		CASE em_pr.fax WHEN '' THEN '' ELSE '<br>' + 'פקס: ' + em_pr.fax END as fax,		
		em_pr.HasReception,
		CASE em_pr.ExpProfession WHEN '' THEN '' ELSE '<br>' + em_pr.ExpProfession END as expert,
		em_pr.HasRemarks,
		CASE WHEN @IsOrderDescending = 0 THEN em_pr.professions_ASC
			ELSE em_pr.professions_DESC END as 'professions',
		em_pr.[services],
		em_pr.positions,	
		em_pr.AgreementType,
		em_pr.AgreementTypeDescription,
		em_pr.EmployeeLanguage,
		replace(em_pr.EmployeeLanguageDescription, ',','<br>') as EmployeeLanguages,
		'distance' = (em_pr.xcoord - @CoordinateX)*(em_pr.xcoord - @CoordinateX) + (em_pr.ycoord - @CoordinateY)*(em_pr.ycoord - @CoordinateY),
		em_pr.hasMapCoordinates,
		em_pr.EmployeeStatus,
		em_pr.EmployeeStatusInDept,
		'orderLastNameLike' =
			CASE WHEN @LastName is NOT null AND em_pr.LastName like @LastName + '%' THEN 0
				 WHEN @LastName is NOT null AND em_pr.LastName like '%' + @LastName + '%' THEN 1 
				 ELSE 0 END,
		em_pr.IsMedicalTeam,
		em_pr.IsVirtualDoctor,
		em_pr.ReceiveGuests,
		em_pr.xcoord,
		em_pr.ycoord

		FROM EmployeeInClinic_preselected as em_pr

		LEFT JOIN x_Dept_Employee ON em_pr.employeeID = x_Dept_Employee.employeeID
			AND em_pr.deptCode = x_Dept_Employee.deptCode
			AND (@userIsRegistered = 1 OR x_Dept_Employee.employeeID is NOT NULL)
		LEFT JOIN dept ON em_pr.deptCode = dept.deptCode
			AND (@userIsRegistered = 1 OR dept.status = 1)

		LEFT JOIN vEmplServReseption as vEmSerRecep	
			ON x_Dept_Employee.deptCode = vEmSerRecep.deptCode
			AND x_Dept_Employee.employeeID = vEmSerRecep.employeeID
			AND CAST(GETDATE() as date) between ISNULL(vEmSerRecep.validFrom,'1900-01-01') and ISNULL(vEmSerRecep.validTo,'2079-01-01')
			
		LEFT JOIN vEmplServAgreemExpert as vEmSerExp
			ON x_Dept_Employee.deptCode = vEmSerExp.deptCode
			AND x_Dept_Employee.employeeID = vEmSerExp.employeeID

		WHERE 
			(@DistrictCodes is NULL
			OR
				dept.districtCode IN (SELECT IntField FROM #districtCodesTable)
			OR
				dept.DeptCode IN (SELECT x_Dept_District.DeptCode FROM #districtCodesTable
									 JOIN  x_Dept_District ON #districtCodesTable.IntField = x_Dept_District.districtCode) 
			)
		AND (@FirstName is NULL OR em_pr.FirstName like @FirstName +'%')
		AND (@LastName is NULL OR em_pr.LastName like @LastName +'%')
		AND (@EmployeeID is NULL OR em_pr.EmployeeID = @EmployeeID )
		AND (@CityName is NULL OR  em_pr.CityName like @CityName +'%')
		AND (@CoordinateX is NOT NULL OR (@CityCode is NULL OR em_pr.cityCode = @CityCode))
		AND (@Active is NULL
			OR
			(
				(@Active = 1 
					AND (em_pr.EmployeeStatusInDept IN (1,2) 
						or 
						(em_pr.EmployeeStatusInDept is null and em_pr.EmployeeStatus IN (1,2))
						)
				)

				OR
				
				(@Active <> 1
				AND (em_pr.EmployeeStatusInDept = @Active 
					or
					(em_pr.EmployeeStatusInDept is null and em_pr.EmployeeStatus = @Active))
			)
			)
			)
		AND (@EmployeeSectorCode is NULL OR em_pr.EmployeeSectorCode = @EmployeeSectorCode)
		AND (@Sex is NULL OR em_pr.sex = @Sex)
		AND (@ExpProfession is NULL OR em_pr.IsExpert = @ExpProfession ) 
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
		AND (@AgreementType is NULL OR em_pr.AgreementType = @AgreementType)

		AND (
				(@isInCommunity is not NULL AND em_pr.IsInCommunity = @IsInCommunity 
						AND (Dept.IsCommunity = @IsInCommunity OR Dept.IsCommunity IS NULL)
				)
			OR (@isInMushlam is not NULL AND em_pr.IsInMushlam = @IsInMushlam 
						AND (Dept.IsMushlam = @IsInMushlam OR Dept.IsMushlam IS NULL)
				)
			OR (@isInHospitals is not NULL AND em_pr.isInHospitals = @isInHospitals 
						AND (Dept.isHospital = @isInHospitals OR Dept.isHospital IS NULL)
				)
			)
		AND (@LanguageCode is NULL 
				OR 
				exists (
				SELECT * FROM dbo.SplitString(em_pr.EmployeeLanguage) as T 
				JOIN #LanguageCodeTable ON #LanguageCodeTable.IntField = T.IntField)
			)

		AND (@deptHandicappedFacilities is NULL 
				OR 
				(SELECT COUNT(T.IntField) FROM dbo.SplitString(em_pr.DeptHandicappedFacilities) as T 
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
				(@ReceptionDays is NULL AND (@OpenNow is NULL OR @OpenNow = 0))
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
				 ( vEmSerRecep.openingHour < @OpenToHour_var AND (vEmSerRecep.closingHour > @OpenFromHour_var) )
			)
		AND ( @OpenAtHour_Str is NULL 
				OR (vEmSerRecep.openingHour <= @OpenAtHour_var AND (vEmSerRecep.closingHour >= @OpenAtHour_var) )
			)
		AND ((@OpenNow is NULL OR @OpenNow = 0)
				OR  ( vEmSerRecep.openingHour <= @OpenAtThisHour_var AND vEmSerRecep.closingHour >= @OpenAtThisHour_var )
			)
		AND (@CoordinateX is NULL OR ( xcoord <> 0 AND ycoord <> 0)) -- redundantly????

		AND (@licenseNumber is NULL OR em_pr.licenseNumber = @LicenseNumber)

		AND (@ReceiveGuests is NULL OR @ReceiveGuests = 0 OR x_Dept_Employee.ReceiveGuests = @ReceiveGuests)

		AND (@NumberOfRecordsToShow is NULL OR (em_pr.xcoord <> 0 and em_pr.ycoord <> 0))

		) as innerSelection
		) as middleSelection
	END	
-- END regular search **************************


SELECT TOP (@PageSise) * INTO #tempTable FROM #tempTableAllRows
WHERE RowNumber > @StartingPosition AND RowNumber <= @StartingPosition + @PageSise
ORDER BY RowNumber

-- Employees --
SELECT *, deptEmployeeID as ID, 0 as ParentCode FROM #tempTable

DROP TABLE #tempTable

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

-- EmployeeServices
SELECT DISTINCT T.* FROM
(
SELECT    xd.deptCode, xd.EmployeeID, 
          dbo.Employee.EmployeeSectorCode,
          S.ServiceDescription,
		  S.ServiceCode,
		  xd.AgreementType,
		  xd.DeptEmployeeID,
		  xd.DeptEmployeeID as ParentCode,
		  xdes.x_Dept_Employee_ServiceID as ID
FROM DeptEmployeeReception AS dER 
INNER JOIN x_Dept_Employee xd ON dER.DeptEmployeeID = xd.DeptEmployeeID
			AND xd.active <> 0
INNER JOIN dbo.Employee ON xd.EmployeeID = dbo.Employee.employeeID
INNER JOIN deptEmployeeReceptionServices dERS ON dER.receptionID = dERS.receptionID
INNER JOIN [Services] S ON dERS.serviceCode = S.ServiceCode
INNER JOIN x_Dept_Employee_Service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
	AND dERS.serviceCode = xdes.serviceCode
WHERE NOT EXISTS (	SELECT * FROM x_Dept_Employee_Service 
				WHERE x_Dept_Employee_Service.serviceCode = 180300
				AND x_Dept_Employee_Service.DeptEmployeeID = xd.DeptEmployeeID	) 
AND dER.validFrom <= GETDATE() AND (dER.validTo is null OR dER.validTo > GETDATE())

UNION

SELECT    xd.deptCode, xd.EmployeeID,
          dbo.Employee.EmployeeSectorCode,
			' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא:<br/>' +
			stuff((SELECT ',' + s2.serviceDescription    
				FROM x_Dept_Employee_Service xdes2
				INNER JOIN [Services] s2 ON xdes2.serviceCode = s2.serviceCode
				INNER JOIN x_Dept_Employee xd2 ON xdes2.DeptEmployeeID = xd2.DeptEmployeeID
				WHERE xd2.employeeID = xd.employeeID
				AND xd2.deptCode = xd.deptCode
				AND xdes2.Status = 1
				AND s2.serviceCode <> 180300 
				order by s2.serviceDescription
			for xml path('')),1,1,'')
			as ServiceDescription,
			180300	as ServiceCode,
		xd.AgreementType,
		xd.DeptEmployeeID,
		xd.DeptEmployeeID as ParentCode,
		xdes.x_Dept_Employee_ServiceID as ID

FROM DeptEmployeeReception AS dER 
INNER JOIN x_Dept_Employee xd ON dER.DeptEmployeeID = xd.DeptEmployeeID
			AND xd.active <> 0
INNER JOIN dbo.Employee ON xd.EmployeeID = dbo.Employee.employeeID
INNER JOIN deptEmployeeReceptionServices dERS ON dER.receptionID = dERS.receptionID
INNER JOIN [Services] S ON dERS.serviceCode = S.ServiceCode
INNER JOIN x_Dept_Employee_Service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
	AND dERS.serviceCode = xdes.serviceCode
WHERE EXISTS (	SELECT * FROM x_Dept_Employee_Service 
				WHERE x_Dept_Employee_Service.serviceCode = 180300
				AND x_Dept_Employee_Service.DeptEmployeeID = xd.DeptEmployeeID	)     
AND dER.validFrom <= GETDATE() AND (dER.validTo is null OR dER.validTo > GETDATE())                 
) T
JOIN #tempTableAllRows ON T.DeptEmployeeID = #tempTableAllRows.DeptEmployeeID



-- EmployeeServicesReception --
SELECT ReceptionDayName, dbo.rfn_GetEmployeeReceptionsWithRemarkStringNoBR(deptCode, EmployeeID, ServiceCode, receptionDay) 
	as ReceptionHours,
	ParentCode,
	ID
FROM
(
	SELECT DISTINCT TOP 100 percent  v.deptCode
		  ,v.receptionDay
		  ,v.ReceptionDayName
		  ,v.ServiceCode
		  ,v.EmployeeID
		  ,xdes.x_Dept_Employee_ServiceID as ParentCode
		  ,0 as ID 
	  FROM [dbo].[vEmployeeReceptionHours_Having180300service] v
	  left join deptEmployeeReception dER on v.receptionID = dER.receptionID
	  left join DeptEmployeeReceptionRemarks DERR on dER.receptionID = DERR.EmployeeReceptionID
	  inner join #tempTableAllRows tbl
		on tbl.deptCode = v.deptCode
		and tbl.EmployeeID = v.EmployeeID
		and tbl.AgreementType = v.AgreementType
	INNER JOIN x_Dept_Employee_Service xdes ON
		tbl.DeptEmployeeID = xdes.DeptEmployeeID AND v.ServiceCode = xdes.serviceCode
	  order by v.[deptCode],v.[receptionDay]
) T

-- EmployeeRemarks
SELECT distinct
	v_DE_ER.DeptEmployeeID as ParentCode,
	0 as ID,		
	dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as RemarkText,
	CASE WHEN (ValidTo is null OR ValidTo > '2050-01-01') THEN ''
		ELSE 'תוקף ' + CONVERT(varchar(12),ValidTo,  103) END as ValidTo
FROM View_DeptEmployee_EmployeeRemarks v_DE_ER
	inner join #tempTableAllRows tbl
	on tbl.deptCode = v_DE_ER.deptCode
	and tbl.EmployeeID = v_DE_ER.EmployeeID
	where GETDATE() between ISNULL(v_DE_ER.validFrom,'1900-01-01') 
					and ISNULL(v_DE_ER.validTo,'2079-01-01')

-- EmployeeServiceRemarks

SELECT
	xdes.x_Dept_Employee_ServiceID as ParentCode,
	0 as ID,
	dbo.rfn_GetFotmatedRemark(desr.RemarkText) as RemarkText,
	CASE WHEN (ValidTo is null OR ValidTo > '2050-01-01') THEN ''
		ELSE 'תוקף ' + CONVERT(varchar(12),ValidTo,  103) END as ValidTo		
FROM DeptEmployeeServiceRemarks desr
INNER JOIN x_dept_employee_service xdes ON desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID AND xdes.Status = 1
inner join x_dept_employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
inner join #tempTableAllRows tbl on tbl.deptCode = xde.deptCode
and tbl.EmployeeID = xde.EmployeeID
where GETDATE() between ISNULL(desr.validFrom,'1900-01-01') 
					and ISNULL(desr.validTo,'2079-01-01')
						

DROP TABLE #tempTableAllRows

GO

GRANT EXEC ON [rpc_getDoctorList_ForPrinting] TO [clalit\webuser]
GO

GRANT EXEC ON [rpc_getDoctorList_ForPrinting] TO [clalit\IntranetDev]
GO