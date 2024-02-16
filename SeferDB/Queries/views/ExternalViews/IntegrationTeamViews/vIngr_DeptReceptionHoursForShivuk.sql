
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DeptReceptionHoursForShivuk]'))
	DROP VIEW [dbo].[vIngr_DeptReceptionHoursForShivuk]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
שליפת פרטי יחידות עבור שיווק
א.	קוד יחידה
ב.	 שם מרפאה
ג.	סוג יחידה + שיוך
ד.	מחוז
ה.	כתובת (עיר, רחוב, מיקוד קואורדינאטות, הערה לכתובת)
ו.	טלפון
ז.	שעות קבלה 
ח.	הערות לשעות
*/


CREATE VIEW [dbo].[vIngr_DeptReceptionHoursForShivuk]
AS

select deptcode, deptName,deptTypeName, 
				deptSubTypeName,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				phone,
max([א-1]) as [א-1],max([א-2]) as [א-2],max([א-3]) as [א-3],max([ב-1]) as [ב-1],max([ב-2]) as [ב-2],max([ב-3]) as [ב-3],max([ג-1]) as [ג-1],max([ג-2]) as [ג-2],max([ג-3]) as [ג-3],max([ד-1]) as [ד-1],max([ד-2]) as [ד-2],max([ד-3]) as [ד-3],max([ה-1]) as [ה-1],max([ה-2]) as [ה-2],max([ה-3]) as [ה-3],max([ו-1]) as [ו-1],max([ו-2]) as [ו-2],max([ו-3]) as [ו-3],max([חג-1]) as [חג-1],max([חג-2]) as [חג-2],max([חוה"מ-1]) as [חוה"מ-1],max([חוה"מ-2]) as [חוה"מ-2],max([חוה"מ-3]) as [חוה"מ-3],max([ערב חג-1]) as [ערב חג-1],max([ערב חג-2]) as [ערב חג-2],max([ש-1]) as [ש-1],max([ש-2]) as [ש-2],
max([הערה-א-1]) as [הערה-א-1],max([הערה-א-2]) as [הערה-א-2],max([הערה-א-3]) as [הערה-א-3],max([הערה-ב-1]) as [הערה-ב-1],max([הערה-ב-2]) as [הערה-ב-2],max([הערה-ב-3]) as [הערה-ב-3],max([הערה-ג-1]) as [הערה-ג-1],max([הערה-ג-2]) as [הערה-ג-2],max([הערה-ג-3]) as [הערה-ג-3],max([הערה-ד-1]) as [הערה-ד-1],max([הערה-ד-2]) as [הערה-ד-2],max([הערה-ד-3]) as [הערה-ד-3],max([הערה-ה-1]) as [הערה-ה-1],max([הערה-ה-2]) as [הערה-ה-2],max([הערה-ה-3]) as [הערה-ה-3],max([הערה-ו-1]) as [הערה-ו-1],max([הערה-ו-2]) as [הערה-ו-2],max([הערה-ו-3]) as [הערה-ו-3],max([הערה-חג-1]) as [הערה-חג-1],max([הערה-חג-2]) as [הערה-חג-2],max([הערה-חוה"מ-1]) as [הערה-חוה"מ-1],max([הערה-חוה"מ-2]) as [הערה-חוה"מ-2],max([הערה-חוה"מ-3]) as [הערה-חוה"מ-3],max([הערה-ערב חג-1]) as [הערה-ערב חג-1],max([הערה-ערב חג-2]) as [הערה-ערב חג-2],max([הערה-ש-1]) as [הערה-ש-1],max([הערה-ש-2]) as [הערה-ש-2]
from 
(select
d.deptCode, d.deptName, 
ut.UnitTypeName as deptTypeName, 
				sut.subUnitTypeName as deptSubTypeName,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
				dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as phone,
dr.receptionDay,
dr.openingHour ,
dr.closingHour ,
[DIC_ReceptionDays].ReceptionDayName,
openingHour + '-'+closingHour as Hours,
derp.RemarkText,
row_number() over (partition by d.deptCode,dr.receptionDay 
order by dr.openingHour --,DeptReception.closingHour 
)rn,
[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by d.deptCode,dr.receptionDay order by dr.openingHour /*,dr.closingHour*/ ) as varchar(10)) shift ,
'הערה-'+[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by d.deptCode,dr.receptionDay 
												order by dr.openingHour) as varchar(10)) shift2
from dept d 
join DeptReception dr
on d.deptCode = dr.deptCode 
and dr.ReceptionHoursTypeID = 1
left join [DIC_ReceptionDays]
on dr.receptionDay = [DIC_ReceptionDays].ReceptionDayCode  
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on d.subUnitTypeCode = sut.subUnitTypeCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
left join DeptReceptionRemarks derp
on derp.ReceptionID = dr.receptionID
where d.status = 1
and GETDATE() between ISNULL(dr.validFrom,'1900-01-01') 
and ISNULL(dr.validTo,'2079-01-01')  
) a
pivot 
(max(Hours) for shift in ([א-1],[א-2],[א-3],[ב-1],[ב-2],[ב-3],[ג-1],[ג-2],[ג-3],[ד-1],[ד-2],[ד-3],[ה-1],[ה-2],[ה-3],[ו-1],[ו-2],[ו-3],[ש-1],[ש-2],[חג-1],[חג-2],[חוה"מ-1],[חוה"מ-2],[חוה"מ-3],[ערב חג-1],[ערב חג-2])
) AS PivotTable
pivot 
(max(RemarkText) for shift2 in ([הערה-א-1],[הערה-א-2],[הערה-א-3],[הערה-ב-1],[הערה-ב-2],[הערה-ב-3],[הערה-ג-1],[הערה-ג-2],[הערה-ג-3],[הערה-ד-1],[הערה-ד-2],[הערה-ד-3],[הערה-ה-1],[הערה-ה-2],[הערה-ה-3],[הערה-ו-1],[הערה-ו-2],[הערה-ו-3],[הערה-ש-1],[הערה-ש-2],[הערה-חג-1],[הערה-חג-2],[הערה-חוה"מ-1],[הערה-חוה"מ-2],[הערה-חוה"מ-3],[הערה-ערב חג-1],[הערה-ערב חג-2])
) AS PivotTable2
group by deptcode, deptName, deptTypeName, 
				deptSubTypeName,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				phone
union
select d.deptcode, d.deptName,
ut.UnitTypeName as deptTypeName, 
				sut.subUnitTypeName as deptSubTypeName,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
				dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as phone,
'' as [א-1],'' as [א-2],'' as [א-3],'' as [ב-1],'' as [ב-2],'' as [ב-3],'' as [ג-1],'' as [ג-2],'' as [ג-3],'' as [ד-1],'' as [ד-2],'' as [ד-3],'' as [ה-1],'' as [ה-2],'' as [ה-3],'' as [ו-1],'' as [ו-2],'' as [ו-3],
'' as [חג-1],'' as [חג-2], '' as [חוה"מ-1],'' as [חוה"מ-2],'' as [חוה"מ-3],'' as [ערב חג-1],'' as [ערב חג-2],'' as [ש-1],'' as [ש-2],
'' as [הערה-א-1],'' as [הערה-א-2],'' as [הערה-א-3],'' as [הערה-ב-1],'' as [הערה-ב-2],'' as [הערה-ב-3],'' as [הערה-ג-1],'' as [הערה-ג-2],'' as [הערה-ג-3],'' as [הערה-ד-1],'' as [הערה-ד-2],'' as [הערה-ד-3],'' as [הערה-ה-1],'' as [הערה-ה-2],'' as [הערה-ה-3],'' as [הערה-ו-1],'' as [הערה-ו-2],'' as [הערה-ו-3],'' as [הערה-חג-1],'' as [הערה-חג-2],'' as [הערה-חוה"מ-1],'' as [הערה-חוה"מ-2],'' as [הערה-חוה"מ-3],'' as [הערה-ערב חג-1],'' as [הערה-ערב חג-2],'' as [הערה-ש-1],'' as [הערה-ש-2]
from Dept d
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on d.subUnitTypeCode = sut.subUnitTypeCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
where d.deptCode not in (select deptCode from DeptReception where ReceptionHoursTypeID = 1)
and d.status = 1

GO


GRANT SELECT ON [dbo].[vIngr_DeptReceptionHoursForShivuk] TO [public] AS [dbo]
GO
