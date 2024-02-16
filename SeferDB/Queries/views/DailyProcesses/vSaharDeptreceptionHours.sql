/*
דוח שעות קבלה ביחידה מול שעות מעבדה באותה היחידה
הקובץ יכיל שדות הבאים :
מס' מוסד (מחוז), מס' יחידה, שם יחידה, סוג יחידה (מרפאה , מכון, בית מרקחת , מעבדה וכו...)
יום בשבוע, שעת פתיחה (התחלה של השרות), שעת  סגירה (שעת סיום של השרות), 
סוג שרות (קבלה רגילה , שרות מעבדה וכו..), מס מופע ליום (אם יש פיצול באותו יום)

על השדות להיות מופרדים ב נקודה פסיק (;)
הקובץ יהיה קובץ  ASCII שטוח רשומה לכל מופע.


עבור מערכת שכר
*/
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vSaharDeptreceptionHours]'))
	DROP VIEW [dbo].vSaharDeptreceptionHours
GO


create view dbo.[vSaharDeptreceptionHours]
as
SELECT 
	right('000000' + convert(varchar(6), districtCode), 6) as districtCode,
	right('00000' + Simul228, 5) as Simul228,
	right('000000' + convert(varchar(6), deptCode), 6) as deptCode,
	deptName , UnitTypeName , 
	ReceptionDayName , ServiceDescription ,  
	openingHour , closingHour ,
	row_number() over (partition by A.districtCode, a.deptCode, A.ServiceDescription
		, A.ReceptionDayName ORDER BY A.openingHour, A.closingHour ) shift
FROM 
	(
	SELECT distinct d.districtCode, ISNULL(CAST(DS.Simul228 as varchar(10)), '') as Simul228, d.deptCode, d.deptName, UT.UnitTypeName,
	DIC_RD.ReceptionDayName, s.ServiceDescription, DER.openingHour, DER.closingHour
	FROM
	Dept d
	JOIN deptSimul DS ON d.deptCode = DS.deptCode
	JOIN UnitType UT ON d.typeUnitCode = UT.UnitTypeCode
	JOIN Cities ON d.cityCode = Cities.cityCode
	JOIN x_Dept_Employee xDE ON d.deptCode = xDE.deptCode
	JOIN x_Dept_Employee_Service xDES ON xDE.DeptEmployeeID = xDES.DeptEmployeeID AND xdes.serviceCode = 515
	JOIN deptEmployeeReception DER ON xDE.DeptEmployeeID = DER.DeptEmployeeID
	join deptEmployeeReceptionServices ders on der.receptionID = ders.receptionID AND ders.serviceCode = 515
	JOIN [Services] s ON xDES.serviceCode = s.ServiceCode
	LEFT JOIN DIC_ReceptionDays DIC_RD ON DER.receptionDay = DIC_RD.ReceptionDayCode
	WHERE d.status = 1
	AND d.IsCommunity = 1
	AND (DER.validFrom is NULL OR DER.validFrom < GETDATE())
	AND (DER.validTo is NULL OR DER.validTo > GETDATE())

	UNION

	SELECT 
	d.districtCode, ISNULL(CAST(DS.Simul228 as varchar(10)), '') as Simul228, d.deptCode, d.deptName, UT.UnitTypeName,
	DIC_RD.ReceptionDayName, 'שעות קבלה' as ServiceDescription, DR.openingHour, DR.closingHour
	--, 
	--row_number() over (partition by d.deptCode, DR.receptionDay 
	--ORDER BY DR.openingHour, DR.closingHour ) shift
	FROM
	Dept d
	JOIN deptSimul DS ON d.deptCode = DS.deptCode
	JOIN UnitType UT ON d.typeUnitCode = UT.UnitTypeCode
	JOIN Cities ON d.cityCode = Cities.cityCode
	JOIN DeptReception DR ON d.deptCode = DR.deptCode and ReceptionHoursTypeID = 1
	LEFT JOIN DIC_ReceptionDays DIC_RD ON DR.receptionDay = DIC_RD.ReceptionDayCode
	WHERE d.status = 1
	AND d.IsCommunity = 1
	AND (DR.validFrom is NULL OR DR.validFrom < GETDATE())
	AND (DR.validTo is NULL OR DR.validTo > GETDATE())
	) A
go

GRANT SELECT ON [vSaharDeptreceptionHours] TO [public]

GO
