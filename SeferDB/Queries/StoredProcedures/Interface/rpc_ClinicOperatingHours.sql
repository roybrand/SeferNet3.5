IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_ClinicOperatingHours]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_ClinicOperatingHours]
GO

CREATE Procedure [dbo].[rpc_ClinicOperatingHours]

AS
--DECLARE @tempTable table (deptCode varchar(10), receptionDay varchar(3), [openingHour_1] varchar(8), [closingHour_1] varchar(8), [openingHour_2] varchar(8),[closingHour_2] varchar(8))
select  deptCode, receptionDay 
       ,max([openingHour_1]) as [openingHour_1], max([closingHour_1]) as [closingHour_1]
       , isnull(max([openingHour_2]), '00:00:00') as [openingHour_2]
       , isnull(max([closingHour_2]), '00:00:00') as [closingHour_2]
from 
(
       select dr.deptCode, dr.receptionDay, dr.openingHour + ':00' as Hours--, dr.closingHour
              ,'openingHour' + '_' + convert(varchar(2),ROW_NUMBER() over(PARTITION BY dr.deptCode, dr.receptionDay 
                                                order by dr.deptCode ,dr.receptionDay, dr.openingHour)) as Nr
       from DeptReception dr
       join Dept d on dr.deptCode = d.deptCode
       left join DeptReceptionRemarks drr on dr.receptionID = drr.ReceptionID
       where GETDATE() between ISNULL(dr.validFrom,'1900-01-01') and ISNULL(dr.validTo,'2079-01-01')
       and d.status = 1 and d.IsCommunity = 1 
       and (drr.RemarkID is null or drr.RemarkID <> 72)
       and dr.receptionDay < 8
UNION
       select dr.deptCode, dr.receptionDay, dr.closingHour + ':00' as Hours
              ,'closingHour' + '_' + convert(varchar(2),ROW_NUMBER() over(PARTITION BY dr.deptCode, dr.receptionDay 
                                                order by dr.deptCode ,dr.receptionDay, dr.openingHour)) as Nr
       from DeptReception dr
       join Dept d on dr.deptCode = d.deptCode
       left join DeptReceptionRemarks drr on dr.receptionID = drr.ReceptionID
       where GETDATE() between ISNULL(dr.validFrom,'1900-01-01') and ISNULL(dr.validTo,'2079-01-01')
       and d.status = 1 and d.IsCommunity = 1
       and (drr.RemarkID is null or drr.RemarkID <> 72)
       and dr.receptionDay < 8
) a
pivot 
(max(Hours) for Nr in ([openingHour_1],[closingHour_1],[openingHour_2],[closingHour_2])
) AS PivotTable
group by deptCode, receptionDay
order by deptCode, receptionDay

GO

GRANT EXEC ON rpc_ClinicOperatingHours TO PUBLIC

GO
