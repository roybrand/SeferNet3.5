IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getLanguagesByName')
	BEGIN
		DROP  Procedure  rpc_getLanguagesByName
	END

GO

CREATE Procedure rpc_getLanguagesByName
	(
		@SearchString varchar(50)
	)


AS
SELECT languageCode, languageDescription FROM
(
	SELECT
	languageCode,
	languageDescription,
	showOrder = 0
	FROM languages
	WHERE languageDescription like @SearchString + '%'

	UNION 

	SELECT
	languageCode,
	languageDescription,
	showOrder = 1
	FROM languages
	WHERE languageDescription like '%' + @SearchString + '%'
	AND languageDescription NOT like @SearchString + '%'
) as T1

ORDER BY showOrder, languageDescription

GO

GRANT EXEC ON rpc_getLanguagesByName TO PUBLIC

GO

