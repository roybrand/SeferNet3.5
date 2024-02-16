IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteAdminComment')
	BEGIN
		DROP  Procedure  rpc_DeleteAdminComment
	END

GO

CREATE Procedure dbo.rpc_DeleteAdminComment
(
	@ID int 
)
AS

DELETE FROM AdminComments where ID=@ID

GO


GRANT EXEC ON rpc_DeleteAdminComment TO PUBLIC

GO


