IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'GetEmployeeGeneralData')
	BEGIN
		DROP  Procedure  GetEmployeeGeneralData
	END

GO

Create Procedure  dbo.GetEmployeeGeneralData(@EmployeeID  int) 
as 
Select DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' +  Employee.firstName as EmployeeName  
FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
WHERE employeeID = @EmployeeID

GO


GRANT EXEC ON GetEmployeeGeneralData TO PUBLIC

GO


