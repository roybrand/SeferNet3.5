IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMailToList')
	BEGIN
		DROP  Procedure  rpc_GetMailToList
	END

GO

CREATE Procedure dbo.rpc_GetMailToList
(	
	@employeeID BIGINT,
	@deptCode INT,	
	@email VARCHAR(1000) OUTPUT
	
)

AS

DECLARE @districtCode INT
SET @email = ''

IF (@employeeID IS NOT NULL AND @employeeID <> 0)
	SELECT @districtCode = PrimaryDistrict
	FROM Employee
	WHERE EmployeeID = @employeeID

ELSE
	SELECT @districtCode = DistrictCode
	FROM Dept
	WHERE DeptCode = @deptCode


SELECT @email = @email + Email + ';'
FROM UserPermissions up
INNER JOIN Users u ON up.UserID = u.UserID
WHERE Email IS NOT NULL
AND ( (up.PermissionType = 1 AND ErrorReport = 1 AND DeptCode = @districtCode) 
	  OR (up.permissionType = 5 AND ErrorReport = 1))

GO


GRANT EXEC ON rpc_GetMailToList TO PUBLIC

GO


