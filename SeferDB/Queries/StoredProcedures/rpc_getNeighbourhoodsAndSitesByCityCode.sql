IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getNeighbourhoodsAndSitesByCityCode')
	BEGIN
		DROP  Procedure  rpc_getNeighbourhoodsAndSitesByCityCode
	END

GO

CREATE Procedure dbo.rpc_getNeighbourhoodsAndSitesByCityCode
(
	@cityCode int,
	@SearchStr varchar(20)=null
)

AS

SELECT CityCode, rtrim( ltrim(InstituteName)) as Name, InstituteCode as Code, 1 as IsSite 
FROM Atarim
WHERE (@cityCode is null or CityCode = @cityCode ) 
AND (@SearchStr is null or InstituteName like '%' + @SearchStr + '%') 


UNION

SELECT CityCode, rtrim( ltrim(NybName)) as Name, NeighbourhoodCode as Code, 0 as IsSite  
FROM Neighbourhoods
WHERE (@cityCode is null or CityCode = @cityCode ) 
AND (@SearchStr is null or NybName like '%' + @SearchStr+ '%') 

ORDER BY Name

GO


GRANT EXEC ON dbo.rpc_getNeighbourhoodsAndSitesByCityCode TO PUBLIC

GO