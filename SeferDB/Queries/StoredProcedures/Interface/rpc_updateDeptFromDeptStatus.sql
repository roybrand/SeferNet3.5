IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_updateDeptFromDeptStatus]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_updateDeptFromDeptStatus]
GO

CREATE Procedure [dbo].[rpc_updateDeptFromDeptStatus]

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

UPDATE dept 
SET dept.status = T2.Status,
dept.updateUser = @autoUpdateUser + ' ' + REPLACE(T2.updateUser, @autoUpdateUser + ' ', ''),
dept.updateDate = @currentDate
FROM dept INNER JOIN
	(SELECT 
		deptCode, 
		'Status' = IsNull((SELECT TOP 1 Status FROM DeptStatus
		WHERE deptCode = T1.deptCode
		AND fromDate < @currentDate
		ORDER BY fromDate desc), -1),
		'updateUser' = (SELECT TOP 1 updateUser FROM DeptStatus
		WHERE deptCode = T1.deptCode
		AND fromDate < @currentDate
		ORDER BY fromDate desc)
	FROM 
	(SELECT distinct deptCode 
	FROM DeptStatus 
	WHERE fromDate < @currentDate) as T1
	) as T2 
ON dept.deptCode = T2.deptCode 
AND dept.status <> T2.Status -- involve only those whose status has really changed
AND T2.Status <> -1


DELETE FROM DeptReception
WHERE deptCode IN (SELECT DeptCode FROM dept WHERE dept.status = 0)

DELETE FROM x_Dept_Employee
WHERE deptCode IN (SELECT DeptCode FROM dept WHERE dept.status = 0)


GO
GRANT EXEC ON [rpc_updateDeptFromDeptStatus] TO PUBLIC

GO
