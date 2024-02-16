IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getMainMenuItem')
	BEGIN
		DROP  Procedure  rpc_getMainMenuItem
	END

GO

CREATE Procedure dbo.rpc_getMainMenuItem
	(
		@ItemID int
	)


AS

	SELECT 
	MMI.ItemID,
	MMI.Title,
	MMI.Description,
	MMI.Url,
	'Roles' = dbo.fun_getRolesForMenuItem(@ItemID),
	MMI.ParentID,
	MMI.OrderNumber,
	'parentTitle' = IsNull(parMMI.Title, '')
	FROM MainMenuItems as MMI
	LEFT JOIN MainMenuItems as parMMI ON MMI.ParentID = parMMI.ItemID
	WHERE MMI.ItemID = @ItemID
	
	SELECT
	MainMenuRestrictionsID, MainMenuItemID, PageName
	FROM MainMenuRestrictions
	WHERE MainMenuItemID = @ItemID
	
GO

GRANT EXEC ON rpc_getMainMenuItem TO PUBLIC

GO

