IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptQueueOrderMethod')
	BEGIN
		DROP  Procedure  rpc_insertDeptQueueOrderMethod
	END

GO

CREATE Procedure dbo.rpc_insertDeptQueueOrderMethod
	(
		@DeptCode int,
		@QueueOrderMethod int,
		@UpdateUser varchar(50),
		@ErrCode int = 0 OUTPUT,
		@QueueOrderMethodID int = 0 OUTPUT
	)

AS

	INSERT INTO DeptQueueOrderMethod
	(QueueOrderMethod, deptCode, updateDate, updateUser)
	VALUES
	(@QueueOrderMethod, @DeptCode, getdate(), @UpdateUser)
	
	SET @ErrCode = @@Error
	SET @QueueOrderMethodID = @@IDENTITY

GO

GRANT EXEC ON rpc_insertDeptQueueOrderMethod TO PUBLIC

GO

