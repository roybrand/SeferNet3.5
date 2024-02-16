IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeesCurrentStatus')
	BEGIN
		DROP  View View_DeptEmployeesCurrentStatus
	END
GO

CREATE VIEW [dbo].View_DeptEmployeesCurrentStatus
AS

select 
x_dept_Employee.deptCode
,x_dept_Employee.employeeID
,x_dept_Employee.AgreementType
,dbo.fun_GetDeptEmployeeCurrentStatus(x_dept_Employee.deptCode, x_dept_Employee.employeeID,x_dept_Employee.AgreementType) as status

from x_dept_Employee
	
GO

grant select on View_DeptEmployeesCurrentStatus to public 
GO

