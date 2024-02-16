IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vInterface_NewDepts]'))
DROP VIEW [dbo].[vInterface_NewDepts]
GO

CREATE VIEW [dbo].[vInterface_NewDepts]
AS
SELECT 
 SimulDeptId, SimulDeptName, dept_name, manageId, SimulManageDescription, 
City, street, house, entrance, flat, zip, 
Preprefix1, Prefix1, Nphone1, preprefix2, prefix2, Nphone2, 
faxpreprefix, faxprefix, Nfax, 
SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, 
DistrictId, SugMosad, 
OpenDateSimul, ClosingDateSimul, StatusSimul, Email, Menahel, 
Simul228, DeptType, key_TypUnit, PopSectorID, NeedToInsertInto_UnitTypeConvertSimul 

FROM( 
SELECT DISTINCT
dept.deptCode,
S403.KodSimul as SimulDeptId,
S403.TeurSimul as SimulDeptName,
'שם לא ידוע' as dept_name,
S403.manageId,
s2.TeurSimul as SimulManageDescription,
case when (S403.City = 0 or MF_Cities200.NewCityCode is null) then 9999
	 else 
		case when (MF_Cities200.ReplacingCode <> 0) then MF_Cities200.ReplacingCode
		else MF_Cities200.NewCityCode
		end
	 end as City,
S403.street,
S403.house,
S403.entrance,
S403.flat,
S403.zip,
S403.Preprefix1,
S403.Prefix1,
S403.phone1 as Nphone1,
S403.preprefix2,
S403.prefix2,
S403.phone2 as Nphone2,
S403.faxpreprfix as faxpreprefix,
S403.faxprefix,
S403.fax as Nfax,
S403.SugSimul501,
S403.TatSugSimul502,
S403.TatHitmahut503,
S403.RamatPeilut504,
ISNULL(CAST((CAST(MF_Cities200.DistrictCode as varchar(3)) + '0000' ) as int), S403.Mahoz) as DistrictId,
S403.SugMosad,
S403.DateOpened as OpenDateSimul,
S403.DateClosed as ClosingDateSimul,
S403.status as StatusSimul,
S403.Email,
S403.Menahel,
CASE WHEN C405.SimulConvertId is null THEN null ELSE CAST (RIGHT( RTRIM( IsNull(C405.SimulConvertId, 0) ), 4) as int) END
	as Simul228,
CASE S403.SugSimul501
		WHEN 65 THEN 1
		WHEN 55 THEN 2
		ELSE 3 END
	as DeptType,
IsNull(UTCS.key_TypUnit, IsNull(UTCS2.key_TypUnit, IsNull(UTCS3.key_TypUnit, IsNull(UTCS4.key_TypUnit, 301)) )) 
	as key_TypUnit,
CASE WHEN UTCS.SugSimul is NOT null THEN  IsNull(UTCS.PopSectorID, 1) 
	 ELSE  
		CASE WHEN UTCS2.SugSimul is NOT null THEN  IsNull(UTCS2.PopSectorID, 1)
			 ELSE
				CASE WHEN UTCS3.SugSimul is NOT null THEN  IsNull(UTCS3.PopSectorID, 1)
				ELSE
					null
				END			
			 END 
	 END
	 as PopSectorID,

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
	as NeedToInsertInto_UnitTypeConvertSimul

FROM Simul403 S403
LEFT JOIN dept ON S403.KodSimul = dept.deptCode
LEFT JOIN Simul403 as s2 ON S403.manageId = s2.KodSimul
LEFT JOIN SimulExceptions SE ON S403.KodSimul = SE.SimulId
LEFT JOIN Conversion405 C405 ON S403.KodSimul = C405.SimulId 
								AND C405.SystemId = 11 AND C405.InActive = 0
LEFT JOIN (SELECT DISTINCT SugSimul, TatSugSimul, TatHitmahut, RamatPeilut, key_TypUnit, PopSectorID
			FROM UnitTypeConvertSimul WHERE key_TypUnit is not NULL ) UTCS 
			ON S403.SugSimul501 = UTCS.SugSimul
			AND S403.TatSugSimul502 = UTCS.TatSugSimul
			AND S403.TatHitmahut503 = UTCS.TatHitmahut
			AND (UTCS.RamatPeilut is null OR S403.RamatPeilut504 = UTCS.RamatPeilut	)
LEFT JOIN (SELECT DISTINCT SugSimul, TatSugSimul, TatHitmahut,key_TypUnit, PopSectorID
			FROM UnitTypeConvertSimul WHERE key_TypUnit is not NULL ) UTCS2 
			ON S403.SugSimul501 = UTCS2.SugSimul
			AND S403.TatSugSimul502 = UTCS2.TatSugSimul
			AND S403.TatHitmahut503 = UTCS2.TatHitmahut
LEFT JOIN (SELECT DISTINCT SugSimul, TatSugSimul, key_TypUnit, PopSectorID
			FROM UnitTypeConvertSimul WHERE key_TypUnit is not NULL ) UTCS3 
			ON S403.SugSimul501 = UTCS3.SugSimul
			AND S403.TatSugSimul502 = UTCS3.TatSugSimul
LEFT JOIN (SELECT DISTINCT SugSimul, key_TypUnit, PopSectorID
			FROM UnitTypeConvertSimul WHERE key_TypUnit is not NULL AND TatSugSimul = 0  ) UTCS4 
			ON S403.SugSimul501 = UTCS4.SugSimul			
									
LEFT JOIN MF_Cities200 ON S403.City = MF_Cities200.Code

WHERE (dept.deptCode is null
		AND ( SE.SeferSherut = 1
			OR 
			(SE.SeferSherut is null AND DATEDIFF(d, S403.DateOpened, GETDATE()) < 365 AND dbo.fun_IsForSeferBy501To503(S403.KodSimul) = 1) )
			
		AND (ISNULL(SE.SeferSherut, 2) <> 0 )
	  )
	  OR
	  (dept.deptCode is NOT null
		AND dept.IsCommunity = 0
		AND DATEDIFF(d, S403.DateOpened, GETDATE()) < 365
	  )
	  
 ) as T


GO



GO





