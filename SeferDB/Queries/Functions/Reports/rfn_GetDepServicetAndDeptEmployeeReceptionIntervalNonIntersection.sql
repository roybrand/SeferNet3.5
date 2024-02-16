IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDepServicetAndDeptEmployeeReceptionIntervalNonIntersection')
	BEGIN
		DROP  function  dbo.rfn_GetDepServicetAndDeptEmployeeReceptionIntervalNonIntersection
	END

GO
-- find and returns areas where Dept Reception Intervals not intersected with Employee Reception Intervals
-- where Dept works and Employee don't works
create function dbo.rfn_GetDepServicetAndDeptEmployeeReceptionIntervalNonIntersection
 (
	@deptCode int,
	@DeptEmployeeId int,
	@day int,
	@span varchar(5)
	--,@direction int	-- @direction = 1  where Dept works without Employee 
					-- @direction = -1  where Employee works without  Dept
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
	select openingHour, closingHour, 0
	from DeptReception as dr 
	where dr.deptCode = @deptCode
	and dr.ReceptionHoursTypeID = 2
	and dr.receptionDay = @day
	and GETDATE()>= dr.validFrom
	order by dr.openingHour
	
	insert into @employeeIntervals
	select openingHour, closingHour, 0
	from deptEmployeeReception  
	where deptEmployeeReception.DeptEmployeeID = @DeptEmployeeId
	and deptEmployeeReception.receptionDay = @day
	and GETDATE()>= deptEmployeeReception.validFrom
	order by deptEmployeeReception.openingHour
	
	insert into @ResultTable select * from rfn_TimeIntervalsNonIntersectedPart( @deptIntervals, @employeeIntervals,  @span )  

	return 
end

go
