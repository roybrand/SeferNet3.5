IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeServiceInDeptStatus')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeServiceInDeptStatus
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeServiceInDeptStatus
(
	@employeeID  BIGINT,
	@deptCode	 INT,
	@serviceCode INT
)

AS


SELECT dess.Status, statusDescription, FromDate, ToDate
FROM DeptEmployeeServiceStatus dess
INNER JOIN DIC_ActivityStatus dic ON dess.Status = dic.Status
join x_Dept_Employee_Service xDES on dess.x_dept_employee_serviceID=xDES.x_Dept_Employee_ServiceID
join x_Dept_Employee xDE on xDES.DeptEmployeeID=xDE.DeptEmployeeID
WHERE xDE.EmployeeID = @employeeID
AND xDE.DeptCode = @deptCode
AND ServiceCode = @serviceCode
ORDER BY FromDate


GO


GRANT EXEC ON rpc_GetEmployeeServiceInDeptStatus TO PUBLIC

GO


