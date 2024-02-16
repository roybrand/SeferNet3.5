IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptRemarks')
	BEGIN
		DROP  View View_DeptRemarks
	END
GO

CREATE  VIEW [dbo].[View_DeptRemarks]
AS

select Dept.deptCode
,R.[DeptRemarkID] as RemarkID
,R.[DicRemarkID]
,R.[RemarkText]
,R.DeptRemarkID as RelatedRemarkID -- temporary, todo.. 
,R.[districtCode]
,R.[administrationCode]
,R.deptCode as RemarkDeptCode
,case when R.deptCode = -1 then 1 else 0 end as IsSharedRemark 
,R.[UnitTypeCode]
,R.[populationSector]
,R.[validFrom]
,R.[validTo]
,R.[displayInInternet]
,R.[updateDate]
,R.[updateUser]
,R.[SubUnitTypeCode]
,R.[ShowOrder]
,R.[RemarkCategoryID]
from Dept
 join View_Remarks as R on Dept.deptCode = R.deptCode

union all	
	
select Dept.deptCode
,R.[DeptRemarkID] as RemarkID
,R.[DicRemarkID]
,R.[RemarkText]
,R.DeptRemarkID as RelatedRemarkID -- temporary, todo.. 
,R.[districtCode]
,R.[administrationCode]
,R.deptCode as RemarkDeptCode
,case when R.deptCode = -1 then 1 else 0 end as IsSharedRemark 
,R.[UnitTypeCode]
,R.[populationSector]
,R.[validFrom]
,R.[validTo]
,R.[displayInInternet]
,R.[updateDate]
,R.[updateUser]
,R.[SubUnitTypeCode]
,R.[ShowOrder]
,R.[RemarkCategoryID]
from Dept
 join View_Remarks as R 
	on R.deptCode = -1 
	and (R.districtCode = -1 or Dept.districtCode = R.districtCode) 
	and (R.administrationCode = -1 or Dept.administrationCode = R.administrationCode)
	and ( R.UnitTypeCode = -1 or Dept.typeUnitCode = R.UnitTypeCode)
	and (R.SubUnitTypeCode = -1 or Dept.subUnitTypeCode = R.SubUnitTypeCode)
	and ( R.populationSector = -1 or Dept.populationSectorCode = R.populationSector)
	and Dept.deptCode not in 
		(select ex.ExcludedDeptCode 
		from SweepingDeptRemarks_Exclusions as ex
		where ex.DeptRemarkID = R.DeptRemarkID)		
			
	
GO


grant select on View_DeptRemarks to public 

go