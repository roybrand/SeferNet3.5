IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeeProfessionCodes')
	BEGIN
		DROP  function  rfn_GetDeptEmployeeProfessionCodes
	END

GO
--case @deptCode = -1  -- means all depts
--case @employeeID = -1  -- means all employees
CREATE function [dbo].rfn_GetDeptEmployeeProfessionCodes(@deptCode bigint, @employeeID bigint) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN

	declare @ProfessionsStr varchar(500) 
	set @ProfessionsStr = ''
	
SELECT @ProfessionsStr = @ProfessionsStr + convert(varchar(50), d.ServiceCode) + '; ' 
FROM
	(select distinct Services.ServiceDescription, Services.ServiceCode
	from x_Dept_Employee_Service as xDEP
	inner join x_Dept_Employee as xde
		on xDEP.DeptEmployeeID = xde.DeptEmployeeID
	inner join Services on xDEP.ServiceCode = Services.ServiceCode
		and (@deptCode = -1 or xde.deptCode = @deptCode)
		and (@employeeID = -1 or xde.employeeID = @employeeID)
		and Services.IsProfession = 1
	)
	as d
order by  d.ServiceDescription

IF(LEN(@ProfessionsStr)) > 0 -- to remove last ','
		BEGIN
			SET @ProfessionsStr = Left( @ProfessionsStr, LEN(@ProfessionsStr) -1 )
		END

return (@ProfessionsStr);
end 
go 

grant exec on dbo.rfn_GetDeptEmployeeProfessionCodes to public 
go  
