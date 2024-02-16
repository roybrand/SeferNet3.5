IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vEmployeeReceptionHours]'))
DROP VIEW [dbo].[vEmployeeReceptionHours]
GO

CREATE VIEW [dbo].[vEmployeeReceptionHours]
AS
SELECT     xd.deptCode, dER.receptionID, xd.EmployeeID, dER.receptionDay, dER.openingHour, dER.closingHour, 
                      dbo.DIC_ReceptionDays.ReceptionDayName, 
                      CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour
                       + '-' END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour + '-' END
                       ELSE openingHour + '-' END + CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN
                       '00:00' THEN 'שעות' ELSE closingHour END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00'
                       THEN 'שעות' ELSE closingHour END ELSE closingHour END + CASE dbo.fun_GetEmployeeRemarksForReception(dER.receptionID) 
                      WHEN '' THEN '' ELSE '<br>' + dbo.fun_GetEmployeeRemarksForReception(dER.receptionID) END AS OpeningHourText, 
                      dbo.Employee.EmployeeSectorCode,
                      S.ServiceDescription, S.ServiceCode, Employee.IsMedicalTeam
FROM DeptEmployeeReception AS dER 
INNER JOIN dbo.DIC_ReceptionDays ON dER.receptionDay = dbo.DIC_ReceptionDays.ReceptionDayCode 
INNER JOIN x_Dept_Employee xd ON dER.DeptEmployeeID = xd.DeptEmployeeID
			AND xd.active <> 0
INNER JOIN dbo.Employee ON xd.EmployeeID = dbo.Employee.employeeID
INNER JOIN deptEmployeeReceptionServices dERS ON dER.receptionID = dERS.receptionID
INNER JOIN [Services] S ON dERS.serviceCode = S.ServiceCode
WHERE dER.validFrom <= GETDATE() AND (dER.validTo is null OR dER.validTo > GETDATE())

GO

GRANT SELECT ON dbo.vEmployeeReceptionHours TO [clalit\webuser]
GO

GRANT SELECT ON dbo.vEmployeeReceptionHours TO [clalit\IntranetDev]
GO 