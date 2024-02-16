IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteSimulNewDepts')
	BEGIN
		DROP  Procedure  rpc_deleteSimulNewDepts
	END

GO

CREATE Procedure dbo.rpc_deleteSimulNewDepts
	(
		@DeptCode int
	)

AS

DELETE FROM InterfaceFromSimulNewDepts
WHERE SimulDeptId = @DeptCode

DELETE FROM SimulExceptions where SimulId = @DeptCode

INSERT INTO SimulExceptions
(SimulId, SeferSherut, UpdateDate, userUpdate)
VALUES
(@DeptCode, 0, GETDATE(), 'היחידה נמחקה בדף קליטה יחידות חדשות')

GO

GRANT EXEC ON rpc_deleteSimulNewDepts TO PUBLIC

GO

