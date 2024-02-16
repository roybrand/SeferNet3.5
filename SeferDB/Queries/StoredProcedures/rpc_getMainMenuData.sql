IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getMainMenuData')
	BEGIN
		DROP  Procedure  rpc_getMainMenuData
	END

GO

CREATE Procedure [dbo].[rpc_getMainMenuData]
(
	@UserPermissions varchar(50), /* user's permissions comma delimited */
	@CurrentPageName varchar(100)
)
AS

DECLARE @Table_Base TABLE (ItemID int, Title varchar(100), Description varchar(100), Url varchar(200), ParentID int, OrderNumber int, HasRestrictions int)
DECLARE @Table_Parent TABLE (ItemID int, Title varchar(100), Description varchar(100), Url varchar(200), ParentID int, OrderNumber int, HasRestrictions int)
DECLARE @Table_Child TABLE (ItemID int, Title varchar(100), Description varchar(100), Url varchar(200), ParentID int, OrderNumber int, HasRestrictions int)
DECLARE @Recordsleft int
SET @Recordsleft = 0

SET @UserPermissions = IsNull(@UserPermissions, 0)

INSERT INTO @Table_Base (ItemID, Title, Description, Url, ParentID, OrderNumber, HasRestrictions)
SELECT DISTINCT ItemID, Title, Description, Url, ParentID, OrderNumber, 
'HasRestrictions' = CASE IsNull((SELECT COUNT(*) FROM MainMenuRestrictions WHERE MainMenuItemID = ItemID), 0) WHEN 0 THEN 0 ELSE 1 END 
FROM MainMenuItems mmi
INNER JOIN MainMenuItemsPermissions mmip ON mmi.ItemID = mmip.MenuItemID 
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@UserPermissions)) as sel ON mmip.RoleID = sel.IntField
WHERE (dbo.fun_ShowMenuItem(ItemID, @CurrentPageName) = 1 OR @CurrentPageName = '')
	/* 5 - permission of admin */
AND (sel.IntField is not null OR EXISTS (SELECT IntField FROM dbo.SplitString(@UserPermissions) WHERE IntField = 5) ) 
ORDER BY OrderNumber

INSERT INTO @Table_Parent (ItemID, Title, Description, Url, ParentID, OrderNumber, HasRestrictions)
SELECT DISTINCT ItemID, Title, Description, Url, ParentID, OrderNumber, HasRestrictions 
FROM @Table_Base WHERE ParentID is NULL

-- 1-st select
SELECT ItemID, Title, Description, Url, ParentID, HasRestrictions, OrderNumber FROM @Table_Parent Order by OrderNumber

SET @Recordsleft = (SELECT COUNT(*) FROM @Table_Base WHERE ParentID IN (SELECT ItemID FROM @Table_Parent) )

WHILE(@Recordsleft > 0)
	BEGIN
	
		DELETE @Table_Child
		
		INSERT INTO @Table_Child (ItemID, Title, Description, Url, ParentID, OrderNumber, HasRestrictions)
		SELECT ItemID, Title, Description, Url, ParentID, OrderNumber, HasRestrictions FROM @Table_Base	
																				 WHERE ParentID IN (SELECT ItemID FROM @Table_Parent) 
																				 ORDER BY OrderNumber
		
		-- (n + 1) select
		SELECT ItemID, Title, Description, Url, ParentID, HasRestrictions, OrderNumber FROM @Table_Child Order by OrderNumber
		
		DELETE @Table_Parent
		
		INSERT INTO @Table_Parent (ItemID, Title, Description, Url, ParentID, OrderNumber, HasRestrictions)
		SELECT ItemID, Title, Description, Url, ParentID, OrderNumber, HasRestrictions FROM @Table_Child
		
		SET @Recordsleft = (SELECT COUNT(*) FROM @Table_Base WHERE ParentID IN (SELECT ItemID FROM @Table_Parent) )
		
	END

GO

GRANT EXEC ON rpc_getMainMenuData TO PUBLIC

GO