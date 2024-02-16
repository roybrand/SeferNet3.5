IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeServiceInDeptStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeServiceInDeptStatus
	END
GO


CREATE Procedure dbo.rpc_UpdateEmployeeServiceInDeptStatus

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpd'

SELECT x_Dept_Employee_Service.DeptEmployeeID, x_Dept_Employee_Service.ServiceCode, T.[status], x_Dept_Employee_Service.UpdateUser
INTO #tempTable
FROM x_Dept_Employee_Service   
INNER JOIN
	(SELECT
	DeptEmployeeID,
	ServiceCode,
	'Status' = IsNull((SELECT TOP 1 Status FROM DeptEmployeeServiceStatus
				WHERE x_Dept_Employee_Service.x_dept_employee_serviceID = DeptEmployeeServiceStatus.x_dept_employee_serviceID
				AND fromDate < @currentDate
				ORDER BY fromDate desc), x_Dept_Employee_Service.status),
	'updateUser' = IsNull((SELECT TOP 1 UpdateUser FROM DeptEmployeeServiceStatus
				WHERE x_Dept_Employee_Service.x_dept_employee_serviceID = DeptEmployeeServiceStatus.x_dept_employee_serviceID
				AND fromDate < @currentDate
				ORDER BY fromDate desc), '')			
	FROM x_Dept_Employee_Service) as T 
ON x_Dept_Employee_Service.DeptEmployeeID = T.DeptEmployeeID
AND x_Dept_Employee_Service.ServiceCode = T.ServiceCode
AND x_Dept_Employee_Service.status <> T.Status -- involve only those whose status has really changed


UPDATE x_Dept_Employee_Service 
SET status = T.Status,
	updateUser = LEFT(@autoUpdateUser  + ' ' + REPLACE(T.updateUser, @autoUpdateUser + ' ', ''), 50),
	updateDate = @currentDate
FROM x_Dept_Employee_Service xDES  
INNER JOIN #tempTable T
	ON xDES.DeptEmployeeID = T.DeptEmployeeID
	AND xDES.ServiceCode = T.ServiceCode 
	
	
DELETE deptEmployeeReception
FROM deptEmployeeReception der
INNER JOIN x_Dept_Employee xDE ON der.DeptEmployeeID = xDE.DeptEmployeeID
INNER JOIN #tempTable T ON xDE.DeptEmployeeID = T.DeptEmployeeID
INNER JOIN deptEmployeeReceptionServices ders ON T.ServiceCode = ders.ServiceCode
WHERE T.status = 0


DROP TABLE #tempTable
-------------------------------

GO

GRANT EXEC ON rpc_UpdateEmployeeServiceInDeptStatus TO PUBLIC

GO


