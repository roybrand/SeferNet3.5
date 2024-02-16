IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeRemarks')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeRemarks
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeeRemarks
	(
		@EmployeeRemarkID int
	)

AS

DELETE FROM EmployeeRemarks
WHERE EmployeeRemarkID = @EmployeeRemarkID


DELETE x_Dept_Employee_EmployeeRemarks
WHERE EmployeeRemarkID = @EmployeeRemarkID


GO

GRANT EXEC ON rpc_deleteEmployeeRemarks TO PUBLIC

GO

