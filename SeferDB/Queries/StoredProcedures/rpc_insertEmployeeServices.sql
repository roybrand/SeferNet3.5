IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeServices')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeServices
	END

GO

CREATE Procedure dbo.rpc_insertEmployeeServices
	(
		@EmployeeID int,
		@ServicesCodes varchar(50),
		@UpdateUser varchar(50)		
	)

AS
	DECLARE @count int, @currentCount int
	DECLARE @curServCode int
	
	Declare @MinServCode int
	SET @curServCode = 0
	Set @MinServCode = 0
	SET @count = (Select count(IntField) from  dbo.SplitString(@ServicesCodes))

	IF( @count > 0)
		BEGIN 

			SET @currentCount = @count

			WHILE (@currentCount > 0)
				BEGIN
				
					SET @curServCode = (select min(IntField) from dbo.SplitString(@ServicesCodes)
											where IntField > @MinServCode)
				
					SET @MinServCode = @curServCode
					
					IF NOT EXISTS 
					(
						SELECT ServiceCode
						FROM EmployeeServices
						WHERE EmployeeID = @EmployeeID AND ServiceCode = @curServCode
					)
												   
					INSERT INTO EmployeeServices 
					(EmployeeID, serviceCode, updateUser)
					VALUES 
					(@EmployeeID, @curServCode, @UpdateUser)
					
					SET @currentCount = @currentCount -1
				
				END

				UPDATE Employee
				SET updateDate = GETDATE()
				WHERE employeeID = @EmployeeID

			END 


GO

GRANT EXEC ON rpc_insertEmployeeServices TO PUBLIC

GO