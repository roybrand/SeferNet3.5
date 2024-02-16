IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetIntegerDevidedByCountForEmployeesDeadOrDeletedOnMF')
	BEGIN
		DROP  Procedure  rpc_GetIntegerDevidedByCountForEmployeesDeadOrDeletedOnMF
	END

GO
/* To fail or not to fail - this is the purpose */
CREATE Procedure dbo.rpc_GetIntegerDevidedByCountForEmployeesDeadOrDeletedOnMF

AS

SELECT 1/COUNT(*)
FROM employee E
INNER JOIN TR_DoctorsInfo226 TR226 ON E.employeeID = CAST( (CAST(TR226.PersonID as varchar(10)) + CAST(TR226.IDControlDigit as varchar(1)) ) as bigint)
WHERE (TR226.DeadDate is NOT null AND E.DeathDate is null)
OR (TR226.DelFlag = 1 AND TR226.DelFlag <> E.DelFlagIn226)

GO

GRANT EXEC ON rpc_GetIntegerDevidedByCountForEmployeesDeadOrDeletedOnMF TO PUBLIC

GO

