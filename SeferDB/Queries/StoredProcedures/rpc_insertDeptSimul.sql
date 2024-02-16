IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptSimul')
	BEGIN
		DROP  Procedure  rpc_insertDeptSimul
	END

GO

CREATE Procedure dbo.rpc_insertDeptSimul
	(
		@DeptCode int,
		@ErrorCode int OUTPUT
	)

AS

SET @ErrorCode = 0

INSERT INTO deptSimul
(deptCode, openDateSimul, closingDateSimul, statusSimul, deptNameSimul, SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, Simul228, SimulManageDescription)
SELECT
SimulDeptId, OpenDateSimul, ClosingDateSimul, StatusSimul, SimulDeptName, SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, Simul228, SimulManageDescription
FROM InterfaceFromSimulNewDepts
WHERE SimulDeptId = @DeptCode

SET @ErrorCode = @@ERROR

GO

GRANT EXEC ON rpc_insertDeptSimul TO PUBLIC

GO

