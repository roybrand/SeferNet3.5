IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeClinicTeam')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeClinicTeam
	END
GO

CREATE Procedure dbo.rpc_GetEmployeeClinicTeam
(
	@DeptCode int
)

AS

SELECT 
TOP 1 Employee.*, x_Dept_Employee.DeptEmployeeID
FROM Employee
LEFT JOIN x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID
WHERE IsMedicalTeam = 1
AND (@DeptCode = 0 OR @DeptCode = x_Dept_Employee.deptCode)
GO

GRANT EXEC ON rpc_GetEmployeeClinicTeam TO PUBLIC

GO