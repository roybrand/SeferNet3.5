IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_CheckIfEmployeeExistsInEmployee')
	BEGIN
		DROP  Procedure  rpc_CheckIfEmployeeExistsInEmployee
	END

GO

CREATE Procedure dbo.rpc_CheckIfEmployeeExistsInEmployee
(
		@employeeID BIGINT,
		@retVal BIT OUTPUT
)

AS

SET @retVal = 0

IF EXISTS
(
	SELECT * FROM Employee
	WHERE EmployeeID = @employeeID  
)
SET @retVal = 1
	
GO


GRANT EXEC ON rpc_CheckIfEmployeeExistsInEmployee TO PUBLIC
GO
