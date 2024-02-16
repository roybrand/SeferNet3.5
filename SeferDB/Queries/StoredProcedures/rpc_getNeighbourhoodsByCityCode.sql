IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getNeighbourhoodsByCityCode')
	BEGIN
		DROP  Procedure  rpc_getNeighbourhoodsByCityCode
	END

GO

CREATE Procedure dbo.rpc_getNeighbourhoodsByCityCode
	(
		@cityCode int,
		@SearchStr varchar(20)=null
	)

AS

SELECT CityCode, rtrim( ltrim(NybName)) as NeighbourhoodName, NeighbourhoodCode 
FROM Neighbourhoods
WHERE (@cityCode is null or CityCode = @cityCode ) 
AND (@SearchStr is null or NybName like '%' + @SearchStr+ '%') 
ORDER BY NybName

GO

GRANT EXEC ON rpc_getNeighbourhoodsByCityCode TO PUBLIC

GO

