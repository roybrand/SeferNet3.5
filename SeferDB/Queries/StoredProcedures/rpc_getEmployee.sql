IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployee')
	BEGIN
		DROP  Procedure  rpc_getEmployee
	END

GO

CREATE Procedure dbo.rpc_getEmployee
	(
		@EmployeeID BIGINT
	)

AS

SELECT
Employee.employeeID,
Employee.degreeCode,
DIC_EmployeeDegree.DegreeName,
Employee.firstName,
Employee.lastName,
Employee.firstName_MF,
Employee.lastName_MF,
Employee.EmployeeSectorCode,
EmployeeSector.EmployeeSectorDescription,
EmployeeSector.RelevantForProfession,
EmployeeSector.IsDoctor,
Employee.sex,
'expert' = dbo.fun_GetEmployeeExpert(@EmployeeID),
DIC_Gender.sexDescription,
'licenseNumber' = CASE CAST(Employee.licenseNumber as varchar(10)) WHEN '0' THEN '' ELSE CAST(Employee.licenseNumber as varchar(10)) END,
'licenseIsDental' = CASE CAST(Employee.IsDental as varchar(1)) WHEN '0'THEN '' ELSE ' (שיניים) ' END,
Employee.primaryDistrict,
Employee.email,
'showEmailInInternet' = CAST (Employee.showEmailInInternet as bit),

'prePrefix_Home' = homePhone.prePrefix,
'prefixCode_Home' = homePhone.prefix,
'prefixText_Home' = dic.prefixValue,
'phone_Home' = homePhone.phone,
'extension_Home' = homePhone.extension,
'isUnlisted_Home' = CAST( isNull(homePhone.isUnlisted, 0) as bit),

'prePrefix_Cell' = cellPhone.prePrefix,
'prefixCode_Cell' = cellPhone.prefix,
'prefixText_Cell' = dic2.prefixValue,
'phone_Cell' = cellPhone.phone,
'extension_Cell' = cellPhone.extension,
'isUnlisted_Cell' = CAST( isNull(cellPhone.isUnlisted, 0) as bit),

Employee.active,
Employee.statusOpenDate,
Employee.statusCloseDate

FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
LEFT JOIN DIC_Gender ON Employee.sex = DIC_Gender.sex

LEFT JOIN EmployeePhones as homePhone ON Employee.employeeID = homePhone.employeeID
	AND homePhone.phoneType = 1 AND homePhone.phoneOrder = 1
LEFT JOIN DIC_PhonePrefix dic ON homePhone.prefix = dic.prefixCode
LEFT JOIN EmployeePhones as cellPhone ON Employee.employeeID = cellPhone.employeeID
	AND cellPhone.phoneType = 3 AND cellPhone.phoneOrder = 1
LEFT JOIN DIC_PhonePrefix dic2 ON cellPhone.prefix = dic2.prefixCode
	
WHERE Employee.employeeID = @EmployeeID

GO

GRANT EXEC ON rpc_getEmployee TO PUBLIC

GO

