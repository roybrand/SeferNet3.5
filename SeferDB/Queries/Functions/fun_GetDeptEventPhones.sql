IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEventPhones')
	BEGIN
		DROP  function  fun_GetDeptEventPhones
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEventPhones]
(
	@DeptEventID int,
	@PhoneType int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ','
	FROM DeptEventPhones
	WHERE DeptEventID = @DeptEventID
	AND DeptEventPhones.phoneType = @PhoneType
	ORDER BY phoneOrder

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetDeptEventPhones to public 
GO    
 