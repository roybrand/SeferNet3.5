IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptReceptionsString')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptReceptionsString
	END

GO
create function dbo.rfn_GetDeptReceptionsString(@DeptCode int, @day int, @ReceptionHoursType int) 
RETURNS varchar(200)
WITH EXECUTE AS CALLER

AS
BEGIN

	declare @IntervalsStr varchar(200) 
	set @IntervalsStr = ''
	
	SELECT 
	@intervalsStr = @intervalsStr + cast(t.openingHour as varchar(5))  + '-' + cast(t.closingHour as varchar(5)) + '; ' 
	
	FROM
	(	select openingHour, closingHour
		from DeptReception  
		where DeptReception.deptCode = @deptCode
		and DeptReception.receptionDay = @day
		and GETDATE()>= DeptReception.validFrom
		and DeptReception.ReceptionHoursTypeID = @ReceptionHoursType
	) as t 
	order by t.openingHour
	
	return (@IntervalsStr);
	
end 


go 
grant exec on rfn_GetDeptReceptionsString to public 
go
