IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[fun_getGeriatricsManagerName]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fun_getGeriatricsManagerName]
GO

CREATE FUNCTION [dbo].[fun_getGeriatricsManagerName]
(
	@DeptCode int
)

RETURNS varchar(100)

AS
BEGIN
	DECLARE  @strGeriatricsManagerName varchar(100)
	SET @strGeriatricsManagerName = ''
	
	set @strGeriatricsManagerName = (SELECT  TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee xd ON employee.EmployeeID = xd.EmployeeID
							INNER JOIN x_Dept_Employee_Position ON xd.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID
							AND x_Dept_Employee_Position.positionCode = 17
							AND xd.deptCode = @deptCode		
)			
							
	if(@strGeriatricsManagerName is null )						
	begin
		 SET @strGeriatricsManagerName = ''		
	end 
	
	RETURN( @strGeriatricsManagerName )		
END
 