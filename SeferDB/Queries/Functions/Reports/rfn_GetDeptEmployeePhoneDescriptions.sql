IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeePhoneDescriptions')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeePhoneDescriptions
	END

GO

create function [dbo].rfn_GetDeptEmployeePhoneDescriptions(@DeptCode int, @employeeID bigint) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN
	declare @Str varchar(500) 
	set @Str = ''
	
	SELECT @Str = @Str + phone + ' ; ' 
	FROM
		(select distinct phone = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
			  DEP.phoneType, DEP.phoneOrder
		from DeptEmployeePhones as dep
		INNER JOIN x_dept_employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.deptCode = @DeptCode 
		AND xd.employeeID = @employeeID
		)
		as d 
	order by d.phoneType, d.phoneOrder
	
	IF(LEN(@Str)) > 0 -- to remove last ';'
		BEGIN
			SET @Str = Left( @Str, LEN(@Str) -1 )
		END
	
	return (@Str);
end 

go 
grant exec on rfn_GetDeptEmployeePhoneDescriptions to public 
go
