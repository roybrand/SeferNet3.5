
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeePhone')
	BEGIN
		DROP  Procedure  rpc_insertEmployeePhone
	END

GO

CREATE Procedure dbo.rpc_insertEmployeePhone
	(
		@employeeID bigint,
		@phoneType int,
		@phoneOrder int,
		@prePrefix int,
		@prefix int,
		@phone int,
		@extension int,
		@isUnlisted tinyint,
		@updateUser varchar(50)
	)

AS
	IF(@prePrefix = -1)
	BEGIN
		SET @prePrefix = null
	END
	IF @prefix = -1
	BEGIN
		SET @prefix = null
	END

	IF(@extension = -1)
	BEGIN
		SET @extension = null
	END	

		INSERT INTO EmployeePhones
		(employeeID, phoneType, phoneOrder, prePrefix, prefix, phone, extension, isUnlisted, updateUser)
		VALUES
		(@employeeID, @phoneType, @phoneOrder, @prePrefix, @prefix, @phone, @extension, @isUnlisted, @updateUser)	
GO

GRANT EXEC ON rpc_insertEmployeePhone TO PUBLIC

GO
