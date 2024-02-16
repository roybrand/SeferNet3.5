IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeProfession')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeProfession
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeeProfession
	(
		@EmployeeID int,
		@ServiceCode int = null
	)

AS

DELETE FROM EmployeeServices
WHERE EmployeeID = @EmployeeID 
AND serviceCode = IsNull(@ServiceCode, serviceCode)
AND serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 1)

UPDATE Employee
SET updateDate = GETDATE()
WHERE employeeID = @EmployeeID
GO

GRANT EXEC ON rpc_deleteEmployeeProfession TO PUBLIC

GO

