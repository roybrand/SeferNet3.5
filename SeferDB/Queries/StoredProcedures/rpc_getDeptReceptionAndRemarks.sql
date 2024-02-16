IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptReceptionAndRemarks')
	BEGIN
		drop procedure rpc_GetDeptReceptionAndRemarks
	END

GO

CREATE Procedure [dbo].[rpc_GetDeptReceptionAndRemarks]
(
	@DeptCode int,
	@ExpirationDate datetime,
	@ServiceCodes varchar(100),
	@RemarkCategoriesForAbsence varchar(50),
	@RemarkCategoriesForClinicActivity varchar(50)
)
as

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForAbsence
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForAbsence)

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForClinicActivity
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForClinicActivity)

------ dept receptions ------------------------------------- OK!
SELECT 
DeptReception.receptionID,
DeptReception.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
'openingHour' = 
	CASE DeptReception.closingHour 
		WHEN '00:00' THEN	 
			CASE DeptReception.openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE DeptReception.openingHour END
		WHEN '23:59' THEN	
			CASE DeptReception.openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE DeptReception.openingHour END
		ELSE DeptReception.openingHour END,
'closingHour' =
	CASE DeptReception.closingHour 
		WHEN '00:00' THEN	
			CASE DeptReception.openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE DeptReception.closingHour END
		WHEN '23:59' THEN	
			CASE DeptReception.openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE DeptReception.closingHour END
		ELSE DeptReception.closingHour END,

'ReceptionDaysCount' = 
	(select count(receptionDay) 
		FROM DeptReception
		where deptCode = @DeptCode
		and ((
		(validFrom is not null AND @ExpirationDate >= validFrom )
		and (validTo is not null and DATEDIFF(dd, validTo , @ExpirationDate) <= 0) )
		OR (validFrom IS NULL AND validTo IS NULL) )
	),	
'remarks' = dbo.fun_getDeptReceptionRemarksValid(receptionID),
'ExpirationDate' = ValidTo,
'WillExpireIn' = DATEDIFF(dd, GETDATE(), IsNull(ValidTo,'01/01/2050')),
ReceptionHoursTypeID

FROM DeptReception
INNER JOIN vReceptionDaysForDisplay on DeptReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode

WHERE deptCode = @DeptCode
AND (validFrom is null OR @ExpirationDate >= validFrom )
AND (validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0) 
ORDER BY receptionDay, openingHour

--------- Clinic General Remarks ------------------------- OK!
SELECT View_DeptRemarks.remarkID
, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText
, validFrom
, validTo
, displayInInternet
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark -- as 'sweeping' 
,GenRem.RemarkCategoryID
FROM View_DeptRemarks
JOIN DIC_GeneralRemarks GenRem ON View_DeptRemarks.DicRemarkID = GenRem.remarkID
LEFT JOIN #RemarkCategoriesForClinicActivity REMACT ON GenRem.RemarkCategoryID = REMACT.RemarkCategoryID
WHERE deptCode = @deptCode
--AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
AND DATEDIFF(dd, validFrom , @ExpirationDate) >= 0
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0 ) 
ORDER BY REMACT.RemarkCategoryID DESC, IsSharedRemark DESC, validFrom, View_DeptRemarks.updateDate

-- Clinic name & District name
SELECT 
dept.deptName, 
View_AllDistricts.districtName,
cityName,
'address' = dbo.GetAddress(@DeptCode),
'phone' = (
	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
	FROM DeptPhones
	WHERE deptCode = @DeptCode
	AND phoneType = 1
	ORDER BY phoneOrder)
FROM dept
INNER JOIN View_AllDistricts ON dept.districtCode = View_AllDistricts.districtCode
INNER JOIN Cities ON dept.cityCode = Cities.cityCode
WHERE dept.deptCode = @DeptCode



--------- Dept Reception Remarks   -------------------------------------------------
SELECT
ReceptionID,
RemarkText
FROM DeptReceptionRemarks
WHERE ReceptionID IN (SELECT receptionID FROM DeptReception WHERE deptCode = @DeptCode)
AND validFrom <= @ExpirationDate 
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0) 

-- ReceptionDaysUnited for ClinicReception and OfficeServicesReception
-- it's useful to build synchronised GridView for both receptions
SELECT deptEmployeeReception.receptionDay, ReceptionDayName
FROM deptEmployeeReceptionServices
join deptEmployeeReception on deptEmployeeReceptionServices.receptionID = deptEmployeeReception.receptionID
INNER JOIN [Services] ON deptEmployeeReceptionServices.serviceCode = [Services].serviceCode
INNER JOIN vReceptionDaysForDisplay ON deptEmployeeReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
join x_Dept_Employee on deptEmployeeReception.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID


AND x_Dept_Employee.deptCode = @DeptCode
AND (
		(   
			 ((validFrom IS not NULL and  validTo IS NULL) and (@ExpirationDate >= validFrom ))			
		  or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @ExpirationDate)
		  or ((validFrom IS not NULL and  validTo IS not NULL) and (@ExpirationDate >= validFrom and validTo >= @ExpirationDate))
		
	     )
	  OR (validFrom IS NULL AND validTo IS NULL)
	)

UNION

SELECT DeptReception.receptionDay, ReceptionDayName
FROM DeptReception
INNER JOIN vReceptionDaysForDisplay ON DeptReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
WHERE DeptReception.deptCode = @DeptCode
AND (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (@ExpirationDate >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @ExpirationDate)
				or ((validFrom IS not NULL and  validTo IS not NULL) and (@ExpirationDate >= validFrom and validTo >= @ExpirationDate))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)

ORDER BY receptionDay


-- closest dept reception change
SELECT MIN(ValidFrom)
FROM DeptReception
WHERE deptCode = @deptCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14

-- closest office reception change
SELECT MIN(ValidFrom)
FROM DeptReception
WHERE ReceptionHoursTypeID = 2
AND deptCode = @deptCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14

-- ReceptionHoursType
SELECT distinct DIC_ReceptionHoursTypes.ReceptionHoursTypeID,DIC_ReceptionHoursTypes.ReceptionTypeDescription FROM DeptReception
join DIC_ReceptionHoursTypes on DeptReception.ReceptionHoursTypeID = DIC_ReceptionHoursTypes.ReceptionHoursTypeID
where deptCode = @DeptCode

-- DefaultReceptionHoursType
SELECT DefaultReceptionHoursTypeID,DIC_ReceptionHoursTypes.ReceptionTypeDescription from subUnitType
join Dept on subUnitType.UnitTypeCode = Dept.typeUnitCode
and subUnitType.subUnitTypeCode = Dept.subUnitTypeCode
join DIC_ReceptionHoursTypes on subUnitType.DefaultReceptionHoursTypeID = DIC_ReceptionHoursTypes.ReceptionHoursTypeID
where Dept.deptCode = @DeptCode

-- Closest reception change for each ReceptionType
select min(d.validFrom) as nextDateChange, d.ReceptionHoursTypeID 
from DeptReception d
where (d.validFrom between GETDATE() and dateadd(day, 14, GETDATE())
	and deptCode = @DeptCode)
group by d.ReceptionHoursTypeID

------ Employee remarks -------------------------------------------------------------

SELECT distinct
dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as remark
,v_DE_ER.displayInInternet, '' as ServiceName, 0 as ServiceCode
,v_DE_ER.EmployeeID
,Employee.lastName
,Employee.IsMedicalTeam
,DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' +  Employee.firstName as EmployeeName
,GenRem.RemarkCategoryID
,CASE WHEN CATABS.RemarkCategoryID IS null THEN 0 ELSE 1 END as AbsenceRemark
,v_DE_ER.ValidFrom
,v_DE_ER.updateDate 

INTO #Remarks

from View_DeptEmployee_EmployeeRemarks as v_DE_ER
JOIN Employee ON v_DE_ER.EmployeeID = Employee.employeeID
JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
JOIN DIC_GeneralRemarks GenRem ON v_DE_ER.DicRemarkID = GenRem.remarkID
JOIN DIC_RemarkCategory RemCat ON GenRem.RemarkCategoryID = RemCat.RemarkCategoryID
LEFT JOIN #RemarkCategoriesForAbsence CATABS ON GenRem.RemarkCategoryID = CATABS.RemarkCategoryID
WHERE v_DE_ER.DeptCode = @DeptCode

AND Employee.EmployeeSectorCode = 7
AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@ExpirationDate) >= 0)
AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@ExpirationDate) <= 0)	

------ Service remarks -------------------------------------------------------------
UNION

SELECT
dbo.rfn_GetFotmatedRemark(desr.RemarkText) as remark
,displayInInternet, ServiceDescription + ': &nbsp;' as ServiceName, xdes.ServiceCode 
,xd.employeeID
,Employee.lastName
,Employee.IsMedicalTeam
,DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' +  Employee.firstName as EmployeeName
,GenRem.RemarkCategoryID
,CASE WHEN CATABS.RemarkCategoryID IS null THEN 0 ELSE 1 END as AbsenceRemark
,desr.ValidFrom
,desr.updateDate 

FROM view_DeptEmployeeServiceRemarks desr
JOIN DIC_GeneralRemarks GenRem ON desr.RemarkID = GenRem.remarkID
INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID AND xd.active = 1
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode AND xdes.Status = 1
JOIN Employee ON xd.EmployeeID = Employee.employeeID
JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN #RemarkCategoriesForAbsence CATABS ON GenRem.RemarkCategoryID = CATABS.RemarkCategoryID
WHERE xd.DeptCode = @DeptCode

AND (@ServiceCodes is null OR xdes.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCodes))) 
AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 )


SELECT DISTINCT employeeID, AbsenceRemark as HasAbsenceRemark
INTO #Absence
FROM #Remarks
WHERE AbsenceRemark = 1

SELECT *
FROM #Remarks
LEFT JOIN #Absence ON #Remarks.employeeID = #Absence.employeeID
ORDER BY #Absence.HasAbsenceRemark DESC,#Remarks.IsMedicalTeam, #Remarks.lastName, #Remarks.AbsenceRemark DESC
	,#Remarks.ValidFrom, #Remarks.updateDate

GO

GRANT EXEC ON rpc_GetDeptReceptionAndRemarks TO PUBLIC
GO

