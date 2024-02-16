IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_DeleteOldDeptAndEmployeeRemarks]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_DeleteOldDeptAndEmployeeRemarks]
GO


CREATE Procedure [dbo].[rpc_DeleteOldDeptAndEmployeeRemarks]

AS

	delete from DeptRemarks where validTo is not null
	and validTo < DATEADD(year, -1, GETDATE())

	delete from x_Dept_Employee_EmployeeRemarks
	where EmployeeRemarkID in(
	select EmployeeRemarkID from EmployeeRemarks 
	where validTo is not null
	and validTo < DATEADD(year, -1, GETDATE()))

	delete from EmployeeRemarks 
	where validTo is not null
	and validTo < DATEADD(year, -1, GETDATE())

GO


GRANT EXEC ON rpc_DeleteOldDeptAndEmployeeRemarks TO PUBLIC

GO

