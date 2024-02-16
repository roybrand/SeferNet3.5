 
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetEmployeeLanguages')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeLanguages
	END
GO 
 
create FUNCTION [dbo].[fun_GetEmployeeLanguages] (@employeeID int)
RETURNS varchar(50)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @count int, @curentCount int, @strLanguages varchar(100)
	DECLARE @curLanguageCode int
	SET @curLanguageCode = 0
	SET @strLanguages = ''

	SET @count = (SELECT COUNT(DISTINCT languageCode) FROM EmployeeLanguages WHERE EmployeeID = @employeeID)

	IF( @count > 0)
		BEGIN
			SET @curentCount = @count

			WHILE (@curentCount > 0)
				BEGIN
					SET @curLanguageCode = 
						(	SELECT MIN(languageCode) FROM EmployeeLanguages 
							WHERE EmployeeID = @employeeID
							AND languageCode > @curLanguageCode)

					SET @strLanguages = @strLanguages + ', ' +
						(	SELECT TOP 1 languageDescription 
							FROM EmployeeLanguages AS EL
							INNER JOIN languages ON EL.languageCode = languages.languageCode
							WHERE EL.languageCode = @curLanguageCode)		

					SET @curentCount = @curentCount - 1
					
				END
			SET @strLanguages = RIGHT( @strLanguages, LEN(@strLanguages) -1 )

		END

	RETURN( @strLanguages )
	
END;