IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vE2MUnitWorkHours]'))
	DROP VIEW [dbo].[vE2MUnitWorkHours]
GO

CREATE view [dbo].[vE2MUnitWorkHours]
as

       select dr.deptCode as 'DeptCode', ds.Simul228 as 'OldDeptCode'
       , d.deptName as 'DeptName', rd.ReceptionDayCode, rd.ReceptionDayName, dr.openingHour, dr.closingHour
       , isnull(drr.RemarkText, '') as Remark
       from DIC_ReceptionDays rd
       left join DeptReception dr on rd.ReceptionDayCode = dr.receptionDay
       left join DeptReceptionRemarks drr on dr.receptionID = drr.ReceptionID
       left join Dept d on dr.deptCode = d.deptCode
       left join deptSimul ds on d.deptCode = ds.deptCode
       where d.status = 1 AND d.IsCommunity = 1
       and  dr.ReceptionHoursTypeID = 1
       and (dr.validTo is null or dr.validTo >= getdate())
       and (dr.validFrom  <= getdate())

GO

GRANT SELECT ON [dbo].[vE2MUnitWorkHours] TO [public] AS [dbo]
GO