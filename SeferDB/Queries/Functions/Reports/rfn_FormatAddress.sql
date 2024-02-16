alter function [dbo].[rfn_FormatAddress](
	@street varchar(50),
	@house  varchar(50),
	@flat  varchar(50), 
	@floor  varchar(50), 	
	@CityName  varchar(50))
RETURNS varchar(100)
AS
BEGIN

	declare @Addr varchar(100) 

	set @Addr = '' 
	if @street Is Not null set @Addr = @street  +  ' '  
	if @house Is Not null set @Addr = @Addr +  @house +   ' '  
	if @flat Is Not null set @Addr = @Addr +  @flat  +   ' '  	
	if @floor Is Not null set @Addr = @Addr +  @floor  +   ' ' 
	 	
	--if @entrance Is Not null set @Addr = @Addr +  @entrance +   ' '  	
	--if @CityName Is Not null set @Addr = @Addr +  @CityName +   ' '  	


	return @Addr
	
end 
go 
grant exec on dbo.rfn_FormatAddress to public  