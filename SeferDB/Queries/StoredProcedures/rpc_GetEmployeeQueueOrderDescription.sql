IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeQueueOrderDescription')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeQueueOrderDescription
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeQueueOrderDescription
(
		@employeeID INT,
		@deptCode INT
)


AS


SELECT 
xe.deptCode,
xe.EmployeeID,
qo.QueueOrder,
qo.QueueOrderDescription,
0 as QueueOrderMethod
 
FROM x_dept_Employee xe
INNER JOIN Dic_QueueOrder qo ON xe.QueueOrder = qo.QueueOrder

WHERE xe.deptcode = @deptCode AND xe.employeeid = @employeeID
AND permitorderMethods = 0 


UNION 

SELECT 
xd.deptCode,
xd.EmployeeID,
qo.QueueOrder,
CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) = '' THEN 
			CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) = '' 
					THEN qom.QueueOrderMethodDescription 
				 ELSE dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) 
			END
	  ELSE dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) END as QueueOrderMethodDescription,
eqom.QueueOrderMethod
 
FROM x_dept_Employee xd
LEFT JOIN EmployeeQueueOrderMethod eqom ON xd.DeptEmployeeID  = eqom.DeptEmployeeID 
LEFT JOIN DeptPhones ON xd.deptCode = deptPhones.DeptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
LEFT JOIN DeptEmployeeQueueOrderPhones queuePhones ON eqom.QueueOrderMethodID = queuePhones.QueueOrderMethodID
INNER JOIN Dic_QueueOrder qo ON xd.QueueOrder = qo.QueueOrder
LEFT JOIN DIC_QueueOrderMethod qom ON eqom.QueueOrderMethod = qom.QueueOrderMethod
WHERE xd.deptcode = @deptCode 
AND xd.employeeid = @employeeID
AND permitOrderMethods = 1 



GO


GRANT EXEC ON rpc_GetEmployeeQueueOrderDescription TO PUBLIC

GO


