IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUserPermissions')
	BEGIN
		DROP  Procedure  rpc_getUserPermissions
	END
GO

CREATE Procedure dbo.rpc_getUserPermissions
(
	@UserID bigint
)

AS

select 
UserID,
PermissionType,
permissionDescription,
UserPermissions.deptCode,
dept.deptName,
ErrorReport,
CASE(IsNull(ErrorReport,0)) WHEN 0 THEN 'לא' ELSE 'כן' END as 'ErrorReportDescription',
TrackingNewClinic,
CASE(IsNull(TrackingNewClinic,0)) WHEN 0 THEN 'לא' ELSE 'כן' END as 'TrackingNewCliniDescription',
TrackingRemarkChanges,
CASE(IsNull(TrackingRemarkChanges,0)) WHEN 0 THEN 'לא' ELSE 'כן' END as 'TrackingRemarkChangesDescription'

from UserPermissions
inner join PermissionTypes 
	on UserPermissions.permissionType = PermissionTypes.permissionCode
left join Dept
	on UserPermissions.DeptCode = Dept.DeptCode
where UserID = @UserID

GO

GRANT EXEC ON dbo.rpc_insertUserPermission TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_insertUserPermission TO [clalit\IntranetDev]
GO


