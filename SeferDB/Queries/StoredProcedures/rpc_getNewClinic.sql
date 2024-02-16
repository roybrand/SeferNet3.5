IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getNewClinic')
	BEGIN
		DROP  Procedure  rpc_getNewClinic
	END

GO

CREATE Procedure rpc_getNewClinic
	(
		@DeptCode int
	)

AS

SELECT SimulDeptId as deptCode, SimulDeptName as deptName, d.deptCode as districtCode, d.DeptName as districtName, 
ManageId, 
'SimulManageDescription' = IsNull(Int1.SimulManageDescription, '0'),
Simul228,
Int1.SugSimul501, t501.SimulDesc, Int1.TatSugSimul502, 
't502_descr' = (SELECT TatSugSimulDesc FROM TatSugSimul502 
	WHERE TatSugSimul502.SugSimul = Int1.SugSimul501 
	AND TatSugSimul502.TatSugSimulId = Int1.TatSugSimul502), 
Int1.TatHitmahut503, 
't503_descr' = (SELECT HitmahutDesc FROM TatHitmahut503 
	WHERE TatHitmahut503.SugSimul = Int1.SugSimul501 
	AND TatHitmahut503.TatSugSimulId = Int1.TatSugSimul502 
	AND TatHitmahut503.TatHitmahut = Int1.TatHitmahut503), 
Int1.RamatPeilut504, 
't504_descr' = (SELECT Teur FROM RamatPeilut504 
	WHERE RamatPeilut504.SugSimul = Int1.SugSimul501 
	AND RamatPeilut504.TatSugSimul = Int1.TatSugSimul502 
	AND RamatPeilut504.TatHitmahut = Int1.TatHitmahut503 
	AND RamatPeilut504.RamatPeilut = Int1.RamatPeilut504), 
Int1.Key_typUnit, UnitType.UnitTypeName, Int1.OpenDateSimul, Int1.PopSectorID, 
PopulationSectors.PopulationSectorDescription,
Cities.CityCode,
Cities.cityName,
Int1.street,
Int1.house,
Int1.entrance,
Int1.flat,
Int1.zip,
'phone1' = dbo.fun_ParsePhoneNumberWithExtension(preprefix1, prefix1, Nphone1, null),
'phone2' = dbo.fun_ParsePhoneNumberWithExtension(preprefix2, prefix2, Nphone2, null),
'fax' = dbo.fun_ParsePhoneNumberWithExtension(faxpreprefix, faxprefix, Nfax, null),
'managerName'= Menahel,
Int1.email,
SugMosad,
'StatusSimul' = CASE StatusSimul WHEN 1 THEN 'פתוח' ELSE 'סגור' END,
OpenDateSimul,
ClosingDateSimul,
'ExistsInDept' = CASE IsNull(dept.deptCode, 0) WHEN 0 THEN 0 ELSE 1 END
FROM InterfaceFromSimulNewDepts as Int1 
LEFT JOIN dept as d ON Int1.DistrictId = d.deptCode 
LEFT JOIN SugSimul501 as t501 ON t501.SugSimul = Int1.SugSimul501 
LEFT JOIN UnitType ON UnitType.UnitTypeCode = Int1.Key_typUnit 
LEFT JOIN PopulationSectors ON PopulationSectors.PopulationSectorId = Int1.PopSectorID
LEFT JOIN dept ON Int1.SimulDeptId = dept.deptCode
LEFT JOIN Cities ON Int1.City = Cities.CityCode 
WHERE SimulDeptId = @DeptCode

GO

GRANT EXEC ON rpc_getNewClinic TO PUBLIC

GO

