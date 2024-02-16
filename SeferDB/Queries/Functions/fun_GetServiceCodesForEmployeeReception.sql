--fun_GetServiceCodesForEmployeeReception 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fun_GetServiceCodesForEmployeeReception]
(
	@ReceptionID int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + CAST(serviceCode AS varchar(5)) + ','
	FROM deptEmployeeReceptionServices
	WHERE receptionID = @ReceptionID

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO
 