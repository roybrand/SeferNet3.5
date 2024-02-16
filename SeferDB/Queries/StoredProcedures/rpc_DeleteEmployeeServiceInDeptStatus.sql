IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeServiceInDeptStatus')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeServiceInDeptStatus
	END

GO

CREATE Procedure dbo.rpc_DeleteEmployeeServiceInDeptStatus
(	
	@employeeID BIGINT,
	@deptCode INT,
	@serviceCode INT
)

AS

DELETE DeptEmployeeServiceStatus 
FROM DeptEmployeeServiceStatus dess
INNER JOIN x_dept_employee_service xdes ON dess.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.EmployeeID = @employeeID
AND xd.DeptCode = @deptCode
AND xdes.ServiceCode = @serviceCode


GO


GRANT EXEC ON rpc_DeleteEmployeeServiceInDeptStatus TO PUBLIC

GO


