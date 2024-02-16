IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_Remarks')
	BEGIN
		DROP  View View_Remarks
	END
GO

CREATE VIEW [dbo].[View_Remarks]
AS

select 
DeptRemarks.[DeptRemarkID]
,DeptRemarks.deptCode
,DeptRemarks.[DicRemarkID]
,DeptRemarks.[RemarkText]
,DeptRemarks.ActiveFrom as validFrom
,DeptRemarks.[validTo]
,DeptRemarks.[displayInInternet]
,DeptRemarks.[updateDate]
,DeptRemarks.[updateUser]
,isnull(SweepingDeptRemarks_District.[districtCode], -1) as districtCode
,isnull(SweepingDeptRemarks_Admin.[administrationCode], -1) as administrationCode
,isnull(SweepingDeptRemarks_UnitType.[UnitTypeCode], -1) as UnitTypeCode
,isnull(SweepingDeptRemarks_SubUnitType.[SubUnitTypeCode], -1) as SubUnitTypeCode
,isnull(SweepingDeptRemarks_PopulationSector.[PopulationSectorCode], -1) as PopulationSector
,isnull(SweepingDeptRemarks_City.cityCode, -1) as cityCode
,isnull(SweepingDeptRemarks_Service.serviceCode, -1) as serviceCode
,DeptRemarks.[ShowOrder]
from DeptRemarks
left join SweepingDeptRemarks_District on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_District.DeptRemarkID
left join SweepingDeptRemarks_Admin	 on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_Admin.DeptRemarkID
left join SweepingDeptRemarks_PopulationSector on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_PopulationSector.DeptRemarkID
left join SweepingDeptRemarks_UnitType on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_UnitType.DeptRemarkID
left join SweepingDeptRemarks_SubUnitType on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_SubUnitType.DeptRemarkID

left join SweepingDeptRemarks_City on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_City.DeptRemarkID
left join SweepingDeptRemarks_Service on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_Service.DeptRemarkID

GO

