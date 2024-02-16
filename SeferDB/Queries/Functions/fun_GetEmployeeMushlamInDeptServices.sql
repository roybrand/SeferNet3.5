IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetEmployeeMushlamInDeptServices')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeMushlamInDeptServices
	END
GO 

CREATE FUNCTION [dbo].[fun_GetEmployeeMushlamInDeptServices] 
(
	@EmployeeID int, 
	@DeptCode int,
	@isOrderASC bit
)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN 

    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    	
	declare @tempTable table
	(
		serviceDescription VARCHAR(100)
	)


	INSERT INTO @tempTable        
    SELECT [Services].serviceDescription    
    FROM x_Dept_Employee_Service
    INNER JOIN [Services] ON x_Dept_Employee_Service.serviceCode = [Services].serviceCode
	INNER JOIN x_Dept_Employee xd ON x_Dept_Employee_service.DeptEmployeeID = xd.DeptEmployeeID
    WHERE xd.employeeID = @EmployeeID
    AND xd.deptCode = @DeptCode
    AND x_Dept_Employee_Service.Status = 1
	AND [Services].serviceCode <> 180300 --"התייעצות עם רופא מומחה למתן חוו''ד שניה"

    ORDER BY 
	CASE @isOrderASC
		WHEN 1 THEN [Services].serviceDescription 
		END,
	CASE WHEN @isOrderASC <> 1 OR @isOrderASC IS NULL THEN [Services].serviceDescription 
		END DESC    
    
    SELECT @p_str = @p_str + RTRIM(serviceDescription) + ', '
	FROM @tempTable    
    
    
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str) )
	END
	
    RETURN @p_str
	
END

