IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteForm')
	BEGIN
		DROP  Procedure  rpc_DeleteForm
	END

GO

CREATE Procedure dbo.rpc_DeleteForm
(
	@FormID int
)	
AS
	delete Forms 
	where FormID = @FormID

GO

GRANT EXEC ON rpc_DeleteForm TO PUBLIC

GO