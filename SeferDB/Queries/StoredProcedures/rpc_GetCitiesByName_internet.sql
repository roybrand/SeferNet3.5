IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetCitiesByName_internet')
	BEGIN
		DROP  Procedure  rpc_GetCitiesByName_internet
	END

GO

CREATE Procedure dbo.rpc_GetCitiesByName_internet
(	
	@cityName VARCHAR(30),
	@searchExtended BIT
)

AS


SELECT CityCode, CityName
FROM Cities
WHERE (CityName LIKE @cityName + '%') OR (CityName LIKE '%' + @cityName + '%' AND @searchExtended = 1)
ORDER BY CityName


GO


GRANT EXEC ON rpc_GetCitiesByName_internet TO PUBLIC

GO


