create function [dbo].[rfn_FormatPhoneReverse](
	@PrePreFix tinyint,
	@PreFix int, 
	@Phone int
)
RETURNS varchar(20)
AS
BEGIN

	declare @PhoneStr varchar(20) 

	set @PhoneStr = '' 
--	set @PhoneStr = cast(@PreFix as varchar(2)) +  ' - '  + cast(@Phone as varchar(7)) 
	set @PhoneStr =    + cast(@Phone as varchar(7)) + ' - ' + cast(@PreFix as varchar(2))  
	if @PrePreFix > 0 
	begin 
--		set @PhoneStr = cast(@PrePreFix as varchar(1)) +  ' - '  + @PhoneStr
		set @PhoneStr = @PhoneStr +  ' - '  +  cast(@PrePreFix as varchar(1)) 	
	end 
	return @PhoneStr
	
end
go 
grant exec on rfn_FormatPhoneReverse to public 