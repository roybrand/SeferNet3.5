IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateMainMenuItem')
	BEGIN
		DROP  Procedure  rpc_UpdateMainMenuItem
	END

GO

CREATE PROCEDURE dbo.rpc_UpdateMainMenuItem
	(
		@ItemID int,
		@Title varchar(100),
		@Description varchar(100),
		@Url varchar(100),
		@Roles varchar(50),
		
		@ErrorStatus int OUTPUT
	)

AS


SET @ErrorStatus = 0
	

	UPDATE MainMenuItems
	SET Title = @Title,
	Description = @Description,
	Url = @Url
	WHERE ItemID = @ItemID

	DELETE MainMenuItemsPermissions
	WHERE MenuItemID = @ItemID

	INSERT INTO MainMenuItemsPermissions
	SELECT @itemID, IntField
	FROM dbo.SplitString(@Roles)

	
	SET @ErrorStatus = @@Error
	
GO

GRANT EXEC ON rpc_UpdateMainMenuItem TO PUBLIC

GO

