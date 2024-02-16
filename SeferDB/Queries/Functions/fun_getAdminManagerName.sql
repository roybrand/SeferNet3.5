IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_getAdminManagerName')
	BEGIN
		DROP  FUNCTION  fun_getAdminManagerName
	END
GO

CREATE FUNCTION [dbo].[fun_getAdminManagerName] 
(
	@deptCode int
)
RETURNS varchar(500)

AS
	
BEGIN
	DECLARE  @strManagerName varchar(500)
	
	SET @strManagerName = (SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
						FROM employee
						INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
						INNER JOIN x_dept_employee xd ON employee.employeeID = xd.employeeID
						INNER JOIN x_Dept_Employee_Position ON xd.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID							
						INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
						WHERE xd.DeptCode = @deptCode
						AND mappingPositions.mappedToAdministrativeManager = 1)							
							
	
	IF(@strManagerName = '' or @strManagerName is null )						
	BEGIN
		SET @strManagerName = (SELECT administrativeManagerName FROM Dept WHERE deptCode = @deptCode)
	END
							
	RETURN( @strManagerName )		
END

GO
 
 