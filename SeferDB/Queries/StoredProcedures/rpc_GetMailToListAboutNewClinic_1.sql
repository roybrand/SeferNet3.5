IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMailToListAboutNewClinic')
	BEGIN
		DROP  Procedure  rpc_GetMailToListAboutNewClinic
	END

GO

CREATE Procedure dbo.rpc_GetMailToListAboutNewClinic
(	
	@deptCode INT,
	@email VARCHAR(1000) OUTPUT
)

AS

DECLARE @district int = 0
DECLARE @adminClinic int = 0
SELECT @district = Dept.districtCode, @adminClinic = Dept.administrationCode FROM Dept WHERE Dept.deptCode = @deptCode
SET @email = ''

SELECT @email = @email + U.Email + ';' FROM
(
SELECT DISTINCT UserID 
FROM UserPermissions up
WHERE (PermissionType = 1 OR PermissionType = 6) -- מחוז, הפקת דוחות
AND TrackingNewClinic = 1  
AND deptCode = @district

UNION

SELECT DISTINCT UserID 
FROM UserPermissions up
WHERE PermissionType = 2 -- מנהלת
AND TrackingNewClinic = 1
AND deptCode = @adminClinic 
) T
JOIN Users U ON T.UserID = U.UserID AND (U.Email is not null AND LEN(ltrim(U.Email)) > 1)

--print @mailList

GO


GRANT EXEC ON rpc_GetMailToListAboutNewClinic TO PUBLIC

GO
