IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeRemarkDept')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeRemarkDept
	END

GO

Create procedure dbo.rpc_InsertEmployeeRemarkDept(@RemarkID int, @DeptCode varchar(100), @EmployeeID int, @UpdateUser  varchar(50)) 
as 


-- Set remark to specified dept code 
insert into x_Dept_Employee_EmployeeRemarks
(EmployeeRemarkID, DeptCode, EmployeeID, updateUser, updateDate) 
Select @RemarkID  as EmployeeRemarkID, TblDepts.ItemID as  DeptCode, @EmployeeID as DeptCode , @UpdateUser as updateUser, getdate() as updateDate 
From x_Dept_Employee_EmployeeRemarks, rfn_SplitStringValues(@DeptCode) as TblDepts 
Where TblDepts.ItemID > 0 
and not EXISTS (Select * 
			  From x_Dept_Employee_EmployeeRemarks 
			  Where x_Dept_Employee_EmployeeRemarks.DeptCode = TblDepts.ItemID
			  and EmployeeRemarkID = @RemarkID )

-- Set remark to all depts  - Diffrent table 
-- record should be exstis - run update not insert 
update EmployeeRemarks
set AttributedToAllClinics =  1 
where EmployeeRemarkID = @RemarkID 
and EmployeeID = @EmployeeID
and 0 in (Select ItemID from rfn_SplitStringValues(@DeptCode) as TblDepts)
GO


GRANT EXEC ON rpc_InsertEmployeeRemarkDept TO PUBLIC

GO


