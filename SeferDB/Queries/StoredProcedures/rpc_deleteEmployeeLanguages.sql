IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeLanguages')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeLanguages
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeeLanguages
	(
		@EmployeeID int,
		@LanguageCode int = NULL
	)

AS

DELETE FROM EmployeeLanguages
WHERE employeeID = @EmployeeID
AND languageCode = IsNull(@LanguageCode,languageCode)

UPDATE Employee
SET updateDate = GETDATE()
WHERE employeeID = @EmployeeID

GO

GRANT EXEC ON rpc_deleteEmployeeLanguages TO PUBLIC

GO

