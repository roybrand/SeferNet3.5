IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceSector')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceSector
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceSector] (@employeeID bigint, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	
	DECLARE @Sector int SET @Sector = 0

	SET @Sector = 
		(SELECT SectorToShowWith FROM [Services] WHERE [Services].ServiceCode = @ServiceCode )
		
	IF @Sector IS NULL
		SET @Sector = 
			(SELECT EmployeeSectorCode FROM Employee WHERE employeeID = @employeeID )
			
	RETURN @Sector

END
GO

grant exec on fun_GetEmployeeServiceSector to public 
go 
