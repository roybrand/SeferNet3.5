IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptNames')
	BEGIN
		DROP  Procedure  rpc_updateDeptNames
	END

GO

CREATE Procedure rpc_updateDeptNames

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

UPDATE dept 
SET dept.deptName = T2.deptName,
dept.updateUser = @autoUpdateUser + ' ' + REPLACE(T2.updateUser, @autoUpdateUser + ' ', ''),
dept.updateDate = @currentDate
FROM dept 
INNER JOIN
	(SELECT 
		deptCode, 
		'deptName' = IsNull((SELECT TOP 1 deptName FROM DeptNames
		WHERE deptCode = T1.deptCode
		AND fromDate < @currentDate
		ORDER BY fromDate desc), ''),
		'updateUser' = (SELECT TOP 1 updateUser FROM DeptNames
		WHERE deptCode = T1.deptCode
		AND fromDate < @currentDate
		ORDER BY fromDate desc)
	FROM 
	(SELECT distinct deptCode 
	FROM DeptNames 
	WHERE fromDate < @currentDate) as T1
	) as T2 
ON dept.deptCode = T2.deptCode 
AND dept.deptName <> T2.deptName -- involve only those whose name has changed
AND RTRIM(LTRIM(T2.deptName)) <> ''

GO

GRANT EXEC ON rpc_updateDeptNames TO PUBLIC

GO

