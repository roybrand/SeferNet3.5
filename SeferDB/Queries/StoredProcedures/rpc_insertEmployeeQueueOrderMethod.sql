IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeQueueOrderMethod')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeQueueOrderMethod
	END

GO

CREATE Procedure dbo.rpc_insertEmployeeQueueOrderMethod
	(
		@deptEmployeeID int,
		@QueueOrderMethod int, 
		@updateUser varchar(50),
		@ErrCode int OUTPUT,
		@newID int OUTPUT
	)

AS			   

	INSERT INTO EmployeeQueueOrderMethod
	(QueueOrderMethod, updateDate, updateUser, DeptEmployeeID)
	VALUES
	(@QueueOrderMethod, getdate(), @updateUser, @deptEmployeeID)

				
	SET @ErrCode = @@Error
	SET @newID = @@IDENTITY
		
GO

GRANT EXEC ON rpc_insertEmployeeQueueOrderMethod TO PUBLIC

GO

