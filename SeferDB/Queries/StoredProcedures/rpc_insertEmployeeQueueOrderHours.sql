IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeQueueOrderHours')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeQueueOrderHours
	END

GO

CREATE PROCEDURE dbo.rpc_insertEmployeeQueueOrderHours
	(
		@QueueOrderMethodID int,
		@ReceptionDay int,
		@FromHour varchar(5),
		@ToHour varchar(5),
		@updateUser varchar(50),
		@ErrCode int = 0 OUTPUT
	)

AS



	INSERT INTO EmployeeQueueOrderHours
	(QueueOrderMethodID, receptionDay, FromHour, ToHour, updateDate, updateUser)
	VALUES
	(@QueueOrderMethodID, @ReceptionDay, @FromHour, @ToHour, getdate(), @updateUser)

	SET @ErrCode = @@Error


GO

GRANT EXEC ON rpc_insertEmployeeQueueOrderHours TO PUBLIC

GO

