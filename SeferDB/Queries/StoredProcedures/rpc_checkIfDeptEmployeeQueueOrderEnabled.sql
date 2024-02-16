IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_checkIfDeptEmployeeQueueOrderEnabled')
	BEGIN
		DROP  Procedure  rpc_checkIfDeptEmployeeQueueOrderEnabled
	END

GO

CREATE Procedure dbo.rpc_checkIfDeptEmployeeQueueOrderEnabled
(
	@employeeID BIGINT,
	@deptCode	INT
)

AS

IF NOT EXISTS 
(
	SELECT *  
	FROM x_Dept_Employee_Service xdes
	INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
	WHERE xd.EmployeeID = @employeeID 
	AND xd.DeptCode = @deptCode
)
	SELECT 0
ELSE
	SELECT 1


GO


GRANT EXEC ON rpc_checkIfDeptEmployeeQueueOrderEnabled TO PUBLIC

GO


