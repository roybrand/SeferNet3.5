IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeServiceQueueOrderDescription')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeServiceQueueOrderDescription
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeServiceQueueOrderDescription
(
	@x_Dept_Employee_ServiceID int
)


AS


SELECT 
xd.deptCode,
xd.EmployeeID,
xDES.serviceCode,
qo.QueueOrder,
qo.QueueOrderDescription,
0 as QueueOrderMethod
 
FROM x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN Dic_QueueOrder qo ON xDES.QueueOrder = qo.QueueOrder
WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
AND permitorderMethods = 0 


UNION 

SELECT 
xd.deptCode,
xd.EmployeeID,
xDES.serviceCode,
qo.QueueOrder,
CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) = '' THEN 
			CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) = '' 
					THEN qom.QueueOrderMethodDescription 
				 ELSE dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) 
			END
	  ELSE dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) END as QueueOrderMethodDescription,
ESQOM.QueueOrderMethod
 
FROM x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID 	
LEFT JOIN DeptPhones ON deptPhones.DeptCode = xd.deptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
LEFT JOIN EmployeeServiceQueueOrderPhones queuePhones ON ESQOM.EmployeeServiceQueueOrderMethodID = queuePhones.EmployeeServiceQueueOrderMethodID
INNER JOIN Dic_QueueOrder qo ON xDES.QueueOrder = qo.QueueOrder
LEFT JOIN DIC_QueueOrderMethod qom ON ESQOM.QueueOrderMethod = qom.QueueOrderMethod
WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
AND permitOrderMethods = 1 



GO


GRANT EXEC ON rpc_GetEmployeeServiceQueueOrderDescription TO PUBLIC

GO


