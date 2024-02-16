IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetAllEmployeeDegree')
	BEGIN
		DROP  Procedure  rpc_GetAllEmployeeDegree
	END

GO

CREATE Procedure rpc_GetAllEmployeeDegree

AS

SELECT *
FROM DIC_EmployeeDegree
ORDER BY DegreeName



GO

GRANT EXEC ON rpc_GetAllEmployeeDegree TO PUBLIC

GO

