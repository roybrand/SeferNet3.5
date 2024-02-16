IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeRemarksForDept')
	BEGIN
		DROP  Procedure  rpc_getEmployeeRemarksForDept
	END

GO

CREATE Procedure dbo.rpc_getEmployeeRemarksForDept
	(
		@DeptCode int,
		@EmployeeID int
	)

AS

SELECT 
EmployeeRemarks.EmployeeRemarkID,
xd.DeptCode,
xd.EmployeeID,
EmployeeRemarks.RemarkText

FROM x_Dept_Employee_EmployeeRemarks as xder
INNER JOIN EmployeeRemarks ON xder.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
INNER JOIN x_Dept_Employee xd ON xder.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.DeptCode = @DeptCode
AND xd.EmployeeID = @EmployeeID
AND ValidFrom <= getdate()
AND (ValidTo is NULL OR ValidTo >= getdate())

GO

GRANT EXEC ON rpc_getEmployeeRemarksForDept TO PUBLIC

GO

