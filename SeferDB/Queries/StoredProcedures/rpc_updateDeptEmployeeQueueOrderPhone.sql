IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptEmployeeQueueOrderPhone')
	BEGIN
		DROP  Procedure  rpc_updateDeptEmployeeQueueOrderPhone
	END

GO

CREATE PROCEDURE dbo.rpc_updateDeptEmployeeQueueOrderPhone
	(
		@QueueOrderPhoneID int,
		@prePrefix int,
		@prefix int,
		@phone int,
		@updateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

IF @prefix = -1
	BEGIN
		SET @prefix = null
	END
IF @prePrefix = -1
	BEGIN
		SET @prePrefix = null
	END


	UPDATE DeptEmployeeQueueOrderPhones
	SET prePrefix		= @prePrefix,
		prefix			= @prefix,
		phone			= @phone,
		updateDate		= getdate(),
		updateUser		= @updateUser
	WHERE QueueOrderPhoneID = @QueueOrderPhoneID
	
	SET @ErrCode = @@Error


GO

GRANT EXEC ON rpc_updateDeptEmployeeQueueOrderPhone TO PUBLIC

GO

