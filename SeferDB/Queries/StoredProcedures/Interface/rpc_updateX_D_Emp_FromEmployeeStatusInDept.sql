
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateX_D_Emp_FromEmployeeStatusInDept')
	BEGIN
		DROP  Procedure  rpc_updateX_D_Emp_FromEmployeeStatusInDept
	END

GO

CREATE Procedure dbo.rpc_updateX_D_Emp_FromEmployeeStatusInDept

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

-- update all statuses that has been changed except "not active"
UPDATE x_Dept_Employee 
SET x_Dept_Employee.active = T.Status,
	x_Dept_Employee.updateUserName = @autoUpdateUser  + ' ' +  REPLACE(T.updateUser, @autoUpdateUser + ' ', ''),
	x_Dept_Employee.updateDate = @currentDate
FROM x_Dept_Employee 
INNER JOIN
	(SELECT
	x_Dept_Employee.employeeID,
	x_Dept_Employee.deptCode,
	x_Dept_Employee.updateUserName,
	'Status' = IsNull((SELECT TOP 1 Status 
				FROM EmployeeStatusInDept
				WHERE x_Dept_Employee.DeptEmployeeID = EmployeeStatusInDept.DeptEmployeeID
				AND fromDate < @currentDate
				ORDER BY fromDate desc), x_Dept_Employee.active),
	'updateUser' = IsNull((SELECT TOP 1 UpdateUser FROM EmployeeStatusInDept
				WHERE x_Dept_Employee.DeptEmployeeID = EmployeeStatusInDept.DeptEmployeeID
				AND fromDate < @currentDate
				ORDER BY fromDate desc), '')			
	FROM x_Dept_Employee) as T 
	ON x_Dept_Employee.employeeID = T.employeeID
	AND x_Dept_Employee.DeptCode = T.DeptCode AND x_Dept_Employee.Active <> T.Status AND T.Status <> 0


-- update not active status
SELECT DISTINCT DeptEmployeeID, UpdateUser
INTO #tempEmployeeTable
FROM EmployeeStatusInDept st
WHERE 
(
	(DATEDIFF(dd, FromDate, GetDate()) >= 0 AND DATEDIFF(dd, FromDate, GetDate()) <= 1)
		OR st.Status <> (select active from x_Dept_Employee xde 
						 where	xde.DeptEmployeeID = st.DeptEmployeeID
								and st.FromDate <= GETDATE())
		and (st.ToDate is null 
			 or (DATEDIFF(dd, st.FromDate, GetDate()) >= 0 and DATEDIFF(dd, st.ToDate, GetDate()) <= 0) 
			)
)
AND st.Status = 0


UPDATE x_Dept_Employee
SET active = 0,
	updateUserName = @autoUpdateUser  + ' ' + updateUserName,
	QueueOrder = NULL,
	updateDate = @currentDate
FROM x_Dept_Employee xde
INNER JOIN #tempEmployeeTable t
ON xde.DeptEmployeeID = t.DeptEmployeeID


-- delete all receptions for not active doctors
DELETE DeptEmployeeReception
FROM DeptEmployeeReception der
INNER JOIN #tempEmployeeTable t
ON der.DeptEmployeeID = t.DeptEmployeeID

-- delete all queue order methods for not active doctors
DELETE EmployeeQueueOrderMethod
FROM EmployeeQueueOrderMethod eqom
INNER JOIN #tempEmployeeTable t
ON eqom.DeptEmployeeID = t.DeptEmployeeID

-- delete positions for not active doctors
DELETE x_Dept_Employee_Position
FROM x_Dept_Employee_Position xDEP 
INNER JOIN x_Dept_Employee xDE
	ON xDEP.DeptEmployeeID = xDE.DeptEmployeeID
	AND xDE.active = 0

GO


GRANT EXEC ON rpc_updateX_D_Emp_FromEmployeeStatusInDept TO PUBLIC

GO

