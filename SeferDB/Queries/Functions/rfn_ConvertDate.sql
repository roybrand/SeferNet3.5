IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_ConvertDate')
	BEGIN
		DROP  function  rfn_ConvertDate
	END
GO

create function [dbo].[rfn_ConvertDate](@StrDate varchar(10)) 
returns smalldatetime 
as  

begin 

declare @d varchar(2) 
declare @m varchar(2) 
declare @y varchar(4)  
declare @Pos int  
declare @LastPos int  
declare @Delemiter char(1) 
declare @CvtDate smalldatetime  


set @Delemiter = '/'  
set @d = '' 
set @m = '' 
set @y = '' 
set @LastPos  = 0 
set @Pos = 0  

set @Pos = CHARINDEX(@Delemiter, @StrDate)
if @Pos > 0 
begin 
	set @d= substring(@StrDate, 1 , @Pos - 1 ) 
	set @LastPos  = @Pos 
end 


set @Pos = CHARINDEX(@Delemiter, @StrDate, @Pos  +  1 )
if @Pos > 0 
begin 
	set @m = substring(@StrDate, @LastPos+1  , @Pos - @LastPos  -1  ) 
	set @LastPos  = @Pos 
end 

set @y = substring(@StrDate, @Pos +1 , len(@StrDate) - @Pos) 



set @CvtDate = cast(@m + @Delemiter + @d + @Delemiter + @y as smalldatetime)  

return @CvtDate 
end 

GO

grant exec on rfn_ConvertDate to public 
GO   