 IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptEmployeeQueueOrderDescriptionsHTML')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeQueueOrderDescriptionsHTML
	END

GO

CREATE  function [dbo].rfn_GetDeptEmployeeQueueOrderDescriptionsHTML(@deptCode int, @employeeID bigint) 
RETURNS varchar(500)

WITH EXECUTE AS CALLER

AS
BEGIN

	declare @Str varchar(500) 
	set @Str = ''
	
	SELECT @Str = @Str + CASE @Str WHEN '' THEN '' ELSE ' | ' END +
		CASE QueueOrderMethod 
			WHEN 3 THEN '<span dir="ltr">*2700</span>' 
			WHEN 4 THEN '@' 
			WHEN 5 THEN '<span style=' + CHAR(39)+ 'font-family:"Webdings"; font-size:16px' + CHAR(39) + '>' + CHAR(72) + '</span>' 
			ELSE '<span style=' + CHAR(39)+ 'font-family:"Wingdings 2"; font-size:16px' + CHAR(39) + '>' + CHAR(39) + '</span>' 
		END  
	FROM
		-- Using "distinct" because methods "1" & "2" both require "phone picture", but only one picture is needed
		(select DISTINCT CASE WHEN DIC_QOM.QueueOrderMethod <= 2 THEN 1 ELSE DIC_QOM.QueueOrderMethod END as 'QueueOrderMethod'
		FROM x_Dept_Employee as xDE
		join EmployeeQueueOrderMethod as eqom
			ON xDE.DeptEmployeeID = eqom.DeptEmployeeID				
		join DIC_QueueOrderMethod as DIC_QOM
			on EQOM.QueueOrderMethod = DIC_QOM.QueueOrderMethod
		WHERE xDE.deptCode = @deptCode
		and xDE.employeeID = @employeeID
		and xDE.QueueOrder = 3 -- "זימון באמצעות:"
		) 
		as d 
	order by d.QueueOrderMethod

	SELECT @Str = @Str + QueueOrderDescription
	FROM x_Dept_Employee as xDE
	JOIN DIC_QueueOrder ON xDE.QueueOrder = DIC_QueueOrder.QueueOrder
		AND DIC_QueueOrder.PermitOrderMethods = 0
		AND xDE.deptCode = @deptCode
		AND xDE.employeeID = @employeeID

	
	IF (@Str = '')
	BEGIN
		SET @Str = '&nbsp;'
	END
	return (@Str)
end 

go 

grant exec on dbo.rfn_GetDeptEmployeeQueueOrderDescriptionsHTML to public 
go