IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getSubUnitTypesWithSubstituteNames')
	BEGIN
		DROP  Procedure  rpc_getSubUnitTypesWithSubstituteNames
	END
GO

CREATE PROCEDURE [dbo].[rpc_getSubUnitTypesWithSubstituteNames]

AS

SELECT
UnitType.UnitTypeCode,
UnitTypeName,
subUnitType.subUnitTypeCode,
subUnitType.subUnitTypeName,
SubstituteName

FROM UnitType
LEFT JOIN subUnitType ON UnitType.UnitTypeCode = subUnitType.UnitTypeCode
LEFT JOIN SubUnitTypeSubstituteName SUTSN 
	ON subUnitType.subUnitTypeCode = SUTSN.SubUnitTypeCode
	AND subUnitType.UnitTypeCode = SUTSN.UnitTypeCode
WHERE IsActive = 1
ORDER BY UnitTypeName

GRANT EXEC ON rpc_getSubUnitTypesWithSubstituteNames TO PUBLIC
GO