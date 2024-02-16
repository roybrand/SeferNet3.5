IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteUserPermissions')
	BEGIN
		DROP  Procedure  rpc_DeleteUserPermissions
	END

GO

CREATE Procedure dbo.rpc_DeleteUserPermissions

	(
		@UserID bigint
	)


AS

	Delete UserPermissions
	where UserID = @UserID

GO


GRANT EXEC ON rpc_DeleteUserPermissions TO PUBLIC

GO


