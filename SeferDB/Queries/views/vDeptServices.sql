IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDeptServices]'))
DROP VIEW [dbo].[vDeptServices]
GO

CREATE VIEW [dbo].[vDeptServices]
AS
SELECT  Dept.DeptCode, x_Dept_Employee_Service.serviceCode,
 [Services].serviceDescription, [Services].IsService, x_Dept_Employee_Service.Status as ServiceStatus
FROM    Dept 
INNER JOIN x_Dept_Employee ON Dept.deptCode = x_Dept_Employee.deptCode
INNER JOIN x_Dept_Employee_Service ON x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID 
INNER JOIN [Services] ON x_Dept_Employee_Service.serviceCode = [Services].serviceCode
INNER JOIN Employee on x_Dept_Employee.employeeID = Employee.employeeID
where Employee.IsMedicalTeam = 1
and x_Dept_Employee.active = 1
GO
