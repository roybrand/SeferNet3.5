IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeePhones')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeePhones
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeePhones
	(
		@EmployeeID bigint
	)
AS

		DELETE FROM EmployeePhones
		WHERE employeeID = @EmployeeID
			
GO

GRANT EXEC ON rpc_deleteEmployeePhones TO PUBLIC

GO
