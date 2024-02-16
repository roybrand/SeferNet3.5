IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptEmployeeServiceRemark')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptEmployeeServiceRemark
	END

GO

CREATE Procedure dbo.rpc_DeleteDeptEmployeeServiceRemark
(
	@deptEmployeeID INT, 
	@serviceCode INT
)

AS

DECLARE @deptEmployeeServiceID INT

SET @deptEmployeeServiceID = (
							  SELECT x_dept_employee_serviceID
							  FROM x_dept_employee_service xdes
							  INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
							  WHERE xd.deptEmployeeID = @deptEmployeeID
							  AND xdes.serviceCode = @serviceCode
							 )

DELETE FROM DeptEmployeeServiceRemarks
WHERE DeptEmployeeServiceRemarks.x_dept_employee_serviceID = @deptEmployeeServiceID
						
UPDATE x_dept_employee_service			
SET DeptEmployeeServiceRemarkID = NULL
WHERE x_Dept_Employee_ServiceID = @deptEmployeeServiceID

GO


GRANT EXEC ON rpc_DeleteDeptEmployeeServiceRemark TO PUBLIC

GO





