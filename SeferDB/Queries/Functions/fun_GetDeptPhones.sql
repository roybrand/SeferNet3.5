IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptPhones')
	BEGIN
		DROP  function  fun_GetDeptPhones
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptPhones]
(
	@DeptCode int,
	@PhoneType int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ','
		+ CASE WHEN (DeptPhones.remark is NULL OR DeptPhones.remark = '') THEN '' ELSE DeptPhones.remark + ',' END
	FROM DeptPhones
	WHERE deptCode = @DeptCode
	AND DeptPhones.phoneType = @PhoneType
	ORDER BY phoneOrder

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END

GO


grant exec on fun_GetDeptPhones to public 
GO    

 