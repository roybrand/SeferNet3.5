IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_getEmployeeQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_getEmployeeQueueOrderMethods
(
	@deptEmployeeID int
)

AS


SELECT xd.QueueOrder,
eqom.QueueOrderMethod,
'DeptPhone' = dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension),
queuePhones.prePrefix , dic.prefixCode, dic.prefixValue as PrefixText, queuePhones.phone, queuePhones.extension	

 
FROM x_dept_Employee xd
LEFT JOIN EmployeeQueueOrderMethod eqom ON xd.DeptEmployeeID  = eqom.DeptEmployeeID 
LEFT JOIN DeptPhones ON deptPhones.DeptCode = xd.deptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
LEFT JOIN DeptEmployeeQueueOrderPhones queuePhones ON eqom.QueueOrderMethodID = queuePhones.QueueOrderMethodID
LEFT JOIN DIC_PhonePrefix dic ON queuePhones.Prefix = dic.prefixCode

WHERE xd.DeptEmployeeID = @deptEmployeeID



SELECT EmployeeQueueOrderHoursID AS QueueOrderHoursID, receptionDay, FromHour as OpeningHour, ToHour as ClosingHour, 
'NumOfSessionsPerDay' = (
			SELECT count(*)
			FROM EmployeeQueueOrderMethod eqom2
			INNER JOIN EmployeeQueueOrderHours hours2 ON eqom2.QueueOrderMethodID = hours2.QueueOrderMethodID 
			AND hours.ReceptionDay = hours2.ReceptionDay
			GROUP BY receptionDay
		)
FROM EmployeeQueueOrderMethod eqom
INNER JOIN EmployeeQueueOrderHours hours ON eqom.QueueOrderMethodID = hours.QueueOrderMethodID
WHERE eqom.DeptEmployeeID = @deptEmployeeID
ORDER BY FromHour,ToHour



GO

GRANT EXEC ON rpc_getEmployeeQueueOrderMethods TO PUBLIC

GO

