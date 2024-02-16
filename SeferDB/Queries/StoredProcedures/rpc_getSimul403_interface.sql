IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getSimul403_interface')
	BEGIN
		DROP  Procedure  rpc_getSimul403_interface
	END

GO

CREATE Procedure dbo.rpc_getSimul403_interface

AS
/* list of depts already exist in SeferSherut*/
SELECT
dept.deptCode,
dept.districtCode,
dept.subAdministrationCode,
DeptSimul.ClosingDateSimul,
DeptSimul.OpenDateSimul,
DeptSimul.StatusSimul,
DeptSimul.DeptNameSimul,
DeptSimul.simul228,
DeptSimul.SugSimul501 as d_SugSimul501,
DeptSimul.TatSugSimul502 as d_TatSugSimul502,
DeptSimul.TatHitmahut503 as d_TatHitmahut503,
DeptSimul.SimulManageDescription as SimulManageDescription_dept,
S403.*,
s2.TeurSimul as SimulManageDescription,
'IsInSefer' = 1,
'simul228new' = 0,
'IsForSeferBy501To503' = 0

FROM Simul403 S403
LEFT JOIN dept ON S403.KodSimul = dept.deptCode
LEFT JOIN DeptSimul ON dept.deptCode = DeptSimul.deptCode
LEFT JOIN SimulExceptions ON S403.KodSimul = SimulExceptions.SimulId
LEFT JOIN Simul403 as s2 on S403.manageId = s2.KodSimul 
WHERE dept.deptCode is not null

UNION

/* list of depts NOT in SeferSherut but are to be inserted */
SELECT
dept.deptCode,
dept.districtCode,
dept.subAdministrationCode,
DeptSimul.ClosingDateSimul,
DeptSimul.OpenDateSimul,
DeptSimul.StatusSimul,
DeptSimul.DeptNameSimul,
DeptSimul.simul228,
DeptSimul.SugSimul501 as d_SugSimul501,
DeptSimul.TatSugSimul502 as d_TatSugSimul502,
DeptSimul.TatHitmahut503 as d_TatHitmahut503,
DeptSimul.SimulManageDescription as SimulManageDescription_dept,
S403.*,
s2.TeurSimul as SimulManageDescription,
'IsInSefer' = 0,
'simul228new' = dbo.fun_GetSimul228_interface(S403.KodSimul),
'IsForSeferBy501To503' = dbo.fun_IsForSeferBy501To503(S403.KodSimul) 

FROM Simul403 S403
LEFT JOIN dept ON S403.KodSimul = dept.deptCode
LEFT JOIN DeptSimul ON dept.deptCode = DeptSimul.deptCode
LEFT JOIN SimulExceptions ON S403.KodSimul = SimulExceptions.SimulId
LEFT JOIN Simul403 as s2 ON S403.manageId = s2.KodSimul
LEFT JOIN SimulExceptions SE ON S403.KodSimul = SE.SimulId
WHERE dept.deptCode is null
AND ( SE.SeferSherut = 1
	OR 
	(SE.SeferSherut is null AND DATEDIFF(d, S403.DateOpened, GETDATE()) < 8 AND dbo.fun_IsForSeferBy501To503(S403.KodSimul) = 1) )


GO


GRANT EXEC ON rpc_getSimul403_interface TO PUBLIC

GO


