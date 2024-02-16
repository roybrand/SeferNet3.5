IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[kkk1]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	BEGIN
		PRINT 'Dropping Table Function kkk1'
		DROP FUNCTION [dbo].[kkk1]
	END
GO

PRINT 'Creating Table Function kkk1'
GO

CREATE FUNCTION [dbo].[kkk1]
(
	@param1 int, 
	@param2 char(5)
)
RETURNS @returntable TABLE 
(
	c1 int, 
	c2 char(5)
)
AS
BEGIN
	INSERT @returntable
	SELECT @param1, @param2
	RETURN 
END