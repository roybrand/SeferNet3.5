IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeService')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeService
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeeService
	(
		@EmployeeID int,
		@ServiceCode int = NULL
	)

AS

DELETE FROM EmployeeServices
WHERE EmployeeID = @EmployeeID 
AND serviceCode = IsNull(@ServiceCode, serviceCode)
AND serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 0)

UPDATE Employee
SET updateDate = GETDATE()
WHERE employeeID = @EmployeeID
GO

GRANT EXEC ON rpc_deleteEmployeeService TO PUBLIC

GO

