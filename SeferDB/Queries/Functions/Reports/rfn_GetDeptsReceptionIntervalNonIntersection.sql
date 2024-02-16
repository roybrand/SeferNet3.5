IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptsReceptionIntervalNonIntersection')
	BEGIN
		DROP  function  dbo.rfn_GetDeptsReceptionIntervalNonIntersection
	END

GO
-- find and returns areas where Dept Reception Intervals not intersected with SubDept Reception Intervals
create function dbo.rfn_GetDeptsReceptionIntervalNonIntersection
 (
	@deptCode int,
	@subDeptCode int,
	@day int,
	@span varchar(5),
	@currentDate datetime
 ) 
RETURNS 
@ResultTable table
(
	intervalsStr varchar(200),		
	intervalsValues_str varchar(200),
	intervalsSum_minu decimal(10,2)	
)
as

begin

	declare @deptIntervals type_TimeIntervals
	declare @subDeptIntervals type_TimeIntervals
	
	
	insert into @deptIntervals
	select openingHour, closingHour, 0
	from DeptReception  
	where DeptReception.deptCode = @deptCode
	and DeptReception.receptionDay = @day
	and @currentDate >= DeptReception.validFrom
	order by DeptReception.openingHour

	insert into @subDeptIntervals
	select openingHour, closingHour, 0
	from DeptReception  
	where DeptReception.deptCode = @subDeptCode
	and DeptReception.receptionDay = @day
	and @currentDate >= DeptReception.validFrom
	order by DeptReception.openingHour
	
	
	insert into @ResultTable select * from rfn_TimeIntervalsNonIntersectedPart(@subDeptIntervals, @deptIntervals,  @Span )  
	return 
end
GO

