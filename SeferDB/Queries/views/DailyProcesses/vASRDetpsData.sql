IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vASRDetpsData]'))
DROP VIEW [dbo].[vASRDetpsData]
GO

CREATE VIEW [dbo].[vASRDetpsData]

AS

SELECT TOP 100 PERCENT
districtCode, 
Simul228, 
deptCode, 
deptNameSimul,
cityCode, 
cityName,
streetName,
house,
addressComment, 
dept_address, 
deptName,
typeUnitCode,
UnitTypeName,
UpdateDate
FROM
(
SELECT TOP 1 
'קוד מחוז' as districtCode, 
'קוד אתר ישן' as Simul228, 
'קוד אתר חדש' as deptCode, 
'תאור אתר' as deptNameSimul, -- empty
'קוד ישוב' as cityCode, 
'ישוב' as cityName,

'רחוב' as streetName,
'מספר בית' as house,
'הערה כתובת' as addressComment,
 
'כתובת' as dept_address, 
'שם מרפאה מספר השירות' as deptName,
'קוד סוג מרפאה' as typeUnitCode,
'סוג מרפאה' as UnitTypeName,
'תאריך עדכון' as UpdateDate,
1 as orderNumber
FROM Employee

UNION

SELECT
CAST(Dept.districtCode as varchar(10)) as districtCode,
IsNull(CAST(deptSimul.Simul228 as varchar(5)), '') as Simul228,
CAST(Dept.deptCode as varchar(10)) as deptCode,
'' as deptNameSimul, -- empty
CAST(Dept.cityCode as varchar(10)) as cityCode,
Cities.cityName,

IsNull(Dept.streetName, ''),
IsNull(Dept.house, ''),
IsNull(Dept.addressComment, ''),

REPLACE(REPLACE(REPLACE(CAST(dbo.GetAddress(Dept.deptCode) as varchar(200)), ',', ' '), CHAR(10), ''), CHAR(13), '') as dept_address,
Dept.deptName,
CAST(Dept.typeUnitCode as varchar(10)) as typeUnitCode,
UnitType.UnitTypeName,
CONVERT(varchar(12), Dept.updateDate, 101) as UpdateDate,
2 as orderNumber
 
FROM Dept WITH(NOLOCK)
LEFT JOIN deptSimul ON Dept.deptCode = deptSimul.deptCode
JOIN Cities ON Dept.cityCode = Cities.cityCode
join UnitType on Dept.typeUnitCode = UnitType.UnitTypeCode
WHERE Dept.status = 1
and Dept.IsCommunity = 1
AND Dept.typeUnitCode in (101, 102, 103, 104, 107, 112, 207, 301, 502)
and exists (select * from x_Dept_Employee xde 
			join x_Dept_Employee_Service xdes on xde.DeptEmployeeID = xdes.DeptEmployeeID
			where xde.deptCode = Dept.deptCode
			and xdes.Status = 1
			and xdes.serviceCode in (31, 58, 61, 62, 63)
		)
) T
ORDER BY orderNumber

GO

grant select on [vASRDetpsData] to public 

GO

