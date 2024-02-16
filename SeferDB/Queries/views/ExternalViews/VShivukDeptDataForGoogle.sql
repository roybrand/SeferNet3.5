/* Select dept data for shivuk - for google
-	שם מרפאה
-	תאור סוג המרפאה (UnitTypeName)
-	רחוב
-	מס' בית
-	דירה
-	כניסה
-	קומה
-	הערה לכתובת
-	יישוב
-	מיקוד
-	טלפון 1
-	טלפון 2
-	פקס
-	שכונה
-	אתר
-	תחבורה
-	קואורדינאטות X ו-Y
-	שעות פעילות המרפאה (פורמט המבוקש תראי במייל של רונן או בקובץ מצ"ב )
-	רשימת שירותים במרפאה (רשימה מופרד ";")

-	יש לשלוף גם את המקצועות והשירותים של רופאים ביחידה תחת רשימת שירותים של היחידה
-	אין לשלוף רופאים עצמאיים
*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VShivukDeptDataForGoogle]'))
	DROP VIEW [dbo].VZimunetDeptData
GO


CREATE VIEW [dbo].VShivukDeptDataForGoogle  
AS  

select rtrim(ltrim(d.deptName)) as deptName, u.UnitTypeName, 
	isNull(d.streetName, '') as streetName, isNull(d.house, '') as house, 
	isNull(d.flat, '') as flat, isNull(d.entrance, '') as entrance, 
	isNull(d.floor, '') as floor, isNull(d.addressComment, '') as addressComment, 
	c.cityName, isNull(d.zipCode, '0') as zipCode,
	dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as Phone1, dbo.GetDeptPhoneNumber(d.deptCode, 1, 2) as Phone2,
	dbo.GetDeptPhoneNumber(d.deptCode, 2, 1) as Fax,
	isNull(n.NybName, '') as 'Neighbourhood', isNull(a.InstituteName, '') as 'Site',
	isNull(d.transportation, '') as transportation, xy.xcoord, xy.ycoord,
	isNull(STUFF((select ',' + convert(varchar(1), DeptReception.receptionDay) + ':' +
			DeptReception.openingHour + ':' + DeptReception.closingHour        
			from dbo.DeptReception        
			where DeptReception.DeptCode = d.deptCode
			and DeptReception.receptionDay <= 7
			order by DeptReception.receptionDay, DeptReception.openingHour
			for xml path('')),1,1,''
	), '') as Receptions, 
	isNull(STUFF(( 
			select distinct ';' + ServiceDescription from
				(select s.ServiceDescription as ServiceDescription
					from x_Dept_Employee_Service xdes
					join x_Dept_Employee xde
					on xdes.DeptEmployeeID = xde.DeptEmployeeID
					join Services s
					on xdes.serviceCode = s.ServiceCode
					where xde.deptCode = d.deptCode
					union 
					select vDeptServices.serviceDescription as ServiceDescription       
					from dbo.vDeptServices        
					where vDeptServices.DeptCode = d.deptCode
					) t
			for xml path('')),1,1,''
	), '') as ServiceList,
	d.IsCommunity, d.IsMushlam, d.IsHospital
from Dept d
join UnitType u
on d.typeUnitCode = u.UnitTypeCode
and u.ShowInInternet = 1 and u.IsActive = 1
join Cities c
on d.cityCode = c.cityCode
left join Neighbourhoods n
on d.cityCode = n.CityCode 
and d.NeighbourhoodOrInstituteCode = n.NeighbourhoodCode
and d.IsSite = 0
left join Atarim a
on d.cityCode = a.CityCode  and d.NeighbourhoodOrInstituteCode = a.InstituteCode
and d.IsSite = 1
left join x_dept_XY xy
on d.deptCode = xy.deptCode
where d.showUnitInInternet = 1
and d.status = 1
and d.typeUnitCode <> 112


GO

GRANT SELECT ON [dbo].VShivukDeptDataForGoogle TO [public] AS [dbo]
GO
