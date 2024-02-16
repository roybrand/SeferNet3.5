create function dbo.rfn_ingBCIsBC(@IsCommunity bit, 
						 @IsMushlam bit, 
						 @IsHospital bit, 
						 @RecID bigint) 
returns tinyint
as 
begin 

	declare @IsBC tinyint 
	
	set @IsBC = 0 
	
	if @IsCommunity = 1 set @IsBC = 1 
	
	return @IsBC 
	
end 

go 

grant exec on dbo.rfn_ingBCIsBC to public 
go  