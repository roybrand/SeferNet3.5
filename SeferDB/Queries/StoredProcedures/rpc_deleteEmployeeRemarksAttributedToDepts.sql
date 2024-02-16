IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeRemarksAttributedToDepts')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeRemarksAttributedToDepts
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeeRemarksAttributedToDepts
	(
		@EmployeeID int,
		@DeptCode int,
		@EmployeeRemarkIDs varchar(50)
	)

AS

DELETE x_Dept_Employee_EmployeeRemarks 
FROM x_Dept_Employee_EmployeeRemarks xder
INNER JOIN x_dept_employee xd ON xder.DeptemployeeID = xd.DeptEmployeeID
WHERE EmployeeRemarkID in (Select IntField from  dbo.SplitString(@EmployeeRemarkIDs))
AND xd.DeptCode = @DeptCode
AND xd.EmployeeID = @EmployeeID

GO

GRANT EXEC ON rpc_deleteEmployeeRemarksAttributedToDepts TO PUBLIC

GO

