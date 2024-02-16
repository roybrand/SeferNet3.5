ALTER Procedure [dbo].[rpc_updateMushlamAgreements]
(
	@sourceDB VARchar(30),
	@sourceTableName VARchar(50),
	@targetDB VARchar(30),
	@targetTableName VARchar(50)
)

AS

-- Check in parameters
IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = @sourceDB) OR
	NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = @targetDB) 
RETURN;

IF object_id(@sourceDB + '.dbo.' + @sourceTableName) is null
	OR object_id(@targetDB + '.dbo.' + @targetTableName) is null
RETURN;

DECLARE @newDeptCode VARCHAR(500)
SET @newDeptCode = '''999'' + Right(''00000''+ CAST(AgreementID as Varchar),6)'

DECLARE @strNOTinMushlam Varchar(5000)
DECLARE @str Varchar(5000)

DECLARE @newDeptName VARCHAR(500)
SET @newDeptName = 'DegreeName + '' '' + Employee.LastName + '' '' + Employee.FirstName + '' - '' + city.Description'

-- Delete from Dept and form x_Dept_Employee *********************************************

SET @strNOTinMushlam = 
'SELECT dept.DeptCode FROM (
	(SELECT DeptCode 
		FROM ' + @targetDB + '.dbo.Dept WHERE DeptCode like ''999%'' AND DeptCode > 999000000) as dept 
		LEFT JOIN (SELECT ' + @newDeptCode + ' as DeptCode FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ') as source
		ON dept.DeptCode = source.DeptCode) WHERE source.DeptCode is NULL '
		
SET @str = ' DELETE FROM ' + @targetDB + '.dbo.x_Dept_Employee WHERE deptCode in 
			(' + @strNOTinMushlam + ')'
			
EXEC (@str)

SET @str = ' DELETE FROM ' + @targetDB + '.dbo.Dept WHERE deptCode in 
			(' + @strNOTinMushlam + ')'

EXEC (@str)


/* INSERTION NEW Depts and their associates */
-- insert to Dept 

SET @str =	' INSERT INTO ' + @targetDB + '.dbo.' + @targetTableName + '
			  (DeptCode, DeptName, DeptType, DistrictCode, DeptLevel, TypeUnitCode, 
			  SubUnitTypeCode, CityCode, StreetName, house, PopulationSectorCode, ShowUnitInInternet, Status, IsCommunity, IsMushlam, 
			  IsHospital,  UpdateDate, UpdateUser )
			  SELECT ' + @newDeptCode + ',' + @newDeptName + ', 3, DistrictCodeLong, 3, 112, 4, city.NewCityCode , Address, HouseNumber, 1, 1, 1, 0, 1, 0, GETDATE(),''Import From Mushlam'' 
			  FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
			  INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code 
			  INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber AND Employee.EmployeeSectorCode = 7 
			  AND IsInMushlam = 1 AND AdvisorType IS NOT NULL 
			  INNER JOIN ' + @targetDB + '.dbo.DIC_EmployeeDegree deg ON Employee.degreeCode = deg.DegreeCode
			  LEFT JOIN  ' + @targetDB + '.dbo.Dept d on d.deptCode = ' + @newDeptCode + ' 
			  WHERE d.deptCode is null'
print 	@str		
			
EXEC (@str)

-- insert to ExternalProcessParameters
SET @str =	'	INSERT INTO ExternalProcessParameters
				(deptCode, MushlamLastUpdateDate)
				SELECT ' + @newDeptCode + ', source.LastUpdate
				FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
				INNER JOIN SeferNet.dbo.Employee ON source.License = Employee.licenseNumber AND Employee.EmployeeSectorCode = 7 
				AND IsInMushlam = 1 AND AdvisorType IS NOT NULL 
				LEFT JOIN SeferNet.dbo.Dept d on d.deptCode = ' + @newDeptCode+ '
				LEFT JOIN ExternalProcessParameters ON d.deptCode = ExternalProcessParameters.deptCode
				WHERE d.deptCode is NOT null
				and ExternalProcessParameters.deptCode is null'
			
print 	@str		
			
EXEC (@str)			
			
-- insert to DeptStatus

SET @str =	' INSERT INTO ' + @targetDB + '.dbo.DeptStatus
			  SELECT ' + @newDeptCode + ',1,GETDATE(),null, ''Import From Mushlam'' ,GETDATE()
			  FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source 
			  INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code 
			  INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber  AND Employee.EmployeeSectorCode = 7
			  AND IsInMushlam = 1 AND AdvisorType IS NOT NULL
			  LEFT JOIN  ' + @targetDB + '.dbo.DeptStatus ds on ds.DeptCode = ' + @newDeptCode + ' 
			  WHERE ds.DeptCode is null'
--print 	@str	
EXEC (@str)

-- insert to X_Dept_Employee

SET @str =	' INSERT INTO ' + @targetDB + '.dbo.x_dept_employee
			( DeptCode, EmployeeId, AgreementType, UpdateDate, UpdateUserName, Active, CascadeUpdateDeptEmployeePhonesFromClinic, QueueOrder, OldRecID, ApptUrl)
			  SELECT ' + @newDeptCode + ',e.EmployeeID, 3, GETDATE(),''Import From Mushlam'', 1, 1 ,3 ,null
			  , CASE WHEN (source.ApptProviderFlag is not null AND source.ApptProviderFlag = 1 AND source.ApptUrl is NOT null) THEN source.ApptUrl ELSE NULL END as ApptUrl
			  FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source 
			  INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code 
			  INNER JOIN ' + @targetDB + '.dbo.Employee as e ON source.License = e.LicenseNumber AND e.EmployeeSectorCode = 7 
				AND IsInMushlam = 1
			  LEFT  JOIN ' + @targetDB + '.dbo.x_dept_employee as xde ON xde.employeeID = e.employeeID' +  
						' and xde.deptCode = ' + @newDeptCode + '
			  WHERE AdvisorType = 5 
			  and NOT exists 
				(SELECT * FROM x_dept_employee WHERE DeptCode = ' + @newDeptCode + ' AND EmployeeID = e.EmployeeID AND AgreementType = 3)

			  UNION 

			  SELECT ' + @newDeptCode + ',e.EmployeeID, 4, GETDATE(),''Import From Mushlam'', 1, 1, 3, null
			   , CASE WHEN (source.ApptProviderFlag is not null AND source.ApptProviderFlag = 1 AND source.ApptUrl is NOT null) THEN source.ApptUrl ELSE NULL END as ApptUrl
			  FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source 
			  INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
			  INNER JOIN ' + @targetDB + '.dbo.Employee as e ON source.License = e.LicenseNumber AND e.EmployeeSectorCode = 7 
			  AND IsInMushlam = 1
			  LEFT  JOIN ' + @targetDB + '.dbo.x_dept_employee as xde ON xde.employeeID = e.employeeID
						 and xde.deptCode = ' + @newDeptCode + '
			  WHERE AdvisorType = 2
			  	and NOT exists 
				(SELECT * FROM x_dept_employee WHERE DeptCode = ' + @newDeptCode + ' AND EmployeeID = e.EmployeeID AND AgreementType = 4)
			  '
	
--print 	@str
EXEC (@str)

-- UPDATE to X_Dept_Employee
SET @str =
	'UPDATE ' + @targetDB + '.dbo.x_dept_employee
	SET x_dept_employee.ApptUrl = source.ApptUrl
	FROM ' + @sourceDB + '.dbo.Mu_DoctorsAgreements as source
	INNER JOIN ' + @targetDB + '.dbo.Employee as e ON source.License = e.LicenseNumber AND e.EmployeeSectorCode = 7 
		AND IsInMushlam = 1
	INNER JOIN ' + @targetDB + '.dbo.x_dept_employee as xde ON xde.employeeID = e.employeeID  
		and xde.deptCode = ' + @newDeptCode + '
		AND xde.AgreementType = 3
	WHERE AdvisorType = 5 
	AND (source.ApptUrl IS NOT NULL AND ApptProviderFlag is NOT NULL AND ApptProviderFlag = 1)
	AND DATEDIFF(d,source.LastUpdate, GETDATE()) <= 2'
EXEC (@str)

SET @str =
	'UPDATE ' + @targetDB + '.dbo.x_dept_employee
	SET x_dept_employee.ApptUrl = source.ApptUrl
	FROM ' + @sourceDB + '.dbo.Mu_DoctorsAgreements as source
	INNER JOIN ' + @targetDB + '.dbo.Employee as e ON source.License = e.LicenseNumber AND e.EmployeeSectorCode = 7 
		AND IsInMushlam = 1
	INNER JOIN ' + @targetDB + '.dbo.x_dept_employee as xde ON xde.employeeID = e.employeeID  
		and xde.deptCode = ' + @newDeptCode + '
		AND xde.AgreementType = 4
	WHERE AdvisorType = 2 
	AND (source.ApptUrl IS NOT NULL AND ApptProviderFlag is NOT NULL AND ApptProviderFlag = 1)
	AND DATEDIFF(d,source.LastUpdate, GETDATE()) <= 2'
EXEC (@str)

-- insert to EmployeeStatusInDept
SET @str =
		'INSERT INTO ' + @targetDB + '.dbo.' + 'EmployeeStatusInDept 
		(Status, FromDate, ToDate, UpdateUser, UpdateDate, DeptEmployeeID)
		SELECT 1, GETDATE(),NULL,''Import From Mushlam'',GETDATE(), xd.DeptEmployeeID
		FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
		INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
		INNER JOIN ' + @targetDB + '.dbo.Employee as e ON source.License = e.LicenseNumber AND e.EmployeeSectorCode = 7
		INNER JOIN ' + @targetDB + '.dbo.x_dept_Employee xd ON e.EmployeeID = xd.EmployeeID AND ' + @newDeptCode + ' = xd.DeptCode
		AND IsInMushlam = 1 AND AdvisorType IS NOT NULL
		LEFT JOIN  ' + @targetDB + '.dbo.EmployeeStatusInDept esd ON esd.DeptEmployeeID = xd.DeptEmployeeID
		WHERE esd.DeptEmployeeID is null'
		
--print 	@str
EXEC (@str)

-- insert to EmployeeQueueOrderMethod
SET @str =	'INSERT INTO ' + @targetDB + '.dbo.EmployeeQueueOrderMethod
			 (QueueOrderMethod, updateDate, updateUser, DeptEmployeeID)
			 SELECT 1, GETDATE(),''Import From Mushlam'', xd.DeptEmployeeID
			 FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
			 INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
			 INNER JOIN ' + @targetDB + '.dbo.Employee as e ON source.License = e.LicenseNumber AND e.EmployeeSectorCode = 7
			 INNER JOIN ' + @targetDB + '.dbo.x_dept_Employee xd ON e.EmployeeID = xd.EmployeeID AND ' + @newDeptCode + ' = xd.DeptCode
				AND IsInMushlam = 1 AND AdvisorType IS NOT NULL
			 LEFT JOIN  ' + @targetDB + '.dbo.EmployeeQueueOrderMethod eqm ON eqm.DeptEmployeeID = xd.DeptEmployeeID
			 WHERE eqm.DeptEmployeeID is null '
--print 	@str

EXEC (@str)

-- insert to x_dept_XY
SET @str =	' INSERT INTO ' + @targetDB + '.dbo.x_dept_XY
			 (deptCode, xcoord, ycoord)
			 SELECT ' + @newDeptCode + ', Xcode, YCode 
			 FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
			 INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
			 INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber AND Employee.EmployeeSectorCode = 7
			 AND IsInMushlam = 1 AND AdvisorType IS NOT NULL 
			 LEFT JOIN SeferNet.dbo.x_dept_XY dx on dx.deptCode = ' + @newDeptCode + '
			 WHERE Xcode IS NOT NULL AND Ycode IS NOT NULL
					AND dx.deptCode is null '
					
--print 	@str
EXEC (@str)

-- insert to DeptNames		
SET @str =	' INSERT INTO ' + @targetDB + '.dbo.DeptNames
			  (deptCode, deptName, fromDate, updateDate, updateUser, ToDate)
			  SELECT ' + @newDeptCode + ',' + @newDeptName + ', GETDATE(), GETDATE(), ''Import from Mushlam'',null
			  FROM ' + @sourceDB + '.dbo.' + @sourceTableName  + ' as source
			  INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber AND Employee.EmployeeSectorCode = 7 
			  AND IsInMushlam = 1 AND AdvisorType IS NOT NULL 
			  INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
			  INNER JOIN ' + @targetDB + '.dbo.DIC_EmployeeDegree deg ON Employee.degreeCode = deg.DegreeCode
			  LEFT JOIN  ' + @targetDB + '.dbo.DeptNames dn ON dn.deptCode = ' + @newDeptCode + '
			  WHERE dn.deptCode is null'
			  
--print 	@str
EXEC (@str)

-- DELETE PHONES to be updated
SET @str =	' DELETE ' + @targetDB + '.dbo.DeptPhones
			  WHERE deptCode in 
			  (SELECT deptCode 
			    FROM ExternalProcessParameters exPP
			    JOIN ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
					ON exPP.deptCode = ' + @newDeptCode + '  
				WHERE exPP.MushlamLastUpdateDate < source.LastUpdate
			  )'
EXEC (@str)

-- insert to DeptPhones
SET @str =	' INSERT INTO ' + @targetDB + '.dbo.DeptPhones 
			 (deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateDate, updateUser)
			 SELECT ' + @newDeptCode + ' , 1, t2.PhoneOrder , t2.PrePrefix, t2.Prefix, 
				CASE IsNumeric(t2.Phone) WHEN 1 then CASE WHEN LEN(t2.phone) > 7 then 0 else t2.phone end  else 0 end ,  
			 null, GETDATE(),''Import from Mushlam'' 
			 FROM ( 
					SELECT ROW_NUMBER() OVER (partition by AgreementID order by AgreementID) as PhoneOrder,
					AgreementID, PrePrefix, Prefix, Phone 
					 FROM (
								 SELECT AgreementID, CASE WHEN LEN(AreaCode1) > 3 THEN LEFT(AreaCode1,1) ELSE NULL END as PrePrefix, 
									dic.prefixCode as Prefix, Telephone1 as Phone
								 FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
								 INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
								 INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber
								 AND Employee.EmployeeSectorCode = 7 AND IsInMushlam = 1 AND AdvisorType IS NOT NULL
								 INNER JOIN ' + @targetDB + '.dbo.dic_PhonePrefix dic ON RIGHT(AreaCode1,3) = dic.prefixValue
								 WHERE Telephone1 IS NOT NULL
										AND LEN(Telephone1) >= 6 
								
								 UNION 
								
								 SELECT AgreementID, CASE WHEN LEN(AreaCode2) > 3 THEN LEFT(AreaCode2,1) ELSE NULL END as PrePrefix,
									 dic.prefixCode as Prefix, Telephone2 as Phone 
								 FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
								 INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
								 INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber 
								 AND Employee.EmployeeSectorCode = 7 AND IsInMushlam = 1 AND AdvisorType IS NOT NULL
								 INNER JOIN ' + @targetDB + '.dbo.dic_PhonePrefix dic ON RIGHT(AreaCode2,3) = dic.prefixValue
								 WHERE Telephone2 IS NOT NULL 
										AND LEN(Telephone2) >= 6 
										
								 UNION

								 SELECT AgreementID, case when LEN(AreaCode1) = 1 and AreaCode1=''*'' then 2 else null end as PrePrefix
									, null as Prefix, Telephone1 as Phone 
								 FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
								 INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
								 INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber
								 AND Employee.EmployeeSectorCode = 7 AND IsInMushlam = 1 AND AdvisorType IS NOT NULL
								 WHERE Telephone1 IS NOT NULL 
								 AND LEN(Telephone1) <= 5
								
								UNION

								 SELECT AgreementID, case when LEN(AreaCode2) = 1 and AreaCode2=''*'' then 2 else null end as PrePrefix
									, null as Prefix, Telephone2 as Phone 
								 FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
								 INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
								 INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber
								 AND Employee.EmployeeSectorCode = 7 AND IsInMushlam = 1 AND AdvisorType IS NOT NULL
								 WHERE Telephone2 IS NOT NULL 
								 AND LEN(Telephone2) <= 5

							) as t1
			 ) as t2
			 LEFT JOIN SeferNet.dbo.DeptPhones dp ON dp.deptCode = ' + @newDeptCode + '
					AND dp.phoneType = 1 AND dp.phoneOrder = t2.PhoneOrder
			 WHERE dp.deptCode is null
			'

--print 	@str
EXEC (@str)

SET @str = ' DELETE ' + @targetDB + '.dbo.DeptPhones WHERE phone = 0'

--print 	@str
EXEC (@str)

-- UPDATE Employee
SET @str = 	' UPDATE ' + @targetDB + '.dbo.Employee  
			 SET PrimaryDistrict = city.DistrictCodeLong  
			 FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
			 INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code 
			 INNER JOIN ' + @targetDB + '.dbo.Employee as e ON source.License = e.LicenseNumber 
				AND e.EmployeeSectorCode = 7 
				AND e.IsInMushlam = 1 
				AND source.AdvisorType IS NOT NULL
				AND e.PrimaryDistrict <> city.DistrictCodeLong
				'
--print 	@str

EXEC (@str) 

-- UPDATE Dept
SET @str =	' UPDATE ' + @targetDB + '.dbo.' + @targetTableName + '
			  SET	DeptName = ' + @newDeptName + ', DistrictCode = DistrictCodeLong,
					CityCode = city.NewCityCode, StreetName = Address, house = HouseNumber, 
					UpdateDate = GETDATE(), UpdateUser = ''Import From Mushlam'' 
			  FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
			  INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code 
			  INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber AND Employee.EmployeeSectorCode = 7 
			  AND IsInMushlam = 1 AND AdvisorType IS NOT NULL 
			  INNER JOIN ' + @targetDB + '.dbo.DIC_EmployeeDegree deg ON Employee.degreeCode = deg.DegreeCode
			  INNER JOIN  ' + @targetDB + '.dbo.Dept d on d.deptCode = ' + @newDeptCode + ' 
			  INNER JOIN ExternalProcessParameters exPP ON d.deptCode = exPP.deptCode
			  LEFT JOIN MainFrame.[dbo].[Mu_Doctors] md ON Employee.employeeID = md.TZ
			  WHERE (exPP.MushlamLastUpdateDate < source.LastUpdate OR exPP.MushlamLastUpdateDate < md.LastUpdate)'
--print 	@str
EXEC (@str) 

-- UPDATE x_dept_XY
SET @str =	'UPDATE ' + @targetDB + '.dbo.x_dept_XY
			 SET xcoord = Xcode, ycoord = YCode, XLongitude = null, YLatitude = null, LocationLink = null
			 FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
			 INNER JOIN ' + @targetDB + '.dbo.MF_Cities200 city ON source.CityCode = city.Code
			 INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber AND Employee.EmployeeSectorCode = 7
			 AND IsInMushlam = 1 AND AdvisorType IS NOT NULL 
			 LEFT JOIN SeferNet.dbo.x_dept_XY dx on dx.deptCode = ' + @newDeptCode + '
			 INNER JOIN ExternalProcessParameters exPP ON dx.deptCode = exPP.deptCode
			 WHERE Xcode IS NOT NULL AND Ycode IS NOT NULL
			 AND exPP.MushlamLastUpdateDate < source.LastUpdate
			'
--print @str
EXEC (@str) 
			
-- UPDATE/INSERT 	ExternalProcessParameters

SET @str = 
'UPDATE ExternalProcessParameters
SET MushlamLastUpdateDate = LastUpdate
FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
INNER JOIN ' + @targetDB + '.dbo.ExternalProcessParameters exPP 
	on ' + @newDeptCode + ' = exPP.deptCode
WHERE exPP.MushlamLastUpdateDate < source.LastUpdate	
'
--print @str
EXEC (@str) 

SET @str = 
'INSERT INTO ExternalProcessParameters
(deptCode, MushlamLastUpdateDate)
SELECT' + @newDeptCode + 'as deptCode, source.LastUpdate
FROM ' + @sourceDB + '.dbo.' + @sourceTableName + ' as source
INNER JOIN ' + @targetDB + '.dbo.Employee ON source.License = Employee.licenseNumber AND Employee.EmployeeSectorCode = 7 
AND IsInMushlam = 1 AND AdvisorType IS NOT NULL 
LEFT JOIN ' + @targetDB + '.dbo.Dept d on d.deptCode = ' + @newDeptCode + '
LEFT JOIN ExternalProcessParameters ON d.deptCode = ExternalProcessParameters.deptCode
WHERE d.deptCode is NOT null
and ExternalProcessParameters.deptCode is null	
'
--print @str
EXEC (@str)

GO

--EXEC rpc_updateMushlamAgreements 'MainFrame', 'Mu_DoctorsAgreements', 'SeferNet', 'Dept' 

ALTER Procedure [dbo].[rpc_getDoctorList_PagedSorted]
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

@isGetEmployeesReceptionHours bit=null

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

DECLARE @DateNow datetime = GETDATE()

DECLARE @ReceptionDayNow tinyint

DECLARE @UseReceptionHours tinyint
	IF(@OpenAtHour_Str is null AND @OpenFromHour_Str is null AND @OpenToHour_Str is null AND @OpenNow <> 1)
		SET @UseReceptionHours = 0
	ELSE
		SET @UseReceptionHours = 1

print '@UseReceptionHours = ' + CAST (@UseReceptionHours as varchar(10))

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
	ReceiveGuests int NULL,
	xcoord float NULL,
	ycoord float NULL,
)
-- *************************
SELECT IntField INTO #LanguageCodeTable FROM dbo.SplitString(@LanguageCode)
SELECT IntField INTO #deptHandicappedFacilitiesTable FROM dbo.SplitString(@deptHandicappedFacilities)
SELECT IntField INTO #districtCodesTable FROM dbo.SplitString(@DistrictCodes)
SELECT IntField INTO #serviceCodeTable FROM dbo.SplitString(@serviceCode)
SELECT IntField INTO #receptionDaysTable FROM dbo.SplitString(@ReceptionDays)

-- Random order temp table --
SELECT DeptEmployeeID as KeyValue, ROW_NUMBER() over (ORDER BY newid()) as OrderValue 
INTO #randomOrderTable 
FROM x_Dept_Employee

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
				 ( vEmSerRecep.openingHour < @OpenToHour_var AND vEmSerRecep.closingHour > @OpenFromHour_var )
			)
		AND ( @OpenAtHour_Str is NULL 
				OR (vEmSerRecep.openingHour <= @OpenAtHour_var AND vEmSerRecep.closingHour >= @OpenAtHour_var )
			)
		AND ((@OpenNow is NULL OR @OpenNow = 0)
				OR  ( vEmSerRecep.openingHour <= @OpenAtThisHour_var AND vEmSerRecep.closingHour >= @OpenAtThisHour_var )
			)
		AND ((@ReceiveGuests is NULL OR @ReceiveGuests = 0 
				OR ((@UseReceptionHours = 0 AND @ReceptionDays is NULL) OR vEmSerRecep.ReceiveGuests = @ReceiveGuests) )
			)				
		AND (@CoordinateX is NULL OR ( xcoord <> 0 AND ycoord <> 0)) -- redundantly????

		AND (@licenseNumber is NULL OR EmployeeInClinic_preselected.licenseNumber = @LicenseNumber)

		AND (@ReceiveGuests is NULL OR @ReceiveGuests = 0 
				OR (@UseReceptionHours = 1 OR @ReceptionDays is NOT NULL OR EmployeeInClinic_preselected.ReceiveGuests = @ReceiveGuests))

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
											else CAST(newid() as varchar(50)) --lastname 																				
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

		WHERE 
			(@DistrictCodes is NULL
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
				 ( vEmSerRecep.openingHour < @OpenToHour_var AND vEmSerRecep.closingHour > @OpenFromHour_var )
			)
		AND ( @OpenAtHour_Str is NULL 
				OR (vEmSerRecep.openingHour <= @OpenAtHour_var AND vEmSerRecep.closingHour >= @OpenAtHour_var )
			)
		AND ((@OpenNow is NULL OR @OpenNow = 0)
				OR  ( vEmSerRecep.openingHour <= @OpenAtThisHour_var AND vEmSerRecep.closingHour >= @OpenAtThisHour_var )
			)
		AND ((@ReceiveGuests is NULL OR @ReceiveGuests = 0 
				OR ((@UseReceptionHours = 0 AND @ReceptionDays is NULL) OR vEmSerRecep.ReceiveGuests = @ReceiveGuests) )
			)				
		AND (@CoordinateX is NULL OR ( xcoord <> 0 AND ycoord <> 0)) -- redundant????

		AND (@licenseNumber is NULL OR EmployeeInClinic_preselected.licenseNumber = @LicenseNumber)

		AND (@ReceiveGuests is NULL OR @ReceiveGuests = 0 
				OR (@UseReceptionHours = 1 OR @ReceptionDays is NOT NULL OR EmployeeInClinic_preselected.ReceiveGuests = @ReceiveGuests))

		AND (@NumberOfRecordsToShow is NULL OR (EmployeeInClinic_preselected.xcoord <> 0 and EmployeeInClinic_preselected.ycoord <> 0))

		) as innerSelection
		) as middleSelection
	END	
-- END regular search **************************


SELECT TOP (@PageSise) * INTO #tempTable FROM #tempTableAllRows
WHERE RowNumber > @StartingPosition AND RowNumber <= @StartingPosition + @PageSise
ORDER BY RowNumber

SELECT * FROM #tempTable

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
WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1 

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
WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 
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
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom
		ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID 
	LEFT JOIN [Services] s ON xdes.serviceCode = s.ServiceCode
	WHERE esqom.QueueOrderMethod is null
	--AND xdes.QueueOrder is null
	
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
	FROM DeptEmployeeServiceRemarks desr
	INNER JOIN x_dept_employee_service xdes ON desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID AND xdes.Status = 1
	inner join x_dept_employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
	inner join #tempTableAllRows tbl on tbl.deptCode = xde.deptCode
	and tbl.EmployeeID = xde.EmployeeID
	where GETDATE() between ISNULL(desr.validFrom,'1900-01-01') 
						and ISNULL(desr.validTo,'2079-01-01')

END

DROP TABLE #tempTableAllRows

GO
