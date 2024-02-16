IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeDeptsByRemarkID')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeDeptsByRemarkID
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeDeptsByRemarkID(@RemarkID int, @EmployeeID int) 
as 
Select 
case
	when er.AttributedToAllClinics  = 1 then 0 
	when xDept.DeptCode is not null then xDept.DeptCode
end as DeptCode
From EmployeeRemarks as er  
left join x_Dept_Employee_EmployeeRemarks as xDept 
on er.EmployeeRemarkID = xDept.EmployeeRemarkID
and er.EmployeeID = xDept.EmployeeID   
where er.EmployeeID = @EmployeeID 
and er.EmployeeRemarkID = @RemarkID

GO


GRANT EXEC ON rpc_GetEmployeeDeptsByRemarkID TO PUBLIC

GO


