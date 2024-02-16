
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_EmployeeReceptionHoursForShivuk]'))
	DROP VIEW [dbo].[vIngr_EmployeeReceptionHoursForShivuk]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
שליפת פרטי נותני שירות עבור שיווק
א.	שם רופא
ב.	קוד יחידה + שם מרפאה
ג.	כתובת (עיר, רחוב, מיקוד קואורדינאטות, הערה לכתובת)
ד.	מחוז
ה.	מקצוע
ו.	טלפון
ז.	שעות קבלה 
ח.	הערות לשעות
*/


CREATE VIEW [dbo].[vIngr_EmployeeReceptionHoursForShivuk]
AS
select doctorName, deptCode, deptName, 
				case when (AgreementTypeID in (1, 2)) then 'קהילה' 
					 when (AgreementTypeID in (3, 4)) then 'מושלם'
					 else 'בית חולים' end as AgreementTypeDescription,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				phone, ServiceDescription,
max([א-1]) as [א-1],max([א-2]) as [א-2],max([א-3]) as [א-3],max([ב-1]) as [ב-1],max([ב-2]) as [ב-2],max([ב-3]) as [ב-3],max([ג-1]) as [ג-1],max([ג-2]) as [ג-2],max([ג-3]) as [ג-3],max([ד-1]) as [ד-1],max([ד-2]) as [ד-2],max([ד-3]) as [ד-3],max([ה-1]) as [ה-1],max([ה-2]) as [ה-2],max([ה-3]) as [ה-3],max([ו-1]) as [ו-1],max([ו-2]) as [ו-2],max([ו-3]) as [ו-3],max([חג-1]) as [חג-1],max([חג-2]) as [חג-2],max([חוה"מ-1]) as [חוה"מ-1],max([חוה"מ-2]) as [חוה"מ-2],max([חוה"מ-3]) as [חוה"מ-3],max([ערב חג-1]) as [ערב חג-1],max([ערב חג-2]) as [ערב חג-2],max([ש-1]) as [ש-1],max([ש-2]) as [ש-2],
max([הערה-א-1]) as [הערה-א-1],max([הערה-א-2]) as [הערה-א-2],max([הערה-א-3]) as [הערה-א-3],max([הערה-ב-1]) as [הערה-ב-1],max([הערה-ב-2]) as [הערה-ב-2],max([הערה-ב-3]) as [הערה-ב-3],max([הערה-ג-1]) as [הערה-ג-1],max([הערה-ג-2]) as [הערה-ג-2],max([הערה-ג-3]) as [הערה-ג-3],max([הערה-ד-1]) as [הערה-ד-1],max([הערה-ד-2]) as [הערה-ד-2],max([הערה-ד-3]) as [הערה-ד-3],max([הערה-ה-1]) as [הערה-ה-1],max([הערה-ה-2]) as [הערה-ה-2],max([הערה-ה-3]) as [הערה-ה-3],max([הערה-ו-1]) as [הערה-ו-1],max([הערה-ו-2]) as [הערה-ו-2],max([הערה-ו-3]) as [הערה-ו-3],max([הערה-חג-1]) as [הערה-חג-1],max([הערה-חג-2]) as [הערה-חג-2],max([הערה-חוה"מ-1]) as [הערה-חוה"מ-1],max([הערה-חוה"מ-2]) as [הערה-חוה"מ-2],max([הערה-חוה"מ-3]) as [הערה-חוה"מ-3],max([הערה-ערב חג-1]) as [הערה-ערב חג-1],max([הערה-ערב חג-2]) as [הערה-ערב חג-2],max([הערה-ש-1]) as [הערה-ש-1],max([הערה-ש-2]) as [הערה-ש-2]
 from 
(select
				e.firstName+' '+e.lastName as doctorName, 
				d.deptCode, d.deptName, dag.AgreementTypeID, --AgreementTypeDescription,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
				dbo.fun_GetDeptEmployeePhonesOnly(e.employeeID, d.deptCode) as phone,
				p.ServiceDescription,
				er.receptionDay,
				er.openingHour ,
				er.closingHour ,
				[DIC_ReceptionDays].ReceptionDayName,
				openingHour + '-'+closingHour as Hours,
				derp.RemarkText,
row_number() over (partition by e.employeeID, d.deptCode,p.serviceCode ,er.receptionDay 
					order by er.openingHour ,er.closingHour )rn,
[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by e.employeeID, d.deptCode,p.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift ,
'הערה-'+[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by e.employeeID, d.deptCode,p.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift2
from Employee e
join x_Dept_Employee de
on de.employeeID = e.employeeID
join Dept d
on de.deptCode = d.deptCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
left join deptEmployeeReception er
on de.deptCode = er.deptCode  and er.EmployeeID = de.employeeID
left join [DIC_ReceptionDays]
on er.receptionDay = [DIC_ReceptionDays].ReceptionDayCode
left join deptEmployeeReceptionProfessions erp
on er.receptionID = erp.receptionID
join Services p
on erp.professionCode = p.ServiceCode
left join DIC_AgreementTypes dag
on de.AgreementType = dag.AgreementTypeID
left join DeptEmployeeReceptionRemarks derp
on derp.EmployeeReceptionID = er.receptionID
where d.status = 1
and e.active = 1
and de.active = 1
and e.EmployeeSectorCode = 7
and GETDATE() between ISNULL(er.validFrom,'1900-01-01') 
and ISNULL(er.validTo,'2079-01-01')  
) a
pivot 
(max(Hours) for shift in ([א-1],[א-2],[א-3],[ב-1],[ב-2],[ב-3],[ג-1],[ג-2],[ג-3],[ד-1],[ד-2],[ד-3],[ה-1],[ה-2],[ה-3],[ו-1],[ו-2],[ו-3],[ש-1],[ש-2],[חג-1],[חג-2],[חוה"מ-1],[חוה"מ-2],[חוה"מ-3],[ערב חג-1],[ערב חג-2])
) AS PivotTable1
pivot 
(max(RemarkText) for shift2 in ([הערה-א-1],[הערה-א-2],[הערה-א-3],[הערה-ב-1],[הערה-ב-2],[הערה-ב-3],[הערה-ג-1],[הערה-ג-2],[הערה-ג-3],[הערה-ד-1],[הערה-ד-2],[הערה-ד-3],[הערה-ה-1],[הערה-ה-2],[הערה-ה-3],[הערה-ו-1],[הערה-ו-2],[הערה-ו-3],[הערה-ש-1],[הערה-ש-2],[הערה-חג-1],[הערה-חג-2],[הערה-חוה"מ-1],[הערה-חוה"מ-2],[הערה-חוה"מ-3],[הערה-ערב חג-1],[הערה-ערב חג-2])
) AS PivotTable2
group by doctorName, deptCode, deptName, AgreementTypeID,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				phone, ServiceDescription
--order by rn desc
union
select doctorName, deptCode, deptName, 
				case when (AgreementTypeID in (1, 2)) then 'קהילה' 
					 when (AgreementTypeID in (3, 4)) then 'מושלם'
					 else 'בית חולים' end as AgreementTypeDescription,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				phone, serviceDescription,
max([א-1]) as [א-1],max([א-2]) as [א-2],max([א-3]) as [א-3],max([ב-1]) as [ב-1],max([ב-2]) as [ב-2],max([ב-3]) as [ב-3],max([ג-1]) as [ג-1],max([ג-2]) as [ג-2],max([ג-3]) as [ג-3],max([ד-1]) as [ד-1],max([ד-2]) as [ד-2],max([ד-3]) as [ד-3],max([ה-1]) as [ה-1],max([ה-2]) as [ה-2],max([ה-3]) as [ה-3],max([ו-1]) as [ו-1],max([ו-2]) as [ו-2],max([ו-3]) as [ו-3],max([חג-1]) as [חג-1],max([חג-2]) as [חג-2],max([חוה"מ-1]) as [חוה"מ-1],max([חוה"מ-2]) as [חוה"מ-2],max([חוה"מ-3]) as [חוה"מ-3],max([ערב חג-1]) as [ערב חג-1],max([ערב חג-2]) as [ערב חג-2],max([ש-1]) as [ש-1],max([ש-2]) as [ש-2],
max([הערה-א-1]) as [הערה-א-1],max([הערה-א-2]) as [הערה-א-2],max([הערה-א-3]) as [הערה-א-3],max([הערה-ב-1]) as [הערה-ב-1],max([הערה-ב-2]) as [הערה-ב-2],max([הערה-ב-3]) as [הערה-ב-3],max([הערה-ג-1]) as [הערה-ג-1],max([הערה-ג-2]) as [הערה-ג-2],max([הערה-ג-3]) as [הערה-ג-3],max([הערה-ד-1]) as [הערה-ד-1],max([הערה-ד-2]) as [הערה-ד-2],max([הערה-ד-3]) as [הערה-ד-3],max([הערה-ה-1]) as [הערה-ה-1],max([הערה-ה-2]) as [הערה-ה-2],max([הערה-ה-3]) as [הערה-ה-3],max([הערה-ו-1]) as [הערה-ו-1],max([הערה-ו-2]) as [הערה-ו-2],max([הערה-ו-3]) as [הערה-ו-3],max([הערה-חג-1]) as [הערה-חג-1],max([הערה-חג-2]) as [הערה-חג-2],max([הערה-חוה"מ-1]) as [הערה-חוה"מ-1],max([הערה-חוה"מ-2]) as [הערה-חוה"מ-2],max([הערה-חוה"מ-3]) as [הערה-חוה"מ-3],max([הערה-ערב חג-1]) as [הערה-ערב חג-1],max([הערה-ערב חג-2]) as [הערה-ערב חג-2],max([הערה-ש-1]) as [הערה-ש-1],max([הערה-ש-2]) as [הערה-ש-2]
 from 
(select
				e.firstName+' '+e.lastName as doctorName, 
				d.deptCode, d.deptName, dag.AgreementTypeID,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
				dbo.fun_GetDeptEmployeePhonesOnly(e.employeeID, d.deptCode) as phone,
				ser.serviceDescription,
				er.receptionDay,
				er.openingHour ,
				er.closingHour ,
				[DIC_ReceptionDays].ReceptionDayName,
				openingHour + '-'+closingHour as Hours,
				derp.RemarkText,
row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode ,er.receptionDay 
					order by er.openingHour ,er.closingHour )rn,
[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift ,
'הערה-'+[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by e.employeeID, d.deptCode,ser.serviceCode, er.receptionDay 
												order by er.openingHour ,er.closingHour ) as varchar(10)) shift2
from Employee e
join x_Dept_Employee de
on de.employeeID = e.employeeID
join Dept d
on de.deptCode = d.deptCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
left join deptEmployeeReception er
on de.deptCode = er.deptCode  and er.EmployeeID = de.employeeID
left join [DIC_ReceptionDays]
on er.receptionDay = [DIC_ReceptionDays].ReceptionDayCode
left join deptEmployeeReceptionServices ers
on er.receptionID = ers.receptionID
join Services ser
on ers.serviceCode = ser.serviceCode
left join DIC_AgreementTypes dag
on de.AgreementType = dag.AgreementTypeID
left join DeptEmployeeReceptionRemarks derp
on derp.EmployeeReceptionID = er.receptionID
where d.status = 1
and e.active = 1
and de.active = 1
and e.EmployeeSectorCode = 7
and GETDATE() between ISNULL(er.validFrom,'1900-01-01') 
and ISNULL(er.validTo,'2079-01-01')  
) a
pivot 
(max(Hours) for shift in ([א-1],[א-2],[א-3],[ב-1],[ב-2],[ב-3],[ג-1],[ג-2],[ג-3],[ד-1],[ד-2],[ד-3],[ה-1],[ה-2],[ה-3],[ו-1],[ו-2],[ו-3],[ש-1],[ש-2],[חג-1],[חג-2],[חוה"מ-1],[חוה"מ-2],[חוה"מ-3],[ערב חג-1],[ערב חג-2])
) AS PivotTable1
pivot 
(max(RemarkText) for shift2 in ([הערה-א-1],[הערה-א-2],[הערה-א-3],[הערה-ב-1],[הערה-ב-2],[הערה-ב-3],[הערה-ג-1],[הערה-ג-2],[הערה-ג-3],[הערה-ד-1],[הערה-ד-2],[הערה-ד-3],[הערה-ה-1],[הערה-ה-2],[הערה-ה-3],[הערה-ו-1],[הערה-ו-2],[הערה-ו-3],[הערה-ש-1],[הערה-ש-2],[הערה-חג-1],[הערה-חג-2],[הערה-חוה"מ-1],[הערה-חוה"מ-2],[הערה-חוה"מ-3],[הערה-ערב חג-1],[הערה-ערב חג-2])
) AS PivotTable2
group by doctorName, deptCode, deptName, AgreementTypeID,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				phone, serviceDescription
union 
select			e.firstName+' '+e.lastName as doctorName, 
				d.deptCode, d.deptName, 
				case when (AgreementTypeID in (1, 2)) then 'קהילה' 
					 when (AgreementTypeID in (3, 4)) then 'מושלם'
					 else 'בית חולים' end as AgreementTypeDescription,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
				dbo.fun_GetDeptEmployeePhonesOnly(e.employeeID, d.deptCode) as phone,
				prof.ServiceDescription,
'' as [א-1],'' as [א-2],'' as [א-3],'' as [ב-1],'' as [ב-2],'' as [ב-3],'' as [ג-1],'' as [ג-2],'' as [ג-3],'' as [ד-1],'' as [ד-2],'' as [ד-3],'' as [ה-1],'' as [ה-2],'' as [ה-3],'' as [ו-1],'' as [ו-2],'' as [ו-3],
'' as [חג-1],'' as [חג-2], '' as [חוה"מ-1],'' as [חוה"מ-2],'' as [חוה"מ-3],'' as [ערב חג-1],'' as [ערב חג-2],'' as [ש-1],'' as [ש-2],
'' as [הערה-א-1],'' as [הערה-א-2],'' as [הערה-א-3],'' as [הערה-ב-1],'' as [הערה-ב-2],'' as [הערה-ב-3],'' as [הערה-ג-1],'' as [הערה-ג-2],'' as [הערה-ג-3],'' as [הערה-ד-1],'' as [הערה-ד-2],'' as [הערה-ד-3],'' as [הערה-ה-1],'' as [הערה-ה-2],'' as [הערה-ה-3],'' as [הערה-ו-1],'' as [הערה-ו-2],'' as [הערה-ו-3],'' as [הערה-חג-1],'' as [הערה-חג-2],'' as [הערה-חוה"מ-1],'' as [הערה-חוה"מ-2],'' as [הערה-חוה"מ-3],'' as [הערה-ערב חג-1],'' as [הערה-ערב חג-2],'' as [הערה-ש-1],'' as [הערה-ש-2]
from Employee e
join x_Dept_Employee de
on de.employeeID = e.employeeID
join Dept d
on de.deptCode = d.deptCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
join x_Dept_Employee_Profession dep
on de.deptCode = dep.deptCode  and dep.employeeID = de.employeeID
join Services prof
on dep.professionCode = prof.ServiceCode
left join DIC_AgreementTypes dag
on de.AgreementType = dag.AgreementTypeID
where d.status = 1
and e.active = 1
and de.active = 1
and e.EmployeeSectorCode = 7
and dep.professionCode not in (select professionCode
								from deptEmployeeReceptionProfessions rp1 
								left join deptEmployeeReception er1
								on er1.receptionID = rp1.receptionID
								where er1.deptCode = d.deptCode
								and er1.EmployeeID = e.employeeID)
union 
select			e.firstName+' '+e.lastName as doctorName, 
				d.deptCode, d.deptName, 
				case when (AgreementTypeID in (1, 2)) then 'קהילה' 
					 when (AgreementTypeID in (3, 4)) then 'מושלם'
					 else 'בית חולים' end as AgreementTypeDescription,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
				dbo.fun_GetDeptEmployeePhonesOnly(e.employeeID, d.deptCode) as phone,
				ser.serviceDescription,
'' as [א-1],'' as [א-2],'' as [א-3],'' as [ב-1],'' as [ב-2],'' as [ב-3],'' as [ג-1],'' as [ג-2],'' as [ג-3],'' as [ד-1],'' as [ד-2],'' as [ד-3],'' as [ה-1],'' as [ה-2],'' as [ה-3],'' as [ו-1],'' as [ו-2],'' as [ו-3],
'' as [חג-1],'' as [חג-2], '' as [חוה"מ-1],'' as [חוה"מ-2],'' as [חוה"מ-3],'' as [ערב חג-1],'' as [ערב חג-2],'' as [ש-1],'' as [ש-2],
'' as [הערה-א-1],'' as [הערה-א-2],'' as [הערה-א-3],'' as [הערה-ב-1],'' as [הערה-ב-2],'' as [הערה-ב-3],'' as [הערה-ג-1],'' as [הערה-ג-2],'' as [הערה-ג-3],'' as [הערה-ד-1],'' as [הערה-ד-2],'' as [הערה-ד-3],'' as [הערה-ה-1],'' as [הערה-ה-2],'' as [הערה-ה-3],'' as [הערה-ו-1],'' as [הערה-ו-2],'' as [הערה-ו-3],'' as [הערה-חג-1],'' as [הערה-חג-2],'' as [הערה-חוה"מ-1],'' as [הערה-חוה"מ-2],'' as [הערה-חוה"מ-3],'' as [הערה-ערב חג-1],'' as [הערה-ערב חג-2],'' as [הערה-ש-1],'' as [הערה-ש-2]
from Employee e
join x_Dept_Employee de
on de.employeeID = e.employeeID
join Dept d
on de.deptCode = d.deptCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
join x_Dept_Employee_Service des
on de.deptCode = des.deptCode  and des.employeeID = de.employeeID
join Services ser
on des.serviceCode = ser.serviceCode
left join DIC_AgreementTypes dag
on de.AgreementType = dag.AgreementTypeID
where d.status = 1
and e.active = 1
and de.active = 1
and e.EmployeeSectorCode = 7
and des.serviceCode not in (select serviceCode
								from deptEmployeeReceptionServices rp1 
								left join deptEmployeeReception er1
								on er1.receptionID = rp1.receptionID
								where er1.deptCode = d.deptCode
								and er1.EmployeeID = e.employeeID)

go


GRANT SELECT ON [dbo].[vIngr_EmployeeReceptionHoursForShivuk] TO [public] AS [dbo]
GO