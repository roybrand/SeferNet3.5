IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSitesByName')
	BEGIN
		DROP  Procedure  rpc_GetSitesByName
	END

GO

CREATE Procedure dbo.rpc_GetSitesByName
(
	@cityCode INT,
	@siteName VARCHAR(30),
	@searchExtended BIT
)

AS

SELECT InstituteName
FROM Atarim
WHERE (CityCode = @cityCode) AND ( (InstituteName LIKE @siteName + '%') OR (InstituteName LIKE '%' + @siteName + '%' AND @searchExtended = 1) )
ORDER BY InstituteName


GO


GRANT EXEC ON rpc_GetSitesByName TO PUBLIC

GO


