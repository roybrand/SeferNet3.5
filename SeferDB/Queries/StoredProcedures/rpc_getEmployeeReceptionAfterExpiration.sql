IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_getEmployeeReceptionAfterExpiration')
	BEGIN
		PRINT 'Dropping Procedure rpc_getEmployeeReceptionAfterExpiration'
		DROP  Procedure  rpc_getEmployeeReceptionAfterExpiration
	END
GO

PRINT 'Creating Procedure rpc_getEmployeeReceptionAfterExpiration'
GO     
CREATE Procedure [dbo].[rpc_getEmployeeReceptionAfterExpiration]
(
	@employeeID int,
	@ExpirationDate dateTime
)

AS

IF (@ExpirationDate is null OR @ExpirationDate <= cast('1/1/1900 12:00:00 AM' as datetime))
	BEGIN
		SET  @ExpirationDate = getdate()
	END	

DECLARE @DateAfterExpiration datetime

SET @DateAfterExpiration = DATEADD(day, 1, @ExpirationDate)

-- "doctorDetails"
SELECT 
Employee.primaryDistrict,
View_AllDistricts.districtName,
EmployeeSectorDescription,
Employee.employeeID,
Employee.badgeID,
'EmployeeName' = DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' + Employee.firstName,
Employee.firstName,
Employee.lastName,
Employee.licenseNumber,
'active' = IsNull(statusDescription, 'לא מוגדר'),
'sex' = isNull(sexDescription, ''),
'languages' = dbo.fun_GetEmployeeLanguages(employeeID),
'professions' = dbo.fun_GetEmployeeProfessions(employeeID),
'expert' = dbo.fun_GetEmployeeExpert(employeeID),
'sevices' = dbo.fun_GetEmployeeServices(employeeID),
'homePhone' = (	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) 
				FROM EmployeePhones
				WHERE employeeID = @employeeID AND phoneType = 1 AND phoneOrder = 1),
'cellPhone' = (	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) 
				FROM EmployeePhones
				WHERE employeeID = @employeeID AND phoneType = 3 AND phoneOrder = 1),
'isUnlisted_Home' = IsNull((SELECT TOP 1 isUnlisted FROM EmployeePhones
				WHERE employeeID = @employeeID AND phoneType = 1 AND phoneOrder = 1), 0),
'isUnlisted_Cell'  = IsNull((SELECT TOP 1 isUnlisted FROM EmployeePhones
				WHERE employeeID = @employeeID AND phoneType = 3 AND phoneOrder = 1), 0),
Employee.email,
'showEmailInInternet' = isNull(Employee.showEmailInInternet, 0)

FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
LEFT JOIN View_AllDistricts ON Employee.primaryDistrict = View_AllDistricts.districtCode
LEFT JOIN DIC_Gender ON Employee.sex = DIC_Gender.sex
LEFT JOIN DIC_ActivityStatus ON Employee.active = DIC_ActivityStatus.status

WHERE employeeID = @employeeID

-------- "doctorReceptionHours" -------------------
SELECT
Dept.deptCode,
Dept.deptName,
deptEmployeeReception.receptionID,
x_Dept_Employee.EmployeeID,
deptEmployeeReception.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
deptEmployeeReception.openingHour,
deptEmployeeReception.closingHour,
'receptionRemarks' = dbo.fun_GetEmployeeRemarksForReception(deptEmployeeReception.receptionID),
'professions' = dbo.fun_GetProfessionsForEmployeeReception(deptEmployeeReception.receptionID),
'services' = dbo.fun_GetServicesForEmployeeReception(deptEmployeeReception.receptionID),
'willExpireIn' = DATEDIFF(day, getdate(), IsNull(validTo,'01/01/2050')),
'expirationDate' = validTo

FROM deptEmployeeReception
INNER JOIN DIC_ReceptionDays ON deptEmployeeReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode
INNER JOIN x_Dept_Employee ON deptEmployeeReception.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
INNER JOIN dept ON x_Dept_Employee.deptCode = dept.deptCode
WHERE x_Dept_Employee.employeeID = @employeeID
AND (
		(   
			((validFrom IS not NULL and  validTo IS NULL) and (@DateAfterExpiration >= validFrom ))			
			or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @DateAfterExpiration)
			or ((validFrom IS not NULL and  validTo IS not NULL) and (@DateAfterExpiration >= validFrom and validTo >= @DateAfterExpiration))
		)
		OR (validFrom IS NULL AND validTo IS NULL)
	)
AND disableBecauseOfOverlapping <> 1		
ORDER BY receptionDay, openingHour, Dept.deptCode

GO


GRANT EXEC ON rpc_getEmployeeReceptionAfterExpiration TO PUBLIC
 GO

