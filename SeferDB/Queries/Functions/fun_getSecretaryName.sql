IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_getSecretaryName')
	BEGIN
		DROP  Function  fun_getSecretaryName
	END
GO

CREATE FUNCTION [dbo].[fun_getSecretaryName]
(
	@DeptCode int
)

RETURNS varchar(100)

AS
BEGIN
	DECLARE  @strSecretaryName varchar(100)
	SET @strSecretaryName = ''
	
	set @strSecretaryName = (SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee xd ON employee.EmployeeID = xd.EmployeeID
							INNER JOIN x_Dept_Employee_Position ON xd.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID
							AND x_Dept_Employee_Position.positionCode = 86
							AND xd.deptCode = @deptCode		
)			
							
	if(@strSecretaryName is null )						
	begin
		 SET @strSecretaryName = ''		
	end 
	
	RETURN( @strSecretaryName )		
END
GO

GRANT EXEC ON fun_getSecretaryName TO [clalit\webuser]
GO
GRANT EXEC ON fun_getSecretaryName TO [clalit\IntranetDev]
GO