 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeDepts')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeDepts
	END

GO
 
create procedure [dbo].[rpc_GetEmployeeDepts](@EmployeeID int) 
as 
Select d.DeptCode as DeptCode,  d.DeptName as DeptName  
From x_Dept_Employee  as xDept 
inner join Dept as d 
on xDept.DeptCode = d.DeptCode  
where xDept.EmployeeID = @EmployeeID

GO

GRANT EXEC ON rpc_GetEmployeeDepts TO PUBLIC

GO