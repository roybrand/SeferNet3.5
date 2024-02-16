
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEventPhone')
	BEGIN
		DROP  Procedure  rpc_insertDeptEventPhone
	END

GO

CREATE Procedure dbo.rpc_insertDeptEventPhone
	(
		@DeptEventID int,
		@prePrefix int,
		@prefix int,
		@phone int,
		@extension int,
		@updateUser varchar(50)
	)

AS

IF @Prefix = -1
	BEGIN
		SET @Prefix = null
	END
IF @PrePrefix = -1
	BEGIN
		SET @PrePrefix = null
	END
IF @extension = -1
	BEGIN
		SET @extension = null
	END

DECLARE @PhoneOrder int
SET @PhoneOrder = (SELECT MAX(phoneOrder) + 1 FROM DeptEventPhones WHERE DeptEventID = @DeptEventID)
IF(@PhoneOrder = 0)
BEGIN
	SET @PhoneOrder = 1
END
SET @PhoneOrder = IsNull(@PhoneOrder,1)

BEGIN 
	INSERT INTO DeptEventPhones
	(DeptEventID, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateDate, updateUser)
	VALUES
	(@DeptEventID, 1, @PhoneOrder, @prePrefix, @prefix, @phone, @extension, getdate(), @updateUser)

END 


GO

GRANT EXEC ON rpc_insertDeptEventPhone TO PUBLIC

GO