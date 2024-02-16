IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateDeptStatus
	END
GO

CREATE Procedure [dbo].[rpc_UpdateDeptStatus]
(
	@DeptCode int = null,
	@UpdateUser varchar(50),
	@CurrentStatus int OUTPUT
)
AS

DECLARE @currentDate datetime SET @currentDate = GETDATE()
DECLARE @DeptStatus int SET @DeptStatus = null

SET @DeptStatus = IsNull((SELECT TOP 1 Status FROM DeptStatus
				  WHERE deptCode = @DeptCode
				  AND fromDate <= @currentDate
				  ORDER BY fromDate desc, StatusID desc), -1)

SET @CurrentStatus = @DeptStatus

UPDATE Dept
SET Dept.status = @DeptStatus,
Dept.updateUser = @UpdateUser
WHERE Dept.DeptCode = @DeptCode
AND @DeptStatus <> -1
AND Dept.status <> @DeptStatus
GO

GRANT EXEC ON rpc_UpdateDeptStatus TO PUBLIC

GO