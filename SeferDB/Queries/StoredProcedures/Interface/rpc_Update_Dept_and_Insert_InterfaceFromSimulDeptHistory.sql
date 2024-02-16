IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Update_Dept_and_Insert_InterfaceFromSimulDeptHistory')
	BEGIN
		DROP  Procedure  rpc_Update_Dept_and_Insert_InterfaceFromSimulDeptHistory
	END

GO

CREATE Procedure dbo.rpc_Update_Dept_and_Insert_InterfaceFromSimulDeptHistory

AS

DECLARE @ErrorMessage varchar(200)

BEGIN TRY
	BEGIN TRANSACTION

		SET @ErrorMessage = 'UPDATE dept'
		
		UPDATE dept 
		SET 
		--dept.deptType = I_UDA_I.deptType,
		dept.updateDate = GETDATE(), 
		dept.updateUser = 'AutoSimul'
		FROM Interface_UpdateDeptsAutomatically_Intermediate I_UDA_I 
		INNER JOIN dept ON I_UDA_I.deptCode = dept.deptCode 

		SET @ErrorMessage = 'UPDATE deptSimul'
		
		UPDATE deptSimul 
		SET 
		deptSimul.DeptNameSimul = I_UDA_I.DeptNameSimul, 
		deptSimul.OpenDateSimul = I_UDA_I.OpenDateSimul, 
		deptSimul.ClosingDateSimul = I_UDA_I.ClosingDateSimul, 
		deptSimul.StatusSimul = I_UDA_I.StatusSimul, 
		deptSimul.simul228 = I_UDA_I.simul228,
		deptSimul.SimulManageDescription = I_UDA_I.SimulManageDescription
		FROM Interface_UpdateDeptsAutomatically_Intermediate I_UDA_I 
		INNER JOIN deptSimul ON I_UDA_I.deptCode = deptSimul.deptCode

		SET @ErrorMessage = 'INSERT deptSimul'

		INSERT INTO deptSimul
		(deptCode, DeptNameSimul, OpenDateSimul, ClosingDateSimul, StatusSimul, simul228, SimulManageDescription)
		SELECT 
		deptCode, DeptNameSimul, OpenDateSimul, ClosingDateSimul, StatusSimul, simul228, SimulManageDescription
		FROM Interface_UpdateDeptsAutomatically_Intermediate 
		WHERE Interface_UpdateDeptsAutomatically_Intermediate.deptCode NOT in (SELECT deptCode FROM deptSimul)

		SET @ErrorMessage = 'INSERT INTO InterfaceFromSimulDeptHistory'

		INSERT INTO InterfaceFromSimulDeptHistory 
		( deptCode, districtCode, deptName, administrationCode, 
		SimulManageDescription,
		cityCode, street, entrance, house, flat, zipCode,
		SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504,
		typeUnitCode, status, DateOpened, DateClosedSimul,
		Email, managerName, simul228,
		SimulNameChng, SimulMangIdChng, SimulOpenDateChng, SimulStatusChng, SimulClosingDateChng, SimulDistrictChng, Simul228Chng,
		DeptNameSimul, PopSectorId )
		SELECT d.deptCode, IsNull(districtCode, 0), deptName, administrationCode,
		deptSimul.SimulManageDescription, 
		d.cityCode, d.streetCode, d.entrance, d.house, d.flat, d.zipCode, 
		deptSimul.SugSimul501, deptSimul.TatSugSimul502, deptSimul.TatHitmahut503, deptSimul.RamatPeilut504, 
		typeUnitCode, d.status, deptSimul.openDateSimul, deptSimul.ClosingDateSimul, 
		d.Email, d.managerName, deptSimul.simul228, 
		'SimulNameChng' = CASE 
			WHEN d.deptName <> simul403.TeurSimul THEN 1 ELSE 0 END, 
		'SimulMangIdChng' = 0, 
		'SimulOpenDateChng' = CASE 
			WHEN deptSimul.OpenDateSimul <> Simul403.DateOpened THEN 1 ELSE 0 END, 
		'SimulClosingDateChng' = CASE 
			WHEN deptSimul.ClosingDateSimul <> Simul403.DateClosed THEN 1 ELSE 0 END, 
		'SimulStatusChng'= CASE 
			WHEN d.status <> simul403.status THEN 1 ELSE 0 END, 
		'SimulDistrictChng'= CASE 
			WHEN d.districtCode <> simul403.Mahoz THEN 1 ELSE 0 END, 
		'Simul228Chng' = CASE 
			WHEN IsNull(deptSimul.Simul228, 0) <> IsNull(I_UDA_I.Simul228, 0) THEN 1 ELSE 0 END,
		simul403.TeurSimul, populationSectorCode 
		FROM dept as d 
		INNER JOIN deptSimul ON d.deptCode = deptSimul.deptCode 
		INNER JOIN simul403 ON d.deptCode = simul403.KodSimul 
		INNER JOIN Interface_UpdateDeptsAutomatically_Intermediate I_UDA_I ON d.deptCode = I_UDA_I.deptCode 

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN 
		
	SET @ErrorMessage = 'Failed on ' + @ErrorMessage
	exec rpc_Insert_LogInterface @ErrorMessage
END CATCH

GO


GRANT EXEC ON rpc_Update_Dept_and_Insert_InterfaceFromSimulDeptHistory TO PUBLIC

GO

