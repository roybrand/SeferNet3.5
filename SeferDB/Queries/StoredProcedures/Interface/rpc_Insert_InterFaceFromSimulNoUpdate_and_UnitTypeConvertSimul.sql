IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Insert_InterFaceFromSimulNoUpdate_and_UnitTypeConvertSimul')
	BEGIN
		DROP  Procedure  rpc_Insert_InterFaceFromSimulNoUpdate_and_UnitTypeConvertSimul
	END

GO

CREATE Procedure dbo.rpc_Insert_InterFaceFromSimulNoUpdate_and_UnitTypeConvertSimul

AS

DECLARE @ErrorMessage varchar(200)

BEGIN TRY
	BEGIN TRANSACTION
	
	--SET @ErrorMessage = 'INSERT INTO UnitTypeConvertSimul'
 
	--INSERT INTO UnitTypeConvertSimul 
	--( SugSimul, TatSugSimul, TatHitmahut, RamatPeilut, key_TypUnit, userUpdate, updateDate, Active, PopSectorID) 
	--SELECT 
	--SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, null, '1717', GETDATE(), 0, null
	--FROM Interface_UpdateDeptsManually_Intermediate
	--WHERE NeedToInsertInto_UnitTypeConvertSimul = 1 

	SET @ErrorMessage = 'INSERT INTO InterFaceFromSimulNoUpdate'

	INSERT INTO InterFaceFromSimulNoUpdate 
	( SimulDeptId, SimulDeptName, districtCode, StatusSimul, manageId, SimulManageDescription, 
	cityCode, street, house, entrance, flat, zipCode, 
	SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, SugMosad, 
	OpenDateSimul, ClosingDateSimul, 
	Email, Menahel, 
	Simul228, DeptType, typeUnitCode, 
	SivugSimulChanged, ManageIdChanged, PopSectorID)
	SELECT
	SimulDeptId, SimulDeptName, districtCode, StatusSimul, manageId, SimulManageDescription, 
	cityCode, street, house, entrance, flat, zipCode, 
	SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, SugMosad, 
	OpenDateSimul, ClosingDateSimul, 
	Email, Menahel, 
	Simul228, DeptType, typeUnitCode, 
	SivugSimulChanged, ManageIdChanged, PopSectorID
	FROM Interface_UpdateDeptsManually_Intermediate
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
		
	SET @ErrorMessage = 'Failed on ' + @ErrorMessage
	exec rpc_Insert_LogInterface @ErrorMessage
END CATCH

GO


GRANT EXEC ON rpc_Insert_InterFaceFromSimulNoUpdate_and_UnitTypeConvertSimul TO PUBLIC

GO


