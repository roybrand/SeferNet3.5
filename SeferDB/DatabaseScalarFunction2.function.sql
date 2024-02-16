IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DatabaseScalarFunction2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	BEGIN
		PRINT 'Dropping Scalar Function DatabaseScalarFunction2'
		DROP FUNCTION [dbo].[DatabaseScalarFunction2]
	END
GO

PRINT 'Creating Scalar Function DatabaseScalarFunction2'
GO

CREATE FUNCTION [dbo].[DatabaseScalarFunction2]
(
	@param1 int, 
	@param2 int
)
RETURNS INT
AS
BEGIN
	RETURN @param1 + @param2
END