IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteBrochure')
	BEGIN
		DROP  Procedure  rpc_DeleteBrochure
	END

GO

CREATE Procedure dbo.rpc_DeleteBrochure
(
	@BrochureID int
)	
AS
	delete Brochures 
	where BrochureID = @BrochureID

GO

GRANT EXEC ON rpc_DeleteBrochure TO PUBLIC

GO