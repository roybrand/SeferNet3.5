IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_CheckIfEmployeeIsDoctor')
	BEGIN
		DROP  Procedure  rpc_CheckIfEmployeeIsDoctor
	END

GO

CREATE Procedure rpc_CheckIfEmployeeIsDoctor
(
	@employeeID BIGINT
)

AS

IF EXISTS
(
	SELECT *
	FROM Employee e
	INNER JOIN EmployeeSector es
	ON e.EmployeeSectorCode = es.EmployeeSectorCode
	WHERE es.IsDoctor = 1 AND EmployeeID = @employeeID
	
)
	SELECT 1
ELSE
	SELECT 0


GO


GRANT EXEC ON rpc_CheckIfEmployeeIsDoctor TO PUBLIC

GO


