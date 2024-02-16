IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptPhones')
	BEGIN
		DROP  Procedure  rpc_deleteDeptPhones
	END

GO

CREATE Procedure dbo.rpc_deleteDeptPhones
	(
		@DeptCode int,
		@ErrorStatus int output
	)

AS

	DELETE FROM DeptPhones WHERE deptCode = @DeptCode

	SET @ErrorStatus = @@Error

GO

GRANT EXEC ON rpc_deleteDeptPhones TO PUBLIC

GO

