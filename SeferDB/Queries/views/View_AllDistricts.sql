IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_AllDistricts')
	BEGIN
		DROP  view  View_AllDistricts
	END

GO

CREATE view [dbo].[View_AllDistricts] as

select 
dept.deptCode as districtCode,
dept.deptName as districtName 
FROM dept
where dept.deptType = 1
and dept.status = 1


GO





