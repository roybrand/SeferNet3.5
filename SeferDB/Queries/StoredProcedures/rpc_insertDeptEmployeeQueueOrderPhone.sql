IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEmployeeQueueOrderPhone')
	BEGIN
		DROP  Procedure  rpc_insertDeptEmployeeQueueOrderPhone
	END

GO

CREATE Procedure dbo.rpc_insertDeptEmployeeQueueOrderPhone
	(
		@QueueOrderMethodID int,
		@prePrefix int,
		@prefix int,
		@phone int,
		@extension int,
		@updateUser varchar(50),
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
					FROM DeptEmployeeQueueOrderPhones 
					WHERE QueueOrderMethodID = @QueueOrderMethodID)
SET @PhoneOrder = IsNull(@PhoneOrder,1)

	INSERT INTO DeptEmployeeQueueOrderPhones
	(
		QueueOrderMethodID,
		phoneType,
		phoneOrder,
		prePrefix,
		prefix,
		phone,
		extension,
		updateDate,
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
		getdate(),
		@updateUser
	)
	
	SET @ErrCode = @@Error


GO

GRANT EXEC ON rpc_insertDeptEmployeeQueueOrderPhone TO PUBLIC

GO

