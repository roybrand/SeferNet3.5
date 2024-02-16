go
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptEmployeeQueueOrderDescriptions')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeQueueOrderDescriptions
	END

GO

--case @deptCode = -1  -- means all depts
--case @employeeID = -1  -- means all employees
create  function [dbo].rfn_GetDeptEmployeeQueueOrderDescriptions(@deptCode bigint, @employeeID bigint) 
RETURNS varchar(500)

WITH EXECUTE AS CALLER

AS
BEGIN 

	declare @Str varchar(500) 
	set @Str = ''
	
	SELECT @Str = @Str + d.QueueOrderMethodDescription + '; ' 
	FROM
		(select distinct DIC_QOM.QueueOrderMethodDescription, DIC_QOM.QueueOrderMethod
		FROM x_Dept_Employee as xDE
		join EmployeeQueueOrderMethod  as eqom
			ON xDE.deptEmployeeID = eqom.DeptEmployeeID						
		join DIC_QueueOrderMethod as DIC_QOM
			on EQOM.QueueOrderMethod = DIC_QOM.QueueOrderMethod
		WHERE (@deptCode = -1 or xDE.deptCode = @deptCode)
		  and (@employeeID = -1 or xDE.employeeID = @employeeID)
		  and (xDE.QueueOrder = 3)-- "זימון באמצעות:"
		) 
		as d 
	order by d.QueueOrderMethod
	
	IF(LEN(@Str)) > 0 -- to remove last ','
		BEGIN
			SET @Str = Left( @Str, LEN(@Str) -1 )
		END
		
	return (@Str);
end 

go 

grant exec on dbo.rfn_GetDeptEmployeeQueueOrderDescriptions to public 
go