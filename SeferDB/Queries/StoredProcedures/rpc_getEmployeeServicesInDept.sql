IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServicesInDept')
	BEGIN
		drop procedure rpc_getEmployeeServicesInDept
	END

GO

CREATE Procedure [dbo].[rpc_getEmployeeServicesInDept]
(
	@deptEmployeeID INT	
)

AS

SELECT
'ToggleID' = xdes.serviceCode,
xdes.x_Dept_Employee_ServiceID, 
xd.deptCode,
xd.employeeID,
xdes.serviceCode,
ServiceDescription,
StatusDescription,
'parentCode' = 0,
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),
'phonesForQueueOrder' = [dbo].fun_getEmployeeServiceQueueOrderPhones_All(xd.employeeID, xd.deptCode, xdes.serviceCode),
IsService,
IsProfession

FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN EmployeeServices ON xd.employeeID = EmployeeServices.employeeID AND xdes.serviceCode = EmployeeServices.serviceCode
INNER JOIN DIC_ActivityStatus dic ON xdes.Status = dic.Status	
INNER JOIN [Services] ON xdes.serviceCode = [Services].ServiceCode
LEFT JOIN DIC_QueueOrder ON xdes.QueueOrder = DIC_QueueOrder.QueueOrder
--QueueOrder
WHERE xdes.DeptEmployeeID = @deptEmployeeID
ORDER BY  IsService, ServiceDescription

SELECT 
ESQOM.EmployeeServiceQueueOrderMethodID,
ESQOM.QueueOrderMethod,
xdes.serviceCode,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired,
xdes.x_Dept_Employee_ServiceID

FROM EmployeeServiceQueueOrderMethod ESQOM
INNER JOIN DIC_QueueOrderMethod ON ESQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN x_Dept_Employee_Service xdes ON ESQOM.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID	
--INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xdes.DeptEmployeeID = @deptEmployeeID
ORDER BY QueueOrderMethod


SELECT 
x_Dept_Employee_ServiceID,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END,
phoneOrder,
'phoneNumber' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
FROM EmployeeServicePhones
WHERE x_Dept_Employee_ServiceID in
	(SELECT x_Dept_Employee_ServiceID 
	FROM x_Dept_Employee_Service xdes	
	WHERE xdes.DeptEmployeeID = @deptEmployeeID)

UNION

SELECT
x_Dept_Employee_ServiceID,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END,
phoneOrder,
'phoneNumber' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN DeptEmployeePhones dep ON dep.DeptEmployeeID = xd.DeptEmployeeID AND dep.phoneType <> 2
WHERE xdes.CascadeUpdateEmployeeServicePhones = 1

UNION

SELECT
x_Dept_Employee_ServiceID,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END,
phoneOrder,
'phoneNumber' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID	
INNER JOIN DeptPhones dp ON xd.deptCode = dp.deptCode AND dp.phoneType <> 2
WHERE xdes.CascadeUpdateEmployeeServicePhones = 1
AND xd.CascadeUpdateDeptEmployeePhonesFromClinic = 1


SELECT
xdes.x_Dept_Employee_ServiceID,
xdes.DeptEmployeeID,
xdes.serviceCode,
EmployeeServiceQueueOrderHoursID,
esqoh.EmployeeServiceQueueOrderMethodID,
esqoh.receptionDay,
ReceptionDayName,
CASE WHEN FromHour = '00:00' AND ToHour = '00:00' THEN '24' ELSE FromHour END as FromHour,
CASE WHEN FromHour = '00:00' AND ToHour = '00:00' THEN 'שעות' ELSE ToHour END as ToHour
FROM EmployeeServiceQueueOrderHours esqoh
INNER JOIN vReceptionDaysForDisplay ON esqoh.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeServiceQueueOrderMethod esqom ON esqoh.EmployeeServiceQueueOrderMethodID = esqom.EmployeeServiceQueueOrderMethodID
INNER JOIN x_Dept_Employee_Service as xdes ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
WHERE xdes.DeptEmployeeID = @deptEmployeeID
ORDER BY vReceptionDaysForDisplay.ReceptionDayCode, FromHour

-- Employee Service Remarks
SELECT
xdes.x_Dept_Employee_ServiceID, 
xd.deptCode,
xd.employeeID,
xdes.serviceCode,
desr.DeptEmployeeServiceRemarkID as RemarkID,
dbo.rfn_GetFotmatedRemark(desr.RemarkText) as RemarkText,
IsService,
IsProfession

FROM x_Dept_Employee_Service as xdes
JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
JOIN EmployeeServices ON xd.employeeID = EmployeeServices.employeeID AND xdes.serviceCode = EmployeeServices.serviceCode
JOIN [Services] ON xdes.serviceCode = [Services].ServiceCode
JOIN DeptEmployeeServiceRemarks desr ON xdes.x_dept_employee_serviceID = desr.x_dept_employee_serviceID
	AND (desr.ValidFrom is null OR DATEDIFF(dd, desr.ValidFrom ,GETDATE()) >= 0 OR DATEDIFF(dd, desr.ActiveFrom ,GETDATE()) >= 0)
	AND (desr.ValidTo is null OR DATEDIFF(dd, desr.ValidTo ,GETDATE()) <= 0)

WHERE xdes.DeptEmployeeID = @deptEmployeeID
ORDER BY  IsService, ServiceDescription

GO


GRANT EXEC ON dbo.rpc_getEmployeeServicesInDept TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getEmployeeServicesInDept TO [clalit\IntranetDev]
GO
