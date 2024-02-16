IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeStatus
	END

GO

CREATE Procedure dbo.rpc_UpdateEmployeeStatus

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

UPDATE Employee 
SET Employee.active = T2.Status,
Employee.updateUser = @autoUpdateUser + ' ' + REPLACE(T2.updateUser, @autoUpdateUser + ' ', ''),
Employee.updateDate = @currentDate
--select * 
FROM Employee INNER JOIN
	(SELECT 
		EmployeeID, 
		'Status' = IsNull((SELECT TOP 1 Status FROM EmployeeStatus
		WHERE EmployeeID = T1.EmployeeID
		AND fromDate < @currentDate
		ORDER BY fromDate desc), -1),
		'updateUser' = (SELECT TOP 1 updateUser FROM EmployeeStatus
		WHERE EmployeeID = T1.EmployeeID
		AND fromDate < @currentDate
		ORDER BY fromDate desc)
	FROM 
	(SELECT distinct EmployeeID
	FROM EmployeeStatus 
	WHERE fromDate < @currentDate) as T1
	) as T2 
ON Employee.employeeID = T2.EmployeeID 
AND Employee.active <> T2.Status -- involve only those whose status has really changed
AND T2.Status <> -1

DELETE FROM x_dept_employee
WHERE EmployeeID IN (SELECT employeeID FROM Employee WHERE Employee.active = 0)

GO

GRANT EXEC ON rpc_UpdateEmployeeStatus TO PUBLIC

GO

