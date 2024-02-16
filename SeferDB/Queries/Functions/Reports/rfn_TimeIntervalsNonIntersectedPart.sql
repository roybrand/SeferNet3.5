IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_TimeIntervalsNonIntersectedPart')
	BEGIN
		DROP  function  dbo.rfn_TimeIntervalsNonIntersectedPart
	END
GO
-- find and returns areas of @BIntervals not intersected with @AIntervals
create function dbo.rfn_TimeIntervalsNonIntersectedPart
 (
	@AIntervals type_TimeIntervals readonly,
	@BIntervals type_TimeIntervals readonly,
	@Span varchar(5)
 ) 
RETURNS 
@ResultTable table
(
	intervalsStr varchar(200),		
	intervalsValues_str varchar(200),
	intervalsSum_minu decimal(10,2)--varchar(20)	
)
as

begin
	
	declare @BIntervals_ed type_TimeIntervals
	
	insert into @BIntervals_ed (openingHour, closingHour, intervalValue)
	select openingHour, closingHour, intervalValue from @BIntervals
	
	
	declare @deptIntCount int 
	declare @i int = 1
	declare @j int = 1
	declare @a_Begin  time(0)
	declare @a_End  time(0)
	declare @b_Begin time(0)
	declare @b_End  time(0)

	-------------------------------------------------------------------

	set @deptIntCount = (select max(d.id) from @AIntervals as d)
	--select @deptIntCount as '@deptIntCount'
	--select * from @AIntervals

	--select * from @BIntervals_ed


		--------- @i <= last row id --------
		while @i <= @deptIntCount
		begin 
			set @j = (select min(d.id) from @BIntervals_ed as d)
			
			--print 'while begin @i = ' + cast(@i as varchar(4))
			 
			set @a_Begin = ( select top 1 d.openingHour from @AIntervals d where d.id = @i)
			set @a_End = ( select top 1 d.closingHour from @AIntervals d where d.id = @i)
			
			--print 'i = ' + cast(@i as varchar(4)) +'    @a_Begin = ' + cast(@a_Begin as varchar(5)) + '      @a_End = ' + cast(@a_End as varchar(5))
			
			--------- @j <= last row id --------
			--while @j <= (select max(d.id) from @BIntervals_ed as d)
			while ((select COUNT(*) from @BIntervals_ed as d where d.id = @j) > 0)
			begin ------------
				
				--print 'while begin @j = ' + cast(@j as varchar(4))
				--select COUNT(*) as containceRowJ from @BIntervals_ed as d where d.id = @j
				
				--set @b_Begin  = ( select top 1 d.openingHour from @BIntervals_ed d where d.id = @j)
				--set @b_End = ( select top 1 d.closingHour from @BIntervals_ed d where d.id = @j)
				
				SELECT TOP 1 @b_Begin = d.openingHour, @b_End = d.closingHour 
				FROM @BIntervals_ed d where d.id = @j
				
				--print 'j = ' + cast(@j as varchar(4))  +'      @b_Begin = ' + cast(@b_Begin as varchar(5)) + ';      @b_End = ' + cast(@b_End as varchar(5))
				
				--- if intervals intersects -------
				if(		@b_Begin < @a_End 
					and @b_End > @a_Begin)
					begin ------------
						---- get nonIntersected area
						if(@b_Begin < @a_Begin)
							begin
								-- add new interval into @BIntervals_ed
								INSERT @BIntervals_ed (openingHour, closingHour) VALUES (@b_Begin, @a_Begin)
								
								--print 'insert row into @BIntervals_ed :  ' + cast(@b_Begin as varchar(5)) +':  '+ cast(@a_Begin as varchar(5))
								--select * from @BIntervals_ed 
							end
						if(@b_End > @a_End)
							begin
								-- add new interval into @BIntervals_ed
								INSERT @BIntervals_ed (openingHour,closingHour ) VALUES (@a_End, @b_End)
								
								--print 'insert row into @BIntervals_ed :  ' + cast(@a_End as varchar(5)) +':  '+ cast(@b_End as varchar(5))
								--select * from @BIntervals_ed 
							end
							
						---- remove row[j] from @BIntervals_ed
						delete from @BIntervals_ed where id = @j
						--print 'delete row from @BIntervals_ed id = ' + cast(@j as varchar(4))
						--select * from @BIntervals_ed 
					end -------------- if

				
				set @j = @j +1
				--print 'while end @j = @j +1 = ' + cast(@j as varchar(4))
				--select * from @BIntervals_ed 
				
			end ------- while @j --

			set @i = @i +1
			--print ' while end @i = @i +1 = ' + cast(@i as varchar(4))
			
		end ------ while @i
		
		-------------------------------------------------
		DECLARE @Span_minu int
		if (@Span is null or @Span = '-1' or ISDATE(@Span)= 0)
			set @Span_minu = 0 
		else
			set @Span_minu = datediff(minute,'00:00', @Span)
		
		declare @resultRowCount int 
		set @resultRowCount  = 
		(select  COUNT(*)
		FROM @BIntervals_ed as t
		where datediff(minute, t.openingHour, t.closingHour )>= @Span_minu)
		
		if( @resultRowCount >0)
		begin
				
					
				declare @intervalsStr varchar(200) 
				declare @intervalsSum_minu	int 
				declare @intervalsValues_str varchar(200)
				set @intervalsStr	= ''	
				set @intervalsSum_minu	=0
				set @intervalsValues_str  = ''
				
				update @BIntervals_ed
				set intervalValue =  datediff(minute, openingHour, closingHour)
				
				---test
				--select * from @BIntervals_ed 
				--select @intervalsStr as '@intervalsStr', @intervalsValues_str as '@intervalsValues_str', @intervalsSum_minu as '@intervalsSum_minu'
			
				SELECT 
				@intervalsStr			= @intervalsStr + cast(t.openingHour as varchar(5))  + '-' + cast(t.closingHour as varchar(5)) + '; ' ,
				@intervalsValues_str	= @intervalsValues_str + cast(cast(DATEADD(minute, intervalValue, '00:00') as time(0))as varchar(5))  + '; ' ,
				@intervalsSum_minu		= @intervalsSum_minu +  intervalValue
				FROM @BIntervals_ed as t
				where datediff(minute, t.openingHour, t.closingHour )>= @Span_minu
				order by  t.openingHour
				
				-- test
				--select @intervalsStr as '@intervalsStr', @intervalsValues_str as '@intervalsValues_str', @intervalsSum_minu as '@intervalsSum_minu'
				
				insert into @ResultTable (intervalsStr, intervalsValues_str, intervalsSum_minu)
				values 
				(@intervalsStr,
				 @intervalsValues_str,
				 cast( cast(@intervalsSum_minu as decimal(10,2))/60 as  decimal(10,2))
				 --cast(cast(DATEADD(minute, @intervalsSum_minu, '00:00') as time(0))as varchar(5))  
				 
				 )
		end

return
end

GO

