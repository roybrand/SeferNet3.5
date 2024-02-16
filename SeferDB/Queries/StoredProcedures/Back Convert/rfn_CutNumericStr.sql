alter function dbo.rfn_CutNumericStr(@NumStr varchar(50)) 
returns int 
as
begin 
DECLARE @Pos int
DECLARE @done tinyint
declare @Num as varchar(50) 

set @Num = '' 
set @Pos = 1 
set @done = 0 
set @NumStr = ltrim(rtrim(@NumStr)) 

		WHILE (@Pos <= len(@NumStr)  and @done = 0 )
		BEGIN
			if isNumeric(substring(@NumStr, 1, @Pos)) = 1 
			begin 
				Set @Pos =  @Pos + 1 
			end 
			else
			begin 
				Set @done = 1 
			end 
		end 
		
		set @Num = left(@NumStr,@Pos-1) 
		--return @Pos
		return cast(@Num as int) 

end  