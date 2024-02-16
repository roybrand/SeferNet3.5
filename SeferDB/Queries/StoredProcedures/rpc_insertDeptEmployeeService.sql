IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEmployeeService')
	BEGIN
		DROP  Procedure  rpc_insertDeptEmployeeService
	END
GO

CREATE Procedure [dbo].[rpc_insertDeptEmployeeService]
	(
		@deptEmployeeID INT,
		@ServiceCodes varchar(1000),
		@UpdateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

DECLARE @count int, @currentCount int, @OrderNumber int
DECLARE @CurrServiceCode int
DECLARE @employeeID BIGINT
DECLARE @deptEmployeeServiceID INT
SET @OrderNumber = 1

SET @count = IsNull((SELECT COUNT(IntField) FROM SplitString(@ServiceCodes)), 0)
IF (@count = 0)
BEGIN
	RETURN
END

	
SET @employeeID =  (SELECT EmployeeID
					FROM x_dept_employee
					WHERE DeptEmployeeID = @deptEmployeeID
					)					
	
	SET @currentCount = @count
	
	WHILE(@currentCount > 0)
		BEGIN
		
			SET @CurrServiceCode = (SELECT IntField FROM SplitString(@ServiceCodes) WHERE OrderNumber = @OrderNumber) 
			
			-- first of all, insert as employee service if not exists
			IF NOT EXISTS (SELECT ServiceCode 
						   FROM EmployeeServices
						   WHERE ServiceCode = @CurrServiceCode AND EmployeeID = @employeeID
						   )
					INSERT INTO EmployeeServices (EmployeeID, serviceCode, updateUser)
					VALUES (@EmployeeID, @CurrServiceCode, @UpdateUser)
							   
			-- insert as employee service in Dept if not exists			
			IF NOT EXISTS (SELECT ServiceCode
						   FROM x_Dept_Employee_Service xdes						   
						   WHERE ServiceCode = @CurrServiceCode 
						   AND DeptEmployeeID = @deptEmployeeID						   
						   )
				BEGIN				
					
					--INSERT INTO x_Dept_Employee_Service
					--( serviceCode, UpdateDate, updateUser, CascadeUpdateEmployeeServicePhones, DeptEmployeeID)
					--VALUES
					--(@CurrServiceCode, GETDATE(), @UpdateUser, 1, @deptEmployeeID)
					
					INSERT INTO x_Dept_Employee_Service
					( serviceCode, UpdateDate, updateUser, CascadeUpdateEmployeeServicePhones, DeptEmployeeID, QueueOrder)
					SELECT ServiceCode, GETDATE(), @UpdateUser, 1, @deptEmployeeID
					,CASE RequiresQueueOrder WHEN 0 THEN 2 ELSE NULL END as RequiresQueueOrder -- 2 means not required queue order
					FROM [Services] S
					WHERE S.ServiceCode = @CurrServiceCode					
					
					SET @deptEmployeeServiceID = @@IDENTITY

					INSERT INTO DeptEmployeeServiceStatus 
					(Status, FromDate, UpdateUser, UpdateDate, x_dept_employee_serviceID)
					VALUES 
					(1, GETDATE(), @UpdateUser, GETDATE(), @deptEmployeeServiceID) 					
				END
	
			SET @OrderNumber = @OrderNumber + 1
			SET @currentCount = @currentCount - 1
		END
		
	-- Delete all the receptions of the services that were just deleted
	SELECT der.receptionid
	INTO #tempServiceIds
	FROM DeptEmployeeReception der 	
	INNER JOIN deptEmployeeReceptionServices ders	
	ON der.ReceptionID = ders.ReceptionID
	WHERE der.DeptEmployeeID = @deptEmployeeID
	AND ServiceCode NOT IN	(
									SELECT ServiceCode
									FROM x_Dept_Employee_Service
									WHERE DeptEmployeeID = @deptEmployeeID
								)
	
	DELETE FROM DeptEmployeeReceptionServices
	WHERE ReceptionID IN 
			(
				SELECT ReceptionID
				FROM #tempServiceIds  
			)
			
	DELETE DeptEmployeeReceptionRemarks
	WHERE EmployeeReceptionID IN
	(
		SELECT ReceptionID
		FROM #tempServiceIds  
	)
	
	
	DELETE DeptEmployeeReception
	WHERE ReceptionID IN 
	(
		SELECT ReceptionID
		FROM #tempServiceIds  
	)		
						
	SET @ErrCode = @@Error
	

GO

GRANT EXEC ON rpc_insertDeptEmployeeService TO PUBLIC

GO

