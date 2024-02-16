IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptProfessions')
	BEGIN
		DROP  Procedure  rpc_getDeptProfessions
	END

GO

CREATE Procedure rpc_getDeptProfessions
	(
		@deptCode int
		
	)

AS

SELECT
x_dept_Professions.deptCode,	
x_dept_Professions.professionCode,
professions.professionDescription
FROM x_dept_Professions
INNER JOIN professions ON x_dept_Professions.professionCode = professions.professionCode
WHERE x_dept_Professions.deptCode = @deptCode
GO

GRANT EXEC ON rpc_getDeptProfessions TO PUBLIC

GO


