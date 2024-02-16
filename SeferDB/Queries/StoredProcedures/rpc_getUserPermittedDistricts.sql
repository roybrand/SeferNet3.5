IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUserPermittedDistricts')
	BEGIN
		DROP  Procedure  rpc_getUserPermittedDistricts
	END

GO

CREATE Procedure dbo.rpc_getUserPermittedDistricts
	(
		@UserID bigint
	)

AS

SELECT 
'districtCode' = dept.deptCode, 'districtName' = dept.deptName
FROM dept
WHERE (deptCode IN (SELECT deptCode FROM UserPermissions WHERE UserID = @UserID AND PermissionType = 1)
       OR (exists (select PermissionType from UserPermissions WHERE UserID = @UserID AND PermissionType = 5)))
AND typeUnitCode = 65
ORDER BY deptName
GO

GRANT EXEC ON rpc_getUserPermittedDistricts TO PUBLIC

GO

