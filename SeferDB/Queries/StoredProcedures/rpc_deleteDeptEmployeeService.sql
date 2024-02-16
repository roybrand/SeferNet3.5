IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptEmployeeService')
	BEGIN
		DROP  Procedure  rpc_deleteDeptEmployeeService
	END

GO

CREATE Procedure dbo.rpc_deleteDeptEmployeeService
	(
		@deptEmployeeID int,
		@ServiceCode int
	)

AS 

DECLARE @deptEmployeeServiceID INT
SET @deptEmployeeServiceID = (
						SELECT  x_dept_employee_serviceID
						FROM x_Dept_employee_service
						WHERE DeptEmployeeID = @deptEmployeeID			
						AND ServiceCode = @serviceCode			
					   )


	DELETE FROM x_Dept_Employee_Service
	WHERE x_dept_employee_serviceID = @deptEmployeeServiceID
	

	
	DELETE DeptEmployeeServiceRemarks
	WHERE x_dept_employee_serviceID = @deptEmployeeServiceID

IF(SELECT COUNT(*) FROM x_Dept_Employee_Service WHERE DeptEmployeeID = @deptEmployeeID) = 0
	BEGIN 
		DELETE FROM EmployeeQueueOrderMethod
		WHERE DeptEmployeeID = @deptEmployeeID

		UPDATE x_Dept_Employee
		SET QueueOrder = null
		WHERE DeptEmployeeID = @deptEmployeeID
	END

GO

GRANT EXEC ON dbo.rpc_deleteDeptEmployeeService TO PUBLIC

GO

