IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertServiceQueueOrderHours')
	BEGIN
		DROP  Procedure  rpc_insertServiceQueueOrderHours
	END

GO

CREATE PROCEDURE dbo.rpc_insertServiceQueueOrderHours
	(
		@EmployeeServiceQueueOrderMethodID int,
		@ReceptionDay int,
		@FromHour varchar(5),
		@ToHour varchar(5),
		@UpdateUser varchar(50),
		@ErrCode int = 0 OUTPUT
	)

AS

	INSERT INTO EmployeeServiceQueueOrderHours
	(EmployeeServiceQueueOrderMethodID, receptionDay, FromHour, ToHour, updateDate, UpdateUser)
	VALUES
	(@EmployeeServiceQueueOrderMethodID, @ReceptionDay, @FromHour, @ToHour, getdate(), @UpdateUser)

	SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_insertServiceQueueOrderHours TO PUBLIC

GO

