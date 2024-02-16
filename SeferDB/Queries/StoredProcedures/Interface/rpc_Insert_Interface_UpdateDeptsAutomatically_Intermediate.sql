IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Insert_Interface_UpdateDeptsAutomatically_Intermediate')
	BEGIN
		DROP  Procedure  rpc_Insert_Interface_UpdateDeptsAutomatically_Intermediate
	END

GO

CREATE Procedure dbo.rpc_Insert_Interface_UpdateDeptsAutomatically_Intermediate

AS

INSERT INTO Interface_UpdateDeptsAutomatically_Intermediate
(deptCode, DeptNameSimul, OpenDateSimul, ClosingDateSimul, StatusSimul, simul228, SimulManageDescription, deptType)

SELECT
deptCode, DeptNameSimul_MF as DeptNameSimul, OpenDate_MF as OpenDateSimul, ClosingDate_MF as ClosingDateSimul, StatusSimul_MF as StatusSimul, simul228new as simul228, SimulManageDescription_MF as SimulManageDescription, DeptType_MF as DeptType  
 
FROM (
	SELECT 
		ExistingDepts.*,
		CASE WHEN OpenDate_MF = OpenDate_sefer 
			  and IsNull(ClosingDate_MF, '00:00:00') = IsNull(ClosingDate_sefer, '00:00:00')
			  and IsNull(StatusSimul_MF, -1) = IsNull(StatusSimul_sefer, -1)
			  and IsNull(SimulManageDescription_MF, '') = IsNull(SimulManageDescription_sefer, '')
			  and IsNull(simul228_sefer, 0) = IsNull(simul228new, 0)
			  and IsNull(DeptNameSimul_MF, '') = IsNull(DeptNameSimul_sefer, '')
			  --and IsNull(DeptType_MF, '') = IsNull(deptType_sefer, '')			  
			  THEN 0 ELSE 1 END 
			as SomeDetailsChanged
	FROM (
		SELECT
		Dept.deptCode,
		S403.Mahoz as districtCode,
		DS.ClosingDateSimul as ClosingDate_sefer,
		DS.OpenDateSimul as OpenDate_sefer,
		DS.StatusSimul as StatusSimul_sefer,
		S403.TeurSimul as DeptNameSimul_MF,
		DS.deptNameSimul as DeptNameSimul_sefer,
		DS.simul228 as simul228_sefer,
		DS.SimulManageDescription as SimulManageDescription_sefer,
		S403.status as StatusSimul_MF,
		S403.manageId,
		S403.DateOpened as OpenDate_MF,
		S403.DateClosed as ClosingDate_MF,
		s2.TeurSimul as SimulManageDescription_MF,
		CASE WHEN C405.SimulConvertId is null THEN null ELSE CAST (RIGHT( RTRIM( IsNull(C405.SimulConvertId, 0) ), 4) as int) END 
			as simul228new,
		CASE S403.SugSimul501
					WHEN 65 THEN 1
					WHEN 55 THEN 2
					ELSE 3 END 
			as DeptType_MF,
		Dept.deptType as deptType_sefer, 
		CASE WHEN (	IsNull(DS.SugSimul501, 0) = IsNull(S403.SugSimul501, 0) 
				AND IsNull(DS.TatSugSimul502, 0) = IsNull(S403.TatSugSimul502, 0)
				AND IsNull(DS.TatHitmahut503, 0) = IsNull(S403.TatHitmahut503, 0)
				AND IsNull(DS.RamatPeilut504, 0) = IsNull(S403.RamatPeilut504, 0) ) THEN 0 ELSE 1 END
			as SivugSimulChanged,
		CASE WHEN (IsNull(dept.subAdministrationCode, 0) = IsNull(S403.manageId, 0)) THEN  0 ELSE 1 END 
			as ManageIdChanged
		
		FROM Simul403 S403
		LEFT JOIN dept ON S403.KodSimul = dept.deptCode
		LEFT JOIN DeptSimul DS ON dept.deptCode = DS.deptCode
		LEFT JOIN Simul403 as s2 ON S403.manageId = s2.KodSimul
		LEFT JOIN vConversion405 C405 ON S403.KodSimul = C405.SimulId 
									AND C405.SystemId = 11 AND C405.InActive = 0
		
		WHERE dept.deptCode is not null
		) as ExistingDepts

	) as T
WHERE SomeDetailsChanged = 1
GO

GRANT EXEC ON rpc_Insert_Interface_UpdateDeptsAutomatically_Intermediate TO PUBLIC

GO

