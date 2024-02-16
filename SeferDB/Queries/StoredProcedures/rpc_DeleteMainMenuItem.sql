IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteMainMenuItem')
	BEGIN
		DROP  Procedure  rpc_DeleteMainMenuItem
	END

GO

CREATE Procedure dbo.rpc_DeleteMainMenuItem
	(
		@ItemID int,
		@ErrorStatus int OUTPUT
	)

AS

DECLARE @Recordsleft int
SET @Recordsleft = 0


DECLARE @Table_ToBeDeleted TABLE (ItemID int)

INSERT INTO @Table_ToBeDeleted (ItemID)
VALUES (@ItemID)

SET @Recordsleft = (SELECT COUNT(*) FROM MainMenuItems WHERE ParentID IN (SELECT ItemID FROM @Table_ToBeDeleted))

WHILE(@Recordsleft > 0)
	BEGIN

		INSERT INTO @Table_ToBeDeleted (ItemID)
		SELECT ItemID	FROM MainMenuItems 
						WHERE ParentID IN (SELECT ItemID FROM @Table_ToBeDeleted)
						AND ItemID NOT IN (SELECT ItemID FROM @Table_ToBeDeleted)

		SET @Recordsleft = (SELECT COUNT(*)	FROM MainMenuItems 
						WHERE ParentID IN (SELECT ItemID FROM @Table_ToBeDeleted)
						AND ItemID NOT IN (SELECT ItemID FROM @Table_ToBeDeleted))
		
	END



	DELETE FROM MainMenuItems WHERE ItemID IN (SELECT ItemID FROM @Table_ToBeDeleted)

	SET @ErrorStatus = @@Error


GO

GRANT EXEC ON rpc_DeleteMainMenuItem TO PUBLIC

GO

