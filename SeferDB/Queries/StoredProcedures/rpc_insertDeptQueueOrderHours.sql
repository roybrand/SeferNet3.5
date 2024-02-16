IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptQueueOrderHours')
	BEGIN
		DROP  Procedure  rpc_insertDeptQueueOrderHours
	END

GO

CREATE Procedure dbo.rpc_insertDeptQueueOrderHours
	(
		@QueueOrderMethodID int,
		@receptionDay int,
		@FromHour varchar(5),
		@ToHour varchar(5),
		@UpdateUser varchar(50),
		@ErrCode int = 0 OUTPUT
	)

AS

	INSERT INTO DeptQueueOrderHours
	(QueueOrderMethodID, receptionDay, FromHour, ToHour, updateUser)
	VALUES
	(@QueueOrderMethodID, @receptionDay, @FromHour, @ToHour, @UpdateUser)
	
	SET @ErrCode = @@ERROR
	
GO

GRANT EXEC ON rpc_insertDeptQueueOrderHours TO PUBLIC

GO

