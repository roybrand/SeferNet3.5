IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_deleteDeptQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_deleteDeptQueueOrderMethods
	(
		@DeptCode int,
		@ErrCode int OUTPUT
	)

AS

		DELETE FROM DeptQueueOrderHours
		WHERE QueueOrderMethodID IN (SELECT QueueOrderMethodID 
									FROM DeptQueueOrderMethod
									WHERE deptCode = @DeptCode)
		SET @ErrCode = @@Error
									
		DELETE FROM DeptQueueOrderPhones
		WHERE QueueOrderMethodID IN (SELECT QueueOrderMethodID 
									FROM DeptQueueOrderMethod
									WHERE deptCode = @DeptCode)
		SET @ErrCode = @@Error
									
		DELETE FROM DeptQueueOrderMethod
		WHERE deptCode = @DeptCode

		SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_deleteDeptQueueOrderMethods TO PUBLIC

GO

