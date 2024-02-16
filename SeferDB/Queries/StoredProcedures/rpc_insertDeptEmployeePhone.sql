IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEmployeePhone')
	BEGIN
		DROP  Procedure  rpc_insertDeptEmployeePhone
	END

GO

CREATE Procedure dbo.rpc_insertDeptEmployeePhone
	(	
		@deptEmployeeID int,
		@phoneType int,
		@prePrefix int,
		@prefix int,
		@phone int,
		@extension int,		
		@updateUser varchar(50),
		@ErrCode int OUTPUT 
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
SET @PhoneOrder = (SELECT MAX(phoneOrder) + 1 
					FROM DeptEmployeePhones 
					WHERE DeptEmployeeID = @deptEmployeeID
					AND phoneType = @phoneType
				   )
SET @PhoneOrder = IsNull(@PhoneOrder,1)


	INSERT INTO DeptEmployeePhones
		(phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateUser, updateDate, DeptEmployeeID)
	VALUES
		(@phoneType, @PhoneOrder, @prePrefix, @prefix, @phone, @extension, @updateUser, getdate(), @deptEmployeeID)
		
	SET @ErrCode = @@Error


GO

GRANT EXEC ON rpc_insertDeptEmployeePhone TO PUBLIC

GO

