IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptEmployeeServiceRemark')
	BEGIN
		DROP  Procedure  rpc_GetDeptEmployeeServiceRemark
	END

GO

CREATE Procedure dbo.rpc_GetDeptEmployeeServiceRemark
(
	@serviceCode INT,
	@employeeID BIGINT,
	@deptCode INT
)

AS


SELECT RemarkID, DeptEmployeeServiceRemarks.RemarkText, ValidFrom, ValidTo, DisplayInInternet
FROM DeptEmployeeServiceRemarks
JOIN x_Dept_Employee_Service xDES ON DeptEmployeeServiceRemarks.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
JOIN x_Dept_Employee xDE ON xDES.DeptEmployeeID = xDE.DeptEmployeeID
WHERE xDES.ServiceCode = @serviceCode
AND xDE.DeptCode = @deptCode
AND xDE.EmployeeID = @employeeID


GO


GRANT EXEC ON rpc_GetDeptEmployeeServiceRemark TO PUBLIC

GO


