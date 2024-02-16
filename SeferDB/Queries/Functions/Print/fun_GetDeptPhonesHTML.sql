IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptPhonesHTML')
	BEGIN
		DROP  function  fun_GetDeptPhonesHTML
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptPhonesHTML]
(
	@DeptCode int,
	@PhoneType int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM DeptPhones
	WHERE deptCode = @DeptCode
	AND DeptPhones.phoneType = @PhoneType
	ORDER BY phoneOrder

	IF len(@p_str) > 1
	-- remove last <br>
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str) - 3)
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetDeptPhonesHTML to public 
GO    
