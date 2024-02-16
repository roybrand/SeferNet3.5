IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_getDeputyHeadOfDepartment')
	BEGIN
		DROP Function fun_getDeputyHeadOfDepartment
	END
GO

CREATE FUNCTION [dbo].[fun_getDeputyHeadOfDepartment]
(
	@DeptCode int
)

RETURNS varchar(100)

AS
BEGIN
	DECLARE  @strDeputyHeadOfDepartment varchar(100)
	SET @strDeputyHeadOfDepartment = ''
	
	set @strDeputyHeadOfDepartment = (SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee xd ON employee.EmployeeID = xd.EmployeeID
							INNER JOIN x_Dept_Employee_Position ON xd.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID
							AND x_Dept_Employee_Position.positionCode = 85
							AND xd.deptCode = @deptCode		
)			
							
	if(@strDeputyHeadOfDepartment is null )						
	begin
		 SET @strDeputyHeadOfDepartment = ''		
	end 
	
	RETURN( @strDeputyHeadOfDepartment )		
END 
GO

GRANT EXEC ON fun_getDeputyHeadOfDepartment TO [clalit\webuser]
GO
GRANT EXEC ON fun_getDeputyHeadOfDepartment TO [clalit\IntranetDev]
GO