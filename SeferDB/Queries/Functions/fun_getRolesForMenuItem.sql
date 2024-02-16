IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getRolesForMenuItem')
	BEGIN
		DROP  FUNCTION  fun_getRolesForMenuItem
	END

GO

CREATE FUNCTION [dbo].fun_getRolesForMenuItem(@itemID INT)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strRoles VARCHAR(100)
	SET @strRoles = ''

	SELECT @strRoles = @strRoles + CONVERT(VARCHAR,RoleID) + ','
	FROM MainMenuItemsPermissions mmip 
	WHERE MenuItemID = @itemID
	
	
	IF (LEN(@strRoles) = 0)
		RETURN NULL
	ELSE	
		SET @strRoles = SUBSTRING(@strRoles, 1, LEN(@strRoles) -1)

	RETURN( @strRoles )
	
END

GO 

grant exec on fun_getRolesForMenuItem to public 
GO
