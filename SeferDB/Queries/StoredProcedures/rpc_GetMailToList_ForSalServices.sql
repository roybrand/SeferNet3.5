IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMailToList_ForSalServices')
	BEGIN
		DROP  Procedure  rpc_GetMailToList_ForSalServices
	END

GO

CREATE Procedure dbo.rpc_GetMailToList_ForSalServices
(	
	@email VARCHAR(1000) OUTPUT
)

AS

SET @email = '';

SELECT @email = @email + Email + ';'
FROM UserPermissions up
INNER JOIN Users u ON up.UserID = u.UserID
WHERE Email IS NOT NULL
AND ( (up.PermissionType = 9 OR up.PermissionType = 7) AND ErrorReport = 1 ) 
	  OR (up.permissionType = 5 AND ErrorReport = 1)


GO


GRANT EXEC ON rpc_GetMailToList_ForSalServices TO PUBLIC

GO


