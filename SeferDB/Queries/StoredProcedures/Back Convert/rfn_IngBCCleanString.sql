ALTER FUNCTION [dbo].[rfn_CleanString](@StringToClean varchar(1000))  
RETURNS varchar(1000) 
AS
BEGIN
	-- Declare the return variable here
	DECLARE @retVal varchar(1000) 

	set @retVal  = @StringToClean

	-- Add the T-SQL statements to compute the return value here
	set @retVal = replace(@retVal, '#', '') 
	set @retVal = replace(@retVal, '&x0D;', '') 
	set @retVal = replace(@retVal, '&amp;quot;', '') 
	set @retVal = replace(@retVal, '&amp;', '') 
	set @retVal = replace(@retVal, 'quot;', '') 
	

	
	RETURN @retVal

END
go 

grant exec on rfn_IngBCCleanString to public 
go  