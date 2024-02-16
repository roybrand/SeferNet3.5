IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vManagers]'))
DROP VIEW [dbo].[vManagers]
GO

create VIEW [dbo].[vManagers]
AS
SELECT 
DegreeName + ' ' + lastName + ' ' + firstName as managerName,
Dept.deptCode,
Dept.status
FROM Dept 
LEFT JOIN x_dept_employee xde ON Dept.deptCode = xde.deptCode			
LEFT JOIN employee ON xde.employeeID = employee.employeeID
LEFT JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN x_Dept_Employee_Position ON xde.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID							
JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
			AND  mappingPositions.mappedToManager = 1            

GO


grant select on vManagers to public 
GO