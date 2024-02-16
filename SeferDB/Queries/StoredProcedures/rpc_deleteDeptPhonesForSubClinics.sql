IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptPhonesForSubClinics')
	BEGIN
		DROP  Procedure  rpc_deleteDeptPhonesForSubClinics
	END

GO

CREATE Procedure rpc_deleteDeptPhonesForSubClinics
	(
		@DeptCode int
	)

AS

DELETE FROM DeptPhones
WHERE deptCode IN (SELECT deptCode FROM dept WHERE subAdministrationCode = @DeptCode)

GO

GRANT EXEC ON rpc_deleteDeptPhonesForSubClinics TO PUBLIC

GO

