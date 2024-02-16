IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeStatus')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeStatus
	END

GO

CREATE Procedure dbo.rpc_DeleteEmployeeStatus
(
	@employeeID BIGINT,
	@ErrorStatus int = 0 output 
)

AS


		DELETE EmployeeStatus
		WHERE EmployeeID = @employeeID
				
		SET @ErrorStatus = @@ERROR


GO


GRANT EXEC ON rpc_DeleteEmployeeStatus TO PUBLIC

GO


