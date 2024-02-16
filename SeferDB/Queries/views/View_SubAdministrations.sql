IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_SubAdministrations')
	BEGIN
		DROP  view  View_SubAdministrations
	END
GO 

create view [dbo].[View_SubAdministrations] as
SELECT 
deptCode as SubAdministrationCode, 
deptName as SubAdministrationName 
FROM dept
WHERE dept.deptCode in (SELECT subAdministrationCode FROM dept)

GO 