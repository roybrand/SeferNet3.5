IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptPhoneForSubClinics')
	BEGIN
		DROP  Procedure  rpc_insertDeptPhoneForSubClinics
	END

GO

CREATE Procedure dbo.rpc_insertDeptPhoneForSubClinics
	(
		@DeptCode int,
		@PhoneType int,
		@PhoneOrder int,
		@PrePrefix int,
		@Prefix int,
		@Phone int,
		@Extension int,
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

	INSERT INTO DeptPhones
	( deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateUser )
	SELECT 
	deptCode, @PhoneType, @PhoneOrder, @PrePrefix, @Prefix, @Phone, @Extension, @UpdateUser
	FROM dept 
	WHERE deptCode IN (SELECT deptCode FROM dept WHERE subAdministrationCode = @DeptCode)

	
	SET @ErrCode = @@Error


GO

GRANT EXEC ON rpc_insertDeptPhoneForSubClinics TO PUBLIC

GO

