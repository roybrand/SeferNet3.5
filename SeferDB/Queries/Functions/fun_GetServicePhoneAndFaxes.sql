IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_GetServicePhoneAndFaxes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_GetServicePhoneAndFaxes]
GO

CREATE FUNCTION [dbo].[fun_GetServicePhoneAndFaxes] 
(
	@DeptCode int,
	@employeeID bigint,
	@serviceCode int
)

RETURNS 
@ResultTable table
(
	phone varchar(15),
	phoneType int
)
as
begin
/* 
   The function select first from the service phones,
   if it's empty it select from the employeeDept phones,
   if it's empty it select from the dept phones.
   
*/

declare @tableServicePhones table
(
	phone varchar(15),
	phoneType int
	
)

declare @tableEmployeePhones table
(
	phone varchar(15),
	phoneType int
	
)

declare @tableDeptPhones table
(
	phone varchar(15),
	phoneType int
	
)

insert into @tableServicePhones
select
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType from x_Dept_Employee xDE
JOIN x_Dept_Employee_Service xDES
on xDE.DeptEmployeeID = xDES.DeptEmployeeID
JOIN EmployeeServicePhones ESP 
on xDES.x_Dept_Employee_ServiceID = ESP.x_Dept_Employee_ServiceID
where xDE.deptCode = @deptCode and xDE.employeeID = @employeeID
and xDES.serviceCode = @serviceCode


insert into @tableEmployeePhones
select
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType from DeptEmployeePhones DEP
JOIN x_Dept_Employee xDE
on DEP.DeptEmployeeID = xDE.DeptEmployeeID
where xDE.deptCode = @deptCode and xDE.employeeID = @employeeID
and not exists
(
	select phone from @tableServicePhones
)


insert into @tableDeptPhones
select
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType from DeptPhones
where deptCode = @deptCode
and not exists
(
	select phone from @tableServicePhones
)
and not exists
(
	select phone from @tableEmployeePhones
)



insert into @ResultTable
select * from @tableServicePhones
union
select * from @tableEmployeePhones
union
select * from @tableDeptPhones
order by phoneType
return
end






GO


