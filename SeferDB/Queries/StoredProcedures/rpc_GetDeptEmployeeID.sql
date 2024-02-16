IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptEmployeeID')
	BEGIN
		DROP  Procedure  rpc_GetDeptEmployeeID
	END

GO

CREATE Procedure rpc_GetDeptEmployeeID
	(
		@DeptCode int,
		@EmployeeID bigint
	)

AS

SELECT DeptEmployeeID 
FROM x_Dept_Employee
WHERE DeptCode = @DeptCode
AND employeeID = @EmployeeID

GO

GRANT EXEC ON rpc_GetDeptEmployeeID TO PUBLIC

GO

