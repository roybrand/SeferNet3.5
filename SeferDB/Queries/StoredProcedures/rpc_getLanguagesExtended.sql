IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getLanguagesExtended')
	BEGIN
		DROP  Procedure  rpc_getLanguagesExtended
	END

GO

CREATE Procedure rpc_getLanguagesExtended
	(
		@SelectedLanguages varchar(100)
	)

AS

SELECT
languageCode,
languageDescription,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END

FROM languages
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedLanguages)) as sel ON languages.languageCode = sel.IntField
where isShow=1

ORDER BY languageDescription


GO

GRANT EXEC ON rpc_getLanguagesExtended TO PUBLIC

GO

