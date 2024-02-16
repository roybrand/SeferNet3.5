IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_updateEmployeeExpertise')
	BEGIN
		DROP  Procedure  rpc_updateEmployeeExpertise
	END

GO

create Procedure [dbo].[rpc_updateEmployeeExpertise]
(
	@employeeID INT,
	@professionCodes VARCHAR(50),
	@updateUser VARCHAR(50)	
)

AS


	DECLARE @count int, @currentCount int
	DECLARE @curProfCode int
	
	Declare @MinProfCode int
	SET @curProfCode = 0
	Set @MinProfCode = 0
	SET @count = (Select count(IntField) from  dbo.SplitString(@professionCodes))

	-- RESET ALL THE EXPERTISES
	UPDATE EmployeeServices
	SET expProfession = 0 
	WHERE EmployeeID = @employeeID
	
	
	IF( @count > 0)
		BEGIN 

			SET @currentCount = @count

			WHILE (@currentCount > 0)
				BEGIN
				
					SET @curProfCode = (select min(IntField) from dbo.SplitString(@professionCodes)
											where IntField > @MinProfCode)
				
					SET @MinProfCode = @curProfCode
												   
					UPDATE EmployeeServices
					SET expProfession = 1,  updateUser = @UpdateUser
					WHERE EmployeeID = @employeeID AND serviceCode = @curProfCode
										
					SET @currentCount = @currentCount -1
				
				END

			UPDATE Employee
			SET updateDate = GETDATE()
			WHERE employeeID = @EmployeeID

		 end
GO

GRANT EXEC ON rpc_updateEmployeeExpertise TO PUBLIC

GO