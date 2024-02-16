IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptFromSimulNewDepts')
	BEGIN
		DROP  Procedure  rpc_insertDeptFromSimulNewDepts
	END

GO

CREATE Procedure [dbo].[rpc_insertDeptFromSimulNewDepts]
	(
		@DeptCode int,
		@UpdateUser varchar(50),
		@ErrorCode int OUTPUT
	)

AS
	SET @ErrorCode = 0

BEGIN TRY
	INSERT INTO dept
	(deptCode, deptName, deptType, districtCode, deptLevel, typeUnitCode, subUnitTypeCode, administrationCode, subAdministrationCode, managerName, cityCode, zipCode, street, streetName, house, flat, entrance, floor, email, status, independent, updateUser)
	SELECT
	SimulDeptId, SimulDeptName, DeptType, DistrictId, 3, Key_typUnit, null, ManageId, null, SimulManageDescription, City, zip, null, street/*streetName*/, house, flat, entrance, null, Email, StatusSimul, null, @UpdateUser
	FROM InterfaceFromSimulNewDepts
	WHERE SimulDeptId = @DeptCode
	
	SET @ErrorCode = @@ERROR
END TRY
BEGIN CATCH
	SET @ErrorCode = 0
END CATCH

GO

GRANT EXEC ON rpc_insertDeptFromSimulNewDepts TO PUBLIC

GO

