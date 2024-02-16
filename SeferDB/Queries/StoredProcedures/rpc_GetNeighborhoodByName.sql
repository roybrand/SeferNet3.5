IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetNeighborhoodByName')
	BEGIN
		DROP  Procedure  rpc_GetNeighborhoodByName
	END

GO

CREATE Procedure dbo.rpc_GetNeighborhoodByName
(
	@cityCode INT,
	@neighborhoodName VARCHAR(50),
	@searchExtended BIT
)

AS

SELECT NybName
FROM Neighbourhoods
WHERE (CityCode = @cityCode) AND ( (NybName LIKE @neighborhoodName + '%') OR (NybName LIKE '%' + @neighborhoodName + '%' AND @searchExtended = 1 ))
ORDER BY NybName


GO


GRANT EXEC ON rpc_GetNeighborhoodByName TO PUBLIC

GO


