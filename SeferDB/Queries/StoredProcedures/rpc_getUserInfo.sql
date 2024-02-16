IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUserInfo')
	BEGIN
		DROP  Procedure  rpc_getUserInfo
	END

GO

CREATE Procedure dbo.rpc_getUserInfo

	(
		@UserID bigint
	)

AS

-- User properties	
SELECT UserID, UserName, UserDescription, PhoneNumber, FirstName, LastName, Domain, Email, DefinedInAD
FROM Users
WHERE UserID = @UserID

-- User permissions	
SELECT permissionType, deptCode, ErrorReport, TrackingNewClinic
FROM UserPermissions
WHERE UserID =  @UserID
	
-- get all depts under user's districts	
SELECT 
dept.deptCode
FROM
(SELECT PermissionType,
		deptCode
		FROM UserPermissions
		where UserID= @UserID
		and permissionType = 1) as permissions
JOIN dept on dept.districtCode=permissions.deptCode

UNION

SELECT 
x_Dept_District.deptCode
FROM
(SELECT PermissionType,
		deptCode
		FROM UserPermissions
		where UserID= @UserID
		and permissionType = 1) as permissions
JOIN x_Dept_District ON x_Dept_District.districtCode = permissions.deptCode

UNION
 
-- get all depts under user's "minhalot"	
SELECT 
dept.deptCode
FROM
(SELECT PermissionType,
		deptCode
		FROM UserPermissions
		where UserID = @UserID
		and permissionType = 2) as permissions
JOIN dept on dept.AdministrationCode=permissions.deptCode

UNION

-- get all user's depts	
SELECT deptCode 
FROM UserPermissions
where UserID = @UserID

UNION

-- get all depts via subAdministrationCode ("kfifut nihulit")	
SELECT 
dept.deptCode

FROM
(SELECT PermissionType,
		deptCode
		FROM UserPermissions
		where UserID = @UserID
		and permissionType = 3) as permissions
JOIN dept on dept.subAdministrationCode = permissions.deptCode

order by deptCode

/* User's districts list */
DECLARE @District int SET @District = 0
DECLARE @Count int SET @Count = 0

SET @Count =
(
SELECT COUNT(*) FROM
	(	SELECT 
		dept.deptCode
		FROM dept WHERE deptCode IN
			(SELECT deptCode
					FROM UserPermissions
					WHERE UserID = @UserID
					and permissionType = 1)

		UNION 

		SELECT 
		dept.districtCode
		FROM dept WHERE deptCode IN
			(SELECT deptCode
					FROM UserPermissions
					WHERE UserID = @UserID
					and (permissionType = 2 OR permissionType = 3)) 
	) as T )

IF(@Count = 1)
	BEGIN 
		SET @District = 
		(
		SELECT 
		dept.deptCode
		FROM dept WHERE deptCode IN
			(SELECT deptCode
					FROM UserPermissions
					WHERE UserID = @UserID
					and permissionType = 1)

		UNION 

		SELECT 
		dept.districtCode
		FROM dept WHERE deptCode IN
			(SELECT deptCode
					FROM UserPermissions
					WHERE UserID = @UserID
					and (permissionType = 2 OR permissionType = 3)) 
		)
	END
ELSE
	BEGIN 
		SET @District = -1
	END

SELECT @District as districtCode
	
	
GO

GRANT EXEC ON rpc_getUserInfo TO PUBLIC

GO
