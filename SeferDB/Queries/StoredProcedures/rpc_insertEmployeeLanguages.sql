
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeLanguages')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeLanguages
	END

GO

CREATE Procedure dbo.rpc_insertEmployeeLanguages
	(
		@EmployeeID int,
		@LanguageCodes varchar(50),
		@UpdateUser varchar(50)
	)

AS

	DECLARE @count int, @currentCount int
	DECLARE @curLangCode int
	
	Declare @MinLangCode int
	SET @curLangCode = 0
	Set @MinLangCode = 0
	SET @count = (Select count(IntField) from  dbo.SplitString(@LanguageCodes))

	IF( @count > 0)
		BEGIN 

			SET @currentCount = @count

			WHILE (@currentCount > 0)
				BEGIN
				
					SET @curLangCode = (select min(IntField) from dbo.SplitString(@LanguageCodes)
											where IntField > @MinLangCode)
				
					SET @MinLangCode = @curLangCode
												   
					INSERT INTO EmployeeLanguages 
					(EmployeeID, languageCode, updateUser)
					VALUES 
					(@EmployeeID, @curLangCode, @UpdateUser)
					
					SET @currentCount = @currentCount -1
				
				END

			UPDATE Employee
			SET updateDate = GETDATE()
			WHERE employeeID = @EmployeeID
			
	END 	

GO

GRANT EXEC ON rpc_insertEmployeeLanguages TO PUBLIC

GO
