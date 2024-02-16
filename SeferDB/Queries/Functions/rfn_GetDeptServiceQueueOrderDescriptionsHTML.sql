IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rfn_GetDeptServiceQueueOrderDescriptionsHTML]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rfn_GetDeptServiceQueueOrderDescriptionsHTML]
GO

create  FUNCTION [dbo].[rfn_GetDeptServiceQueueOrderDescriptionsHTML](@deptCode int, @serviceCode int, @employeeID bigint) 
RETURNS varchar(500)

WITH EXECUTE AS CALLER

AS
BEGIN

	declare @Str varchar(500) 
	set @Str = ''
	
	SELECT @Str = @Str + CASE @Str WHEN '' THEN '' ELSE ' | ' END +
		 CASE QueueOrderMethod WHEN 3 THEN '<span dir="ltr">*2700</span>' WHEN 4 THEN '@' ELSE '<span style=' + CHAR(39)+ 'font-family:"Wingdings 2"; font-size:16px' + CHAR(39) + '>' + CHAR(39) + '</span>' END  
	FROM
		-- Using "distinct" because methods "1" & "2" both require "phone picture", but only one picture is needed
		(
		select DISTINCT  CASE  WHEN  DIC_QOM.QueueOrderMethod <= 2 THEN 1 ELSE DIC_QOM.QueueOrderMethod END as 'QueueOrderMethod'
		FROM x_Dept_Employee_Service as xDES
		join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
		join EmployeeServiceQueueOrderMethod ESOM
			on xDES.x_Dept_Employee_ServiceID = ESOM.x_dept_employee_serviceID
		join DIC_QueueOrderMethod DIC_QOM
			on ESOM.QueueOrderMethod = DIC_QOM.QueueOrderMethod
		where xDE.deptCode = @deptCode and xDE.employeeID = @employeeID
			and xDES.serviceCode = @serviceCode
			and xDES.QueueOrder = 3
		) 
		as d 
	order by d.QueueOrderMethod
	
	IF (@Str = '')
	BEGIN
		SELECT @Str = @Str + QueueOrderDescription
		FROM x_Dept_Employee_Service as xDES
		join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
		join DIC_QueueOrder DIC_QO on xDES.QueueOrder = DIC_QO.QueueOrder
		where xDES.QueueOrder <> 3
			and xDES.serviceCode = @serviceCode
			and xDE.deptCode = @deptCode
			and xDE.employeeID = @employeeID
	END
	
	IF (@Str = '')
	BEGIN
	SELECT @Str = @Str + CASE @Str WHEN '' THEN '' ELSE ' | ' END +
		 CASE DIC_QOM.QueueOrderMethod WHEN 3 THEN '<span dir="ltr">*2700</span>' WHEN 4 THEN '@' ELSE '<span style=' + CHAR(39)+ 'font-family:"Wingdings 2"; font-size:16px' + CHAR(39) + '>' + CHAR(39) + '</span>' END  
		FROM x_Dept_Employee xDE 
		join EmployeeQueueOrderMethod EOM
			on xDE.DeptEmployeeID = EOM.DeptEmployeeID
		join DIC_QueueOrderMethod DIC_QOM
			on EOM.QueueOrderMethod = DIC_QOM.QueueOrderMethod
		where xDE.deptCode = @deptCode 
		and xDE.employeeID = @employeeID
		and xDE.QueueOrder = 3		
	END	
	
	IF (@Str = '')
	BEGIN
		SET @Str = '&nbsp;'
	END
	return (@Str)
end 

GO

grant exec on dbo.rfn_GetDeptServiceQueueOrderDescriptionsHTML to public 
go


