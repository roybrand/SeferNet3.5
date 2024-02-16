IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Insert_InterfaceFromSimulNewDepts_and_UnitTypeConvertSimul')
	BEGIN
		DROP  Procedure  rpc_Insert_InterfaceFromSimulNewDepts_and_UnitTypeConvertSimul
	END

GO

CREATE Procedure dbo.rpc_Insert_InterfaceFromSimulNewDepts_and_UnitTypeConvertSimul

AS

DECLARE @ErrorMessage varchar(200)

BEGIN TRY
	BEGIN TRANSACTION
	
	--SET @ErrorMessage = 'INSERT INTO UnitTypeConvertSimul'
	
	--INSERT INTO UnitTypeConvertSimul 
	--( SugSimul, TatSugSimul, TatHitmahut, RamatPeilut, key_TypUnit, userUpdate, updateDate, Active, PopSectorID) 
	--SELECT 
	--SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, null, '1717', GETDATE(), 0, null
	--FROM Interface_NewDepts_Intermediate
	--WHERE NeedToInsertInto_UnitTypeConvertSimul = 1 

	SET @ErrorMessage = 'INSERT INTO InterfaceFromSimulNewDepts'

	INSERT INTO InterfaceFromSimulNewDepts
	( SimulDeptId, SimulDeptName, dept_name, manageId, SimulManageDescription, 
	City, street, house, entrance, flat, zip, 
	Preprefix1, Prefix1, Nphone1, preprefix2, prefix2, Nphone2, 
	faxpreprefix, faxprefix, Nfax, 
	SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, 
	DistrictId, SugMosad, 
	OpenDateSimul, ClosingDateSimul, StatusSimul, Email, Menahel, 
	Simul228, DeptType, key_TypUnit, PopSectorID)
	SELECT 
	SimulDeptId, SimulDeptName, dept_name, manageId, SimulManageDescription, 
	City, street, house, entrance, flat, zip, 
	Preprefix1, Prefix1, Nphone1, preprefix2, prefix2, Nphone2, 
	faxpreprefix, faxprefix, Nfax, 
	SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, 
	DistrictId, SugMosad, 
	OpenDateSimul, ClosingDateSimul, StatusSimul, Email, Menahel, 
	Simul228, DeptType, key_TypUnit, PopSectorID 
	FROM Interface_NewDepts_Intermediate
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
		
	SET @ErrorMessage = 'Failed on ' + @ErrorMessage
	exec rpc_Insert_LogInterface @ErrorMessage
END CATCH

GO


GRANT EXEC ON rpc_Insert_InterfaceFromSimulNewDepts_and_UnitTypeConvertSimul TO PUBLIC

GO


