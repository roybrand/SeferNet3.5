IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServiceQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_getEmployeeServiceQueueOrderMethods
	END
GO

CREATE PROCEDURE [dbo].[rpc_getEmployeeServiceQueueOrderMethods]

	@x_Dept_Employee_ServiceID int

AS

	SELECT xDES.QueueOrder, ESQOM.QueueOrderMethod, 
	'DeptPhone' = dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension),
	queuePhones.prePrefix, DIC.prefixCode, DIC.prefixValue as PrefixText, queuePhones.phone, queuePhones.extension
	FROM x_Dept_Employee_Service xdes
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID 		
	INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
	LEFT JOIN DeptPhones ON deptPhones.DeptCode = xd.deptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
	LEFT JOIN EmployeeServiceQueueOrderPhones queuePhones ON ESQOM.EmployeeServiceQueueOrderMethodID = queuePhones.EmployeeServiceQueueOrderMethodID
	LEFT JOIN DIC_PhonePrefix DIC ON queuePhones.prefix = DIC.prefixCode
	WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID

	SELECT EmployeeServiceQueueOrderHoursID as QueueOrderHoursID,
	ReceptionDay, FromHour as OpeningHour, ToHour as ClosingHour,
	'NumOfSessionsPerDay' = (
		SELECT COUNT(*)
		FROM EmployeeServiceQueueOrderMethod ESQOM2
		INNER JOIN EmployeeServiceQueueOrderHours ESQOH2 ON ESQOM2.EmployeeServiceQueueOrderMethodID = ESQOH2.EmployeeServiceQueueOrderMethodID
		AND ESQOH.ReceptionDay = ESQOH2.ReceptionDay
		GROUP BY ReceptionDay
		)
	FROM EmployeeServiceQueueOrderMethod ESQOM
	INNER JOIN EmployeeServiceQueueOrderHours ESQOH ON ESQOM.EmployeeServiceQueueOrderMethodID = ESQOH.EmployeeServiceQueueOrderMethodID
	
	INNER JOIN x_Dept_Employee_Service xDES ON ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID		
	WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
GO

GRANT EXEC ON rpc_getEmployeeServiceQueueOrderMethods TO PUBLIC
GO
