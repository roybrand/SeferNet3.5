IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertMainMenuRestriction')
	BEGIN
		DROP  Procedure  rpc_InsertMainMenuRestriction
	END

GO

CREATE Procedure dbo.rpc_InsertMainMenuRestriction
	(
		@MainMenuItemID int,
		@PageName varchar(100)
	)

AS

INSERT INTO MainMenuRestrictions
(MainMenuItemID, PageName)
VALUES
(@MainMenuItemID, @PageName)

GO

GRANT EXEC ON rpc_InsertMainMenuRestriction TO PUBLIC

GO

