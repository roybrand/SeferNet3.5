IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptStatuses')
	BEGIN
		DROP  Procedure  rpc_deleteDeptStatuses
	END

GO

CREATE Procedure dbo.rpc_deleteDeptStatuses
	(
		@DeptCode int,
		@ErrorStatus int = 0 OUTPUT
	)

AS



	DELETE DeptStatus 
	WHERE DeptCode = @DeptCode
	
	SET @ErrorStatus = @@Error
	

GO

GRANT EXEC ON rpc_deleteDeptStatuses TO PUBLIC

GO

