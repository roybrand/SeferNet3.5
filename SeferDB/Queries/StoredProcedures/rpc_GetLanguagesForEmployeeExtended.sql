IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetLanguagesForEmployeeExtended')
	BEGIN
		DROP  Procedure  rpc_GetLanguagesForEmployeeExtended
	END

GO

CREATE Procedure [dbo].[rpc_GetLanguagesForEmployeeExtended]
(
	@employeeID INT
)

AS


SELECT l.languageCode, l.LanguageDescription, CASE IsNull(el.LanguageCode,0) WHEN 0 THEN 0 ELSE 1 END as LinkedToEmployee
FROM Languages l
LEFT JOIN EmployeeLanguages el 
ON l.languageCode = el.languageCode AND el.employeeID = @EmployeeID
where isShow=1
ORDER BY languageDescription

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 4

GO


GRANT EXEC ON dbo.rpc_GetLanguagesForEmployeeExtended TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetLanguagesForEmployeeExtended TO [clalit\IntranetDev]
GO


