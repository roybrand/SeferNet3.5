IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUserPermittedDistrictsForReports')
	BEGIN
		DROP  Procedure  rpc_getUserPermittedDistrictsForReports
	END

GO

CREATE Procedure [dbo].[rpc_getUserPermittedDistrictsForReports]
	(
		@UserID bigint,
		@unitCodes varchar(20)
	)

AS

IF (@unitCodes = '')
	SET @unitCodes = '60,65'

select  districtCode, districtName from
(SELECT TOP 1000  
'districtCode' = dept.deptCode, 'districtName' = dept.deptName, dept.typeUnitCode
FROM dept
WHERE (deptCode IN (SELECT deptCode FROM UserPermissions WHERE UserID = @UserID AND PermissionType in(1, 6))
	OR 
	(SELECT COUNT(*) FROM UserPermissions WHERE UserID = @UserID AND PermissionType = 5) > 0)
AND typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))

ORDER BY typeUnitCode DESC, deptName 
) as temp

GO


GRANT EXEC ON rpc_getUserPermittedDistrictsForReports TO [clalit\webuser]
GO

GRANT EXEC ON rpc_getUserPermittedDistrictsForReports TO [clalit\IntranetDev]
GO

