IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptForEmployee')
	BEGIN
		DROP  Procedure  rpc_getDeptForEmployee
	END

GO

CREATE Procedure rpc_getDeptForEmployee
	(
		@EmployeeID int 
	)


AS

	select 
	x_dept_Employee.DeptCode,
	Dept.DeptName 
	from 
	x_dept_Employee
	inner join Dept on x_dept_Employee.DeptCode = Dept.DeptCode

	where 
	EmployeeID = @EmployeeID


GO


GRANT EXEC ON rpc_getDeptForEmployee TO PUBLIC

GO


