IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeesDeadOrDeletedOnMF')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeesDeadOrDeletedOnMF
	END

GO

CREATE Procedure dbo.rpc_UpdateEmployeesDeadOrDeletedOnMF
 
AS

UPDATE employee
SET DeathDate = TR226.DeadDate,
DelFlagIn226 = TR226.DelFlag
FROM employee E
INNER JOIN TR_DoctorsInfo226 TR226 ON E.employeeID = CAST( (CAST(TR226.PersonID as varchar(10)) + CAST(TR226.IDControlDigit as varchar(1)) ) as bigint)
WHERE (TR226.DeadDate is NOT null AND E.DeathDate is null)
OR (TR226.DelFlag = 1 AND TR226.DelFlag <> E.DelFlagIn226)

GO

GRANT EXEC ON rpc_UpdateEmployeesDeadOrDeletedOnMF TO PUBLIC

GO

