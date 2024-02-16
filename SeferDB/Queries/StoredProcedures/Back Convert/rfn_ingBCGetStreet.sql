ALTER function [dbo].[rfn_ingBCGetStreet](@StreetCode varchar(10), @CityCode int, @DefaultStreetName varchar(50)) 
returns varchar(50) 
as 
begin  
	declare @StreetName varchar(50)
	set @StreetName = '' 
	if not @StreetCode is null  and len(@StreetCode) = 0 
	begin  
		select @StreetName =  name from streets where streetcode = @StreetCode and CityCode = @CityCode 
	end 
	else
	begin 
		set @StreetName = @DefaultStreetName
	end 
	return @StreetName
end
