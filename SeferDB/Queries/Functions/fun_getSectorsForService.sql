 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getSectorsForService')
	BEGIN
		DROP  function  fun_getSectorsForService
	END
GO

CREATE FUNCTION [dbo].[fun_getSectorsForService]
(
	@serviceCode INT
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SELECT @p_str = @p_str + EmployeeSectorDescription + ', '
    FROM x_Services_EmployeeSector xses
    INNER JOIN EmployeeSector ON xses.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
    WHERE xses.ServiceCode = @serviceCode
        
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

  
GRANT EXEC ON fun_getSectorsForService to public 
GO 