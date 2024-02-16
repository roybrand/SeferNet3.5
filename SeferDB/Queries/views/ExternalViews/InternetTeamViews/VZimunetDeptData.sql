/*
VIEW עבור זימונט באינטרנט הכולל את השדות הבאים בלבד :

•	קוד מרפאה ישן
•	שם מרפאה
•	כתובת
•	סוג מרפאה ( UnitType)
•	מס' טלפון.

יש לשלוף רק יחידות פעילות, כל הסוגים, רק קהילה
*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VZimunetDeptData]'))
	DROP VIEW [dbo].VZimunetDeptData
GO


CREATE VIEW [dbo].VZimunetDeptData  
AS  

select d.deptCode , ds.Simul228 as OldSimul ,d.deptName as DeptName, 
		c.cityName, case when d.StreetCode is null then d.streetName else s.Name end as Street,
		d.house as HouseNo, d.addressComment as AddressComment, 
		d.zipCode,d.typeUnitCode as UnitType,
		dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) AS PhoneNumber,
		d.IsCommunity, d.IsMushlam, d.IsHospital
from Dept d
join deptSimul ds
on d.deptCode = ds.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on s.CityCode = d.cityCode
and s.StreetCode = d.StreetCode
left join DeptPhones dp
on dp.deptCode = d.deptCode
and dp.phoneType = 1
and dp.phoneOrder = 1
where d.status = 1

GO

GRANT SELECT ON [dbo].VZimunetDeptData TO [public] AS [dbo]
GO
