IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_ShowMenuItem')
	BEGIN
		DROP  FUNCTION  fun_ShowMenuItem
	END

GO

CREATE FUNCTION [dbo].[fun_ShowMenuItem]  
(
	@MainMenuItemID int,
	@PageName varchar(100)
)
RETURNS tinyint
AS
BEGIN
	DECLARE @Count int SET @Count = 0
	
	SET @Count = (SELECT COUNT(DISTINCT ItemID) FROM MainMenuItems MMI
				 LEFT JOIN MainMenuRestrictions MMR ON MMI.ItemID = MMR.MainMenuItemID 
				 WHERE MMI.ItemID = @MainMenuItemID
				 AND (MMR.PageName = @PageName
					OR
					(NOT EXISTS (SELECT * FROM MainMenuRestrictions WHERE MainMenuItemID = MMI.ItemID))					) 
				)
				
	RETURN (@Count)

END
GO

GRANT EXEC ON fun_ShowMenuItem TO PUBLIC
GO