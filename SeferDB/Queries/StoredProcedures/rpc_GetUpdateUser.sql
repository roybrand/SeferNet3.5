IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetUpdateUser')
	BEGIN
		DROP  Procedure  rpc_GetUpdateUser
	END
GO

CREATE Proc [dbo].[rpc_GetUpdateUser]
	@updateUserSelected VARCHAR(max)
As

SELECT Users.UserID as UserID, (Users.FirstName + ' ' + Users.LastName) as UserName,
	CASE IsNull(selectedUsers.ItemID, '0') WHEN '0' THEN 0 ELSE 1 END as 'selected'  
FROM Users
LEFT JOIN (	SELECT ItemID FROM dbo.rfn_SplitStringValuesToStr(@updateUserSelected)) As selectedUsers 
	ON Users.UserID = selectedUsers.ItemID

GO

GRANT EXEC ON dbo.rpc_GetUpdateUser TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetUpdateUser TO [clalit\IntranetDev]
GO
