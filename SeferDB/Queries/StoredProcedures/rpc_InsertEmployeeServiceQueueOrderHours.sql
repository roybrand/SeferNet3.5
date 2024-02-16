IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServiceQueueOrderHours')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderHours
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertEmployeeServiceQueueOrderHours]
	(
		@EmployeeServiceQueueOrderMethodID int,
		@ReceptionDay int,
		@FromHour varchar(5),
		@ToHour varchar(5),
		@updateUser varchar(50),
		@ErrCode int = 0 OUTPUT
	)

AS



	INSERT INTO EmployeeServiceQueueOrderHours
	(EmployeeServiceQueueOrderMethodID, ReceptionDay, FromHour, ToHour, updateUser)
	VALUES
	(@EmployeeServiceQueueOrderMethodID, @ReceptionDay, @FromHour, @ToHour, @updateUser)

	SET @ErrCode = @@ERROR


GO


GRANT EXEC ON rpc_InsertEmployeeServiceQueueOrderHours TO PUBLIC
GO