IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeRemarkDept')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeRemarkDept
	END

GO

CREATE Procedure rpc_DeleteEmployeeRemarkDept(
		@RemarkID int ,
		@EmployeeID int , 
		@DeptsCodes varchar(100), 
		@UpdateUser varchar(30)) 
AS

Delete from x_Dept_Employee_EmployeeRemarks
Where EmployeeRemarkID = @RemarkID 
and EmployeeID = @EmployeeID 
and DeptCode not in (Select ItemID from rfn_SplitStringValues(@DeptsCodes) as TblDepts) 

Update EmployeeRemarks
set AttributedToAllClinics =  0 
where EmployeeRemarkID = @RemarkID 
and EmployeeID = @EmployeeID
and 0 not in (Select ItemID from rfn_SplitStringValues(@DeptsCodes) as TblDepts)
GO


GRANT EXEC ON rpc_DeleteEmployeeRemarkDept TO PUBLIC

GO


