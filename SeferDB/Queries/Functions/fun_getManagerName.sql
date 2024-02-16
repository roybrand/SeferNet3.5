SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter FUNCTION [dbo].[fun_getManagerName] 
(
	@deptCode int
)
RETURNS varchar(500)

AS
BEGIN
	DECLARE  @strManagerName varchar(500)
	SET @strManagerName = ''
	
	 set @strManagerName = (SELECT  TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID 								
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToManager = 1
							AND x_dept_employee.deptCode = @deptCode)
		
	
							
	if(@strManagerName = '' or @strManagerName is null )						
	begin
		 select @strManagerName = Dept.managerName from Dept where Dept.deptCode = @deptCode			
	end 
	
	RETURN( @strManagerName )

	
	
END
 
 