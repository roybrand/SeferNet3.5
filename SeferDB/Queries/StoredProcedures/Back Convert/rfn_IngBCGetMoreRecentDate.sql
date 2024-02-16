ALTER function [dbo].[rfn_IngBCGetMoreRecentDate](@Date1 datetime, @Date2 datetime) 
returns datetime 
as  

begin  

	declare @ReturnDate datetime 

	set @ReturnDate = @Date1   
	
	if @Date1 is null or datediff(d, @Date1, @Date2) > 0 
	begin 
		set @ReturnDate = @Date2 
	end 
	return @ReturnDate 
end