IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'GetDeptPhoneNumber')
	BEGIN
		DROP  function  GetDeptPhoneNumber
	END
GO

CREATE FUNCTION [dbo].[GetDeptPhoneNumber]
(
	@DeptCode int,
	@PhoneType int,
	@PhoneOrder int
)
RETURNS varchar(100)

AS
BEGIN
	DECLARE @FullPhoneNumber varchar(100)
	
	SET @FullPhoneNumber =
	 (SELECT TOP 1
		dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
		FROM DeptPhones
		WHERE deptCode = @DeptCode AND DeptPhones.phoneType = @PhoneType AND phoneOrder = @PhoneOrder )
	
	IF ISNUMERIC(@FullPhoneNumber) = 1	/* phone num. can't be just a number*/
		BEGIN
			SET @FullPhoneNumber = ''
		END
	RETURN (CASE CAST(ISNULL(@FullPhoneNumber,'0') as varchar(100)) WHEN '0' THEN '' ELSE @FullPhoneNumber END)
END

GO

grant exec on GetDeptPhoneNumber to public 
GO    