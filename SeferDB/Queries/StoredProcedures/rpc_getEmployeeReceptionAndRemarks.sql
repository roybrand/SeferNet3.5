
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeReceptionAndRemarks')
	BEGIN
		drop procedure rpc_getEmployeeReceptionAndRemarks
	END

GO

CREATE Procedure [dbo].[rpc_getEmployeeReceptionAndRemarks]
(
	@DeptEmployeeID int,
	@ServiceCode varchar(100),
	@ExpirationDate datetime
)
as

IF (@ExpirationDate is null OR @ExpirationDate <= cast('1/1/1900 12:00:00 AM' as datetime))
	BEGIN
		SET  @ExpirationDate = getdate()
	END	

------ Employee remark -------------------------------------------------------------

--using  View_DeptEmployee_EmployeeRemarks includes EmployeeRemarks  per dept 
-- and EmployeeRemarks Attributed ToAll Clinics InCommunity, ..InMushlam, ..InHospitals 
-- according to Dept Membership Type

 SELECT distinct
	dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as remark,
	v_DE_ER.displayInInternet,
	'' as ServiceName
	,GenRem.RemarkCategoryID
from View_DeptEmployee_EmployeeRemarks as v_DE_ER
	JOIN DIC_GeneralRemarks GenRem ON v_DE_ER.DicRemarkID = GenRem.remarkID
	where v_DE_ER.DeptEmployeeID = @DeptEmployeeID
	AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@ExpirationDate) >= 0)
	AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@ExpirationDate) <= 0)

UNION

SELECT
dbo.rfn_GetFotmatedRemark(desr.RemarkText), displayInInternet
,ServiceDescription + ': &nbsp;' as ServiceName 
,GenRem.RemarkCategoryID
FROM view_DeptEmployeeServiceRemarks desr
JOIN DIC_GeneralRemarks GenRem ON desr.RemarkID = GenRem.remarkID
INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode AND xdes.Status = 1
WHERE xd.DeptEmployeeID = @DeptEmployeeID
AND (@ServiceCode = '' OR xdes.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode))) 
AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 ) 

------ Employee name, dept name, profession in dept -------------------------------------------------------------
SELECT 
dept.deptName,
'employeeName' = DegreeName + ' ' + Employee.lastName + ' ' + Employee.firstName,
'professions' = [dbo].[fun_GetEmployeeInDeptProfessions](x_Dept_Employee.employeeID, x_Dept_Employee.deptCode, 1)
FROM Employee
INNER JOIN x_Dept_Employee ON Employee.EmployeeID = x_Dept_Employee.EmployeeID
INNER JOIN dept ON x_Dept_Employee.deptCode = dept.deptCode
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode

WHERE x_Dept_Employee.DeptEmployeeID = @DeptEmployeeID


-- get the closest new reception within 14 days for each profession or service
SELECT MIN(ValidFrom) as ChangeDate , s.serviceCode AS ServiceOrProfessionCode, s.ServiceDescription as professionOrServiceDescription
FROM deptEmployeeReception der
INNER JOIN deptEmployeeReceptionServices  ders on der.receptionID = ders.receptionID
INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] s ON dERS.serviceCode = s.serviceCode
WHERE xd.DeptEmployeeID = @DeptEmployeeID
AND DATEDIFF(dd, ValidFrom, @ExpirationDate) < 0 
AND DATEDIFF(dd, ValidFrom, @ExpirationDate) >= -14
AND (@ServiceCode = '' OR ders.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode))) 
GROUP BY s.serviceCode, s.serviceDescription



--------  "doctorReception" (Doctor's Hours in Clinic) -------------------

SELECT
dER.receptionID,
xd.EmployeeID,
xd.deptCode,
xd.DeptEmployeeID,
IsNull(dERS.serviceCode, 0) as professionOrServiceCode,
IsNull(serviceDescription, 'NoData') as professionOrServiceDescription,
DER.validFrom,
DER.validTo,
'expirationDate' = DER.validTo,
'willExpireIn' = DATEDIFF(day, @ExpirationDate, IsNull(validTo,'01/01/2050')),
dER.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
'openingHour' = 
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END			
		ELSE openingHour END,
'closingHour' =
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		ELSE closingHour END,
'receptionRemarks' = dbo.fun_GetEmployeeRemarksForReception(dER.receptionID),
'serviceCodes' = dbo.fun_GetServiceCodesForEmployeeReception(dER.receptionID),
'receptionDaysInDept'= (SELECT COUNT(*) FROM deptEmployeeReception as der2
						 INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
						 INNER JOIN x_Dept_Employee xd ON der2.DeptEmployeeID = xd.DeptEmployeeID
						 WHERE xd.DeptEmployeeID = @DeptEmployeeID 
						 AND ders2.serviceCode = ders.serviceCode
						),
CASE WHEN (dERS.serviceCode = 2 OR dERS.serviceCode = 40) 
	 THEN der.ReceiveGuests
	 ELSE 0
	 END AS ReceiveGuests
FROM deptEmployeeReception as der
INNER JOIN deptEmployeeReceptionServices as dERS ON der.receptionID = dERS.receptionID
INNER JOIN [Services] ON dERS.serviceCode = [Services].serviceCode
INNER JOIN x_dept_employee_service xdes ON der.DeptEmployeeID = xdes.DeptEmployeeID AND [Services].serviceCode = xdes.serviceCode AND xdes.Status = 1
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN vReceptionDaysForDisplay on dER.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
WHERE xd.DeptEmployeeID = @DeptEmployeeID
AND (@ServiceCode = '' OR xdes.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode))) 
AND (
	(validFrom is null OR DATEDIFF(dd, ValidFrom, @ExpirationDate) >= 0 )
	and 
	(validTo is null OR DATEDIFF(dd, ValidTo, @ExpirationDate) <= 0 ) 
	)

ORDER BY EmployeeID, receptionDay, openingHour

------ DeptEmployeePhones
SELECT
employeeID,
phoneOrder,
xd.DeptEmployeeID,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType,
phoneTypeName,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END

FROM DeptEmployeePhones dep
INNER JOIN x_Dept_Employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN DIC_PhoneTypes ON dep.phoneType = DIC_PhoneTypes.phoneTypeCode
WHERE xd.DeptEmployeeID = @DeptEmployeeID

--------- Remarks for Changes in clinic activity-------------------------
SELECT 
View_DeptRemarks.remarkID
, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText
, validFrom
, validTo
, displayInInternet
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark -- as 'sweeping' 
, ShowOrder
, RemarkCategoryID

FROM View_DeptRemarks
JOIN DIC_GeneralRemarks ON View_DeptRemarks.DicRemarkID = DIC_GeneralRemarks.remarkID
JOIN x_Dept_Employee xde ON View_DeptRemarks.deptCode = xde.deptCode
WHERE DIC_GeneralRemarks.linkedToReceptionHours = 0
--AND DIC_GeneralRemarks.RemarkCategoryID = 4
--and DIC_GeneralRemarks.linkedToServiceInClinic = 0
and xde.DeptEmployeeID = @DeptEmployeeID
AND DATEDIFF(dd, validFrom , @ExpirationDate) >= 0
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0 ) 
ORDER BY IsSharedRemark desc ,ShowOrder asc 


GO


GRANT EXEC ON rpc_getEmployeeReceptionAndRemarks TO PUBLIC
GO
