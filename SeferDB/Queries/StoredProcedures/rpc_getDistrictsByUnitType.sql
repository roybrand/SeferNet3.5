IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDistrictsByUnitType')
	BEGIN
		DROP  Procedure  rpc_getDistrictsByUnitType
	END

GO

CREATE Procedure dbo.rpc_getDistrictsByUnitType
	(
		@unitCodes varchar(20)
	)

AS

select deptCode,deptName,
'sort' = case typeUnitCode
		 when '60' then 1
		 when '65' then 0
		 end
into #tmpTable from Dept
	WHERE typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))
ORDER BY sort,deptName


select deptCode as districtCode,
deptName as districtName from #tmpTable
DROP TABLE #tmpTable



GO

GRANT EXEC ON dbo.rpc_getDistrictsByUnitType TO PUBLIC

GO





