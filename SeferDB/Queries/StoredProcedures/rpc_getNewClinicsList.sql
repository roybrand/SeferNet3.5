IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getNewClinicsList')
	BEGIN
		DROP  Procedure  rpc_getNewClinicsList
	END

GO

CREATE Procedure [dbo].[rpc_getNewClinicsList]

AS

SELECT * FROM
(  
SELECT SimulDeptId as deptCode, d.DeptName as districtName, Int1.DistrictId as DistrictCode
, SimulDeptName as deptName,  
'SimulManageDescription' = IsNull(Int1.SimulManageDescription, '0'), 
Int1.ManageId,
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
Int1.updateDate,
'ExistsInDept' = CASE IsNull(dept.deptCode, 0) WHEN 0 THEN 0 ELSE 1 END,
'UpdateToCommunity' = CASE IsNull(dept.IsCommunity, -1) WHEN 0 THEN 1 ELSE 0 END
FROM InterfaceFromSimulNewDepts as Int1 
LEFT JOIN dept as d ON Int1.DistrictId = d.deptCode 
LEFT JOIN SugSimul501 as t501 ON t501.SugSimul = Int1.SugSimul501 
LEFT JOIN UnitType ON UnitType.UnitTypeCode = Int1.Key_typUnit 
LEFT JOIN PopulationSectors ON PopulationSectors.PopulationSectorId = Int1.PopSectorID
LEFT JOIN dept ON Int1.SimulDeptId = dept.deptCode
) T
WHERE 	(
			(@SimulDeptID is NOT null OR @SimulDeptName <> '')
			AND	((@SimulDeptID is NOT null AND deptCode = @SimulDeptID)
				OR (@SimulDeptName <> '' AND deptName LIKE '%'+ @SimulDeptName +'%'))
		)
	OR 
		(	(@SimulDeptID is null AND @SimulDeptName = '')
			AND 
			(@OpenDateSimul is null OR @OpenDateSimul <= OpenDateSimul)
			AND 
			(@ExistsInSefer = -1 OR T.ExistsInDept = @ExistsInSefer )
		)

UNION 

SELECT d.deptCode, '' as districtName, DistrictCode, deptName
,'' as SimulManageDescription, 0 as ManageId, ds.SugSimul501, '' as SimulDesc, ds.TatSugSimul502, '' as t502_descr
, ds.TatHitmahut503, '' as t503_descr, ds.RamatPeilut504, '' as t504_descr
, d.typeUnitCode as Key_typUnit, '' as UnitTypeName, ds.openDateSimul, d.populationSectorCode as PopSectorID
, '' as PopulationSectorDescription, d.updateDate, 1 as ExistsInDept
, 'UpdateToCommunity' = CASE IsNull(d.IsCommunity, -1) WHEN 0 THEN 1 ELSE 0 END 

FROM Dept d
LEFT JOIN deptSimul ds ON d.deptCode = ds.deptCode
WHERE (@SimulDeptID is NOT null AND d.deptCode = @SimulDeptID)	

ORDER BY OpenDateSimul DESC 

GO

GRANT EXEC ON rpc_getNewClinicsList TO PUBLIC

GO

