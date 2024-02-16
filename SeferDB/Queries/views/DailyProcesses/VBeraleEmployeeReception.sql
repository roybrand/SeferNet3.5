/*
2.	דוח שעות פעילות נותני שירות ביחידות:
הדוח יכלול נותני שירות פעילים מסקטור רופאים ביחידות מסוג:
מרכז בריאות האישה,מרכז בריאות הילד
,מרכז בריאות הנפש,מרפאה באוניברסיטה,מרפאה יועצת,מרפאה כפרית
,מרפאה משולבת,מרפאה ראשונית,מרפאת שיניים,רופא עצמאי
ובתנאי שאינם מסוג: צוות רפואי/מרפאה. יופיעו גם רופאים שאין להם שעות פעילות ביחידה
השדות:
שם יחידה, קוד סימול, ת.ז נותן שירות, רשיון רופא, תואר,
שם פרטי, שם משפחה, מגדר, תחום שירות,
יום, משעה, עד שעה, הערה לשעות,
טלפון נותן שירות ביחידה
----------------------------------------------------------

select * from UnitType u
where u.UnitTypeName in ('מרכז בריאות האישה','מרכז בריאות הילד'
,'מרכז בריאות הנפש','מרפאה באוניברסיטה','מרפאה יועצת','מרפאה כפרית'
,'מרפאה משולבת','מרפאה ראשונית','מרפאת שיניים','רופא עצמאי')

*/


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VBeraleEmployeeReception]'))
	DROP VIEW [dbo].VBeraleEmployeeReception
GO


CREATE VIEW [dbo].VBeraleEmployeeReception  
AS  
select d.deptCode as 'DeptCode',--'קוד סימול', 
		d.deptName as 'DeptName', --'שם יחידה'
		e.employeeID as 'EmployeeID',
		e.licenseNumber as 'LicenseNumber',
		ed.DegreeName as 'Degree',
		e.firstName as 'FirstName',
		e.lastName as 'LastName',
		g.sexDescription as 'Sex',
		s.ServiceDescription as 'Service',
		rd.ReceptionDayName as 'ReceptionDay', --'יום'
		der.openingHour as 'OpeningHour', -- 'משעה'
		CASE WHEN der.closingHour NOT like '%:%' AND der.closingHour is NOT null
				THEN LEFT(der.closingHour, 2) + ':' + RIGHT(der.closingHour, 2) 
				ELSE der.closingHour END as 'ClosingHour', -- 'עד שעה'
		drr.RemarkText as 'ReceptionRemark' -- 'הערה לשעות'		
from x_Dept_Employee xde
join Dept d
on xde.deptCode = d.deptCode
join Employee e
on xde.employeeID = e.employeeID
and e.IsMedicalTeam = 0 -- Not a medical team
left join DIC_EmployeeDegree ed
on e.degreeCode = ed.DegreeCode
left join DIC_Gender g
on e.sex = g.sex
left join x_Dept_Employee_Service xdes
on xde.DeptEmployeeID = xdes.DeptEmployeeID
left join deptEmployeeReception der
on der.DeptEmployeeID = xde.DeptEmployeeID
left join DIC_ReceptionDays rd
on der.receptionDay = rd.ReceptionDayCode
left join DeptEmployeeReceptionRemarks drr
on der.receptionID = drr.EmployeeReceptionID
left join deptEmployeeReceptionServices ders
on der.receptionID = ders.receptionID
and xdes.serviceCode = ders.serviceCode
left join Services s
on xdes.serviceCode = s.ServiceCode
where d.status = 1
and e.active = 1
and xde.active = 1
and e.EmployeeSectorCode in (2, 5, 7)
and d.typeUnitCode in (101, 102, 103, 104, 107, 111, 112, 301, 501, 502, 503)
and d.IsCommunity = 1
and xde.AgreementType in (1, 2)
--order by d.deptCode, xde.employeeID, der.receptionDay


GO

GRANT SELECT ON [dbo].VBeraleEmployeeReception TO [public] AS [dbo]
GO
