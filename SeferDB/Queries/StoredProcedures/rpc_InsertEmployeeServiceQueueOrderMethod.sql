IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServiceQueueOrderMethod')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderMethod
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertEmployeeServiceQueueOrderMethod]
	(
		@x_Dept_Employee_ServiceID int,
		@QueueOrderMethod int, 
		@updateUser varchar(50),
		@ErrCode int OUTPUT,
		@newID int OUTPUT
	)

AS

		INSERT INTO EmployeeServiceQueueOrderMethod
		(QueueOrderMethod, updateUser, x_dept_employee_serviceID)
		SELECT @QueueOrderMethod, @updateUser, x_dept_employee_serviceID
		FROM x_Dept_Employee_Service xDES
		WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
				
		SET @ErrCode = @@ERROR
		SET @newID = @@IDENTITY
		
GO


GRANT EXEC ON rpc_InsertEmployeeServiceQueueOrderMethod TO PUBLIC
GO