IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDoctorList')
	BEGIN
		DROP  Procedure  rpc_GetDoctorList
	END

GO

CREATE Procedure dbo.rpc_GetDoctorList
(

@DoctorName1 VARCHAR(20),
@DoctorName2 VARCHAR(20) = '',
@DoctorName3 VARCHAR(20) = '',
@NameSearchExtended BIT,
@ExactStringSearch BIT,
@CityCode int=null,
@SectionCodeDelimited varchar(100)= null,
@DistrictCode int = null,
@sex int = null,
@deptHandicappedFacilities varchar(50) = null,
@LanguageCode varchar(100)=null,
@ReceptionDays varchar(50)=null,
@OpenFromHour_Str varchar(50)=null,	-- string in format "hh:mm"
@OpenToHour_Str varchar(50)=null,	-- string in format "hh:mm"
@OpenAtHour_Str varchar(50)=null,	-- string in format "hh:mm"
@TypeUnitCode INT
)



--with recompile
AS




DECLARE @HandicappedFacilitiesCount int
SET @HandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@deptHandicappedFacilities)), 0)


DECLARE @OpenAtHour int -- in minutes
DECLARE @OpenFromHour int-- in minutes
DECLARE @OpenToHour int-- in minutes
SET @OpenAtHour =	LEFT( @OpenAtHour_Str, 2)*60 + RIGHT(@OpenAtHour_Str, 2)
SET @OpenFromHour = LEFT( @OpenFromHour_Str, 2)*60 + RIGHT(@OpenFromHour_Str, 2)
SET @OpenToHour =	LEFT( @OpenToHour_Str, 2)*60 + RIGHT(@OpenToHour_Str, 2)

DECLARE @nameStr1   VARCHAR(50)
DECLARE @nameStr1_1 VARCHAR(50)
DECLARE @nameStr2   VARCHAR(50)
DECLARE @nameStr2_1 VARCHAR(50)

SET @nameStr1 = @DoctorName1
SET @nameStr2 = @DoctorName2

IF (@DoctorName3 <> '')
BEGIN
	SET @nameStr2 = @DoctorName3
	SET @nameStr1_1 = rtrim(ltrim(@DoctorName2 + ' ' + @DoctorName3))
	SET @nameStr2_1 = rtrim(ltrim(@DoctorName1 + ' ' + @DoctorName2))
END





SELECT
Employee.employeeID,
DegreeName,
firstName,
LastName,
'expert' = dbo.fun_GetEmployeeExpert(Employee.employeeID),
'positions'	= [dbo].[fun_GetEmployeeInDeptPositions](x_Dept_Employee.employeeID, x_Dept_Employee.deptCode, employee.sex),
'professions' = [dbo].[fun_GetEmployeeInDeptProfessions](x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),
'services' = [dbo].[fun_GetEmployeeInDeptServices] (x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),
cityName,
dept.deptName,
dept.deptCode,
Streets.Name as Street,
Dept.House,
Dept.Floor,
Dept.Flat,
AddressComment,
'phone' = (SELECT dbo.ParsePhoneNumber(prePrefix, prefix, phone) 
			FROM DeptEmployeePhones 
			WHERE deptCode = x_Dept_Employee.deptCode
			AND employeeID = x_Dept_Employee.employeeID
			AND phoneType = 1
			AND phoneOrder = 1),
'fax' = (SELECT dbo.ParsePhoneNumber(prePrefix, prefix, phone) 
			FROM DeptEmployeePhones 
			WHERE deptCode = x_Dept_Employee.deptCode
			AND employeeID = x_Dept_Employee.employeeID
			AND phoneType = 2
			AND phoneOrder = 1),
'QueueOrderMethods' = dbo.fun_GetEmployeeInDeptQueueOrders(Employee.EmployeeId, Dept.DeptCode),
xcoord,
ycoord


INTO #tempDoctorsTable
FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID
INNER JOIN dept ON x_Dept_Employee.deptCode = dept.deptCode
LEFT JOIN Streets ON Dept.Street = Streets.StreetCode AND Dept.CityCode = Streets.CityCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
INNER JOIN Cities ON dept.cityCode = Cities.cityCode

WHERE
(@DistrictCode is null or dept.districtCode = @DistrictCode)
AND (
		 (  ( (Employee.FirstName = @nameStr1 AND Employee.LastName = @nameStr2) OR 
			  (Employee.FirstName = @nameStr2 AND Employee.LastName = @nameStr1 AND @NameSearchExtended = 1 )  
			 ) AND @ExactStringSearch = 1   -- EXACT SEARCH
		 ) 
	 OR
		  (  (  (Employee.FirstName LIKE @nameStr1 + '%' AND Employee.LastName LIKE @nameStr2 + '%') OR 
				(Employee.FirstName LIKE @nameStr2 + '%' AND Employee.LastName LIKE @nameStr1 + '%' AND @NameSearchExtended = 1) 
			 ) AND @ExactStringSearch = 0   -- LIKE SEARCH
		  )
	 OR 
		  ( ( ( (Employee.FirstName LIKE @nameStr1 + '%' OR Employee.LastName LIKE @nameStr1 + '%') AND @ExactStringSearch = 0) OR 
		      (Employee.FirstName = @nameStr1 OR Employee.LastName = @nameStr1) 
		    ) AND @nameStr2 = ''           -- ONE WORD SEARCH
		  )	
	 OR 
		  (  (  (Employee.FirstName LIKE @nameStr1 + '%' AND Employee.LastName LIKE @nameStr1_1 + '%') OR 
				(Employee.FirstName LIKE @nameStr2 + '%' AND Employee.LastName LIKE @nameStr2_1 + '%' AND @NameSearchExtended = 1) 
			 ) AND @ExactStringSearch = 0   -- LIKE SEARCH FOR 3 WORDS
		  ) 	
	 OR 
		  (  (  (Employee.FirstName = @nameStr1 AND Employee.LastName = @nameStr1_1) OR 
				(Employee.FirstName = @nameStr2 AND Employee.LastName = @nameStr2_1 AND @NameSearchExtended = 1) 
			 ) AND @ExactStringSearch = 1   -- EXACT SEARCH FOR 3 WORDS
		  ) 		  		  	  
	 OR 
	      (
			@nameStr1 = '' AND @nameStr2 = ''
		  ) 
	 )

AND (@CityCode is null or Cities.CityCode = @CityCode)
AND (@sex is null OR sex = @sex)
AND TypeUnitCode = IsNull(@TypeUnitCode,TypeUnitCode)
AND (@SectionCodeDelimited is null 
	OR 
	x_Dept_Employee.employeeID IN (SELECT employeeID 
									FROM x_Dept_Employee_Profession 
									WHERE deptCode = x_Dept_Employee.deptCode
									AND employeeID = x_Dept_Employee.employeeID
									AND professionCode IN (SELECT IntField FROM dbo.SplitString(@SectionCodeDelimited))
										  
								   )
	OR 
	x_Dept_Employee.employeeID IN (SELECT employeeID 
									FROM x_Dept_Employee_Service 
									WHERE deptCode = x_Dept_Employee.deptCode
									AND employeeID = x_Dept_Employee.employeeID
									AND ServiceCode IN (SELECT IntField FROM dbo.SplitString(@SectionCodeDelimited))
								  )
	)	
	
AND (@LanguageCode is null 
	OR
		x_Dept_Employee.employeeID IN (SELECT EmployeeID 
										FROM EmployeeLanguages
										WHERE languageCode IN (SELECT IntField FROM dbo.SplitString(@LanguageCode))	
										)									
	)
AND (@deptHandicappedFacilities is null
	OR
	x_Dept_Employee.deptCode IN (SELECT deptCode FROM x_Dept_Employee as New
								WHERE (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
										WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@deptHandicappedFacilities))
										AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )
	)

	
AND (@ReceptionDays is null
	OR

	-- logical OR for "@ReceptionDays"
	x_Dept_Employee.deptCode IN (SELECT DISTINCT deptCode 
								FROM deptEmployeeReception 
								WHERE receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)) 
								)
	)
AND (@OpenAtHour is null
	OR
	x_Dept_Employee.deptCode IN (SELECT deptCode FROM deptEmployeeReception as T
								WHERE T.deptCode = x_Dept_Employee.deptCode
								AND T.EmployeeID = x_Dept_Employee.EmployeeID
								AND	(LEFT( openingHour, 2)*60 + RIGHT(openingHour, 2)) <= @OpenAtHour
								AND (LEFT( closingHour, 2)*60 + RIGHT(closingHour, 2)) >= @OpenAtHour 
								) 
	)

AND (@OpenFromHour is null
	OR
	x_Dept_Employee.deptCode IN (SELECT deptCode FROM deptEmployeeReception as T
								WHERE T.deptCode = x_Dept_Employee.deptCode
								AND T.EmployeeID = x_Dept_Employee.EmployeeID
								AND	(
										( (LEFT( openingHour, 2)*60 + RIGHT(openingHour, 2)) <= @OpenFromHour AND (LEFT( closingHour, 2)*60 + RIGHT(closingHour, 2)) >= @OpenToHour )
										OR
										( (LEFT( openingHour, 2)*60 + RIGHT(openingHour, 2)) < @OpenFromHour AND (LEFT( closingHour, 2)*60 + RIGHT(closingHour, 2)) > @OpenFromHour )
										OR
										( (LEFT( openingHour, 2)*60 + RIGHT(openingHour, 2)) < @OpenToHour AND (LEFT( closingHour, 2)*60 + RIGHT(closingHour, 2)) > @OpenToHour )
										OR
										( (LEFT( openingHour, 2)*60 + RIGHT(openingHour, 2)) >= @OpenFromHour AND (LEFT( closingHour, 2)*60 + RIGHT(closingHour, 2)) <= @OpenToHour )
									)
								AND (@ReceptionDays is null
									OR
										T.receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays))
									)
								)
	)

AND (
	 Dept.ShowUnitInInternet = 1  AND Employee.IsVirtualDoctor <> 1
	 AND Dept.DeptCode NOT IN	(SELECT DISTINCT DeptCode 
								 FROM DeptStatus 
								 WHERE Status = 0 AND DATEDIFF(dd,FromDate, GETDATE()) >= 0 
								 AND (ToDate IS NULL OR DATEDIFF(dd, ToDate, GETDATE()) <= 0 )
								 )
	AND Employee.EmployeeID NOT IN (SELECT DISTINCT EmployeeID
									FROM EmployeeStatus
									WHERE Status = 0 AND DATEDIFF(dd,FromDate, GETDATE()) >= 0 
									AND (ToDate IS NULL OR DATEDIFF(dd, ToDate, GETDATE()) <= 0 )
									)
	AND Employee.EmployeeID NOT IN (SELECT DISTINCT EmployeeID
									FROM EmployeeStatusInDept
									WHERE Status = 0 AND DeptCode = Dept.DeptCode
									AND DATEDIFF(dd,FromDate, GETDATE()) >= 0 AND (ToDate IS NULL OR DATEDIFF(dd, ToDate, GETDATE()) <= 0 )
									)									
								 
	)

ORDER BY DeptName
		



SELECT * FROM #tempDoctorsTable 


SELECT eqom.EmployeeID, eqom.DeptCode, eqoh.*
FROM #tempDoctorsTable 
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempDoctorsTable.EmployeeID = eqom.EmployeeID  AND #tempDoctorsTable.DeptCode = eqom.DeptCode
INNER JOIN EmployeeQueueOrderHours eqoh ON eqom.QueueOrderMethodID = eqoh.QueueOrderMethodID
WHERE #tempDoctorsTable.EmployeeID IS NOT NULL
ORDER BY eqom.EmployeeID, eqom.DeptCode,ReceptionDay


DROP TABLE 	#tempDoctorsTable	




GO


GRANT EXEC ON rpc_GetDoctorList TO PUBLIC

GO


