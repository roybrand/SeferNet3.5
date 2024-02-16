IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeProfessions')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeProfessions
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeProfessions] (@employeeID int)
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
	AND [Services].IsProfession = 1

	IF(LEN(@strServices) > 0)
	BEGIN
		SET @strServices = LEFT( @strServices, LEN(@strServices) -1 )
	END

	RETURN( ISNULL(@strServices, ''))
		
END;
GO

grant exec on fun_GetEmployeeProfessions to public 
go 
