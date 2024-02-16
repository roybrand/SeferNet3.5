IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_UpdateDeptStatus]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_UpdateDeptStatus]
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
				  ORDER BY fromDate desc), -1)

SET @CurrentStatus = @DeptStatus

UPDATE Dept
SET Dept.status = @DeptStatus,
Dept.updateUser = @UpdateUser
WHERE Dept.DeptCode = @DeptCode
AND @DeptStatus <> -1
AND Dept.status <> @DeptStatus

/*
DELETE FROM DeptReception
WHERE deptCode IN (SELECT DeptCode FROM dept WHERE dept.status = 0)

DELETE FROM x_Dept_Employee
WHERE deptCode IN (SELECT DeptCode FROM dept WHERE dept.status = 0)
*/
GO

GRANT EXEC ON [rpc_UpdateDeptStatus] TO PUBLIC

GO

