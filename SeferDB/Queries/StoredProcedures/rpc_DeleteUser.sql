IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteUser')
	BEGIN
		DROP  Procedure  rpc_DeleteUser
	END

GO

CREATE Procedure dbo.rpc_DeleteUser

	(
		@UserID bigint
	)


AS
	
	Delete Users where UserID = @UserID
GO


GRANT EXEC ON rpc_DeleteUser TO PUBLIC

GO


