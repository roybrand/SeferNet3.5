IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'SqlDynamicColumnCommaSeparator')
	BEGIN
		DROP  FUNCTION  SqlDynamicColumnCommaSeparator
	END
GO

create FUNCTION [dbo].[SqlDynamicColumnCommaSeparator]
(
	@sqlSelect nvarchar(max)
)
RETURNS nvarchar(max)

AS
BEGIN	
	DECLARE @NewLineChar AS CHAR(2) 
	SET @NewLineChar = CHAR(13) + CHAR(10)
		
	DECLARE @positionIndex int 
	SET @positionIndex = 0
	-- Is 'SELECT' the last word in the expression?
	SET @positionIndex = CHARINDEX('select', RTRIM(@sqlSelect), LEN(RTRIM(REPLACE( @sqlSelect, @NewLineChar, ''))) - LEN('select') )
	IF (@positionIndex = 0)  --'SELECT' is NOT the last word
		SET @sqlSelect = @sqlSelect + ','

	RETURN (@sqlSelect)
END  
go 

grant exec on SqlDynamicColumnCommaSeparator to public 
go 