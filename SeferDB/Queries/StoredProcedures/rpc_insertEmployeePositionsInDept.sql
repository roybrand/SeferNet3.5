IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeePositionsInDept')
	BEGIN
		DROP  Procedure  rpc_insertEmployeePositionsInDept
	END

GO

CREATE PROCEDURE dbo.rpc_insertEmployeePositionsInDept
	(
		@EmployeeID int,
		@DeptCode int,
		@PositionCodes varchar(50),
		@UpdateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

DECLARE @count int, @currentCount int, @OrderNumber int
DECLARE @CurrPositionCode int

SET @OrderNumber = 1
SET @count = IsNull((SELECT COUNT(IntField) FROM SplitString(@PositionCodes)), 0)
IF (@count = 0)
BEGIN
	RETURN
END

	DECLARE @deptEmployeeID INT 
	SELECT @deptEmployeeID =	DeptEmployeeID
								FROM x_dept_employee
								WHERE DeptCode = @deptCode 
								AND EmployeeID = @employeeID
	
	SET @currentCount = @count
	
	WHILE(@currentCount > 0)
		BEGIN

			SET @CurrPositionCode = (SELECT IntField FROM SplitString(@PositionCodes) WHERE OrderNumber = @OrderNumber)

			INSERT INTO x_Dept_Employee_Position
			( positionCode, updateUser, updateDate, DeptEmployeeID)
			VALUES
			(@CurrPositionCode, @UpdateUser, getdate(), @deptEmployeeID)

			SET @OrderNumber = @OrderNumber + 1
			SET @currentCount = @currentCount - 1
		END
						
	SET @ErrCode = @@Error
	

GO

GRANT EXEC ON rpc_insertEmployeePositionsInDept TO PUBLIC

GO

