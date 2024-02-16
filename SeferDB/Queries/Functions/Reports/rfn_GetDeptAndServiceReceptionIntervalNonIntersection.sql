IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptAndServiceReceptionIntervalNonIntersection')
	BEGIN
		DROP  function  dbo.rfn_GetDeptAndServiceReceptionIntervalNonIntersection
							
	END

GO
-- find and returns areas where Dept Reception Intervals not intersected with SubDept Reception Intervals
create function dbo.rfn_GetDeptAndServiceReceptionIntervalNonIntersection
 (
	@deptCode int,
	@day int,
	@span varchar(5)
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
	declare @serviceIntervals type_TimeIntervals
	
	
	insert into @deptIntervals
	select openingHour, closingHour, 0
	from DeptReception  as dr
	where dr.deptCode = @deptCode
	and dr.receptionDay = @day
	and GETDATE()>= dr.validFrom
	and dr.ReceptionHoursTypeID = 1
	order by dr.openingHour

	insert into @serviceIntervals
	select openingHour, closingHour, 0
	from DeptReception  as dr
	where dr.deptCode = @deptCode
	and dr.receptionDay = @day
	and GETDATE()>= dr.validFrom
	and dr.ReceptionHoursTypeID = 2 -- OfficeservicesHours
	order by dr.openingHour

	
	insert into @ResultTable select * from rfn_TimeIntervalsNonIntersectedPart(@serviceIntervals, @deptIntervals, @Span )  
	return 
end
go
