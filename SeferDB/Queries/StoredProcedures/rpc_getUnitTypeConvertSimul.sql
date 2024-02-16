IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUnitTypeConvertSimul')
	BEGIN
		DROP  Procedure  rpc_getUnitTypeConvertSimul
	END

GO

CREATE Procedure dbo.rpc_getUnitTypeConvertSimul
	(
		@ConvertId int 
	)

AS

SELECT CAST(UnitTypeConvertSimul.Active as bit) as Active, CASE UnitTypeConvertSimul.Active WHEN 1 THEN 'פעיל' ELSE '' END as 'ActiveDesc', UnitTypeConvertSimul.ConvertId, UnitTypeConvertSimul.SugSimul, 
UnitTypeConvertSimul.TatSugSimul, UnitTypeConvertSimul.TatHitmahut, UnitTypeConvertSimul.RamatPeilut, 
UnitTypeConvertSimul.key_TypUnit, UnitType.UnitTypeName, IsNull(PopSectorID, -1) as PopSectorID, PopulationSectorDescription,
SugSimul501.SimulDesc, 
TatSugSimul502.TatSugSimulDesc, 
TatHitmahut503.HitmahutDesc,
RamatPeilut504.Teur as 'RamatPeilutDesc'
FROM UnitTypeConvertSimul 
LEFT JOIN UnitType ON UnitTypeConvertSimul.key_TypUnit = UnitType.UnitTypeCode
LEFT JOIN PopulationSectors ON UnitTypeConvertSimul.PopSectorID = populationSectors.PopulationSectorId 
LEFT JOIN SugSimul501 ON UnitTypeConvertSimul.SugSimul = SugSimul501.SugSimul
LEFT JOIN TatSugSimul502 ON UnitTypeConvertSimul.SugSimul = TatSugSimul502.SugSimul
	AND UnitTypeConvertSimul.TatSugSimul = TatSugSimul502.TatSugSimulId
LEFT JOIN TatHitmahut503 ON UnitTypeConvertSimul.SugSimul = TatHitmahut503.SugSimul
	AND UnitTypeConvertSimul.TatSugSimul = TatHitmahut503.TatSugSimulId
	AND UnitTypeConvertSimul.TatHitmahut = TatHitmahut503.TatHitmahut
LEFT JOIN RamatPeilut504 ON UnitTypeConvertSimul.SugSimul = RamatPeilut504.SugSimul
	AND UnitTypeConvertSimul.TatSugSimul = RamatPeilut504.TatSugSimul
	AND UnitTypeConvertSimul.TatHitmahut = RamatPeilut504.TatHitmahut
	AND UnitTypeConvertSimul.RamatPeilut = RamatPeilut504.RamatPeilut
WHERE @ConvertId IS null OR UnitTypeConvertSimul.ConvertId = @ConvertId
ORDER BY SugSimul, TatSugSimul, TatHitmahut 

GO

GRANT EXEC ON rpc_getUnitTypeConvertSimul TO PUBLIC

GO

