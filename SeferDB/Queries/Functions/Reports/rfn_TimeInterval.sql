IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_TimeInterval')
	BEGIN
		DROP  function  dbo.rfn_TimeInterval
	END

GO

Create function [dbo].[rfn_TimeInterval](@openingHour_str varchar(5), @closingHour_str varchar(5))
  
RETURNS int
	
WITH EXECUTE AS CALLER
AS

BEGIN
	declare @interval_str as varchar(5)
	declare  @minutes as int
    declare  @interval as time(0)
    declare  @openingHour as time(0)
    declare  @closingHour as time(0)
    
	if ((@closingHour_str = '00:00' or @closingHour_str = '23:59' or @closingHour_str = '01:00' ) 
		and(@openingHour_str = '00:01' or @openingHour_str = '01:00' or @openingHour_str = '00:00'))
		begin
			set @minutes = 24*60 
		end
	else
		begin
			if(isdate(@openingHour_str) = 1)
				set @openingHour = cast(@openingHour_str as time(0))
			else
				set  @openingHour = cast('00:00' as time(0))
			
			if(isdate(@closingHour_str) = 1)
				set @closingHour = cast(@closingHour_str as time(0))
			else
				set  @closingHour = cast('00:00' as time(0))
			
			set @minutes =	DATEDIFF(minute, @openingHour, @closingHour) 
			
			if(@minutes < 0)
			begin
				set @minutes = @minutes + 24*60;
			end
			
		end
	return	(@minutes)	 
END

	


	 




