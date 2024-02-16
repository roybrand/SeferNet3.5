IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDistrictsExtended')
	BEGIN
		DROP  Procedure  rpc_getDistrictsExtended
	END

GO

CREATE Procedure dbo.rpc_getDistrictsExtended
	(
		@SelectedDistricts varchar(100),
		@unitCodes varchar(20),
		@permittedDistricts varchar(100)
	)

AS

SELECT deptCode, REPLACE(deptName, char(39), '`') as deptName, typeUnitCode,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END,
'isReadOnly' = CASE 
				WHEN @permittedDistricts is null OR  @permittedDistricts = '' THEN 0 
				ELSE CASE IsNull(per.IntField, 0) WHEN 0 THEN 1 ELSE 0 END END
INTO #tmpTable
FROM Dept
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedDistricts)) as sel ON dept.deptCode = sel.IntField
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@permittedDistricts)) as per ON dept.deptCode = per.IntField
WHERE typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))
AND status = 1
--AND (@permittedDistricts is null OR  @permittedDistricts = '' OR deptCode in (SELECT IntField FROM dbo.SplitString(@permittedDistricts)))
ORDER BY typeUnitCode desc,deptName


SELECT deptCode as districtCode,
deptName as districtName, selected, isReadOnly 
FROM #tmpTable
DROP TABLE #tmpTable


GO

GRANT EXEC ON rpc_getDistrictsExtended TO PUBLIC

GO