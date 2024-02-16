IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeProfession')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeProfession
	END

GO

CREATE Procedure dbo.rpc_insertEmployeeProfession
	(
		@EmployeeID int,
		@ProfesionCodes varchar(max),
		@UpdateUser varchar(max)	
	)

AS

	DECLARE @count int, @currentCount int
	DECLARE @curProfCode int
	
	Declare @MinProfCode int
	SET @curProfCode = 0
	Set @MinProfCode = 0
	SET @count = (Select count(IntField) from  dbo.SplitString(@ProfesionCodes))

	IF( @count > 0)
		BEGIN 

			SET @currentCount = @count

			WHILE (@currentCount > 0)
				BEGIN
				
					SET @curProfCode = (select min(IntField) from dbo.SplitString(@ProfesionCodes)
											where IntField > @MinProfCode)
				
					SET @MinProfCode = @curProfCode
												   
					IF NOT EXISTS 
					(
						SELECT EmployeeID, serviceCode
						FROM EmployeeServices
						WHERE EmployeeID = @EmployeeID AND serviceCode = @curProfCode
					)
					INSERT INTO EmployeeServices 
					(EmployeeID, serviceCode, mainProfession, expProfession, updateUser)
					VALUES 
					(@EmployeeID, @curProfCode, 0, 0, @UpdateUser)
					
					SET @currentCount = @currentCount -1
				
				END

				UPDATE Employee
				SET updateDate = GETDATE()
				WHERE employeeID = @EmployeeID

		END 

GO

GRANT EXEC ON rpc_insertEmployeeProfession TO PUBLIC

GO
