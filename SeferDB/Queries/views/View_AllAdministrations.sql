IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_AllAdministrations')
	BEGIN
		DROP  view  View_AllAdministrations
	END

GO

Create view [dbo].[View_AllAdministrations] as
select 
dept.deptCode as AdministrationCode,
dept.deptName as AdministrationName,
districtCode
from dept 
where deptType = 2

GO



