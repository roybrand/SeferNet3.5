IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptStatusForNewDept')
	BEGIN
		DROP  Procedure  rpc_insertDeptStatusForNewDept
	END

GO

CREATE Procedure dbo.rpc_insertDeptStatusForNewDept
	(
		@DeptCode int,
		@UpdateUser varchar(50),
		@ErrorCode int = 0 OUTPUT
	)

AS

	INSERT INTO DeptStatus
	(DeptCode, Status, FromDate, ToDate, UpdateUser, UpdateDate)
	SELECT
	SimulDeptId, 2, getdate(), null, @UpdateUser, getdate()
	FROM InterfaceFromSimulNewDepts
	WHERE SimulDeptId = @DeptCode

	SET @ErrorCode = @@Error

GO

GRANT EXEC ON rpc_insertDeptStatusForNewDept TO PUBLIC

GO

