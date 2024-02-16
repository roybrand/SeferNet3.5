
/*-------------------------------------------------------------------------
Get all dept reception data for integration team
-------------------------------------------------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicReceptionHours]'))
	DROP VIEW [dbo].vIngr_ClinicReceptionHours
GO


CREATE VIEW [dbo].vIngr_ClinicReceptionHours
AS

select	dr.deptCode as ClinicCode, dr.receptionDay, drd.ReceptionDayName, 
		dr.ReceptionHoursTypeID, drh.ReceptionTypeDescription,
		dr.openingHour, dr.closingHour, dr.validFrom, dr.validTo, 
		drr.RemarkID, drr.RemarkText
from DeptReception dr
join DIC_ReceptionDays drd
on dr.receptionDay = drd.ReceptionDayCode
join DIC_ReceptionHoursTypes drh
on dr.ReceptionHoursTypeID = drh.ReceptionHoursTypeID
left join DeptReceptionRemarks drr
on dr.receptionID = drr.ReceptionID
where GETDATE() between ISNULL(dr.validFrom, '1900-01-01') and ISNULL(dr.validTo, '2079-01-01')

GO


GRANT SELECT ON [dbo].vIngr_ClinicReceptionHours TO [public] AS [dbo]
GO
