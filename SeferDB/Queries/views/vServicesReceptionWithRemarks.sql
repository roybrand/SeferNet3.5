 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vServicesReceptionWithRemarks')
	BEGIN
		DROP  view  vServicesReceptionWithRemarks
	END

GO

CREATE VIEW [dbo].[vServicesReceptionWithRemarks]
AS
SELECT     TOP (100) PERCENT DERS.receptionID, xDE.deptCode, DERS.serviceCode, DER.receptionDay, DER.openingHour, DER.closingHour, 
                      CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour
                       + '-' END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour + '-' END
                       ELSE openingHour + '-' END + CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN
                       '00:00' THEN 'שעות' ELSE closingHour END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00'
                       THEN 'שעות' ELSE closingHour END ELSE closingHour END + CASE dbo.fun_GetDeptServiceHoursRemarks(DER.receptionID) 
                      WHEN '' THEN '' ELSE '<br>' + dbo.fun_GetDeptServiceHoursRemarks(DER.receptionID) END AS OpeningHourText,
					  Employee.IsMedicalTeam                      
FROM
	deptEmployeeReceptionServices DERS join [Services]
	on dERS.serviceCode = [Services].ServiceCode
	join deptEmployeeReception DER on DERS.receptionID = DER.receptionID
	join x_Dept_Employee xDE on DER.DeptEmployeeID = xDE.DeptEmployeeID
	join Employee on Employee.employeeID = xDE.employeeID
WHERE (DER.validFrom IS NOT NULL) AND (DER.validTo IS NULL) AND (GETDATE() >= DER.validFrom) OR
                      (DER.validFrom IS NULL) AND (DER.validTo IS NOT NULL) AND (DER.validTo >= GETDATE()) OR
                      (DER.validFrom IS NOT NULL) AND (DER.validTo IS NOT NULL) AND (GETDATE() >= DER.validFrom) AND (DER.validTo >= GETDATE()) OR
                      (DER.validFrom IS NULL) AND (DER.validTo IS NULL)
ORDER BY DERS.serviceCode, DER.receptionDay, DER.openingHour

GO

grant select on vServicesReceptionWithRemarks to public 
GO
  