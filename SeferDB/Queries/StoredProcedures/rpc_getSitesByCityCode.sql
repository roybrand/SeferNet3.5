IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getSitesByCityCode')
	BEGIN
		DROP  Procedure  rpc_getSitesByCityCode
	END

GO

CREATE Procedure dbo.rpc_getSitesByCityCode
(
	@cityCode int,
	@SearchStr varchar(20)=null
)

AS

SELECT CityCode, rtrim( ltrim(InstituteName)) as InstituteName 
FROM Atarim
WHERE (@cityCode is null or CityCode = @cityCode ) 
AND (@SearchStr is null or InstituteName like '%' + @SearchStr + '%') 
ORDER BY InstituteName


GO


GRANT EXEC ON dbo.rpc_getSitesByCityCode TO PUBLIC

GO