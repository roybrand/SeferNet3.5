IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptQueueOrderPhone')
	BEGIN
		DROP  Procedure  rpc_insertDeptQueueOrderPhone
	END

GO

CREATE Procedure dbo.rpc_insertDeptQueueOrderPhone
	(
		@QueueOrderMethodID int,
		@prePrefix int,
		@prefix int,
		@phone int,
		@extension int,
		@UpdateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

IF(@prefix = -1)
	BEGIN
		SET @prefix = null
	END
	
IF(@prePrefix = -1)	
	BEGIN
		SET @prePrefix = null
	END
	
IF(@extension = -1)	
	BEGIN
		SET @extension = null
	END

DECLARE @PhoneOrder int
SET @PhoneOrder = (SELECT MAX(PhoneOrder) + 1 
					FROM DeptQueueOrderPhones 
					WHERE QueueOrderMethodID = @QueueOrderMethodID)
SET @PhoneOrder = IsNull(@PhoneOrder,1)

	INSERT INTO DeptQueueOrderPhones
	(
		QueueOrderMethodID,
		phoneType,
		phoneOrder,
		prePrefix,
		prefix,
		phone,
		extension,
		updateUser	
	)
	VALUES
	(
		@QueueOrderMethodID,
		1,
		@PhoneOrder,
		@prePrefix,
		@prefix,
		@phone,
		@extension,
		@UpdateUser
	)
	SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_insertDeptQueueOrderPhone TO PUBLIC

GO

