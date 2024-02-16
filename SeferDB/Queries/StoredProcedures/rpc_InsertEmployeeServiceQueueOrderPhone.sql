IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServiceQueueOrderPhone')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderPhone
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertEmployeeServiceQueueOrderPhone]
	(
		@EmployeeServiceQueueOrderMethodID int,
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
					FROM EmployeeServiceQueueOrderPhones 
					WHERE EmployeeServiceQueueOrderMethodID = @EmployeeServiceQueueOrderMethodID)
SET @PhoneOrder = IsNull(@PhoneOrder, 1)

	INSERT INTO EmployeeServiceQueueOrderPhones
	(
		EmployeeServiceQueueOrderMethodID,
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
		@EmployeeServiceQueueOrderMethodID,
		1,
		@PhoneOrder,
		@prePrefix,
		@prefix,
		@phone,
		@extension,
		@updateUser
	)
	
	SET @ErrCode = @@Error


GO


GRANT EXEC ON rpc_InsertEmployeeServiceQueueOrderPhone TO PUBLIC
GO