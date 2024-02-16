IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptDetailsForUpdate')
	BEGIN
		DROP  Procedure  rpc_getDeptDetailsForUpdate
	END

GO

CREATE  Procedure [dbo].[rpc_getDeptDetailsForUpdate]
(
	@deptCode int
)

AS

DECLARE @ExpirationDate datetime = DATEADD(day, DATEDIFF(day, 0, getdate()), 0) 
DECLARE @DateAfterExpiration datetime
SET @DateAfterExpiration = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, getdate()), 0))


--- DeptDetails --------------------------------------------------------
SELECT
-- FIRST SECTION on page --------------------------------------------------------
D.deptName,
D.deptNameFreePart,
D.deptType, -- 1, 2, 3
DIC_DeptTypes.deptTypeDescription, -- מחוז, מנהלת, מרפאה
D.typeUnitCode, -- סוג יחידה
UnitType.UnitTypeName,
'subUnitTypeCode' = IsNull(D.subUnitTypeCode, -1), -- שיוך

D.deptLevel,
D.managerName,
'substituteManagerName' = IsNull((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID								
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToManager = 1
							AND x_Dept_Employee.deptCode = D.deptCode
							), ''),
D.administrativeManagerName,
'substituteAdministrativeManagerName' = IsNull((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToAdministrativeManager = 1
							AND x_Dept_Employee.deptCode = D.deptCode
							), ''),

-- SECOND SECTION --------------------------------------------------------
D.cityCode,
Cities.cityName,
D.streetCode,
'streetName' = RTRIM(LTRIM(D.streetName)),
D.house,
D.flat,
D.floor,
D.addressComment,
D.email,
'showEmailInInternet' = CAST(IsNull(D.showEmailInInternet, 0) as bit),
D.NeighbourhoodOrInstituteCode,
D.IsSite,
CASE WHEN D.IsSite = 1 THEN Atarim.InstituteName ELSE Neighbourhoods.NybName END as NeighbourhoodOrInstituteName,
D.Building,
D.LinkToBlank17,
D.LinkToContactUs,

-- THIRD SECTION --------------------------------------------------------
D.transportation,
D.parking,

-- FORTH SECTION --------------------------------------------------------
'districtCode' = IsNull(D.districtCode, -1),
'additionaDistrictCodes' = dbo.fun_GetAdditionalDistrictCodes(@deptCode),
'additionaDistrictNames' = dbo.fun_GetAdditionalDistrictNames(@deptCode), 
'administrationCode' = IsNull(D.administrationCode, -1),				-- "מנהלות" 
'subAdministrationCode' = IsNull(D.subAdministrationCode, -1),
'subAdministrationName' = (SELECT dept.deptName 
							FROM dept
							WHERE dept.deptCode = D.subAdministrationCode),
'parentClinicCode' = IsNull(D.ParentClinic, -1),
'parentClinicName' = (SELECT dept.deptName FROM Dept WHERE dept.deptCode = D.ParentClinic),

'populationSectorCode' = IsNull(D.populationSectorCode, -1),
D.deptCode,
deptSimul.Simul228,
DIC_ActivityStatus.statusDescription,

-- FIFTH SECTION --------------------------------------------------------
deptSimul.deptNameSimul,
'statusSimul' = CASE deptSimul.statusSimul WHEN 1 THEN 'פתוח' ELSE 'סגור' END,
'openDateSimul'= CONVERT(varchar(10),openDateSimul,101),
'closingDateSimul'= CONVERT(varchar(10),closingDateSimul,101),
deptSimul.SimulManageDescription,

deptSimul.SugSimul501,
deptSimul.TatSugSimul502,
deptSimul.TatHitmahut503,
deptSimul.RamatPeilut504,
'SugSimulDesc' = SugSimul501.SimulDesc,
'TatSugSimulDesc' = TatSugSimul502.TatSugSimulDesc,
'TatHitmahutDesc' = TatHitmahut503.HitmahutDesc,
'RamatPeilutDesc' = RamatPeilut504.Teur,

'UnitTypeNameSimul' = IsNull(UT.UnitTypeName, ''),
'UnitTypeCodeSimul' = IsNull(outerUTCS.key_TypUnit,301),
 
'showUnitInInternet' = IsNull(D.showUnitInInternet, 1),
'AllowQueueOrder' = IsNull(UnitType.AllowQueueOrder, 0),
ISNULL(x_dept_XY.xcoord, 0) as xcoord,
ISNULL(x_dept_XY.ycoord, 0) as ycoord,
ISNULL(x_dept_XY.XLongitude, 0) as XLongitude,
ISNULL(x_dept_XY.YLatitude, 0) as YLatitude,
ISNULL(x_dept_XY.UpdateManually, 0) as UpdateManually,
d.IsCommunity,
d.IsHospital,
d.IsMushlam

-- SIXTH SECTION --------------------------------------------------------
,d.TypeOfDefenceCode
,d.DefencePolicyCode
,d.HasElectricalPanel
,d.HasGenerator
,d.IsUnifiedClinic
-- ש.ל.ה --------------------------------------------------------
,d.DeptShalaCode
-- dept status --------------------------------------------------------
,d.status 
 

FROM dept as D
INNER JOIN DIC_DeptTypes ON D.deptType = DIC_DeptTypes.deptType	-- ??
INNER JOIN Cities ON D.cityCode = Cities.cityCode
INNER JOIN DIC_ActivityStatus ON D.status = DIC_ActivityStatus.status
LEFT JOIN deptSimul ON D.deptCode = deptSimul.deptCode
LEFT JOIN SugSimul501 ON deptSimul.SugSimul501 = SugSimul501.SugSimul
LEFT JOIN TatSugSimul502 ON deptSimul.TatSugSimul502 = TatSugSimul502.TatSugSimulId
	AND deptSimul.SugSimul501 = TatSugSimul502.SugSimul
LEFT JOIN TatHitmahut503 ON deptSimul.TatHitmahut503 = TatHitmahut503.TatHitmahut
	AND deptSimul.TatSugSimul502 = TatHitmahut503.TatSugSimulId
	AND deptSimul.SugSimul501 = TatHitmahut503.SugSimul
LEFT JOIN RamatPeilut504 ON deptSimul.RamatPeilut504 = RamatPeilut504.RamatPeilut
	AND deptSimul.TatHitmahut503 = RamatPeilut504.TatHitmahut
	AND deptSimul.TatSugSimul502 = RamatPeilut504.TatSugSimul
	AND deptSimul.SugSimul501 = RamatPeilut504.SugSimul

INNER JOIN UnitType ON D.typeUnitCode = UnitType.UnitTypeCode
LEFT JOIN x_dept_XY ON D.deptCode = x_dept_XY.deptCode
LEFT JOIN Atarim ON D.NeighbourhoodOrInstituteCode = Atarim.InstituteCode
LEFT JOIN Neighbourhoods ON D.NeighbourhoodOrInstituteCode = Neighbourhoods.NeighbourhoodCode

--LEFT JOIN UnitTypeConvertSimul ON deptSimul.SugSimul501 = UnitTypeConvertSimul.SugSimul
--	AND deptSimul.TatSugSimul502 = UnitTypeConvertSimul.TatSugSimul
--	AND deptSimul.TatHitmahut503 = UnitTypeConvertSimul.TatHitmahut
--	AND deptSimul.RamatPeilut504 = UnitTypeConvertSimul.RamatPeilut
--LEFT JOIN (SELECT DISTINCT key_TypUnit, SugSimul, TatSugSimul, TatHitmahut, 0 as RamatPeilut FROM UnitTypeConvertSimul ) as UTCS2
--	ON deptSimul.SugSimul501 = UTCS2.SugSimul
--	AND deptSimul.TatSugSimul502 = UTCS2.TatSugSimul
--	AND deptSimul.TatHitmahut503 = UTCS2.TatHitmahut	
--LEFT JOIN (SELECT DISTINCT TOP 1 key_TypUnit, SugSimul, TatSugSimul FROM UnitTypeConvertSimul ) as UTCS3
--	ON deptSimul.SugSimul501 = UTCS3.SugSimul
--	AND deptSimul.TatSugSimul502 = UTCS3.TatSugSimul
--LEFT JOIN (SELECT DISTINCT TOP 1 key_TypUnit, SugSimul FROM UnitTypeConvertSimul ) as UTCS4	
--	ON deptSimul.SugSimul501 = UTCS4.SugSimul	
--LEFT JOIN UnitType as UT ON UnitTypeConvertSimul.key_TypUnit = UT.UnitTypeCode
--LEFT JOIN UnitType as UT2 ON UTCS2.key_TypUnit = UT2.UnitTypeCode
--LEFT JOIN UnitType as UT3 ON UTCS3.key_TypUnit = UT3.UnitTypeCode
--LEFT JOIN UnitType as UT4 ON UTCS4.key_TypUnit = UT4.UnitTypeCode
LEFT JOIN 
(
 SELECT TOP 1 deptCode, key_TypUnit FROM
	(
	SELECT DISTINCT ds.deptCode, key_TypUnit, SugSimul, TatSugSimul, TatHitmahut, RamatPeilut, 1 as ORD 
	FROM UnitTypeConvertSimul UTCS
	JOIN deptSimul ds
		ON ds.SugSimul501 = UTCS.SugSimul
		AND ds.TatSugSimul502 = UTCS.TatSugSimul
		AND ds.TatHitmahut503 = UTCS.TatHitmahut 
		AND ds.RamatPeilut504 = UTCS.RamatPeilut 		
	WHERE ds.deptCode = @deptCode
		
		UNION	
	
	SELECT DISTINCT ds.deptCode, key_TypUnit, SugSimul, TatSugSimul, TatHitmahut, 0 as RamatPeilut, 2 as ORD 
	FROM UnitTypeConvertSimul UTCS
	JOIN deptSimul ds
		ON ds.SugSimul501 = UTCS.SugSimul
		AND ds.TatSugSimul502 = UTCS.TatSugSimul
		AND ds.TatHitmahut503 = UTCS.TatHitmahut 
	WHERE ds.deptCode = @deptCode
		
		UNION
		
	SELECT DISTINCT ds.deptCode, key_TypUnit, SugSimul, TatSugSimul, 0 as TatHitmahut, 0 as RamatPeilut, 3 as ORD
	FROM UnitTypeConvertSimul UTCS
	JOIN deptSimul ds
		ON ds.SugSimul501 = UTCS.SugSimul
		AND ds.TatSugSimul502 = UTCS.TatSugSimul
	WHERE ds.deptCode = @deptCode
			
		UNION	
		
	SELECT DISTINCT ds.deptCode, key_TypUnit, SugSimul, 0 as TatSugSimul, 0 as TatHitmahut, 0 as RamatPeilut, 4 as ORD
	FROM UnitTypeConvertSimul UTCS
	JOIN deptSimul ds
		ON ds.SugSimul501 = UTCS.SugSimul
	WHERE ds.deptCode = @deptCode
			
		) innerUTCS 
	ORDER BY ORD
) outerUTCS ON  D.deptCode = outerUTCS.deptCode
LEFT JOIN UnitType as UT ON outerUTCS.key_TypUnit = UT.UnitTypeCode

WHERE D.deptCode = @deptCode


-- DeptHandicappedFacilities
SELECT T1.FacilityCode, T1.FacilityDescription,
'CinicHasFacility' = CASE IsNull(T2.FacilityCode, 0) WHEN 0 THEN 0 ELSE 1 END
FROM
(SELECT
DIC_HandicappedFacilities.FacilityCode,
DIC_HandicappedFacilities.FacilityDescription
FROM DIC_HandicappedFacilities where Active=1) as T1 

LEFT JOIN 
(SELECT FacilityCode FROM DeptHandicappedFacilities
WHERE DeptCode = @deptCode) as T2 ON T1.FacilityCode = T2.FacilityCode

-- DeptQueueOrderMethods_ForHeadline
DECLARE @QueueOrderMethods varchar(100)
SET @QueueOrderMethods = ''

SELECT @QueueOrderMethods = QueueOrderDescription + ', ' + @QueueOrderMethods
FROM Dept d
INNER JOIN DIC_QueueOrder dic ON d.QueueOrder = dic.QueueOrder
WHERE DeptCode = @deptCode 
AND d.QueueOrder IS NOT NULL AND dic.PermitOrderMethods = 0

SELECT @QueueOrderMethods = QueueOrderMethodDescription + ', ' + @QueueOrderMethods
FROM DeptQueueOrderMethod
INNER JOIN DIC_QueueOrderMethod ON DeptQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE deptCode = @deptCode AND ShowPhonePicture = 0

SELECT @QueueOrderMethods = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ', '+ @QueueOrderMethods
FROM DeptPhones
INNER JOIN DeptQueueOrderMethod ON DeptPhones.deptCode = DeptQueueOrderMethod.deptCode
INNER JOIN DIC_QueueOrderMethod ON DeptQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE DeptPhones.deptCode = @deptCode AND phoneType = 1 AND phoneOrder = 1
AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1

SELECT @QueueOrderMethods = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ', '+ @QueueOrderMethods
FROM DeptQueueOrderPhones
INNER JOIN DeptQueueOrderMethod ON DeptQueueOrderPhones.QueueOrderMethodID = DeptQueueOrderMethod.QueueOrderMethodID
INNER JOIN DIC_QueueOrderMethod ON DIC_QueueOrderMethod.QueueOrderMethod = DeptQueueOrderMethod.QueueOrderMethod
WHERE deptCode = @deptCode 
AND SpecialPhoneNumberRequired = 1

IF len(@QueueOrderMethods) > 1
-- remove last comma
BEGIN
	SET @QueueOrderMethods = SUBSTRING(@QueueOrderMethods, 0, len(@QueueOrderMethods))
END

SELECT TOP 1 @QueueOrderMethods FROM EmployeeServiceQueueOrderMethod



--------- Remarks (for viewing purposes only)--------------------------------------------------------
--------- general Remarks concern the clinic--------------------------------------------------------
SELECT remarkID
, 'RemarkText' = dbo.rfn_GetFotmatedRemark(RemarkText)
, validFrom
, validTo
, displayInInternet
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark as 'sweeping' 
, ShowOrder
FROM View_DeptRemarks
LEFT JOIN Dept ON View_DeptRemarks.deptCode = Dept.deptCode
WHERE View_DeptRemarks.deptCode = @deptCode
AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
AND (IsSharedRemark = 0 OR Dept.IsCommunity = 1) 
ORDER BY sweeping desc ,ShowOrder asc



-------- DeptPhones --------------------------------------------------------
SELECT 
DeptPhoneID,
DeptPhones.phoneType,
phoneOrder,
prePrefix,
prefixCode,
PrefixValue as PrefixText,
phone,
extension,
Remark
FROM DeptPhones
LEFT JOIN DIC_PhonePrefix dic ON DeptPhones.Prefix = dic.PrefixCode
WHERE deptCode = @deptCode
AND DeptPhones.phoneType = 1 -- (Phone)

-------- DeptFaxes --------------------------------------------------------
SELECT 
DeptPhoneID,
DeptPhones.phoneType,
phoneOrder,
prePrefix,
prefixCode,
PrefixValue as PrefixText,
phone,
extension,
Remark
FROM DeptPhones
LEFT JOIN DIC_PhonePrefix dic ON DeptPhones.Prefix = dic.PrefixCode
WHERE deptCode = @deptCode
AND DeptPhones.phoneType = 2 -- (Fax)

-------- DeptDirectPhones --------------------------------------------------------
SELECT 
DeptPhoneID,
DeptPhones.phoneType,
phoneOrder,
prePrefix,
prefixCode,
PrefixValue as PrefixText,
phone,
extension,
Remark
FROM DeptPhones
LEFT JOIN DIC_PhonePrefix dic ON DeptPhones.Prefix = dic.PrefixCode
WHERE deptCode = @deptCode
AND DeptPhones.phoneType = 5 -- (DeptDirectPhone)


GO

GRANT EXEC ON dbo.rpc_getDeptDetailsForUpdate TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getDeptDetailsForUpdate TO [clalit\IntranetDev]
GO


