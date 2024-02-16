IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeesServiceDescriptions')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeesServiceDescriptions
	END

GO
create FUNCTION [dbo].rfn_GetDeptEmployeesServiceDescriptions(@deptCode bigint, @employeeID bigint)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @NewLineChar AS CHAR(2) 
	set @NewLineChar = CHAR(13) + CHAR(10)
	
	DECLARE @strServices varchar(500)
	SET @strServices = ''
	
--  @strServices look like  not corect ordered in case any serviceDescription containce english literals.
	SELECT @strServices = @strServices + s.serviceDescription +'; '
	from
		(SELECT DISTINCT [Services].serviceDescription, [Services].serviceCode
		FROM x_Dept_Employee_Service AS xdes		
		INNER JOIN [Services] ON xDES.serviceCode = [Services].ServiceCode
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE (@deptCode = -1 or xd.deptCode = @deptCode)
			AND (@employeeID = -1 or xd.employeeID = @employeeID)
			AND status = 1
			AND [Services].IsService = 1
		)
		as s
	order by s.serviceDescription
	
	IF(LEN(@strServices)) > 0 -- to remove last ','
	BEGIN
		SET @strServices = left( @strServices, LEN(@strServices) -1 )
	END
	
	RETURN( @strServices )
END
go 

grant exec on rfn_GetDeptEmployeesServiceDescriptions to public 
go

