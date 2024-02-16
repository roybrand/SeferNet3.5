 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptProfessions')
	BEGIN
		DROP  View View_DeptProfessions
	END
GO
 
create view [dbo].[View_DeptProfessions] as

Select distinct deptCode as DeptCode , vProfs.professionCode as ProfessionCode, vProfs.professionDescription  as ProfessionName  
from x_Dept_Employee as DeptEmployee
inner join EmployeeServices
		on DeptEmployee.EmployeeID = EmployeeServices.EmployeeID 
inner join View_Professions as vProfs 
on EmployeeServices.serviceCode  = vProfs.professionCode

GO