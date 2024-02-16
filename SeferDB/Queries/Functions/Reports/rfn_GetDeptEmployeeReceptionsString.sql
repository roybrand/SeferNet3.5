IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeeReceptionsString')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeeReceptionsString
	END

GO
create function dbo.rfn_GetDeptEmployeeReceptionsString(@DeptEmployeeId int,  @day int) 
RETURNS varchar(200)
WITH EXECUTE AS CALLER

AS
BEGIN

	declare @IntervalsStr varchar(200) 
	set @IntervalsStr = ''
	
	SELECT 
	@intervalsStr = @intervalsStr + cast(t.openingHour as varchar(5))  + '-' + cast(t.closingHour as varchar(5)) + '; ' 
	
	FROM
	(	
		select openingHour, closingHour
		from deptEmployeeReception  
		where deptEmployeeReception.DeptEmployeeId = @DeptEmployeeId
			and deptEmployeeReception.receptionDay = @day
			and GETDATE()>= deptEmployeeReception.validFrom
			
	) as t 
	order by t.openingHour
	
	return (@IntervalsStr);
	
end 


go 
grant exec on rfn_GetDeptEmployeeReceptionsString to public 
go
