IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetStreetsByName')
	BEGIN
		DROP  Procedure  rpc_GetStreetsByName
	END

GO

CREATE Procedure dbo.rpc_GetStreetsByName
(
	@cityCode INT,
	@streetName VARCHAR(30),
	@searchExtended BIT
)

AS

SELECT Name
FROM Streets
WHERE (CityCode = @cityCode) AND ( (Name LIKE @streetName + '%') OR (Name LIKE '%' + @streetName + '%' AND @searchExtended = 1 )  )
ORDER BY Name




GO


GRANT EXEC ON rpc_GetStreetsByName TO PUBLIC

GO

