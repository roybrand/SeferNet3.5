IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection')
	BEGIN
		DROP  function  dbo.rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection
	END

GO
-- find and returns areas where Dept Reception Intervals not intersected with Employee Reception Intervals
-- where Dept works and Employee don't works
Create function [dbo].[rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection]
 (
	@deptCode int,
	@deptEmployeeId int,
	@day int,
	@span varchar(5),
	@direction int,	-- @direction = 1  where Dept works without Employee 
					-- @direction = -1  where Employee works without  Dept
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
	declare @employeeIntervals type_TimeIntervals
	
	
	insert into @deptIntervals
	select openingHour, CASE closingHour when '24:00' then '23:59' else closingHour end, 0
	--select openingHour, closingHour, 0
	
	from DeptReception  
	where DeptReception.deptCode = @deptCode
	and DeptReception.receptionDay = @day
	and @currentDate >= DeptReception.validFrom
	AND (validTo is null OR validTo > @currentDate) 
	order by DeptReception.openingHour

	insert into @employeeIntervals
	select openingHour, CASE closingHour when '24:00' then '23:59' else closingHour end, 0
	--select openingHour, closingHour, 0
	
	from deptEmployeeReception  
	where deptEmployeeReception.DeptEmployeeId = @deptEmployeeId
	and deptEmployeeReception.receptionDay = @day
	and @currentDate >= deptEmployeeReception.validFrom
	AND (validTo is null OR validTo > @currentDate) 
	order by deptEmployeeReception.openingHour
	
	if(@direction = 1)
	insert into @ResultTable select * from rfn_TimeIntervalsNonIntersectedPart(@employeeIntervals, @deptIntervals,  @Span )  
	else --(@direction = -1)
	insert into @ResultTable select * from rfn_TimeIntervalsNonIntersectedPart(@deptIntervals, @employeeIntervals,  @Span )  
	
	return 
end
GO

