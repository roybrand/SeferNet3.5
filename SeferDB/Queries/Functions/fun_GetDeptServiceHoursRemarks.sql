IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetDeptServiceHoursRemarks')
	BEGIN
		DROP  FUNCTION  fun_GetDeptServiceHoursRemarks
	END

GO
CREATE FUNCTION [dbo].[fun_GetDeptServiceHoursRemarks]
(
	@EmployeeReceptionID int
)

RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strRemarks varchar(1000)
	SET @strRemarks = ''

	SELECT @strRemarks = @strRemarks +  REPLACE(RemarkText,'#','') + '<br>'
		FROM DeptEmployeeReceptionRemarks 
		WHERE EmployeeReceptionID = @EmployeeReceptionID
			
	RETURN( @strRemarks )
	
END
GO

GRANT EXEC ON fun_GetDeptServiceHoursRemarks TO PUBLIC
GO
