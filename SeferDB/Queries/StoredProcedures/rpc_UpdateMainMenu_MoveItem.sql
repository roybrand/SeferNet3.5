IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateMainMenu_MoveItem')
	BEGIN
		DROP  Procedure  rpc_UpdateMainMenu_MoveItem
	END

GO

CREATE PROCEDURE dbo.rpc_UpdateMainMenu_MoveItem
	(
		@ItemID int,
		@MoveDirection int, /* '1' - up; '-1' - down*/
		@ErrCode int OUTPUT
	)

AS

DECLARE @OrderNumber_Current int
DECLARE @OrderNumber_ToBeReplaced int
DECLARE @ParentID int
DECLARE @ItemID_of_Neihbor int

SET @ErrCode = 0

SET @OrderNumber_Current = (SELECT OrderNumber FROM MainMenuItems WHERE ItemID = @ItemID)

SET @ParentID = IsNull((SELECT ParentID FROM MainMenuItems WHERE ItemID = @ItemID), 0)

IF(@MoveDirection = 1) -- Up
	BEGIN
		SET @ItemID_of_Neihbor = IsNull((SELECT TOP 1 ItemID 
									FROM MainMenuItems 
									WHERE IsNull(ParentID, 0) = @ParentID
									AND OrderNumber < @OrderNumber_Current -- '>'
									ORDER BY OrderNumber DESC), 0)
	END
ELSE	-- Down
	BEGIN
		SET @ItemID_of_Neihbor = IsNull((SELECT TOP 1 ItemID 
									FROM MainMenuItems 
									WHERE IsNull(ParentID, 0) = @ParentID
									AND OrderNumber > @OrderNumber_Current -- '<'
									ORDER BY OrderNumber), 0)
	END

IF(@ItemID_of_Neihbor <> 0)
	BEGIN
		SET @OrderNumber_ToBeReplaced = (SELECT TOP 1 OrderNumber 
										FROM MainMenuItems 
										WHERE ItemID = @ItemID_of_Neihbor)
	
			
				UPDATE MainMenuItems
				SET OrderNumber = @OrderNumber_Current WHERE ItemID = @ItemID_of_Neihbor
				
				UPDATE MainMenuItems
				SET OrderNumber = @OrderNumber_ToBeReplaced WHERE ItemID = @ItemID
	
		
			SET @ErrCode = @@Error
	END


GO

GRANT EXEC ON rpc_UpdateMainMenu_MoveItem TO PUBLIC

GO

