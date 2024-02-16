 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetUnitRemarks')
	BEGIN
		DROP  Procedure  rpc_GetUnitRemarks
	END

GO

CREATE procedure [dbo].[rpc_GetUnitRemarks](@UnitCode int) 
as 
--Select RecordType, RemarkID, RemarkText, RemarkTemplate, ValidFrom, ValidTo, Internetdisplay, Deleted
--from 
--(
-- Sweeping Remarks

Select  distinct
1 as RecordType
, r.remarkID as RemarkID
, RemarkText as RemarkText
,case 
	when dgr.Remark  is not null then dgr.Remark  
	else '' 
	end as RemarkTemplate 
, convert(varchar, ValidFrom, 103) as ValidFrom
, convert(varchar, ValidTo , 103)  as ValidTo 
, displayInInternet as Internetdisplay
, 0 as Deleted
, IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager 

FROM View_DeptRemarks as r
join dbo.DIC_GeneralRemarks as dgr 
	on r.DicRemarkID = dgr.RemarkID
	and deptCode = @UnitCode
	and r.IsSharedRemark = 1
	and dbo.rfn_IsDatesCurrent(validFrom, validTo, getdate()) = 1

-- Current Remarks
Select  distinct
2 as RecordType
, r.remarkID as RemarkID
, RemarkText as RemarkText
,ShowOrder
,case 
	when dgr.Remark  is not null then dgr.Remark  
	else '' 
	end as RemarkTemplate 
, convert(varchar, ValidFrom, 103) as ValidFrom
, convert(varchar, ValidTo , 103)  as ValidTo 
, displayInInternet as Internetdisplay
, 0 as Deleted
, IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager 

FROM View_DeptRemarks as r
join dbo.DIC_GeneralRemarks as dgr 
	on r.DicRemarkID = dgr.RemarkID
	and deptCode = @UnitCode
	and r.IsSharedRemark = 0
	and dbo.rfn_IsDatesCurrent(validFrom, validTo, getdate()) = 1
	ORDER BY ShowOrder
-- Future Remarks
--union 
Select  3 as RecordType, r.DeptRemarkID as RemarkID, RemarkText as RemarkText, ShowOrder,
case 
	when dgr.Remark  is not null then dgr.Remark  
	else '' 
end as RemarkTemplate , convert(varchar, ValidFrom, 103) as ValidFrom, convert(varchar, ValidTo , 103)  as ValidTo ,
displayInInternet as Internetdisplay, 0 as Deleted, IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager 
from View_Remarks r 
left join dbo.DIC_GeneralRemarks as dgr 
on r.DicRemarkID = dgr.RemarkID 
Where ValidFrom > getdate() 
and DeptCode = @UnitCode  
--) as tblRemarks 
--order by RecordType , ValidFrom, ValidTo
 

-- Historic Remarks 
Select  4 as RecordType, r.DeptRemarkID as RemarkID, RemarkText as RemarkText, dbo.rfn_GetFotmatedRemark(RemarkText) as FormattedRemark,  
case 
	when dgr.Remark  is not null then dgr.Remark  
	else '' 
end as RemarkTemplate , ValidFrom, ValidTo, displayInInternet as Internetdisplay, 0 as Deleted, IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager 
from View_Remarks r  
left join dbo.DIC_GeneralRemarks as dgr 
on r.DicRemarkID = dgr.RemarkID 
Where DateDiff(day, ValidTo, getdate()) >= 1
and DeptCode = @UnitCode  


GO

grant exec on dbo.rpc_GetUnitRemarks to [clalit\webuser]

go


