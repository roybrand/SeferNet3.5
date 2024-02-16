IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteMainMenuRestrictions')
	BEGIN
		DROP  Procedure  rpc_DeleteMainMenuRestrictions
	END
GO

CREATE Procedure dbo.rpc_DeleteMainMenuRestrictions
	(
		@MainMenuItemID int
	)

AS

DELETE FROM MainMenuRestrictions
WHERE MainMenuItemID = @MainMenuItemID

GO

GRANT EXEC ON rpc_DeleteMainMenuRestrictions TO PUBLIC
GO

