IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeProfessionsInDept')
	BEGIN
		DROP  Procedure  rpc_getEmployeeProfessionsInDept
	END
GO

CREATE Procedure dbo.rpc_getEmployeeProfessionsInDept
(
	@deptEmployeeID int
)

AS

SELECT 
xdes.serviceCode as professionCode,
[Services].ServiceDescription as professionDescription,
mainProfession,
'expProfession' = CASE expProfession WHEN 1 THEN '(מומחה)' ELSE '' END
FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN EmployeeServices ON xdes.serviceCode = EmployeeServices.serviceCode AND xd.employeeID = EmployeeServices.EmployeeID
INNER JOIN [Services] ON xdes.serviceCode = [Services].ServiceCode
WHERE xdes.deptEmployeeID = @deptEmployeeID
AND [Services].IsService = 0
ORDER BY professionDescription


GO


GRANT EXEC ON rpc_getEmployeeProfessionsInDept TO PUBLIC

GO

