IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateEmployeeProfession')
	BEGIN
		DROP  Procedure  rpc_updateEmployeeProfession
	END

GO

CREATE PROCEDURE dbo.rpc_updateEmployeeProfession
	(
		@EmployeeID int,
		@ProfessionCode int,
		@MainProfession int,
		@ExpProfession int,
		@UpdateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

	UPDATE EmployeeServices
	SET expProfession = @ExpProfession
	WHERE EmployeeID = @EmployeeID
		AND serviceCode = @ProfessionCode
	
	SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_updateEmployeeProfession TO PUBLIC

GO

