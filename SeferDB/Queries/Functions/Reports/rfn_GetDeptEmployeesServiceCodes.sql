set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetDeptEmployeesServiceCodes')
	BEGIN
		DROP  function  rfn_GetDeptEmployeesServiceCodes
	END

GO

create FUNCTION [dbo].rfn_GetDeptEmployeesServiceCodes(@deptCode bigint, @employeeID bigint)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strServices varchar(500)
	SET @strServices = ''
	
	SELECT @strServices = @strServices + convert(varchar(50), s.serviceCode) + '; '
	from
		(select distinct Services.serviceDescription, Services.serviceCode
		FROM x_Dept_Employee_Service AS xDES
		join x_Dept_Employee xde
		on xDES.DeptEmployeeID = xde.DeptEmployeeID
		inner join Services 
			ON xDES.serviceCode = Services.serviceCode
			and (@deptCode = -1 or xde.deptCode = @deptCode)
			and (@employeeID = -1 or xde.employeeID = @employeeID)
			and status = 1
			and Services.IsService = 1
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

grant exec on dbo.rfn_GetDeptEmployeesServiceCodes to public 
go  