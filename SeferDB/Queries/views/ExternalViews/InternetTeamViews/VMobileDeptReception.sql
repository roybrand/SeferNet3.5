﻿/*
1.	דוח שעות פעילות ביחידות:
הדוח יכלול נתוני יחידות פעילות מסוג:
בית מרקחת,יחידה במרפאה,מוקד רפואה דחופה,מכון התפתחות הילד,מכון פיזיותרפיה
,מכון קרדיולוגי,מכון ריפוי בעיסוק,מכון רנטגן/הדמיה,מכון רפואי
,מכון שמיעה ודיבור,מרכז בריאות האישה,מרכז בריאות הילד,מרכז בריאות הנפש
,מרפאה באוניברסיטה,מרפאה יועצת,מרפאה כפרית,מרפאה למטייל
,מרפאה משולבת,מרפאה ראשונית,מרפאת אסתטיקה,מרפאת ספורט
,מרפאת רפואה משלימה,מרפאת שיניים,רופא עצמאי 
ובתנאי שהן אינן מסומנות לא לתצוגה באינטרנט. יופיעו גם מרפאות שאין להן שעות פעילות ביחידה
השדות:
שם יחידה, סוג יחידה, שיוך, קוד סימול, כתובת, הערה לכתובת, טלפון 1, טלפון 2, יום, משעה, עד שעה, הערה לשעות
-----------------------------------------------------

select * from UnitType u
where u.UnitTypeName in ('בית מרקחת','יחידה במרפאה','מוקד רפואה דחופה','מכון התפתחות הילד',
'מכון פיזיותרפיה','מכון קרדיולוגי','מכון ריפוי בעיסוק','מכון רנטגן/הדמיה',
'מכון רפואי','מכון שמיעה ודיבור','מרכז בריאות האישה','מרכז בריאות הילד',
'מרכז בריאות הנפש','מרפאה באוניברסיטה','מרפאה יועצת','מרפאה כפרית',
'מרפאה למטייל','מרפאה משולבת','מרפאה ראשונית','מרפאת אסתטיקה',
'מרפאת ספורט','מרפאת רפואה משלימה','מרפאת שיניים','רופא עצמאי')

קובץ שנוצר הוא : DeptReceptionForMobile.xls

*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VMobileDeptReception]'))
	DROP VIEW [dbo].VMobileDeptReception
GO


CREATE VIEW [dbo].VMobileDeptReception  
AS  
select d.deptCode as 'DeptCode',--'קוד סימול', 
		d.deptName as 'DeptName', --'שם יחידה', 
		ut.UnitTypeName as 'DeptType', -- 'סוג יחידה', 
		sut.subUnitTypeName 'DeptSubType',--'שיוך', 
		dbo.GetAddress(d.deptCode) as 'Address',-- 'הערה לכתובת' + 'כתובת', 
		dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as 'Phone1', -- 'טלפון 1',
		dbo.GetDeptPhoneNumber(d.deptCode, 1, 2) as 'Phone2', -- 'טלפון 2',
		rd.ReceptionDayName as 'ReceptionDay', --'יום',
		dr.openingHour as 'OpeningHour', -- 'משעה', 
		dr.closingHour as 'ClosingHour', -- 'עד שעה',
		drr.RemarkText as 'ReceptionRemark', -- 'הערה לשעות'
		c.cityName as 'City',
		d.streetName as 'Street',
		d.house as 'HouseNum',
		d.flat as 'Flat', 
		d.floor as 'Floor', 
		d.addressComment as 'AddressComment', --'הערה לכתובת'
		xy.xcoord, 
		xy.ycoord
from Dept d
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on d.subUnitTypeCode = sut.subUnitTypeCode
left join DeptReception dr
on dr.deptCode = d.deptCode
and dr.ReceptionHoursTypeID = 1
left join DIC_ReceptionDays rd
on dr.receptionDay = rd.ReceptionDayCode
left join DeptReceptionRemarks drr
on dr.ReceptionID = drr.ReceptionID
join Cities c on d.cityCode = c.cityCode
left join x_dept_XY xy on d.deptCode = xy.deptCode
where d.status = 1
and d.showUnitInInternet = 1
and d.IsCommunity = 1
and d.typeUnitCode in (101, 102, 103, 104, 107, 111, 112, 114, 115, 202, 203, 204, 205, 207, 208, 212, 301, 303, 401, 501, 502, 503, 917, 918)
--order by d.deptCode, dr.receptionDay

GO

GRANT SELECT ON [dbo].VMobileDeptReception TO [public] AS [dbo]
GO
