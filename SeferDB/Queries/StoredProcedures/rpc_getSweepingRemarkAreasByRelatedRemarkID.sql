IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getSweepingRemarkAreasByRelatedRemarkID')
	BEGIN
		DROP  Procedure  rpc_getSweepingRemarkAreasByRelatedRemarkID
	END

GO

CREATE Procedure dbo.rpc_getSweepingRemarkAreasByRelatedRemarkID
(
	@DeptRemarkID int 
)

AS
--1)
SELECT DISTINCT 
r.districtCode
, districtName 
FROM dbo.SweepingDeptRemarks_District as r
INNER JOIN View_AllDistricts ON r.districtCode = View_AllDistricts.districtCode
WHERE r.DeptRemarkID = @DeptRemarkID
-- 2)
SELECT DISTINCT 
r.administrationCode
, 'AdministrationName' = isNull(AdministrationName,'') 
FROM dbo.SweepingDeptRemarks_Admin as r
LEFT JOIN View_AllAdministrations ON r.administrationCode = View_AllAdministrations.AdministrationCode
WHERE r.DeptRemarkID = @DeptRemarkID
-- 3)
SELECT DISTINCT 
r.UnitTypeCode as 'UnitTypeCode'
, 'UnitTypeName' = isNull(UnitTypeName,'') 
,'SubUnitTypeCode' = isNull(RSUT.SubUnitTypeCode, -1) 
FROM dbo.SweepingDeptRemarks_UnitType as r
left join dbo.SweepingDeptRemarks_SubUnitType as RSUT on r.DeptRemarkID = RSUT.DeptRemarkID
LEFT JOIN UnitType ON r.UnitTypeCode = UnitType.UnitTypeCode
WHERE r.DeptRemarkID = @DeptRemarkID
-- 4)
SELECT DISTINCT 
'populationSector' =  r.populationSectorCode
, 'PopulationSectorDescription' = isNull(PopulationSectorDescription,'') 
FROM dbo.SweepingDeptRemarks_PopulationSector as r
LEFT JOIN PopulationSectors ON r.populationSectorCode = PopulationSectors.PopulationSectorID
WHERE r.DeptRemarkID = @DeptRemarkID
--5)
SELECT DISTINCT 
r.ExcludedDeptCode as 'ExcludedDeptCode'
, Dept.deptName as 'ExcludedDeptName'
FROM dbo.SweepingDeptRemarks_Exclusions as r
INNER JOIN Dept ON r.ExcludedDeptCode = Dept.DeptCode
WHERE r.DeptRemarkID = @DeptRemarkID
GO

GRANT EXEC ON dbo.rpc_getSweepingRemarkAreasByRelatedRemarkID TO PUBLIC

GO

