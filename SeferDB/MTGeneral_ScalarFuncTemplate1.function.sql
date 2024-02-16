IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MTGeneral_ScalarFuncTemplate1]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	BEGIN
		PRINT 'Dropping Scalar Function MTGeneral_ScalarFuncTemplate1'
		DROP FUNCTION [dbo].[MTGeneral_ScalarFuncTemplate1]
	END
GO

PRINT 'Creating Scalar Function MTGeneral_ScalarFuncTemplate1'
GO

CREATE FUNCTION [dbo].[MTGeneral_ScalarFuncTemplate1]
(
	@param1 int, 
	@param2 int
)
RETURNS INT
AS
BEGIN
	RETURN @param1 + @param2
END