IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Update_Simul228_From_Admin')
	BEGIN
		DROP  Procedure  rpc_Update_Simul228_From_Admin
	END

GO

CREATE Procedure dbo.rpc_Update_Simul228_From_Admin

AS

UPDATE deptSimul   
SET deptSimul.Simul228 = deptSimul_Admin.Simul228
FROM dept D
INNER JOIN deptSimul ON D.deptCode = deptSimul.deptCode
LEFT JOIN dept D_Admin ON D.subAdministrationCode = D_Admin.deptCode
LEFT JOIN deptSimul deptSimul_Admin ON D_Admin.deptCode = deptSimul_Admin.deptCode
WHERE (deptSimul.Simul228 is null OR deptSimul.Simul228 = 0)  
AND (deptSimul_Admin.Simul228 is NOT null AND deptSimul_Admin.Simul228 <> 0)

GO

GRANT EXEC ON rpc_Update_Simul228_From_Admin TO PUBLIC

GO


