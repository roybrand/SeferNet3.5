
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.rfn_CleanString(@StringToClean varchar(1000))  
RETURNS varchar(1000) 
AS
BEGIN
	-- Declare the return variable here
	DECLARE @retVal varchar(1000) 

	set @retVal  = @StringToClean

	-- Add the T-SQL statements to compute the return value here
	set @retVal = replace(@retVal, '#', '') 

	
	RETURN @retVal

END
GO

 