IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeProfessionsInDept')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeProfessionsInDept
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeeProfessionsInDept
(
	@employeeID INT,
	@deptCode	INT
)

AS

DELETE x_Dept_Employee_Service 
FROM x_Dept_Employee_Service xdes
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.DeptCode = @deptCode 
AND xd.EmployeeID = @employeeID
AND xdes.serviceCode IN
	(SELECT serviceCode FROM [Services] WHERE IsProfession = 1)



GO


GRANT EXEC ON rpc_deleteEmployeeProfessionsInDept TO PUBLIC

GO


