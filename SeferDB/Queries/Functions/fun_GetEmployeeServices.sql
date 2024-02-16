IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetEmployeeServices')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServices
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServices] (@employeeID int)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strServices varchar(500)

	SET @strServices = ''

	SELECT	@strServices = @strServices + RTRIM([Services].ServiceDescription) + ', ' 
	FROM EmployeeServices AS ES
	INNER JOIN [Services] ON ES.serviceCode = [Services].serviceCode
	WHERE ES.EmployeeID = @employeeID	
	AND [Services].IsService = 1

	IF(LEN(@strServices) > 0)
	BEGIN
		SET @strServices = LEFT( @strServices, LEN(@strServices) -1 )
	END

	RETURN( ISNULL(@strServices, '') )
	
END;
GO 

grant exec on fun_GetEmployeeServices to public 
GO