IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptPhone')
	BEGIN
		DROP  Procedure  rpc_insertDeptPhone
	END

GO

CREATE Procedure [dbo].[rpc_insertDeptPhone]
	(
		@DeptCode int,
		@PhoneType int,
		@PhoneOrder int,
		@PrePrefix int,
		@Prefix int,
		@Phone int,
		@Extension int,
		@Remark varchar(500),
		@UpdateUser varchar(50),
		
		@ErrCode int = 0 OUTPUT
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
IF @Extension = -1
	BEGIN
		SET @Extension = null
	END
	

	INSERT INTO DeptPhones
	( deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, Remark, updateUser )
	VALUES
	(@DeptCode, @PhoneType, @PhoneOrder, @PrePrefix, @Prefix, @Phone, @Extension, @Remark, @UpdateUser)
	
	SET @ErrCode = @@Error
GO

GRANT EXEC ON dbo.rpc_insertDeptPhone TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_insertDeptPhone TO [clalit\IntranetDev]
GO

