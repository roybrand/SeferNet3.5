IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DeptReception]'))
DROP VIEW [dbo].[v_DeptReception]
GO

CREATE view [dbo].[v_DeptReception]
as 
select distinct  deptER.receptionID, deptER.deptCode, 
deptER.receptionDay,deptER.openingHour,deptER.closingHour,deptER.validFrom,deptER.validTo , 
deptERRemarks.RemarkID as RemarkID, deptERRemarks.RemarkText ,
Dept.deptName ,Dept.cityCode,cityName,deptER.ReceptionHoursTypeID

from DeptReception as deptER
left join DeptReceptionRemarks as deptERRemarks  on deptER.receptionID = deptERRemarks.ReceptionID
inner join  Dept on deptER.deptCode = Dept.deptCode 
inner join  Cities on Dept.cityCode = Cities.cityCode   
--where deptER.deptCode=43300

GO

grant select on v_DeptReception to public 
go


