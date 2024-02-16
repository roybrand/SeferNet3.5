IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSubUnitTypesForUnit')
	BEGIN
		DROP  Procedure  rpc_GetSubUnitTypesForUnit
	END

GO

CREATE Procedure dbo.rpc_GetSubUnitTypesForUnit
(
	@unitType INT
)

AS

SELECT SubUnitTypeCode, SubUnitTypeName
FROM SubUnitType
WHERE UnitTypeCode = @unitType
ORDER BY SubUnitTypeName


GO


GRANT EXEC ON rpc_GetSubUnitTypesForUnit TO PUBLIC

GO


