IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeServiceQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeServiceQueueOrderMethods
	END
GO

CREATE PROCEDURE dbo.rpc_DeleteEmployeeServiceQueueOrderMethods
	@x_Dept_Employee_ServiceID int
AS

IF EXISTS 	(
				SELECT * 
				FROM x_Dept_Employee_Service
				WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID AND QueueOrder = 3
			)
		
BEGIN
	DELETE EmployeeServiceQueueOrderMethod
	WHERE EmployeeServiceQueueOrderMethodID IN 
								(SELECT EmployeeServiceQueueOrderMethodID
								 FROM EmployeeServiceQueueOrderMethod esqom
								 INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID								 									
								 WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID)
	
	
	UPDATE x_Dept_Employee_Service
	SET QueueOrder = -1
	WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
END
GO

GRANT EXEC ON rpc_DeleteEmployeeServiceQueueOrderMethods TO PUBLIC
GO