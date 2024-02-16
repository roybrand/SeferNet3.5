IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUserMailesToSendReportAboutClinicRemark')
	BEGIN
		DROP  Procedure  rpc_getUserMailesToSendReportAboutClinicRemark
	END

GO

CREATE Procedure [dbo].[rpc_getUserMailesToSendReportAboutClinicRemark]
	
	@DeptCode int
	
AS
DECLARE @EmailList varchar(500) = ''
SELECT @EmailList = @EmailList + Users.Email + ';'
FROM Users
WHERE EXISTS
(SELECT * FROM UserPermissions
WHERE UserPermissions.UserID = Users.UserID
AND UserPermissions.PermissionType = 1
AND UserPermissions.TrackingRemarkChanges = 1
AND EXISTS
	(SELECT * FROM Dept WHERE deptCode = @DeptCode AND Dept.districtCode = UserPermissions.deptCode)
)

SELECT @EmailList as EmailList

GO

GRANT EXEC ON dbo.rpc_getUserMailesToSendReportAboutClinicRemark TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getUserMailesToSendReportAboutClinicRemark TO [clalit\IntranetDev]
GO