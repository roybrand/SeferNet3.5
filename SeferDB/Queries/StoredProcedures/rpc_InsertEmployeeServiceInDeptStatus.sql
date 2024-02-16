IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServiceInDeptStatus')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServiceInDeptStatus
	END

GO

CREATE Procedure dbo.rpc_InsertEmployeeServiceInDeptStatus
(
	@employeeID BIGINT,
	@deptCode INT, 
	@serviceCode INT, 
	@status SMALLINT, 
	@fromDate DATETIME, 
	@toDate DATETIME,
	@userName VARCHAR(30)
)

AS

INSERT INTO DeptEmployeeServiceStatus (Status, FromDate, ToDate, UpdateUser, UpdateDate, x_dept_employee_serviceID)
SELECT @status , @fromDate , @toDate , @userName , GETDATE(), x_dept_employee_serviceID
FROM x_dept_employee xd
INNER JOIN x_dept_employee_service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
WHERE xd.EmployeeID = @employeeID
AND xd.DeptCode = @deptCode
AND xdes.ServiceCode = @serviceCode


GO


GRANT EXEC ON rpc_InsertEmployeeServiceInDeptStatus TO PUBLIC

GO



