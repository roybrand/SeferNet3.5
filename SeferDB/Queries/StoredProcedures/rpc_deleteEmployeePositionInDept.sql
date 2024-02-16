IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeePositionInDept')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeePositionInDept
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeePositionInDept
	(
		@EmployeeID int,
		@DeptCode int, 
		@PositionCode int = NULL
	)

AS

DELETE x_Dept_Employee_Position 
FROM x_Dept_Employee_Position pos
INNER JOIN x_dept_employee xd ON pos.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.deptCode = @DeptCode
AND xd.employeeID = @EmployeeID
AND IsNull(@PositionCode, PositionCode) = PositionCode

GO

GRANT EXEC ON rpc_deleteEmployeePositionInDept TO PUBLIC

GO

