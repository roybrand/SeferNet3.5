IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertUnitTypeConvertSimul')
	BEGIN
		DROP  Procedure  rpc_InsertUnitTypeConvertSimul
	END

GO

CREATE Procedure dbo.rpc_InsertUnitTypeConvertSimul

AS

	INSERT INTO UnitTypeConvertSimul 
	( SugSimul, TatSugSimul, TatHitmahut, RamatPeilut, key_TypUnit, userUpdate, updateDate, Active, PopSectorID ) 
	SELECT 
	SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, null, '1717', GETDATE(), 0, null
	FROM vInterface_NewDepts
	WHERE NeedToInsertInto_UnitTypeConvertSimul = 1 

GO

GRANT EXEC ON rpc_InsertUnitTypeConvertSimul TO PUBLIC

GO