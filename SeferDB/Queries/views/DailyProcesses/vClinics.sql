/* שליפה עבור סיבל מוקדים 

הדוח יכיל את פרטי המרפאות בחתך של רופאים מחמש המקצועות 
השדות שצריכים להיות מועברים הם:
קוד מחוז, קוד אתר ישן, קוד אתר חדש
קוד ישוב, ישוב, כתובת, שם מרפאה מספר השירות
בדוח הנ"ל אנחנו מדברים אך ורק על מרפאות/רופאים של 
הקהילה (קהילה + עצמאי) ולא שולפים פרטים על מושלם/בתי חולים


*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vClinics]'))
DROP VIEW [dbo].[vClinics]
GO

CREATE VIEW [dbo].[vClinics]

AS

SELECT TOP 100 PERCENT
districtCode, 
Simul228, 
deptCode, 
deptNameSimul,
cityCode, 
cityName, 
dept_address, 
deptName,
typeUnitCode,
UnitTypeName
FROM
(
SELECT TOP 1 
'קוד מחוז' as districtCode, 
'קוד אתר ישן' as Simul228, 
'קוד אתר חדש' as deptCode, 
'תאור אתר' as deptNameSimul, -- empty
'קוד ישוב' as cityCode, 
'ישוב' as cityName, 
'כתובת' as dept_address, 
'שם מרפאה מספר השירות' as deptName,
'קוד סוג מרפאה' as typeUnitCode,
'סוג מרפאה' as UnitTypeName,
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
REPLACE(CAST(dbo.GetAddress(Dept.deptCode) as varchar(200)), ',', ' ') as dept_address,
Dept.deptName,
CAST(Dept.typeUnitCode as varchar(10)) as typeUnitCode,
UnitType.UnitTypeName,
2 as orderNumber
 
FROM Dept WITH(NOLOCK)
LEFT JOIN deptSimul ON Dept.deptCode = deptSimul.deptCode
JOIN Cities ON Dept.cityCode = Cities.cityCode
join UnitType on Dept.typeUnitCode = UnitType.UnitTypeCode
WHERE Dept.status <> 0
and Dept.IsCommunity = 1
AND Dept.deptCode in
	(SELECT deptCode 
	FROM x_Dept_Employee
	JOIN x_Dept_Employee_Service ON x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID
	WHERE x_Dept_Employee_Service.serviceCode in (31,61,58,63,62)
	)
) T
ORDER BY orderNumber

GO


grant select on [vClinics] to public 
go


