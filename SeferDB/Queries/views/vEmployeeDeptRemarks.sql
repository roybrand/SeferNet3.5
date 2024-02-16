 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vEmployeeDeptRemarks')
	BEGIN
		DROP  view  vEmployeeDeptRemarks
	END

GO


CREATE VIEW [dbo].[vEmployeeDeptRemarks]
AS
SELECT     dbo.EmployeeRemarks.EmployeeRemarkID, dbo.EmployeeRemarks.EmployeeID, dbo.EmployeeRemarks.DicRemarkID, 
					  dbo.EmployeeRemarks.RemarkText, dbo.EmployeeRemarks.displayInInternet, 
					  dbo.EmployeeRemarks.AttributedToAllClinicsInCommunity as AttributedToAllClinics, 
					  dbo.EmployeeRemarks.ValidFrom, dbo.EmployeeRemarks.ValidTo, dbo.x_Dept_Employee.deptCode, dbo.Employee.EmployeeSectorCode
FROM        dbo.EmployeeRemarks 
			INNER JOIN dbo.Employee ON dbo.EmployeeRemarks.EmployeeID = dbo.Employee.employeeID 
			INNER JOIN dbo.x_Dept_Employee ON dbo.EmployeeRemarks.EmployeeID = dbo.x_Dept_Employee.employeeID 
			LEFT JOIN dbo.x_Dept_Employee_EmployeeRemarks xder ON dbo.EmployeeRemarks.EmployeeRemarkID = xder.EmployeeRemarkID 				
WHERE					   
	(dbo.EmployeeRemarks.ValidFrom IS NULL 	OR	dbo.EmployeeRemarks.ValidFrom <= GETDATE()) 
	AND (dbo.EmployeeRemarks.ValidTo IS NULL OR 	dbo.EmployeeRemarks.ValidTo >= GETDATE())
	AND (EmployeeRemarks.AttributedToAllClinicsInCommunity = 1 OR xder.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID)

GO
  
grant select on vEmployeeDeptRemarks to public 

go