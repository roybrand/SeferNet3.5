IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeStatusInDept')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeStatusInDept
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeStatusInDept
(
		@employeeID BIGINT,
		@deptCode	INT
)

AS


SELECT es.Status,DIC_ActivityStatus.StatusDescription, FromDate,ToDate
FROM EmployeeStatusInDept es
INNER JOIN x_dept_employee xd ON es.deptEmployeeID = xd.DeptEmployeeID
INNER JOIN DIC_ActivityStatus ON es.Status = DIC_ActivityStatus.status
WHERE xd.EmployeeID = @employeeID AND xd.DeptCode = @deptCode
ORDER BY fromDate


GO


GRANT EXEC ON rpc_GetEmployeeStatusInDept TO PUBLIC

GO


