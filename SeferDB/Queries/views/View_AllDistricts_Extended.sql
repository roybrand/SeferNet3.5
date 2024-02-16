IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_AllDistricts_Extended')
	BEGIN
		DROP  view  View_AllDistricts_Extended
	END

GO

CREATE view [dbo].[View_AllDistricts_Extended] as

SELECT 
dept.deptCode as districtCode,
dept.deptName as districtName 
FROM dept
WHERE dept.typeUnitCode in (60, 65)
and dept.status = 1


GO


