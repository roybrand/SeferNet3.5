 SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fun_GetEmployeeRemarksForReception]
(
	@receptionID int
)
RETURNS varchar(1000)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(1000)
    SET @p_str = ''

	SELECT @p_str = @p_str + IsNull(REPLACE(RemarkText, '#', ''), '') + ','
	FROM DeptEmployeeReceptionRemarks
	WHERE EmployeeReceptionID = @receptionID
	AND (ValidFrom is null OR ValidFrom <= getdate())
	AND (ValidTo is null OR ValidTo >= getdate())

	IF len(@p_str) = 1
		SET @p_str = ''
	
	IF len(@p_str) > 1
	-- remove last comma from the string
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str)) 
	END
	
    RETURN @p_str

END
GO



