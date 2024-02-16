IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptServiceStatus')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptServiceStatus
	END

GO

CREATE Procedure dbo.rpc_DeleteDeptServiceStatus
(
	@deptCode INT,
	@serviceCode INT,
	@employeeID bigint
	
)

AS


DELETE DeptEmployeeServiceStatus
WHERE x_dept_employee_serviceID in
(
	select DESS.x_dept_employee_serviceID from DeptEmployeeServiceStatus DESS
	join x_Dept_Employee_Service xDES on DESS.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
	join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
	where xDE.deptCode = @deptCode
	and xDES.serviceCode = @serviceCode
	and xDE.employeeID = @employeeID
)

GO


GRANT EXEC ON rpc_DeleteDeptServiceStatus TO PUBLIC

GO


