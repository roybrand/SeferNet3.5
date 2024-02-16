IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteProfessionHours')
	BEGIN
		DROP  Procedure  rpc_DeleteProfessionHours
	END

GO

CREATE Procedure rpc_DeleteProfessionHours

	(
		@receptionID int
	)

AS

	delete DeptProfessionReception where receptionID= @receptionID


GO

GRANT EXEC ON rpc_DeleteProfessionHours TO PUBLIC

GO

