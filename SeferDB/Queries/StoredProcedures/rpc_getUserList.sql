IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUserList')
	BEGIN
		DROP  Procedure  rpc_getUserList
	END

GO

CREATE Procedure [dbo].[rpc_getUserList]
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
		@TrackingNewClinic tinyint,
		@ReportRemarksChange tinyint = NULL
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
AND 
(@ReportRemarksChange is null OR UserPermissions.TrackingRemarkChanges = @ReportRemarksChange)

SELECT UpdateUser, convert(varchar, MAX(UpdateDate), 20) as MaxUpdateDate
INTO #UpdatesByUser
FROM LogChange
GROUP BY UpdateUser

SELECT Users.UserID, Users.UserName, Users.Domain,
FirstName+' '+LastName as UserDetails,
PhoneNumber, Email,
UserDescription, DefinedInAD, CASE DefinedInAD WHEN 0 THEN 'לא' ELSE 'כן' END as 'DefinedInAD_text'
,ISNULL(#UpdatesByUser.MaxUpdateDate, '') as MaxUpdateDate
FROM Users 
LEFT JOIN #UpdatesByUser ON Users.UserID = #UpdatesByUser.UpdateUser
WHERE UserID in (SELECT UserID FROM @UsersIDlist)

SELECT UserID, permissionType, PT.permissionDescription,  CASE ErrorReport WHEN 1 THEN 'כן' ELSE '' END as 'ErrorReport',
	IsNull(CAST( dept.deptCode as varchar(10)) , '') as 'deptCode' , IsNull(dept.deptName, '') as 'deptName',
	CASE TrackingNewClinic WHEN 1 THEN 'כן' ELSE '' END as 'TrackingNewClinic',
	CASE TrackingRemarkChanges WHEN 1 THEN 'כן' ELSE '' END as 'TrackingRemarkChanges'
FROM UserPermissions UP
INNER JOIN PermissionTypes PT ON UP.PermissionType = PT.permissionCode
LEFT JOIN dept ON UP.deptCode = dept.deptCode
WHERE UserID in (SELECT UserID FROM @UsersIDlist)
GO

GRANT EXEC ON dbo.rpc_insertUserPermission TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_insertUserPermission TO [clalit\IntranetDev]
GO


