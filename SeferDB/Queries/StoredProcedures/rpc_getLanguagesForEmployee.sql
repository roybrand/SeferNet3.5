IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getLanguagesForEmployee')
	BEGIN
		DROP  Procedure  rpc_getLanguagesForEmployee
	END

GO

CREATE Procedure rpc_getLanguagesForEmployee
	(
		@EmployeeID bigint
	)

AS

SELECT
l.languageCode,
languageDescription
FROM languages l
INNER JOIN EmployeeLanguages el 
ON l.languageCode = el.languageCode AND el.employeeID = @EmployeeID
ORDER BY languageDescription

GO

GRANT EXEC ON rpc_getLanguagesForEmployee TO PUBLIC

GO

