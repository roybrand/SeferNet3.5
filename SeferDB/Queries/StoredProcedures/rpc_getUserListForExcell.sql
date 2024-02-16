IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_getUserListForExcell]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_getUserListForExcell]
GO
CREATE Procedure [dbo].[rpc_getUserListForExcell]
	(
		@DistrictCode int,
		@PermissionType int,
		@UserName varchar(50),
		@FirstName varchar(50),
		@LastName varchar(50),
		@UserID bigint,
		@Domain varchar(50),
		@DefinedInAD tinyint,
		@ErrorReport tinyint,
		@TrackingNewClinic tinyint
	)

AS

DECLARE @UsersIDlist as TABLE (UserID bigint)

INSERT INTO @UsersIDlist
(UserID)
SELECT distinct Users.UserID
FROM Users
LEFT JOIN UserPermissions ON Users.UserID = UserPermissions.UserID
WHERE 
(
	(
		(PermissionType = @PermissionType OR @PermissionType = -1) 
		AND 
		(UserPermissions.DeptCode in (select deptCode from dept where districtCode = @DistrictCode)
			OR UserPermissions.deptCode = @DistrictCode 
			OR UserPermissions.deptCode = -1
			OR @DistrictCode = -1
		)		
	) 
	OR (PermissionType = -1 AND @DistrictCode = -1) -- display a new user with no permissions
)
AND 
(@UserName is null OR Users.UserName LIKE '%' + @UserName + '%')
AND 
(@FirstName is null OR @FirstName = '' OR Users.FirstName LIKE '%' + @FirstName + '%')
AND 
(@LastName is null OR @LastName = '' OR Users.LastName LIKE '%' + @LastName + '%')
AND 
(@UserID is null OR Users.UserID = @UserID)
AND 
(@Domain is null OR Users.Domain LIKE @Domain)
AND 
(@DefinedInAD is null OR Users.DefinedInAD = @DefinedInAD)
AND 
(@ErrorReport is null OR UserPermissions.ErrorReport = @ErrorReport)
AND 
(@TrackingNewClinic is null OR UserPermissions.TrackingNewClinic = @TrackingNewClinic)

SELECT UpdateUser, convert(varchar, MAX(UpdateDate), 20) as MaxUpdateDate
INTO #UpdatesByUser
FROM LogChange
GROUP BY UpdateUser

SELECT  LastName, FirstName, Users.UserName, ISNULL(UserDescription, '') as UserDescription,
ISNULL(Users.PhoneNumber, '') as PhoneNumber, Users.UserID,
Users.Email, CASE ErrorReport WHEN 1 THEN 'כן' ELSE '' END as ErrorReport,
CASE TrackingNewClinic WHEN 1 THEN 'כן' ELSE '' END as TrackingNewClinic,
ISNULL(#UpdatesByUser.MaxUpdateDate, '') as MaxUpdateDate,
PT.permissionDescription, 
IsNull(CAST( dept.deptCode as varchar(10)), '') as deptCode, IsNull(dept.deptName, '') as deptName

FROM Users
LEFT JOIN UserPermissions UP ON Users.UserID = UP.UserID
LEFT JOIN PermissionTypes PT ON UP.PermissionType = PT.permissionCode
LEFT JOIN dept ON UP.deptCode = dept.deptCode
LEFT JOIN #UpdatesByUser ON Users.UserID = #UpdatesByUser.UpdateUser
WHERE Users.UserID in (SELECT UserID FROM @UsersIDlist)
ORDER BY Users.LastName, Users.FirstName, UP.PermissionType, dept.deptCode
GO

GRANT EXEC ON rpc_getUserListForExcell TO [clalit\webuser]
GO

GRANT EXEC ON rpc_getUserListForExcell TO [clalit\IntranetDev]
GO