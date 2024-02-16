IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertUserPermission')
	BEGIN
		DROP  Procedure  rpc_insertUserPermission
	END

GO

CREATE Procedure [dbo].[rpc_insertUserPermission]
(
	@UserID bigint,
	@permissionType int,
	@DeptCode int,
	@ErrorReport tinyint,
	@TrackingNewClinic tinyint,
	@ReportRemarksChange tinyint,
	@UpdateUserName varchar(50)
)

AS

BEGIN TRY
	IF NOT EXISTS
		(SELECT * FROM UserPermissions WHERE UserID = @UserID AND PermissionType = @permissionType AND DeptCode = @DeptCode)
		BEGIN	
			INSERT INTO UserPermissions
			(UserID, PermissionType, DeptCode, ErrorReport, TrackingNewClinic, UpdateUser, TrackingRemarkChanges)
			VALUES
			(@UserID, @permissionType, @DeptCode, @ErrorReport, @TrackingNewClinic, @UpdateUserName, @ReportRemarksChange)
		END
	ELSE
		BEGIN
			UPDATE UserPermissions
			SET ErrorReport = @ErrorReport, TrackingNewClinic = @TrackingNewClinic,
				UpdateUser = @UpdateUserName, TrackingRemarkChanges = @ReportRemarksChange
			WHERE UserID = @UserID 
			AND PermissionType = @permissionType 
			AND DeptCode = @DeptCode
		END
END TRY 
BEGIN CATCH
	Exec master.dbo.sp_RethrowError
END CATCH	

GO

GRANT EXEC ON dbo.rpc_insertUserPermission TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_insertUserPermission TO [clalit\IntranetDev]
GO

