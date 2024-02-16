IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_IsEmployeeParaMedicalOrSiudSector')
	BEGIN
		DROP  Procedure  rpc_IsEmployeeParaMedicalOrSiudSector
	END

GO

CREATE Procedure dbo.rpc_IsEmployeeParaMedicalOrSiudSector
(
	@employeeID  BIGINT,
	@retValue BIT OUTPUT
	
)

AS


SET @retValue = 0

IF EXISTS
(
	SELECT EmployeeID
	FROM Employee
	WHERE EmployeeID = @employeeID
	AND EmployeeSectorCode IN (2,5)
)
SET @retValue = 1




GO


GRANT EXEC ON rpc_IsEmployeeParaMedicalOrSiudSector TO PUBLIC

GO


