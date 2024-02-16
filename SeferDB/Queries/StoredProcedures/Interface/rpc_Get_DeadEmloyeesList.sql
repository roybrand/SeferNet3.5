IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Get_DeadEmloyeesList')
	BEGIN
		DROP  Procedure  rpc_Get_DeadEmloyeesList
	END

GO

CREATE Procedure dbo.rpc_Get_DeadEmloyeesList

AS

SELECT E.employeeID, E.licenseNumber, E.lastName, E.firstName,  TR226.DeadDate as DeathDate, TR226.DelFlag  
FROM employee E
INNER JOIN TR_DoctorsInfo226 TR226 ON E.employeeID = CAST( (CAST(TR226.PersonID as varchar(10)) + CAST(TR226.IDControlDigit as varchar(1)) ) as bigint)
WHERE TR226.DeadDate is not null 
AND E.active = 1
AND E.EmployeeSectorCode = 7
GO

GRANT EXEC ON rpc_Get_DeadEmloyeesList TO PUBLIC

GO

