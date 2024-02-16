IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeGeneralData')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeGeneralData
	END

GO

create Procedure  [dbo].[rpc_GetEmployeeGeneralData](@EmployeeID  int) 
as 
Select DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' +  Employee.firstName as EmployeeName
, Employee.IsMedicalTeam  
FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
WHERE employeeID = @EmployeeID

GO

GRANT EXEC ON rpc_GetEmployeeGeneralData TO PUBLIC

GO