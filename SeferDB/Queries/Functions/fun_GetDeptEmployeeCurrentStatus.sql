IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetDeptEmployeeCurrentStatus')
	BEGIN
		DROP  FUNCTION  fun_GetDeptEmployeeCurrentStatus
	END

GO

CREATE FUNCTION [dbo].fun_GetDeptEmployeeCurrentStatus 
(
	@deptCode bigint,
	@employeeID bigint,
	@agreementType tinyint
)
RETURNS tinyint

AS
BEGIN
declare @deptEmplState tinyint
if(@deptCode is null)
		set @deptEmplState=	
		(select Employee.active 
		from Employee 
		where Employee.employeeID = @employeeID)
else
		set @deptEmplState=								
		(select dept.status 
		from dept 
		where dept.deptCode = @deptCode)
		*
		(select Employee.active 
		from Employee 
		where Employee.employeeID = @employeeID)
		*
		(select x_dept_Employee.active 
		from x_dept_Employee 
		where x_dept_Employee.employeeID = @employeeID
			and x_dept_Employee.deptCode = @deptCode
			and x_dept_Employee.AgreementType = @agreementType);
			
if @deptEmplState > 2 
	set @deptEmplState = 2	
	
	return @deptEmplState		 
END

go

grant exec on fun_GetDeptEmployeeCurrentStatus to public 
GO 