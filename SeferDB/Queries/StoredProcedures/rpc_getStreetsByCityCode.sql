IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getStreetsByCityCode')
	BEGIN
		DROP  Procedure  rpc_getStreetsByCityCode
	END

GO

Create procedure [dbo].[rpc_getStreetsByCityCode]

@cityCode int,
@SearchStr varchar(20)=null

as

SELECT CityCode, StreetName, StreetCode FROM
(
SELECT CityCode, rtrim( ltrim(Name)) as StreetName, StreetCode, showOrder = 0 
FROM streets
where (@cityCode is null or CityCode = @cityCode ) 
and (@SearchStr is null or Name like @SearchStr+'%') 

UNION

SELECT CityCode, rtrim( ltrim(Name)) as StreetName, StreetCode, showOrder = 1 
FROM streets
where (@cityCode is null or CityCode = @cityCode ) 
and (@SearchStr is null OR (Name like '%' + @SearchStr + '%' AND Name NOT like @SearchStr+'%'))
) as T1
ORDER BY showOrder, StreetName


GO


GRANT EXEC ON dbo.rpc_getStreetsByCityCode TO PUBLIC

GO

