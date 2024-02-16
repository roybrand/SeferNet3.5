IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Insert_Interface_UpdateDeptsManually_Intermediate')
	BEGIN
		DROP  Procedure  rpc_Insert_Interface_UpdateDeptsManually_Intermediate
	END

GO

CREATE Procedure dbo.rpc_Insert_Interface_UpdateDeptsManually_Intermediate

AS

INSERT INTO Interface_UpdateDeptsManually_Intermediate 
( SimulDeptId, SimulDeptName, districtCode, StatusSimul, manageId, SimulManageDescription, 
cityCode, street, house, entrance, flat, zipCode, 
SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, SugMosad, 
OpenDateSimul, ClosingDateSimul, 
Email, Menahel, 
Simul228, DeptType, typeUnitCode, 
SivugSimulChanged, ManageIdChanged, PopSectorID, NeedToInsertInto_UnitTypeConvertSimul)

SELECT 
SimulDeptId, SimulDeptName, districtCode, StatusSimul, manageId, SimulManageDescription, 
cityCode, street, house, entrance, flat, zipCode, 
SugSimul501_MF as SugSimul501, TatSugSimul502_MF as TatSugSimul502, TatHitmahut503_MF as TatHitmahut503, RamatPeilut504, SugMosad, 
OpenDateSimul, ClosingDateSimul, 
Email, Menahel, 
simul228new	as Simul228, DeptType, key_TypUnit AS typeUnitCode, 
SivugSimulChanged, ManageIdChanged, PopSectorID, NeedToInsertInto_UnitTypeConvertSimul
 
FROM (
SELECT 
	ExistingDepts.*
FROM (
	SELECT  DISTINCT
	dept.deptCode as SimulDeptId,
	dept.subAdministrationCode,
	S403.Mahoz as districtCode,
	S403.TeurSimul as SimulDeptName,
	DS.simul228 as simul228_sefer,
	S403.manageId,
	S403.status as StatusSimul,
	S403.DateOpened as OpenDateSimul,
	S403.DateClosed as ClosingDateSimul,
	S403.SugSimul501 as SugSimul501_MF,
	S403.TatSugSimul502 as TatSugSimul502_MF,
	S403.TatHitmahut503 as TatHitmahut503_MF,
	S403.RamatPeilut504,
	S403.SugMosad,
	S403.Email,
	S403.Menahel, 
	S403.City as cityCode,
	S403.street,
	S403.house,
	S403.entrance,
	S403.flat,
	S403.zip as zipCode,
	s2.TeurSimul as SimulManageDescription,
	1 as IsInSefer,
	CASE WHEN C405.SimulConvertId is null THEN null ELSE CAST (RIGHT( RTRIM( IsNull(C405.SimulConvertId, 0) ), 4) as int) END
		as simul228new,
	CASE S403.SugSimul501
			WHEN 65 THEN 1
			WHEN 55 THEN 2
			ELSE 3 END
		as DeptType,
	UTCS.key_TypUnit,
	CASE WHEN (	IsNull(DS.SugSimul501, 0) = IsNull(S403.SugSimul501, 0) 
			AND IsNull(DS.TatSugSimul502, 0) = IsNull(S403.TatSugSimul502, 0)
			AND IsNull(DS.TatHitmahut503, 0) = IsNull(S403.TatHitmahut503, 0)
			AND IsNull(DS.RamatPeilut504, 0) = IsNull(S403.RamatPeilut504, 0) ) THEN 0 ELSE 1 END
		as SivugSimulChanged,
	CASE WHEN (IsNull(dept.subAdministrationCode, 0) = IsNull(S403.manageId, 0)) THEN  0 ELSE 1 END
		as ManageIdChanged,
	null as PopSectorID,

	CASE WHEN	(
				SELECT COUNT(*) FROM UnitTypeConvertSimul UT 
				WHERE UT.SugSimul = S403.SugSimul501
				AND (	IsNull(S403.TatSugSimul502, 0) = 0 
						OR 
						(UT.TatSugSimul = S403.TatSugSimul502
							AND (IsNull(S403.TatHitmahut503, 0) = 0
								OR 
									(UT.TatHitmahut = S403.TatHitmahut503
										AND (IsNull(S403.RamatPeilut504, 0) = 0
											OR UT.RamatPeilut = S403.RamatPeilut504
											)
									)
								)
						) 
					)
				) > 0 THEN 0 ELSE 1 END
		as NeedToInsertInto_UnitTypeConvertSimul,
		
	CASE WHEN DS.SugSimul501 = S403.SugSimul501
		  and IsNull(DS.TatSugSimul502, -1) = IsNull(S403.TatSugSimul502, -1)
		  and IsNull(DS.TatHitmahut503, -1) = IsNull(S403.TatHitmahut503, -1)
		  THEN 0 ELSE 1 END 
		as Combination501to503Changed 
	
	
	FROM Simul403 S403
	INNER JOIN dept ON S403.KodSimul = dept.deptCode
	LEFT JOIN DeptSimul DS ON dept.deptCode = DS.deptCode
	LEFT JOIN Simul403 as s2 ON S403.manageId = s2.KodSimul
	LEFT JOIN vConversion405 C405 ON S403.KodSimul = C405.SimulId 
								AND C405.SystemId = 11 AND C405.InActive = 0
	LEFT JOIN UnitTypeConvertSimul UTCS ON S403.SugSimul501 = UTCS.SugSimul
								AND S403.TatSugSimul502 = UTCS.TatSugSimul
								AND S403.TatHitmahut503 = UTCS.TatHitmahut
								AND S403.TatHitmahut503 = UTCS.RamatPeilut
) as ExistingDepts

) as T
WHERE Combination501to503Changed = 1

GO


GRANT EXEC ON rpc_Insert_Interface_UpdateDeptsManually_Intermediate TO PUBLIC

GO


