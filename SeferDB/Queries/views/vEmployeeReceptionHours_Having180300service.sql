IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vEmployeeReceptionHours_Having180300service]'))
DROP VIEW [dbo].[vEmployeeReceptionHours_Having180300service]
GO

create VIEW [dbo].[vEmployeeReceptionHours_Having180300service]
AS
SELECT     xd.deptCode, dER.receptionID, xd.EmployeeID, dER.receptionDay, dER.openingHour, dER.closingHour, 
                      dbo.DIC_ReceptionDays.ReceptionDayName, 
                      CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour
                       + '-' END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour + '-' END
                       ELSE openingHour + '-' END + CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN
                       '00:00' THEN 'שעות' ELSE closingHour END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00'
                       THEN 'שעות' ELSE closingHour END ELSE closingHour END + 
                       replace (('<br>' +
							isnull(STUFF((SELECT '#' + RemarkText 
								from DeptEmployeeReceptionRemarks
							WHERE EmployeeReceptionID = dER.receptionID
							AND (ValidFrom is null OR ValidFrom <= getdate())
							AND (ValidTo is null OR ValidTo >= getdate())
							for xml path('')),1,1,''), '&DelBR')), '<br>&DelBR', '')
                      AS OpeningHourText, 
                      dbo.Employee.EmployeeSectorCode,
                      S.ServiceDescription,
					  S.ServiceCode,
					  xd.AgreementType
FROM DeptEmployeeReception AS dER 
INNER JOIN dbo.DIC_ReceptionDays ON dER.receptionDay = dbo.DIC_ReceptionDays.ReceptionDayCode 
INNER JOIN x_Dept_Employee xd ON dER.DeptEmployeeID = xd.DeptEmployeeID
			AND xd.active <> 0
INNER JOIN dbo.Employee ON xd.EmployeeID = dbo.Employee.employeeID
INNER JOIN deptEmployeeReceptionServices dERS ON dER.receptionID = dERS.receptionID
INNER JOIN [Services] S ON dERS.serviceCode = S.ServiceCode
WHERE NOT EXISTS (	SELECT * FROM x_Dept_Employee_Service 
				WHERE x_Dept_Employee_Service.serviceCode = 180300
				AND x_Dept_Employee_Service.DeptEmployeeID = xd.DeptEmployeeID	) 
AND dER.validFrom <= GETDATE() AND (dER.validTo is null OR dER.validTo > GETDATE())

UNION

SELECT     xd.deptCode, dER.receptionID, xd.EmployeeID, dER.receptionDay, dER.openingHour, dER.closingHour, 
                      dbo.DIC_ReceptionDays.ReceptionDayName, 
                      CASE closingHour 
						WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour + '-' END 
                        WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour + '-' END
                        ELSE openingHour + '-' END + 
                        CASE closingHour 
							WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END 
							WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END 
							ELSE closingHour END + 
							replace (('<br>' +
							isnull(STUFF((SELECT '#' + RemarkText 
								from DeptEmployeeReceptionRemarks
							WHERE EmployeeReceptionID = dER.receptionID
							AND (ValidFrom is null OR ValidFrom <= getdate())
							AND (ValidTo is null OR ValidTo >= getdate())
							for xml path('')),1,1,''), '&DelBR')), '<br>&DelBR', '')
						AS OpeningHourText, 
                      dbo.Employee.EmployeeSectorCode,
						' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא:<br/>' +
						stuff((SELECT ',' + s2.serviceDescription    
							FROM x_Dept_Employee_Service xdes2
							INNER JOIN [Services] s2 ON xdes2.serviceCode = s2.serviceCode
							INNER JOIN x_Dept_Employee xd2 ON xdes2.DeptEmployeeID = xd2.DeptEmployeeID
							WHERE xd2.employeeID = xd.employeeID
							AND xd2.deptCode = xd.deptCode
							AND xdes2.Status = 1
							AND s2.serviceCode <> 180300 
							order by s2.serviceDescription
						for xml path('')),1,1,'')
						as ServiceDescription,
						180300	as ServiceCode,
					xd.AgreementType	

FROM DeptEmployeeReception AS dER 
INNER JOIN dbo.DIC_ReceptionDays ON dER.receptionDay = dbo.DIC_ReceptionDays.ReceptionDayCode 
INNER JOIN x_Dept_Employee xd ON dER.DeptEmployeeID = xd.DeptEmployeeID
			AND xd.active <> 0
INNER JOIN dbo.Employee ON xd.EmployeeID = dbo.Employee.employeeID
INNER JOIN deptEmployeeReceptionServices dERS ON dER.receptionID = dERS.receptionID
INNER JOIN [Services] S ON dERS.serviceCode = S.ServiceCode
WHERE EXISTS (	SELECT * FROM x_Dept_Employee_Service 
				WHERE x_Dept_Employee_Service.serviceCode = 180300
				AND x_Dept_Employee_Service.DeptEmployeeID = xd.DeptEmployeeID	)     
AND dER.validFrom <= GETDATE() AND (dER.validTo is null OR dER.validTo > GETDATE())                 

GO


grant select on vEmployeeReceptionHours_Having180300service to public 
go