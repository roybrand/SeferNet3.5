IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertMainMenuItem')
	BEGIN
		DROP  Procedure  rpc_InsertMainMenuItem
	END

GO

CREATE PROCEDURE dbo.rpc_InsertMainMenuItem
	(
		@Title varchar(100),
		@Description varchar(100),
		@Url varchar(100),
		@Roles varchar(50),
		@ParentID int,
		
		@ItemID int OUTPUT
	)

AS

IF @ParentID = -1
BEGIN
	SET @ParentID = null
END

DECLARE @OrderNumber int

SET @OrderNumber = (SELECT MAX(OrderNumber) FROM MainMenuItems WHERE (@ParentID is NOT null AND ParentID = @ParentID) OR (@ParentID is null AND ParentID is null) )
SET @OrderNumber = IsNull(@OrderNumber, 0) + 1

SET @ItemID = IsNull((SELECT MAX(ItemID) FROM MainMenuItems), 0) + 1

INSERT INTO MainMenuItems
(ItemID, Title, Description, Url, ParentID, OrderNumber)
VALUES
(@ItemID, @Title, @Description, @Url, @ParentID, @OrderNumber)


INSERT INTO MainMenuItemsPermissions
SELECT @ItemID, IntField
FROM dbo.SplitString(@Roles)

	

GO


GRANT EXEC ON rpc_InsertMainMenuItem TO PUBLIC

GO

