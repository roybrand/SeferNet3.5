IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMainDeptPhone')
	BEGIN
		DROP  Procedure  rpc_GetMainDeptPhone
	END

GO

CREATE Procedure dbo.rpc_GetMainDeptPhone
(
		@deptCode INT,
		@phoneType INT,
		@phoneNumber VARCHAR(30) OUTPUT
)

AS

SET @phoneNumber = ''

SELECT @phoneNumber = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
FROM DeptPhones
WHERE deptCode = @deptCode AND PhoneType = @phoneType AND PhoneOrder = 1


GO


GRANT EXEC ON rpc_GetMainDeptPhone TO PUBLIC

GO


