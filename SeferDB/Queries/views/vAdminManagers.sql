IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vAdminManagers]'))
DROP VIEW [dbo].[vAdminManagers]
GO

CREATE VIEW [dbo].[vAdminManagers]
AS
SELECT 
DegreeName + ' ' + lastName + ' ' + firstName as adminManagerName,
Dept.deptCode
FROM Dept 
LEFT JOIN x_dept_employee xde ON Dept.deptCode = xde.deptCode			
LEFT JOIN employee ON xde.employeeID = employee.employeeID
LEFT JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN x_Dept_Employee_Position ON xde.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID							
JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
			AND  mappingPositions.mappedToAdministrativeManager = 1            

GO

grant select on vAdminManagers to public 
GO
