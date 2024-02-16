IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceRemarks')
	BEGIN
		DROP  Procedure  rpc_getServiceRemarks
	END

GO

CREATE Procedure dbo.rpc_getServiceRemarks
	(
		@DeptCode int,
		@ServiceCode int
	)

AS

SELECT
DESR.DeptEmployeeServiceRemarkID,
xDE.DeptCode,
ServiceCode,
RemarkId,
DESR.RemarkText,
displayInInternet,
ValidFrom,
'validTo' =  CASE CAST(isNull(validTo,0) as varchar(20)) WHEN 'Jan  1 1900 12:00AM' THEN 'ללא הגבלת' else CONVERT(varchar(20), validTo, 103) end
FROM DeptEmployeeServiceRemarks DESR
join x_Dept_Employee_Service xDES on DESR.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
WHERE xDE.DeptCode = @DeptCode
	AND ServiceCode = @ServiceCode

GO


GRANT EXEC ON rpc_getServiceRemarks TO PUBLIC

GO


