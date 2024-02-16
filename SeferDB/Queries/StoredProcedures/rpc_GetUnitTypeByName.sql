IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetUnitTypeByName')
	BEGIN
		DROP  Procedure  rpc_GetUnitTypeByName
	END

GO

CREATE Procedure dbo.rpc_GetUnitTypeByName
(
	@unitTypeName VARCHAR(30),
	@searchExtended BIT
)

AS

SELECT UnitTypeCode, UnitTypeName
FROM UnitType
WHERE ((UnitTypeName LIKE @unitTypeName + '%') OR (UnitTypeName LIKE '%' + @unitTypeName + '%' AND @searchExtended = 1))
AND ShowInInternet = 1
ORDER BY UnitTypeName



GO


GRANT EXEC ON rpc_GetUnitTypeByName TO PUBLIC

GO



