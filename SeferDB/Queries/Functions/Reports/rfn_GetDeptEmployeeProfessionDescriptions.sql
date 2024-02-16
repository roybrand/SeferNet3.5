IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptEmployeeProfessionDescriptions')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeProfessionDescriptions
	END

GO

--case @deptCode = -1  -- means all depts
--case @employeeID = -1  -- means all employees
CREATE FUNCTION [dbo].rfn_GetDeptEmployeeProfessionDescriptions(@deptCode bigint, @employeeID bigint) 
RETURNS varchar(500)
AS
BEGIN

	declare @ProfessionsStr varchar(500) 
	set @ProfessionsStr = ''
	
	SELECT @ProfessionsStr = @ProfessionsStr + d.ServiceDescription + '; ' 
	FROM
		(select distinct [Services].ServiceDescription, [Services].ServiceCode
		from x_Dept_Employee_Service as xDES
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN [Services] on xDES.ServiceCode = [Services].ServiceCode
		WHERE (@deptCode = -1 or xd.deptCode = @deptCode)
		AND (@employeeID = -1 or xd.employeeID = @employeeID)
		AND [Services].IsProfession = 1
		) 
		as d 
	order by d.ServiceDescription
	
	IF(LEN(@ProfessionsStr)) > 0 -- to remove last ','
		BEGIN
			SET @ProfessionsStr = Left( @ProfessionsStr, LEN(@ProfessionsStr) -1 )
		END
		
	return (@ProfessionsStr);

end 

go 

grant exec on dbo.rfn_GetDeptEmployeeProfessionDescriptions to public 
go