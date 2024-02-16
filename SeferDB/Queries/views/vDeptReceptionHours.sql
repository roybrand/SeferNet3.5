
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vDeptReceptionHours')
	BEGIN
		DROP  view  vDeptReceptionHours
	END

GO


create VIEW [dbo].[vDeptReceptionHours]
AS
SELECT     TOP (100) PERCENT dbo.DeptReception.receptionID, dbo.DeptReception.deptCode, dbo.DeptReception.receptionDay, dbo.DeptReception.openingHour, 
                      dbo.DeptReception.closingHour, dbo.fun_getDeptReceptionRemarksValid(dbo.DeptReception.receptionID) AS RemarkText, 
                      CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN '24 ' WHEN '01:00' THEN '24 ' WHEN '00:00' THEN '24 ' ELSE openingHour
                       + '-' END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN '24 ' WHEN '01:00' THEN '24 ' WHEN '00:00' THEN '24 ' ELSE openingHour + '-'
                       END ELSE openingHour + '-' END + CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN
                       '00:00' THEN 'שעות' ELSE closingHour END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00'
                       THEN 'שעות' ELSE closingHour END ELSE closingHour END + CASE dbo.fun_getDeptReceptionRemarksValid(receptionID) 
                      WHEN '' THEN '' ELSE '<br>' + dbo.fun_getDeptReceptionRemarksValid(receptionID) END AS 'openingHourText',
                      DeptReception.ReceptionHoursTypeID,
                      dRH.ReceptionTypeDescription
FROM         dbo.DeptReception INNER JOIN
                      dbo.DIC_ReceptionDays ON dbo.DeptReception.receptionDay = dbo.DIC_ReceptionDays.ReceptionDayCode AND 
                      (dbo.DeptReception.validFrom IS NOT NULL AND dbo.DeptReception.validTo IS NULL AND GETDATE() >= dbo.DeptReception.validFrom OR
                      dbo.DeptReception.validFrom IS NULL AND dbo.DeptReception.validTo IS NOT NULL AND dbo.DeptReception.validTo >= GETDATE() OR
                      dbo.DeptReception.validFrom IS NOT NULL AND dbo.DeptReception.validTo IS NOT NULL AND GETDATE() >= dbo.DeptReception.validFrom AND 
                      dbo.DeptReception.validTo >= GETDATE() OR
                      dbo.DeptReception.validFrom IS NULL AND dbo.DeptReception.validTo IS NULL)
                      join DIC_ReceptionHoursTypes dRH on DeptReception.ReceptionHoursTypeID = dRH.ReceptionHoursTypeID
ORDER BY dbo.DeptReception.receptionDay, dbo.DeptReception.openingHour


GO


  
grant select on vDeptReceptionHours to public 

go